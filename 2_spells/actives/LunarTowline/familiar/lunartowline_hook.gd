extends Familiar
class_name LunarTowline_Hook

# a failsafe in seconds. self destructs at end.
const MAX_LIFE_TIME: float = 120.0

const SPEED: float = 15.0
const GRAVITY: float = 0.25
var Velocity: Vector3

var hooked_id : int = 0
var HOOK_POS_OWNER : Vector3
var HOOK_POS_TARGET : Vector3

var mesh_instance := MeshInstance3D.new()

# we use _init() and reduce_to_byte_array() to ensure all necessary info is present
# before sending over the network.
func _init(owner_id: int, projectile_pos: Vector3, projectile_velocity: Vector3) -> void:
   super(owner_id, MAX_LIFE_TIME)
   name = str(owner_id) + "__lunar_towline_hook__" + str(randi())
   position = projectile_pos
   Velocity = projectile_velocity
   #var primary_color  : Color = SettingsManager.peer_settings[owner_id].primary_color   if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.PRIMARY_COLOR
   #var secondary_color: Color = SettingsManager.peer_settings[owner_id].secondary_color if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.SECONDARY_COLOR
   
   add_child(mesh_instance)
   mesh_instance.mesh = SphereMesh.new()
   mesh_instance.mesh.radius = 0.1
   mesh_instance.mesh.height = 0.2
   var area := Area3D.new()
   add_child(area)
   var collisionshape := CollisionShape3D.new()
   area.add_child(collisionshape)
   collisionshape.shape = SphereShape3D.new()
   collisionshape.shape.radius = 4.0
   
   area.collision_layer = 8
   area.collision_mask = 4
   area.body_entered.connect(_on_body_entered)

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
static func create_from_byte_array(owner_id: int, data: PackedByteArray) -> LunarTowline_Hook: 
   var new_position := Vector3( data.decode_float( 0), data.decode_float( 4), data.decode_float( 8) )
   var new_velocity := Vector3( data.decode_float(12), data.decode_float(16), data.decode_float(20) )
   # TODO: name your new Familiar
   return LunarTowline_Hook.new(owner_id, new_position, new_velocity) 

func _physics_process(delta: float) -> void:
   if hooked_id != 0:
      pass
   else:
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
         
      position   +=  delta*SPEED*Velocity
      Velocity.y += -delta*GRAVITY

#func _process(delta: float) -> void:
   #super(delta) # NOTE: keep this line if adding custom _process(). kills self at end of life.

func _on_body_entered(body : Node3D):
   if hooked_id != 0: return
   if body is Player or body is Dummy:
      if body.NETWORK_ID == OwnerID: return
      hooked_id = body.NETWORK_ID
      print("hooked ", hooked_id)
