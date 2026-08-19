class_name Spell

@warning_ignore("unused_signal")
signal state_changed(new_state: int)
var CurrentState: int = 0

var SpellID: int = -1

func on_state_changed(new_state: int) -> void: CurrentState = new_state

func _init(id: int) -> void:
   SpellID = id
   if id == -1: printerr("spell.gd: spell constructed with no ID.")
