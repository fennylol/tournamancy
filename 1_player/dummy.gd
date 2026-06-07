extends Node3D
class_name Dummy

var velocity := Vector3.ZERO
var _net_pos := Vector3.ZERO
var _net_rot := Vector3.ZERO
var _net_vel := Vector3.ZERO
var _has_net_state: bool = false
var _time_since_packet: float = 0.0
const EXTRAPOLATION_LIMIT: float = 0.5  # seconds

func _on_transform_data(data: PackedByteArray) -> void:
   _net_pos = Vector3(data.decode_float(0),  data.decode_float(4),  data.decode_float(8))
   _net_rot = Vector3(data.decode_float(12), data.decode_float(16), data.decode_float(20))
   _net_vel = Vector3(data.decode_float(24), data.decode_float(28), data.decode_float(32))
   _has_net_state = true
   _time_since_packet = 0.0

func _physics_process(delta: float) -> void:
   if not _has_net_state: return

   _time_since_packet += delta
   if _time_since_packet < EXTRAPOLATION_LIMIT:
      _net_pos += _net_vel * delta   # only extrapolate while data is fresh

   var t := 1.0 - exp(-20.0 * delta)
   position = position.lerp(_net_pos, t)
   quaternion = quaternion.slerp(Quaternion.from_euler(_net_rot), t)
   velocity = _net_vel
