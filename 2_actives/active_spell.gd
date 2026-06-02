class_name ActiveSpell

var Cooldown: float = 0.0:
   set(new_cd):
      Cooldown = new_cd
      TimeSinceActivation = new_cd
var TimeSinceActivation: float = 0.0

func _add_time(delta: float) -> void: TimeSinceActivation += delta
func _can_activate(cooldown_reduction: float) -> bool: return TimeSinceActivation > Cooldown*cooldown_reduction
func _on_activate(_activator: Player) -> void: printerr("ERROR: _on_activate() not overridden but called.")
