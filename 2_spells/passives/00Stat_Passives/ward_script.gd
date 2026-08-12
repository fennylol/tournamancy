extends PassiveSpell
class_name WardSpell

func _init(stacks: int = 1) -> void: super(stacks, SpellData.PassiveSpellIDs.Ward)

func _get_stat_contributions() -> Dictionary: return { SpellData.StatTypes.WARD: Stacks }

func _on_equip(player: Player) -> void: 
   player.sync_health()
func _on_update(player : Player) -> void: 
   player.sync_health()

func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_unequip(_player: Player) -> void: pass
