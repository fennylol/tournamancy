extends PassiveSpell
class_name HealthSpell

var BaseMult: float = 0.25

func _get_stat_contributions() -> Dictionary:
   var mod: float = 0
   if Stacks > 0:
      mod = BaseMult*Stacks
   elif Stacks < 0:
      for i in range(absi(Stacks)): mod += (1.0-mod)*BaseMult
      mod = -mod
   return { SpellData.StatTypes.HEALTH: mod }

func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_equip(_player: Player) -> void: pass
func _on_unequip(_player: Player) -> void: pass
