extends Node3D
class_name Effect

@warning_ignore("unused_signal")
signal state_changed(new_state: int)
var CurrentState: int = 0

var ThePlayer : Player

func change_state(new_state: int) -> void: CurrentState = new_state
