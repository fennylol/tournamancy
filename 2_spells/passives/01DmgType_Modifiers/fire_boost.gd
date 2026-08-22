extends PassiveSpell
class_name FireBoost

func _init(stacks: int = 1) -> void: super(stacks, SpellData.PassiveSpellIDs.Boost_Fire)

func _get_stat_contributions() -> Dictionary: return { SpellData.StatTypes.BOOST_FIRE: Stacks }

func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_equip(_player: Player) -> void: pass
func _on_update(_player : Player) -> void: pass
func _on_unequip(_player: Player) -> void: pass
