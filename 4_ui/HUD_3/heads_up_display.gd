extends Control
class_name HeadsUpDisplay

@onready var HEALTHBAR : HealthDisplay = $VBoxContainer/HBoxContainerBottom/CenterContainer/Control/HealthDisplay

@onready var PASSIVE_ICON_STACK : Node2D = $VBoxContainer/HBoxContainerTop/CenterContainer/Control/PassiveIcons/IconStack
@onready var PASSIVE_ICON_COUNT : Node2D = $VBoxContainer/HBoxContainerTop/CenterContainer/Control/PassiveIcons/Numbers
var passive_list : Dictionary[SpellData.PassiveSpellIDs,int] = {}
const ICON_OFFSET : Vector2i = Vector2i(64,32)

@onready var L_ACTIVE_ICON     : Sprite2D           = $VBoxContainer/HBoxContainerBottom/ActiveL/Icon/CenterContainer/ActiveL/Icon
@onready var L_ACTIVE_CLDN_BAR : TextureProgressBar = $VBoxContainer/HBoxContainerBottom/ActiveL/Icon/CenterContainer/ActiveL/Cooldown
@onready var L_ACTIVE_CLDN_RAD : TextureProgressBar = $CenterContainer/Countdown_L
@onready var L_ACTIVE_ANIM     : TextureRect        = $CenterContainer/ready_anim_L
@onready var R_ACTIVE_ICON     : Sprite2D           = $VBoxContainer/HBoxContainerBottom/ActiveR/Icon/CenterContainer/ActiveR/Icon
@onready var R_ACTIVE_CLDN_BAR : TextureProgressBar = $VBoxContainer/HBoxContainerBottom/ActiveR/Icon/CenterContainer/ActiveR/Cooldown
@onready var R_ACTIVE_CLDN_RAD : TextureProgressBar = $CenterContainer/Countdown_R
@onready var R_ACTIVE_ANIM     : TextureRect        = $CenterContainer/ready_anim_R
var active_hold_array : Array[bool] = []
var active_anim_array : Array[int] = []

@onready var BUTTONPROMPT_TEXTURERECTS : Array[TextureRect] = [$VBoxContainer/HBoxContainerTop/CenterContainer/ButtonPrompt/color,$VBoxContainer/HBoxContainerTop/CenterContainer/ButtonPrompt/lines,$VBoxContainer/HBoxContainerBottom/ActiveL/Icon/ButtonPrompt/color,$VBoxContainer/HBoxContainerBottom/ActiveL/Icon/ButtonPrompt/lines,$VBoxContainer/HBoxContainerBottom/ActiveR/Icon/ButtonPrompt/color,$VBoxContainer/HBoxContainerBottom/ActiveR/Icon/ButtonPrompt/lines]
const BUTTONPROMPT_RECT_KYBD : Array[Rect2] = [Rect2(0,96,64,32),Rect2(0,64,64,32),Rect2(0,192,32,40),Rect2(0,128,32,40),Rect2(32,192,32,40),Rect2(32,128,32,40)]
const BUTTONPROMPT_RECT_CTRL : Array[Rect2] = [Rect2(64,64,64,64),Rect2(64,0,64,64),Rect2(128,32,64,32),Rect2(128,0,64,32),Rect2(128,96,64,32),Rect2(128,64,64,32)]
@onready var CURSOR : Marker2D = $Cursor

func _ready() -> void: 
   var slotsize : int = get_parent().get_parent().SpellBook.ActiveSlots
   active_anim_array.resize(slotsize)
   active_hold_array.resize(slotsize)
   for i in range(slotsize):
      active_anim_array[i] = 0
      update_active_icon(i)
      _get_active_cooldown_bar_from_slot(i).value = 0.0
      _get_active_cooldown_rad_from_slot(i).value = 0.0
func process(delta : float):
   for i in range(active_anim_array.size()):
      if active_anim_array[i] == 2: _animate_active_icon_ready(i, delta)

# ================ #
#  passive spells  #
# ================ #

## Takes an array of PassiveSpells, finds the relevant icons, and arrays them in the passivebox. If [member full_clear] is true, the passive box will empty before adding the new passives. If false, it will add the new passive spells to those already displayed.
func import_passive_spells(imported_spells : Array[PassiveSpell], full_clear : bool = false):
   ## SET UP DICTIONARY
   if full_clear: passive_list.clear()
   for i in range(imported_spells.size()):
      var stack_size : int
      if passive_list.has(imported_spells[i].SpellID):
         stack_size = imported_spells[i].Stacks + passive_list.get(imported_spells[i].SpellID)
      else:
         stack_size = imported_spells[i].Stacks
      passive_list.merge( {imported_spells[i].SpellID : stack_size },true)
   ## CLEAR AND SET ICONS
   for child in PASSIVE_ICON_STACK.get_children(): child.queue_free()
   for child in PASSIVE_ICON_COUNT.get_children(): child.queue_free()
   for i in range(passive_list.keys().size()):
      ## CREATE NEW ICON
      var new_icon = Sprite2D.new()
      var new_texture = AtlasTexture.new()
      new_texture.atlas = SpellList.PassiveSpells.get(passive_list.keys()[i]).get(SpellData.SpellFields.IconPath)
      new_texture.region = SpellList.PassiveSpells.get(passive_list.keys()[i]).get(SpellData.SpellFields.IconRect)
      new_icon.texture = new_texture
      PASSIVE_ICON_STACK.add_child(new_icon)
      ## SET ICON LOCATION
      @warning_ignore("integer_division")
      new_icon.position = Vector2(ICON_OFFSET.x * i,floor(i/9))
      ## CREATE NUMBER
      var new_number = Label.new()
      new_number.text = "x" + str(passive_list.get(passive_list.keys()[i]))
      new_number.size = Vector2(32,32)
      new_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
      new_number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
      PASSIVE_ICON_COUNT.add_child(new_number)
      ## PLACE NUMBER
      @warning_ignore("integer_division")
      new_number.position = Vector2((ICON_OFFSET.x * i)+16,(floor(i/9))-16)

# =============== #
#  active spells  #
# =============== #

## Updates an Active slot with the correct texture and cooldown value based on a given SpellID
func update_active_icon(active_slot : int, id : SpellData.ActiveSpellIDs = SpellData.ActiveSpellIDs.ERROR):
   var icon         : Sprite2D           = L_ACTIVE_ICON if active_slot == 0 else R_ACTIVE_ICON
   var cooldown_bar := _get_active_cooldown_bar_from_slot(active_slot)
   var cooldown_rad := _get_active_cooldown_rad_from_slot(active_slot)
   if id == SpellData.ActiveSpellIDs.ERROR or not SpellList.ActiveSpells.has(id):
      icon.texture = ImageTexture.new()
      cooldown_bar.max_value = 0.0
      cooldown_rad.max_value = 0.0
   else:
      var new_texture := AtlasTexture.new()
      new_texture.atlas = SpellList.ActiveSpells.get(id).get(SpellData.SpellFields.IconPath)
      new_texture.region = SpellList.ActiveSpells.get(id).get(SpellData.SpellFields.IconRect)
      icon.texture = new_texture
      cooldown_bar.max_value = SpellList.ActiveSpells.get(id).get(SpellData.SpellFields.Cooldown)
      cooldown_rad.max_value = SpellList.ActiveSpells.get(id).get(SpellData.SpellFields.Cooldown)
## Updates an Active slot's cooldown progress bar based on a given time delta.
func update_active_cooldown(active_slot : int, time_since_activation : float):
   var cooldown_bar := _get_active_cooldown_bar_from_slot(active_slot)
   var cooldown_rad := _get_active_cooldown_rad_from_slot(active_slot)
   var new_value = clamp(cooldown_bar.max_value - time_since_activation , 0.0 , cooldown_bar.max_value)
   cooldown_bar.value = new_value
   cooldown_rad.value = new_value
   if new_value == 0.0 and active_anim_array[active_slot] == 1: 
      active_anim_array[active_slot] = 2
## Resets an active cooldown to its max value.
func reset_active_cooldown(active_slot : int):
   var cooldown_bar := _get_active_cooldown_bar_from_slot(active_slot)
   var cooldown_rad := _get_active_cooldown_rad_from_slot(active_slot)
   cooldown_bar.value = cooldown_bar.max_value
   cooldown_rad.value = cooldown_rad.max_value
   _reset_animate_active(active_slot)
   active_anim_array[active_slot] = 1
## Called when an input button is held.
func hold_active(active_slot : int):
   var cooldown_bar := _get_active_cooldown_bar_from_slot(active_slot)
   var cooldown_rad := _get_active_cooldown_rad_from_slot(active_slot)
   if cooldown_bar.value <= 0:
      cooldown_bar.value = cooldown_bar.max_value
      active_hold_array[active_slot] = true
   if cooldown_rad.value <= 0:
      cooldown_rad.value = cooldown_rad.max_value
      active_hold_array[active_slot] = true
   _reset_animate_active(active_slot)
   active_anim_array[active_slot] = 1
## Called when an input button is released.
func release_active(active_slot : int):
   active_hold_array[active_slot] = false
## Used to differentiate between different active slots. Extensible if we add more active slots.
func _get_active_cooldown_bar_from_slot(slot : int) -> TextureProgressBar:
   var cooldown_bar : TextureProgressBar = L_ACTIVE_CLDN_BAR if slot == 0 else R_ACTIVE_CLDN_BAR
   return cooldown_bar
## Used to differentiate between different active slots. Extensible if we add more active slots.
func _get_active_cooldown_rad_from_slot(slot : int) -> TextureProgressBar:
   var cooldown_bar : TextureProgressBar = L_ACTIVE_CLDN_RAD if slot == 0 else R_ACTIVE_CLDN_RAD
   return cooldown_bar
## Used to differentiate between different active slots. Extensible if we add more active slots.
func _get_active_icon_from_slot(slot : int) -> Sprite2D:
   var icon : Sprite2D = L_ACTIVE_ICON if slot == 0 else R_ACTIVE_ICON
   return icon
##
func _animate_active_icon_ready(slot : int, delta: float) -> void:
   var animate_node : TextureRect = L_ACTIVE_ANIM if slot == 0 else R_ACTIVE_ANIM
   animate_node.visible = true
   animate_node.offset_transform_scale += Vector2(delta,delta) * 3
   animate_node.self_modulate -= Color(0,0,0,delta * 2)
   if animate_node.self_modulate.a <= 0.0:
      active_anim_array[slot] = 0
      _reset_animate_active(slot)
##
func _reset_animate_active(slot : int):
   var animate_node : TextureRect = L_ACTIVE_ANIM if slot == 0 else R_ACTIVE_ANIM
   animate_node.visible = false
   animate_node.offset_transform_scale = Vector2(1,1)
   animate_node.self_modulate = Color.WHITE

# ============= #
#   healthbar   #
# ============= #

## Pass value and boolean data to the Healthbar
func update_healthbar(val : Array[float], add : bool = false): HEALTHBAR.update_display(val,add)

# ===================== #
#  inspect and prompts  #
# ===================== #

@onready var COLOR_RECT  : ColorRect = $Cursor/ColorRect
@onready var PREAMBLE    : Label = $Cursor/ColorRect/MarginContainer/VBoxContainer/isActive
@onready var NAME        : Label = $Cursor/ColorRect/MarginContainer/VBoxContainer/Name
@onready var DESCRIPTION : RichTextLabel = $Cursor/ColorRect/MarginContainer/VBoxContainer/Description

## Recieves an Interactable from the player while their raycast is looking at one. Used to display class data to player.
func show_interactable_info(obj : Interactable):
   CURSOR.position = get_viewport_rect().size / 2
   CURSOR.visible = true
   COLOR_RECT.color = SettingsManager.personal_settings.PRIMARY_COLOR
   PREAMBLE.label_settings = LabelSettings.new()
   NAME.label_settings = LabelSettings.new()
   @warning_ignore("integer_division")
   PREAMBLE.label_settings.font_size = SettingsManager.personal_settings.TEXTSIZE * 2/3
   @warning_ignore("integer_division")
   NAME.label_settings.font_size = SettingsManager.personal_settings.TEXTSIZE * 4/3
   if obj is ClassBook:
      PREAMBLE.text = "ARCANE DISCIPLINE"
      PREAMBLE.label_settings.font_color = Color.WHITE
      NAME.text = ClassData.ClassRecipes.get(obj.ClassID).get(ClassData.ClassFields.NAME)
      NAME.label_settings.font_color = obj.book_color
      DESCRIPTION.text = "[font_size=" + str(SettingsManager.personal_settings.TEXTSIZE) + "]" + ClassData.ClassRecipes.get(obj.ClassID).get(ClassData.ClassFields.DESCRIPTION) +"[/font_size]"
   elif obj is Prism:
      PREAMBLE.text = "a unique"
      PREAMBLE.label_settings.font_color = Color.WHITE
      NAME.text = "SPELL PRISM"
      NAME.label_settings.font_color = Color.WHITE
      NAME.label_settings.outline_size = 2
      NAME.label_settings.outline_color = Color.HOT_PINK
      DESCRIPTION.text = "[font_size=" + str(SettingsManager.personal_settings.TEXTSIZE) + "]dropped by a defeated player[/font_size]" if obj.is_player_prism else "[font_size=" + str(SettingsManager.personal_settings.TEXTSIZE) + "]spawned into the world[/font_size]"
   else:
      CURSOR.visible = false
## Closes the interactable info window.
func close_interactable_info():
   CURSOR.visible = false
## Changes the visible button prompts on the two active icons and below the passive box to show either keyboard/mouse buttons or controller buttons, depending on whether [member keyboard] is true.
func swap_button_prompts(keyboard : bool):
   for i in range(BUTTONPROMPT_TEXTURERECTS.size()):
      BUTTONPROMPT_TEXTURERECTS[i].texture.region = BUTTONPROMPT_RECT_KYBD[i] if keyboard else BUTTONPROMPT_RECT_CTRL[i]
