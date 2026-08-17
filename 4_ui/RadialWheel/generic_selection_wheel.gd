extends Control
class_name SelectionWheel

@onready var wheel_node = $CenterContainer/the_wheel
@onready var texture_node = $CenterContainer/textures
@onready var action_node = $actions

#var item_texture_scene = preload("res://items_and_materials/inventory_item_texture.tscn")

var PLAYER_CHARACTER : Player

var time_since_press = 0

var wheel_scale     : float = 0.4
var wheel_thickness : float = 100.0
var wheel_size      : int
var outer_rim_size  : int
var inner_rim_size  : int
const wheel_draw_precision = 10 #22.5
const section_offset = 10

var wheel_contents : Array[Polygon2D] = []
var wheel_vector_dict = {}
var selection_vector = Vector2.ZERO
var selection : int = -1

var window_centerpoint := Vector2.ZERO
var mouse_location     := Vector2.ZERO
var cursor_location    := Vector2.ZERO

## Setup and Teardown
func _on_visibility_changed():
   if self.visible:
      window_centerpoint = get_viewport_rect().size / 2
      mouse_location = window_centerpoint
      cursor_location = window_centerpoint
      ## SET CIRCLE SIZE
      var SCREENSIZE = get_viewport_rect().size
      var small_side = SCREENSIZE.y / 2 if SCREENSIZE.y < SCREENSIZE.x else SCREENSIZE.x / 2
      wheel_size = small_side * wheel_scale
      @warning_ignore("narrowing_conversion")
      outer_rim_size = wheel_size + ( wheel_thickness / 2 )
      @warning_ignore("narrowing_conversion")
      inner_rim_size = wheel_size - ( wheel_thickness / 2 )
   else:
      for i in wheel_node.get_children():
         i.queue_free()
      wheel_contents.clear()
      wheel_vector_dict.clear()

func _input(event):
   if event is InputEventMouseMotion:
      mouse_location.x += event.relative.x * SettingsManager.personal_settings.MOUSE_SENSITIVITY
      mouse_location.y += event.relative.y * SettingsManager.personal_settings.MOUSE_SENSITIVITY
      if ( mouse_location - window_centerpoint ).length() > inner_rim_size: 
         mouse_location = window_centerpoint + ( ( mouse_location - window_centerpoint ).normalized() * inner_rim_size )

func _process(_delta):
   var joystick_selection_input = Input.get_vector("camera_left", "camera_right", "camera_down", "camera_up") * -1
   ## modify based on SettingsManager.personal_settings.INVERTAXIS both X and Y
   if joystick_selection_input == Vector2.ZERO:
      cursor_location = mouse_location
   else:
      mouse_location = window_centerpoint
      cursor_location = window_centerpoint + ( joystick_selection_input * inner_rim_size )
   
   selection_vector = Vector2( ( cursor_location.x - window_centerpoint.x) , -( cursor_location.y - window_centerpoint.y )).normalized()
   if selection_vector != Vector2.ZERO:
      var selection_array = []
      for i in wheel_vector_dict.keys():
         var test_dist = abs(selection_vector.angle_to(wheel_vector_dict[i]))
         selection_array.append(test_dist)
      selection = selection_array.find(selection_array.min())
   
   for i in wheel_contents.size():
      if i == selection:
         wheel_contents[i].color = Color.RED
      else:
         wheel_contents[i].color = Color.WHITE
   
   queue_redraw()

func _draw():
   draw_circle(cursor_location,10,Color.WHITE)
   draw_line(window_centerpoint, cursor_location, Color.WHITE)

func generate_wheel(contents : Array, count : int = -1):
   var num = contents.size() if count == -1 else count
   
   ## DETERMINE SLICE LINES
   var right_slice_in_deg = 360.0 / (num * 2)
   var left_slice_in_deg = 360.0 - right_slice_in_deg
   var rim_points = (right_slice_in_deg * 2) / wheel_draw_precision
   var left_slice_in_rad = deg_to_rad(left_slice_in_deg)
   var right_slice_in_rad = deg_to_rad(right_slice_in_deg)
   
   ## CREATE POINT ARRAY FOR A SINGLE SLICE
   var points = PackedVector2Array()
   points.push_back(Vector2(cos(left_slice_in_rad), sin(left_slice_in_rad)) * outer_rim_size)
   for i in int(rim_points):
      var point = deg_to_rad(left_slice_in_deg + (i * wheel_draw_precision))
      points.push_back(Vector2(cos(point), sin(point)) * outer_rim_size)
   points.push_back(Vector2(cos(right_slice_in_rad), sin(right_slice_in_rad)) * outer_rim_size)
   points.push_back(Vector2(cos(right_slice_in_rad), sin(right_slice_in_rad)) * inner_rim_size)
   for i in int(rim_points):
      var point = deg_to_rad(right_slice_in_deg - (i * wheel_draw_precision))
      points.push_back(Vector2(cos(point), sin(point)) * inner_rim_size)
   points.push_back(Vector2(cos(left_slice_in_rad), sin(left_slice_in_rad)) * inner_rim_size)
   
   for i in range(num):
      ## CREATE A NEW SLICE AND POSITION IT
      var new_item := Polygon2D.new()
      wheel_node.add_child(new_item)
      @warning_ignore("integer_division")
      var new_pos := Vector2.UP.rotated(deg_to_rad(i * 360 / num))
      new_item.position = new_pos * section_offset
      new_item.rotation = (3 * PI / 2) + (i * PI * 2 / num)
      new_item.polygon = points
      new_item.name = str(i)
      wheel_contents.append(new_item)
      
      ## ADD REFERENCE TO WHEEL DICTIONARY
      @warning_ignore("integer_division")
      var new_angle = deg_to_rad(90 - (( 360 / num ) * i))
      var new_vector = Vector2.RIGHT.rotated(new_angle)
      var new_wheel_dict_entry = {i:new_vector}
      wheel_vector_dict.merge(new_wheel_dict_entry)
      
      ## ADD TEXTURE SPRITE
      # skip if a blank array was generated
      if count != -1: continue
      
      #var new_sprite = item_texture_scene.instantiate()
      #texture_node.add_child(new_sprite)
      #new_sprite.position = new_pos * ( inner_rim_size + outer_rim_size ) / 2
      #var set_texture = contents[i] if contents[i] is ItemTexture else ItemTexture.new()
      #new_sprite.set_item_texture(set_texture)
 
