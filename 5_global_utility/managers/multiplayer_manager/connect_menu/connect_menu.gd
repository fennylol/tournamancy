extends HBoxContainer
class_name ConnectMenu

@onready var ID_LABEL       : Label    = $VBoxContainer/HBoxContainer/YourInfo/id_info/ID_label
@onready var COPY_ID_BUTTON : Button   = $VBoxContainer/HBoxContainer/YourInfo/id_info/copy_id_button
@onready var WAN_LABEL      : Label    = $VBoxContainer/HBoxContainer/YourInfo/wan_info/WAN_label
@onready var COPY_WAN_BUTTON: Button   = $VBoxContainer/HBoxContainer/YourInfo/wan_info/copy_wan_button
@onready var LAN_LABEL      : Label    = $VBoxContainer/HBoxContainer/YourInfo/lan_info/LAN_label
@onready var COPY_LAN_BUTTON: Button   = $VBoxContainer/HBoxContainer/YourInfo/lan_info/copy_lan_button
@onready var NAME_TAG_BOX   : LineEdit = $VBoxContainer/HBoxContainer/YourInfo/name_box/name_box
@onready var NAME_TAG_BUTTON: Button   = $VBoxContainer/HBoxContainer/YourInfo/name_box/change_name_button
@onready var MIN_PORT_BOX   : LineEdit = $VBoxContainer/HBoxContainer/YourInfo/scan_settings_and_labels/scan_settings_box/min_port_box
@onready var MAX_PORT_BOX   : LineEdit = $VBoxContainer/HBoxContainer/YourInfo/scan_settings_and_labels/scan_settings_box/max_port_box
@onready var RATE_BOX       : LineEdit = $VBoxContainer/HBoxContainer/YourInfo/scan_settings_and_labels/scan_settings_box/rate_box
@onready var SETTINGS_BUTTON: Button   = $VBoxContainer/HBoxContainer/YourInfo/scan_settings_and_labels/save_button_box/save_settings_button

@onready var PEER_LIST      : TextEdit = $VBoxContainer/HBoxContainer/TheirInfo/peer_list
@onready var TARGET_IP_BOX  : LineEdit = $VBoxContainer/HBoxContainer/TheirInfo/target_ip_box/target_IP_box
@onready var CONNECT_BUTTON : Button   = $VBoxContainer/HBoxContainer/TheirInfo/target_ip_box/connect_button
@onready var READY_BUTTON   : Button   = $VBoxContainer/ready_button

signal connect_button_pressed(Address: String)
signal settings_button_pressed(MinPort: int, MaxPort: int, PPS: int)
signal ready_button_pressed()
signal name_changed(new_name: String)

func _ready() -> void:
   for address in IP.get_local_addresses(): if address.begins_with("192.168"): _set_lan_label(address)
   CONNECT_BUTTON.pressed.connect(_on_connect_button_pressed)
   NAME_TAG_BUTTON.pressed.connect(_on_name_tag_button_pressed)
   SETTINGS_BUTTON.pressed.connect(_on_settings_button_pressed)
   READY_BUTTON.pressed.connect(ready_button_pressed.emit)

# =============== #
# button handlers #
# =============== #
func _on_connect_button_pressed() -> void:
   var input_text = TARGET_IP_BOX.text.strip_edges()
   if _is_valid_ip_addr(input_text) or _is_valid_ip_port(input_text):
      TARGET_IP_BOX.text = ""
      connect_button_pressed.emit(input_text)
func _on_name_tag_button_pressed() -> void:
   var new_name: String = NAME_TAG_BOX.text.strip_edges()
   if new_name != "":
      NAME_TAG_BOX.placeholder_text = new_name
      NAME_TAG_BOX.text = ""
      name_changed.emit(new_name)
func _on_settings_button_pressed() -> void:
   var min_port: int = clampi(MIN_PORT_BOX.text.to_int(), 1, 65534) if MIN_PORT_BOX.text else 49152
   var max_port: int = clampi(MAX_PORT_BOX.text.to_int(), min_port, 65535) if MAX_PORT_BOX.text else 65535
   var rate: int = RATE_BOX.text.to_int() if RATE_BOX.text else 3000
   settings_button_pressed.emit(min_port, max_port, rate)
# ============= #
# label setters #
# ============= #
func _set_id_label(input_text: String) -> void:
   ID_LABEL.text = input_text
   COPY_ID_BUTTON.pressed.connect(DisplayServer.clipboard_set.bind(input_text))
func _set_wan_label(input_text: String) -> void:
   if _is_valid_ip_addr(input_text):
      WAN_LABEL.text = input_text
      COPY_WAN_BUTTON.pressed.connect(DisplayServer.clipboard_set.bind(input_text))
func _set_lan_label(input_text: String) -> void:
   if _is_valid_ip_addr(input_text):
      LAN_LABEL.text = input_text
      COPY_LAN_BUTTON.pressed.connect(DisplayServer.clipboard_set.bind(input_text))
# ============= #
# other utility #
# ============= #
func update_peers(connections: Array) -> void:
   var lines: PackedStringArray = []
   for conn in connections:
      if conn is not PingusPrime: continue
      var state_str: String = conn.TargetAddr
      match conn.PingusState:
         PingusPrime.PingusStates.NOT_STARTED: state_str += " not started\n"
         PingusPrime.PingusStates.SPRAYING   : state_str += " spraying port " + str(conn.TargetPort) + "...\n"
         PingusPrime.PingusStates.INFORMING  : state_str += " informing port " + str(conn.TargetPort) + "...\n"
         PingusPrime.PingusStates.CONNECTED  : state_str += ":" + str(conn.TargetPort) + " connected\n"
         _                                   : state_str += " unknown\n"

      if conn.TargetID != 0: state_str = conn.name.split("_")[0] + " (" + str(conn.TargetID) + ")\n" + state_str
      lines.append(state_str)
   PEER_LIST.text = "\n".join(lines)

func _is_valid_ip_addr(input_text: String) -> bool:
   var regex = RegEx.new()
   regex.compile("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
   var result = regex.search(input_text)
   return true if result else false

func _is_valid_ip_port(input_text: String) -> bool:
   var parts := input_text.rsplit(":", true, 1)
   if parts.size() != 2: return false
   if not _is_valid_ip_addr(parts[0]): return false
   if not parts[1].is_valid_int(): return false
   var port := int(parts[1])
   return port >= 1 and port <= 65535
