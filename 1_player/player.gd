extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8
var mouse_captured = false

@onready var camera  := $Camera3D
@onready var lookdir := $Camera3D/RayCast3D
@onready var lhand   := $Camera3D/Lhand
@onready var rhand   := $Camera3D/Rhand

const LhandIMG : Texture2D = preload("res://1_player/Lhand.png")
const LpointIMG: Texture2D = preload("res://1_player/Lpoint.png")
const RhandIMG : Texture2D = preload("res://1_player/Rhand.png")
const RpointIMG: Texture2D = preload("res://1_player/Rpoint.png")

@export var sensitivity = 0.5


# ╭----------------╮
# |    UTILITY     |
# ╰----------------╯
func register_input(input_name: String, keycode: Key):
   InputMap.add_action(input_name)
   var event = InputEventKey.new()
   event.keycode = keycode
   InputMap.action_add_event(input_name, event)



func _ready():
   register_input("capture_mouse", KEY_ESCAPE)
   register_input("jump", KEY_SPACE)
   
   register_input("use_left", KEY_Q)
   register_input("use_right", KEY_E)
   
   register_input("left", KEY_A)
   register_input("down", KEY_S)
   register_input("right", KEY_D)
   register_input("up", KEY_W)

# mouse
func _unhandled_input(event):
   if event is InputEventMouseMotion and mouse_captured:
      rotate_y(-event.relative.x * .005 * sensitivity)
      camera.rotate_x(-event.relative.y * .005 * sensitivity)
      camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

# mouse capture
func _process(_delta):
   if Input.is_action_just_pressed("capture_mouse") or \
   Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_captured:
      mouse_captured = !mouse_captured
      if mouse_captured:Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
      else:Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
   
   if mouse_captured:
      if Input.is_action_just_pressed("use_left"):
         lhand.texture = LpointIMG
      elif Input.is_action_just_released("use_left"):
         lhand.texture = LhandIMG
      
      if Input.is_action_just_pressed("use_right"):
         rhand.texture = RpointIMG
      elif Input.is_action_just_released("use_right"):
         rhand.texture = RhandIMG

# movement
func _physics_process(delta):
   if !mouse_captured: return
   if not is_on_floor(): velocity.y -= GRAVITY * delta
   
   if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y = JUMP_VELOCITY
   
   var input_dir = Input.get_vector("left", "right", "up", "down")
   var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
   if direction:
      velocity.x = direction.x * SPEED
      velocity.z = direction.z * SPEED
   else:
      velocity.x = move_toward(velocity.x, 0, SPEED)
      velocity.z = move_toward(velocity.z, 0, SPEED)

   if Input.is_action_pressed("use_left") or Input.is_action_pressed("use_right"):
      if lookdir.is_colliding():
         var hit = lookdir.get_collider()
         if hit is Interactable:
            hit._on_interact(self)


   move_and_slide()
