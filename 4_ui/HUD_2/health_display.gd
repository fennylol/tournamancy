extends Node2D
class_name HealthDisplay

## An array of exactly four (4) float values, representing [color=red][b]Hearts[/b][/color], [color=orange][b]Armor[/b][/color], [color=cyan][b]Wards[/b][/color], and [color=purple][b]Overhealth[/b][/color] respectively.[br]Additional elements in the array will likely break the system (or they will just be ignored).
@export var health_value : Array[float] = [ 20.0 , 0.0 , 0.0 , 0.0 ]
## The number of health points represented by a single icon.[br]A value of [b]4[/b] means that 4.0 hit points show as 1 heart, 8.0 hit points show as 2 hearts, etc.[br]The current system supports fractional hearts in quarter increments.[br]A value of [b]4[/b] means that 1.0 hit point is represented by 1/4th of a heart, 2.0 hit points is 1/2 of a heart, etc
@export var points_per_icon : float = 4.0
## How many decimal places the text field displaying remaining health should round to.
@export var text_decimal_places : int = 2
@onready var health_text     = $Control/HealthText
var icon_map_array : Array[TileMapLayer] = []
enum {HEARTS, ARMOR, WARD, OVERHEALTH}
var min_quarter : float = 0.125
var min_half    : float = 0.375
var min_3fourth : float = 0.625
var min_full    : float = 0.875

func _ready():
   icon_map_array = [ $HEARTS, $ARMOR, $WARD, $OVERHEALTH ]
   ## THE CURRENT TEXTURE ATLAS HAS ONLY 3 ICONS: QUARTER, HALF, 3-QUARTER, AND FULL
   ## CALCULATE THE RANGE FOR EACH ICON BASED ON points_per_heart
   var step_size : float = 1 / ( points_per_icon * 2 )
   min_quarter = step_size
   min_half    = step_size * 3
   min_3fourth = step_size * 5
   min_full    = step_size * 7

## Called to update the icons and text field to represent a new value. Accepts an array of four floats (representng [color=red][b]Hearts[/b][/color], [color=orange][b]Armor[/b][/color], [color=cyan][b]Wards[/b][/color], and [color=purple][b]Overhealth[/b][/color] respectively), and sets the display to that amount of each.[br] if "add" is set to [b]true[/b], the four float values are instead added to their respective current values.
func update_display(value : Array[float], add : bool = false) -> void:
   ## DIFFERENTIATE BETWEEN SET AND ADD
   if add:
      for i in range(value.size()):
         health_value[i] += value[i]
   else:
      health_value = value
   
   ## UPDATE HEALTH_TEXT TO THE SUM OF ALL VALUES
   var sum = 0.0
   for i in range(health_value.size()):
      if health_value[i] < 0: health_value[i] = 0
      sum += health_value[i]
   if sum <= 0.005:
      sum = 0.0
      health_text.text = "0.0 DEAD"
   else:
      var rounded_sum = round(sum*pow(10,text_decimal_places))/pow(10,text_decimal_places)
      if rounded_sum < 0.0 and sum > 0.0: rounded_sum = pow(10,-text_decimal_places)
      health_text.text = str(rounded_sum)
   
   ## UPDATE DISPLAY
   var icon_offset = [0,0,0,0]
   for i in [HEARTS, ARMOR, WARD, OVERHEALTH]:
      ## CALCULATE TOTAL OFFSET FOR THIS SET OF ICONS
      var offset = 0
      for k in range(0,i):
         offset += icon_offset[k]
      ## FOR EACH OF THE FOUR ICONS...
      ## CALCULATE HOW MANY ICONS TO DISPLAY (INCL. FRACTIONS OF AN ICON)
      var icon_amt = floor( health_value[i] / points_per_icon )
      var icon_rem = ( health_value[i] / points_per_icon ) - icon_amt
      icon_offset[i] = icon_amt
      if icon_offset[i] <= 0: icon_offset[i] = 0
      icon_map_array[i].clear()
      ## SKIP ICON IF THERE ARE NONE TO DISPLAY
      if health_value[i] <= 0: continue
      ## ADD FULL ICONS TO GRID
      for j in range(icon_amt):
         icon_map_array[i].set_cell(Vector2i(offset+j,0),1,Vector2i(randi_range(0,5),i*2))
      ## ADD AN EXTRA FULL HEART IF FRACTIONAL AMOUNT IS LARGE ENOUGH
      if icon_rem >= min_full:
         icon_map_array[i].set_cell(Vector2i(offset+icon_offset[i],0),1,Vector2i(randi_range(0,5),i*2))
         icon_offset[i] += 1
      ## ELSE, ADD A FRACTIONAL ICON
      elif icon_rem >= min_quarter:
         var fraction = 2 if icon_rem >= min_3fourth else 1 if icon_rem >= min_half else 0
         icon_map_array[i].set_cell(Vector2i(offset+icon_offset[i],0),1,Vector2i((fraction*2)+randi_range(0,1),(i*2)+1))
         icon_offset[i] += 1
   ## SPECIAL CASE: NEVER SHOW 0 ICONS. ALWAYS SHOW 1/4 ICON AT MINIMUM AS LONG AS HEALTH IS ABOVE 0
   ## TODO: weirdness when two types of health are small enough to sum together to be less than 1/4th of an icon. but that's a later problem tbh
   if sum > 0 and ( sum / points_per_icon ) < min_quarter:
      var icon_to_show = OVERHEALTH if health_value.max() == health_value[3] else WARD if health_value.max() == health_value[2] else ARMOR if health_value.max() == health_value[1] else HEARTS
      icon_map_array[icon_to_show].set_cell(Vector2i(0,0),1,Vector2i(randi_range(0,1),(icon_to_show*2)+1))

## Returns an int representing how many icons are currently needed to display the whole value. Partial icons are counted as full icons.[br]For example, a health value of 21 under ordinary settings would be represented by five full hearts and 1 quarter-heart, so the function will return 6.
func get_bar_size() -> int:
   var bar_size : float = 0
   for i in health_value:
      bar_size += i
   var bar_size_int = int( ceil( float ( bar_size / points_per_icon ) ) )
   return bar_size_int
