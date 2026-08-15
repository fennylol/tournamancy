extends Node3D
class_name GameMap

const LIBRARY_SPAWN_POS := Vector3(0,0,-150)

signal force_player_location(pos : Vector3)

enum DragPoints {NONE, FLY, HOVER, LANDING}
var dragging_towards : DragPoints = DragPoints.NONE
const DRAGSPEED : float = 0.20
const FLY_AND_HOVER_POINT : Vector3 = Vector3(0,100,-10)
const HOVERTIME : float = 0.5
var drag_player_from : Vector3 = Vector3.ZERO
var chosen_spawn_point := Vector3.ZERO
var dragtime : float = 0.0

func _physics_process(delta: float) -> void:
   match dragging_towards:
      DragPoints.NONE: pass
      DragPoints.FLY:
         dragtime += delta * DRAGSPEED
         var new_pos: Vector3 = drag_player_from.slerp(FLY_AND_HOVER_POINT, ease(dragtime,-3))
         force_player_location.emit(new_pos)
         var player_current_pos : Vector3 = get_parent().get_parent().get_player_position()
         if (player_current_pos - FLY_AND_HOVER_POINT).length() <= 1.0: 
            dragtime = 0.0
            dragging_towards = DragPoints.HOVER
      DragPoints.HOVER:
         dragtime += delta
         force_player_location.emit(FLY_AND_HOVER_POINT)
         if dragtime >= HOVERTIME:
            dragtime = 0.0
            dragging_towards = DragPoints.LANDING
      DragPoints.LANDING:
         if chosen_spawn_point == Vector3.ZERO: chosen_spawn_point = _find_player_spawn_point()
         dragtime += delta * DRAGSPEED
         var new_pos: Vector3 = FLY_AND_HOVER_POINT.slerp(chosen_spawn_point, ease(dragtime,-3))
         force_player_location.emit(new_pos)
         var player_current_pos : Vector3 = get_parent().get_parent().get_player_position()
         if (player_current_pos - chosen_spawn_point).length() <= 1.0: 
            dragtime = 0.0
            chosen_spawn_point = Vector3.ZERO
            dragging_towards = DragPoints.NONE

## Searches through available points from SettingsManager.match_settings and returns the best available spawn location as a Vector3
func _find_player_spawn_point() -> Vector3:
   var return_pos := Vector3.ZERO
   match SettingsManager.match_settings.PLAYER_SPAWN_LOCATION:
      SettingsManager.match_settings.PlayerSpawnLocationOptions.any: pass
      SettingsManager.match_settings.PlayerSpawnLocationOptions.list:
         return_pos = SettingsManager.match_settings.PLAYER_SPAWN_LOCATION_LIST.pick_random()
      SettingsManager.match_settings.PlayerSpawnLocationOptions.edge: pass
   return return_pos

func _on_exit_window_body_entered(body: Node3D) -> void:
   if body is Player:
      print("exited")
      drag_player_from = body.position
      dragging_towards = DragPoints.FLY
      dragtime = 0.0

func get_library_spawn_pos() -> Vector3: return LIBRARY_SPAWN_POS + Vector3(randf(), 0, randf())
