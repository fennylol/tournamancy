extends HBoxContainer
class_name ConnectMenu

@onready var ID_LABEL       : Label         = $VBoxContainer/ID_label
@onready var WAN_LABEL      : Label         = $VBoxContainer/wan_info/WAN_label
@onready var COPY_WAN_BUTTON: Button        = $VBoxContainer/wan_info/copy_wan_button
@onready var LAN_LABEL      : Label         = $VBoxContainer/lan_info/LAN_label
@onready var COPY_LAN_BUTTON: Button        = $VBoxContainer/lan_info/copy_lan_button
@onready var PEER_LIST      : TextEdit      = $VBoxContainer/peer_list
@onready var TARGET_IP_BOX  : LineEdit      = $VBoxContainer/target_ip_box/target_IP_box
@onready var CONNECT_BUTTON : Button        = $VBoxContainer/target_ip_box/connect_button
@onready var NAME_TAG_BOX   : LineEdit      = $VBoxContainer/name_box/name_box
@onready var NAME_TAG_BUTTON: Button        = $VBoxContainer/name_box/change_name_button
@onready var READY_BUTTON   : Button        = $VBoxContainer/ready_button


signal connect_button_pressed(Address: String)
signal ready_button_pressed()
signal name_changed(new_name: String)

func _ready() -> void:
   for address in IP.get_local_addresses(): if address.begins_with("192.168"): _set_lan_label(address)
   CONNECT_BUTTON.pressed.connect(_on_connect_button_pressed)
   READY_BUTTON.pressed.connect(ready_button_pressed.emit)
   NAME_TAG_BUTTON.pressed.connect(_on_name_tag_button_pressed)
   

func _on_connect_button_pressed() -> void:
   var input_text = TARGET_IP_BOX.text.strip_edges()
   if _is_valid_ip_port(input_text):
      TARGET_IP_BOX.text = ""
      connect_button_pressed.emit(input_text)

func _on_name_tag_button_pressed() -> void:
   var new_name: String = NAME_TAG_BOX.text.strip_edges()
   if new_name != "":
      NAME_TAG_BOX.placeholder_text = new_name
      NAME_TAG_BOX.text = ""
      name_changed.emit(new_name)

func update_peers(connections: Array) -> void:
   var lines: PackedStringArray = []
   for conn in connections:
      if conn is not PingusPrime: continue
      var state_name: String
      match conn.PingusState:
         PingusPrime.PingusStates.NOT_STARTED: state_name = "not started"
         PingusPrime.PingusStates.SPRAYING   : state_name = "spraying port " + str(conn.TargetPort) + "..."
         PingusPrime.PingusStates.INFORMING  : state_name = "informing port " + str(conn.TargetPort) + "..."
         PingusPrime.PingusStates.CONNECTED  : state_name = "connected"
         _                                   : state_name = "unknown"
      var peer_name: String = conn.TargetAddr
      if conn.TargetID != 0: peer_name = conn.name.split("_")[0]
      lines.append(peer_name + ": " + state_name)
      if conn.TargetID != 0:  lines.append(str(conn.TargetID) + " (" + conn.TargetAddr + ")\n")
   PEER_LIST.text = "\n".join(lines)

func _set_id_label(input_text: String) -> void:
   ID_LABEL.text = input_text

func _set_wan_label(input_text: String) -> void:
   if _is_valid_ip_port(input_text):
      WAN_LABEL.text = input_text
      COPY_WAN_BUTTON.pressed.connect(DisplayServer.clipboard_set.bind(input_text))

func _set_lan_label(input_text: String) -> void:
   if _is_valid_ip_port(input_text):
      LAN_LABEL.text = input_text
      COPY_LAN_BUTTON.pressed.connect(DisplayServer.clipboard_set.bind(input_text))


func _is_valid_ip_port(input_text: String) -> bool:
   var regex = RegEx.new()
   regex.compile("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
   var result = regex.search(input_text)
   return true if result else false
