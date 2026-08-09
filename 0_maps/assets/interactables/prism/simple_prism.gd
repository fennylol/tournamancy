extends Interactable
class_name Prism

const ROTATE_SPEED  : float = 0.6
const BOBBING_SPEED : float = 1.3
const BOBBING_DEPTH : float = 0.1

var MAXIMUM_CRACK_COUNT : int = 1

@onready var PRISMBODY : Node3D = $PrismBody

@export_range(0,4) var PrismShape : int = 0
enum PrismShapes { tetrahedron , cube , octahedron , dodecahedron , icosahedron }

var time : float = 0.0
var crack_count : int = 0

func _ready() -> void:
   for i in range(5):
      if PrismShape == i: PRISMBODY.get_child(i).visible = true
      else: PRISMBODY.get_child(i).visible = false

func _process(delta: float) -> void:
   time += delta
   PRISMBODY.rotate(Vector3.UP, delta * ROTATE_SPEED)
   PRISMBODY.position.y = -0.25 + (sin(time * BOBBING_SPEED) * BOBBING_DEPTH)

func _on_interact(interacter: Player) -> void:
   super._on_interact(interacter)
   if crack_count >= MAXIMUM_CRACK_COUNT: return
   crack_count += 1
   interacter.open_prism(self)
