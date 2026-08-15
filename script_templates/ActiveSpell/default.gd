extends ActiveSpell

enum States {}

func _init() -> void:
   # TODO: replace ERROR with your new spell ID
   super(SpellData.ActiveSpellIDs.ERROR)

func _on_activate(_activator: Player)               -> void: pass

#func change_state(new_state: int) -> void:
   #super(new_state) # NOTE: keep this line if adding custom state change logic
