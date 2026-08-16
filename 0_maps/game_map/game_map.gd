extends Node3D
class_name GameMap

@onready var PRISMS_NODE : Node3D = $Prisms

# ===================== #
#    PLAYER SPAWNING    #
# ===================== #

signal force_player_location(pos : Vector3)

const LIBRARY_SPAWN_POS := Vector3(0,0,-150)

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

# =================== #
#    PRISM SPAWNING   #
# =================== #

const vertical_prism_offset := Vector3(0,1,0)

var new_prism_instance = preload("res://0_maps/assets/interactables/prism/simple_prism.tscn")

signal spawned_prism(contents : PackedByteArray)
signal updated_prism()
signal removed_prism(id: int)

var PrismList : Dictionary[int,Prism] = {}

func prism_destroyed_here(id : int):
   removed_prism.emit(id)
   PrismList.erase(id)
func prism_destroyed_from_network(id : int):
   var rem_prism : Prism = PrismList.get(id)
   PrismList.erase(id)
   rem_prism.force_destroy()

func spawn_natural_prism():
   pass

func spawn_player_prism_from_self(KO_pos : Vector3, pre_actives : Array[ActiveSpell], pre_passives : Array[PassiveSpell]):
   ## If there are no actives OR passives, return and don't bother spawning or sending anything
   ## (make sure not to pass empty slots ("null") as ActiveSpells)
   ## (also if we don't do the pre_passives -> passives, the array deletes itself when the original player's class is reset before the prism is opened)
   var actives : Array[ActiveSpell]
   var passives : Array[PassiveSpell]
   for i in pre_actives:
      if i is ActiveSpell: actives.append(i)
   for i in pre_passives:
      if i is PassiveSpell: passives.append(i)
   if actives.is_empty() and passives.is_empty(): return
   
   ## Basic Instantiation
   var KO_prism : Prism = new_prism_instance.instantiate()
   PRISMS_NODE.add_child(KO_prism)
   KO_prism.position = KO_pos + vertical_prism_offset
   KO_prism.PrismShape = KO_prism.determine_prism_shape()
   
   ## Spell Synchronization 
   KO_prism.load_spells_from_player(actives, passives)
   
   ## Set a new PrismID (used to sending prism_removal_data later)
   var new_prism_id : int = randi() % 100
   while PrismList.keys().has(new_prism_id):
      new_prism_id = randi() % 100
   KO_prism.set_prism_id(new_prism_id)
   
   ## Add to Prism list and connect signals
   PrismList.merge({new_prism_id:KO_prism})
   KO_prism.destroy_prism.connect(prism_destroyed_here)
   
   ## emit as PackedByteArray
   spawned_prism.emit(KO_prism.to_PackedByteArray())
func spawn_prism_from_network(prismdata : PackedByteArray):
   var new_prism : Prism = new_prism_instance.instantiate()
   ## I don't know a better way to do this, so i am creating a "phantom prism" from the PackedByteArray and then setting the instantiated prisms data to match
   var check_prism = Prism.from_PackedByteArray(prismdata)
   new_prism.PRISM_ID = check_prism.PRISM_ID
   new_prism.PrismShape = check_prism.PrismShape
   new_prism.is_player_prism = check_prism.is_player_prism
   new_prism.position = check_prism.position
   new_prism.ActiveSpellList = check_prism.ActiveSpellList
   new_prism.PassiveSpellList = check_prism.PassiveSpellList
   PRISMS_NODE.add_child(new_prism)
   PrismList.merge({new_prism.PRISM_ID:new_prism})
   new_prism.destroy_prism.connect(prism_destroyed_here)
