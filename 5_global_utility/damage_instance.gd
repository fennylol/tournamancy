extends Node
class_name DamagePackage

## The object that dealt damage. For example: a player, turret, or familiar.
var obj_from : Node3D
## The damaging object's owner. If the object that dealt damage is a turret or another “spawnable” damaging object, this represents that object's owner. If the object that dealt damage is a player, this should be null.
var obj_owner : Node3D
## The object recieving damage. For example: an enemy player, or their turret.
var obj_to : Node3D
## The global position of the object dealing damage.
var location_source : Vector3
## The global position of the object recieving damage.
var location_receipt  : Vector3
## The amount of damage dealt.
var amount : float
## The type of damage dealt.
var type : DamageType
## The amount of pushing / shoving force dealt by the attack.[br]This should be multiplied against the difference between location_source and location_receipt to get the direction.
var force : float

## There are eight damage types, each of which starts with a different letter.[br][b][color=orange]Impact[/color][/b] "default" hammers, bats, bullets.[br][b][color=white]Sharp[/color][/b] blades.[br][b][color=purple]Energy[/color][/b] classic magic rays, light-based attacks, etc.[br][b][color=red]Fire[/color][/b] fire.[br][b][color=cyan]Cold[/color][/b] cold.[br][b][color=yellow]Zap[/color][/b] electricity, shock.[br][b][color=brown]Rot[/color][/b] poison, acid, necrosis, other “evil”-types.[br][b][color=green]Natural[/color][/b] bleeding, suffocation, etc.
enum DamageType {
   ## The default attack type. This includes objects such as hammers, bats, and bullets.
   IMPACT,
   ## Bladed weapons which slash or pierce. Swords, arrows, and claws.
   SHARP,
   ## Classic magic rays and light-based attacks.
   ENERGY,
   ## Hot attacks, including fire itself as well as boiling oil, steam, or red-hot metal.
   FIRE,
   ## Cold attacks.
   COLD,
   ## Electricity-based attacks such as lightning, static shocks, and electromagnetic pulses.
   ZAP,
   ## Poison, acid, necrosis, and other "evil" attacks.
   ROT,
   ## Damage done as a result of depriving the body. Bleeding, suffocation, etc.
   NATURAL}

func _init(_obj_from : Node3D = Node3D.new(), _obj_owner : Node3D = Node3D.new(), _obj_to : Node3D = Node3D.new(), _location_source : Vector3 = Vector3.ZERO, _location_receipt : Vector3 = Vector3.ZERO, _amount : float = 0.0, _type : DamageType = DamageType.IMPACT, _force : float = 0.0) -> void:
   obj_from = _obj_from
   obj_owner = _obj_owner
   obj_to = _obj_to
   location_source = _location_source
   location_receipt = _location_receipt
   amount = _amount
   type = _type
   force = _force
