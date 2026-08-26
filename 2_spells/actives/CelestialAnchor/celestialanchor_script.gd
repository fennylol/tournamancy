extends ActiveSpell
class_name CelestialAnchorSpell

#enum States {}
#enum FamiliarIDs {}

#func on_state_changed(new_state: int) -> void:
   #super(new_state) # NOTE: keep this line if adding custom state change logic

var activated : bool = false
var time_in_air : float = 0.0
var MAX_TIME_IN_AIR : float = 4.0

# TODO: replace ERROR with your new spell ID
func _init() -> void: super(SpellData.ActiveSpellIDs.CelestialAnchor)

func _on_activate(_activator: Player) -> void:
   if _can_activate() and not activated: 
      activated = true

func _on_process_end(delta: float) -> void:
   super(delta)
   if activated:
      Player_Self.velocity.y = 0.0
      time_in_air += delta
      if time_in_air >= MAX_TIME_IN_AIR:
         activated = false
         time_in_air = 0.0
         TimeSinceActivation = 0.0
