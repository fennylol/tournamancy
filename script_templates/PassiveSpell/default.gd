# meta-name: Default
# meta-description: Base template for passive spells
# meta-default: true
# meta-space-indent: 3
extends PassiveSpell

#enum States {}
#func change_state(new_state: int) -> void:
   #super(new_state) # NOTE: keep this line if adding custom state change logic

func _init(stacks: int = 1) -> void:
   # TODO: replace ERROR with your new spell ID
   super(stacks, SpellData.PassiveSpellIDs.ERROR)

func _get_stat_contributions()                   -> Dictionary: return {}
func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player)   -> void: pass
func _on_equip(_player: Player)                        -> void: pass
func _on_update(_player : Player)                      -> void: pass
func _on_unequip(_player: Player)                      -> void: pass
