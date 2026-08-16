extends Effect

var EnemiesNearby: int = 0


func _on_phantom_flight_area_effect_body_entered(body: Node3D) -> void:
   var parent_node: Node3D = body.get_parent()
   if parent_node and parent_node is Dummy:
      if not EnemiesNearby: state_changed.emit(PhantomFlightSpell.States.EnemyNearby)
      EnemiesNearby += 1
      
func _on_phantom_flight_area_effect_body_exited(body: Node3D) -> void:
   var parent_node: Node3D = body.get_parent()
   if parent_node and parent_node is Dummy:
      EnemiesNearby -= 1
      if not EnemiesNearby: state_changed.emit(PhantomFlightSpell.States.Alone)
