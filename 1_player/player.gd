extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8

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

@onready var Camera  := $Camera3D
@onready var LookDir := $Camera3D/RayCast3D
@onready var Lhand   := $Camera3D/Lhand
@onready var Rhand   := $Camera3D/Rhand

const HandImg : Texture2D = preload("res://4_ui/hud/Lhand.png")
const PointImg: Texture2D = preload("res://4_ui/hud/Lpoint.png")
#const RhandIMG : Texture2D = preload("res://4_ui/hud/Rhand.png")
#const RpointIMG: Texture2D = preload("res://4_ui/hud/Rpoint.png")

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
      Lhand.texture = PointImg
   elif Input.is_action_just_released("interact") or not enabled: 
      Lhand.texture = HandImg

   if Input.is_action_just_pressed("active_spell_0") and enabled:
      Lhand.texture = PointImg
      if SpellBook.ActiveSpells[0]:
         SpellBook.ActiveSpells[0]._on_activate(self)
   elif Input.is_action_just_released("active_spell_0") or not enabled: 
      Lhand.texture = HandImg
   
   if Input.is_action_just_pressed("active_spell_1") and enabled:
      Rhand.texture = PointImg
      if SpellBook.ActiveSpells[1]:
         SpellBook.ActiveSpells[1]._on_activate(self)      
   elif Input.is_action_just_released("active_spell_1") or not enabled: 
      Rhand.texture = HandImg 
   SpellBook.process_end(delta, self)

func _unhandled_input(event):
   # handle mouse
   if event is InputEventMouseMotion and enabled:
      rotate_y(-event.relative.x * .005 * Sensitivity)
      Camera.rotate_x(-event.relative.y * .005 * Sensitivity)
      Camera.rotation.x = clamp(Camera.rotation.x, -PI/2, PI/2)


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
      if LookDir.is_colliding():
         var hit = LookDir.get_collider()
         if hit is Interactable:
            hit._on_interact(self)
   move_and_slide()

func generate_transform_data() -> PackedByteArray:
   var packed_data := PackedByteArray()
   packed_data.resize((4*9)+1)
   
   packed_data.encode_float(0,  position.x)
   packed_data.encode_float(4,  position.y) 
   packed_data.encode_float(8,  position.z)
   packed_data.encode_float(12, Camera.rotation.x)
   packed_data.encode_float(16, rotation.y) 
   packed_data.encode_float(20, rotation.z)
   packed_data.encode_float(24, velocity.x)
   packed_data.encode_float(28, velocity.y)
   packed_data.encode_float(32, velocity.z)
   
   var flags := 0
   if Lhand.texture == HandImg: flags |= 1 << 0
   if Rhand.texture == HandImg: flags |= 1 << 1
   packed_data.encode_u8(36, flags)
   
   return packed_data
