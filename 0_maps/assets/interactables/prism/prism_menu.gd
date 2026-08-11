extends Control
class_name PrismMenu

@onready var SPELL_GRIDMAP  : GridContainer = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/GridContainer
@onready var BUTTON_REROLL  : Button        = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Reroll
@onready var BUTTON_CONFIRM : Button        = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Confirm
@onready var BUTTON_CANCEL  : Button        = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Cancel

@onready var SpellSlotInstance : PackedScene = load("res://0_maps/assets/interactables/prism/prism_spell_instance.tscn")

const ICONMARGIN : Rect2 = Rect2(8,8,16,16)

var CurrentActivePrism : Prism

signal close_menu()

var SlotTextureList : Array[TextureRect]
var SlotButtonList : Array[TextureButton]
var SlotIsActive_List : Array[bool]
var CurrentButton : Control

var ActiveSpellList : Array[SpellData.ActiveSpellIDs]
var PassiveSpellList : Array[SpellData.PassiveSpellIDs]
var selected_active_list : Array[SpellData.ActiveSpellIDs] = []
var selected_passive_list : Array[SpellData.PassiveSpellIDs] = []
var passed_active_spell_list : Array[SpellData.ActiveSpellIDs] = []
var passed_passive_spell_list : Array[SpellData.PassiveSpellIDs] = []

var current_slot_count : int = 0
var reroll_count : int = 0

# ========= #
#   setup   #
# ========= #

func _ready() -> void: get_viewport().gui_focus_changed.connect(_on_focus_changed)
func setup(the_prism_in_question : Prism) -> void:
   CurrentActivePrism = the_prism_in_question
   ActiveSpellList = CurrentActivePrism.get_active_spells()
   PassiveSpellList = CurrentActivePrism.get_passive_spells()
   current_slot_count = SettingsManager.match_settings.DEFAULT_PRISM_SHOW_COUNT
   reroll_count = 0
   BUTTON_REROLL.disabled = false
   BUTTON_REROLL.text = "REROLL (" + str(SettingsManager.match_settings.PRISM_REROLL_COUNT) + ")"
   gridmap_setup(current_slot_count)
   SlotButtonList[0].grab_focus()
   roll_slots()
func gridmap_setup(slot_number : int):
   ## CLEAR PREVIOUS SPELL SLOTS
   for i in SPELL_GRIDMAP.get_children(): i.queue_free()
   ## RESIZE GRID AND FILL WITH SPELL SLOTS
   SPELL_GRIDMAP.columns = ceil( slot_number / floor( sqrt( slot_number ) ) )
   for i : Array in [SlotTextureList, SlotButtonList, SlotIsActive_List]: i.resize(slot_number)
   for i in range(slot_number):
      var new_slot_instance = SpellSlotInstance.instantiate()
      SPELL_GRIDMAP.add_child(new_slot_instance)
      new_slot_instance.name = "Spell Slot " + str(i)
      SlotTextureList[i] = new_slot_instance.get_child(0) as TextureRect
      SlotButtonList[i] = new_slot_instance.get_child(0).get_child(1) as TextureButton
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
            if chosen_value <= 0:
               slot_position = j
               SlotIsActive_List[i] = false
               break
         if slot_position == -1:
            printerr("Slot position not found based on rolled value")
            return
      
      ## GET ID AND UPDATE TEXTURE
      @warning_ignore("incompatible_ternary")
      var spell_id = ActiveSpellList[slot_position] if SlotIsActive_List[i] == true else PassiveSpellList[slot_position]
      var new_texture = AtlasTexture.new()
      new_texture.margin = ICONMARGIN
      new_texture.atlas = load(SpellData.ActiveSpells.get(spell_id).get(SpellData.SpellFields.IconPath)) if SlotIsActive_List[i] == true else load(SpellData.PassiveSpells.get(spell_id).get(SpellData.SpellFields.IconPath))
      new_texture.region = SpellData.ActiveSpells.get(spell_id).get(SpellData.SpellFields.IconRect) if SlotIsActive_List[i] == true else load(SpellData.PassiveSpells.get(spell_id).get(SpellData.SpellFields.IconRect))
      SlotTextureList[i].texture = new_texture
      
      ## REMOVE FROM POOL
      ## need to find a way to keep this from bricking the program if it empties the array
      if SlotIsActive_List[i] == true:
         ActiveSpellList.pop_at(slot_position)
      else:
         PassiveSpellList.pop_at(slot_position)
      

# =============== #
#   interaction   #
# =============== #

func _process(_delta: float) -> void:
   if Input.is_action_just_pressed("select"):
      if CurrentButton is Button: CurrentButton.pressed.emit()
      if CurrentButton is TextureButton: _on_spell_icon_button_pressed()
func _on_spell_icon_button_pressed() ->void:
   CurrentButton.get_parent().find_child("Selected").visible = not CurrentButton.get_parent().find_child("Selected").visible
   if CurrentButton.get_parent().find_child("Selected").visible:
      print(CurrentButton, " selected")
   else:
      print(CurrentButton, " de-selected")

func _on_button_reroll_pressed() -> void:
   if reroll_count < SettingsManager.match_settings.PRISM_REROLL_COUNT:
      reroll_count += 1
      current_slot_count = SettingsManager.match_settings.DEFAULT_PRISM_SHOW_COUNT - ( reroll_count * SettingsManager.match_settings.PRISM_REROLL_DECREMENT )
      gridmap_setup(current_slot_count)
      roll_slots()
   BUTTON_REROLL.text = "REROLL (" + str(SettingsManager.match_settings.PRISM_REROLL_COUNT - reroll_count) + ")"
   if reroll_count >= SettingsManager.match_settings.PRISM_REROLL_COUNT: BUTTON_REROLL.disabled = true
func _on_button_confirm_pressed() -> void:
   pass
func _on_button_cancel_pressed() -> void:
   close_menu.emit(CurrentActivePrism)

# =========================== #
#  background button handling #
# =========================== #

func _on_focus_changed(control: Control) -> void: CurrentButton = control
func _on_spell_icon_mouseover(button : TextureButton): button.grab_focus()
func _on_button_reroll_mouse_entered() -> void: BUTTON_REROLL.grab_focus()
func _on_button_confirm_mouse_entered() -> void: BUTTON_CONFIRM.grab_focus()
func _on_button_cancel_mouse_entered() -> void: BUTTON_CANCEL.grab_focus()
