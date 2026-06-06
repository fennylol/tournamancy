extends Node3D
   
@onready var PlayerCharacter: Player = $Player
@onready var OpponentCharacter: Player = $Opponent
@onready var ConnectionMenu : ConnectMenu = $ConnectMenu
var MultiPlayerCoupler := PingusPrime.new()

func _ready() -> void:
   InputManager.init_inputs()
   
   var handle_IP_singleton: Callable 
   handle_IP_singleton = func(msg: String, type: PingusPrime.SignalTypes) -> void:
      if msg != "IP RECIEVED" or type != PingusPrime.SignalTypes.CONTROL: printerr("INVALID MESSAGE ARRIVED EARLY")
      for function in MultiPlayerCoupler.message_recieved.get_connections():
         MultiPlayerCoupler.message_recieved.disconnect(function["callable"])
      MultiPlayerCoupler.message_recieved.connect(_recieve_message)
      ConnectionMenu._set_wan_label(MultiPlayerCoupler.ExternAddr)
   MultiPlayerCoupler.message_recieved.connect(handle_IP_singleton)
   
   ConnectionMenu.connect_button_pressed.connect(func(address: String): MultiPlayerCoupler.TargetAddr = address)
   
   MultiPlayerCoupler.set_name("mpc")
   add_child(MultiPlayerCoupler)

func _process(delta: float) -> void:
   if MultiPlayerCoupler.PingusState == PingusPrime.PingusStates.CONNECTED:
      _send_data()

func _recieve_message(Msg: String, Type: PingusPrime.SignalTypes) -> void:
   print(Msg)
   if Type == PingusPrime.SignalTypes.CONTROL:
      ConnectionMenu.STATUS_LABEL.text = Msg
   if MultiPlayerCoupler.PingusState == PingusPrime.PingusStates.CONNECTED:
      ConnectionMenu.visible = false
      PlayerCharacter.enabled = true
      

func _recieve_data(data: PackedByteArray) -> void:
   OpponentCharacter.position.x = data.decode_float(0)
   OpponentCharacter.position.y = data.decode_float(4)
   OpponentCharacter.position.z = data.decode_float(8)
   OpponentCharacter.rotation.x = data.decode_float(12)
   OpponentCharacter.rotation.y = data.decode_float(16)
   OpponentCharacter.rotation.z = data.decode_float(20)

func _send_data() -> void:
   var raw_data: Array = [PlayerCharacter.position.x,
                          PlayerCharacter.position.y, 
                          PlayerCharacter.position.z,
                          PlayerCharacter.rotation.x,
                          PlayerCharacter.rotation.y, 
                          PlayerCharacter.rotation.z]
   var packed_data := PackedByteArray(raw_data)
   MultiPlayerCoupler.send_data(packed_data)
