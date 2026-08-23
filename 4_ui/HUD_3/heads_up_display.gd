extends Control
class_name HeadsUpDisplay

@onready var HEALTHBAR : HealthDisplay = $VBoxContainer/HBoxContainerBottom/CenterContainer/Control/HealthDisplay

@onready var PASSIVE_ICON_STACK : Node2D = $VBoxContainer/HBoxContainerTop/CenterContainer/Control/PassiveIcons/IconStack
@onready var PASSIVE_ICON_COUNT : Node2D = $VBoxContainer/HBoxContainerTop/CenterContainer/Control/PassiveIcons/Numbers
var passive_list : Dictionary[SpellData.PassiveSpellIDs,int] = {}
const ICON_OFFSET : Vector2i = Vector2i(64,32)

@onready var L_ACTIVE_ICON : Sprite2D           = $VBoxContainer/HBoxContainerBottom/ActiveL/Icon/CenterContainer/ActiveL/Icon
@onready var L_ACTIVE_CLDN : TextureProgressBar = $VBoxContainer/HBoxContainerBottom/ActiveL/Icon/CenterContainer/ActiveL/Cooldown
@onready var R_ACTIVE_ICON : Sprite2D           = $VBoxContainer/HBoxContainerBottom/ActiveR/Icon/CenterContainer/ActiveR/Icon
@onready var R_ACTIVE_CLDN : TextureProgressBar = $VBoxContainer/HBoxContainerBottom/ActiveR/Icon/CenterContainer/ActiveR/Cooldown
var active_hold_array : Array[bool] = [false,false]

@onready var BUTTONPROMPT_TEXTURERECTS : Array[TextureRect] = [$VBoxContainer/HBoxContainerTop/CenterContainer/ButtonPrompt/color,$VBoxContainer/HBoxContainerTop/CenterContainer/ButtonPrompt/lines,$VBoxContainer/HBoxContainerBottom/ActiveL/Icon/ButtonPrompt/color,$VBoxContainer/HBoxContainerBottom/ActiveL/Icon/ButtonPrompt/lines,$VBoxContainer/HBoxContainerBottom/ActiveR/Icon/ButtonPrompt/color,$VBoxContainer/HBoxContainerBottom/ActiveR/Icon/ButtonPrompt/lines]
const BUTTONPROMPT_RECT_KYBD : Array[Rect2] = [Rect2(0,96,64,32),Rect2(0,64,64,32),Rect2(0,192,32,40),Rect2(0,128,32,40),Rect2(32,192,32,40),Rect2(32,128,32,40)]
const BUTTONPROMPT_RECT_CTRL : Array[Rect2] = [Rect2(64,64,64,64),Rect2(64,0,64,64),Rect2(128,32,64,32),Rect2(128,0,64,32),Rect2(128,96,64,32),Rect2(128,64,64,32)]
@onready var CURSOR : Marker2D = $Cursor

func _ready() -> void: 
   for i in range(active_hold_array.size()):
      update_active_icon(i)
      _get_active_cooldown_from_slot(i).value = 0.0

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
      new_texture.atlas = load(SpellData.PassiveSpells.get(passive_list.keys()[i]).get(SpellData.SpellFields.IconPath))
      new_texture.region = SpellData.PassiveSpells.get(passive_list.keys()[i]).get(SpellData.SpellFields.IconRect)
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
   var cooldown_bar := _get_active_cooldown_from_slot(active_slot)
   if id == SpellData.ActiveSpellIDs.ERROR or not SpellData.ActiveSpells.has(id): 
      icon.texture = ImageTexture.new()
      cooldown_bar.max_value = 0.0
   else:
      var new_texture := AtlasTexture.new()
      new_texture.atlas = load(SpellData.ActiveSpells.get(id).get(SpellData.SpellFields.IconPath))
      new_texture.region = SpellData.ActiveSpells.get(id).get(SpellData.SpellFields.IconRect)
      icon.texture = new_texture
      cooldown_bar.max_value = SpellData.ActiveSpells.get(id).get(SpellData.SpellFields.Cooldown)
## Updates an Active slot's cooldown progress bar based on a given time delta.
func update_active_cooldown(active_slot : int, time_since_activation : float):
   var cooldown_bar := _get_active_cooldown_from_slot(active_slot)
   cooldown_bar.value = clamp(cooldown_bar.max_value - time_since_activation , 0.0 , cooldown_bar.max_value)
## Resets an active cooldown to its max value.
func reset_active_cooldown(active_slot : int):
   var cooldown_bar := _get_active_cooldown_from_slot(active_slot)
   cooldown_bar.value = cooldown_bar.max_value
## Called when an input button is held.
func hold_active(active_slot : int):
   var cooldown_bar := _get_active_cooldown_from_slot(active_slot)
   if cooldown_bar.value > 0: return
   cooldown_bar.value = cooldown_bar.max_value
   active_hold_array[active_slot] = true
## Called when an input button is released.
func release_active(active_slot : int):
   active_hold_array[active_slot] = false
## Used to differentiate between different active slots. Extensible if we add more active slots.
func _get_active_cooldown_from_slot(slot : int) -> TextureProgressBar:
   var cooldown_bar : TextureProgressBar = L_ACTIVE_CLDN if slot == 0 else R_ACTIVE_CLDN
   return cooldown_bar
## Used to differentiate between different active slots. Extensible if we add more active slots.
func _get_active_icon_from_slot(slot : int) -> Sprite2D:
   var icon : Sprite2D = L_ACTIVE_ICON if slot == 0 else R_ACTIVE_ICON
   return icon

# ============= #
#   healthbar   #
# ============= #

## Pass value and boolean data to the Healthbar
func update_healthbar(v : Array[float], b : bool = false): HEALTHBAR.update_display(v,b)

# ===================== #
#  inspect and prompts  #
# ===================== #

## Recieves an Interactable from the player while their raycast is looking at one. Used to display class data to player.
func show_interactable_info(obj : Interactable):
   CURSOR.position = get_viewport_rect().size / 2
   CURSOR.visible = true
   if obj is ClassBook:
      CURSOR.get_child(0).get_child(0).get_child(0).text = "CLASS"
      CURSOR.get_child(0).get_child(0).get_child(1).text = ClassData.ClassRecipes.get(obj.ClassID).get(ClassData.ClassFields.NAME)
      CURSOR.get_child(0).get_child(0).get_child(1).label_settings = LabelSettings.new()
      CURSOR.get_child(0).get_child(0).get_child(1).label_settings.font_color = obj.book_color
      CURSOR.get_child(0).get_child(0).get_child(2).text = "[font_size=" + str(SettingsManager.personal_settings.TEXTSIZE) + "]" + ClassData.ClassRecipes.get(obj.ClassID).get(ClassData.ClassFields.DESCRIPTION) +"[/font_size]"
   elif obj is Prism:
      CURSOR.get_child(0).get_child(0).get_child(0).text = "a unique"
      CURSOR.get_child(0).get_child(0).get_child(1).text = "SPELL PRISM"
      CURSOR.get_child(0).get_child(0).get_child(1).label_settings = LabelSettings.new()
      CURSOR.get_child(0).get_child(0).get_child(1).label_settings.font_color = Color.WHITE
      CURSOR.get_child(0).get_child(0).get_child(1).label_settings.outline_size = 2
      CURSOR.get_child(0).get_child(0).get_child(1).label_settings.outline_color = Color.HOT_PINK
      CURSOR.get_child(0).get_child(0).get_child(2).text = "[font_size=" + str(SettingsManager.personal_settings.TEXTSIZE) + "]dropped by a defeated player[/font_size]" if obj.is_player_prism else "[font_size=" + str(SettingsManager.personal_settings.TEXTSIZE) + "]spawned into the world[/font_size]"
   else:
      CURSOR.visible = false
func close_interactable_info():
   CURSOR.visible = false
## Changes the visible button prompts on the two active icons and below the passive box to show either keyboard/mouse buttons or controller buttons, depending on whether [member keyboard] is true.
func swap_button_prompts(keyboard : bool):
   for i in range(BUTTONPROMPT_TEXTURERECTS.size()):
      BUTTONPROMPT_TEXTURERECTS[i].texture.region = BUTTONPROMPT_RECT_KYBD[i] if keyboard else BUTTONPROMPT_RECT_CTRL[i]
