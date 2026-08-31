extends Familiar
class_name PolytopePartyBlock

const MONOTOPE_MESH: Mesh = preload("res://2_spells/actives/PolytopeParty/familiar/monotope_mesh.tres")
const MAX_LIFE_TIME: float = 10.0
const MONOTOPE_SIZE: float = 2.5
const SPEED        : float = 5
var BlockType: PolytopePartySpell.BlockTypes
var TargetY: float

func _init(owner_id: int, block_type: PolytopePartySpell.BlockTypes, block_pos: Vector3, block_rot: float) -> void: 
   super(owner_id, MAX_LIFE_TIME)
   name = str(owner_id) + "__polytope__" + str(randi())
   BlockType  = block_type
   position   = block_pos
   TargetY    = block_pos.y
   rotation.y = block_rot
   
   var primary_color  : Color = SettingsManager.peer_settings[owner_id].primary_color   if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.PRIMARY_COLOR
   var secondary_color: Color = SettingsManager.peer_settings[owner_id].secondary_color if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.SECONDARY_COLOR
   
   var monotope_mat_0 := StandardMaterial3D.new()
   monotope_mat_0.albedo_color = primary_color
   
   var monotope_mat_1 := StandardMaterial3D.new()
   monotope_mat_1.albedo_color = secondary_color
   
   var monotope   := MeshInstance3D.new()
   monotope.scale *= MONOTOPE_SIZE 
   monotope.mesh   = MONOTOPE_MESH
   monotope.set_surface_override_material(0, monotope_mat_0)
   
   var tile_1 := MeshInstance3D.new()
   tile_1.mesh = MONOTOPE_MESH
   tile_1.set_surface_override_material(0, monotope_mat_1)
   var rb_1    := StaticBody3D.new()
   var coll_1  := CollisionShape3D.new()
   coll_1.shape = BoxShape3D.new()
   rb_1.add_child(coll_1)
   tile_1.add_child(rb_1)
   
   var tile_2 := MeshInstance3D.new()
   tile_2.mesh = MONOTOPE_MESH
   tile_2.set_surface_override_material(0, monotope_mat_0)
   var rb_2    := StaticBody3D.new()
   var coll_2  := CollisionShape3D.new()
   coll_2.shape = BoxShape3D.new()
   rb_2.add_child(coll_2)
   tile_2.add_child(rb_2)
   
   var tile_3 := MeshInstance3D.new()
   tile_3.mesh = MONOTOPE_MESH
   tile_3.set_surface_override_material(0, monotope_mat_1)
   var rb_3    := StaticBody3D.new()
   var coll_3  := CollisionShape3D.new()
   coll_3.shape = BoxShape3D.new()
   rb_3.add_child(coll_3)
   tile_3.add_child(rb_3)
   
   match BlockType:
      PolytopePartySpell.BlockTypes.I:
         tile_1.position = Vector3(0, -1, 0)
         tile_2.position = Vector3(0, -2, 0)
         tile_3.position = Vector3(0, -3, 0)
         TargetY += 4 * MONOTOPE_SIZE
      PolytopePartySpell.BlockTypes.L: 
         tile_1.position = Vector3(0, -1, 0)
         tile_2.position = Vector3(0, -2, 0)
         tile_3.position = Vector3(0, -2, 1)
         TargetY += 3 * MONOTOPE_SIZE
      PolytopePartySpell.BlockTypes.O: 
         tile_1.position = Vector3(0, -1, 0)
         tile_2.position = Vector3(0, -1, 1)
         tile_3.position = Vector3(0,  0, 1)
         TargetY += 2 * MONOTOPE_SIZE
      PolytopePartySpell.BlockTypes.S: 
         tile_1.position = Vector3(0, -1, 0)
         tile_2.position = Vector3(0, -1, 1)
         tile_3.position = Vector3(0, -2, 1)
         TargetY += 3 * MONOTOPE_SIZE
      PolytopePartySpell.BlockTypes.T: 
         tile_1.position = Vector3(0, -1, 0)
         tile_2.position = Vector3(0, -2, 0)
         tile_3.position = Vector3(0, -1, 1)
         TargetY += 3 * MONOTOPE_SIZE
         tile_3.set_surface_override_material(0, monotope_mat_0)
   
   var rb_0    := StaticBody3D.new()
   var coll_0  := CollisionShape3D.new()
   coll_0.shape = BoxShape3D.new()
   rb_0.add_child(coll_0)
   monotope.add_child(rb_0)
   monotope.add_child(tile_1)
   monotope.add_child(tile_2)
   monotope.add_child(tile_3)
   add_child(monotope)
      
func reduce_to_byte_array() -> PackedByteArray: 
   var data: PackedByteArray = []
   data.resize(17)
   data.encode_u8(0, BlockType)
   data.encode_float(1, position.x)
   data.encode_float(5, position.y)
   data.encode_float(9, position.z)
   data.encode_float(13, rotation.y)
   self.queue_free()
   return data

static func create_from_byte_array(owner_id: int, data: PackedByteArray) -> Familiar: 
   var type: PolytopePartySpell.BlockTypes = data.decode_u8(0) as PolytopePartySpell.BlockTypes
   var block_pos: Vector3
   block_pos.x = data.decode_float(1)
   block_pos.y = data.decode_float(5)
   block_pos.z = data.decode_float(9)
   var block_rot: float = data.decode_float(13)
   return PolytopePartyBlock.new(owner_id, type, block_pos, block_rot)


func _process(delta: float) -> void:
   super(delta)
   position.y = move_toward(position.y, TargetY, delta * SPEED * (4 if BlockType == PolytopePartySpell.BlockTypes.I else 2 if BlockType == PolytopePartySpell.BlockTypes.O else 3))
