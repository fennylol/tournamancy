# meta-name: Default
# meta-description: Base template for familiar
# meta-default: true
# meta-space-indent: 3
# Familiars are used when you want to spawn an entity that is independent of the 
# spawning player. When spawning one (generally from an effect/spell), the spawning
# script should create one with new() and immediately call reduce_to_byte_array()
# on it. the resulting PackedByteArray can be passed to the Player's spawn_familiar()
extends Familiar
# TODO: name your new Familiar
class_name NewFamiliar

# a failsafe in seconds. self destructs at end.
const MAX_LIFE_TIME: float = 30.0

# we use _init() and reduce_to_byte_array() to ensure all necessary info is present
# before sending over the network.
func _init(owner_id: int) -> void: 
   super(owner_id, MAX_LIFE_TIME)
   name = str(owner_id) + "__new_familiar__" + str(randi())
   #var primary_color  : Color = SettingsManager.peer_settings[owner_id].primary_color   if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.PRIMARY_COLOR
   #var secondary_color: Color = SettingsManager.peer_settings[owner_id].secondary_color if SettingsManager.peer_settings.has(owner_id) else SettingsManager.personal_settings.SECONDARY_COLOR

# pack essential info into a PackedByteArray then destroy self. 
# inverse of create_from_byte_array()
func reduce_to_byte_array() -> PackedByteArray: 
   var data: PackedByteArray = []
   self.queue_free()
   return data

# restore from a PackedByteArray recieved over the network.
# inverse of reduce_to_byte_array()
static func create_from_byte_array(owner_id: int, _data: PackedByteArray) -> Familiar: 
   # TODO: name your new Familiar
   return NewFamiliar.new(owner_id)


#func _process(delta: float) -> void:
   #super(delta) # NOTE: keep this line if adding custom _process(). kills self at end of life.

