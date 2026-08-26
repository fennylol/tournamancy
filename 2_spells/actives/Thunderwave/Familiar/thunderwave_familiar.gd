extends Familiar
class_name ThunderwaveFamiliar

# a failsafe in seconds. self destructs at end.
const MAX_LIFE_TIME: float = 0.5

var wave_size  : Vector3
var wave_reach : float
var WAVEMESH := MeshInstance3D.new()
var WAVESPEED : float

func _init(owner_id: int, wave_position: Vector3, wave_rotation: Vector3, size : Vector3, reach: float) -> void: 
   super(owner_id, MAX_LIFE_TIME)
   name = str(owner_id) + "__thunderwave_box__" + str(randi())
   
   rotation = wave_position
   position = wave_rotation
   wave_size = size
   wave_reach = reach
   
   WAVESPEED = wave_reach / MAX_LIFE_TIME
   
   add_child(WAVEMESH)
   WAVEMESH.mesh = BoxMesh.new()
   WAVEMESH.mesh.size = wave_size
   var mat := StandardMaterial3D.new()
   mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
   mat.metallic = 0.0
   mat.roughness = 1.0
   mat.albedo_color = SettingsManager.peer_settings[owner_id].primary_color   if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.PRIMARY_COLOR
   mat.albedo_color.a = 0.5
   WAVEMESH.mesh.material = mat

# pack essential info into a PackedByteArray then destroy self. 
# inverse of create_from_byte_array()
func reduce_to_byte_array() -> PackedByteArray: 
   var data: PackedByteArray = []
   data.resize(40)
   data.encode_float( 0, position.x)
   data.encode_float( 4, position.y)
   data.encode_float( 8, position.z)
   data.encode_float(12, rotation.x)
   data.encode_float(16, rotation.y)
   data.encode_float(20, rotation.z)
   data.encode_float(24, wave_size.x)
   data.encode_float(28, wave_size.y)
   data.encode_float(32, wave_size.z)
   data.encode_float(36, wave_reach)
   self.queue_free()
   return data

# restore from a PackedByteArray recieved over the network.
# inverse of reduce_to_byte_array()
static func create_from_byte_array(owner_id: int, data: PackedByteArray) -> ThunderwaveFamiliar: 
   var pos : Vector3
   var rot : Vector3
   var siz : Vector3
   var rch : float
   pos.x = data.decode_float(0)
   pos.y = data.decode_float(4)
   pos.z = data.decode_float(8)
   rot.x = data.decode_float(12)
   rot.y = data.decode_float(16)
   rot.z = data.decode_float(20)
   siz.x = data.decode_float(24)
   siz.y = data.decode_float(28)
   siz.z = data.decode_float(32)
   rch   = data.decode_float(36)
   return ThunderwaveFamiliar.new(owner_id, pos, rot, siz, rch)

func _process(delta: float) -> void:
   position -= transform.basis.z.normalized() * delta * WAVESPEED
   super(delta)
