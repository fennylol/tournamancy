extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8
var mouse_captured = false

@onready var Camera  := $Camera3D
@onready var LookDir := $Camera3D/RayCast3D
@onready var Lhand   := $Camera3D/Lhand
@onready var Rhand   := $Camera3D/Rhand

const LhandIMG : Texture2D = preload("res://4_ui/hud/Lhand.png")
const LpointIMG: Texture2D = preload("res://4_ui/hud/Lpoint.png")
const RhandIMG : Texture2D = preload("res://4_ui/hud/Rhand.png")
const RpointIMG: Texture2D = preload("res://4_ui/hud/Rpoint.png")

@export var Sensitivity = 0.5

var Abilities: Grimoire = Grimoire.new()



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

func _process(_delta):
   Abilities._on_process_begin(self)
   
   # mouse capture
   if Input.is_action_just_pressed("capture_mouse") or \
   Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_captured:
      mouse_captured = !mouse_captured
      if mouse_captured:Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
      else:Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

   # change hand textures
   if mouse_captured:
      if Input.is_action_just_pressed("use_left"): 
         Lhand.texture = LpointIMG
      elif Input.is_action_just_released("use_left") : 
         Lhand.texture = LhandIMG
      
      if Input.is_action_just_pressed("use_right"): 
         Rhand.texture = RpointIMG
      elif Input.is_action_just_released("use_right"): 
         Rhand.texture = RhandIMG
   
   Abilities._on_process_end(self)
   

func _physics_process(delta):
   if !mouse_captured: return
   
   # vertical movement
   if not is_on_floor(): velocity.y -= GRAVITY * delta
   if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y = JUMP_VELOCITY
   
   # horizontal movement
   var input_dir = Input.get_vector("left", "right", "up", "down")
   var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
   if direction:
      velocity.x = direction.x * SPEED
      velocity.z = direction.z * SPEED
   else:
      velocity.x = move_toward(velocity.x, 0, SPEED)
      velocity.z = move_toward(velocity.z, 0, SPEED)

   # use interactables
   if Input.is_action_pressed("use_left") or Input.is_action_pressed("use_right"):
      if LookDir.is_colliding():
         var hit = LookDir.get_collider()
         if hit is Interactable:
            hit._on_interact(self)

   move_and_slide()


func _unhandled_input(event):
   # handle mouse
   if event is InputEventMouseMotion and mouse_captured:
      rotate_y(-event.relative.x * .005 * Sensitivity)
      Camera.rotate_x(-event.relative.y * .005 * Sensitivity)
      Camera.rotation.x = clamp(Camera.rotation.x, -PI/2, PI/2)
