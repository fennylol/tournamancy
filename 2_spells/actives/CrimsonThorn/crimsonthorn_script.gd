extends ActiveSpell
class_name CrimsonThornSpell

#enum States {}
#enum FamiliarIDs {}

#func on_state_changed(new_state: int) -> void:
   #super(new_state) # NOTE: keep this line if adding custom state change logic

# TODO: replace ERROR with your new spell ID
func _init() -> void: super(SpellData.ActiveSpellIDs.CrimsonThorn)

func _on_activate(_activator: Player) -> void:
   if _can_activate():
      TimeSinceActivation = 0.0
