# meta-name: Default
# meta-description: Base template for passive spells
# meta-default: true
# meta-space-indent: 3
extends PassiveSpell
# TODO: name your class
class_name NewPassiveSpell

#enum States {}
#enum FamiliarIDs {}
#func on_state_changed(new_state: int) -> void:
   #super(new_state) # NOTE: keep this line if adding custom state change logic

# TODO: replace ERROR with your new spell ID
func _init(stacks: int = 1) -> void: super(stacks, SpellData.PassiveSpellIDs.ERROR)

func _get_stat_contributions()                   -> Dictionary: return {}
func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player)   -> void: pass
func _on_equip(_player: Player)                        -> void: pass
func _on_update(_player : Player)                      -> void: pass
func _on_unequip(_player: Player)                      -> void: pass
