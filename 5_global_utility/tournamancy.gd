extends Node3D
class_name Tournamancy

var VP_MANAGER : VictoryPointManager = VictoryPointManager.new()

@onready var PLAYER_CHARACTER: Player             = $Player
@onready var GAME_MAP        : GameMap            = $Map/GameMap
@onready var MPM             : MultiplayerManager = $MultiplayerManager
@onready var FAMILIARS       : Node3D             = $Familiars

const DummyScene  : PackedScene = preload("res://1_player/dummy/dummy.tscn")

enum DataTypes { TransformData = 0x20, ConnectionData = 0xCD, NameTagData = 0x15}
func _ready() -> void:
   InputManager.init_inputs()
   MPM.connection_established.connect(_on_mpm_connection_established)
   MPM.peer_disconnected.connect(_on_mpm_peer_discconected)
   MPM.ready_button_pressed.connect(_on_mpm_ready_button_pressed)
   MPM.identity_changed.connect(PLAYER_CHARACTER.set_colors)
   MPM.transform_data.connect(_on_mpm_transform_data)
   MPM.identity_data.connect(_on_mpm_identity_data)
   MPM.damage_data.connect(_on_mpm_damage_data)
   MPM.health_update_data.connect(_on_mpm_health_update_data)
   MPM.knockout_data.connect(_on_mpm_knockout_data)
   MPM.victory_point_data.connect(_on_mpm_victory_point_data)
   MPM.spawned_prism_data.connect(_on_mpm_spawned_prism_data)
   MPM.updated_prism_data.connect(_on_mpm_updated_prism_data)
   MPM.removed_prism_data.connect(_on_mpm_removed_prism_data)
   MPM.effect_equipped_data.connect(_on_mpm_effect_equipped_data)
   MPM.effect_erased_data.connect(_on_mpm_effect_erased_data)
   MPM.spell_state_data.connect(_on_mpm_spell_state_data)
   MPM.spawn_familiar_data.connect(_on_mpm_spawn_familiar_data)
   VP_MANAGER.set_personal_id(MPM.get_local_player_id())
   GAME_MAP.force_player_location.connect(force_player_position)
   GAME_MAP.grant_spawn_overhealth.connect(grant_respawn_overhealth)
   GAME_MAP.spawned_prism.connect(MPM.send_spawned_prism_data)
   GAME_MAP.updated_prism.connect(MPM.send_updated_prism_data)
   GAME_MAP.removed_prism.connect(MPM.send_removed_prism_data)
   PLAYER_CHARACTER.HEALTHBAR.health_updated.connect(_on_player_health_updated)
   PLAYER_CHARACTER.HEALTHBAR.health_reached_zero.connect(_on_player_knocked_out)
   PLAYER_CHARACTER.open_connection_menu_please.connect(MPM.open_connection_menu)
   PLAYER_CHARACTER.spell_equipped.connect(MPM.send_effect_equip_data)
   PLAYER_CHARACTER.spell_erased.connect(MPM.send_effect_erase_data)
   PLAYER_CHARACTER.spell_changed_state.connect(MPM.send_spell_state_data)
   PLAYER_CHARACTER.damage_dealt.connect(_on_player_damage_dealt)
   PLAYER_CHARACTER.familiar_spawned.connect(_on_player_familiar_spawned)
   PLAYER_CHARACTER.NETWORK_ID = MPM.get_local_player_id()
   PLAYER_CHARACTER.position = GAME_MAP.get_library_spawn_pos()

func _physics_process(_delta: float) -> void:
   if Input.is_key_pressed(KEY_0): VP_MANAGER.self_dictionary_to_PackedByteArray()
   MPM.send_player_transform_data(PLAYER_CHARACTER.generate_transform_data())

func _spawn_familiar(owner_id: int, spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray) -> void:
   var spell_data: Dictionary = SpellData.get_active_spell_data(spell_id) if is_active else SpellData.get_passive_spell_data(spell_id)
   if not ((is_active and SpellData.is_valid_active_spell(spell_data)) or SpellData.is_valid_passive_spell(spell_data)): return
   
   var familiar_list: Array = spell_data[SpellData.SpellFields.Familiars]
   if familiar_list.size() <= familiar_idx: return
   
   var familiar: Familiar = load(familiar_list[familiar_idx]).create_from_byte_array(owner_id, creation_data)
   if owner_id == PLAYER_CHARACTER.NETWORK_ID: 
      # TODO: REALLY cludgy way to do this but idk man
      familiar.ThePlayer = PLAYER_CHARACTER
   FAMILIARS.add_child(familiar)

# ================ #
#  PLAYER RESPAWN  #
# ================ #

func force_player_position(pos : Vector3): PLAYER_CHARACTER.position = pos
func get_player_position() -> Vector3: return PLAYER_CHARACTER.position
func grant_respawn_overhealth() -> void:
   PLAYER_CHARACTER.sync_health()
   PLAYER_CHARACTER._update_heath_display([0,0,0,SettingsManager.match_settings.RETURNING_PLAYER_OVERHEALTH], true)

# ======================== #
#  VICTORY POINT HANDLING  #
# ======================== #

func update_VP_condition_total(condition : VictoryPointManager.PointConditions, delta : int):
   VP_MANAGER.update_condition_total(condition, delta)
   MPM.send_victory_point_data(VP_MANAGER.self_dictionary_to_PackedByteArray())
func update_opponent_VP(data : PackedByteArray):
   var new_dict = VP_MANAGER.PackedByteArray_to_peer_Dictionary(data)
   VP_MANAGER.import_single_peer_dict(new_dict.keys()[0],new_dict.get(new_dict.keys()[0]), true)

# ===================== #
#    SIGNAL HANDLING    #
# ===================== #

# multiplayer_manager 
func _on_mpm_connection_established(network_id: int) -> void:
   var dummy: Dummy = DummyScene.instantiate()
   add_child(dummy)
   dummy.NETWORK_ID = network_id
   dummy.set_name("dummy_" + str(network_id))
   SettingsManager.peer_settings[network_id] = SettingsManager.PeerSettings.new(dummy, str(network_id), Color.WHITE, Color.WHITE)
   PLAYER_CHARACTER.announce_inventory()
func _on_mpm_peer_discconected     (network_id: int) -> void:
   if SettingsManager.peer_settings.has(network_id):
      SettingsManager.peer_settings[network_id].dummy.queue_free()
      SettingsManager.peer_settings[network_id] = null
func _on_mpm_transform_data        (network_id: int, data: PackedByteArray) -> void:
   if SettingsManager.peer_settings.has(network_id):
     SettingsManager.peer_settings[network_id].dummy.on_transform_data(data)
func _on_mpm_identity_data         (network_id: int, new_name: String, primary_color: Color, secondary_color: Color) -> void:
   if SettingsManager.peer_settings.has(network_id):
      SettingsManager.peer_settings[network_id].dummy.on_identity_data(new_name, primary_color, secondary_color)
func _on_mpm_damage_data           (_network_id: int, package: DamagePackage) -> void:
   if package.id_to == MPM.get_local_player_id():
      PLAYER_CHARACTER.on_damage_data(package)
   elif SettingsManager.peer_settings.has(package.id_to):
      SettingsManager.peer_settings[package.id_to].dummy.on_damage_data(package)
func _on_mpm_health_update_data    (network_id: int, health : Array[float]) -> void:
   if SettingsManager.peer_settings.has(network_id):
      SettingsManager.peer_settings[network_id].dummy.on_mpm_sync_healthbar(health)
func _on_mpm_knockout_data         (killer_id: int, KO_player_id : int) -> void: 
   if SettingsManager.peer_settings.has(KO_player_id):
      SettingsManager.peer_settings[KO_player_id].dummy.on_knockout_reset()
   if killer_id == MPM.get_local_player_id() and KO_player_id != MPM.get_local_player_id():
      update_VP_condition_total(VictoryPointManager.PointConditions.self_KO_opponent, 1)
func _on_mpm_victory_point_data    (data : PackedByteArray) -> void: 
   update_opponent_VP(data)
func _on_mpm_spawned_prism_data    (prismdata : PackedByteArray) -> void: 
   GAME_MAP.spawn_prism_from_network(prismdata)
func _on_mpm_updated_prism_data    (_prismdata : PackedByteArray) -> void: pass
func _on_mpm_removed_prism_data    (id : int) -> void: 
   GAME_MAP.prism_destroyed_from_network(id)
func _on_mpm_effect_equipped_data  (network_id: int, spell_id: int, is_active: bool) -> void:
   if SettingsManager.peer_settings.has(network_id):
     SettingsManager.peer_settings[network_id].dummy.on_effect_equipped_data(spell_id, is_active)
func _on_mpm_effect_erased_data    (network_id: int, spell_id: int, is_active: bool) -> void:
   if SettingsManager.peer_settings.has(network_id):
     SettingsManager.peer_settings[network_id].dummy.on_effect_erased_data(spell_id, is_active)
func _on_mpm_spell_state_data      (network_id: int, spell_id: int, is_active: bool, spell_state: int) -> void:
   if SettingsManager.peer_settings.has(network_id):
     SettingsManager.peer_settings[network_id].dummy.on_spell_state_data(spell_id, is_active, spell_state)
func _on_mpm_spawn_familiar_data   (network_id: int, spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray) -> void:
   _spawn_familiar(network_id, spell_id, is_active, familiar_idx, creation_data)
func _on_mpm_ready_button_pressed  () -> void:
   PLAYER_CHARACTER.Enabled = true

# game map
func _on_gamemap_prism_spawned     (): pass
func _on_gamemap_prism_updated     (): pass
func _on_gamemap_prism_removed     (): pass

# player
func _on_player_health_updated     (new_health : Array[float]):
   MPM.send_health_update_data(new_health)
   PLAYER_CHARACTER.HUD.update_healthbar(new_health, false)
func _on_player_damage_dealt       (package : DamagePackage) -> void:
   MPM.send_damage_data(package)
   if SettingsManager.peer_settings.has(package.id_to):
      SettingsManager.peer_settings[package.id_to].dummy.on_damage_data(package)
func _on_player_knocked_out        (killer_id : int): 
   ## SEND KNOCKOUT VICTORY POINT DATA
   MPM.send_knockout_data(killer_id)
   if killer_id == MPM._OTP.NetworkID: update_VP_condition_total(VictoryPointManager.PointConditions.self_KO_self, 1)
   else: update_VP_condition_total(VictoryPointManager.PointConditions.opponent_KO_self, 1)
   ## SPAWN PRISM
   GAME_MAP.spawn_player_prism_from_self(PLAYER_CHARACTER.position, PLAYER_CHARACTER.SpellBook.ActiveSpells, PLAYER_CHARACTER.SpellBook.PassiveSpells)
   ## RESET PLAYER
   PLAYER_CHARACTER.position = GAME_MAP.get_library_spawn_pos()
   PLAYER_CHARACTER.SpellBook.adopt_class(ClassData.ClassIDs.NakedManChallenge)
   PLAYER_CHARACTER.update_HUD_icons()
   PLAYER_CHARACTER.sync_health()
func _on_player_familiar_spawned   (spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray) -> void:
   _spawn_familiar(MPM.get_local_player_id(), spell_id, is_active, familiar_idx, creation_data)
   MPM.send_spawn_familiar_data(spell_id, is_active, familiar_idx, creation_data)
