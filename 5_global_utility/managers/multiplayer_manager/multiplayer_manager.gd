extends Node
class_name MultiplayerManager

@onready var _ConnectionMenu: ConnectMenu = $ConnectMenu

signal ready_button_pressed()
signal peer_disconnected(network_id: int)
signal connection_established(network_id: int)
signal transform_data(network_id: int, data: PackedByteArray)
signal name_data(network_id: int, new_name: String)
signal subspell_data()

var NameTag  : String        = ""
var _OTP     : OneTruePingus = OneTruePingus.new()
var _NameTags: Dictionary    = {}
var _Hosting : bool          = false

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
   _ConnectionMenu.hosting_type_changed.connect(_on_hosting_type_changed)
   _ConnectionMenu.quit_button_pressed.connect(_on_disconnect_button_pressed)
   
   _OTP.set_name("MultiplayerCoupler")
   add_child(_OTP)
func _notification(what: int) -> void:
   if what == NOTIFICATION_WM_CLOSE_REQUEST:
      _send_disconnection_data()
# =============== #
# signal handling #
# =============== #
func _on_connect_button_pressed(target_address: String) -> void:
   var parts := target_address.rsplit(":", true, 1)
   if parts.size() < 2: return
   _OTP.add_peer(parts[0], parts[1].to_int())
   _refresh_peer_list()
func _on_disconnect_button_pressed() -> void:
   _send_disconnection_data()
   for peer:OneTruePingus.PingusPeer in _OTP.Peers:
      peer_disconnected.emit(peer.NetworkID)
      _OTP.Peers.erase(peer)
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
func _on_network_type_changed(global: bool) -> void:
   _ConnectionMenu.set_ip_label(_OTP.get_addr_port(global))
   if not global: 
      _OTP._discover_address()
      _OTP.ExternAddr = "PEE.POO.CUM.POO"
func _on_hosting_type_changed(client: bool) -> void:
   _Hosting = not client
func _refresh_peer_list() -> void:
   for peer:OneTruePingus.PingusPeer in _OTP.Peers:
      if peer.KeepAliveNum*OneTruePingus._KEEP_ALIVE_TIME >= OneTruePingus._TIMEOUT_TIME:
         peer_disconnected.emit(peer.NetworkID)
         _OTP.Peers.erase(peer)
   _ConnectionMenu.update_peers(_OTP.Peers, _NameTags)
func passthrough_player_enabled_changed(new_val: bool) -> void:
   _ConnectionMenu.visible = not new_val

# ============ #
# data routing #
# ============ #
#IMPLEMMENMT CHILD NODE DATA
enum DataTypes { 
   # gameplay data #
   TransformData = 0x20, DamageData = 0xDA,
   # connection state #
   ConnectionData = 0xCD, DisconnectionData = 0xDD, NameTagData = 0x15, 
   # inventory #
   SubSpellEquip = 0xEC, SubSpellErase = 0x0C, SubSpellState = 0xC5
}
#var MinSizes: Dictionary = {
   #DataTypes.TransformData    : Player.TRANSFORM_DATA_SIZE,
   #DataTypes.ConnectionData   : OneTruePingus.NETWORK_ID_SIZE + OneTruePingus.PORT_SIZE,
   #DataTypes.DisconnectionData: OneTruePingus.NETWORK_ID_SIZE,
   #DataTypes.NameTagData      : 0
#}

func _recieve_data(_sender_id: int, data_type: int, data: PackedByteArray) -> void:
   #if data_type != OneTruePingus.DataTypes.CONTROL and data.size() < MinSizes[data_type]: 
      #if DEBUG_PRINT_CONTROL_MESSAGES:
         #print("ERROR: undersized data of type %s from %d" % [DataTypes.find_key(data_type), sender_id])
      #return
   match data_type:
      DataTypes.TransformData    : _recieve_transform_data     (data)
      DataTypes.DamageData       : _recieve_damage_data        (data)
      DataTypes.ConnectionData   : _recieve_connection_data    (data)
      DataTypes.DisconnectionData: _recieve_disconnection_data (data)
      DataTypes.NameTagData      : _recieve_name_data          (data)
      DataTypes.SubSpellEquip    : _recieve_subspell_equip_data(data)
      DataTypes.SubSpellErase    : _recieve_subspell_erase_data(data)
      DataTypes.SubSpellState    : _recieve_subspell_state_data(data)
      OneTruePingus.DataTypes.CONTROL:
         if DEBUG_PRINT_CONTROL_MESSAGES: print(data.get_string_from_utf8())
         if _OTP.ExternAddr != "" and _ConnectionMenu.GLOBAL_BUTTON.disabled:
            _ConnectionMenu.set_ip_label(_OTP.get_addr_port(true))
         _refresh_peer_list()

func _recieve_transform_data     (data: PackedByteArray) -> void:
   var peer_id: int = data.decode_u32(0)
   var trans_data: PackedByteArray = data.slice(OneTruePingus.NETWORK_ID_SIZE)
   transform_data.emit(peer_id, trans_data)
func _recieve_damage_data        (data: PackedByteArray)                 -> void:
   print("DAMAGE DATA RECIEVED BUT NO HANDLER EXISTS")
func _recieve_connection_data    (data: PackedByteArray)                 -> void:
   var peer_id = data.decode_u32(0)
   var peer_port = data.decode_u16(OneTruePingus.NETWORK_ID_SIZE)
   var peer_address = data.slice(OneTruePingus.NETWORK_ID_SIZE + OneTruePingus.PORT_SIZE).get_string_from_utf8()
   
   if (peer_id == _OTP.NetworkID) \
   or (peer_address == _OTP.ExternAddr and peer_port == _OTP.ExternPort) \
   or (peer_address == _OTP.LocalAddr and peer_port == _OTP.LocalPort):
      return 
   
   _OTP.add_peer(peer_address, peer_port, peer_id)
func _recieve_disconnection_data (data: PackedByteArray)                 -> void:
   var peer_id: int = data.decode_u32(0)
   for peer:OneTruePingus.PingusPeer in _OTP.Peers:
      if peer.NetworkID == peer_id: 
         _OTP.Peers.erase(peer)
         peer_disconnected.emit(peer.NetworkID)
   _refresh_peer_list()
func _recieve_name_data          (data: PackedByteArray) -> void:
   var peer_id: int = data.decode_u32(0)
   var new_name: String = data.slice(OneTruePingus.NETWORK_ID_SIZE).get_string_from_utf8()
   _NameTags[peer_id] = new_name
   name_data.emit(peer_id, new_name)
   _refresh_peer_list()
func _recieve_subspell_equip_data(data: PackedByteArray)                 -> void:
   print("EQUIP SUBSPELL DATA RECIEVED BUT NO HANDLER EXISTS")
func _recieve_subspell_erase_data(data: PackedByteArray)                 -> void:
   print("ERASE SUBSPELL DATA RECIEVED BUT NO HANDLER EXISTS")
func _recieve_subspell_state_data(data: PackedByteArray)                 -> void:
   var network_id      : int = data.decode_u32(0) 
   var active_v_passive: int = data.decode_u8 (OneTruePingus.NETWORK_ID_SIZE)
   var spell_id        : int = data.decode_u16(OneTruePingus.NETWORK_ID_SIZE + SpellData.ACTIVE_V_PASSIVE_SIZE)
   var spell_state     : int = data.decode_u8 (OneTruePingus.NETWORK_ID_SIZE + SpellData.ACTIVE_V_PASSIVE_SIZE + SpellData.SPELL_ID_SIZE)


func send_player_transform_data(data: PackedByteArray, owner_id: int = _OTP.NetworkID) -> void:
   var data_with_id: PackedByteArray = []
   data_with_id.resize(OneTruePingus.NETWORK_ID_SIZE)
   data_with_id.encode_u32(0, owner_id)
   data_with_id.append_array(data)
   _OTP.send_data(DataTypes.TransformData, data_with_id)
func send_damage_data() -> void:
   print("DAMAGE DATA SNET BUT NO DATA REALLY EXISTS")
   var data: PackedByteArray = []
   var make_the_function_signature_yellow_please
   _OTP.send_data(DataTypes.DamageData, data)
func _send_connection_data(network_id: int, peer_address: String, peer_port: int) -> void:
   var data: PackedByteArray = []
   data.resize(OneTruePingus.NETWORK_ID_SIZE + OneTruePingus.PORT_SIZE)
   data.encode_u32(0, network_id)
   data.encode_u16(OneTruePingus.NETWORK_ID_SIZE, peer_port)
   data.append_array(peer_address.to_utf8_buffer())
   _OTP.send_data(DataTypes.ConnectionData, data)
func _send_disconnection_data(disconnecting_id: int = _OTP.NetworkID) -> void:
   var data: PackedByteArray = []
   data.resize(OneTruePingus.NETWORK_ID_SIZE)
   data.encode_u32(0, disconnecting_id)
   _OTP.send_data(DataTypes.DisconnectionData, data)
func _send_nametag_data(owner_id: int = _OTP.NetworkID) -> void:
   var data: PackedByteArray = []
   data.resize(OneTruePingus.NETWORK_ID_SIZE)
   data.encode_u32(0, owner_id)
   data.append_array(NameTag.to_utf8_buffer())
   _OTP.send_data(DataTypes.NameTagData, data)
func _send_subspell_equip_data(spell_id: int, is_active: bool) -> void:
   print("EQUIP SUBSPELL DATA SNET BUT NO DATA REALLY EXISTS")
   var data: PackedByteArray = []
   _OTP.send_data(DataTypes.DamageData, data)
func _send_subspell_erase_data(spell_id: int, is_active: bool) -> void:
   print("ERASE SUBSPELL DATA SNET BUT NO DATA REALLY EXISTS")
   var data: PackedByteArray = []
   _OTP.send_data(DataTypes.DamageData, data)
func _send_subspell_state_data(spell_id: int, is_active: bool, spell_state: int) -> void:
   print("SUBSPELL STATE DATA SNET BUT NO DATA REALLY EXISTS")
   var data: PackedByteArray = []
   _OTP.send_data(DataTypes.SubSpellState, data)
