extends Familiar
class_name GreatBallOFireFamiliar

const FIREBALL_MESH: Mesh = preload("res://2_spells/actives/GreatBallOFire/familiar/new_fireball_mesh.tres")
const FIREBALL_SHADER: Shader = preload("res://2_spells/actives/GreatBallOFire/familiar/fireball_shader.gdshader")
const FIREBALL_NOISE: NoiseTexture2D = preload("res://2_spells/actives/GreatBallOFire/familiar/fireball_noise.tres")
const FIREBALL_SHAPE: CapsuleShape3D = preload("res://2_spells/actives/GreatBallOFire/familiar/fireball_collision_shape.tres")

const MAX_LIFE_TIME: float = 15
const SPEED: float = 15.0
#const SPEED: float = 1.0

var Velocity: Vector3
var my_grad: GradientTexture1D

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
   Velocity.y += -delta*(SPEED/30.0)

static func create_from_byte_array(owner_id: int, data: PackedByteArray) -> Familiar:
   var new_position := Vector3( data.decode_float( 0), data.decode_float( 4), data.decode_float( 8) )
   var new_velocity := Vector3( data.decode_float(12), data.decode_float(16), data.decode_float(20) )
   return GreatBallOFireFamiliar.new(owner_id, new_position, new_velocity) 
func reduce_to_byte_array() -> PackedByteArray:
   var data: PackedByteArray = []
   data.resize(4 * 8)
   data.encode_float( 0, position.x)
   data.encode_float( 4, position.y)
   data.encode_float( 8, position.z)
   data.encode_float(12, Velocity.x)
   data.encode_float(16, Velocity.y)
   data.encode_float(20, Velocity.z)
   self.queue_free()
   return data

func _init(owner_id: int, fireball_pos: Vector3, fireball_velocity: Vector3) -> void:
   super(owner_id, MAX_LIFE_TIME)
   position = fireball_pos
   Velocity = fireball_velocity
   name = str(owner_id) + "__great_ball_o_fire__" + str(randi())
   
   var shader_mat := ShaderMaterial.new()
   var new_gradient_tex := GradientTexture1D.new()
   var new_gradient := Gradient.new()
   var ball_color: Color = SettingsManager.peer_settings[owner_id].primary_color   if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.PRIMARY_COLOR
   var tail_color: Color = SettingsManager.peer_settings[owner_id].secondary_color if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.SECONDARY_COLOR
   new_gradient.set_color(0, ball_color)
   new_gradient.set_color(1, tail_color)
   new_gradient.set_offset(0, 0.2)
   new_gradient.set_offset(1, 0.8)
   #new_gradient.interpolation_color_space = Gradient.ColorSpace.GRADIENT_COLOR_SPACE_OKLAB
   new_gradient_tex.gradient = new_gradient
   my_grad = new_gradient_tex
   
   shader_mat.shader = FIREBALL_SHADER
   shader_mat.set_shader_parameter("noise_sampler", FIREBALL_NOISE)
   shader_mat.set_shader_parameter("gradient_sampler", new_gradient_tex)
   
   var mesh_inst := MeshInstance3D.new()
   mesh_inst.mesh = FIREBALL_MESH
   mesh_inst.material_override = shader_mat
   add_child(mesh_inst)
   
   var area := Area3D.new()
   var col_shape := CollisionShape3D.new()
   col_shape.shape = FIREBALL_SHAPE
   col_shape.position.z = 0.375
   col_shape.rotation_degrees.x = 90
   area.add_child(col_shape)
   area.collision_mask = 5
   area.body_entered.connect(_on_body_entered)
   add_child(area)
   
   
   #var packed = PackedScene.new()
   #packed.pack(self)
   #ResourceSaver.save(packed, "res://saved_branch.tscn")

func _ready() -> void:
   if Velocity.length_squared() > 0.001:
      look_at(global_position + Velocity, Vector3.UP)

func _on_body_entered(body: Node3D) -> void:
   if not ThePlayer: return
   var parent_node: Node3D = body.get_parent()
   if parent_node and parent_node is Dummy and parent_node.NETWORK_ID != OwnerID:
      var stat_influenced_damage : float = GreatBallOFire.SPELL_DAMAGE * SpellData.get_influenced_stat(SpellData.StatTypes.DAMAGE, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.DAMAGE], ThePlayer.SpellBook.get_stat(SpellData.StatTypes.DAMAGE))
      
      var new_damage_package = DamagePackage.new()
      new_damage_package.id_from = OwnerID
      new_damage_package.id_to = parent_node.NETWORK_ID
      new_damage_package.location_source = global_position
      new_damage_package.location_receipt = parent_node.global_position
      new_damage_package.amount = stat_influenced_damage
      new_damage_package.type = DamagePackage.DamageType.ZAP
      new_damage_package.force = 0.0
      ThePlayer.send_damage_package(new_damage_package)
   elif body is CollisionObject3D and body.collision_layer == 1:
      self.queue_free()
