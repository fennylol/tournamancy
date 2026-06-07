extends Node
class_name MultiplayerManager

@onready var ConnectionMenu : ConnectMenu = $ConnectMenu
var MultiPlayerCoupler := PingusPrime.new()

signal on_connection_established()
signal on_transform_data(id: int, data: PackedByteArray)

func _ready() -> void:
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


func _recieve_message(Msg: String, Type: PingusPrime.SignalTypes) -> void:
   if Type == PingusPrime.SignalTypes.CONTROL:
      ConnectionMenu.STATUS_LABEL.text = Msg
   if MultiPlayerCoupler.PingusState == PingusPrime.PingusStates.CONNECTED:
      ConnectionMenu.visible = false
      on_connection_established.emit()


# ================ #
# message handling #
# ================ #
enum DataType { TransformData = 0x20, ConnectionData = 0xCD }
const TYPE_BYTE: int = 1

func _recieve_data(data: PackedByteArray) -> void:
   var type_byte: DataType = data.decode_u8(0) as DataType
   var payload: PackedByteArray = data.slice(TYPE_BYTE)
   match type_byte:
      DataType.ConnectionData:
         _establish_new_connection(payload)
      DataType.TransformData:
         on_transform_data.emit(0, payload)

func _establish_new_connection(_data: PackedByteArray) -> void:
   pass

func send_player_transform_data(player: Player) -> void:
   if not MultiPlayerCoupler.PingusState == PingusPrime.PingusStates.CONNECTED: return
   
   var packed_data := PackedByteArray()
   packed_data.resize(TYPE_BYTE + (4*9))
   packed_data.encode_u8(0, DataType.TransformData)
   packed_data.encode_float(TYPE_BYTE + 0,  player.position.x)
   packed_data.encode_float(TYPE_BYTE + 4,  player.position.y) 
   packed_data.encode_float(TYPE_BYTE + 8,  player.position.z)
   packed_data.encode_float(TYPE_BYTE + 12, player.rotation.x)
   packed_data.encode_float(TYPE_BYTE + 16, player.rotation.y) 
   packed_data.encode_float(TYPE_BYTE + 20, player.rotation.z)
   packed_data.encode_float(TYPE_BYTE + 24, player.velocity.x)
   packed_data.encode_float(TYPE_BYTE + 28, player.velocity.y)
   packed_data.encode_float(TYPE_BYTE + 32, player.velocity.z)
   
   MultiPlayerCoupler.send_data(packed_data)
