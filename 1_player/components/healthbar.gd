extends Node
class_name HealthComponent

@export_category("Components")
@export var player : Player

const NUMBER_OF_HEALTH_TYPES : int = 4
var total_health : Array[float] = [ 0.0 , 0.0 , 0.0 , 0.0 ]
var damage_taken : float = 0.0

func _ready():
   pass

func _process(_delta):
   pass

func recieve_damage_package(package : DamagePackage):
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

func get_health() -> Array[float]: return total_health
func set_health(health_array : Array[float], add : bool = false):
   health_array.resize(NUMBER_OF_HEALTH_TYPES)
   if add:
      for i in range(health_array.size()):
         total_health[i] += health_array[i]
   else:
      total_health = health_array
