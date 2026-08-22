extends ActiveSpell
class_name GreatBallOFire

enum FamiliarIDs { FIREBALL_PROJECTILE }
const SPELL_DAMAGE: float = 5.0

func _init() -> void: super(SpellData.ActiveSpellIDs.GreatBallOfFire)
   
func _on_activate(activator: Player) -> void:
   if _can_activate():
      TimeSinceActivation = 0.0
      var player_look_dir: Vector3 = -activator.CAMERA.global_transform.basis.z
      var fireball_pos: Vector3 = activator.CAMERA.global_position + (player_look_dir * 0.25)
      var fireball_velocity: Vector3 = player_look_dir + (activator.velocity * 0.05)
      var temp_familiar := GreatBallOFireFamiliar.new(activator.NETWORK_ID, fireball_pos, fireball_velocity)
      activator.spawn_familiar(true, SpellData.ActiveSpellIDs.GreatBallOfFire, FamiliarIDs.FIREBALL_PROJECTILE, temp_familiar.reduce_to_byte_array())
