extends Node3D
class_name Effect

var ThePlayer : Player

func change_state(_new_state: int) -> void:
   printerr("ERROR: change_state() not overridden but called.")

## Called by the Effectory in equip_effect() when the effect is placed on a player (not on a dummy) so the effect has a reference to the local Player node if necessary.
func find_the_player(player : Player): ThePlayer = player
