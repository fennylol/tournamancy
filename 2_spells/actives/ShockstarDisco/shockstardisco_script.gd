extends ActiveSpell
class_name ShockstarDiscoSpell

var Distance: float = 5.0

# set true cooldown
func _init() -> void:
   super(SpellData.ActiveSpellIDs.ShockstarDisco)

func _on_activate(activator: Player) -> void:
   if _can_activate():
      TimeSinceActivation = 0.0
      print("Shockstar Disco Activated")
