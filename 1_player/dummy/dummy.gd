extends Node3D
class_name Dummy

## NODES AND TEXTURES
@onready var EYES        : Node3D        = $Eyes
@onready var L_HAND      : Sprite3D      = $Eyes/Lhand
@onready var R_HAND      : Sprite3D      = $Eyes/Rhand
@onready var BODY        : WizardBody    = $WizardBody
@onready var NAMETAG     : Label3D       = $NameTag
@onready var HB_VIEWPORT : SubViewport   = $SubViewport
@onready var HEALTHBAR   : HealthDisplay = $SubViewport/HealthDisplay
@onready var EFFECTS     : Node3D        = $Effectory
const HAND_IMG : Texture2D = preload("res://4_ui/hud/oppponent_hand.png")
const POINT_IMG: Texture2D = preload("res://4_ui/hud/oppponent_point.png")

## MOVEMENT DATA
var velocity := Vector3.ZERO
var _net_pos := Vector3.ZERO
var _net_rot := Vector3.ZERO
var _net_vel := Vector3.ZERO
var _has_net_state: bool = false
var _time_since_packet: float = 0.0
const EXTRAPOLATION_LIMIT: float = 0.5  # seconds

## HEALTHBAR DATA
var total_health : Array[float] = [ 20.0 , 0.0 , 0.0 , 0.0 ]

func _ready() -> void:
   _sync_healthbar()
func _process(_delta: float) -> void:
   if Input.is_physical_key_pressed(KEY_7): recieve_damage(0.25)
   if Input.is_physical_key_pressed(KEY_8): recieve_additional_health([0.25])

func _physics_process(delta: float) -> void:
   if not _has_net_state: return

   _time_since_packet += delta
   if _time_since_packet < EXTRAPOLATION_LIMIT:
      _net_pos += _net_vel * delta   # only extrapolate while data is fresh

   var t := 1.0 - exp(-20.0 * delta)
   position = position.lerp(_net_pos, t)
   if position != _net_pos: BODY.set_walk_direction(position, _net_pos)
   BODY.update_facing_direction(_net_rot)
   #quaternion = quaternion.slerp(Quaternion.from_euler(Vector3(0, _net_rot.y, _net_rot.z)), t)
   #EYES.rotation.x = clamp(_net_rot.x, -PI/2, PI/2)
   
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
func on_nametag_data(new_name: String) -> void:
   NAMETAG.text = new_name

func on_effect_equip_data(spell_id: int, is_active: bool) -> void:
   EFFECTS.equip_effect(spell_id, is_active)
func on_effect_erase_data(spell_id: int, is_active: bool) -> void: EFFECTS.erase_effect(spell_id, is_active)
func on_effect_state_data(spell_id: int, is_active: bool, spell_state: int) -> void:
   EFFECTS.change_effect_state(spell_id, is_active, spell_state)

func recieve_damage(amt : float):
   var remaining_damage : float = amt
   for i in total_health.size():
      var j : int= total_health.size() - 1 - i
      if total_health[j] >= remaining_damage: 
         total_health[j] -= remaining_damage
         remaining_damage = 0
      else:
         remaining_damage -= total_health[j]
         total_health[j] = 0
   _sync_healthbar()
func recieve_additional_health(add_health : Array[float]):
   for i in add_health.size():
      if i >= 4: continue
      total_health[i] += add_health[i]
   _sync_healthbar()
func _sync_healthbar():
   HEALTHBAR.update_display(total_health)
   HB_VIEWPORT.size.x = HEALTHBAR.get_bar_size() * 24
