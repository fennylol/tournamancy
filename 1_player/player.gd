extends CharacterBody3D
class_name Player

#region BASE STATISTICS
var BASE_HEARTS         : float = 0.0
var BASE_ARMOR          : float = 0.0
var BASE_WARD           : float = 0.0
var BASE_OVERHEALTH     : float = 0.0
var BASE_ARMOR_STRENGTH : float = 0.0
var BASE_WARD_STRENGTH  : float = 0.0
var BASE_LIFESTEAL      : float = 0.0
var BASE_DAMAGE         : float = 0.0
var BASE_RANGE          : float = 0.0
var BASE_COOLDOWN       : float = 0.0
var BASE_FORCE          : float = 0.0
var BASE_CRIT           : float = 0.0
var BASE_LUCK           : float = 0.0
var BASE_SPEED          : float = 0.0
var BASE_SPRINT         : float = 0.0
var BASE_JUMP           : float = 0.0
var BASE_GRAVITY        : float = 0.0
var BASE_STEADFASTNESS  : float = 0.0
var BASE_MELEE_DAMAGE   : float = 0.0
var BASE_MELEE_RANGE    : float = 0.0
var BASE_MELEE_FORCE    : float = 0.0
var BASE_MELEE_COOLDOWN : float = 0.0
#endregion

const TRANSFORM_DATA_SIZE: int = (4*9)+1
#const HAND_IMG : Texture2D = preload("res://4_ui/hud/Lhand.png")
#const POINT_IMG: Texture2D = preload("res://4_ui/hud/Lpoint.png")

## NODES
@onready var CAMERA    := $Eyes
@onready var LOOK_DIR  := $Eyes/RayCast3D
#@onready var L_HAND    := $Eyes/Lhand
#@onready var R_HAND    := $Eyes/Rhand
@onready var LEFT_ARM  := $Eyes/LEFTARM
@onready var RIGHT_ARM := $Eyes/RIGHTARM
@onready var EFFECTORY := $Effectory
@onready var HUD       := $DefaultHud
var HUD_LEFT_ACTIVE    : Node2D
var HUD_RIGHT_ACTIVE   : Node2D
var HUD_PASSIVEBOX     : Node2D
var HUD_HEALTHBAR      : HealthDisplay

## SETTINGS AND REFERENCE FILES
var personal_settings : PersonalSettings = PersonalSettings.new()
var SpellBook: Grimoire = Grimoire.new()

## LOCAL VARIABLES
var is_sprinting : bool = false
var Enabled: bool = false:
   set(new_val):
      Enabled = new_val
      enabled_changed.emit(new_val)
      if Enabled:
         Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
      else:
         Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## SIGNALS
signal enabled_changed(new_val:bool)
signal spell_equipped(spell_id: int, is_active: bool)
signal spell_change_state(spell_id: int, is_active: bool, new_state: int)

# =========== #
#    setup    #
# =========== #

func _ready() -> void:
   HUD_LEFT_ACTIVE = HUD.find_child("Actives").find_child("ActiveIcon(L)")
   HUD_RIGHT_ACTIVE = HUD.find_child("Actives").find_child("ActiveIcon(R)")
   HUD_PASSIVEBOX = HUD.find_child("PassiveBox").find_child("PassiveIcons")
   HUD_HEALTHBAR = HUD.find_child("HealthPoints").find_child("HealthDisplay")
   SpellBook.spell_equipped.connect(_on_grimoire_spell_equipped)
   SpellBook.spell_change_state.connect(_on_grimoire_change_effect_state) # TODO: make this work.

# =================== #
# _process() handling #
# =================== #

func _process(delta):
   
   ## MOUSE CAPTURE
   if Input.is_action_just_pressed("menu"):
      Enabled = !Enabled
   
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

# =============== #
# simple movement #
# =============== #

func _physics_process(delta):
   ## GET RELEVANT INFLUENCED STATS
   var influenced_speed   : float = SpellData.get_influenced_stat(SpellData.StatTypes.SPEED, BASE_SPEED, SpellBook.get_stat(SpellData.StatTypes.SPEED))
   var influenced_sprint  : float = SpellData.get_influenced_stat(SpellData.StatTypes.SPRINT, BASE_SPRINT, SpellBook.get_stat(SpellData.StatTypes.SPRINT))
   var influenced_jump    : float = SpellData.get_influenced_stat(SpellData.StatTypes.JUMP, BASE_JUMP, SpellBook.get_stat(SpellData.StatTypes.JUMP))
   var influenced_gravity : float = SpellData.get_influenced_stat(SpellData.StatTypes.GRAVITY, BASE_GRAVITY, SpellBook.get_stat(SpellData.StatTypes.GRAVITY))
   
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
   var input_dir = Input.get_vector("left", "right", "up", "down")
   var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() if is_on_floor() else (Vector3(velocity.x, 0, velocity.z)).normalized()
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

# ================= #
# data manipulation #
# ================= #

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
## Called by the game manager (Tournamancy.gd) with the statistics passed in from a MatchSettings object.
func sync_statistics(stat_dict : Dictionary):
   BASE_HEARTS         = stat_dict.get(SpellData.StatTypes.HEARTS)
   BASE_ARMOR          = stat_dict.get(SpellData.StatTypes.ARMOR)
   BASE_WARD           = stat_dict.get(SpellData.StatTypes.WARD)
   BASE_OVERHEALTH     = stat_dict.get(SpellData.StatTypes.OVERHEALTH)
   BASE_ARMOR_STRENGTH = stat_dict.get(SpellData.StatTypes.ARMOR_STRENGTH)
   BASE_WARD_STRENGTH  = stat_dict.get(SpellData.StatTypes.WARD_STRENGTH)
   BASE_LIFESTEAL      = stat_dict.get(SpellData.StatTypes.LIFESTEAL)
   BASE_DAMAGE         = stat_dict.get(SpellData.StatTypes.DAMAGE)
   BASE_RANGE          = stat_dict.get(SpellData.StatTypes.RANGE)
   BASE_COOLDOWN       = stat_dict.get(SpellData.StatTypes.COOLDOWN)
   BASE_FORCE          = stat_dict.get(SpellData.StatTypes.FORCE)
   BASE_CRIT           = stat_dict.get(SpellData.StatTypes.CRIT)
   BASE_LUCK           = stat_dict.get(SpellData.StatTypes.LUCK)
   BASE_SPEED          = stat_dict.get(SpellData.StatTypes.SPEED)
   BASE_SPRINT         = stat_dict.get(SpellData.StatTypes.SPRINT)
   BASE_JUMP           = stat_dict.get(SpellData.StatTypes.JUMP)
   BASE_GRAVITY        = stat_dict.get(SpellData.StatTypes.GRAVITY)
   BASE_STEADFASTNESS  = stat_dict.get(SpellData.StatTypes.STEADFASTNESS)
   BASE_MELEE_DAMAGE   = stat_dict.get(SpellData.StatTypes.MELEE_DAMAGE)
   BASE_MELEE_RANGE    = stat_dict.get(SpellData.StatTypes.MELEE_RANGE)
   BASE_MELEE_FORCE    = stat_dict.get(SpellData.StatTypes.MELEE_FORCE)
   BASE_MELEE_COOLDOWN = stat_dict.get(SpellData.StatTypes.MELEE_COOLDOWN)

# ==================== #
# just passin' through #
# ==================== #

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
func get_cooldown() -> float:  return SpellData.get_influenced_stat(SpellData.StatTypes.COOLDOWN, BASE_COOLDOWN, SpellBook.get_stat(SpellData.StatTypes.COOLDOWN))
func _on_grimoire_spell_equipped(spell_id: int, is_active: bool) -> void: 
   EFFECTORY.equip_effect(spell_id, is_active)
   spell_equipped.emit(spell_id, is_active)
   if SpellBook.ActiveSpells[0]: SpellBook.ActiveSpells[0].identify_player(self)
   if SpellBook.ActiveSpells[1]: SpellBook.ActiveSpells[1].identify_player(self)
func _on_grimoire_spell_erase(spell_id: int, is_active: bool) -> void: 
   EFFECTORY.erase_effect(spell_id, is_active)
func _on_grimoire_change_effect_state(spell_id: int, is_active: bool, spell_state: int) -> void:
   EFFECTORY.change_effect_state(spell_id, is_active, spell_state)
   spell_change_state.emit(spell_id, is_active, spell_state)
