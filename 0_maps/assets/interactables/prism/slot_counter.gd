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

var atlastexture      : AtlasTexture

func _init(_is_active : bool = false, _ActiveSpellID : SpellData.ActiveSpellIDs = SpellData.ActiveSpellIDs.ERROR, _PassiveSpellID : SpellData.PassiveSpellIDs = SpellData.PassiveSpellIDs.ERROR, _Stacks : int = 1, _Weight : int = 0, _slot_location : int = -1, _IconTextureRect : TextureRect = TextureRect.new(), _IconTextureButton : TextureButton = TextureButton.new(), _IconLabel : Label = Label.new(), _is_selected : bool = false, _passed_count : int = 0, _atlastexture : AtlasTexture = AtlasTexture.new()):
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
   atlastexture = _atlastexture

func duplicate_self() -> PrismSlotCounter:
   var new_counter := PrismSlotCounter.new()
   new_counter.is_active = is_active
   new_counter.ActiveSpellID = ActiveSpellID
   new_counter.PassiveSpellID = PassiveSpellID
   new_counter.Stacks = Stacks
   new_counter.Weight = Weight
   new_counter.slot_location = slot_location
   new_counter.IconTextureRect = IconTextureRect
   new_counter.IconTextureButton = IconTextureButton
   new_counter.IconLabel = IconLabel
   new_counter.is_selected = is_selected
   new_counter.passed_count = passed_count
   new_counter.atlastexture = atlastexture
   return new_counter
