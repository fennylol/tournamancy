extends Effect

@onready var LOS: RayCast3D = $RayCast3D

func _init() -> void: FollowsEyes = true

func on_state_changed(new_state: int) -> void:
   super(new_state)
   
   if LOS.is_colliding():
      var hit_body = LOS.get_collider()
      var parent_node: Node3D = hit_body.get_parent()
      if parent_node and parent_node is Dummy:
         print("dealing damage")
