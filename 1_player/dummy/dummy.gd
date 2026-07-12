extends Node3D
class_name Dummy

@onready var Eyes   : Node3D   = $Eyes
@onready var Lhand  : Sprite3D = $Eyes/Lhand
@onready var Rhand  : Sprite3D = $Eyes/Rhand
@onready var NameTag: Label3D  = $NameTag

const HandImg : Texture2D = preload("res://4_ui/hud/oppponent_hand.png")
const PointImg: Texture2D = preload("res://4_ui/hud/oppponent_point.png")

var velocity := Vector3.ZERO
var _net_pos := Vector3.ZERO
var _net_rot := Vector3.ZERO
var _net_vel := Vector3.ZERO
var _has_net_state: bool = false
var _time_since_packet: float = 0.0
const EXTRAPOLATION_LIMIT: float = 0.5  # seconds

func _physics_process(delta: float) -> void:
   if not _has_net_state: return

   _time_since_packet += delta
   if _time_since_packet < EXTRAPOLATION_LIMIT:
      _net_pos += _net_vel * delta   # only extrapolate while data is fresh

   var t := 1.0 - exp(-20.0 * delta)
   position = position.lerp(_net_pos, t)
   quaternion = quaternion.slerp(Quaternion.from_euler(Vector3(0, _net_rot.y, _net_rot.z)), t)
   
   Eyes.rotation.x = clamp(_net_rot.x, -PI/2, PI/2)
   
   velocity = _net_vel
func _on_transform_data(data: PackedByteArray) -> void:
   _net_pos = Vector3(data.decode_float(0),  data.decode_float(4),  data.decode_float(8))
   _net_rot = Vector3(data.decode_float(12), data.decode_float(16), data.decode_float(20))
   _net_vel = Vector3(data.decode_float(24), data.decode_float(28), data.decode_float(32))
   
   var flags := data.decode_u8(36)
   Lhand.texture = HandImg if flags & (1 << 0) else PointImg
   Rhand.texture = HandImg if flags & (1 << 1) else PointImg
   
   _has_net_state = true
   _time_since_packet = 0.0
func _on_nametag_data(new_name: String) -> void:
   NameTag.text = new_name
func _on_subspell_equip_data(_spell_id: int, _is_active: bool) -> void: pass
func _on_subspell_erase_data(_spell_id: int, _is_active: bool) -> void: pass
func _on_subspell_state_data(_spell_id: int, _is_active: bool, _spell_state: int) -> void: pass
