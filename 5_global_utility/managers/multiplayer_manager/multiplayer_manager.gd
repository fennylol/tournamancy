extends Node
class_name MultiplayerManager

@onready var _ConnectionMenu: ConnectMenu = $ConnectMenu

signal ready_button_pressed()
signal connection_established(network_id: int)
signal transform_data(network_id: int, data: PackedByteArray)
signal name_data(network_id: int, data: PackedByteArray)

var NameTag      : String        = ""
var _OTP         : OneTruePingus = OneTruePingus.new()
var _NameTags    : Dictionary    = {}
#var _InternalAddr: String        = ""

var DEBUG_PRINT_CONTROL_MESSAGES: bool = true

func _ready() -> void:
   NameTag = str(_OTP.NetworkID)
   _ConnectionMenu.set_id_label(NameTag)

   _OTP.recieved_data.connect(_recieve_data)
   _OTP.connection_established.connect(_on_connection_established)
   
   _ConnectionMenu.name_changed.connect(_on_name_changed)
   _ConnectionMenu.connect_button_pressed.connect(_on_connect_button_pressed)
   _ConnectionMenu.ready_button_pressed.connect(_on_ready_button_pressed)
   _ConnectionMenu.network_type_changed.connect(_on_network_type_changed)
   _ConnectionMenu.hosting_type_changed.connect(func(_client: bool): pass)
   
   _OTP.set_name("MultiplayerCoupler")
   add_child(_OTP)

# =============== #
# signal handling #
# =============== #
func _on_connect_button_pressed(target_address: String) -> void:
   var parts := target_address.rsplit(":", true, 1)
   if parts.size() < 2: return
   _OTP.add_peer(parts[0], parts[1].to_int())
   _refresh_peer_list()
func _on_connection_established(network_id: int, peer_address: String, peer_port: int) -> void:
   connection_established.emit(network_id)
   _send_connection_data(network_id, peer_address, peer_port)
   for peer in _OTP.Peers:
      if peer.NetworkID == network_id: continue
      if peer.State != OneTruePingus.PingusStates.CONNECTED: continue
      _send_connection_data(peer.NetworkID, peer.Addr, peer.Port)
   _refresh_peer_list()
   _send_nametag_data()
func _on_ready_button_pressed() -> void:
   ready_button_pressed.emit()
   _ConnectionMenu.visible = false
func _on_name_changed(new_name: String) -> void:
   NameTag = new_name
   _send_nametag_data()
func _on_network_type_changed(global: bool):
   _ConnectionMenu.set_ip_label(_OTP.get_addr_port(global))
func _refresh_peer_list() -> void:
   _ConnectionMenu.update_peers(_OTP.Peers, _NameTags)
func passthrough_player_enabled_changed(new_val: bool) -> void:
   _ConnectionMenu.visible = not new_val

# ============ #
# data routing #
# ============ #
enum DataTypes { TransformData = 0x20, ConnectionData = 0xCD, NameTagData = 0x15 }

func _recieve_data(sender_id: int, data_type: int, data: PackedByteArray) -> void:
   match data_type:
      DataTypes.TransformData : transform_data.emit(sender_id, data)
      DataTypes.NameTagData   : _recieve_name_data(sender_id, data)
      DataTypes.ConnectionData: _recieve_connection_data(data)
      OneTruePingus.DataTypes.CONTROL:
         if DEBUG_PRINT_CONTROL_MESSAGES: print(data.get_string_from_utf8())
         if _OTP.ExternAddr != "" and _ConnectionMenu.GLOBAL_BUTTON.disabled:
            _ConnectionMenu.set_ip_label(_OTP.get_addr_port(true))
         _refresh_peer_list()

func _recieve_name_data(sender_id: int, data: PackedByteArray) -> void:
   _NameTags[sender_id] = data.get_string_from_utf8()
   name_data.emit(sender_id, data)
   _refresh_peer_list()

func _recieve_connection_data(data: PackedByteArray) -> void:
   var peer_id = data.decode_u32(0)
   var peer_port = data.decode_u16(OneTruePingus.ID_SIZE)
   var peer_address = data.slice(OneTruePingus.ID_SIZE + OneTruePingus.PORT_SIZE).get_string_from_utf8()
   
   if (peer_id == _OTP.NetworkID) \
   or (peer_address == _OTP.ExternAddr and peer_port == _OTP.ExternPort) \
   or (peer_address == _OTP.LocalAddr and peer_port == _OTP.LocalPort):
      return 
   
   _OTP.add_peer(peer_address, peer_port, peer_id)

func send_player_transform_data(data: PackedByteArray) -> void:
   _OTP.send_data(DataTypes.TransformData, data)

func _send_connection_data(network_id: int, peer_address: String, peer_port: int) -> void:
   var data: PackedByteArray = []
   data.resize(OneTruePingus.ID_SIZE + OneTruePingus.PORT_SIZE)
   data.encode_u32(0, network_id)
   data.encode_u16(OneTruePingus.ID_SIZE, peer_port)
   data.append_array(peer_address.to_utf8_buffer())
   _OTP.send_data(DataTypes.ConnectionData, data)

func _send_nametag_data() -> void:
   _OTP.send_data(DataTypes.NameTagData, NameTag.to_utf8_buffer())
