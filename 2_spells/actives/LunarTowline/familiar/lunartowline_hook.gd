extends Familiar
class_name LunarTowline_Hook

# a failsafe in seconds. self destructs at end.
const MAX_LIFE_TIME: float = 120.0

const SPEED: float = 15.0
const GRAVITY: float = 0.25
var Velocity: Vector3

var hooked_id : int = 0
var HOOK_OWNER  : Node3D ## can be either a Player or a Dummy
var HOOK_TARGET : Node3D ## can be either a Player or a Dummy

var mesh_instance := MeshInstance3D.new()

func _init(owner_id: int, projectile_pos: Vector3, projectile_velocity: Vector3) -> void:
   super(owner_id, MAX_LIFE_TIME)
   name = str(owner_id) + "__lunar_towline_hook__" + str(randi())
   position = projectile_pos
   Velocity = projectile_velocity
   #var primary_color  : Color = SettingsManager.peer_settings[owner_id].primary_color   if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.PRIMARY_COLOR
   #var secondary_color: Color = SettingsManager.peer_settings[owner_id].secondary_color if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.SECONDARY_COLOR
   
   add_child(mesh_instance)
   mesh_instance.mesh = SphereMesh.new()
   mesh_instance.mesh.radius = 0.1
   mesh_instance.mesh.height = 0.2
   var area := Area3D.new()
   add_child(area)
   var collisionshape := CollisionShape3D.new()
   area.add_child(collisionshape)
   collisionshape.shape = SphereShape3D.new()
   collisionshape.shape.radius = 4.0
   
   area.collision_layer = 8
   area.set_collision_mask_value(3, true)
   area.body_entered.connect(_on_body_entered)

func reduce_to_byte_array() -> PackedByteArray: 
   var data: PackedByteArray = []
   data.resize(4 * 8)
   data.encode_float( 0, position.x)
   data.encode_float( 4, position.y)
   data.encode_float( 8, position.z)
   data.encode_float(12, Velocity.x)
   data.encode_float(16, Velocity.y)
   data.encode_float(20, Velocity.z)
   self.queue_free()
   return data
static func create_from_byte_array(owner_id: int, data: PackedByteArray) -> LunarTowline_Hook: 
   var new_position := Vector3( data.decode_float( 0), data.decode_float( 4), data.decode_float( 8) )
   var new_velocity := Vector3( data.decode_float(12), data.decode_float(16), data.decode_float(20) )
   # TODO: name your new Familiar
   return LunarTowline_Hook.new(owner_id, new_position, new_velocity) 

func _physics_process(delta: float) -> void:
   ## MOVE ACCORDING TO VELOCITY IF NOT HOOKED
   if hooked_id == 0:
      if Velocity.length_squared() > 0.001:
         var dir := Velocity.normalized()
         var up := Vector3.UP
         if abs(dir.dot(up)) > 0.999:
            up = Vector3.FORWARD
         
         var target_basis := Basis.looking_at(dir, up)
         var target_quat := target_basis.get_rotation_quaternion()
         var current_quat := global_transform.basis.get_rotation_quaternion()
         var new_quat := current_quat.slerp(target_quat, 1.0 - exp(-SPEED * delta))
         global_transform.basis = Basis(new_quat)
         
      position   +=  delta*SPEED*Velocity
      Velocity.y += -delta*GRAVITY
   ## REMAIN WITH THE HOOKED CHARACTER IF THERE IS ONE
   else:
      var pos0 = (HOOK_TARGET.position + Vector3.UP) if HOOK_TARGET else Vector3.ZERO
      var pos1 = (HOOK_OWNER.position + Vector3.UP) if HOOK_OWNER else Vector3.ZERO
      _draw_line(pos0, pos1)

func _draw_line(pos0 : Vector3, pos1 : Vector3, color : Color = Color.WHITE):
   var immediate_mesh := ImmediateMesh.new()
   mesh_instance.mesh = immediate_mesh
   mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
   var material = ORMMaterial3D.new()
   material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
   material.albedo_color = color
   immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
   immediate_mesh.surface_add_vertex(pos0)
   immediate_mesh.surface_add_vertex(pos1)
   immediate_mesh.surface_end()

#func _process(delta: float) -> void:
   #super(delta) # NOTE: keep this line if adding custom _process(). kills self at end of life.

func _on_body_entered(body : Node3D):
   if hooked_id != 0: return
   var check_body = body if body is Player else body.get_parent() if body.get_parent() is Dummy else null
   if check_body is Player or check_body is Dummy:
      if check_body.NETWORK_ID == OwnerID: return
      hooked_id = check_body.NETWORK_ID
      find_hook_owner()
      find_hook_target()
      if OwnerID == get_parent().get_parent().MPM.get_local_player_id(): send_hook_id_to_owner()
      position = Vector3.ZERO
      rotation = Vector3.ZERO
func find_hook_owner():
   if OwnerID == get_parent().get_parent().MPM.get_local_player_id():
      HOOK_OWNER = get_parent().get_parent().find_child("Player") as Player
   elif SettingsManager.peer_settings.has(OwnerID):
      HOOK_OWNER = SettingsManager.peer_settings.get(OwnerID).dummy as Dummy
   else:
      printerr("owner id doesn't exist in peer settings. see lunartowline_hood.gd")
func find_hook_target():
   if hooked_id == get_parent().get_parent().MPM.get_local_player_id():
      HOOK_TARGET = get_parent().get_parent().find_child("Player") as Player
   elif SettingsManager.peer_settings.has(hooked_id):
      HOOK_TARGET = SettingsManager.peer_settings.get(hooked_id).dummy as Dummy
   else:
      printerr("hooked player id doesn't exist in peer settings. see lunartowline_hood.gd")

## called after a player has been hooked, and only if this familiar is running on the familiar's owner's computer
func send_hook_id_to_owner():
   for i in range(ThePlayer.SpellBook.ActiveSlots):
      var test_spell = ThePlayer.SpellBook.ActiveSpells[i]
      if test_spell is LunarTowlineSpell and test_spell.CurrentState == test_spell.States.Cast:
         test_spell.recieve_target_id(hooked_id)
func get_state_from_spell():
   for i in range(ThePlayer.SpellBook.ActiveSlots):
      var test_spell = ThePlayer.SpellBook.ActiveSpells[i]
      if test_spell is LunarTowlineSpell and ( test_spell.CurrentState == test_spell.States.Reeling or test_spell.CurrentState == test_spell.States.None ):
         self.queue_free()
