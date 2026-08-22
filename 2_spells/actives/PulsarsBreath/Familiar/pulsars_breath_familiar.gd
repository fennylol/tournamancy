extends Familiar
class_name PulsarsBreathFamiliar

var MAX_LIFE_TIME: float = 0.25
var BEAM_WIDTH: float = 0.025
var mesh_inst := MeshInstance3D.new()
var particles := GPUParticles3D.new()

func _init(owner_id: int, beam_position: Vector3, beam_rotation: Vector3, length: float) -> void: 
   super(owner_id, MAX_LIFE_TIME)

   rotation = beam_rotation
   position = beam_position
   
   add_child(mesh_inst)
   mesh_inst.mesh = CylinderMesh.new()
   mesh_inst.mesh.height = length
   mesh_inst.mesh.top_radius = BEAM_WIDTH
   mesh_inst.mesh.bottom_radius = BEAM_WIDTH
   
   var mat := StandardMaterial3D.new()
   var beam_color: Color = SettingsManager.peer_settings[owner_id].primary_color if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.PRIMARY_COLOR
   beam_color.a = 0.5
   mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
   mat.albedo_color = beam_color
   mat.emission = beam_color
   mat.emission_energy_multiplier = 50
   mat.emission_enabled = true
   mesh_inst.mesh.material = mat
   
   if length == 100: return
   add_child(particles)
   particles.one_shot = true
   particles.emitting = true
   particles.draw_passes = 1
   particles.amount = 75
   particles.lifetime = 0.25
   particles.position.y = -(length/2)
   
   var particle_process_material := ParticleProcessMaterial.new()
   particle_process_material.direction = Vector3.UP
   particle_process_material.gravity = Vector3.ZERO
   particle_process_material.initial_velocity_min = length/2
   particle_process_material.initial_velocity_max = length/2
   particle_process_material.angular_velocity_min = -180
   particle_process_material.angular_velocity_max =  180
   particles.process_material = particle_process_material
   
   var particle_mesh := QuadMesh.new()
   particle_mesh.size = Vector2(0.05, 0.05)
   particles.draw_pass_1 = particle_mesh
   
   var particle_mat := StandardMaterial3D.new()
   var particle_color: Color = SettingsManager.peer_settings[owner_id].secondary_color if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.SECONDARY_COLOR
   particle_mat.albedo_color = particle_color
   particle_mat.emission = particle_color
   particle_mat.emission_energy_multiplier = 5
   particle_mat.emission_enabled = true
   particle_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
   particle_mat.billboard_keep_scale = true
   particles.material_override = particle_mat
    
func reduce_to_byte_array() -> PackedByteArray: 
   var data: PackedByteArray = []
   data.resize(4 * 7)
   data.encode_float( 0, position.x)
   data.encode_float( 4, position.y)
   data.encode_float( 8, position.z)
   data.encode_float(12, rotation.x)
   data.encode_float(16, rotation.y)
   data.encode_float(20, rotation.z)
   data.encode_float(24, mesh_inst.mesh.height)
   self.queue_free()
   return data

static func create_from_byte_array(owner_id: int, data: PackedByteArray) -> Familiar: 
   var pos    := Vector3(data.decode_float(0),  data.decode_float(4),  data.decode_float(8))
   var rot    := Vector3(data.decode_float(12), data.decode_float(16), data.decode_float(20))
   var length := data.decode_float(24)
   return PulsarsBreathFamiliar.new(owner_id, pos, rot, length)


func _process(delta: float) -> void:
   super(delta)
   mesh_inst.mesh.top_radius    -= (delta*BEAM_WIDTH)/MAX_LIFE_TIME
   mesh_inst.mesh.bottom_radius -= (delta*BEAM_WIDTH)/MAX_LIFE_TIME
