extends PassiveSpell
class_name JBLSpeakerSpell

var BaseMult: float = 0.25

func _get_stat_contributions() -> Dictionary: return {}

func _on_process_begin(_delta: float, player: Player) -> void:
   if player.velocity.length() >= 1: print("baba")
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_equip(player: Player) -> void:
   player.add_item(SpellData.PassiveSpellIDs.JBLSpeaker)
func _on_unequip(_player: Player) -> void: pass
