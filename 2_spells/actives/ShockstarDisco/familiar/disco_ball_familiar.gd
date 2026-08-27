extends Familiar
class_name DiscoBallFamiliar

const DISCO_SHADER_MAT := preload("res://2_spells/actives/ShockstarDisco/familiar/disco_shader_material.tres")
const MAX_LIFE_TIME: float = 30.0

var LightBar: Node3D
var DamageMesh: MeshInstance3D
var DamageArea: Area3D
var MeshInstance: MeshInstance3D
var CollisionArea: Area3D
var CollisionShape: CollisionShape3D

var Velocity: Vector3
var PrevPosition: Vector3
var BounceCount: int = 0
var DamageTime: float = 0
 
# BALANCE PARAMETERS #
const SPELL_DAMAGE: float = 5.0
const RADIUS      : float = 0.35
const DMG_RADIUS  : float = 5*RADIUS
const DMG_TIME    : float = 0.1
const SPEED       : float = 15.0
const GRAVITY     : float = 0.8
const ELASTICITY  : float = 0.85
const MAX_BOUNCES : int   = 5


# we use _init() and reduce_to_byte_array() to ensure all necessary info is present
# before sending over the network.
func _init(owner_id: int, projectile_pos: Vector3, projectile_velocity: Vector3) -> void:
   super(owner_id, MAX_LIFE_TIME)
   name = str(owner_id) + "__disco_ball__" + str(randi())
   position = projectile_pos
   Velocity = projectile_velocity
   
   var primary_color  : Color = SettingsManager.peer_settings[owner_id].primary_color   if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.PRIMARY_COLOR
   var secondary_color: Color = SettingsManager.peer_settings[owner_id].secondary_color if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.SECONDARY_COLOR
   
   MeshInstance = MeshInstance3D.new()
   var sphere_mesh := SphereMesh.new()
   sphere_mesh.height = RADIUS*2
   sphere_mesh.radius = RADIUS
   MeshInstance.mesh = sphere_mesh
   MeshInstance.set_surface_override_material(0, DISCO_SHADER_MAT)
   add_child(MeshInstance)
   
   DamageMesh = MeshInstance3D.new()
   var dmg_sphere_mesh := SphereMesh.new()
   dmg_sphere_mesh.height = DMG_RADIUS*2
   dmg_sphere_mesh.radius = DMG_RADIUS
   DamageMesh.mesh = dmg_sphere_mesh
   var dmg_sphere_mat := StandardMaterial3D.new()
   dmg_sphere_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
   dmg_sphere_mat.albedo_color = Color(1,1,1,0.75)
   DamageMesh.set_surface_override_material(0, dmg_sphere_mat)
   DamageMesh.visible = false
   add_child(DamageMesh)
   
   CollisionArea = Area3D.new()
   CollisionArea.collision_layer = 8
   CollisionArea.collision_mask = 9
   CollisionArea.body_entered.connect(_resolve_bounce)
   CollisionArea.area_entered.connect(_resolve_bounce)
   add_child(CollisionArea)
   
   CollisionShape = CollisionShape3D.new()
   var sphere_shape := SphereShape3D.new()
   sphere_shape.radius = RADIUS
   CollisionShape.shape = sphere_shape
   CollisionArea.add_child(CollisionShape)
   
   DamageArea = Area3D.new()
   DamageArea.monitorable = false
   DamageArea.collision_layer = 0
   DamageArea.collision_mask = 4
   add_child(DamageArea)
   
   var dmg_collision_shape = CollisionShape3D.new()
   var dmg_sphere_shape := SphereShape3D.new()
   dmg_sphere_shape.radius = DMG_RADIUS
   dmg_collision_shape.shape = dmg_sphere_shape
   DamageArea.add_child(dmg_collision_shape)
   
   LightBar = Node3D.new()
   add_child(LightBar)
   
   for i in randi_range(3, 5):
      var prim_light := OmniLight3D.new()
      prim_light.light_color = primary_color
      prim_light.omni_range = RADIUS*10
      #prim_light.omni_attenuation = 0.25
      prim_light.light_energy = 0.25
      prim_light.position = Vector3(
         randf_range(RADIUS*2, RADIUS*4) * (2*floor(randf()+0.5)-1), 
         randf_range(RADIUS*2, RADIUS*4) * (2*floor(randf()+0.5)-1), 
         randf_range(RADIUS*2, RADIUS*4) * (2*floor(randf()+0.5)-1))
      LightBar.add_child(prim_light) 
      
      var secd_light := OmniLight3D.new()
      secd_light.light_color = secondary_color
      secd_light.omni_range = RADIUS*10
      #secd_light.omni_attenuation = 0.25
      secd_light.light_energy = 0.15
      secd_light.position = Vector3(
         randf_range(RADIUS*2, RADIUS*4) * (2*floor(randf()+0.5)-1), 
         randf_range(RADIUS*2, RADIUS*4) * (2*floor(randf()+0.5)-1), 
         randf_range(RADIUS*2, RADIUS*4) * (2*floor(randf()+0.5)-1))
      LightBar.add_child(secd_light) 
      
# pack essential info into a PackedByteArray then destroy self. 
# inverse of create_from_byte_array()
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

# restore from a PackedByteArray recieved over the network.
# inverse of reduce_to_byte_array()
static func create_from_byte_array(owner_id: int, data: PackedByteArray) -> Familiar: 
   var new_position := Vector3( data.decode_float( 0), data.decode_float( 4), data.decode_float( 8) )
   var new_velocity := Vector3( data.decode_float(12), data.decode_float(16), data.decode_float(20) )
   return DiscoBallFamiliar.new(owner_id, new_position, new_velocity) 

func _physics_process(delta: float) -> void:
   PrevPosition = position
   position    +=  delta*Velocity*SPEED
   Velocity.y  += -delta*GRAVITY
   MeshInstance.rotation +=  delta*Velocity*SPEED
   LightBar.rotation += delta*SPEED*Vector3(SettingsManager.personal_settings.PRIMARY_COLOR.r, SettingsManager.personal_settings.PRIMARY_COLOR.g, SettingsManager.personal_settings.PRIMARY_COLOR.b )
   #DamageMesh.visible = false
   
   if Velocity.length_squared() > 0.001:
      var dir := Velocity.normalized()
      var up := Vector3.UP
      if abs(dir.dot(up)) > 0.999:
         up = Vector3.FORWARD

      var target_basis := Basis.looking_at(dir, up)
      var target_quat := target_basis.get_rotation_quaternion()
      var current_quat := global_transform.basis.get_rotation_quaternion()
      var new_quat := current_quat.slerp(target_quat, 1.0 - exp(-SPEED * delta))
      global_transform.basis = Basis(new_quat)

func _resolve_bounce(_contact: Node3D) -> void:
   var space_state := get_world_3d().direct_space_state

   var query := PhysicsShapeQueryParameters3D.new()
   query.shape = CollisionShape.shape
   query.transform = CollisionShape.global_transform
   query.collision_mask = CollisionArea.collision_mask
   query.collide_with_bodies = true
   query.collide_with_areas = true
   query.exclude = [CollisionArea.get_rid(), DamageArea.get_rid()]

   var contacts := space_state.get_rest_info(query)

   if contacts.has("normal"):
      DamageMesh.visible = true
      DamageTime = 0.0
      Velocity = Velocity.bounce(contacts.normal) * ELASTICITY
      BounceCount += 1
      
      if ThePlayer:
         for body in DamageArea.get_overlapping_bodies():
            if body.get_parent() is Dummy: 
               send_damage(body.get_parent())
      
      if Velocity.length_squared() < 0.025:
         queue_free()
  

func _process(delta: float) -> void:
   super(delta)
   if DamageTime <= DMG_TIME: DamageTime += delta
   elif BounceCount >= MAX_BOUNCES: queue_free() 
   else: DamageMesh.visible = false

func send_damage(enemy : Dummy):
   var stat_influenced_damage : float = GreatBallOFire.SPELL_DAMAGE * SpellData.get_influenced_stat(SpellData.StatTypes.DAMAGE, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.DAMAGE], ThePlayer.SpellBook.get_stat(SpellData.StatTypes.DAMAGE))
      
   var new_damage_package = DamagePackage.new()
   new_damage_package.id_from = OwnerID
   new_damage_package.id_to = enemy.NETWORK_ID
   new_damage_package.location_source = global_position
   new_damage_package.location_receipt = enemy.global_position
   new_damage_package.amount = stat_influenced_damage
   new_damage_package.type = DamagePackage.DamageType.ZAP
   new_damage_package.force = 0.0
   ThePlayer.send_damage_package(new_damage_package)
