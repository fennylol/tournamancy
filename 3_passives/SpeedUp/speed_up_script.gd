extends PassiveSpell

var BaseMult: float = 0.25

func _get_stat_contributions() -> Dictionary: return { SpellData.StatTypes.SPEED: BaseMult*Stacks }

func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_equip() -> void: pass
func _on_unequip() -> void: pass
