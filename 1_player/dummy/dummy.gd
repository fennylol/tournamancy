extends Node3D
class_name Dummy

var NETWORK_ID : int

## NODES AND TEXTURES
@onready var BODY        : WizardBody       = $WizardBody
@onready var FAKE_EYES   : RemoteTransform3D= $RemoteTransform3D
@onready var NAMETAG     : Label3D          = $NameTag
@onready var HB_VIEWPORT : SubViewport      = $SubViewport
@onready var HB_DISPLAY  : HealthDisplay    = $SubViewport/HealthDisplay
@onready var HEALTHBAR   : HealthComponent  = $HealthComponent
@onready var EFFECTS     : Node3D           = $Effectory

## MOVEMENT DATA
var velocity := Vector3.ZERO
var _net_pos := Vector3.ZERO
var _net_rot := Vector3.ZERO
var _net_vel := Vector3.ZERO
var _has_net_state: bool = false
var _time_since_packet: float = 0.0
const EXTRAPOLATION_LIMIT: float = 0.5  # seconds

func _ready() -> void:
   var starting_health : Array[float] = [
      SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.HEARTS],
      SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.ARMOR],
      SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.WARD],
      SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.OVERHEALTH]
   ]
   HEALTHBAR.set_health(starting_health)
   _sync_healthbar()

func _physics_process(delta: float) -> void:
   if not _has_net_state: return

   _time_since_packet += delta
   if _time_since_packet < EXTRAPOLATION_LIMIT:
      _net_pos += _net_vel * delta   # only extrapolate while data is fresh

   var t := 1.0 - exp(-20.0 * delta)
   position = position.lerp(_net_pos, t)
   if position != _net_pos: BODY.set_walk_direction(position, _net_pos)
   BODY.update_facing_direction(_net_rot)

   #FAKE_EYES.quaternion = quaternion.slerp(Quaternion.from_euler(_net_rot), t)
   FAKE_EYES.rotation.x = clamp(_net_rot.x, -PI/2, PI/2)
   FAKE_EYES.rotation.y = _net_rot.y
   
   velocity = _net_vel

func on_transform_data(data: PackedByteArray) -> void:
   _net_pos = Vector3(data.decode_float(0),  data.decode_float(4),  data.decode_float(8))
   _net_rot = Vector3(data.decode_float(12), data.decode_float(16), data.decode_float(20))
   _net_vel = Vector3(data.decode_float(24), data.decode_float(28), data.decode_float(32))
   
   var flags := data.decode_u8(36)
   #L_HAND.texture = HAND_IMG if flags & (1 << 0) else POINT_IMG
   #R_HAND.texture = HAND_IMG if flags & (1 << 1) else POINT_IMG
   var lefthand_dir = 0 if flags & (1 << 0) else 90
   var righthand_dir = 0 if flags & (1 << 1) else 90
   BODY.point_with_left(lefthand_dir)
   BODY.point_with_right(righthand_dir)
   
   _has_net_state = true
   _time_since_packet = 0.0
func on_identity_data(new_name: String, new_primary_color: Color, new_secondary_color: Color) -> void:
   NAMETAG.text = new_name
   BODY.set_colors(new_primary_color, new_secondary_color)
   var dummy_settings: SettingsManager.PeerSettings = SettingsManager.peer_settings[NETWORK_ID]
   dummy_settings.name_tag = new_name
   dummy_settings.primary_color = new_primary_color
   dummy_settings.secondary_color = new_secondary_color
   
func on_effect_equipped_data(spell_id: int, is_active: bool) -> void:
   EFFECTS.equip_effect(spell_id, is_active)
func on_effect_erased_data(spell_id: int, is_active: bool) -> void:
   EFFECTS.erase_effect(spell_id, is_active)
func on_spell_state_data(spell_id: int, is_active: bool, spell_state: int) -> void:
   EFFECTS.change_effect_state(spell_id, is_active, spell_state)
func on_damage_data(package : DamagePackage):
   HEALTHBAR.on_damage_data(package)
   _sync_healthbar()
func on_knockout_reset():
   ## CLEAR ALL EFFECTS
   pass
   ## RESET HEALTH
   var default_health : Array[float] = [
      SettingsManager.match_settings.PLAYER_BASE_STATS.get(SpellData.StatTypes.HEARTS), \
      SettingsManager.match_settings.PLAYER_BASE_STATS.get(SpellData.StatTypes.ARMOR), \
      SettingsManager.match_settings.PLAYER_BASE_STATS.get(SpellData.StatTypes.WARD), \
      SettingsManager.match_settings.PLAYER_BASE_STATS.get(SpellData.StatTypes.OVERHEALTH)]
   HEALTHBAR.set_health(default_health)
   _sync_healthbar()

func on_mpm_sync_healthbar(health : Array[float]):
   HEALTHBAR.set_health(health)
   _sync_healthbar()
func _sync_healthbar():
   HB_DISPLAY.update_display(HEALTHBAR.get_health())
   HB_VIEWPORT.size.x = HB_DISPLAY.get_bar_size() * 24
