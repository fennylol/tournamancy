@tool
extends Interactable
class_name BasicButton

@export var button_color: Color = Color.WHITE:
    set(value):
        button_color = value
        if button_mesh:
            button_mesh.material_override = StandardMaterial3D.new()
            button_mesh.material_override.albedo_color = button_color
@onready var button_mesh: MeshInstance3D = $CollisionShape3D/MeshInstance3D

const PRESS_TIME: float = 0.0625
var press_time: float = 0.0

func _ready() -> void:
   if button_mesh:
      button_mesh.material_override = StandardMaterial3D.new()
      button_mesh.material_override.albedo_color = button_color

func _process(delta: float) -> void:
   if press_time > 0.0: press_time -= delta
   else: button_mesh.position = Vector3.ZERO
   
func _on_interact(_interacter: Player) -> void:
   button_mesh.position = Vector3(0,-0.05, 0)
   press_time = PRESS_TIME
