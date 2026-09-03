extends Control
class_name HeadsUpDisplay

var UI_TEXTURES : CompressedTexture2D = preload("res://4_ui/HUD_3/main_ui_sheet48.png")

func _ready() -> void: 
   var slotsize : int = get_parent().get_parent().SpellBook.ActiveSlots
   _resize_active_slots(slotsize)
   active_anim_array.resize(slotsize)
   for i in range(slotsize):
      active_anim_array[i] = 0
      update_active_icon(i)
      ACTIVE_CLDN_RECTS[i].value = 0.0
      ACTIVE_CLDN_RADLS[i].value = 0.0
func process(delta : float):
   $VBoxContainer/HBoxContainerTop/CenterContainer/Control/L_bar.self_modulate = SettingsManager.personal_settings.PRIMARY_COLOR
   $VBoxContainer/HBoxContainerTop/CenterContainer/Control/R_bar.self_modulate = SettingsManager.personal_settings.SECONDARY_COLOR
   for i in range(active_anim_array.size()):
      if active_anim_array[i] == 2: _animate_ready_icon(i, delta)

# ================ #
#  passive spells  #
# ================ #

@onready var PASSIVE_ICON_STACK : Node2D = $VBoxContainer/HBoxContainerTop/CenterContainer/Control/PassiveIcons/IconStack
@onready var PASSIVE_ICON_COUNT : Node2D = $VBoxContainer/HBoxContainerTop/CenterContainer/Control/PassiveIcons/Numbers
var passive_list : Dictionary[SpellData.PassiveSpellIDs,int] = {}
const ICON_OFFSET : Vector2i = Vector2i(64,32)

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

@onready var ACTIVE_SLOT_CONTAINER : HBoxContainer   = $VBoxContainer/HBoxContainerBottom
@onready var ACTIVE_RADL_CONTAINER : CenterContainer = $CenterContainer
@onready var ACTIVE_READY_ANIM : TextureRect = $CenterContainer/ready_anim

@onready var ACTIVE_ICONS : Array[TextureRect] = []
@onready var ACTIVE_CLDN_RECTS : Array[TextureProgressBar] = []
@onready var ACTIVE_CLDN_RADLS : Array[TextureProgressBar] = []

const radial_margin : float = 5.0
var active_anim_array : Array[int] = []

## Updates the HUD to contain the correct number of active slots, according to [member slot_num].
func _resize_active_slots(slot_num : int) -> void:
   while ACTIVE_SLOT_CONTAINER.get_children().size() > 3:
      ACTIVE_SLOT_CONTAINER.get_children().pop_back().free()
   BUTTONPROMPT_TEXTURERECTS.resize(slot_num + 1)
   ACTIVE_ICONS.resize(slot_num)
   ACTIVE_CLDN_RECTS.resize(slot_num)
   ACTIVE_CLDN_RADLS.resize(slot_num)
   for i in range(slot_num):
      var new_node := _create_new_ActiveSlot_node(i)
      ACTIVE_SLOT_CONTAINER.add_child(new_node)
      var new_radial := _create_new_active_cooldown_radial(i, slot_num)
      ACTIVE_RADL_CONTAINER.add_child(new_radial)
   var spacer := Control.new()
   spacer.name = "SpacerR"
   spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
   spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
   ACTIVE_SLOT_CONTAINER.add_child(spacer)
## Creates a new node tree for an active icon and returns it. To be used immediately prior to an add_child() call.
func _create_new_ActiveSlot_node(slot : int , update_promptpointer : bool = true) -> VBoxContainer:
   var new_container := VBoxContainer.new()
   new_container.name = "Active_" + str(slot)
   new_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
   new_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
   new_container.size_flags_stretch_ratio = 3.0
   var center_container_01 := CenterContainer.new()
   center_container_01.name = "Icon"
   center_container_01.size_flags_horizontal = Control.SIZE_EXPAND_FILL
   center_container_01.size_flags_vertical = Control.SIZE_EXPAND_FILL
   center_container_01.size_flags_stretch_ratio = 2.0
   new_container.add_child(center_container_01)
   var texture_rect_01 := TextureRect.new()
   texture_rect_01.name = "color"
   texture_rect_01.modulate = Color(1,1,1,0.5)
   texture_rect_01.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
   center_container_01.add_child(texture_rect_01)
   var color_rect_atlas := AtlasTexture.new()
   color_rect_atlas.atlas = UI_TEXTURES
   color_rect_atlas.region = Rect2(320+(64*slot),384,64,64)
   texture_rect_01.texture = color_rect_atlas
   var center_container_02 := CenterContainer.new()
   center_container_02.name = "CooldownContainer"
   center_container_01.add_child(center_container_02)
   
   var texture_progress_bar := TextureProgressBar.new()
   texture_progress_bar.name = "Cooldown"
   texture_progress_bar.fill_mode = TextureProgressBar.FillMode.FILL_BOTTOM_TO_TOP
   texture_progress_bar.max_value = 1.0
   texture_progress_bar.step = 0.01
   texture_progress_bar.value = 1.0
   texture_progress_bar.self_modulate = Color(1,1,1,0.5)
   texture_progress_bar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
   center_container_02.add_child(texture_progress_bar)
   var progress_bar_line := AtlasTexture.new()
   progress_bar_line.atlas = UI_TEXTURES
   progress_bar_line.region = Rect2(320+(64*slot),320,64,64)
   texture_progress_bar.texture_under = progress_bar_line
   texture_progress_bar.texture_over = progress_bar_line
   var progress_bar_fill := AtlasTexture.new()
   progress_bar_fill.atlas = UI_TEXTURES
   progress_bar_fill.region = Rect2(320+(64*slot),448,64,64)
   texture_progress_bar.texture_progress = progress_bar_fill
   
   var texture_rect_02 := TextureRect.new()
   texture_rect_02.name = "Icon"
   texture_rect_02.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
   center_container_02.add_child(texture_rect_02)
   var icon_atlas := AtlasTexture.new()
   icon_atlas.atlas = UI_TEXTURES
   icon_atlas.region = Rect2(336+(48*slot),240,48,48)
   texture_rect_02.texture = icon_atlas
   
   var center_container_03 := CenterContainer.new()
   center_container_03.name = "ButtonPrompt"
   center_container_03.offset_transform_enabled = true
   center_container_03.offset_transform_position = Vector2(0,32)
   center_container_03.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
   center_container_01.add_child(center_container_03)
   var texture_rect_03 := TextureRect.new()
   texture_rect_03.name = "PromptTexture"
   center_container_03.add_child(texture_rect_03)
   var button_prompt_atlas := AtlasTexture.new()
   button_prompt_atlas.atlas = UI_TEXTURES
   button_prompt_atlas.region = Rect2((slot*48),192,48,48) ## TODO: update to array reference
   texture_rect_03.texture = button_prompt_atlas
   var spacer_01 := Control.new()
   spacer_01.name = "Spacer"
   spacer_01.size_flags_horizontal = Control.SIZE_EXPAND_FILL
   spacer_01.size_flags_vertical = Control.SIZE_EXPAND_FILL
   new_container.add_child(spacer_01)
   if update_promptpointer:
      BUTTONPROMPT_TEXTURERECTS[slot+1] = texture_rect_03
      ACTIVE_ICONS             [slot]   = texture_rect_02
      ACTIVE_CLDN_RECTS        [slot]   = texture_progress_bar
   return new_container
## Creates a new radial progress bar node and returns it. To be used immediately prior to an add_child() call.
func _create_new_active_cooldown_radial(slot : int, slotmax : int = -1, update_promptpointer : bool = true) -> TextureProgressBar:
   ## NODE SETUP
   var new_radial := TextureProgressBar.new()
   new_radial.name = "Cooldown_" + str(slot)
   new_radial.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
   new_radial.self_modulate = Color(1,1,1,0.5)
   new_radial.fill_mode = TextureProgressBar.FillMode.FILL_CLOCKWISE_AND_COUNTER_CLOCKWISE
   new_radial.max_value = 1.0
   new_radial.value = 1.0
   new_radial.step = 0.01
   new_radial.offset_transform_enabled = true
   new_radial.offset_transform_scale = Vector2(-1,1)
   var new_texture := AtlasTexture.new()
   new_texture.atlas = UI_TEXTURES
   new_texture.region = Rect2(528,192,48,48)
   new_radial.texture_progress = new_texture
   ## MATH
   var M : float = get_parent().get_parent().SpellBook.ActiveSlots if slotmax <= 0 else slotmax
   var L : float = (90*(M+2))/M
   var D : float = 360/(2*M) if M > 2 else 0.0
   ## DETERMINE ANGLE
   var angle : float = 0.0
   if slot < 2:    angle = ((D+L)/2)+(slot*(L+(D*M)-(D*3)))
   elif slot == 2: angle = 0.0
   else:           angle = L+(D*slot)-(2*D)
   ## ASSIGN VALUES
   new_radial.radial_initial_angle = angle
   new_radial.radial_fill_degrees = L-radial_margin if slot < 2 else D-radial_margin
   if update_promptpointer: ACTIVE_CLDN_RADLS[slot] = new_radial
   print("slot #", slot," set to angle ", angle)
   return new_radial

## Updates an Active slot with the correct texture and cooldown value based on a given SpellID
func update_active_icon(active_slot : int, id : SpellData.ActiveSpellIDs = SpellData.ActiveSpellIDs.ERROR):
   var cooldown_bar := ACTIVE_CLDN_RECTS[active_slot]
   var cooldown_rad := ACTIVE_CLDN_RADLS[active_slot]
   if id == SpellData.ActiveSpellIDs.ERROR or not SpellList.ActiveSpells.has(id):
      ACTIVE_ICONS[active_slot].texture = ImageTexture.new()
      cooldown_bar.max_value = 0.0
      cooldown_rad.max_value = 0.0
   else:
      var new_texture := AtlasTexture.new()
      new_texture.atlas = SpellList.ActiveSpells.get(id).get(SpellData.SpellFields.IconPath)
      new_texture.region = SpellList.ActiveSpells.get(id).get(SpellData.SpellFields.IconRect)
      ACTIVE_ICONS[active_slot].texture = new_texture
      cooldown_bar.max_value = SpellList.ActiveSpells.get(id).get(SpellData.SpellFields.Cooldown)
      cooldown_rad.max_value = SpellList.ActiveSpells.get(id).get(SpellData.SpellFields.Cooldown)
## Updates an Active slot's cooldown progress bar based on a given time delta.
func update_active_cooldown(active_slot : int, time_since_activation : float):
   var cooldown_bar := ACTIVE_CLDN_RECTS[active_slot]
   var cooldown_rad := ACTIVE_CLDN_RADLS[active_slot]
   var new_value = clamp(time_since_activation , 0.0 , cooldown_bar.max_value)
   cooldown_bar.value = new_value
   cooldown_rad.value = new_value
   var is_loaded : bool = new_value == cooldown_bar.max_value
   var bar_color : Color = SettingsManager.personal_settings.PRIMARY_COLOR if is_loaded else SettingsManager.personal_settings.SECONDARY_COLOR
   cooldown_bar.tint_progress = bar_color
   cooldown_rad.tint_progress = bar_color
   if is_loaded and active_anim_array[active_slot] == 1:
      active_anim_array[active_slot] = 2
## Resets an active cooldown to its max value.
func reset_active_cooldown(active_slot : int):
   var cooldown_bar := ACTIVE_CLDN_RECTS[active_slot]
   var cooldown_rad := ACTIVE_CLDN_RADLS[active_slot]
   cooldown_bar.value = cooldown_bar.max_value
   cooldown_rad.value = cooldown_rad.max_value
   _reset_animate_active()
   active_anim_array[active_slot] = 1
## Called when an input button is held.
func hold_active(active_slot : int):
   var cooldown_bar := ACTIVE_CLDN_RECTS[active_slot]
   var cooldown_rad := ACTIVE_CLDN_RADLS[active_slot]
   if cooldown_bar.value <= 0:
      cooldown_bar.value = cooldown_bar.max_value
      #active_hold_array[active_slot] = true
   if cooldown_rad.value <= 0:
      cooldown_rad.value = cooldown_rad.max_value
      #active_hold_array[active_slot] = true
   _reset_animate_active()
   active_anim_array[active_slot] = 1

## Updates the "Active Spell is Ready" animation according to delta.
func _animate_ready_icon(slot : int, delta: float) -> void:
   ACTIVE_READY_ANIM.visible = true
   ACTIVE_READY_ANIM.offset_transform_scale += Vector2(delta,delta) * 3
   ACTIVE_READY_ANIM.self_modulate -= Color(0,0,0,delta * 2)
   if ACTIVE_READY_ANIM.self_modulate.a <= 0.0:
      active_anim_array[slot] = 0
      _reset_animate_active()
## Resets the "Active Spell is Ready" animation to its default state.
func _reset_animate_active():
   ACTIVE_READY_ANIM.visible = false
   ACTIVE_READY_ANIM.offset_transform_scale = Vector2(1,1)
   ACTIVE_READY_ANIM.self_modulate = SettingsManager.personal_settings.PRIMARY_COLOR.lightened(0.5)

# ============= #
#   healthbar   #
# ============= #

@onready var HEALTHBAR : HealthDisplay = $VBoxContainer/HBoxContainerBottom/CenterContainer/Control/HealthDisplay

## Pass value and boolean data to the Healthbar
func update_healthbar(val : Array[float], add : bool = false): HEALTHBAR.update_display(val,add)

# ===================== #
#  inspect and prompts  #
# ===================== #

@onready var CURSOR      : Marker2D      = $Cursor
@onready var COLOR_RECT  : ColorRect     = $Cursor/ColorRect
@onready var PREAMBLE    : Label         = $Cursor/ColorRect/MarginContainer/VBoxContainer/isActive
@onready var NAME        : Label         = $Cursor/ColorRect/MarginContainer/VBoxContainer/Name
@onready var DESCRIPTION : RichTextLabel = $Cursor/ColorRect/MarginContainer/VBoxContainer/Description

@onready var BUTTONPROMPT_TEXTURERECTS : Array[TextureRect] = [$VBoxContainer/HBoxContainerTop/CenterContainer/ButtonPrompt/icon]

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
   for i in BUTTONPROMPT_TEXTURERECTS:
      if i is TextureRect: i.texture.region.position.y = 192 if keyboard else 240
