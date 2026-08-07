extends ActiveSpell
class_name ThunderwaveSpell

enum States {IDLE, DAMAGE_WAVE}

func _init() -> void: super(SpellData.ActiveSpellIDs.Thunderwave)

func _on_activate(activator: Player) -> void:
   if _can_activate():
      TimeSinceActivation = 0.0
      StateChanged.emit(States.DAMAGE_WAVE)
      StateChanged.emit(States.IDLE)
