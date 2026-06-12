class_name InputManager

static func init_inputs() -> void:
   var register_input: Callable = func(input_name: String, keycode: Key):
      InputMap.add_action(input_name)
      var event := InputEventKey.new()
      event.keycode = keycode
      InputMap.action_add_event(input_name, event)
   var register_mouse_button_input: Callable = func(input_name: String, keycode: MouseButton):
      InputMap.add_action(input_name)
      var event := InputEventMouseButton.new()
      event.button_index = keycode
      InputMap.action_add_event(input_name, event)
   
   register_input.call("menu", KEY_ESCAPE)
   register_input.call("jump", KEY_SPACE)
   
   register_input.call("left",  KEY_A)
   register_input.call("down",  KEY_S)
   register_input.call("right", KEY_D)
   register_input.call("up",    KEY_W)
   
   register_input.call("interact", KEY_E)
   register_mouse_button_input.call("active_spell_0", MOUSE_BUTTON_LEFT)
   register_mouse_button_input.call("active_spell_1", MOUSE_BUTTON_RIGHT)
