extends Node3D
class_name Tournamancy

@onready var PLAYER_CHARACTER: Player             = $Player
@onready var MPM             : MultiplayerManager = $MultiplayerManager
@onready var FAMILIARS       : Node3D             = $Familiars

var _dummies: Dictionary = {}
const DummyScene: PackedScene = preload("res://1_player/dummy/dummy.tscn")

enum DataTypes { TransformData = 0x20, ConnectionData = 0xCD, NameTagData = 0x15}
func _ready() -> void:
   InputManager.init_inputs()
   MPM.connection_established.connect(_on_mpm_connection_established)
   MPM.peer_disconnected.connect(_on_mpm_peer_discconected)
   MPM.ready_button_pressed.connect(_on_mpm_ready_button_pressed)
   MPM.transform_data.connect(_on_mpm_transform_data)
   MPM.name_data.connect(_on_mpm_name_data)
   MPM.damage_data.connect(_on_mpm_damage_data)
   MPM.effect_equipped_data.connect(_on_mpm_effect_equipped_data)
   MPM.effect_state_data.connect(_on_mpm_effect_state_data)
   MPM.spawn_familiar_data.connect(_on_mpm_spawn_familiar_data)
   PLAYER_CHARACTER.open_connection_menu_please.connect(MPM.open_connection_menu)
   PLAYER_CHARACTER.spell_equipped.connect(MPM.send_effect_equip_data)
   PLAYER_CHARACTER.player_spell_change_state.connect(MPM.send_effect_state_data)
   PLAYER_CHARACTER.damage_dealt.connect(_on_player_damage_dealt)
   PLAYER_CHARACTER.familiar_spawned.connect(_on_player_familiar_spawned)
   PLAYER_CHARACTER.MY_NETWORK_ID = MPM.get_local_player_id()
   PLAYER_CHARACTER.position = Vector3(randf(), 0, randf())
   sync_player_base_stats()
   sync_prism_settings()
   
func _physics_process(_delta: float) -> void:
   MPM.send_player_transform_data(PLAYER_CHARACTER.generate_transform_data())

func _spawn_familiar(owner_id: int, spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray) -> void:
   var spell_data: Dictionary = SpellData.get_active_spell_data(spell_id) if is_active else SpellData.get_passive_spell_data(spell_id)
   if not ((is_active and SpellData.is_valid_active_spell(spell_data)) or SpellData.is_valid_passive_spell(spell_data)): return
   
   var familiar_list: Array = spell_data[SpellData.SpellFields.Familiars]
   if familiar_list.size() < familiar_idx: return
   
   var familiar: Familiar = load(familiar_list[familiar_idx]).create_from_byte_array(owner_id, creation_data)
   FAMILIARS.add_child(familiar)
   
# ===================== #
#    SIGNAL HANDLING    #
# ===================== #

func _on_mpm_connection_established(network_id: int) -> void:
   var dummy: Dummy = DummyScene.instantiate()
   add_child(dummy)
   dummy.NETWORK_ID = network_id
   dummy.set_name("dummy_" + str(network_id))
   dummy.recieve_base_statistics(match_settings.PLAYER_BASE_STATS)
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
func _on_mpm_damage_data           (_network_id: int, package: DamagePackage):
   if package.id_to == PLAYER_CHARACTER.MY_NETWORK_ID:
      PLAYER_CHARACTER.recieve_damage_package(package)
   elif _dummies.has(package.id_to):
      _dummies[package.id_to].recieve_damage_package(package)
   else:
      return
func _on_mpm_ready_button_pressed  () -> void:
   PLAYER_CHARACTER.Enabled = true
func _on_mpm_effect_equipped_data  (network_id: int, spell_id: int, is_active: bool) -> void:
   if _dummies.has(network_id):
     _dummies[network_id].on_effect_equip_data(spell_id, is_active)
func _on_mpm_effect_state_data     (network_id: int, spell_id: int, is_active: bool, spell_state: int) -> void:
   if _dummies.has(network_id):
     _dummies[network_id].on_effect_state_data(spell_id, is_active, spell_state)
func _on_mpm_spawn_familiar_data   (network_id: int, spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray) -> void:
   _spawn_familiar(network_id, spell_id, is_active, familiar_idx, creation_data)

func _on_player_damage_dealt       (package : DamagePackage) -> void:
   MPM.send_damage_data(package)
   if _dummies.has(package.id_to):
      _dummies[package.id_to].recieve_damage_package(package)

func _on_player_familiar_spawned   (spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray) -> void:
   _spawn_familiar(MPM.get_local_player_id(), spell_id, is_active, familiar_idx, creation_data)
   MPM.send_spawn_familiar_data(spell_id, is_active, familiar_idx, creation_data)

# ================ #
#    GAME SETUP    #
# ================ #

var match_settings : MatchSettings = MatchSettings.new()

func sync_player_base_stats(): 
   PLAYER_CHARACTER.sync_statistics(match_settings.PLAYER_BASE_STATS)
func sync_prism_settings():
   PLAYER_CHARACTER.sync_prism_settings(match_settings.MIN_SPELL_FROM_PRISM,match_settings.MAX_SPELL_FROM_PRISM,match_settings.DEFAULT_PRISM_SHOW_COUNT, \
                                    match_settings.PRISM_REROLL_COUNT,match_settings.PRISM_REROLL_DECREMENT,match_settings.MAX_PRISM_REROLL_LOCK, \
                                    match_settings.PRISM_FORCE_ACTIVE_ABILITIES,match_settings.ACTIVE_ABILITIES_PERCENT,
                                    match_settings.ACTIVE_SPELL_WEIGHTS, match_settings.PASSIVE_SPELL_WEIGHTS, match_settings.ACTIVE_MERCY_WEIGHTS, \
                                    match_settings.PASSIVE_MERCY_WEIGHTS, match_settings.KOS_PER_MERCY_WEIGHT,match_settings.MAX_MERCY_WEIGHT_APPLICATION)
