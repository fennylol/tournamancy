extends CharacterBody3D
class_name Player

const TRANSFORM_DATA_SIZE: int = (4*9)+1

## NODES
@onready var CAMERA    : Camera3D        = $Eyes
@onready var LOOK_DIR  : RayCast3D       = $Eyes/RayCast3D
@onready var MELEEBOX  : Area3D          = $Eyes/quickmelee

@onready var LEFT_ARM  : Node3D          = $Eyes/LEFTARM
@onready var RIGHT_ARM : Node3D          = $Eyes/RIGHTARM
@onready var HAT_MESH  : MeshInstance3D  = $Eyes/HAT
@onready var ARM_L_MESH: MeshInstance3D  = $Eyes/LEFTARM/ARM_L
@onready var ARM_R_MESH: MeshInstance3D  = $Eyes/RIGHTARM/ARM_R

@onready var EFFECTORY : Effectory       = $Effectory
@onready var HEALTHBAR : HealthComponent = $Healthbar
@onready var HUD       : HeadsUpDisplay  = $CanvasLayer/HeadsUpDisplay
@onready var THE_WHEEL : SelectionWheel  = $CanvasLayer/GenericSelectionWheel
@onready var PRISMMENU : PrismMenu       = $CanvasLayer/PrismMenu

## SETTINGS AND REFERENCE FILES
var personal_settings : PersonalSettings = PersonalSettings.new()
var SpellBook: Grimoire = Grimoire.new()
var NETWORK_ID : int

## LOCAL VARIABLES
var Enabled: bool = false:
   set(new_val):
      Enabled = new_val
      if Enabled:
         Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
      else:
         Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
var is_sprinting  : bool = false
var shove_vector  := Vector3.ZERO
var prism_is_open : bool = false
var time_since_melee  : float = 0.0
const MELEE_WAIT : float = 1.0
var ActiveMeshArray : Array[Node3D] = []

## SIGNALS
signal open_connection_menu_please(show_menu:bool)

signal spell_equipped(spell_id: int, is_active: bool)
signal spell_erased(spell_id: int, is_active: bool)
signal spell_updated(spell_id: int, is_active: bool)
signal spell_changed_state(spell_id: int, is_active: bool, new_state: int)

signal damage_dealt(package : DamagePackage)
signal familiar_spawned(spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray)

# =========== #
#    setup    #
# =========== #

func _ready() -> void:
   SpellBook.ThePlayer = self
   SpellBook.spell_equipped.connect(_on_grimoire_spell_equipped)
   SpellBook.spell_erased.connect(_on_grimoire_spell_erased)
   SpellBook.spell_updated.connect(_on_grimoire_spell_updated)
   SpellBook.spell_change_state.connect(_on_change_spell_state)
   EFFECTORY.spell_state_changed.connect(_on_change_spell_state)
   PRISMMENU.close_menu.connect(close_prism)
   PRISMMENU.visible = false
   THE_WHEEL.visible = false
   set_colors()
   
   #ActiveMeshArray.resize(SpellBook.ActiveSlots)
   ActiveMeshArray = [LEFT_ARM,RIGHT_ARM]
   
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
      HUD.visible = Enabled
   
   ## HUD PROCESS
   HUD.process(delta)
   
   ## PASSIVE PROCESSES, BEGIN
   if Enabled: SpellBook.process_begin(delta, self)
   
   ## JOYPAD CAMERA MOVEMENT
   var cam_horizontal : float = Input.get_axis("camera_left","camera_right")
   var cam_vertical   : float = Input.get_axis("camera_down", "camera_up")
   self.rotation.y += cam_horizontal * 0.05 * personal_settings.JOYSTICK_SENSITIVITY_X
   CAMERA.rotation.x += cam_vertical * 0.05 * personal_settings.JOYSTICK_SENSITIVITY_X
   CAMERA.rotation.x = clamp(CAMERA.rotation.x, -PI/2, PI/2)
   
   ## ACTIVE ABILITIES
   for i in range(SpellBook.ActiveSlots):
      if not Enabled: continue
      var input_button : String = "active_spell_" + str(i)
      if   Input.is_action_just_pressed (input_button): 
         if SpellBook.ActiveSpells[i]: SpellBook.ActiveSpells[i]._on_activate(self)
         ActiveMeshArray[i].rotation.x = -80.0
      elif Input.is_action_pressed      (input_button): 
         if SpellBook.ActiveSpells[i]: SpellBook.ActiveSpells[i]._on_hold(self, delta)
         HUD.hold_active(i)
      elif Input.is_action_just_released(input_button): 
         if SpellBook.ActiveSpells[i]: SpellBook.ActiveSpells[i]._on_release(self)
         ActiveMeshArray[i].rotation.x = 0.0
   
   ## QUICK MELEE
   time_since_melee += delta * SpellData.get_influenced_stat(SpellData.StatTypes.MELEE_COOLDOWN,SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.MELEE_COOLDOWN],SpellBook.get_stat(SpellData.StatTypes.MELEE_COOLDOWN))
   if Input.is_action_just_pressed("quick_melee") and Enabled:
      if time_since_melee >= MELEE_WAIT:
         LEFT_ARM.rotation.x = -80.0
         RIGHT_ARM.rotation.x = -80.0
         _melee_attack()
         time_since_melee = 0.0
   elif Input.is_action_just_released("quick_melee") and Enabled:
      LEFT_ARM.rotation.x = 0.0
      RIGHT_ARM.rotation.x = 0.0
   
   ## DEBUG ACTION (DELETE ON RELEASE)
   if Input.is_action_just_pressed("debug"):
      THE_WHEEL.visible = true
      var contents : Array[AtlasTexture] = []
      contents.resize(8)
      for i in range(contents.size()):
         contents[i] = AtlasTexture.new()
         contents[i].atlas = load("res://2_spells/actives/misc_active_icons.png")
         contents[i].region = Rect2(32*i,0,32,32) if i <= 3 else Rect2(32*(i-4),32,32,32)
      THE_WHEEL.generate_wheel(contents)
   if Input.is_action_just_released("debug"):
      THE_WHEEL.visible = false
   
   ## PASSIVE PROCESSES, BEGIN
   if Enabled: SpellBook.process_end(delta, self)
   
   ## UPDATE COOLDOWN VISUALIZERS ON HUD
   if SpellBook.ActiveSpells[0]: HUD.update_active_cooldown(0, SpellBook.ActiveSpells[0].get_cooldown())
   if SpellBook.ActiveSpells[1]: HUD.update_active_cooldown(1, SpellBook.ActiveSpells[1].get_cooldown())

func _unhandled_input(event):
   ## HANDLE MOUSE-TO-CAMERA INPUT
   if event is InputEventMouseMotion and Enabled:
      rotate_y(-event.relative.x * .005 * personal_settings.MOUSE_SENSITIVITY)
      CAMERA.rotate_x(-event.relative.y * .005 * personal_settings.MOUSE_SENSITIVITY)
      CAMERA.rotation.x = clamp(CAMERA.rotation.x, -PI/2, PI/2)
   ## CHANGE BUTTON PROMPTS
   if event is InputEventKey or \
      event is InputEventMouseMotion or  \
      event is InputEventMouseButton: 
         HUD.swap_button_prompts(true)
   elif event is InputEventJoypadButton or \
        event is InputEventJoypadMotion: 
         HUD.swap_button_prompts(false)

func _melee_attack():
   ## RESIZE MELEE AREA
   var stat_influenced_melee_range : float = SpellData.get_influenced_stat(SpellData.StatTypes.MELEE_RANGE, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.MELEE_RANGE], SpellBook.get_stat(SpellData.StatTypes.MELEE_RANGE))
   MELEEBOX.get_child(0).position.z = -( ( stat_influenced_melee_range / 2 ) + 0.5 )
   MELEEBOX.get_child(0).shape.size = Vector3( stat_influenced_melee_range , stat_influenced_melee_range , stat_influenced_melee_range )
   
   ## CHECK FOR ENEMIES AND CONSTRUCT DAMAGE PACKAGE
   for i in MELEEBOX.get_overlapping_bodies():
      if i.get_parent() is Dummy:
         var enemy : Dummy = i.get_parent()
         var stat_influenced_damage : float = SpellData.get_influenced_stat(SpellData.StatTypes.MELEE_DAMAGE, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.MELEE_DAMAGE], SpellBook.get_stat(SpellData.StatTypes.MELEE_DAMAGE))
         var stat_influenced_force  : float = SpellData.get_influenced_stat(SpellData.StatTypes.MELEE_FORCE, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.MELEE_FORCE], SpellBook.get_stat(SpellData.StatTypes.MELEE_FORCE))
         var new_damage_package = DamagePackage.new()
         new_damage_package.id_from = NETWORK_ID
         new_damage_package.id_to = enemy.NETWORK_ID
         new_damage_package.location_source = global_position
         new_damage_package.location_receipt = enemy.global_position
         new_damage_package.amount = stat_influenced_damage
         new_damage_package.type = DamagePackage.DamageType.ZAP
         new_damage_package.force = stat_influenced_force
         send_damage_package(new_damage_package)

# =================== #
#   simple movement   #
# =================== #

func _physics_process(delta):
   ## GET RELEVANT INFLUENCED STATS
   var influenced_speed   : float = SpellData.get_influenced_stat(SpellData.StatTypes.SPEED,   SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.SPEED],   SpellBook.get_stat(SpellData.StatTypes.SPEED))
   var influenced_jump    : float = SpellData.get_influenced_stat(SpellData.StatTypes.JUMP,    SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.JUMP],    SpellBook.get_stat(SpellData.StatTypes.JUMP))
   var influenced_gravity : float = SpellData.get_influenced_stat(SpellData.StatTypes.GRAVITY, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.GRAVITY], SpellBook.get_stat(SpellData.StatTypes.GRAVITY))
   
   ## GRAVITY AND JUMP VELOCITY
   if not is_on_floor(): velocity.y -= influenced_gravity * delta
   if Input.is_action_pressed("jump") and is_on_floor() and Enabled: velocity.y = influenced_jump
   
   ## HORIZONTAL MOVEMENT
   var input_dir := Input.get_vector("left", "right", "up", "down")
   var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
   if direction and Enabled:
      velocity.x = direction.x * influenced_speed# * sprint_multi
      velocity.z = direction.z * influenced_speed# * sprint_multi
   else:
      velocity.x = move_toward(velocity.x, 0, influenced_speed)
      velocity.z = move_toward(velocity.z, 0, influenced_speed)
   
   ## DEAL WITH SHOVING EFFECTS
   if shove_vector != Vector3.ZERO:
      velocity += shove_vector
      shove_vector = shove_vector.normalized() * (shove_vector.length() * exp(-delta))
      if shove_vector.length() <= 0.01: shove_vector = Vector3.ZERO
   
   ## INTERACTABLES
   if Input.is_action_pressed("interact") and Enabled:
      if LOOK_DIR.is_colliding():
         var hit = LOOK_DIR.get_collider()
         if hit is Interactable:
            hit._on_interact(self)
   ## SEND INTERACTABLE DATA TO HUD
   if LOOK_DIR.is_colliding() and LOOK_DIR.get_collider() is Interactable:
      HUD.show_interactable_info(LOOK_DIR.get_collider())
   else:
      HUD.close_interactable_info()
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

func _update_heath_display(new_health : Array[float], add : bool = false) -> void:
   HEALTHBAR.set_health(new_health, add)
   HUD.update_healthbar(HEALTHBAR.get_health())

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
   HUD.update_active_icon(0,active_spell_l)
   HUD.update_active_icon(1,active_spell_r)
   #HUD_LEFT_ACTIVE._update_icon(active_spell_l)
   #HUD_RIGHT_ACTIVE._update_icon(active_spell_r)
   ## PASSIVE SPELL ICONS
   HUD.import_passive_spells(SpellBook.PassiveSpells, true)
   #HUD_PASSIVEBOX.import_passive_spells(SpellBook.PassiveSpells, true)
## Called by the base ActiveSpell class to get the players "stat influenced cooldown" which is multiplied with the delta each frame to reduce that spell's cooldown timer.
func get_cooldown() -> float:  return SpellData.get_influenced_stat(SpellData.StatTypes.COOLDOWN,SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.COOLDOWN],SpellBook.get_stat(SpellData.StatTypes.COOLDOWN))
## returns the SpellID of the active currently in [member hand]. returns SpellData.ActiveSpellIDs.ERROR if there is no active in that hand.
func get_active(hand : int) -> SpellData.ActiveSpellIDs: return SpellBook.ActiveSpells[hand].SpellID as SpellData.ActiveSpellIDs if SpellBook.ActiveSpells[hand] else SpellData.ActiveSpellIDs.ERROR
## Called by the PrismMenu with a given spellID and hand. Asks the SpellBook to add that spell, then updates the HUD.
func request_new_active_spell(id : SpellData.ActiveSpellIDs, slot : int):
   SpellBook.add_active(id, slot)
   update_HUD_icons()
## Called by the PrismMenu with a given spellID and stack count. Asks the SpellBook to add that spell, then updates the HUD.
func request_new_passive_spell(id: SpellData.PassiveSpellIDs, stacks : int):
   SpellBook.add_passive(id, stacks)
   update_HUD_icons()

func send_damage_package(package : DamagePackage):
   damage_dealt.emit(package)
func on_damage_data(package : DamagePackage):
   ## SEND DAMAGE TO HEALTHBAR
   HEALTHBAR.on_damage_data(package)
   HUD.update_healthbar(HEALTHBAR.get_health(), false)
   ## CHECK FOR SHOVE
   if package.force != 0.0:
      var influenced_steadfastness : float = SpellData.get_influenced_stat(SpellData.StatTypes.STEADFASTNESS,SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.STEADFASTNESS],SpellBook.get_stat(SpellData.StatTypes.STEADFASTNESS))
      shove_vector += (package.location_receipt - package.location_source).normalized() * package.force * ( 1 / influenced_steadfastness )

func _on_grimoire_spell_equipped(spell_id: int, is_active: bool) -> void: 
   EFFECTORY.equip_effect(spell_id, is_active)
   spell_equipped.emit(spell_id, is_active)
   if SpellBook.ActiveSpells[0]: SpellBook.ActiveSpells[0].identify_player(self)
   if SpellBook.ActiveSpells[1]: SpellBook.ActiveSpells[1].identify_player(self)
func _on_grimoire_spell_erased(spell_id: int, is_active: bool) -> void: 
   EFFECTORY.erase_effect(spell_id, is_active)
   spell_erased.emit(spell_id, is_active)
func _on_grimoire_spell_updated(spell_id: int, is_active: bool):
   spell_updated.emit(spell_id, is_active)
func _on_change_spell_state(spell_id: int, is_active: bool, spell_state: int) -> void:
   EFFECTORY.change_effect_state(spell_id, is_active, spell_state)
   SpellBook.change_spell_state(spell_id, is_active, spell_state)
   spell_changed_state.emit(spell_id, is_active, spell_state)

func spawn_familiar(is_active: bool, spell_id: int, familiar_idx: int, creation_data: PackedByteArray) -> void:
   familiar_spawned.emit(spell_id, is_active, familiar_idx, creation_data)

func announce_inventory() -> void:
   for spell:ActiveSpell in SpellBook.ActiveSpells:
      if spell: spell_equipped.emit(spell.SpellID, true)
   for spell:PassiveSpell in SpellBook.PassiveSpells:
      spell_equipped.emit(spell.SpellID, false)
