extends Effect

@onready var SPEAKER := $AudioStreamPlayer3D

func change_state(new_state: JBLSpeakerSpell.States) -> void:
   #print("new_state: ", JBLSpeakerSpell.States.find_key(new_state))
   SPEAKER.stream_paused = not new_state
