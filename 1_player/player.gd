extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8

var mouse_captured: bool = false
var enabled: bool = false
@export var Sensitivity = 0.5

@onready var Camera  := $Camera3D
@onready var LookDir := $Camera3D/RayCast3D
@onready var Lhand   := $Camera3D/Lhand
@onready var Rhand   := $Camera3D/Rhand

const LhandIMG : Texture2D = preload("res://4_ui/hud/Lhand.png")
const LpointIMG: Texture2D = preload("res://4_ui/hud/Lpoint.png")
const RhandIMG : Texture2D = preload("res://4_ui/hud/Rhand.png")
const RpointIMG: Texture2D = preload("res://4_ui/hud/Rpoint.png")


var SpellBook: Grimoire = Grimoire.new()


# =================== #
# _process() handling #
# =================== #
func _process(delta):
   SpellBook.process_begin(delta, self)
   
   if enabled:
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

func _physics_process(delta: float) -> void:
   var use_source_physics: bool = false   
   if use_source_physics: _source_physics_process(delta)
   else: _simple_physics_process(delta)

func _unhandled_input(event):
   # handle mouse
   if event is InputEventMouseMotion and mouse_captured and enabled:
      rotate_y(-event.relative.x * .005 * Sensitivity)
      Camera.rotate_x(-event.relative.y * .005 * Sensitivity)
      Camera.rotation.x = clamp(Camera.rotation.x, -PI/2, PI/2)

# =========== #
# input setup #
# =========== #
#func _ready():
   #var register_input: Callable = func(input_name: String, keycode: Key):
      #InputMap.add_action(input_name)
      #var event := InputEventKey.new()
      #event.keycode = keycode
      #InputMap.action_add_event(input_name, event)
   #var register_mouse_button_input: Callable = func(input_name: String, keycode: MouseButton):
      #InputMap.add_action(input_name)
      #var event := InputEventMouseButton.new()
      #event.button_index = keycode
      #InputMap.action_add_event(input_name, event)
   #
   #register_input.call("capture_mouse", KEY_ESCAPE)
   #register_input.call("jump", KEY_SPACE)
   #
   #register_input.call("left",  KEY_A)
   #register_input.call("down",  KEY_S)
   #register_input.call("right", KEY_D)
   #register_input.call("up",    KEY_W)
   #
   #register_input.call("interact", KEY_E)
   #register_mouse_button_input.call("active_spell_0", MOUSE_BUTTON_LEFT)
   #register_mouse_button_input.call("active_spell_1", MOUSE_BUTTON_RIGHT)

# =============== #
# simple movement #
# =============== #
func _simple_physics_process(delta):
   if not mouse_captured: return
   if not enabled: return
   var stat_influenced_speed   = SPEED         * SpellBook.get_stat(SpellData.StatTypes.SPEED)
   var stat_influenced_gravity = GRAVITY       * SpellBook.get_stat(SpellData.StatTypes.GRAVITY)
   var stat_influenced_jump    = JUMP_VELOCITY * SpellBook.get_stat(SpellData.StatTypes.JUMP)
   
   # vertical movement
   if not is_on_floor(): velocity.y -= stat_influenced_gravity * delta
   if Input.is_action_pressed("jump") and is_on_floor(): velocity.y = stat_influenced_jump
   
   # horizontal movement
   var input_dir = Input.get_vector("left", "right", "up", "down")
   var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
   
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

# =============== #
# source movement #
# =============== #
var ground_accel    := 20.0
var ground_decel    := 7.0
var ground_friction := 3.5

var air_cap        := 5.0
var air_accel      := 80.0
var air_move_speed := 5.0

func _source_physics_process(delta):
    if !mouse_captured: return
    var stat_influenced_speed   = SPEED         * SpellBook.get_stat(SpellData.StatTypes.SPEED)
    var stat_influenced_gravity = GRAVITY       * SpellBook.get_stat(SpellData.StatTypes.GRAVITY)
    var stat_influenced_jump    = JUMP_VELOCITY * SpellBook.get_stat(SpellData.StatTypes.JUMP)

    # vertical movement
    if not is_on_floor(): velocity.y -= stat_influenced_gravity * delta
    if Input.is_action_pressed("jump") and is_on_floor(): velocity.y = stat_influenced_jump

    # horizontal movement
    var input_dir = Input.get_vector("left", "right", "up", "down")
    var wish_dir  = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if is_on_floor():
        _handle_ground_physics(wish_dir, stat_influenced_speed, delta)
    else:
        _handle_air_physics(wish_dir, delta)

    # use interactables
    if Input.is_action_pressed("interact"):
        if LookDir.is_colliding():
            var hit = LookDir.get_collider()
            if hit is Interactable:
                hit._on_interact(self)

    move_and_slide()


func _handle_ground_physics(wish_dir: Vector3, move_speed: float, delta: float) -> void:
    var cur_speed_in_wish_dir = velocity.dot(wish_dir)
    var add_speed_till_cap    = move_speed - cur_speed_in_wish_dir
    if add_speed_till_cap > 0:
        var accel_speed = min(ground_accel * delta * move_speed, add_speed_till_cap)
        velocity += accel_speed * wish_dir

    var control   = max(velocity.length(), ground_decel)
    var drop      = control * ground_friction * delta
    var new_speed = max(velocity.length() - drop, 0.0)
    if velocity.length() > 0:
        velocity *= new_speed / velocity.length()


func _handle_air_physics(wish_dir: Vector3, delta: float) -> void:
    var cur_speed_in_wish_dir = velocity.dot(wish_dir)
    var capped_speed          = min((air_move_speed * wish_dir).length(), air_cap)
    var add_speed_till_cap    = capped_speed - cur_speed_in_wish_dir
    if add_speed_till_cap > 0:
        var accel_speed = min(air_accel * air_move_speed * delta, add_speed_till_cap)
        velocity += accel_speed * wish_dir
