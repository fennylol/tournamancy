extends ActiveSpell
class_name TeleportSpell

var Distance: float = 5.0

# set true cooldown
func _init() -> void:
   super(SpellData.ActiveSpellIDs.Teleport)
   Cooldown = 5.0

func _on_activate(activator: Player) -> void:
   if _can_activate():
      TimeSinceActivation = 0.0
      activator.translate(Vector3(0, 0, -Distance))
