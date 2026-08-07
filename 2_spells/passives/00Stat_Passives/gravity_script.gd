extends PassiveSpell
class_name GravitySpell

var BaseMult: float = 0.25

func _init(stacks: int = 1) -> void: super(stacks, SpellData.PassiveSpellIDs.Gravity)

func _get_stat_contributions() -> Dictionary: return { SpellData.StatTypes.GRAVITY : BaseMult * Stacks }
   #var mod: float = 0
   #if Stacks > 0:
      #mod = BaseMult*Stacks
   #elif Stacks < 0:
      #for i in range(absi(Stacks)): mod += (1.0-mod)*BaseMult
      #mod = -mod
   #return { SpellData.StatTypes.GRAVITY: mod }

func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_equip(_player: Player) -> void: pass
func _on_unequip(_player: Player) -> void: pass
