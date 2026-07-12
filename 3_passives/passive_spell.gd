class_name PassiveSpell

var Stacks: int = 1

func _init(stacks: int = 1) -> void: Stacks = stacks

func _get_stat_contributions() -> Dictionary: 
   printerr("ERROR: _get_stat_contributions() not overridden but called.")
   return {}

func _on_process_begin(_delta: float, _player: Player) -> void: printerr("ERROR: _on_process_begin() not overridden but called.")
func _on_process_end(_delta: float, _player: Player) -> void: printerr("ERROR: _on_process_end() not overridden but called.")
func _on_equip(_player: Player) -> void: printerr("ERROR: _on_equip() not overridden but called.")
func _on_unequip(_player: Player) -> void: printerr("ERROR: _on_unequip() not overridden but called.")
