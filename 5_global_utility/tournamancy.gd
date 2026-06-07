extends Node3D
   
@onready var PlayerCharacter: Player = $Player
@onready var OpponentCharacter: Dummy = $Opponent
@onready var MPM: MultiplayerManager = $MultiplayerManager



func _ready() -> void:
   InputManager.init_inputs()
   MPM.on_connection_established.connect(
      func(): 
         PlayerCharacter.enabled = true
         OpponentCharacter.visible = true
   )
   MPM.on_transform_data.connect(_on_transform_data)
   
func _physics_process(_delta: float) -> void:
   MPM.send_player_transform_data(PlayerCharacter.generate_transform_data())

   
func _on_transform_data(_id: int, data: PackedByteArray) -> void:
   OpponentCharacter._on_transform_data(data)
