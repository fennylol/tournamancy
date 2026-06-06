@tool
extends BasicButton
class_name ClassButton

@export var ClassID: ClassData.ClassIDs = ClassData.ClassIDs.NakedManChallenge

func _on_interact(interacter: Player) -> void:
   super._on_interact(interacter)
   print("becoming ", ClassData.ClassIDs.find_key(ClassID))
   interacter.SpellBook.adopt_class(ClassID)
