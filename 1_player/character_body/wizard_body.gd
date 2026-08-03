extends Node3D
class_name WizardBody

@onready var TORSO : MeshInstance3D = $_TORSO
@onready var HEAD : MeshInstance3D = $_TORSO/_HEAD
@onready var ARM_L : MeshInstance3D = $_TORSO/_LEFTARM
@onready var ARM_R : MeshInstance3D = $_TORSO/_RIGHTARM
@onready var LEGS : MeshInstance3D = $_LEGS
@onready var FEET: MeshInstance3D = $_FEET

const MAX_HEAD_TURN : float = 55.0
const MAX_BODY_TURN : float = 35.0
var legs_animate_direction := Vector3.ZERO

## FACING DIRECTION
func face_head(dir : float = 0.0):
   HEAD.rotation.y = dir
func face_torso(dir : float = 0.0):
   TORSO.rotation.y = dir

## POINT WITH ARMS
func point_with_left(dir : float = 0.0):
   ARM_L.rotation.x = dir
func point_with_right(dir : float = 0.0):
   ARM_R.rotation.x = dir
func reset_arms():
   point_with_left(0)
   point_with_right(0)

# animation range: 6-10 deg
func _process(delta: float) -> void:
   pass
