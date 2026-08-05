extends Node3D
class_name Tournamancy

@onready var PlayerCharacter: Player             = $Player
@onready var MPM            : MultiplayerManager = $MultiplayerManager

const DummyScene: PackedScene = preload("res://1_player/dummy/dummy.tscn")
var _dummies: Dictionary = {}

enum DataTypes { TransformData = 0x20, ConnectionData = 0xCD, NameTagData = 0x15}
func _ready() -> void:
   InputManager.init_inputs()
   MPM.connection_established.connect(_on_mpm_connection_established)
   MPM.peer_disconnected.connect(_on_mpm_peer_discconected)
   MPM.ready_button_pressed.connect(_on_mpm_ready_button_pressed)
   MPM.transform_data.connect(_on_mpm_transform_data)
   MPM.name_data.connect(_on_mpm_name_data)
   MPM.effect_equipped_data.connect(_on_mpm_effect_equipped_data)
   MPM.effect_state_data.connect(_on_mpm_effect_state_data)
   #PlayerCharacter.enabled_changed.connect(_on_player_enable_changed)
   #PlayerCharacter.spell_equipped.connect(_on_player_spell_equipped)
   PlayerCharacter.enabled_changed.connect(MPM.passthrough_player_enabled_changed)
   PlayerCharacter.spell_equipped.connect(MPM.send_effect_equip_data)
   PlayerCharacter.spell_change_state.connect(MPM.send_effect_state_data)
   sync_player_base_stats()
   
func _physics_process(_delta: float) -> void:
   MPM.send_player_transform_data(PlayerCharacter.generate_transform_data())

# ===================== #
#    SIGNAL HANDLING    #
# ===================== #

func _on_mpm_connection_established(network_id: int) -> void:
   var dummy: Dummy = DummyScene.instantiate()
   dummy.set_name("dummy_" + str(network_id))
   add_child(dummy)
   _dummies[network_id] = dummy
func _on_mpm_peer_discconected     (network_id: int) -> void:
   if _dummies.has(network_id):
     _dummies[network_id].queue_free()
func _on_mpm_transform_data        (network_id: int, data: PackedByteArray) -> void:
   if _dummies.has(network_id):
     _dummies[network_id].on_transform_data(data)
func _on_mpm_name_data             (network_id: int, new_name: String) -> void:
   if _dummies.has(network_id):
     _dummies[network_id].on_nametag_data(new_name)
func _on_mpm_ready_button_pressed  () -> void:
   PlayerCharacter.Enabled = true
func _on_mpm_effect_equipped_data  (network_id: int, spell_id: int, is_active: bool) -> void:
   if _dummies.has(network_id):
     _dummies[network_id].on_effect_equip_data(spell_id, is_active)
func _on_mpm_effect_state_data     (network_id: int, spell_id: int, is_active: bool, spell_state: int) -> void:
   if _dummies.has(network_id):
     _dummies[network_id].on_effect_state_data(spell_id, is_active, spell_state)


#func _on_player_enable_changed(enabled: bool) -> void:
   #MPM.passthrough_player_enabled_changed(enabled)
#func _on_player_spell_equipped(spell_id: int, is_active: bool) -> void:
   #MPM.send_effect_equip_data(spell_id, is_active)

# ================ #
#    GAME SETUP    #
# ================ #

var match_settings : MatchSettings = MatchSettings.new()

func sync_player_base_stats(): PlayerCharacter.sync_statistics(match_settings.PLAYER_BASE_STATS)
