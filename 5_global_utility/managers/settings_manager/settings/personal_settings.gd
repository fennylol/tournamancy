extends Resource
class_name PersonalSettings

## The name that other players will see you as. Displayed above your head.
var NICKNAME : String = ""
## The color of your wizardly robes, among other things!
var PRIMARY_COLOR : Color = Color.from_ok_hsl(randf(), 1.0, 0.6)
## the color of your wizardly hat, among other things!
var SECONDARY_COLOR : Color = Color.from_ok_hsl(randf(), 0.9, 0.5)
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
