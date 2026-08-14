extends Node
## An object that contains all data for a single instance of damage.
class_name DamagePackage

## The object that dealt damage. For example: a player, turret, or familiar.
var id_from : int
## The damaging object's owner. If the object that dealt damage is a turret or another “spawnable” damaging object, this represents that object's owner. If the object that dealt damage is a player, this should be 0.
var id_owner : int
## The object recieving damage. For example: an enemy player, or their turret.
var id_to : int
## The global position of the object dealing damage.
var location_source : Vector3
## The global position of the object recieving damage.
var location_receipt  : Vector3
## The amount of damage dealt.
var amount : float = 0.0:
   set(new_val):
      amount = _round_damage_to_decimal(new_val)
## The type of damage dealt.
var type : DamageType
## The amount of pushing / shoving force dealt by the attack.[br]This should be multiplied against the difference between location_source and location_receipt to get the direction.
var force : float

## size in bytes of a [member id_from].
const ID_FROM_SIZE          : int = 4
## size in bytes of a [member id_owner].
const ID_OWNER_SIZE         : int = 4
## size in bytes of a [member id_to].
const ID_TO_SIZE            : int = 4
## size in bytes of a [member location_source].
const LOCATION_SOURCE_SIZE  : int = 12
## size in bytes of a [member location_receipt].
const LOCATION_RECEIPT_SIZE : int = 12
## size in bytes of a [member amount].
const AMOUNT_SIZE           : int = 4
## size in bytes of a [member type].
const TYPE_SIZE             : int = 1
## size in bytes of a [member force].
const FORCE_SIZE            : int = 6

## The number of decimal places the damage amount should be rounded to.
const ROUNDING_PLACES       : int = 5

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

func _init(_id_from : int = 0, _id_owner : int = 0, _id_to : int = 0, _location_source : Vector3 = Vector3.ZERO, _location_receipt : Vector3 = Vector3.ZERO, _amount : float = 0.0, _type : DamageType = DamageType.IMPACT, _force : float = 0.0) -> void:
   id_from = _id_from
   id_owner = _id_owner
   id_to = _id_to
   location_source = _location_source
   location_receipt = _location_receipt
   amount = _amount
   type = _type
   force = _force

## Rounds the float value new_val to the nearest N decimal places, where N is determined by this class' ROUNDING_PLACES value.
func _round_damage_to_decimal(new_val : float) -> float: return round( new_val * pow( 10 , ROUNDING_PLACES ) ) / pow( 10 , ROUNDING_PLACES )
## Returns a PackedByteArray containing all the necessary data in the DamagePackage to be sent over the wire. Can be unpacked using DamagePackage.from_PackedByteArray().
func to_PackedByteArray() -> PackedByteArray:
   var data: PackedByteArray = []
   data.resize(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE + LOCATION_RECEIPT_SIZE + AMOUNT_SIZE + TYPE_SIZE + FORCE_SIZE)
   data.encode_u32  (0,                                                                                                                id_from)
   data.encode_u32  (ID_FROM_SIZE,                                                                                                    id_owner)
   data.encode_u32  (ID_FROM_SIZE + ID_OWNER_SIZE,                                                                                       id_to)
   data.encode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE,                                                              location_source.x)
   data.encode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + 4,                                                          location_source.y)
   data.encode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + 8,                                                          location_source.z)
   data.encode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE,                                      location_receipt.x)
   data.encode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE + 4,                                  location_receipt.y)
   data.encode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE + 8,                                  location_receipt.z)
   data.encode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE + LOCATION_RECEIPT_SIZE,                          amount)
   data.encode_u8   (ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE + LOCATION_RECEIPT_SIZE + AMOUNT_SIZE,              type)
   data.encode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE + LOCATION_RECEIPT_SIZE + AMOUNT_SIZE + TYPE_SIZE, force)
   return data
## From a given PackedByteArray - packed using DamagePackage.to_PackedByteArray() - constructs and returns a valid DamagePackage with all the same data.
static func from_PackedByteArray(data : PackedByteArray) -> DamagePackage:
   var package := DamagePackage.new()
   package.id_from            = data.decode_u32  (0)
   package.id_owner           = data.decode_u32  (ID_FROM_SIZE)
   package.id_to              = data.decode_u32  (ID_FROM_SIZE + ID_OWNER_SIZE)
   package.location_source.x  = data.decode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE)
   package.location_source.y  = data.decode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + 4)
   package.location_source.z  = data.decode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + 8)
   package.location_receipt.x = data.decode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE)
   package.location_receipt.y = data.decode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE + 4)
   package.location_receipt.z = data.decode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE + 8)
   package.amount             = data.decode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE + LOCATION_RECEIPT_SIZE)
   package.type               = data.decode_u8   (ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE + LOCATION_RECEIPT_SIZE + AMOUNT_SIZE) as DamageType
   package.force              = data.decode_float(ID_FROM_SIZE + ID_OWNER_SIZE + ID_TO_SIZE + LOCATION_SOURCE_SIZE + LOCATION_RECEIPT_SIZE + AMOUNT_SIZE + TYPE_SIZE)
   return package
