extends PassiveSpell
class_name PhantomFlight

enum States {Alone, EnemyNearby}

func _init(stacks: int = 1) -> void:
   super(stacks, SpellData.PassiveSpellIDs.PhantomFlight)

func _get_stat_contributions() -> Dictionary: 
   if CurrentState == States.Alone:
      return {SpellData.StatTypes.SPEED: 5}
   else:
      return {SpellData.StatTypes.SPEED: -1}
func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player)   -> void: pass
func _on_equip(_player: Player)                        -> void: pass
func _on_update(_player : Player)                      -> void: pass
func _on_unequip(_player: Player)                      -> void: pass
