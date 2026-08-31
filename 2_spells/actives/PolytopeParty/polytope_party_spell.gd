extends ActiveSpell
class_name PolytopePartySpell

#enum States {}
enum FamiliarIDs {BLOCK}
enum BlockTypes {I, L, O, S, T}

#func on_state_changed(new_state: int) -> void:
   #super(new_state) # NOTE: keep this line if adding custom state change logic

# TODO: replace ERROR with your new spell ID
func _init() -> void:
   super(SpellData.ActiveSpellIDs.PolytopeParty)

func _on_activate(activator: Player) -> void:
   if _can_activate() and activator.is_on_floor():
      TimeSinceActivation = 0.0
      var block_idx: int = randi_range(0, BlockTypes.size()-1)
      var block_pos: Vector3 = activator.global_position - Vector3(0, PolytopePartyBlock.MONOTOPE_SIZE/2, 0)
      var block_rot: float = activator.rotation.y
      var temp_familiar := PolytopePartyBlock.new(activator.NETWORK_ID, block_idx, block_pos, block_rot)
      activator.spawn_familiar(true, SpellData.ActiveSpellIDs.PolytopeParty, FamiliarIDs.BLOCK, temp_familiar.reduce_to_byte_array())
