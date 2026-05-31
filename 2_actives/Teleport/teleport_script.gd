extends ActiveAbility

var Distance: float = 5.0

func _on_activate(activator: Player) -> void:
   activator.position.z -= Distance
