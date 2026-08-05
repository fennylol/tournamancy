extends ActiveSpell
class_name ThunderwaveSpell

var Distance: float = 5.0

# set true cooldown
func _init() -> void:
   super(SpellData.ActiveSpellIDs.Thunderwave)

func _on_activate(activator: Player) -> void:
   if _can_activate():
      TimeSinceActivation = 0.0
      print("Thunderwave Activated")
