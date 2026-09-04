class_name InputManager

static func init_inputs() -> void:
   var register_keyboard_input: Callable = func(input_name: String, keycode: Key):
      if not InputMap.has_action(input_name): InputMap.add_action(input_name)
      var event := InputEventKey.new()
      event.keycode = keycode
      InputMap.action_add_event(input_name, event)
   var register_mouse_button_input: Callable = func(input_name: String, keycode: MouseButton):
      if not InputMap.has_action(input_name): InputMap.add_action(input_name)
      var event := InputEventMouseButton.new()
      event.button_index = keycode
      InputMap.action_add_event(input_name, event)
   var register_joypad_button_input: Callable = func(input_name: String, keycode: JoyButton):
      if not InputMap.has_action(input_name): InputMap.add_action(input_name)
      var event := InputEventJoypadButton.new()
      event.button_index = keycode
      InputMap.action_add_event(input_name, event)
   var register_joypad_axis_input: Callable = func(input_name: String, keycode: JoyAxis, value : float):
      if not InputMap.has_action(input_name): InputMap.add_action(input_name)
      var event := InputEventJoypadMotion.new()
      event.axis = keycode
      event.axis_value = value
      InputMap.action_add_event(input_name, event)
   
   # ======================== #
   #    KEYBOARD AND MOUSE    #
   # ======================== #
   
   ## MENU
   register_keyboard_input.call("menu", KEY_ESCAPE)
   register_keyboard_input.call("free_mouse", KEY_TAB)
   register_keyboard_input.call("active_shuffle", KEY_ALT)
   
   ## MOVE AND JUMP
   register_keyboard_input.call("left",  KEY_A)
   register_keyboard_input.call("down",  KEY_S)
   register_keyboard_input.call("right", KEY_D)
   register_keyboard_input.call("up",    KEY_W)
   register_keyboard_input.call("jump", KEY_SPACE)
   register_keyboard_input.call("sprint", KEY_SHIFT)
   
   ## INTERACT
   register_keyboard_input.call("interact", KEY_E)
   register_keyboard_input.call("quick_melee", KEY_E)
   
   ## ACTIVE ABILITIES
   register_mouse_button_input.call("active_spell_0", MOUSE_BUTTON_LEFT)
   register_mouse_button_input.call("active_spell_1", MOUSE_BUTTON_RIGHT)
   
   ## PRISMS AND UI
   register_keyboard_input.call("cursor_left",  KEY_LEFT)
   register_keyboard_input.call("cursor_down",  KEY_DOWN)
   register_keyboard_input.call("cursor_right", KEY_RIGHT)
   register_keyboard_input.call("cursor_up",    KEY_UP)
   register_keyboard_input.call("cursor_left",  KEY_D)
   register_keyboard_input.call("cursor_down",  KEY_S)
   register_keyboard_input.call("cursor_right", KEY_A)
   register_keyboard_input.call("cursor_up",    KEY_W)
   register_mouse_button_input.call("select", MOUSE_BUTTON_LEFT)
   register_keyboard_input.call("select", KEY_ENTER)
   register_keyboard_input.call("select", KEY_E)
   register_keyboard_input.call("cancel", KEY_ESCAPE)
   register_keyboard_input.call("lock", KEY_SHIFT)
   register_keyboard_input.call("reroll", KEY_TAB)
   register_keyboard_input.call("reroll", KEY_R)
   
   # ================ #
   #    CONTROLLER    #
   # ================ #
   
   ## MENU
   register_joypad_button_input.call("menu", JOY_BUTTON_GUIDE)
   register_joypad_button_input.call("menu", JOY_BUTTON_START)
   register_joypad_button_input.call("free_mouse", JOY_BUTTON_Y)
   register_joypad_button_input.call("active_shuffle", JOY_BUTTON_RIGHT_STICK)
   
   ## CAMERA
   register_joypad_axis_input.call("camera_left",  JOY_AXIS_RIGHT_X, 1.0)
   register_joypad_axis_input.call("camera_down",  JOY_AXIS_RIGHT_Y, 1.0)
   register_joypad_axis_input.call("camera_right", JOY_AXIS_RIGHT_X, -1.0)
   register_joypad_axis_input.call("camera_up",    JOY_AXIS_RIGHT_Y, -1.0)
   
   ## MOVE AND JUMP
   register_joypad_axis_input.call("left",  JOY_AXIS_LEFT_X, -1.0)
   register_joypad_axis_input.call("down",  JOY_AXIS_LEFT_Y, 1.0)
   register_joypad_axis_input.call("right", JOY_AXIS_LEFT_X, 1.0)
   register_joypad_axis_input.call("up",    JOY_AXIS_LEFT_Y, -1.0)
   register_joypad_button_input.call("jump", JOY_BUTTON_A)
   register_joypad_button_input.call("sprint", JOY_BUTTON_B)
   
   ## INTERACT
   register_joypad_button_input.call("interact", JOY_BUTTON_X)
   register_joypad_button_input.call("quick_melee", JOY_BUTTON_X)
   
   ## ACTIVE ABILITIES
   register_joypad_axis_input.call("active_spell_0", JOY_AXIS_TRIGGER_LEFT, 1.0)
   register_joypad_axis_input.call("active_spell_1", JOY_AXIS_TRIGGER_RIGHT, 1.0)
   
   ## PRISMS AND UI
   register_joypad_button_input.call("cursor_left",  JOY_BUTTON_DPAD_LEFT)
   register_joypad_button_input.call("cursor_down",  JOY_BUTTON_DPAD_DOWN)
   register_joypad_button_input.call("cursor_right", JOY_BUTTON_DPAD_RIGHT)
   register_joypad_button_input.call("cursor_up",    JOY_BUTTON_DPAD_UP)
   register_joypad_button_input.call("select", JOY_BUTTON_A)
   register_joypad_button_input.call("cancel", JOY_BUTTON_B)
   register_joypad_button_input.call("lock", JOY_BUTTON_Y)
   register_joypad_button_input.call("reroll", JOY_BUTTON_X)
