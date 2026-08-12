extends Control
class_name PrismMenu

@onready var MAIN_MENU      : HBoxContainer   = $ButtonContainer
@onready var SPELL_GRIDMAP  : GridContainer   = $ButtonContainer/VBoxContainer/HBoxContainer/VBoxContainer/GridContainer
@onready var BUTTON_REROLL  : Button          = $ButtonContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Reroll
@onready var BUTTON_CONFIRM : Button          = $ButtonContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Confirm
@onready var BUTTON_CANCEL  : Button          = $ButtonContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Cancel

@onready var ACTIVE_MENU    : HBoxContainer   = $ActiveConfirm
@onready var ACTIVE_SEL     : CenterContainer = $ActiveConfirm/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/SpellInstance_SELECTED
@onready var ACTIVE_CL      : CenterContainer = $ActiveConfirm/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/SpellInstance_CLEFT
@onready var ACTIVE_CR      : CenterContainer = $ActiveConfirm/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/SpellInstanceCRIGHT

@onready var SpellSlotInstance : PackedScene = load("res://0_maps/assets/interactables/prism/prism_spell_instance.tscn")

const ICONMARGIN : Rect2 = Rect2(8,8,16,16)

var CurrentActivePrism : Prism

signal close_menu()

var SlotTextureList   : Array[TextureRect]
var SlotButtonList    : Array[TextureButton]
var SlotLabelList     : Array[Label]
var SlotIsActive_List : Array[bool]
var SlotIDList        : Array[int]
var CurrentButton : Control

var ActiveSpellList           : Array[SpellData.ActiveSpellIDs]  = []
var PassiveSpellList          : Array[SpellData.PassiveSpellIDs] = []
var PassiveSpellStacks        : Array[int]                       = []
var selected_active_list      : Array[SpellData.ActiveSpellIDs]  = []
var selected_passive_list     : Array[SpellData.PassiveSpellIDs] = []
var selected_passive_stacks   : Array[int]                       = []
#var passed_active_spell_list  : Array[SpellData.ActiveSpellIDs]  = []
#var passed_passive_spell_list : Array[SpellData.PassiveSpellIDs] = []

var current_slot_count : int = 0
var reroll_count : int = 0

var selecting_active : bool = false
var ActiveButton_Selected : TextureButton
var ActiveButton_Left     : TextureButton
var ActiveButton_Right    : TextureButton

# ========= #
#   setup   #
# ========= #

func _ready() -> void: 
   get_viewport().gui_focus_changed.connect(_on_focus_changed)
   ActiveButton_Selected = ACTIVE_SEL.get_child(0).get_child(1)
   ActiveButton_Left = ACTIVE_CL.get_child(0).get_child(1)
   ActiveButton_Right = ACTIVE_CR.get_child(0).get_child(1)
   ActiveButton_Selected.mouse_entered.connect(_on_spell_icon_mouseover.bind(ActiveButton_Selected))
   ActiveButton_Left.mouse_entered.connect(_on_spell_icon_mouseover.bind(ActiveButton_Left))
   ActiveButton_Right.mouse_entered.connect(_on_spell_icon_mouseover.bind(ActiveButton_Right))
func setup(the_prism_in_question : Prism) -> void:
   MAIN_MENU.visible = true
   ACTIVE_MENU.visible = false
   CurrentActivePrism = the_prism_in_question
   ActiveSpellList = CurrentActivePrism.get_active_spells()
   PassiveSpellList = CurrentActivePrism.get_passive_spells()
   PassiveSpellStacks = CurrentActivePrism.get_passive_stacks()
   PassiveSpellStacks.resize(PassiveSpellList.size())
   current_slot_count = SettingsManager.match_settings.DEFAULT_PRISM_SHOW_COUNT
   reroll_count = 0
   BUTTON_REROLL.disabled = false
   BUTTON_CONFIRM.disabled = true if SettingsManager.match_settings.MIN_SPELL_FROM_PRISM > 0 else false
   BUTTON_REROLL.text = "REROLL (" + str(SettingsManager.match_settings.PRISM_REROLL_COUNT) + ")"
   BUTTON_CONFIRM.text = "CONFIRM (" + str(SettingsManager.match_settings.MAX_SPELL_FROM_PRISM) + ")"
   gridmap_setup(current_slot_count)
   SlotButtonList[0].grab_focus()
   roll_slots()
func gridmap_setup(slot_number : int):
   ## CLEAR PREVIOUS SPELL SLOTS
   for i in SPELL_GRIDMAP.get_children(): i.queue_free()
   ## RESIZE GRID AND FILL WITH SPELL SLOTS
   SPELL_GRIDMAP.columns = ceil( slot_number / floor( sqrt( slot_number ) ) )
   for i : Array in [SlotTextureList, SlotButtonList, SlotLabelList, SlotIsActive_List, SlotIDList]: i.resize(slot_number)
   for i in range(slot_number):
      var new_slot_instance = SpellSlotInstance.instantiate()
      SPELL_GRIDMAP.add_child(new_slot_instance)
      new_slot_instance.name = "Spell Slot " + str(i)
      SlotTextureList[i] = new_slot_instance.get_child(0) as TextureRect
      SlotButtonList[i] = new_slot_instance.get_child(0).get_child(1) as TextureButton
      SlotLabelList[i] = new_slot_instance.get_child(1) as Label
   ## CONNECT BUTTONS TOGETHER
   for i in range(SlotButtonList.size()):
      SlotButtonList[i].pressed.connect(_on_spell_icon_button_pressed)
      SlotButtonList[i].mouse_entered.connect(_on_spell_icon_mouseover.bind(SlotButtonList[i]))
      if i == 0:
         SlotButtonList[i].focus_previous = BUTTON_CANCEL.get_path()
         if slot_number > 1: SlotButtonList[i].focus_next = SlotButtonList[i+1].get_path()
         BUTTON_REROLL.focus_previous = SlotButtonList[i].get_path()
      elif i == slot_number - 1:
         SlotButtonList[i].focus_previous = SlotButtonList[i-1].get_path()
         SlotButtonList[i].focus_next = BUTTON_REROLL.get_path()
         BUTTON_CANCEL.focus_next = SlotButtonList[i].get_path()
      else:
         SlotButtonList[i].focus_previous = SlotButtonList[i-1].get_path()
         SlotButtonList[i].focus_next = SlotButtonList[i+1].get_path()
func roll_slots():
   for i in range(current_slot_count):
      ## IF FORCE_ACTIVE_ABILITIES, DETERMINE ACTIVE-PASSIVE
      ## the SlotIsActive array is true at a given position if the spell in that slot should be an active ability
      if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true:
         SlotIsActive_List[i] = true if randf() <= SettingsManager.match_settings.ACTIVE_ABILITIES_PERCENT else false
      
      ## GET WEIGHTS
      ## loops through the active and passive spell lists and finds their associated spell weights from the match_settings script (if they have one, else 0).
      ## ends with two arrays of integers. Each integer is equal to the weight of the spell in the same position in the Active/PassiveSpellList array.
      ## for example, the spell in position 2 in ActivespellList has the weight in position 2 in active_weight_array.
      var active_weight_array : Array[int] = []
      var passive_weight_array : Array[int] = []
      for j in range(ActiveSpellList.size()):
         if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true and SlotIsActive_List[i] == false: break
         var spell_weight : int = SettingsManager.match_settings.ACTIVE_SPELL_WEIGHTS.get(ActiveSpellList[j]) if SettingsManager.match_settings.ACTIVE_SPELL_WEIGHTS.has(ActiveSpellList[j]) else 0
         # the folling line adds mercy weights, but first we need some way to determine how many times the player has been defeated.
         #spell_weight += ( SettingsManager.match_settings.ACTIVE_MERCY_WEIGHTS.get(ActiveSpellList[j]) * _defeatcount) if SettingsManager.match_settings.ACTIVE_MERCY_WEIGHTS.has(ActiveSpellList[j]) else 0
         active_weight_array.append(spell_weight)
      for j in range(PassiveSpellList.size()):
         if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true and SlotIsActive_List[i] == true: break
         var spell_weight : int = SettingsManager.match_settings.PASSIVE_SPELL_WEIGHTS.get(PassiveSpellList[j]) if SettingsManager.match_settings.PASSIVE_SPELL_WEIGHTS.has(PassiveSpellList[j]) else 0
         # the folling line adds mercy weights, but first we need some way to determine how many times the player has been defeated.
         #spell_weight += ( SettingsManager.match_settings.PASSIVE_MERCY_WEIGHTS.get(PassiveSpellList[j]) * _defeatcount) if SettingsManager.match_settings.PASSIVE_MERCY_WEIGHTS.has(PassiveSpellList[j]) else 0
         passive_weight_array.append(spell_weight)
      
      ## ROLL A RANDOM NUMBER
      ## the weights of the two weight arrays are summed to a single value for each.
      ## then a random number is generated whose maximum value is equal to the weight sum.
      ## if PRISM_FORCE_ACTIVE_ABILITIES is true, the weight sum is one or the other. if false, the weight sum is the sum of all weights (both passive and active)
      var active_weight_sum : int = 0
      var passive_weight_sum : int = 0
      for j in range(active_weight_array.size()): active_weight_sum += active_weight_array[j] if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true and SlotIsActive_List[i] == true else 0
      for j in range(passive_weight_array.size()): passive_weight_sum += passive_weight_array[j] if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true and SlotIsActive_List[i] == false else 0
      var chosen_value = randi_range(1,active_weight_sum+passive_weight_sum) if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == false else randi_range(1,active_weight_sum) if SlotIsActive_List[i] == true else randi_range(1,passive_weight_sum) 
      
      ## CHECK AGAINST WEIGHTS
      ## loop through all the active and passive weights, subtracting their values from the randomly-generated number.
      ## once the generated number reaches 0, the position currently in the loop is the chosen spell
      var slot_position : int = -1
      while slot_position == -1:
         for j in range(active_weight_array.size()):
            if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true and SlotIsActive_List[i] == false: break
            chosen_value -= active_weight_array[j]
            if chosen_value <= 0:
               slot_position = j
               SlotIsActive_List[i] = true
               break
         for j in range(passive_weight_array.size()):
            if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true and SlotIsActive_List[i] == true: break
            chosen_value -= passive_weight_array[j]
            if chosen_value <= 0:
               slot_position = j
               SlotIsActive_List[i] = false
               break
         if slot_position == -1: break
      if slot_position == -1:
         printerr("Slot position not found based on rolled value")
         continue
         
      ## GET ID AND UPDATE TEXTURE
      @warning_ignore("incompatible_ternary")
      var spell_id = ActiveSpellList[slot_position] if SlotIsActive_List[i] == true else PassiveSpellList[slot_position]
      SlotIDList[i] = spell_id
      var new_texture = AtlasTexture.new()
      new_texture.margin = ICONMARGIN
      new_texture.atlas = load(SpellData.ActiveSpells.get(spell_id).get(SpellData.SpellFields.IconPath)) if SlotIsActive_List[i] == true else load(SpellData.PassiveSpells.get(spell_id).get(SpellData.SpellFields.IconPath))
      new_texture.region = SpellData.ActiveSpells.get(spell_id).get(SpellData.SpellFields.IconRect) if SlotIsActive_List[i] == true else SpellData.PassiveSpells.get(spell_id).get(SpellData.SpellFields.IconRect)
      SlotTextureList[i].texture = new_texture
      #if not SlotIsActive_List[i]:
         #SlotLabelList[i].visible = true
         #SlotLabelList[i].text = "x" + str(PassiveSpellStacks[i])
      
      ## REMOVE FROM POOL
      ## need to find a way to keep this from bricking the program if it empties the array
      #if SlotIsActive_List[i] == true:
         #ActiveSpellList.pop_at(slot_position)
      #else:
         #PassiveSpellList.pop_at(slot_position)

# =============== #
#   interaction   #
# =============== #

func _process(_delta: float) -> void:
   if Input.is_action_just_pressed("select"):
      if CurrentButton is Button: CurrentButton.pressed.emit()
      if CurrentButton is TextureButton: 
         if selecting_active:
            pass
         else:
            _on_spell_icon_button_pressed()
func _on_spell_icon_button_pressed() ->void:
   ## DON'T ALLOW SELECTION IF YOU'VE SELECTED TO MANY, OTHERWISE TOGGLE SELECTED SYMBOL
   if CurrentButton.get_parent().find_child("Selected").visible == false:
      if ( selected_active_list.size() + selected_passive_list.size() ) >= SettingsManager.match_settings.MAX_SPELL_FROM_PRISM: return
      CurrentButton.get_parent().find_child("Selected").visible = true
   else: CurrentButton.get_parent().find_child("Selected").visible = false
   
   var slot_number = SlotButtonList.find(CurrentButton)
   if CurrentButton.get_parent().find_child("Selected").visible:
      if SlotIsActive_List[slot_number] == true: selected_active_list.append(SlotIDList[slot_number])
      else: selected_passive_list.append(SlotIDList[slot_number])
   else:
      if SlotIsActive_List[slot_number] == true: selected_active_list.erase(SlotIDList[slot_number])
      else: selected_passive_list.erase(SlotIDList[slot_number])
   var amount_selected : int = ( selected_active_list.size() + selected_passive_list.size() )
   BUTTON_CONFIRM.text = "CONFIRM (" + str(SettingsManager.match_settings.MAX_SPELL_FROM_PRISM - amount_selected ) + ")" if (SettingsManager.match_settings.MAX_SPELL_FROM_PRISM - amount_selected ) != 0 else "CONFIRM"
   BUTTON_CONFIRM.disabled = true if ( amount_selected < SettingsManager.match_settings.MIN_SPELL_FROM_PRISM ) or ( amount_selected > SettingsManager.match_settings.MAX_SPELL_FROM_PRISM ) else false

func _on_button_reroll_pressed() -> void:
   if reroll_count < SettingsManager.match_settings.PRISM_REROLL_COUNT:
      reroll_count += 1
      current_slot_count = SettingsManager.match_settings.DEFAULT_PRISM_SHOW_COUNT - ( reroll_count * SettingsManager.match_settings.PRISM_REROLL_DECREMENT )
      selected_active_list.clear()
      selected_passive_list.clear()
      gridmap_setup(current_slot_count)
      roll_slots()
   BUTTON_REROLL.text = "REROLL (" + str(SettingsManager.match_settings.PRISM_REROLL_COUNT - reroll_count) + ")" if (SettingsManager.match_settings.PRISM_REROLL_COUNT - reroll_count) != 0 else "NO REROLLS REMAIN"
   if reroll_count >= SettingsManager.match_settings.PRISM_REROLL_COUNT: BUTTON_REROLL.disabled = true
func _on_button_confirm_pressed() -> void:
   for i in range(selected_passive_list.size()):
      ## oh no i forgot to figure out stacks
      get_parent().get_parent().request_new_passive_spell(selected_passive_list.pop_front(), 1)
   if selected_active_list != []:
      selecting_active = true
      MAIN_MENU.visible = false
      ACTIVE_MENU.visible = true
      setup_active_spell_chooser(selected_active_list.pop_front())
   else:
      close_menu.emit(CurrentActivePrism)
func _on_button_cancel_pressed() -> void:
   close_menu.emit(CurrentActivePrism)

# ================================ #
#  active spell selection handling #
# ================================ #

func setup_active_spell_chooser(id : SpellData.ActiveSpellIDs):
   ## SELECTED SPELL TEXTURE
   var new_texture_s = AtlasTexture.new()
   new_texture_s.margin = ICONMARGIN
   new_texture_s.atlas = load(SpellData.ActiveSpells.get(id).get(SpellData.SpellFields.IconPath))
   new_texture_s.region = SpellData.ActiveSpells.get(id).get(SpellData.SpellFields.IconRect)
   ACTIVE_SEL.get_child(0).texture = new_texture_s
   
   ## CURRENT SPELLS TEXTURE
   var leftid  : SpellData.ActiveSpellIDs = get_parent().get_parent().get_active(0)
   var rightid : SpellData.ActiveSpellIDs = get_parent().get_parent().get_active(1)
   var new_texture_l = AtlasTexture.new()
   if leftid == SpellData.ActiveSpellIDs.ERROR:
      new_texture_l.atlas = load("res://0_maps/assets/interactables/prism/prism_buttons.png")
      new_texture_l.region = Rect2(0,48,48,48)
   else:
      new_texture_l.margin = ICONMARGIN
      new_texture_l.atlas = load(SpellData.ActiveSpells.get(leftid).get(SpellData.SpellFields.IconPath))
      new_texture_l.region = SpellData.ActiveSpells.get(leftid).get(SpellData.SpellFields.IconRect)
   ACTIVE_CL.get_child(0).texture = new_texture_l
   var new_texture_r = AtlasTexture.new()
   if rightid == SpellData.ActiveSpellIDs.ERROR:
      new_texture_r.atlas = load("res://0_maps/assets/interactables/prism/prism_buttons.png")
      new_texture_r.region = Rect2(96,48,48,48)
   else:
      new_texture_r.margin = ICONMARGIN
      new_texture_r.atlas = load(SpellData.ActiveSpells.get(rightid).get(SpellData.SpellFields.IconPath))
      new_texture_r.region = SpellData.ActiveSpells.get(rightid).get(SpellData.SpellFields.IconRect)
   ACTIVE_CR.get_child(0).texture = new_texture_r
   
   ## BUTTON SETUP
   ActiveButton_Selected.pressed.connect(_on_active_spell_chooser_button_press.bind(id))
   ActiveButton_Left.pressed.connect(_on_active_spell_chooser_button_press.bind(id, 0))
   ActiveButton_Right.pressed.connect(_on_active_spell_chooser_button_press.bind(id, 1))
func _on_active_spell_chooser_button_press(new_id : SpellData.ActiveSpellIDs, slot : int = -1):
   if slot != -1: get_parent().get_parent().request_new_active_spell(new_id, slot)
   if selected_active_list == []:
      close_menu.emit(CurrentActivePrism)
   else:
      setup_active_spell_chooser(selected_active_list.pop_front())

# =========================== #
#  background button handling #
# =========================== #

func _on_focus_changed(control: Control) -> void: CurrentButton = control
func _on_spell_icon_mouseover(button : TextureButton): button.grab_focus()
func _on_button_reroll_mouse_entered() -> void: BUTTON_REROLL.grab_focus()
func _on_button_confirm_mouse_entered() -> void: BUTTON_CONFIRM.grab_focus()
func _on_button_cancel_mouse_entered() -> void: BUTTON_CANCEL.grab_focus()
