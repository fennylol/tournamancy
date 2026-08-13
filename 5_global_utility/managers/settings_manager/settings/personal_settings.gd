extends Resource
class_name PersonalSettings

const COLOR_SIZE: int = 4

## The name that other players will see you as. Displayed above your head.
var NICKNAME : String = ""
## The color of your wizardly robes, among other things!
var PRIMARY_COLOR : Color = Color.from_ok_hsl(randf(), 1.0, 0.6)
## the color of your wizardly hat, among other things!
var SECONDARY_COLOR : Color = Color.from_ok_hsl(randf(), 0.9, 0.8)
## The maximum view angle your camera can see while playing.
var FIELD_OF_VIEW : float = 30.0
## How fast the camera moves in response to mouse input.
var MOUSE_SENSITIVITY : float = 1.0
## How fast the camera moves in response to horizontal joystick input.
var JOYSTICK_SENSITIVITY_X : float = 0.8
## How fast the camera moves in response to vertical joystick input.
var JOYSTICK_SENSITIVITY_y : float = 0.5
## Inverting X causes the camera to look right when the mouse or joystick pushes left.
var INVERT_X : bool = false
## Inverting Y causes the camera to look down when the mouse or joystick pushes up.
var INVERT_y : bool = false

func set_color(primary: bool, new_hue: float) -> void: 
   if primary: PRIMARY_COLOR = make_color(primary, new_hue)
   else: SECONDARY_COLOR = make_color(primary, new_hue)
func get_color(primary: bool) -> float:  return (PRIMARY_COLOR if primary else SECONDARY_COLOR).ok_hsl_h
func make_color(primary: bool, new_hue: float) -> Color: return Color.from_ok_hsl(new_hue, 1.0 if primary else 0.9, 0.6 if primary else 0.5) 
