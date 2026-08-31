# meta-name: Default
# meta-description: Base template for active spells
# meta-default: true
# meta-space-indent: 3
extends ActiveSpell
# TODO: name your new ActiveSpell
class_name NewActiveSpell

#enum States {}
#enum FamiliarIDs {}

#func on_state_changed(new_state: int) -> void:
   #super(new_state) # NOTE: keep this line if adding custom state change logic

# TODO: replace ERROR with your new spell ID
func _init() -> void: super(SpellData.ActiveSpellIDs.ERROR)

func _on_activate(_activator: Player) -> void:
   if _can_activate():
      TimeSinceActivation = 0.0
      # var temp_familiar := NewFamiliar.new(activator.NETWORK_ID)
      # activator.spawn_familiar(true, SpellData.ActiveSpellIDs.NewActiveSpell, FamiliarIDs.FAMILIAR, temp_familiar.reduce_to_byte_array())


# NOTE: don't forget to add your ActiveSpell to SpellList.ActiveSpells