extends Node
class_name HealthComponent

@export_category("Components")
@export var player : Player

var total_health : Array[float] = [ 0.0 , 0.0 , 0.0 , 0.0 ]
var damage_taken : float = 0.0

func _ready():
   pass

func _process(_delta):
   pass

func sync_health():
   pass

func recieve_damage(_input : DamagePackage):
   pass
