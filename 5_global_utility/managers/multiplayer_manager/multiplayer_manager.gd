extends Node
class_name MultiplayerManager

@onready var ConnectionMenu: ConnectMenu = $ConnectMenu
@onready var ActiveConnections: Node = $ActiveConnections
@onready var PendingConnections: Node = $PendingConnections

signal on_connection_established(network_id: int)
signal on_transform_data(id: int, data: PackedByteArray)

var ExternalAddress: String = ""


func _ready() -> void:
   var ipg := PingusPrime.IPGopher.new()
   ipg.ip_fetching_finished.connect(
      func(result: PingusPrime.IPGopher.IpFetchingErrs):
         var retry_on_fail: Callable = func(err_str: String):
            printerr(err_str + " Retrying... ")
            await get_tree().create_timer(PingusPrime.RETRY_TIME).timeout
            ipg._attempt_addr_fetch()
         
         match result:
            PingusPrime.IPGopher.IpFetchingErrs.OK:
               ExternalAddress = ipg.get_address_as_string()
               ConnectionMenu._set_wan_label(ExternalAddress)
               ipg.queue_free()
            PingusPrime.IPGopher.IpFetchingErrs.BAD_RESULT  : retry_on_fail.call("BAD_RESULT.")
            PingusPrime.IPGopher.IpFetchingErrs.BAD_RESPONSE: retry_on_fail.call("BAD_RESPONSE.")
            PingusPrime.IPGopher.IpFetchingErrs.BAD_IP      : retry_on_fail.call("BAD_IP.")
   )
   
   ipg.set_name("PingusPrime.IPGopher")
   add_child(ipg)
   
   ConnectionMenu.connect_button_pressed.connect(
      func(address: String):
         create_connection(address)
   )

func create_connection(target_address: String) -> void:
   var MPC := PingusPrime.new(ExternalAddress)
   MPC.TargetAddr = target_address
   MPC.message_recieved.connect(_recieve_message)
   MPC.data_recieved.connect(_recieve_data)
   MPC.set_name("mpc_" + target_address)
   PendingConnections.add_child(MPC)





func _recieve_message(Msg: String, Type: PingusPrime.MessageTypes) -> void:
   print(Msg)
   if Type == PingusPrime.MessageTypes.CONTROL:
      ConnectionMenu.STATUS_LABEL.text = Msg
   for conn in PendingConnections.get_children():
      if conn.PingusState == PingusPrime.PingusStates.CONNECTED:
         var id: int = conn.NetworkID
         PendingConnections.remove_child(conn)
         ActiveConnections.add_child(conn)
         on_connection_established.emit(id)


# ================ #
# message handling #
# ================ #
enum DataType { TransformData = 0x20, ConnectionData = 0xCD }
const TYPE_BYTE: int = 1

func _recieve_data(netword_id:int, data: PackedByteArray) -> void:
   var type_byte: DataType = data.decode_u8(0) as DataType
   var payload: PackedByteArray = data.slice(TYPE_BYTE)
   match type_byte:
      DataType.ConnectionData:
         _establish_new_connection(payload)
      DataType.TransformData:
         on_transform_data.emit(netword_id, payload)

func _establish_new_connection(_data: PackedByteArray) -> void:
   pass

func send_player_transform_data(data: PackedByteArray) -> void:
   var packed_data := PackedByteArray()
   packed_data.resize(TYPE_BYTE)
   packed_data.encode_u8(0, DataType.TransformData)
   packed_data.append_array(data)

   for conn in ActiveConnections.get_children():
      conn.send_data(packed_data)
