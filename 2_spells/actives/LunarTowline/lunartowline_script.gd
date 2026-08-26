extends ActiveSpell
class_name LunarTowlineSpell

enum States {None, Charging, Cast, Hold, Reeling}
enum FamiliarIDs {Hook}

var cast_power : float = 0.0

#func on_state_changed(new_state: int) -> void:
   #super(new_state) # NOTE: keep this line if adding custom state change logic

func _init() -> void: super(SpellData.ActiveSpellIDs.LunarTowline)

func _on_activate(_activator: Player) -> void:
   if ( CurrentState == States.Cast or CurrentState == States.Hold ):
      CurrentState = States.Reeling
      TimeSinceActivation = 0.0
      cast_power = 0.0
      print("reeled the line in")
   elif _can_activate():
      CurrentState = States.Charging
   else:
      print("cannot activate")

func _on_hold(_activator: Player, delta : float) -> void:
   if CurrentState == States.Charging:
      cast_power +=  delta
      if is_equal_approx(cast_power,(round(cast_power*10)/10)): print("charging. ", cast_power)

func _on_release(activator: Player) -> void:
   if CurrentState == States.Charging:
      CurrentState = States.Cast
      _cast(activator)
      print("cast the line at ", cast_power, " power")
   elif CurrentState == States.Reeling:
      CurrentState = States.None

func _cast(activator : Player):
   var player_look_dir: Vector3 = -activator.CAMERA.global_transform.basis.z
   var hook_pos: Vector3 = activator.CAMERA.global_position + (player_look_dir * 0.25)
   var hook_velocity: Vector3 = player_look_dir.normalized() * cast_power
   var temp_familiar := LunarTowline_Hook.new(activator.NETWORK_ID, hook_pos, hook_velocity)
   activator.spawn_familiar(true, SpellData.ActiveSpellIDs.LunarTowline, FamiliarIDs.Hook, temp_familiar.reduce_to_byte_array())
