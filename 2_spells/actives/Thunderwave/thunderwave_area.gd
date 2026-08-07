extends Effect

@onready var DAMAGE_AREA : Area3D = $Area3D

func change_state(new_state: ThunderwaveSpell.States) -> void:
   if new_state == ThunderwaveSpell.States.DAMAGE_WAVE:
      print("Thunderwave Activated")
