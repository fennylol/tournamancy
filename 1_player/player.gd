extends CharacterBody3D
class_name Player

const TRANSFORM_DATA_SIZE: int = (4*9)+1

## NODES
@onready var CAMERA    : Camera3D        = $Eyes
@onready var LOOK_DIR  : RayCast3D       = $Eyes/RayCast3D
@onready var LEFT_ARM  : Node3D          = $Eyes/LEFTARM
@onready var RIGHT_ARM : Node3D          = $Eyes/RIGHTARM
@onready var EFFECTORY : Effectory       = $Effectory
@onready var HEALTHBAR : HealthComponent = $Healthbar
@onready var HUD       : Control         = $CanvasLayer/DefaultHud
@onready var PRISMMENU : PrismMenu       = $CanvasLayer/PrismMenu

@onready var HAT_MESH: MeshInstance3D = $Eyes/HAT
@onready var ARM_L_MESH: MeshInstance3D = $Eyes/LEFTARM/ARM_L
@onready var ARM_R_MESH: MeshInstance3D = $Eyes/RIGHTARM/ARM_R
var HUD_LEFT_ACTIVE    : Node2D
var HUD_RIGHT_ACTIVE   : Node2D
var HUD_PASSIVEBOX     : Node2D
var HUD_HEALTHBAR      : HealthDisplay

## SETTINGS AND REFERENCE FILES
var personal_settings : PersonalSettings = PersonalSettings.new()
var SpellBook: Grimoire = Grimoire.new()
var MY_NETWORK_ID : int

## LOCAL VARIABLES
var is_sprinting  : bool = false
var prism_is_open : bool = false
var Enabled: bool = false:
   set(new_val):
      Enabled = new_val
      if Enabled:
         Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
      else:
         Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## SIGNALS
signal open_connection_menu_please(show_menu:bool)
signal spell_equipped(spell_id: int, is_active: bool)
signal player_spell_change_state(spell_id: int, is_active: bool, new_state: int)
signal damage_dealt(package : DamagePackage)
signal familiar_spawned(spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray)

# =========== #
#    setup    #
# =========== #

func _ready() -> void:
   HUD_LEFT_ACTIVE = HUD.find_child("Actives").find_child("ActiveIcon(L)")
   HUD_RIGHT_ACTIVE = HUD.find_child("Actives").find_child("ActiveIcon(R)")
   HUD_PASSIVEBOX = HUD.find_child("PassiveBox").find_child("PassiveIcons")
   HUD_HEALTHBAR = HUD.find_child("HealthPoints").find_child("HealthDisplay")
   SpellBook.ThePlayer = self
   SpellBook.spell_equipped.connect(_on_grimoire_spell_equipped)
   SpellBook.passive_spell_updated.connect(_on_grimoire_spell_updated)
   SpellBook.spell_change_state.connect(_on_grimoire_change_effect_state)
   PRISMMENU.close_menu.connect(close_prism)
   PRISMMENU.visible = false
   set_colors()

   var starting_health : Array[float] = [
      SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.HEARTS],
      SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.ARMOR],
      SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.WARD],
      SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.OVERHEALTH]
   ]
   _update_heath_display(starting_health)

# =================== #
# _process() handling #
# =================== #

func _process(delta):
   
   ## MOUSE CAPTURE
   if Input.is_action_just_pressed("menu"):
      if prism_is_open: return
      Enabled = !Enabled
      open_connection_menu_please.emit(not(Enabled))
   
   
   ## PASSIVE PROCESSES, BEGIN
   if Enabled: SpellBook.process_begin(delta, self)
   
   ## JOYPAD CAMERA MOVEMENT
   var cam_horizontal : float = Input.get_axis("camera_left","camera_right")
   var cam_vertical   : float = Input.get_axis("camera_down", "camera_up")
   self.rotation.y += cam_horizontal * 0.05 * personal_settings.JOYSTICK_SENSITIVITY_X
   CAMERA.rotation.x += cam_vertical * 0.05 * personal_settings.JOYSTICK_SENSITIVITY_X
   CAMERA.rotation.x = clamp(CAMERA.rotation.x, -PI/2, PI/2)
   
   ## CHANGE HAND TEXTURES
   #if Input.is_action_just_pressed("interact") and Enabled: 
      #L_HAND.texture = POINT_IMG
   #elif Input.is_action_just_released("interact") or not Enabled: 
      #L_HAND.texture = HAND_IMG
   
   if Input.is_action_just_pressed("active_spell_0") and Enabled:
      #L_HAND.texture = POINT_IMG
      LEFT_ARM.rotation.x = -80.0
      HUD_LEFT_ACTIVE._hold()
      if SpellBook.ActiveSpells[0]:
         SpellBook.ActiveSpells[0]._on_activate(self)
   elif Input.is_action_just_released("active_spell_0") or not Enabled: 
      #L_HAND.texture = HAND_IMG
      LEFT_ARM.rotation.x = 0.0
      HUD_LEFT_ACTIVE._release()
   
   if Input.is_action_just_pressed("active_spell_1") and Enabled:
      #R_HAND.texture = POINT_IMG
      RIGHT_ARM.rotation.x = -80.0
      HUD_RIGHT_ACTIVE._hold()
      if SpellBook.ActiveSpells[1]:
         SpellBook.ActiveSpells[1]._on_activate(self)      
   elif Input.is_action_just_released("active_spell_1") or not Enabled: 
      #R_HAND.texture = HAND_IMG 
      RIGHT_ARM.rotation.x = 0.0
      HUD_RIGHT_ACTIVE._release()
   
   ## PASSIVE PROCESSES, BEGIN
   if Enabled: SpellBook.process_end(delta, self)
   
   ## UPDATE COOLDOWN VISUALIZERS ON HUD
   if SpellBook.ActiveSpells[0]: HUD_LEFT_ACTIVE.update_cooldown(SpellBook.ActiveSpells[0].get_cooldown())
   if SpellBook.ActiveSpells[1]: HUD_RIGHT_ACTIVE.update_cooldown(SpellBook.ActiveSpells[1].get_cooldown())

func _unhandled_input(event):
   ## HANDLE MOUSE-TO-CAMERA INPUT
   if event is InputEventMouseMotion and Enabled:
      rotate_y(-event.relative.x * .005 * personal_settings.MOUSE_SENSITIVITY)
      CAMERA.rotate_x(-event.relative.y * .005 * personal_settings.MOUSE_SENSITIVITY)
      CAMERA.rotation.x = clamp(CAMERA.rotation.x, -PI/2, PI/2)

# =================== #
#   simple movement   #
# =================== #

func _physics_process(delta):
   ## GET RELEVANT INFLUENCED STATS
   var influenced_speed   : float = SpellData.get_influenced_stat(SpellData.StatTypes.SPEED,   SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.SPEED],   SpellBook.get_stat(SpellData.StatTypes.SPEED))
   var influenced_sprint  : float = SpellData.get_influenced_stat(SpellData.StatTypes.SPRINT,  SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.SPRINT],  SpellBook.get_stat(SpellData.StatTypes.SPRINT))
   var influenced_jump    : float = SpellData.get_influenced_stat(SpellData.StatTypes.JUMP,    SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.JUMP],    SpellBook.get_stat(SpellData.StatTypes.JUMP))
   var influenced_gravity : float = SpellData.get_influenced_stat(SpellData.StatTypes.GRAVITY, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.GRAVITY], SpellBook.get_stat(SpellData.StatTypes.GRAVITY))
   
   ## GRAVITY AND JUMP VELOCITY
   if not is_on_floor(): velocity.y -= influenced_gravity * delta
   if Input.is_action_pressed("jump") and is_on_floor() and Enabled: velocity.y = influenced_jump
   
   ## PLAYER SPRINTS IF THEY A) ARE ALREADY SPRINTING OR B) PRESS THE "SPRINT" BUTTON. STOP SPRINTING WHEN STOP MOVING. CANNOT START/STOP SPRINTING IN THE AIR.
   var sprint_multi : float = 1.0
   if velocity.x == 0 and velocity.z == 0: is_sprinting = false
   if not is_on_floor():
      sprint_multi = influenced_sprint if is_sprinting else 1.0
   else:
      if Input.is_action_pressed("sprint"): is_sprinting = true
      if is_sprinting: sprint_multi = influenced_sprint
   
   ## HORIZONTAL MOVEMENT
   var input_dir := Input.get_vector("left", "right", "up", "down")
   var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
   if direction and Enabled:
      velocity.x = direction.x * influenced_speed * sprint_multi
      velocity.z = direction.z * influenced_speed * sprint_multi
   else:
      velocity.x = move_toward(velocity.x, 0, influenced_speed)
      velocity.z = move_toward(velocity.z, 0, influenced_speed)

   ## INTERACTABLES
   if Input.is_action_pressed("interact") and Enabled:
      if LOOK_DIR.is_colliding():
         var hit = LOOK_DIR.get_collider()
         if hit is Interactable:
            hit._on_interact(self)
   move_and_slide()

# ================== #
#   prism handling   #
# ================== #

func open_prism(prism : Prism):
   prism_is_open = true
   PRISMMENU.visible = true
   Enabled = false
   PRISMMENU.setup(prism)
func close_prism(prism : Prism):
   prism_is_open = false
   PRISMMENU.visible = false
   Enabled = true
   prism.destroy_self_if_limit()

# =================== #
#  data manipulation  #
# =================== #

## Encodes player data to be sent to multiplayer peers.
func generate_transform_data() -> PackedByteArray:
   var packed_data := PackedByteArray()
   packed_data.resize(TRANSFORM_DATA_SIZE)
   
   packed_data.encode_float(0,  position.x)
   packed_data.encode_float(4,  position.y) 
   packed_data.encode_float(8,  position.z)
   packed_data.encode_float(12, CAMERA.rotation.x)
   packed_data.encode_float(16, rotation.y) 
   packed_data.encode_float(20, rotation.z)
   packed_data.encode_float(24, velocity.x)
   packed_data.encode_float(28, velocity.y)
   packed_data.encode_float(32, velocity.z)
   
   var flags := 0
   #if L_HAND.texture == HAND_IMG: flags |= 1 << 0
   #if R_HAND.texture == HAND_IMG: flags |= 1 << 1
   if LEFT_ARM.rotation.x  == 0.0: flags |= 1 << 0
   if RIGHT_ARM.rotation.x == 0.0: flags |= 1 << 1
   packed_data.encode_u8(36, flags)
   
   return packed_data

func sync_health():
   var new_health : Array[float] = [
      SpellData.get_influenced_stat(SpellData.StatTypes.HEARTS,     SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.HEARTS],     SpellBook.get_stat(SpellData.StatTypes.HEARTS)),\
      SpellData.get_influenced_stat(SpellData.StatTypes.ARMOR,      SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.ARMOR],      SpellBook.get_stat(SpellData.StatTypes.ARMOR)),\
      SpellData.get_influenced_stat(SpellData.StatTypes.WARD,       SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.WARD],       SpellBook.get_stat(SpellData.StatTypes.WARD)),\
      SpellData.get_influenced_stat(SpellData.StatTypes.OVERHEALTH, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.OVERHEALTH], SpellBook.get_stat(SpellData.StatTypes.OVERHEALTH))
   ]
   _update_heath_display(new_health)

func _update_heath_display(new_health : Array[float]) -> void:
   HEALTHBAR.set_health(new_health)
   HUD_HEALTHBAR.update_display(HEALTHBAR.get_health(), false)


func set_colors() -> void:
   var primary_mat := StandardMaterial3D.new()
   primary_mat.albedo_color = SettingsManager.personal_settings.PRIMARY_COLOR
   
   var secondary_mat := StandardMaterial3D.new()
   secondary_mat.albedo_color = SettingsManager.personal_settings.SECONDARY_COLOR
   
   HAT_MESH.set_surface_override_material(0, secondary_mat)
   
   ARM_L_MESH.set_surface_override_material(0, primary_mat)
   ARM_R_MESH.set_surface_override_material(0, primary_mat)

# ====================== #
#  just passin' through  #
# ====================== #

## Called by an interactable when it adds or removes a spell. Adds or removes the textures of said spells in the player's HUD.
func update_HUD_icons():
   ## ACTIVE SPELL ICONS
   var active_spell_l = SpellBook.ActiveSpells[0].SpellID if SpellBook.ActiveSpells[0] else -1
   var active_spell_r = SpellBook.ActiveSpells[1].SpellID if SpellBook.ActiveSpells[1] else -1
   HUD_LEFT_ACTIVE._update_icon(active_spell_l)
   HUD_RIGHT_ACTIVE._update_icon(active_spell_r)
   ## PASSIVE SPELL ICONS
   HUD_PASSIVEBOX.import_passive_spells(SpellBook.PassiveSpells, true)
## Called by the base ActiveSpell class to get the players "stat influenced cooldown" which is multiplied with the delta each frame to reduce that spell's cooldown timer.
func get_cooldown() -> float:  return SpellData.get_influenced_stat(SpellData.StatTypes.COOLDOWN,  SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.COOLDOWN], SpellBook.get_stat(SpellData.StatTypes.COOLDOWN))
## returns the SpellID of the active currently in [member hand]. returns SpellData.ActiveSpellIDs.ERROR if there is no active in that hand.
func get_active(hand : int) -> SpellData.ActiveSpellIDs: return SpellBook.ActiveSpells[hand].SpellID as SpellData.ActiveSpellIDs if SpellBook.ActiveSpells[hand] else SpellData.ActiveSpellIDs.ERROR
## Called by the PrismMenu with a given spellID and hand. Asks the SpellBook to add that spell, then updates the HUD.
func request_new_active_spell(id : SpellData.ActiveSpellIDs, slot : int):
   SpellBook.add_active(id, slot)
   update_HUD_icons()
func request_new_passive_spell(id: SpellData.PassiveSpellIDs, stacks : int):
   SpellBook.add_passive(id, stacks)
   update_HUD_icons()
## Passes a list of actives and passives to the Effectory. That's it. Effectory takes it from there.
func sync_effectory(list_of_actives : Array[SpellData.ActiveSpellIDs], list_of_passives : Array[SpellData.PassiveSpellIDs]): 
   EFFECTORY.sync_effects(list_of_actives, list_of_passives)
func send_damage_package(package : DamagePackage):
   damage_dealt.emit(package)
func on_damage_data(package : DamagePackage):
   HEALTHBAR.on_damage_data(package)
   HUD_HEALTHBAR.update_display(HEALTHBAR.get_health(), false)
func _on_grimoire_spell_equipped(spell_id: int, is_active: bool) -> void: 
   EFFECTORY.equip_effect(spell_id, is_active)
   spell_equipped.emit(spell_id, is_active)
   if SpellBook.ActiveSpells[0]: SpellBook.ActiveSpells[0].identify_player(self)
   if SpellBook.ActiveSpells[1]: SpellBook.ActiveSpells[1].identify_player(self)
func _on_grimoire_spell_updated(spell_id : int):
   pass
func _on_grimoire_spell_erase(spell_id: int, is_active: bool) -> void: 
   EFFECTORY.erase_effect(spell_id, is_active)
func _on_grimoire_change_effect_state(spell_id: int, is_active: bool, spell_state: int) -> void:
   EFFECTORY.change_effect_state(spell_id, is_active, spell_state)
   player_spell_change_state.emit(spell_id, is_active, spell_state)
func spawn_familiar(is_active: bool, spell_id: int, familiar_idx: int, creation_data: PackedByteArray) -> void:
   familiar_spawned.emit(is_active, spell_id, familiar_idx, creation_data)
