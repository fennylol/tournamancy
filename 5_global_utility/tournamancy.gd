extends Node3D
class_name Tournamancy

@onready var PLAYER_CHARACTER: Player             = $Player
@onready var LIBRARY         : Node3D             = $Library
@onready var MPM             : MultiplayerManager = $MultiplayerManager
@onready var FAMILIARS       : Node3D             = $Familiars

const DummyScene  : PackedScene = preload("res://1_player/dummy/dummy.tscn")

@onready var SPAWN_POS_IN_LIBRARY := LIBRARY.position
const drag_player_to : Vector3 = Vector3(0,100,-10)
var drag_player_from : Vector3 = Vector3.ZERO
var is_dragging : bool = false
var dragtime : float = 0
const dragspeed : float = 0.20

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
   MPM.knockout_data.connect(_on_mpm_knockout_data)
   MPM.victory_point_data.connect(_on_mpm_victory_point_data)
   MPM.effect_equipped_data.connect(_on_mpm_effect_equipped_data)
   MPM.effect_state_data.connect(_on_mpm_effect_state_data)
   MPM.spawn_familiar_data.connect(_on_mpm_spawn_familiar_data)
   LIBRARY.player_exited.connect(_on_library_player_exited)
   PLAYER_CHARACTER.HEALTHBAR.health_reached_zero.connect(_on_player_knocked_out)
   PLAYER_CHARACTER.open_connection_menu_please.connect(MPM.open_connection_menu)
   PLAYER_CHARACTER.spell_equipped.connect(MPM.send_effect_equip_data)
   PLAYER_CHARACTER.player_spell_change_state.connect(MPM.send_effect_state_data)
   PLAYER_CHARACTER.damage_dealt.connect(_on_player_damage_dealt)
   PLAYER_CHARACTER.familiar_spawned.connect(_on_player_familiar_spawned)
   PLAYER_CHARACTER.MY_NETWORK_ID = MPM.get_local_player_id()
   PLAYER_CHARACTER.position = SPAWN_POS_IN_LIBRARY + Vector3(randf(), 0, randf())

func _physics_process(delta: float) -> void:
   if is_dragging:
      dragtime += delta * dragspeed
      PLAYER_CHARACTER.position = drag_player_from.slerp(drag_player_to, ease(dragtime,-3))
   if abs(PLAYER_CHARACTER.position.z - drag_player_to.z) <= 1: is_dragging = false
   MPM.send_player_transform_data(PLAYER_CHARACTER.generate_transform_data())

func _spawn_familiar(owner_id: int, spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray) -> void:
   var spell_data: Dictionary = SpellData.get_active_spell_data(spell_id) if is_active else SpellData.get_passive_spell_data(spell_id)
   if not ((is_active and SpellData.is_valid_active_spell(spell_data)) or SpellData.is_valid_passive_spell(spell_data)): return
   
   var familiar_list: Array = spell_data[SpellData.SpellFields.Familiars]
   if familiar_list.size() < familiar_idx: return
   
   var familiar: Familiar = load(familiar_list[familiar_idx]).create_from_byte_array(owner_id, creation_data)
   FAMILIARS.add_child(familiar)

# ======================== #
#  VICTORY POINT HANDLING  #
# ======================== #

func check_VP_for_self_KO_opponent():
   var point_delta = SettingsManager.match_settings.POINT_RULES.get(SettingsManager.match_settings.PointConditions.self_KO_opponent)
   if point_delta != null and point_delta != 0: _send_VP_data(point_delta)
func check_VP_for_opponent_KO_self(): 
   var point_delta = SettingsManager.match_settings.POINT_RULES.get(SettingsManager.match_settings.PointConditions.opponent_KO_self)
   if point_delta != null and point_delta != 0: _send_VP_data(point_delta)
func check_VP_for_self_KO_self():
   var point_delta = SettingsManager.match_settings.POINT_RULES.get(SettingsManager.match_settings.PointConditions.self_KO_self)
   if point_delta != null and point_delta != 0: _send_VP_data(point_delta)
func _send_VP_data(point_delta : int):
   ## TODO: UPDATE VICTORY POINTS FOR SELF
   print("You have earned ", point_delta, " Victory Point(s).")
   pass
   ## SEND VICTORY POINTS
   MPM.send_victory_point_data(point_delta)
func update_opponent_VP(peer_id : int, point_delta : int):
   ## TODO: UPDATE VICTORY POINTS FOR OPPONENTS
   print("Opponent ", peer_id, " has earned ", point_delta, " Victory Point(s).")

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
func _on_mpm_peer_discconected     (network_id: int) -> void:
   if SettingsManager.peer_settings.has(network_id):
      SettingsManager.peer_settings[network_id].dummy.queue_free()
      SettingsManager.peer_settings[network_id] = null
func _on_mpm_transform_data        (network_id: int, data: PackedByteArray) -> void:
   if SettingsManager.peer_settings.has(network_id):
     SettingsManager.peer_settings[network_id].dummy.on_transform_data(data)
func _on_mpm_identity_data         (network_id: int, new_name: String, primary_color: float, secondary_color: float) -> void:
   if SettingsManager.peer_settings.has(network_id):
      SettingsManager.peer_settings[network_id].dummy.on_identity_data(new_name, primary_color, secondary_color)
func _on_mpm_damage_data           (_network_id: int, package: DamagePackage):
   if package.id_to == MPM.get_local_player_id():
      PLAYER_CHARACTER.on_damage_data(package)
   elif SettingsManager.peer_settings.has(package.id_to):
      SettingsManager.peer_settings[package.id_to].dummy.on_damage_data(package)
func _on_mpm_knockout_data         (killer_id: int, KO_player_id : int): 
   if SettingsManager.peer_settings.has(KO_player_id):
      SettingsManager.peer_settings[KO_player_id].dummy.on_knockout_reset()
   if killer_id == MPM.get_local_player_id() and KO_player_id != MPM.get_local_player_id():
      check_VP_for_self_KO_opponent()
func _on_mpm_victory_point_data    (network_id: int, points_delta : int): 
   if network_id == MPM.get_local_player_id(): return
   update_opponent_VP(network_id, points_delta)
func _on_mpm_ready_button_pressed  () -> void:
   PLAYER_CHARACTER.Enabled = true
func _on_mpm_effect_equipped_data  (network_id: int, spell_id: int, is_active: bool) -> void:
   if SettingsManager.peer_settings.has(network_id):
     SettingsManager.peer_settings[network_id].dummy.on_effect_equip_data(spell_id, is_active)
func _on_mpm_effect_state_data     (network_id: int, spell_id: int, is_active: bool, spell_state: int) -> void:
   if SettingsManager.peer_settings.has(network_id):
     SettingsManager.peer_settings[network_id].dummy.on_effect_state_data(spell_id, is_active, spell_state)
func _on_mpm_spawn_familiar_data   (network_id: int, spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray) -> void:
   _spawn_familiar(network_id, spell_id, is_active, familiar_idx, creation_data)

func _on_player_damage_dealt       (package : DamagePackage) -> void:
   MPM.send_damage_data(package)
   if SettingsManager.peer_settings.has(package.id_to):
      SettingsManager.peer_settings[package.id_to].dummy.on_damage_data(package)
func _on_player_knocked_out        (killer_id : int): 
   ## SEND KNOCKOUT VICTORY POINT DATA
   MPM.send_knockout_data(killer_id)
   if killer_id == MPM._OTP.NetworkID: check_VP_for_self_KO_self()
   else: check_VP_for_opponent_KO_self()
   ## RESET PLAYER
   PLAYER_CHARACTER.position = SPAWN_POS_IN_LIBRARY + Vector3(randf(), 0, randf())
   PLAYER_CHARACTER.SpellBook.adopt_class(ClassData.ClassIDs.NakedManChallenge)
   PLAYER_CHARACTER.update_HUD_icons()
   PLAYER_CHARACTER.sync_health()

func _on_player_familiar_spawned   (spell_id: int, is_active: bool, familiar_idx: int, creation_data: PackedByteArray) -> void:
   _spawn_familiar(MPM.get_local_player_id(), spell_id, is_active, familiar_idx, creation_data)
   MPM.send_spawn_familiar_data(spell_id, is_active, familiar_idx, creation_data)

func _on_library_player_exited     (start_location : Vector3):
   drag_player_from = start_location
   is_dragging = true
   dragtime = 0.0
