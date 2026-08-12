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
func destroy_self(): self.queue_free()

# ================ #
#  spell handling  #
# ================ #

var ActiveSpellList : Array[SpellData.ActiveSpellIDs] = [0,1,2,3,4]
var PassiveSpellList : Array[SpellData.PassiveSpellIDs] = [SpellData.PassiveSpellIDs.Heart,SpellData.PassiveSpellIDs.Damage,SpellData.PassiveSpellIDs.Speed,SpellData.PassiveSpellIDs.Sprint,SpellData.PassiveSpellIDs.Jump,SpellData.PassiveSpellIDs.Gravity,SpellData.PassiveSpellIDs.MoonJump]
var PassiveSpellStacks : Array[int] = [4,3,1,1,2,1,1]

func load_spells_from_world():
   pass
func load_spells_from_player(actives : Array[SpellData.ActiveSpellIDs], passives : Array[SpellData.PassiveSpellIDs]):
   ActiveSpellList = actives
   PassiveSpellList = passives
func get_active_spells() -> Array[SpellData.ActiveSpellIDs]: return ActiveSpellList
func get_passive_spells() -> Array[SpellData.PassiveSpellIDs]: return PassiveSpellList
func get_passive_stacks() -> Array[int]: return PassiveSpellStacks

# ============= #
#   animation   #
# ============= #

const ROTATE_SPEED  : float = 0.6
const BOBBING_SPEED : float = 1.3
const BOBBING_DEPTH : float = 0.1
var time : float = 0.0

func _ready() -> void:
   for i in range(5):
      if PrismShape == i: PRISMBODY.get_child(i).visible = true
      else: PRISMBODY.get_child(i).visible = false

func _process(delta: float) -> void:
   time += delta
   PRISMBODY.rotate(Vector3.UP, delta * ROTATE_SPEED)
   PRISMBODY.position.y = -0.25 + (sin(time * BOBBING_SPEED) * BOBBING_DEPTH)
