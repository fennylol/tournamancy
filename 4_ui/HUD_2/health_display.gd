extends Node2D

@export var health_value : Array[float] = [ 20.0 , 0.0 , 0.0 , 0.0 ]:
	get:
		return health_value
	set(value):
		#_update_display(value)             <- THIS IS BEING CALLED BEFORE THE _READY FUNCTION, WHICH BREAKS IT
		print("Updated Health to ",value)
## HEARTS, SHIELDS, WARDS, OVERHEALTH

@export var points_per_heart : float = 4.0
var min_quarter : float = 0.125
var min_half    : float = 0.375
var min_3fourth : float = 0.625
var min_full    : float = 0.875

@onready var hearts_map = $Color_1
@onready var health_text = $Control/HealthText

func _ready():
	calculate_partials()

func _update_display(value : Array[float]):
	## UPDATE HEALTH_TEXT TO THE SUM OF ALL VALUES
	var sum = 0.0
	for i in value:
		sum += i
	health_text.text = str(sum)
	
	## UPDATE DISPLAY
	## HEARTS
	var hearts_amt = floor( value[0] / points_per_heart )
	var hearts_rem = ( value[0] / points_per_heart ) - hearts_amt
	var heart_offset = hearts_amt
	hearts_map.clear()
	## ADD ALL NORMAL HEARTS
	for i in range(hearts_amt):
		hearts_map.set_cell(Vector2i(i,0),1,Vector2i(randi_range(0,5),0))
	## ADD ONE EXTRA HEART IF THE REMAINDER IS HIGH ENOUGH
	if hearts_rem >= min_full: 
		hearts_map.set_cell(Vector2i(heart_offset,0),1,Vector2i(randi_range(0,5),0))
		heart_offset += 1
	## ELSE ADD A FRACTIONAL HEART, BASED ON AMOUNT REMAINING
	## SPECIAL CASE: NEVER SHOW 0 HEARTS. ALWAYS SHOW 1/4 HEART AT MINIMUM AS LONG AS HEALTH IS ABOVE 0
	elif hearts_rem >= min_quarter: 
		var fraction = 2 if hearts_rem >= min_3fourth else 1 if hearts_rem >= min_half else 0
		if value[0] > 0 and value[0] < ( 1 / points_per_heart ): fraction = 0
		hearts_map.set_cell(Vector2i(heart_offset,0),1,Vector2i((fraction*2)+randi_range(0,1),1))
		heart_offset += 1

func calculate_partials():
	## the current texture atlas has only 3 icons: quarter, half, three-quarter, and full
	## calculate the range for each icon based on points_per_heart
	var step_size : float = 1 / ( points_per_heart * 2 )
	min_quarter = step_size
	min_half    = step_size * 3
	min_3fourth = step_size * 5
	min_full    = step_size * 7
