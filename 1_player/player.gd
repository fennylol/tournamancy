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

var SpellBook: Grimoire = Grimoire.new()


# =================== #
# _process() handling #
# =================== #
func _process(delta):
   SpellBook.process_begin(delta, self)
   
   # mouse capture
   if Input.is_action_just_pressed("capture_mouse") or \
   Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_captured:
      mouse_captured = !mouse_captured
      if mouse_captured:Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
      else:Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

   # change hand textures
   if mouse_captured:
      if Input.is_action_just_pressed("interact"): 
         Lhand.texture = LpointIMG
      elif Input.is_action_just_released("interact") : 
         Lhand.texture = LhandIMG

      if Input.is_action_just_pressed("active_spell_0"):
         Lhand.texture = LpointIMG
         if SpellBook.ActiveSpells[0]:
            SpellBook.ActiveSpells[0]._on_activate(self)
      elif Input.is_action_just_released("active_spell_0") : 
         Lhand.texture = LhandIMG
      
      if Input.is_action_just_pressed("active_spell_1"):
         Rhand.texture = RpointIMG
         if SpellBook.ActiveSpells[1]:
            SpellBook.ActiveSpells[1]._on_activate(self)      
      elif Input.is_action_just_released("active_spell_1"): 
         Rhand.texture = RhandIMG
   
   SpellBook.process_end(delta, self)
   
func _physics_process(delta):
   if !mouse_captured: return
   
   # vertical movement
   if not is_on_floor(): velocity.y -= GRAVITY * delta
   if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y = JUMP_VELOCITY
   
   # horizontal movement
   var input_dir = Input.get_vector("left", "right", "up", "down")
   var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
   
   var stat_influenced_speed = SPEED * SpellBook.get_stat(SpellData.StatTypes.SPEED)
   if direction:
      velocity.x = direction.x * stat_influenced_speed
      velocity.z = direction.z * stat_influenced_speed
   else:
      velocity.x = move_toward(velocity.x, 0, stat_influenced_speed)
      velocity.z = move_toward(velocity.z, 0, stat_influenced_speed)

   # use interactables
   if Input.is_action_pressed("interact"):
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


# =========== #
# input setup #
# =========== #
func _ready():
   var register_input: Callable = func(input_name: String, keycode: Key):
      InputMap.add_action(input_name)
      var event := InputEventKey.new()
      event.keycode = keycode
      InputMap.action_add_event(input_name, event)
   var register_mouse_button_input: Callable = func(input_name: String, keycode: MouseButton):
      InputMap.add_action(input_name)
      var event := InputEventMouseButton.new()
      event.button_index = keycode
      InputMap.action_add_event(input_name, event)
   
   register_input.call("capture_mouse", KEY_ESCAPE)
   register_input.call("jump", KEY_SPACE)
   
   register_input.call("left",  KEY_A)
   register_input.call("down",  KEY_S)
   register_input.call("right", KEY_D)
   register_input.call("up",    KEY_W)
   
   register_input.call("interact", KEY_E)
   register_mouse_button_input.call("active_spell_0", MOUSE_BUTTON_LEFT)
   register_mouse_button_input.call("active_spell_1", MOUSE_BUTTON_RIGHT)
