extends Node
class_name HealthComponent

@export_category("Components")
@export var player : Player

const NUMBER_OF_HEALTH_TYPES : int = 4
var total_health : Array[float] = [ 0.0 , 0.0 , 0.0 , 0.0 ]
var damage_taken : float = 0.0

signal health_reached_zero(killer_id : int)
signal health_updated(new_health : Array[float])

func _ready():
   pass

func _process(delta):
   if total_health[3] != 0.0:
      total_health[3] = total_health[3] * pow(2 , -( delta / SettingsManager.match_settings.OVERHEALTH_DECAY_RATE ))
      health_updated.emit(total_health)

func on_damage_data(package : DamagePackage):
   damage_taken += package.amount
   
   ## REMOVE INCOMING DAMAGE FROM TOTAL HEALTH
   ## TODO: MAKE ARMOR AND WARD REDUCE DAMAGE
   var unallocated_damage = package.amount
   for i in range(NUMBER_OF_HEALTH_TYPES):
      var j = NUMBER_OF_HEALTH_TYPES - i - 1
      if unallocated_damage > total_health[j]:
         unallocated_damage -= total_health[j]
         total_health[j] = 0.0
      else:
         total_health[j] -= unallocated_damage
         unallocated_damage = 0.0
   
   health_updated.emit(total_health)
   
   ## SIGNAL WHEN HEALTH REACHES ZERO
   var health_sum : float = 0
   for i in range(NUMBER_OF_HEALTH_TYPES): health_sum += total_health[i]
   if health_sum <= 0.0: 
      health_reached_zero.emit(package.id_from)

func get_health() -> Array[float]: return total_health
func set_health(health_array : Array[float], add : bool = false):
   health_array.resize(NUMBER_OF_HEALTH_TYPES)
   if add:
      for i in range(health_array.size()):
         total_health[i] += health_array[i]
   else:
      total_health = health_array
   health_updated.emit(total_health)
