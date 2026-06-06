extends HBoxContainer
class_name ConnectMenu

@onready var WAN_LABEL      : Label    = $VBoxContainer/wan_info/WAN_label
@onready var COPY_WAN_BUTTON: Button   = $VBoxContainer/wan_info/copy_wan_button
@onready var LAN_LABEL      : Label    = $VBoxContainer/lan_info/LAN_label
@onready var COPY_LAN_BUTTON: Button   = $VBoxContainer/lan_info/copy_lan_button
@onready var TARGET_IP_BOX  : LineEdit = $VBoxContainer/target_ip_box/target_IP_box
@onready var CONNECT_BUTTON : Button   = $VBoxContainer/target_ip_box/connect_button
@onready var STATUS_LABEL   : Label    = $VBoxContainer/status_label

signal connect_button_pressed(Address: String)

func _ready() -> void:
   _set_lan_label(IP.get_local_addresses()[3])
   CONNECT_BUTTON.pressed.connect(_on_connect_button_pressed)

func _on_connect_button_pressed() -> void:
   var input_text = TARGET_IP_BOX.text.strip_edges()
   if is_valid_ip_port(input_text):
      STATUS_LABEL.text = "CONNECTING TO: " + input_text
      connect_button_pressed.emit(input_text)
   else:
      STATUS_LABEL.text  = input_text + " is not a valid IP address."

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
