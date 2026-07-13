extends Node2D

@onready var hearts_map = $Color_1
@onready var health_text = $Control/HealthText

## HEARTS, SHIELDS, WARDS, OVERHEALTH
@export var health_value : Array[float] = [ 20.0 , 0.0 , 0.0 , 0.0 ]
@export var points_per_heart : float = 4.0
var min_quarter : float = 0.125
var min_half    : float = 0.375
var min_3fourth : float = 0.625
var min_full    : float = 0.875
var text_decimal_places = 2

func _ready():
   calculate_partials()

func _process(delta: float):
   ## PRESS "+" TO DEMO TAKING DAMAGE
   if Input.is_action_just_released("take_damage"): _update_display([-randf_range(0.0,2.0)], true)

func _update_display(value : Array[float], add : bool = false):
   ## DIFFERENTIATE BETWEEN SET AND ADD
   if add:
      for i in range(value.size()):
         health_value[i] += value[i]
   else:
      health_value = value
   
   ## UPDATE HEALTH_TEXT TO THE SUM OF ALL VALUES
   var sum = 0.0
   for i in range(health_value.size()):
      sum += health_value[i]
   if sum < 0:
      health_text.text = "0.0 DEAD"
   else:
      var rounded_sum = round(sum*pow(10,text_decimal_places))/pow(10,text_decimal_places)
      if rounded_sum < 0.0 and sum > 0.0: rounded_sum = pow(10,-text_decimal_places)
      health_text.text = str(rounded_sum)
   
   ## UPDATE DISPLAY
   ## HEARTS
   var hearts_amt = floor( health_value[0] / points_per_heart )
   var hearts_rem = ( health_value[0] / points_per_heart ) - hearts_amt
   var heart_offset = hearts_amt
   hearts_map.clear()
   if health_value[0] <= 0: return
   ## ADD ALL NORMAL HEARTS
   for i in range(hearts_amt):
      hearts_map.set_cell(Vector2i(i,0),1,Vector2i(randi_range(0,5),0))
   ## ADD ONE EXTRA HEART IF THE REMAINDER IS HIGH ENOUGH
   if hearts_rem >= min_full: 
      hearts_map.set_cell(Vector2i(heart_offset,0),1,Vector2i(randi_range(0,5),0))
      heart_offset += 1
   ## ELSE ADD A FRACTIONAL HEART, BASED ON AMOUNT REMAINING
   elif hearts_rem >= min_quarter: 
      var fraction = 2 if hearts_rem >= min_3fourth else 1 if hearts_rem >= min_half else 0
      hearts_map.set_cell(Vector2i(heart_offset,0),1,Vector2i((fraction*2)+randi_range(0,1),1))
      heart_offset += 1
   ## SPECIAL CASE: NEVER SHOW 0 HEARTS. ALWAYS SHOW 1/4 HEART AT MINIMUM AS LONG AS HEALTH IS ABOVE 0
   elif hearts_amt == 0 and hearts_rem > 0.0 and hearts_rem < ( 1.0 / points_per_heart ):
      hearts_map.set_cell(Vector2i(heart_offset,0),1,Vector2i(randi_range(0,1),1))
      heart_offset += 1

func calculate_partials():
   ## the current texture atlas has only 3 icons: quarter, half, three-quarter, and full
   ## calculate the range for each icon based on points_per_heart
   var step_size : float = 1 / ( points_per_heart * 2 )
   min_quarter = step_size
   min_half    = step_size * 3
   min_3fourth = step_size * 5
   min_full    = step_size * 7
