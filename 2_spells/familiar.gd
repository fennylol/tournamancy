extends Node3D
class_name Familiar


var LifeTime: float
var OwnerID: int
var ThePlayer: Player


static func create_from_byte_array(owner_id: int, _data: PackedByteArray) -> Familiar: 
   return Familiar.new(owner_id)
func reduce_to_byte_array() -> PackedByteArray: 
   self.queue_free()
   return []

func _process(delta: float) -> void:
   LifeTime -= delta
   if LifeTime < 0: self.queue_free()
func _init(owner_id: int, max_life_time: float = 300.0) -> void: 
   LifeTime = max_life_time
   OwnerID = owner_id
   
