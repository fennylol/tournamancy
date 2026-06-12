extends Node
class_name MultiplayerManager

@onready var ConnectionMenu    : ConnectMenu = $ConnectMenu
@onready var ActiveConnections : Node        = $ActiveConnections
@onready var PendingConnections: Node        = $PendingConnections

signal connection_established(network_id: int)
signal transform_data(id: int, data: PackedByteArray)
signal ready_button_pressed()

var ExternalAddress: String = ""
var NetworkID: int = 0

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

   ConnectionMenu.connect_button_pressed.connect(_create_connection)
   ConnectionMenu.ready_button_pressed.connect(_on_ready_button_pressed)

func _create_connection(target_address: String) -> void:
   for conn in PendingConnections.get_children():
      if conn.TargetAddr == target_address: return

   var MPC := PingusPrime.new(ExternalAddress, NetworkID)
   NetworkID = MPC.NetworkID
   MPC.TargetAddr = target_address
   MPC.message_recieved.connect(_recieve_message)
   MPC.data_recieved.connect(_recieve_data)
   MPC.set_name("mpc_" + target_address + "_" + str(randi()))
   PendingConnections.add_child(MPC)
   ConnectionMenu.update_peers(PendingConnections.get_children() + ActiveConnections.get_children())

func _on_ready_button_pressed() -> void:
   ready_button_pressed.emit()
   ConnectionMenu.visible = false

func _recieve_message(network_id: int, Msg: String, _Type: PingusPrime.MessageTypes) -> void:
   if network_id != NetworkID: print(Msg)
   for conn in PendingConnections.get_children():
      if conn.PingusState == PingusPrime.PingusStates.CONNECTED:
         var new_addr: String = conn.TargetAddr
         PendingConnections.remove_child(conn)
         ActiveConnections.add_child(conn)

         # tell every existing peer about the new one, and vice versa
         for peer in ActiveConnections.get_children():
            if peer == conn: continue
            _send_connection_data(peer, new_addr)
            _send_connection_data(conn, peer.TargetAddr)

         connection_established.emit(network_id)

   ConnectionMenu.update_peers(PendingConnections.get_children() + ActiveConnections.get_children())

func passthrough_player_enabled_changed(new_val: bool) -> void:
   ConnectionMenu.visible = not new_val

# ================ #
# message handling #
# ================ #
enum DataType { TransformData = 0x20, ConnectionData = 0xCD }
const TYPE_BYTE: int = 1

func _recieve_data(network_id: int, data: PackedByteArray) -> void:
   var type_byte: DataType = data.decode_u8(0) as DataType
   var payload: PackedByteArray = data.slice(TYPE_BYTE)
   match type_byte:
      DataType.ConnectionData:
         _establish_new_connection(payload)
      DataType.TransformData:
         transform_data.emit(network_id, payload)

func _establish_new_connection(data: PackedByteArray) -> void:
   _create_connection(data.get_string_from_utf8())

func _send_connection_data(conn: PingusPrime, address: String) -> void:
   var packed_data := PackedByteArray()
   packed_data.resize(TYPE_BYTE)
   packed_data.encode_u8(0, DataType.ConnectionData)
   packed_data.append_array(address.to_utf8_buffer())
   conn.send_data(packed_data)

func send_player_transform_data(data: PackedByteArray) -> void:
   var packed_data := PackedByteArray()
   packed_data.resize(TYPE_BYTE)
   packed_data.encode_u8(0, DataType.TransformData)
   packed_data.append_array(data)

   for conn in ActiveConnections.get_children():
      conn.send_data(packed_data)
