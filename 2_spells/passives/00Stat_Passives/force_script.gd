extends PassiveSpell
class_name ForceSpell

func _init(stacks: int = 1) -> void: super(stacks, SpellData.PassiveSpellIDs.Force)

func _get_stat_contributions() -> Dictionary: return { SpellData.StatTypes.FORCE: Stacks }

func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_equip(_player: Player) -> void: pass
func _on_update(_player : Player) -> void: pass
func _on_unequip(_player: Player) -> void: pass
