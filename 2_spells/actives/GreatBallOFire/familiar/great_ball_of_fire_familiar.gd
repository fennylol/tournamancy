extends Familiar
class_name GreatBallOFireFamiliar

const MAX_LIFE_TIME: float = 15
const FIREBALL_MESH: Mesh = preload("res://2_spells/actives/GreatBallOFire/familiar/fireball_mesh.tres")
const SPEED: float = 15.0

var Velocity: Vector3


func _physics_process(delta: float) -> void:
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
   
   var mesh_inst := MeshInstance3D.new()
   mesh_inst.mesh = FIREBALL_MESH
   add_child(mesh_inst)
