extends Node
class_name MultiplayerManager

@onready var _ConnectionMenu: ConnectMenu = $ConnectMenu

signal ready_button_pressed()
signal peer_disconnected(network_id: int)
signal connection_established(network_id: int)
signal transform_data(network_id: int, data: PackedByteArray)
signal damage_data(network_id: int, package: DamagePackage)
signal name_data(network_id: int, new_name: String)
signal effect_equipped_data(network_id: int, spell_id: int, is_active: bool)
#signal effect_erased_data(network_id: int, spell_id: int, is_active: bool)
signal effect_state_data(network_id: int, spell_id: int, is_active: bool, spell_state: int)
signal spawn_familiar_data(network_id: int, spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray)

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
func get_local_player_id() -> int: return _OTP.NetworkID
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
   EffectEquip = 0xEC, EffectErase = 0x0C, EffectState = 0xC5,
   # familiars #
   SpawnFamiliar = 0x5F
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
      DataTypes.EffectEquip      : _recieve_effect_equip_data  (data)
      DataTypes.EffectErase      : _recieve_effect_erase_data  (data)
      DataTypes.EffectState      : _recieve_effect_state_data  (data)
      DataTypes.SpawnFamiliar    : _recieve_spawn_familiar_data(data)
      OneTruePingus.DataTypes.CONTROL:
         if DEBUG_PRINT_CONTROL_MESSAGES: print(data.get_string_from_utf8())
         if _OTP.ExternAddr != "" and _ConnectionMenu.GLOBAL_BUTTON.disabled:
            _ConnectionMenu.set_ip_label(_OTP.get_addr_port(true))
         _refresh_peer_list()

func _recieve_transform_data     (data: PackedByteArray) -> void:
   var peer_id: int = data.decode_u32(0)
   var trans_data: PackedByteArray = data.slice(OneTruePingus.NETWORK_ID_SIZE)
   transform_data.emit(peer_id, trans_data)
func _recieve_damage_data        (data: PackedByteArray) -> void:
   ## Note that DataTypes.DamageData == 0xDA. I don't know if that needs to change.
   var peer_id : int = data.decode_u32(0)
   var ID_OFFSET_SIZE         : int = OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE
   var ID_AND_LOC_OFFSET_SIZE : int = OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE + DamagePackage.LOCATION_SOURCE_SIZE + DamagePackage.LOCATION_RECEIPT_SIZE
   var new_damage_instance := DamagePackage.new()
   new_damage_instance.id_from          = data.decode_u32(OneTruePingus.NETWORK_ID_SIZE)
   new_damage_instance.id_owner         = data.decode_u32(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE)
   new_damage_instance.id_to            = data.decode_u32(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE)
   new_damage_instance.location_source  = Vector3(data.decode_float(ID_OFFSET_SIZE),  data.decode_float(ID_OFFSET_SIZE + 4),  data.decode_float(ID_OFFSET_SIZE + 8))
   new_damage_instance.location_receipt = Vector3(data.decode_float(ID_OFFSET_SIZE + DamagePackage.LOCATION_SOURCE_SIZE), data.decode_float(ID_OFFSET_SIZE + DamagePackage.LOCATION_SOURCE_SIZE + 4), data.decode_float(ID_OFFSET_SIZE + DamagePackage.LOCATION_SOURCE_SIZE + 8))
   new_damage_instance.amount           = data.decode_float(ID_AND_LOC_OFFSET_SIZE)
   new_damage_instance.type             = data.decode_u8(ID_AND_LOC_OFFSET_SIZE + DamagePackage.AMOUNT_SIZE) as DamagePackage.DamageType
   new_damage_instance.force            = data.decode_float(ID_AND_LOC_OFFSET_SIZE + DamagePackage.AMOUNT_SIZE + DamagePackage.TYPE_SIZE)
   damage_data.emit(peer_id, new_damage_instance)
func _recieve_connection_data    (data: PackedByteArray) -> void:
   var peer_id = data.decode_u32(0)
   var peer_port = data.decode_u16(OneTruePingus.NETWORK_ID_SIZE)
   var peer_address = data.slice(OneTruePingus.NETWORK_ID_SIZE + OneTruePingus.PORT_SIZE).get_string_from_utf8()
   
   if (peer_id == _OTP.NetworkID) \
   or (peer_address == _OTP.ExternAddr and peer_port == _OTP.ExternPort) \
   or (peer_address == _OTP.LocalAddr and peer_port == _OTP.LocalPort):
     return 
   
   _OTP.add_peer(peer_address, peer_port, peer_id)
func _recieve_disconnection_data (data: PackedByteArray) -> void:
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
func _recieve_effect_equip_data  (data: PackedByteArray) -> void:
   var peer_id: int    = data.decode_u32(0)
   var spell_id: int   = data.decode_u16(OneTruePingus.NETWORK_ID_SIZE)
   var is_active: bool = data.decode_u8 (OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE)
   effect_equipped_data.emit(peer_id, spell_id, is_active)
func _recieve_effect_erase_data  (data: PackedByteArray) -> void:
   print("ERASE EFFECT DATA RECIEVED BUT NO HANDLER EXISTS")
func _recieve_effect_state_data  (data: PackedByteArray) -> void:
   var network_id : int = data.decode_u32(0) 
   var spell_id   : int = data.decode_u16(OneTruePingus.NETWORK_ID_SIZE)
   var is_active  : int = data.decode_u8 (OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE)
   var spell_state: int = data.decode_u8 (OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE + SpellData.IS_ACTIVE_SIZE)
   effect_state_data.emit(network_id, spell_id, is_active, spell_state)
func _recieve_spawn_familiar_data(data: PackedByteArray) -> void:
   var network_id  : int = data.decode_u32(0) 
   var spell_id    : int = data.decode_u16(OneTruePingus.NETWORK_ID_SIZE)
   var is_active   : int = data.decode_u8 (OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE)
   var familiar_idx: int = data.decode_u8 (OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE + SpellData.IS_ACTIVE_SIZE)
   var creation_data    := data.slice     (OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE + SpellData.IS_ACTIVE_SIZE + SpellData.FAMILIAR_IDX_SIZE)
   spawn_familiar_data.emit(network_id, spell_id, is_active, familiar_idx, creation_data)

func send_player_transform_data(data: PackedByteArray, owner_id: int = _OTP.NetworkID) -> void:
   var data_with_id: PackedByteArray = []
   data_with_id.resize(OneTruePingus.NETWORK_ID_SIZE)
   data_with_id.encode_u32(0, owner_id)
   data_with_id.append_array(data)
   _OTP.send_data(DataTypes.TransformData, data_with_id)
func send_damage_data(package : DamagePackage, owner_id: int = _OTP.NetworkID) -> void:
   # TODO: when client/server changed made fix who add the ID
   var data: PackedByteArray = []
   ## Note that DataTypes.DamageData == 0xDA. I don't know if that needs to change.
   data.resize(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE + DamagePackage.LOCATION_SOURCE_SIZE + DamagePackage.LOCATION_RECEIPT_SIZE + DamagePackage.AMOUNT_SIZE + DamagePackage.TYPE_SIZE + DamagePackage.FORCE_SIZE)
   data.encode_u32(0,                                                                                                                                                                                                                                                      owner_id)
   data.encode_u32(OneTruePingus.NETWORK_ID_SIZE,                                                                                                                                                                                                                          package.id_from)
   data.encode_u32(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE,                                                                                                                                                                                             package.id_owner)
   data.encode_u32(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE,                                                                                                                                                               package.id_to)
   data.encode_float(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE,                                                                                                                                  package.location_source.x)
   data.encode_float(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE + 4,                                                                                                                              package.location_source.y)
   data.encode_float(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE + 8,                                                                                                                              package.location_source.z)
   data.encode_float(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE + DamagePackage.LOCATION_SOURCE_SIZE,                                                                                             package.location_receipt.x)
   data.encode_float(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE + DamagePackage.LOCATION_SOURCE_SIZE + 4,                                                                                         package.location_receipt.y)
   data.encode_float(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE + DamagePackage.LOCATION_SOURCE_SIZE + 8,                                                                                         package.location_receipt.z)
   data.encode_float(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE + DamagePackage.LOCATION_SOURCE_SIZE + DamagePackage.LOCATION_RECEIPT_SIZE,                                                       package.amount)
   data.encode_u8(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE + DamagePackage.LOCATION_SOURCE_SIZE + DamagePackage.LOCATION_RECEIPT_SIZE + DamagePackage.AMOUNT_SIZE,                              package.type)
   data.encode_float(OneTruePingus.NETWORK_ID_SIZE + DamagePackage.ID_FROM_SIZE + DamagePackage.ID_OWNER_SIZE + DamagePackage.ID_TO_SIZE + DamagePackage.LOCATION_SOURCE_SIZE + DamagePackage.LOCATION_RECEIPT_SIZE + DamagePackage.AMOUNT_SIZE + DamagePackage.TYPE_SIZE, package.force)
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
func send_effect_equip_data(spell_id: int, is_active: bool, owner_id: int = _OTP.NetworkID) -> void:
   var data: PackedByteArray = []
   data.resize(OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE + SpellData.IS_ACTIVE_SIZE)
   data.encode_u32(0, owner_id)
   data.encode_u16(OneTruePingus.NETWORK_ID_SIZE, spell_id)
   data.encode_u8 (OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE, is_active)
   _OTP.send_data(DataTypes.EffectEquip, data)
func _send_effect_erase_data(spell_id: int, is_active: bool) -> void:
   print("ERASE EFFECT DATA SENT BUT NO DATA REALLY EXISTS")
   var data: PackedByteArray = []
   _OTP.send_data(DataTypes.EffectErase, data)
func send_effect_state_data(spell_id: int, is_active: bool, spell_state: int, owner_id: int = _OTP.NetworkID) -> void:
   var data: PackedByteArray = []
   data.resize(OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE + SpellData.IS_ACTIVE_SIZE + SpellData.SPELL_STATE_SIZE)
   data.encode_u32(0, owner_id)
   data.encode_u16(OneTruePingus.NETWORK_ID_SIZE, spell_id)
   data.encode_u8 (OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE, is_active)
   data.encode_u8 (OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE + SpellData.IS_ACTIVE_SIZE, spell_state)
   _OTP.send_data(DataTypes.EffectState, data)
func send_spawn_familiar_data(spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray, owner_id: int = _OTP.NetworkID) -> void:
   var data: PackedByteArray = []
   data.resize(OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE + SpellData.IS_ACTIVE_SIZE + SpellData.FAMILIAR_IDX_SIZE)
   data.encode_u32(0, owner_id)
   data.encode_u16(OneTruePingus.NETWORK_ID_SIZE, spell_id)
   data.encode_u8 (OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE, is_active)
   data.encode_u8 (OneTruePingus.NETWORK_ID_SIZE + SpellData.SPELL_ID_SIZE + SpellData.IS_ACTIVE_SIZE, familiar_idx)
   data.append_array(creation_data)
   _OTP.send_data(DataTypes.SpawnFamiliar, data)
   
   
