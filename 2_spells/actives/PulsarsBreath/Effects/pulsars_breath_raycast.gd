extends Effect

@onready var LOS: RayCast3D = $RayCast3D

func _init() -> void: FollowsEyes = true

func on_state_changed(_new_state: int) -> void:
   #super(new_state)
   
   var contact_point: Vector3
   
   if LOS.is_colliding():
      var hit_body = LOS.get_collider()
      var parent_node: Node3D = hit_body.get_parent()
      if parent_node and parent_node is Dummy:
         print("dealing damage")
      
      contact_point = to_local(LOS.get_collision_point())
   else: contact_point = Vector3(0,0,-100)  
   var ocular_dist: float = 0.25
   var new_beam = PulsarBeam.new(-contact_point.z-ocular_dist)
   new_beam.rotation = global_rotation + Vector3(PI/2, 0, 0)
   new_beam.position = to_global(position+Vector3(0, 0, (contact_point.z-ocular_dist)/2))
   get_tree().get_root().add_child(new_beam)
      

class PulsarBeam extends MeshInstance3D:
   var MAX_LIFETIME: float = 0.25
   var BEAM_WIDTH: float = 0.025
   var Lifetime: float
   
   func _init(length: float) -> void:
      Lifetime = MAX_LIFETIME
      mesh = CylinderMesh.new()
      mesh.height = length
      mesh.top_radius = BEAM_WIDTH
      mesh.bottom_radius = BEAM_WIDTH
      
      var mat := StandardMaterial3D.new()
      var beam_color := SettingsManager.personal_settings.PRIMARY_COLOR
      beam_color.a = 0.5
      mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
      mat.albedo_color = beam_color
      mat.emission_enabled = true
      mat.emission = beam_color
      mat.emission_energy_multiplier = 50
      mesh.material = mat
   
      
   
   func _process(delta: float) -> void: 
      if Lifetime >= 0: 
         Lifetime -= delta
         mesh.top_radius    -= (delta*BEAM_WIDTH)/MAX_LIFETIME
         mesh.bottom_radius -= (delta*BEAM_WIDTH)/MAX_LIFETIME
      else: queue_free()
      
