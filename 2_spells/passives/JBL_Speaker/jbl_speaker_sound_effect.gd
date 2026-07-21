extends Effect

enum States {NotPlaying, Playing}

func change_state(new_state: States) -> void:
   print("new_state: ", States.find_key(new_state))
