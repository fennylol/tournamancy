extends MeshInstance3D

@onready var cam: Camera3D = $SubViewport/Camera3D

func _process(_delta: float) -> void:
   cam.global_rotation = global_rotation
