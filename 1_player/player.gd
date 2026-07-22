extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8
const TRANSFORM_DATA_SIZE: int = (4*9)+1
const HAND_IMG : Texture2D = preload("res://4_ui/hud/Lhand.png")
const POINT_IMG: Texture2D = preload("res://4_ui/hud/Lpoint.png")

@onready var CAMERA    := $Eyes
@onready var LOOK_DIR  := $Eyes/RayCast3D
@onready var L_HAND    := $Eyes/Lhand
@onready var R_HAND    := $Eyes/Rhand
@onready var EFFECTORY := $Effectory
@onready var HUD       := $DefaultHud
var HUD_LEFT_ACTIVE    : Node2D
var HUD_RIGHT_ACTIVE   : Node2D
var HUD_PASSIVEBOX     : Node2D
var HUD_HEALTHBAR      : Node2D

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
   SpellBook.process_begin(delta, self)
   
   # mouse capture
   if Input.is_action_just_pressed("menu"):
      Enabled = !Enabled

   # change hand textures
   if Input.is_action_just_pressed("interact") and Enabled: 
      L_HAND.texture = POINT_IMG
   elif Input.is_action_just_released("interact") or not Enabled: 
      L_HAND.texture = HAND_IMG

   if Input.is_action_just_pressed("active_spell_0") and Enabled:
      L_HAND.texture = POINT_IMG
      HUD_LEFT_ACTIVE._hold()
      if SpellBook.ActiveSpells[0]:
         SpellBook.ActiveSpells[0]._on_activate(self)
   elif Input.is_action_just_released("active_spell_0") or not Enabled: 
      L_HAND.texture = HAND_IMG
      HUD_LEFT_ACTIVE._release()
   
   if Input.is_action_just_pressed("active_spell_1") and Enabled:
      R_HAND.texture = POINT_IMG
      HUD_RIGHT_ACTIVE._hold()
      if SpellBook.ActiveSpells[1]:
         SpellBook.ActiveSpells[1]._on_activate(self)      
   elif Input.is_action_just_released("active_spell_1") or not Enabled: 
      R_HAND.texture = HAND_IMG 
      HUD_RIGHT_ACTIVE._release()
   SpellBook.process_end(delta, self)
   
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
   var stat_influenced_speed   = SPEED         * SpellBook.get_stat(SpellData.StatTypes.SPEED)
   var stat_influenced_gravity = GRAVITY       * SpellBook.get_stat(SpellData.StatTypes.GRAVITY)
   var stat_influenced_jump    = JUMP_VELOCITY * SpellBook.get_stat(SpellData.StatTypes.JUMP)
   
   # vertical movement
   if not is_on_floor(): velocity.y -= stat_influenced_gravity * delta
   if Input.is_action_pressed("jump") and is_on_floor() and Enabled: velocity.y = stat_influenced_jump
   
   # horizontal movement
   var input_dir = Input.get_vector("left", "right", "up", "down")
   var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
   
   if direction and Enabled:
      velocity.x = direction.x * stat_influenced_speed
      velocity.z = direction.z * stat_influenced_speed
   else:
      velocity.x = move_toward(velocity.x, 0, stat_influenced_speed)
      velocity.z = move_toward(velocity.z, 0, stat_influenced_speed)

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
