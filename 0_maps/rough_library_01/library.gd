extends Node3D

@onready var ExitWindow : Area3D = $ExitWindow

signal player_exited(pos : Vector3)

func _on_exit_window_body_entered(body: Node3D) -> void:
   if body is Player: 
      player_exited.emit(body.position)
