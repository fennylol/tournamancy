@tool
extends Interactable
class_name ClassBook

@onready var book_box : MeshInstance3D = $MeshInstance3D
var meshalbedo

@export var ClassID: ClassData.ClassIDs = ClassData.ClassIDs.NakedManChallenge
@export var book_color : Color = Color.WHITE:
   set(value):
      book_color = value
      if book_box:
         book_box.material_override = StandardMaterial3D.new()
         book_box.material_override.albedo_color = book_color

const BOOK_MOVE_SPEED : float = 0.5
const BOOK_PULL_TIME : float = 2.5
const BOOK_WAIT_TIME : float = 2.0
const BOOK_PUSH_TIME : float = 0.5


var pull_time: float = 100.0

func _ready() -> void:
   if book_box:
      book_box.material_override = StandardMaterial3D.new()
      book_box.material_override.albedo_color = book_color

func _process(delta: float) -> void:
   if pull_time > 0.0: pull_time -= delta
   if pull_time <= 0.0: pass
   elif pull_time <= BOOK_PUSH_TIME: book_box.position.z -= delta * BOOK_MOVE_SPEED
   elif pull_time <= BOOK_WAIT_TIME: pass
   elif pull_time <= BOOK_PULL_TIME: book_box.position.z += delta * BOOK_MOVE_SPEED

func _on_interact(interacter: Player) -> void:
   super._on_interact(interacter)
   interacter.SpellBook.adopt_class(ClassID)
   interacter.update_HUD_icons()
   
   pull_time = BOOK_PULL_TIME
