extends Control
class_name  ActiveShuffle

signal close_menu(updated_list : Array[SpellData.ActiveSpellIDs])

var PLAYER : Player
var UI_TEXTURES : CompressedTexture2D = preload("res://4_ui/main_ui_sheet48.png")
const ICON_ERROR_MARGIN : float = 50.0
const NEW_REGION   : Rect2 = Rect2(576,720,48,48)
const SLOT0_REGION : Rect2 = Rect2(336,240,48,48)
const TRASH_REGION : Rect2 = Rect2(624,720,48,48)

@onready var CURSOR      : Marker2D        = $Cursor
@onready var CURSOR_ICON : TextureRect     = $Cursor/HandItem/Icon
@onready var NEW_SLOTS   : HBoxContainer   = $ActiveConfirm/VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/New_Slots
@onready var ACT_SLOTS   : HBoxContainer   = $ActiveConfirm/VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/Active_Slots
@onready var TRASH_SLOT  : CenterContainer = $ActiveConfirm/VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/Trash_Slot
var icon_slot_array      : Array[TextureRect]
var selected_slot_array  : Array[TextureRect]
var spell_id_array       : Array[SpellData.ActiveSpellIDs]
var cursor_spell : SpellData.ActiveSpellIDs = SpellData.ActiveSpellIDs.ERROR

var base_count : int = 0
var import_count : int = 0

func setup(import_spells : Array[SpellData.ActiveSpellIDs] = []) -> void:
   Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
   ## SETUP SPELL ARRAYS
   base_count = PLAYER.SpellBook.ActiveSlots
   import_count = import_spells.size()
   spell_id_array.resize(base_count)
   for i in range(spell_id_array.size()):
      spell_id_array[i] = PLAYER.SpellBook.ActiveSpells[i].SpellID as SpellData.ActiveSpellIDs if PLAYER.SpellBook.ActiveSpells[i] is ActiveSpell else -1
   for i in range(import_spells.size()):
      spell_id_array.append(import_spells[i])
   spell_id_array.append(SpellData.ActiveSpellIDs.ERROR)
   ##
   icon_slot_array.resize(base_count + import_count + 1)
   selected_slot_array.resize(base_count + import_count + 1)
   ## CLEAR AND RESET BASE SLOTS
   for i in ACT_SLOTS.get_children(): i.free()
   for i in range(base_count):
      var base_slot := create_slot_node(i)
      ACT_SLOTS.add_child(base_slot)
      icon_slot_array[i] = base_slot.get_child(0)
      selected_slot_array[i] = base_slot.get_child(1)
   ## CLEAR AND RESET NEW SLOTS
   for i in NEW_SLOTS.get_children(): i.free()
   for i in range(import_count):
      var new_slot := create_slot_node(i, true)
      NEW_SLOTS.add_child(new_slot)
      icon_slot_array[base_count + i] = new_slot.get_child(0)
      selected_slot_array[base_count + i] = new_slot.get_child(1)
   ## ADD TRASH SLOTS
   icon_slot_array[base_count + import_count] = TRASH_SLOT.get_child(0)
   selected_slot_array[base_count + import_count] = TRASH_SLOT.get_child(1)
   ##
   for i in range(icon_slot_array.size()):
      sync_slot_texture(i, spell_id_array[i])
func _ready() -> void:
   PLAYER = get_parent().get_parent()
func _process(_delta: float) -> void:
   if PLAYER.menu_open != Player.Menu.ACTIVE: return
   if Input.get_last_mouse_velocity() != Vector2.ZERO: CURSOR.position = get_global_mouse_position()
   
   ## SHOW THE SELECTION TEXTURE WHILE MOUSE IS HOVERING OVER THE ICON
   for i in range(icon_slot_array.size()):
      var icon : TextureRect = icon_slot_array[i]
      if CURSOR.global_position.x > icon.global_position.x and CURSOR.global_position.y > icon.global_position.y and CURSOR.global_position.x < (icon.global_position.x+ICON_ERROR_MARGIN) and CURSOR.global_position.y < (icon.global_position.y+ICON_ERROR_MARGIN):
         selected_slot_array[i].visible = true
      else:
         selected_slot_array[i].visible = false
   
   if Input.is_action_just_pressed("select"):
      ## GET RELEVANT SLOT
      var selected_slot : int = -1
      for i in range(selected_slot_array.size()):
         if selected_slot_array[i].visible == true:
            selected_slot = i
            break
      if selected_slot == -1: return
      
      ## SWAP IDS AND TEXTURES
      ## SPECIAL CASE: DON'T SWAP TRASH
      sync_slot_texture(selected_slot,cursor_spell)
      var pick_id : SpellData.ActiveSpellIDs = SpellData.ActiveSpellIDs.ERROR if ( selected_slot == (spell_id_array.size()-1) and cursor_spell != SpellData.ActiveSpellIDs.ERROR) else spell_id_array[selected_slot]
      if pick_id == SpellData.ActiveSpellIDs.ERROR:
         CURSOR_ICON.texture.atlas = UI_TEXTURES
         CURSOR_ICON.texture.region = Rect2(0,198,48,48)
      else:
         CURSOR_ICON.texture.atlas = SpellList.ActiveSpells.get(pick_id).get(SpellData.SpellFields.IconPath)
         CURSOR_ICON.texture.region = SpellList.ActiveSpells.get(pick_id).get(SpellData.SpellFields.IconRect)
      spell_id_array[selected_slot] = cursor_spell
      cursor_spell = pick_id
      
      ## REMOVE SLOT IF NEW
      if selected_slot >= base_count and selected_slot < (base_count + import_count) and spell_id_array[selected_slot] == SpellData.ActiveSpellIDs.ERROR:
         NEW_SLOTS.get_child(selected_slot-base_count).queue_free()
         icon_slot_array.pop_at(selected_slot)
         selected_slot_array.pop_at(selected_slot)
         spell_id_array.pop_at(selected_slot)
         import_count -= 1

## Creates a new node tree for a slot icon and returns it. To be used immediately prior to an add_child() call.
func create_slot_node(slot : int, new_spell : bool = false) -> CenterContainer:
   var new_slot := CenterContainer.new()
   new_slot.name = "New_"+str(slot) if new_spell else "Slot_"+str(slot)
   new_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
   new_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
   var icon_rect := TextureRect.new()
   icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
   var icon_texture := AtlasTexture.new()
   icon_texture.atlas = UI_TEXTURES
   icon_texture.region = NEW_REGION if new_spell else SLOT0_REGION
   if not new_spell: icon_texture.region.position.x += (48*slot)
   icon_rect.texture = icon_texture
   new_slot.add_child(icon_rect)
   var selected_rect := TextureRect.new()
   selected_rect.visible = false
   selected_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
   selected_rect.self_modulate = Color(1,1,1,0.5)
   var selected_texture := AtlasTexture.new()
   selected_texture.atlas = UI_TEXTURES
   selected_texture.region = Rect2(480,192,48,48)
   selected_rect.texture = selected_texture
   new_slot.add_child(selected_rect)
   return new_slot
## Places the correct texture into the 'ICON' TextureRect based on a spellid.
func sync_slot_texture(slot : int, id : int = -1) -> void:
   var slot_texture : AtlasTexture = icon_slot_array[slot].texture
   if id == -1 or id == SpellData.ActiveSpellIDs.ERROR:
      slot_texture.atlas = UI_TEXTURES
      if slot < base_count: 
         slot_texture.region = Rect2(Vector2(SLOT0_REGION.position.x + (48*slot),SLOT0_REGION.position.y),SLOT0_REGION.size)
      elif slot < (base_count + import_count): 
         slot_texture.region = NEW_REGION
      else: 
         slot_texture.region = TRASH_REGION
   else:
      slot_texture.atlas = SpellList.ActiveSpells.get(id).get(SpellData.SpellFields.IconPath)
      slot_texture.region = SpellList.ActiveSpells.get(id).get(SpellData.SpellFields.IconRect)

func _on_button_confirm_pressed() -> void:
   var updated_list : Array[SpellData.ActiveSpellIDs] = []
   updated_list.resize(base_count)
   for i in range(base_count): updated_list[i] = spell_id_array[i]
   close_menu.emit(updated_list)
func _on_button_cancel_pressed() -> void:
   var typed_empty : Array[SpellData.ActiveSpellIDs] = []
   close_menu.emit(typed_empty)
