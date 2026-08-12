extends PassiveSpell
class_name ArmorSpell

func _init(stacks: int = 1) -> void: super(stacks, SpellData.PassiveSpellIDs.Armor)

func _get_stat_contributions() -> Dictionary: return { SpellData.StatTypes.ARMOR: Stacks }

func _on_equip(player: Player) -> void: 
   player.sync_health()
func _on_update(player : Player) -> void: 
   player.sync_health()

func _on_process_begin(_delta: float, _player: Player) -> void: pass
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_unequip(_player: Player) -> void: pass
