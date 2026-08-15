extends PassiveSpell
class_name JBLSpeakerSpell

enum States {PAUSED, PLAYING}

func _init(stacks: int = 1) -> void: super(stacks, SpellData.PassiveSpellIDs.JBLSpeaker)

func _get_stat_contributions() -> Dictionary: return {}

func _on_process_begin(_delta: float, player: Player) -> void:
   if player.velocity.length() >= 4.9: state_changed.emit(States.PLAYING)
   else: state_changed.emit(States.PAUSED)
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_equip(player: Player) -> void: pass
func _on_unequip(_player: Player) -> void: pass
