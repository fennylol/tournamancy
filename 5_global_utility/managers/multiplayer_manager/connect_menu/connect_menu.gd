extends HBoxContainer
class_name ConnectMenu

@onready var WAN_LABEL      : Label         = $VBoxContainer/wan_info/WAN_label
@onready var COPY_WAN_BUTTON: Button        = $VBoxContainer/wan_info/copy_wan_button
@onready var LAN_LABEL      : Label         = $VBoxContainer/lan_info/LAN_label
@onready var COPY_LAN_BUTTON: Button        = $VBoxContainer/lan_info/copy_lan_button
@onready var PEER_LIST      : TextEdit      = $VBoxContainer/peer_list
@onready var TARGET_IP_BOX  : LineEdit      = $VBoxContainer/target_ip_box/target_IP_box
@onready var CONNECT_BUTTON : Button        = $VBoxContainer/target_ip_box/connect_button
@onready var READY_BUTTON   : Button        = $VBoxContainer/ready_button


signal connect_button_pressed(Address: String)
signal ready_button_pressed()

func _ready() -> void:
   for address in IP.get_local_addresses():
      if address.begins_with("192.168"):
         _set_lan_label(address)
   CONNECT_BUTTON.pressed.connect(_on_connect_button_pressed)
   READY_BUTTON.pressed.connect(ready_button_pressed.emit)

func _on_connect_button_pressed() -> void:
   var input_text = TARGET_IP_BOX.text.strip_edges()
   if is_valid_ip_port(input_text):
      TARGET_IP_BOX.text = ""
      connect_button_pressed.emit(input_text)

func update_peers(connections: Array) -> void:
   var lines: PackedStringArray = []
   for conn in connections:
      var state_name: String
      match conn.PingusState:
         PingusPrime.PingusStates.NOT_STARTED: state_name = "not started"
         PingusPrime.PingusStates.SPRAYING   : state_name = "spraying..."
         PingusPrime.PingusStates.INFORMING  : state_name = "informing..."
         PingusPrime.PingusStates.CONNECTED  : state_name = "connected"
         _                                   : state_name = "unknown"
      lines.append(conn.TargetAddr + ": " + state_name)
   PEER_LIST.text = "\n".join(lines)

func _set_wan_label(input_text: String) -> void:
   if is_valid_ip_port(input_text):
      WAN_LABEL.text = input_text
      COPY_WAN_BUTTON.pressed.connect(DisplayServer.clipboard_set.bind(input_text))

func _set_lan_label(input_text: String) -> void:
   if is_valid_ip_port(input_text):
      LAN_LABEL.text = input_text
      COPY_LAN_BUTTON.pressed.connect(DisplayServer.clipboard_set.bind(input_text))

func is_valid_ip_port(input_text: String) -> bool:
   var regex = RegEx.new()
   regex.compile("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
   var result = regex.search(input_text)
   return true if result else false
