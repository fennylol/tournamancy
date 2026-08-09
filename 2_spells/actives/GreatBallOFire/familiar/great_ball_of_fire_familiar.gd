extends Familiar
class_name GreatBallOFireFamiliar

const FIREBALL_MESH: Mesh = preload("res://2_spells/actives/GreatBallOFire/familiar/new_fireball_mesh.tres")
const FIREBALL_SHADER: Shader = preload("res://2_spells/actives/GreatBallOFire/familiar/fireball_shader.gdshader")
const FIREBALL_NOISE: NoiseTexture2D = preload("res://2_spells/actives/GreatBallOFire/familiar/fireball_noise.tres")
const FIREBALL_GRADIENT: GradientTexture1D = preload("res://2_spells/actives/GreatBallOFire/familiar/fireball_gradient.tres")

const MAX_LIFE_TIME: float = 15
const SPEED: float = 15.0

var Velocity: Vector3

func _physics_process(delta: float) -> void:
   if Velocity.length_squared() > 0.001:
      var dir := Velocity.normalized()
      var up := Vector3.UP
      if abs(dir.dot(up)) > 0.999:
         up = Vector3.FORWARD

      # build the target orientation without touching our actual transform
      var target_basis := Basis.looking_at(dir, up)
      var target_quat := target_basis.get_rotation_quaternion()
      var current_quat := global_transform.basis.get_rotation_quaternion()

      var new_quat := current_quat.slerp(target_quat, 1.0 - exp(-SPEED * delta))

      global_transform.basis = Basis(new_quat)
   
   position += Velocity*SPEED*delta
   Velocity.y += -delta*0.5

static func create_from_byte_array(owner_id: int, data: PackedByteArray) -> Familiar:
   var new_position := Vector3( data.decode_float( 0), data.decode_float( 4), data.decode_float( 8) )
   var new_velocity := Vector3( data.decode_float(12), data.decode_float(16), data.decode_float(20) )
   return GreatBallOFireFamiliar.new(owner_id, new_position, new_velocity) 
func reduce_to_byte_array() -> PackedByteArray:
   var data: PackedByteArray = []
   data.resize(4 * 6)
   data.encode_float( 0, position.x)
   data.encode_float( 4, position.y)
   data.encode_float( 8, position.z)
   data.encode_float(12, Velocity.x)
   data.encode_float(16, Velocity.y)
   data.encode_float(20, Velocity.z)
   self.queue_free()
   return data

func _init(owner_id: int, fireball_pos: Vector3, fireball_velocity : Vector3) -> void:
   super(owner_id, MAX_LIFE_TIME)
   position = fireball_pos
   Velocity = fireball_velocity
   name = str(owner_id) + "__great_ball_o_fire__" + str(randi())
   
   var shader_mat := ShaderMaterial.new()
   shader_mat.shader = FIREBALL_SHADER
   shader_mat.set_shader_parameter("noise_sampler", FIREBALL_NOISE)
   shader_mat.set_shader_parameter("gradient_sampler", FIREBALL_GRADIENT)
   
   var mesh_inst := MeshInstance3D.new()
   mesh_inst.mesh = FIREBALL_MESH
   mesh_inst.material_override = shader_mat
   add_child(mesh_inst)

func _ready() -> void:
   if Velocity.length_squared() > 0.001:
      look_at(global_position + Velocity, Vector3.UP)
