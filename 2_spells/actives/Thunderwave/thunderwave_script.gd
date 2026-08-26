extends ActiveSpell
class_name ThunderwaveSpell

enum States {IDLE, DAMAGE_WAVE}
enum FamiliarIDs {WAVE}

func _init() -> void: super(SpellData.ActiveSpellIDs.Thunderwave)

func _on_activate(_activator: Player) -> void:
   if _can_activate():
      TimeSinceActivation = 0.0
      state_changed.emit(States.DAMAGE_WAVE)
