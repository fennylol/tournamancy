extends Interactable
class_name Prism

@onready var PRISMBODY : Node3D = $PrismBody
@export_range(0,4) var PrismShape : int = 0
enum PrismShapes { tetrahedron , cube , octahedron , dodecahedron , icosahedron }

# =============== #
#   interaction   #
# =============== #

var crack_count : int = 0

func _on_interact(interacter: Player) -> void:
   super._on_interact(interacter)
   if crack_count >= SettingsManager.match_settings.PRISM_CRACK_COUNT: return
   crack_count += 1
   interacter.open_prism(self)
func destroy_self_if_limit(): 
   if crack_count >= SettingsManager.match_settings.PRISM_CRACK_COUNT: self.queue_free()

# ================ #
#  spell handling  #
# ================ #

var ActiveSpellList : Array[ActiveSpell] = []
var PassiveSpellList : Array[PassiveSpell] = []

func clear_spells():
   ActiveSpellList.clear()
   PassiveSpellList.clear()
func load_spells_from_world():
   ActiveSpellList = SettingsManager.match_settings.get_world_prism_actives()
   PassiveSpellList = SettingsManager.match_settings.get_world_prism_passives()
func load_spells_from_player(actives : Array[ActiveSpell], passives : Array[PassiveSpell]):
   ActiveSpellList = actives
   PassiveSpellList = passives
func get_active_spells() -> Array[ActiveSpell]: return ActiveSpellList
func get_passive_spells() -> Array[PassiveSpell]: return PassiveSpellList

# ============= #
#   animation   #
# ============= #

const ROTATE_SPEED  : float = 1.0
const BOBBING_SPEED : float = 1.3
const BOBBING_DEPTH : float = 0.006
var time : float = 0.0

func _ready() -> void:
   clear_spells()
   load_spells_from_world()
   for i in range(5):
      if PrismShape == i: PRISMBODY.get_child(i).visible = true
      else: PRISMBODY.get_child(i).visible = false

func _process(delta: float) -> void:
   time += delta
   PRISMBODY.rotate(Vector3.UP, delta * ROTATE_SPEED * ( 1 / ( float(PrismShape) + 1 ) ) )
   PRISMBODY.position.y += (sin(time * BOBBING_SPEED) * BOBBING_DEPTH)
