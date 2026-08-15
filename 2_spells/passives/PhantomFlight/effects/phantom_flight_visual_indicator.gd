extends Effect

@onready var ring_mesh := $MeshInstance3D

var ALONE_COLOR: Color = Color.from_rgba8(0, 255, 0, 64)
var NEARBY_COLOR: Color = Color.from_rgba8(255, 0, 0, 64)

func _ready() -> void:
   var mat: StandardMaterial3D = ring_mesh.get_surface_override_material(0)
   mat.albedo_color = ALONE_COLOR
   
func change_state(new_state: int) -> void:
   super(new_state)
   var mat: StandardMaterial3D = ring_mesh.get_surface_override_material(0)
   if new_state == PhantomFlight.States.Alone:
      mat.albedo_color = ALONE_COLOR
   else:
      mat.albedo_color = NEARBY_COLOR
      
