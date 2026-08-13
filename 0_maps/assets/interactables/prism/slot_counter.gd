extends Resource
class_name PrismSlotCounter

var is_active         : bool
var ActiveSpellID     : SpellData.ActiveSpellIDs
var PassiveSpellID    : SpellData.PassiveSpellIDs
var Stacks            : int
var Weight            : int

var slot_location     : int
var IconTextureRect   : TextureRect
var IconTextureButton : TextureButton
var IconLabel         : Label

var is_selected       : bool
var passed_count      : int


func init(_is_active : bool = false, _ActiveSpellID : SpellData.ActiveSpellIDs = SpellData.ActiveSpellIDs.ERROR, _PassiveSpellID : SpellData.PassiveSpellIDs = SpellData.PassiveSpellIDs.ERROR, _Stacks : int = 1, _Weight : int = 0, _slot_location : int = -1, _IconTextureRect : TextureRect = TextureRect.new(), _IconTextureButton : TextureButton = TextureButton.new(), _IconLabel : Label = Label.new(), _is_selected : bool = false, _passed_count : int = 0):
   is_active = _is_active
   ActiveSpellID = _ActiveSpellID
   PassiveSpellID = _PassiveSpellID
   Stacks = _Stacks
   Weight = _Weight
   slot_location = _slot_location
   IconTextureRect = _IconTextureRect
   IconTextureButton = _IconTextureButton
   IconLabel = _IconLabel
   is_selected = _is_selected
   passed_count = _passed_count
