class_name Spell

@warning_ignore("unused_signal")
signal StateChanged(new_state: int)
var SpellID: int = -1

func _init(id: int) -> void:
   SpellID = id
   if id == -1: printerr("spell.gd: spell constructed with no ID.")
