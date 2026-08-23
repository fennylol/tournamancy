extends ActiveSpell
class_name ShockstarDiscoSpell

enum FamiliarIDs {DISCO_BALL}
var Distance: float = 5.0


# set true cooldown
func _init() -> void: super(SpellData.ActiveSpellIDs.ShockstarDisco)

func _on_activate(activator: Player) -> void:
   if _can_activate():
      TimeSinceActivation = 0.0
      var player_look_dir: Vector3 = -activator.CAMERA.global_transform.basis.z
      var ball_pos: Vector3 = activator.CAMERA.global_position + (player_look_dir * 0.25)
      var ball_velocity: Vector3 = player_look_dir + (activator.velocity * 0.05)
      var temp_familiar := DiscoBallFamiliar.new(activator.NETWORK_ID, ball_pos, ball_velocity)
      activator.spawn_familiar(true, SpellData.ActiveSpellIDs.ShockstarDisco, FamiliarIDs.DISCO_BALL, temp_familiar.reduce_to_byte_array())
