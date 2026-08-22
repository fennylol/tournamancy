extends ActiveSpell
class_name PulsarsBreath

enum States {FIRE}
enum FamiliarIDs {PULSAR_BEAM}

const SPELL_DAMAGE: float = 5.0

#func on_state_changed(new_state: int) -> void:
   #super(new_state) # NOTE: keep this line if adding custom state change logic

func _init() -> void: super(SpellData.ActiveSpellIDs.PulsarsBreath)

func _on_activate(_activator: Player) -> void:
   if _can_activate():
      TimeSinceActivation = 0.0
      state_changed.emit(States.FIRE)
