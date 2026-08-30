# meta-name: Default
# meta-description: Base template for projectile Familiars
# meta-default: true
# meta-space-indent: 3
# Familiars are used when you want to spawn an entity that is independent of the 
# spawning player. When spawning one (generally from an effect/spell), the spawning
# script should create one with new() and immediately call reduce_to_byte_array()
# on it. the resulting PackedByteArray can be passed to the Player's spawn_familiar()
extends Familiar
# TODO: name your new Familiar
class_name NewFamiliar

# a failsafe in seconds. self destructs at end.
const MAX_LIFE_TIME: float = 30.0

const SPEED: float = 15.0
const GRAVITY: float = 0.25
var Velocity: Vector3

# we use _init() and reduce_to_byte_array() to ensure all necessary info is present
# before sending over the network.
func _init(owner_id: int, projectile_pos: Vector3, projectile_velocity: Vector3) -> void:
   super(owner_id, MAX_LIFE_TIME)
   name = str(owner_id) + "__new_projectile_familiar__" + str(randi())
   position = projectile_pos
   Velocity = projectile_velocity
   #var primary_color  : Color = SettingsManager.peer_settings[owner_id].primary_color   if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.PRIMARY_COLOR
   #var secondary_color: Color = SettingsManager.peer_settings[owner_id].secondary_color if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.SECONDARY_COLOR

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
   # TODO: name your new Familiar
   return NewFamiliar.new(owner_id, new_position, new_velocity) 

func _physics_process(delta: float) -> void:
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


# NOTE: don't forget to add your Familiar to the SpellList