extends CharacterBody3D
class_name Player

const BASE_HEARTS : float = 0
const BASE_ARMOR : float = 0
const BASE_WARD : float = 0
const BASE_OVERHEALTH : float = 0
const BASE_ARMOR_STRENGTH : float = 0
const BASE_WARD_STRENGTH : float = 0
const BASE_LIFESTEAL : float = 0
const BASE_DAMAGE : float = 0
const BASE_RANGE : float = 0
const BASE_COOLDOWN : float = 0
const BASE_FORCE : float = 0
const BASE_CRIT : float = 0
const BASE_LUCK : float = 0
const BASE_SPEED : float = 5.0
const BASE_SPRINT : float = 0
const BASE_JUMP : float = 4.5
const BASE_GRAVITY : float = 9.8
const BASE_STEADFASTNESS : float = 0
const BASE_MELEE_DAMAGE : float = 0
const BASE_MELEE_RANGE : float = 0
const BASE_MELEE_FORCE : float = 0
const BASE_MELEE_COOLDOWN : float = 0

const TRANSFORM_DATA_SIZE: int = (4*9)+1
const HAND_IMG : Texture2D = preload("res://4_ui/hud/Lhand.png")
const POINT_IMG: Texture2D = preload("res://4_ui/hud/Lpoint.png")

@onready var CAMERA    := $Eyes
@onready var LOOK_DIR  := $Eyes/RayCast3D
@onready var L_HAND    := $Eyes/Lhand
@onready var R_HAND    := $Eyes/Rhand
@onready var LEFT_ARM  := $Eyes/LEFTARM
@onready var RIGHT_ARM := $Eyes/RIGHTARM
@onready var EFFECTORY := $Effectory
@onready var HUD       := $DefaultHud
var HUD_LEFT_ACTIVE    : Node2D
var HUD_RIGHT_ACTIVE   : Node2D
var HUD_PASSIVEBOX     : Node2D
var HUD_HEALTHBAR      : HealthDisplay

var Sensitivity = 0.5
var SpellBook: Grimoire = Grimoire.new()
var Enabled: bool = false:
   set(new_val):
      Enabled = new_val
      enabled_changed.emit(new_val)
      if Enabled:
         Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
      else:
         Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

signal enabled_changed(new_val:bool)
signal spell_equipped(spell_id: int, is_active: bool)
signal spell_change_state(spell_id: int, is_active: bool, new_state: int)

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
   
   if Enabled: SpellBook.process_begin(delta, self)
   
   ## JOYPAD CAMERA MOVEMENT
   var cam_horizontal : float = Input.get_axis("camera_left","camera_right")
   var cam_vertical   : float = Input.get_axis("camera_down", "camera_up")
   self.rotation.y += cam_horizontal * Sensitivity * 0.08
   CAMERA.rotation.x += cam_vertical * Sensitivity * 0.05
   CAMERA.rotation.x = clamp(CAMERA.rotation.x, -PI/2, PI/2)
   
   ## CHANGE HAND TEXTURES
   if Input.is_action_just_pressed("interact") and Enabled: 
      L_HAND.texture = POINT_IMG
   elif Input.is_action_just_released("interact") or not Enabled: 
      L_HAND.texture = HAND_IMG
   
   if Input.is_action_just_pressed("active_spell_0") and Enabled:
      L_HAND.texture = POINT_IMG
      LEFT_ARM.rotation.x = -80.0
      HUD_LEFT_ACTIVE._hold()
      if SpellBook.ActiveSpells[0]:
         SpellBook.ActiveSpells[0]._on_activate(self)
   elif Input.is_action_just_released("active_spell_0") or not Enabled: 
      L_HAND.texture = HAND_IMG
      LEFT_ARM.rotation.x = 0.0
      HUD_LEFT_ACTIVE._release()
   
   if Input.is_action_just_pressed("active_spell_1") and Enabled:
      R_HAND.texture = POINT_IMG
      RIGHT_ARM.rotation.x = -80.0
      HUD_RIGHT_ACTIVE._hold()
      if SpellBook.ActiveSpells[1]:
         SpellBook.ActiveSpells[1]._on_activate(self)      
   elif Input.is_action_just_released("active_spell_1") or not Enabled: 
      R_HAND.texture = HAND_IMG 
      RIGHT_ARM.rotation.x = 0.0
      HUD_RIGHT_ACTIVE._release()
   
   if Enabled: SpellBook.process_end(delta, self)
   
   if SpellBook.ActiveSpells[0]: HUD_LEFT_ACTIVE.update_cooldown(SpellBook.ActiveSpells[0].get_cooldown())
   if SpellBook.ActiveSpells[1]: HUD_RIGHT_ACTIVE.update_cooldown(SpellBook.ActiveSpells[1].get_cooldown())

func _unhandled_input(event):
   # handle mouse
   if event is InputEventMouseMotion and Enabled:
      rotate_y(-event.relative.x * .005 * Sensitivity)
      CAMERA.rotate_x(-event.relative.y * .005 * Sensitivity)
      CAMERA.rotation.x = clamp(CAMERA.rotation.x, -PI/2, PI/2)

# =============== #
# simple movement #
# =============== #
func _physics_process(delta):
    # vertical movement
   if not is_on_floor(): velocity.y -= get_influenced_stat(SpellData.StatTypes.GRAVITY) * delta
   if Input.is_action_pressed("jump") and is_on_floor() and Enabled: velocity.y = get_influenced_stat(SpellData.StatTypes.JUMP)
   
   # horizontal movement
   var input_dir = Input.get_vector("left", "right", "up", "down")
   var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
   
   if direction and Enabled:
      velocity.x = direction.x * get_influenced_stat(SpellData.StatTypes.SPEED)
      velocity.z = direction.z * get_influenced_stat(SpellData.StatTypes.SPEED)
   else:
      velocity.x = move_toward(velocity.x, 0, get_influenced_stat(SpellData.StatTypes.SPEED))
      velocity.z = move_toward(velocity.z, 0, get_influenced_stat(SpellData.StatTypes.SPEED))

   # use interactables
   if Input.is_action_pressed("interact") and Enabled:
      if LOOK_DIR.is_colliding():
         var hit = LOOK_DIR.get_collider()
         if hit is Interactable:
            hit._on_interact(self)
   move_and_slide()
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
   if L_HAND.texture == HAND_IMG: flags |= 1 << 0
   if R_HAND.texture == HAND_IMG: flags |= 1 << 1
   packed_data.encode_u8(36, flags)
   
   return packed_data

## Takes a given [param SpellData.StatTypes] value and returns a [b]float[/b] based on the player's base stat plus any stat contributions from actives and passives.[br][br]By default, an influenced stat is simply [code]BASESTAT * CONTRIBUTION[/code], but more complicated functions are possible (SEE [member GRAVITY]).
func get_influenced_stat(stat : SpellData.StatTypes) -> float:
   var influenced_stat : float
   match stat:
      SpellData.StatTypes.HEARTS:         influenced_stat = BASE_HEARTS         * SpellBook.get_stat(SpellData.StatTypes.HEARTS)
      SpellData.StatTypes.ARMOR:          influenced_stat = BASE_ARMOR          * SpellBook.get_stat(SpellData.StatTypes.ARMOR)
      SpellData.StatTypes.WARD:           influenced_stat = BASE_WARD           * SpellBook.get_stat(SpellData.StatTypes.WARD)
      SpellData.StatTypes.OVERHEALTH:     influenced_stat = BASE_OVERHEALTH     * SpellBook.get_stat(SpellData.StatTypes.OVERHEALTH)
      SpellData.StatTypes.ARMOR_STRENGTH: influenced_stat = BASE_ARMOR_STRENGTH * SpellBook.get_stat(SpellData.StatTypes.ARMOR_STRENGTH)
      SpellData.StatTypes.WARD_STRENGTH:  influenced_stat = BASE_WARD_STRENGTH  * SpellBook.get_stat(SpellData.StatTypes.WARD_STRENGTH)
      SpellData.StatTypes.LIFESTEAL:      influenced_stat = BASE_LIFESTEAL      * SpellBook.get_stat(SpellData.StatTypes.LIFESTEAL)
      SpellData.StatTypes.DAMAGE:         influenced_stat = BASE_DAMAGE         * SpellBook.get_stat(SpellData.StatTypes.DAMAGE)
      SpellData.StatTypes.RANGE:          influenced_stat = BASE_RANGE          * SpellBook.get_stat(SpellData.StatTypes.RANGE)
      SpellData.StatTypes.COOLDOWN:       influenced_stat = BASE_COOLDOWN       * SpellBook.get_stat(SpellData.StatTypes.COOLDOWN)
      SpellData.StatTypes.FORCE:          influenced_stat = BASE_FORCE          * SpellBook.get_stat(SpellData.StatTypes.FORCE)
      SpellData.StatTypes.CRIT:           influenced_stat = BASE_CRIT           * SpellBook.get_stat(SpellData.StatTypes.CRIT)
      SpellData.StatTypes.LUCK:           influenced_stat = BASE_LUCK           * SpellBook.get_stat(SpellData.StatTypes.LUCK)
      SpellData.StatTypes.SPEED:          influenced_stat = BASE_SPEED          * SpellBook.get_stat(SpellData.StatTypes.SPEED)
      SpellData.StatTypes.SPRINT:         influenced_stat = BASE_SPRINT         * SpellBook.get_stat(SpellData.StatTypes.SPRINT)
      SpellData.StatTypes.JUMP:           influenced_stat = BASE_JUMP           * SpellBook.get_stat(SpellData.StatTypes.JUMP)
      ## PLATFORMER JUMPS. while "jump" is held, gravity is low. when "jump" is released, gravity is high.
      SpellData.StatTypes.GRAVITY:        influenced_stat = BASE_GRAVITY * pow( 2.0 , ( -SpellBook.get_stat(SpellData.StatTypes.GRAVITY) / 2 ) ) if Input.is_action_pressed("jump") else BASE_GRAVITY * pow( 2.0 , ( SpellBook.get_stat(SpellData.StatTypes.GRAVITY) / 2 ) )
      SpellData.StatTypes.STEADFASTNESS:  influenced_stat = BASE_STEADFASTNESS  * SpellBook.get_stat(SpellData.StatTypes.STEADFASTNESS)
      SpellData.StatTypes.MELEE_DAMAGE:   influenced_stat = BASE_MELEE_DAMAGE   * SpellBook.get_stat(SpellData.StatTypes.MELEE_DAMAGE)
      SpellData.StatTypes.MELEE_RANGE:    influenced_stat = BASE_MELEE_RANGE    * SpellBook.get_stat(SpellData.StatTypes.MELEE_RANGE)
      SpellData.StatTypes.MELEE_FORCE:    influenced_stat = BASE_MELEE_FORCE    * SpellBook.get_stat(SpellData.StatTypes.MELEE_FORCE)
      SpellData.StatTypes.MELEE_COOLDOWN: influenced_stat = BASE_MELEE_COOLDOWN * SpellBook.get_stat(SpellData.StatTypes.MELEE_COOLDOWN)
   return influenced_stat

# ==================== #
# just passin' through #
# ==================== #
func update_HUD_icons():
   ## ACTIVE SPELL ICONS
   var active_spell_l = SpellBook.ActiveSpells[0].SpellID if SpellBook.ActiveSpells[0] else -1
   var active_spell_r = SpellBook.ActiveSpells[1].SpellID if SpellBook.ActiveSpells[1] else -1
   HUD_LEFT_ACTIVE._update_icon(active_spell_l)
   HUD_RIGHT_ACTIVE._update_icon(active_spell_r)
   ## PASSIVE SPELL ICONS
   HUD_PASSIVEBOX.import_passive_spells(SpellBook.PassiveSpells, true)
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
