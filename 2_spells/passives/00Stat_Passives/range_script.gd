extends PassiveSpell
class_name RangeSpell

func _init(stacks: int = 1) -> void: super(stacks, SpellData.PassiveSpellIDs.Attack_Range)

func _get_stat_contributions() -> Dictionary: return { SpellData.StatTypes.RANGE: Stacks }

func _on_equip(_player: Player) -> void: 
   ## probably need a function that updates the size of any sized nodes (Area3D, Raycast3D, etc) the player controlls.
   pass

func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_update(_player : Player) -> void: pass
func _on_unequip(_player: Player) -> void: pass
