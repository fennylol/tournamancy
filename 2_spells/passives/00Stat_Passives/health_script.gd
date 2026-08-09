extends PassiveSpell
class_name HealthSpell

var BaseMult: float = 1.0

func _init(stacks: int = 1) -> void: super(stacks, SpellData.PassiveSpellIDs.Heart)

func _get_stat_contributions() -> Dictionary:
   var mod: float = 0
   if Stacks > 0:
      mod = BaseMult*Stacks
   elif Stacks < 0:
      for i in range(absi(Stacks)): mod += (1.0-mod)*BaseMult
      mod = -mod
   return { SpellData.StatTypes.HEARTS: mod }

func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_equip(player: Player) -> void: 
   player.sync_health()
func _on_unequip(_player: Player) -> void: pass
