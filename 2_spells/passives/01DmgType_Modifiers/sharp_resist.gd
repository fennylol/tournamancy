extends PassiveSpell
class_name SharpResist

func _init(stacks: int = 1) -> void: super(stacks, SpellData.PassiveSpellIDs.Resist_Sharp)

func _get_stat_contributions() -> Dictionary: return { SpellData.StatTypes.RESIST_SHARP: Stacks }

func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_equip(_player: Player) -> void: pass
func _on_update(_player : Player) -> void: pass
func _on_unequip(_player: Player) -> void: pass
