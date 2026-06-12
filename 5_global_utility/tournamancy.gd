extends Node3D
class_name Tournamancy

@onready var PlayerCharacter: Player             = $Player
@onready var MPM            : MultiplayerManager = $MultiplayerManager

const DummyScene: PackedScene = preload("res://1_player/dummy.tscn")
var _dummies: Dictionary = {}

func _ready() -> void:
   InputManager.init_inputs()
   MPM.connection_established.connect(_on_mpm_connection_established)
   MPM.transform_data.connect(_on_mpm_transform_data)
   MPM.ready_button_pressed.connect(_on_mpm_ready_button_pressed)
   PlayerCharacter.enabled_changed.connect(MPM.passthrough_player_enabled_changed)

func _physics_process(_delta: float) -> void:
   MPM.send_player_transform_data(PlayerCharacter.generate_transform_data())

func _on_mpm_transform_data(id: int, data: PackedByteArray) -> void:
   if _dummies.has(id):
      _dummies[id]._on_transform_data(data)

func _on_mpm_connection_established(id: int) -> void:
   var dummy: Dummy = DummyScene.instantiate()
   dummy.set_name("dummy_" + str(id))
   add_child(dummy)
   _dummies[id] = dummy

func _on_mpm_ready_button_pressed() -> void:
   PlayerCharacter.enabled = true
