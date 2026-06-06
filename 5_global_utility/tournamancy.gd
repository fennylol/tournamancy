extends Node3D
   
@onready var PlayerCharacter: Player = $Player
@onready var OpponentCharacter: Player = $Opponent
@onready var ConnectionMenu : ConnectMenu = $ConnectMenu
var MultiPlayerCoupler := PingusPrime.new()

var _net_pos := Vector3.ZERO
var _net_rot := Vector3.ZERO
var _net_vel := Vector3.ZERO
var _has_net_state := false
var _time_since_packet := 0.0
const EXTRAPOLATION_LIMIT := 0.5  # seconds

func _ready() -> void:
   InputManager.init_inputs()
   
   var handle_IP_singleton: Callable 
   handle_IP_singleton = func(msg: String, type: PingusPrime.SignalTypes) -> void:
      if msg != "IP RECIEVED" or type != PingusPrime.SignalTypes.CONTROL: printerr("INVALID MESSAGE ARRIVED EARLY")
      for function in MultiPlayerCoupler.message_recieved.get_connections():
         MultiPlayerCoupler.message_recieved.disconnect(function["callable"])
      MultiPlayerCoupler.message_recieved.connect(_recieve_message)
      MultiPlayerCoupler.data_recieved.connect(_recieve_data)
      ConnectionMenu._set_wan_label(MultiPlayerCoupler.ExternAddr)
   MultiPlayerCoupler.message_recieved.connect(handle_IP_singleton)
   
   ConnectionMenu.connect_button_pressed.connect(func(address: String): MultiPlayerCoupler.TargetAddr = address)
   
   MultiPlayerCoupler.set_name("mpc")
   add_child(MultiPlayerCoupler)

func _physics_process(delta: float) -> void:
   if MultiPlayerCoupler.PingusState == PingusPrime.PingusStates.CONNECTED:
      _send_data()

   if not _has_net_state: return

   _time_since_packet += delta
   if _time_since_packet < EXTRAPOLATION_LIMIT:
      _net_pos += _net_vel * delta   # only extrapolate while data is fresh

   var t := 1.0 - exp(-20.0 * delta)
   OpponentCharacter.position = OpponentCharacter.position.lerp(_net_pos, t)
   OpponentCharacter.quaternion = OpponentCharacter.quaternion.slerp(Quaternion.from_euler(_net_rot), t)
   OpponentCharacter.velocity = _net_vel

func _recieve_message(Msg: String, Type: PingusPrime.SignalTypes) -> void:
   if Type == PingusPrime.SignalTypes.CONTROL:
      print(Msg)
      ConnectionMenu.STATUS_LABEL.text = Msg
   if MultiPlayerCoupler.PingusState == PingusPrime.PingusStates.CONNECTED:
      ConnectionMenu.visible = false
      PlayerCharacter.enabled = true
      

func _recieve_data(data: PackedByteArray) -> void:
   _net_pos = Vector3(data.decode_float(0),  data.decode_float(4),  data.decode_float(8))
   _net_rot = Vector3(data.decode_float(12), data.decode_float(16), data.decode_float(20))
   _net_vel = Vector3(data.decode_float(24), data.decode_float(28), data.decode_float(32))
   _has_net_state = true
   _time_since_packet = 0.0

func _send_data() -> void:
   var packed_data := PackedByteArray()
   packed_data.resize(4*9)
   packed_data.encode_float(0, PlayerCharacter.position.x)
   packed_data.encode_float(4, PlayerCharacter.position.y) 
   packed_data.encode_float(8, PlayerCharacter.position.z)
   packed_data.encode_float(12, PlayerCharacter.rotation.x)
   packed_data.encode_float(16, PlayerCharacter.rotation.y) 
   packed_data.encode_float(20, PlayerCharacter.rotation.z)
   packed_data.encode_float(24, PlayerCharacter.velocity.x)
   packed_data.encode_float(28, PlayerCharacter.velocity.y)
   packed_data.encode_float(32, PlayerCharacter.velocity.z)
   MultiPlayerCoupler.send_data(packed_data)
