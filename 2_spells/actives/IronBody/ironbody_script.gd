extends ActiveSpell
class_name IronBodySpell

var OverhealthAmount: float = 20.0

# set true cooldown
func _init() -> void:
   super(SpellData.ActiveSpellIDs.IronBody)

func _on_activate(activator: Player) -> void:
   if _can_activate():
      TimeSinceActivation = 0.0
      activator._update_heath_display([0,0,0,OverhealthAmount], true)
