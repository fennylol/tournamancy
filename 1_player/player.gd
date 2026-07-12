extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8
const TRANSFORM_DATA_SIZE: int = (4*9)+1
const HAND_IMG : Texture2D = preload("res://4_ui/hud/Lhand.png")
const POINT_IMG: Texture2D = preload("res://4_ui/hud/Lpoint.png")

signal enabled_changed(new_val:bool)

var enabled: bool = false:
   set(new_val):
      enabled = new_val
      enabled_changed.emit(new_val)
      if enabled:
         Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
      else:
         Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
@export var Sensitivity = 0.5

@onready var CAMERA    := $Eyes
@onready var LOOK_DIR  := $Eyes/RayCast3D
@onready var L_HAND    := $Eyes/Lhand
@onready var R_HAND    := $Eyes/Rhand
@onready var SUBSPELLS := $SubSpells

var SpellBook: Grimoire = Grimoire.new()

# =================== #
# _process() handling #
# =================== #
func _process(delta):
   SpellBook.process_begin(delta, self)
   
   # mouse capture
   if Input.is_action_just_pressed("menu"):
      enabled = !enabled

   # change hand textures
   if Input.is_action_just_pressed("interact") and enabled: 
      L_HAND.texture = POINT_IMG
   elif Input.is_action_just_released("interact") or not enabled: 
      L_HAND.texture = HAND_IMG

   if Input.is_action_just_pressed("active_spell_0") and enabled:
      L_HAND.texture = POINT_IMG
      if SpellBook.ActiveSpells[0]:
         SpellBook.ActiveSpells[0]._on_activate(self)
   elif Input.is_action_just_released("active_spell_0") or not enabled: 
      L_HAND.texture = HAND_IMG
   
   if Input.is_action_just_pressed("active_spell_1") and enabled:
      R_HAND.texture = POINT_IMG
      if SpellBook.ActiveSpells[1]:
         SpellBook.ActiveSpells[1]._on_activate(self)      
   elif Input.is_action_just_released("active_spell_1") or not enabled: 
      R_HAND.texture = HAND_IMG 
   SpellBook.process_end(delta, self)

func _unhandled_input(event):
   # handle mouse
   if event is InputEventMouseMotion and enabled:
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
   if Input.is_action_pressed("jump") and is_on_floor() and enabled: velocity.y = stat_influenced_jump
   
   # horizontal movement
   var input_dir = Input.get_vector("left", "right", "up", "down")
   var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
   
   if direction and enabled:
      velocity.x = direction.x * stat_influenced_speed
      velocity.z = direction.z * stat_influenced_speed
   else:
      velocity.x = move_toward(velocity.x, 0, stat_influenced_speed)
      velocity.z = move_toward(velocity.z, 0, stat_influenced_speed)

   # use interactables
   if Input.is_action_pressed("interact") and enabled:
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

# TODO: dopesnt really work
func add_subspell(constructor: Callable) -> Node:
   var result = constructor.call()
   if result is Node: 
      SUBSPELLS.add_child(result)
      return result
   else: return null
   
