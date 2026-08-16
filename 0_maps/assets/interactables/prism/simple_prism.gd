extends Interactable
class_name Prism

var PRISM_ID : int = 0
@onready var PRISMBODY : Node3D      = $PrismBody
@onready var OMNILIGHT : OmniLight3D = $OmniLight3D
@export_range(0,4) var PrismShape : int = 0
enum PrismShapes { tetrahedron , cube , octahedron , dodecahedron , icosahedron }

var is_player_prism : bool = false
var timeout : float = 0.0

signal update_prism(id: int)
signal destroy_prism(id : int)

const PRISM_ID_SIZE           : int = 1
const PRISM_SHAPE_SIZE        : int = 1
const PRISM_CRACK_CT_SIZE     : int = 1
const PRISM_LOC_SIZE          : int = 12
const PRISM_ACLS_SIZE         : int = 2
const PRISM_PSLS_SIZE         : int = 2
const PRISM_ACTIVESPELL_SIZE  : int = 2
const PRISM_PASSIVESPELL_SIZE : int = 4

# ========== #
#   basics   #
# ========== #

func _ready() -> void:
   _set_shape()

func _process(delta: float) -> void:
   _process_animation(delta)
   timeout += delta
   match is_player_prism:
      true: if timeout >= SettingsManager.match_settings.PLAYER_PRISM_DESPAWN_COOLDOWN: destroy_self_if_alone()
      false: if timeout >= SettingsManager.match_settings.NATURAL_PRISM_DESPAWN_COOLDOWN: destroy_self_if_alone()

func set_prism_id(id : int): PRISM_ID = id
func get_prism_id() -> int: return PRISM_ID
func determine_prism_shape() -> int:
   ## TODO: make the shape mean something
   PrismShape = randi_range(0,4)
   _set_shape()
   return PrismShape

# =============== #
#   interaction   #
# =============== #

var crack_count : int = 0

func _on_interact(interacter: Player) -> void:
   super._on_interact(interacter)
   if crack_count >= SettingsManager.match_settings.PRISM_CRACK_COUNT: return
   crack_count += 1
   interacter.open_prism(self)
## This function is called when the player closes the PrismMenu after cancelling or selecting spells. If the prism has been opened too many times, it is destroyed.
func destroy_self_if_limit(): 
   if crack_count >= SettingsManager.match_settings.PRISM_CRACK_COUNT: 
      destroy_prism.emit(PRISM_ID)
      self.queue_free()
## This function is called from this script's _process() function if the prism has been extant for too long (determined by match settings).
func destroy_self_if_alone():
   ## CHECK TO SEE IF A PLAYER HAS THE PRISM OPEN?
   destroy_prism.emit(PRISM_ID)
   self.queue_free()
## This function is called by GameMap when this prism was destroyed by another peer and the signal to destroy it was recieved over the network.
func force_destroy():
   self.queue_free()

# ================ #
#  spell handling  #
# ================ #

var ActiveSpellList : Array[ActiveSpell] = []
var PassiveSpellList : Array[PassiveSpell] = []

func clear_spells():
   ActiveSpellList.clear()
   PassiveSpellList.clear()
func load_spells_from_world():
   clear_spells()
   is_player_prism = false
   ActiveSpellList = SettingsManager.match_settings.get_world_prism_actives()
   PassiveSpellList = SettingsManager.match_settings.get_world_prism_passives()
func load_spells_from_player(actives : Array[ActiveSpell], passives : Array[PassiveSpell]):
   clear_spells()
   is_player_prism = true
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

func _set_shape() -> void:
   for i in range(5):
      if PrismShape == i: PRISMBODY.get_child(i).visible = true
      else: PRISMBODY.get_child(i).visible = false
func _process_animation(delta: float) -> void:
   time += delta
   PRISMBODY.rotate(Vector3.UP, delta * ROTATE_SPEED * ( 1 / ( float(PrismShape) + 1 ) ) )
   PRISMBODY.position.y += (sin(time * BOBBING_SPEED) * BOBBING_DEPTH)
   OMNILIGHT.position.y += (sin(time * BOBBING_SPEED) * BOBBING_DEPTH)

# ================= #
#   network bytes   #
# ================= #

## Returns a PackedByteArray containing all the necessary data in the Prism to be sent over the network. Can be unpacked using Prism.from_PackedByteArray().
func to_PackedByteArray() -> PackedByteArray:
   var data : PackedByteArray = []
   var active_list_size : int = ActiveSpellList.size()
   var passive_list_size : int = PassiveSpellList.size()
   var shape_and_player = PrismShape + 64 if is_player_prism else PrismShape
   data.resize( PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + PRISM_LOC_SIZE + PRISM_ACLS_SIZE + PRISM_PSLS_SIZE + ( PRISM_ACTIVESPELL_SIZE * active_list_size ) + ( PRISM_PASSIVESPELL_SIZE * passive_list_size ) )
   data.encode_u8    (0                                                                                        , PRISM_ID)
   data.encode_u8    (PRISM_ID_SIZE                                                                            , shape_and_player)
   data.encode_u8    (PRISM_ID_SIZE + PRISM_SHAPE_SIZE                                                         , crack_count)
   data.encode_float (PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE                                   , position.x)
   data.encode_float (PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + 4                               , position.y)
   data.encode_float (PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + 8                               , position.z)
   data.encode_u16   (PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + PRISM_LOC_SIZE                  , active_list_size)
   data.encode_u16   (PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + PRISM_LOC_SIZE + PRISM_ACLS_SIZE, passive_list_size)

   for i in range(active_list_size):
      if active_list_size == 0: continue
      var encoded_spell_offset : int = PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + PRISM_LOC_SIZE + PRISM_ACLS_SIZE + PRISM_PSLS_SIZE + ( PRISM_ACTIVESPELL_SIZE * i )
      var encoded_spell_id     : int = ActiveSpellList[i].SpellID
      data.encode_s16(encoded_spell_offset, encoded_spell_id)
   for i in range(passive_list_size):
      if passive_list_size == 0: continue
      var encoded_spell_offset : int = PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + PRISM_LOC_SIZE + PRISM_ACLS_SIZE + PRISM_PSLS_SIZE + ( PRISM_ACTIVESPELL_SIZE * active_list_size ) + ( PRISM_PASSIVESPELL_SIZE * i )
      var encoded_spell_id     : int = PassiveSpellList[i].SpellID
      var encoded_spell_stacks : int = PassiveSpellList[i].Stacks
      data.encode_s16(encoded_spell_offset, encoded_spell_id)
      data.encode_s16(encoded_spell_offset + 2, encoded_spell_stacks)
   
   return data
## From a given PackedByteArray - packed using Prism.to_PackedByteArray() - constructs and returns a valid Prism with all the same data.
static func from_PackedByteArray(data : PackedByteArray) -> Prism:
   var new_prism : Prism = Prism.new()
   new_prism.PRISM_ID            = data.decode_u8    (0)
   var shape_and_player    : int = data.decode_u8    (PRISM_ID_SIZE)
   new_prism.PrismShape = shape_and_player if shape_and_player < 64 else shape_and_player - 64
   new_prism.is_player_prism = true if shape_and_player >= 64 else false
   new_prism.crack_count         = data.decode_u8    (PRISM_ID_SIZE + PRISM_SHAPE_SIZE)
   new_prism.position.x          = data.decode_float (PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE)
   new_prism.position.y          = data.decode_float (PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + 4)
   new_prism.position.z          = data.decode_float (PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + 8)
   
   if new_prism.is_player_prism:
      var active_list_size       : int = data.decode_u16(PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + PRISM_LOC_SIZE)
      var passive_list_size      : int = data.decode_u16(PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + PRISM_LOC_SIZE + PRISM_ACLS_SIZE)
      var new_active_spell_list  : Array[ActiveSpell] = []
      var new_passive_spell_list : Array[PassiveSpell] = []
      new_active_spell_list.resize(active_list_size)
      new_passive_spell_list.resize(passive_list_size)
      var contents_data : PackedByteArray = data.slice  (PRISM_ID_SIZE + PRISM_SHAPE_SIZE + PRISM_CRACK_CT_SIZE + PRISM_LOC_SIZE + PRISM_ACLS_SIZE + PRISM_PSLS_SIZE)
      for i in range(active_list_size):
         var new_active_id : int = contents_data.decode_s16(0)
         var new_spell : ActiveSpell = ActiveSpell.new(new_active_id)
         new_active_spell_list[i] = new_spell
         contents_data = contents_data.slice(PRISM_ACTIVESPELL_SIZE)
      for i in range(passive_list_size):
         var new_passive_id : int = contents_data.decode_s16(0)
         var new_passive_stacks : int = contents_data.decode_s16(2)
         var new_spell : PassiveSpell = PassiveSpell.new(new_passive_stacks, new_passive_id)
         new_passive_spell_list[i] = new_spell
         contents_data = contents_data.slice(PRISM_PASSIVESPELL_SIZE)
      if not contents_data.is_empty() : printerr("Loaded Prism PackedByteArray still has data remaining after loading. See simple_prism.gd from_PackedByteArray() function.")
      new_prism.load_spells_from_player(new_active_spell_list,new_passive_spell_list)
   
   else:
      new_prism.load_spells_from_world()
   
   return new_prism
