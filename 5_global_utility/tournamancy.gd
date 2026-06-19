extends Node3D
class_name Tournamancy

@onready var PlayerCharacter: Player             = $Player
@onready var MPM            : MultiplayerManager = $MultiplayerManager

const DummyScene: PackedScene = preload("res://1_player/dummy.tscn")
var _dummies: Dictionary = {}

enum DataTypes { TransformData = 0x20, ConnectionData = 0xCD, NameTagData = 0x15}
func _ready() -> void:
   var otp := OneTruePingus.new()
   add_child(otp)
   otp.recieved_data.connect(
      func(_network_id: int, data_type: int, data: PackedByteArray) -> void:
         match data_type:
            PingusPrime.DataTypes.CONTROL:
               print(data.get_string_from_utf8())
   )
   
   InputManager.init_inputs()
   MPM.connection_established.connect(_on_mpm_connection_established)
   MPM.ready_button_pressed.connect(_on_mpm_ready_button_pressed)
   MPM.transform_data.connect(_on_mpm_transform_data)
   MPM.name_data.connect(_on_mpm_name_data)
   PlayerCharacter.enabled_changed.connect(MPM.passthrough_player_enabled_changed)

func _physics_process(_delta: float) -> void:
   MPM.send_player_transform_data(PlayerCharacter.generate_transform_data())


func _on_mpm_connection_established(network_id: int) -> void:
   var dummy: Dummy = DummyScene.instantiate()
   dummy.set_name("dummy_" + str(network_id))
   add_child(dummy)
   _dummies[network_id] = dummy

func _on_mpm_transform_data(network_id: int, data: PackedByteArray) -> void:
   if _dummies.has(network_id):
      _dummies[network_id]._on_transform_data(data)

func _on_mpm_name_data(network_id: int, data: PackedByteArray) -> void:
   if _dummies.has(network_id):
      _dummies[network_id]._on_nametag_data(data)

func _on_mpm_ready_button_pressed() -> void:
   PlayerCharacter.enabled = true
