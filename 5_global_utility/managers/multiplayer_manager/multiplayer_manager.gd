extends Node
class_name MultiplayerManager

@onready var ConnectionMenu : ConnectMenu = $ConnectMenu
var MultiPlayerCoupler := PingusPrime.new()

func _ready() -> void:
   IP.get_local_addresses()
   
   var handle_IP_singleton: Callable 
   handle_IP_singleton = func(msg: String, type: PingusPrime.SignalTypes) -> void:
      if msg != "IP RECIEVED" or type != PingusPrime.SignalTypes.CONTROL: printerr("INVALID MESSAGE ARRIVED EARLY")
      for function in MultiPlayerCoupler.message_recieved.get_connections():
         MultiPlayerCoupler.message_recieved.disconnect(function["callable"])
      MultiPlayerCoupler.message_recieved.connect(_recieve_message)
      ConnectionMenu._set_ip_label(MultiPlayerCoupler.ExternAddr)
   MultiPlayerCoupler.message_recieved.connect(handle_IP_singleton)
   
   MultiPlayerCoupler.set_name("mpc")
   add_child(MultiPlayerCoupler)

func _recieve_message(Msg: String, Type: PingusPrime.SignalTypes) -> void:
   print(Msg)
   if Type == PingusPrime.SignalTypes.CONTROL:
      ConnectionMenu.STATUS_LABEL.text = Msg
   if MultiPlayerCoupler.PingusState == PingusPrime.PingusStates.CONNECTED:
      ConnectionMenu.visible = false

func _recieve_data(data: PackedByteArray) -> void:
   print("recieved: ", data)
   pass

func _send_data(data: PackedByteArray) -> void:
   print("sending ", data)
