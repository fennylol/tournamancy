extends Node3D
class_name WizardBody

@onready var TORSO : Node3D = $_TORSO
@onready var HEAD : Node3D = $_TORSO/_HEAD
@onready var ARM_L : Node3D = $_TORSO/_LEFTARM
@onready var ARM_R : Node3D = $_TORSO/_RIGHTARM
@onready var LEGS : Node3D = $_LEGS
@onready var FEET: Node3D = $_FEET

const MAX_HEAD_YAW    : float = 0.96    # 55 deg
const MIN_HEAD_YAW    : float = -0.96   #-55 deg
const MAX_TORSO_YAW   : float = 0.61    # 35 deg
const MIN_TORSO_YAW   : float = -0.61   #-35 deg
const MAX_HEAD_PITCH  : float = 0.87266 # 50 deg
const MIN_HEAD_PITCH  : float = -0.349  #-20 deg
const MAX_TORSO_PITCH : float = 0.349   # 20 deg
const MIN_TORSO_PITCH : float = -0.349  #-20 deg

var previous_rotation : Vector3
var previous_position : Vector3
var legs_animate_direction := Vector3.ZERO

## Points the body in a particular direction, taking into account YAW (euler-y) and PITCH (euler-x). Ignores ROLL (euler-z).
func update_facing_direction(pointing : Vector3):
   if pointing == previous_rotation: return
   var rotation_delta = pointing - previous_rotation
   ## UPDATE YAW 
   if HEAD.rotation.y + rotation_delta.y == clamp(HEAD.rotation.y + rotation_delta.y , MIN_HEAD_YAW, MAX_HEAD_YAW): HEAD.rotation.y += rotation_delta.y
   elif TORSO.rotation.y + rotation_delta.y == clamp(TORSO.rotation.y + rotation_delta.y , MIN_TORSO_YAW, MAX_TORSO_YAW): TORSO.rotation.y += rotation_delta.y
   else: self.rotation.y += rotation_delta.y
   ## UPDATE PITCH
   var remaining_pitch : float = pointing.x
   HEAD.rotation.x = clamp(pointing.x, MIN_HEAD_PITCH, MAX_HEAD_PITCH)
   remaining_pitch -= HEAD.rotation.x
   if abs(remaining_pitch) > 0.0:
      TORSO.rotation.x = clamp(remaining_pitch, MIN_TORSO_PITCH, MAX_TORSO_PITCH)
      remaining_pitch -= TORSO.rotation.x
   ## UPDATE "PREVIOUS" FOR NEXT FRAME
   previous_rotation = pointing

## ANIMATE WALKING (FUTURE)
func set_walk_direction(_current_pos : Vector3, _target_pos : Vector3):
   pass
   #if previous_position == current_pos: legs_animate_direction = Vector3.ZERO; return
   #var direction : Vector3 = ( current_pos - target_pos ).normalized()
   #legs_animate_direction = Vector3.FORWARD

## Points the wizard's [b]left[/b] hand to a particular euler angle.[br]dir=0 (default) points the hand straight down.[br]dir=90 points the hand forward.
func point_with_left(dir : float = 0.0): ARM_L.rotation.x = dir
## Points the wizard's [b]right[/b] hand to a particular euler angle.[br]dir=0 (default) points the hand straight down.[br]dir=90 points the hand forward.
func point_with_right(dir : float = 0.0): ARM_R.rotation.x = dir

## CHARACTER CUSTOMIZATION (FUTURE)
func update_robe_color(_c : Color): pass
## CHARACTER CUSTOMIZATION (FUTURE)
func update_hat_color(_c : Color): pass

# animation range: 6-10 deg
func _process(_delta: float) -> void:
   pass
