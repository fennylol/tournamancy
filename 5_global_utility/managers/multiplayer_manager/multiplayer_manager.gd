extends Node
class_name MultiplayerManager

@onready var ConnectionMenu    : ConnectMenu = $ConnectMenu
@onready var ActiveConnections : Node        = $ActiveConnections
@onready var PendingConnections: Node        = $PendingConnections

signal ready_button_pressed()

signal connection_established(network_id: int)
signal transform_data(network_id: int, data: PackedByteArray)
signal name_data(network_id: int, data: PackedByteArray)

var ExternalAddress: String = ""
var NetworkID: int = 0
var NameTag: String = ""

func _ready() -> void:
   ConnectionMenu.settings_button_pressed.connect(_on_settings_button_pressed)
   ConnectionMenu.name_changed.connect(_on_name_changed)
   ConnectionMenu.connect_button_pressed.connect(_create_connection)
   ConnectionMenu.ready_button_pressed.connect(_on_ready_button_pressed)
   #_get_addr_and_port()
#func _get_addr_and_port() -> void:
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
   
   while NetworkID == 0:
      seed((Time.get_unix_time_from_system()*100000) as int)
      NetworkID = randi()
   ConnectionMenu._set_id_label(str(NetworkID))
   NameTag = str(NetworkID)

# =============== #
# signal handling #
# =============== #
# remote_id is the peer's NetworkID when known (gossip); 0 for manual connects.
# several instances can share one IP, so peers are deduplicated by NetworkID:
# here when the ID is already known, otherwise at establish time once the
# peer's ID has been learned.
func _create_connection(target_address: String, target_id: int = 0) -> void:
   if target_id != 0 and target_id == NetworkID: return
   if target_id != 0:
      for conn in PendingConnections.get_children() + ActiveConnections.get_children():
         if conn.TargetID == target_id: return

   var MPC := PingusPrime.new(ExternalAddress, NetworkID)
   MPC.TargetAddr = target_address
   MPC.TargetID = target_id
   MPC.recieved_data.connect(_recieve_data)
   MPC.connection_established.connect(_on_connection_established.bind(MPC))
   MPC.set_name("mpc_" + target_address + "_" + str(randi()))
   PendingConnections.add_child(MPC)
   _refresh_peer_list()
func _on_connection_established(network_id: int, conn: PingusPrime) -> void:
   # duplicates to a same-IP peer can only be detected once the peer's
   # NetworkID is known: drop this connection if its peer is already active.
   for peer in ActiveConnections.get_children():
      if peer.TargetID == conn.TargetID:
         PendingConnections.remove_child(conn)
         conn.queue_free()
         _refresh_peer_list()
         return

   PendingConnections.remove_child(conn)
   ActiveConnections.add_child(conn)
   var split_name := conn.name.split("_")
   split_name[-1] = str(network_id)
   conn.name = "_".join(split_name) 

   # tell every existing peer about the new one, and vice versa
   for peer in ActiveConnections.get_children():
      if peer == conn: continue
      _send_connection_data(peer, conn)
      _send_connection_data(conn, peer)

   connection_established.emit(network_id)
   _refresh_peer_list()
   _send_nametag_data()
func _on_ready_button_pressed() -> void:
   ready_button_pressed.emit()
   ConnectionMenu.visible = false
func _on_name_changed(new_name: String) -> void:
   NameTag = new_name
   _send_nametag_data()
func _on_settings_button_pressed(min_port: int, max_port: int, rate: int) -> void:
   for conn in PendingConnections.get_children():
      if not conn is PingusPrime: continue
      conn.SprayPortMin = min_port
      conn.SprayPortMax = max_port
      conn.SprayRate = rate

func passthrough_player_enabled_changed(new_val: bool) -> void:
   ConnectionMenu.visible = not new_val
func _refresh_peer_list() -> void:
   ConnectionMenu.update_peers(PendingConnections.get_children() + ActiveConnections.get_children())

# ============ #
# data routing #
# ============ #
enum DataTypes { TransformData = 0x20, ConnectionData = 0xCD, NameTagData = 0x15}
const PEER_ID_SIZE: int = 4

func _recieve_data(network_id: int, data_type: int, data: PackedByteArray) -> void:
   match data_type:
      DataTypes.TransformData : transform_data.emit(network_id, data)
      DataTypes.NameTagData   : _recieve_name_data(network_id, data)
      DataTypes.ConnectionData: _recieve_connection_data(data)
      PingusPrime.DataTypes.CONTROL:
         _refresh_peer_list()
func _recieve_connection_data(data: PackedByteArray) -> void:
   if data.size() < PEER_ID_SIZE:
      return
   _create_connection(data.slice(PEER_ID_SIZE).get_string_from_utf8(), data.decode_u32(0))
func _recieve_name_data(network_id: int, data: PackedByteArray) -> void:
   for conn in ActiveConnections.get_children():
      if not conn is PingusPrime: continue
      if conn.name.ends_with(str(network_id)):
         conn.name = data.get_string_from_utf8() + "_" + conn.name
   name_data.emit(network_id, data)
   _refresh_peer_list()

func send_player_transform_data(data: PackedByteArray) -> void:
   for conn in ActiveConnections.get_children():
      conn.send_data(DataTypes.TransformData, data)
func _send_connection_data(conn: PingusPrime, peer: PingusPrime) -> void:
   var payload := PackedByteArray()
   payload.resize(PEER_ID_SIZE)
   payload.encode_u32(0, peer.TargetID)
   payload.append_array(peer.TargetAddr.to_utf8_buffer())
   conn.send_data(DataTypes.ConnectionData, payload)
func _send_nametag_data() -> void:
   for conn in ActiveConnections.get_children():
      conn.send_data(DataTypes.NameTagData, NameTag.to_utf8_buffer())
