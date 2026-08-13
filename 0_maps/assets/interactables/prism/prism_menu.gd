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

#var SlotTextureList   : Array[TextureRect]
#var SlotButtonList    : Array[TextureButton]
#var SlotLabelList     : Array[Label]
#var SlotIsActive_List : Array[bool]
#var SlotIDList        : Array[int]
#var ActiveSpellList           : Array[SpellData.ActiveSpellIDs]  = []
#var PassiveSpellList          : Array[SpellData.PassiveSpellIDs] = []
#var PassiveSpellStacks        : Array[int]                       = []
#var selected_active_list      : Array[SpellData.ActiveSpellIDs]  = []
#var selected_passive_list     : Array[SpellData.PassiveSpellIDs] = []
#var selected_passive_stacks   : Array[int]                       = []

var SpellList    : Array[PrismSlotCounter] = []
var SlotPointers : Array[PrismSlotCounter] = []
var passive_spell_offset : int = 0

var CurrentButton : Control
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
   SpellList.clear()
   for i : ActiveSpell in CurrentActivePrism.get_active_spells():
      var new_slot_counter = PrismSlotCounter.new()
      new_slot_counter.is_active = true
      new_slot_counter.ActiveSpellID = i.SpellID
      new_slot_counter.Weight = SettingsManager.match_settings.ACTIVE_SPELL_WEIGHTS.get(new_slot_counter.ActiveSpellID) if SettingsManager.match_settings.ACTIVE_SPELL_WEIGHTS.has(new_slot_counter.ActiveSpellID) else 0
      # the folling line adds mercy weights, but first we need some way to determine how many times the player has been defeated.
      #new_slot_counter.Weight += ( SettingsManager.match_settings.ACTIVE_MERCY_WEIGHTS.get(new_slot_counter.ActiveSpellID) * _defeatcount) if SettingsManager.match_settings.ACTIVE_MERCY_WEIGHTS.has(new_slot_counter.ActiveSpellID) else 0
      SpellList.append(new_slot_counter)
   passive_spell_offset = SpellList.size()
   for i : PassiveSpell in CurrentActivePrism.get_passive_spells():
      var new_slot_counter = PrismSlotCounter.new()
      new_slot_counter.is_active = false
      new_slot_counter.PassiveSpellID = i.SpellID
      new_slot_counter.Stacks = i.Stacks
      new_slot_counter.Weight = SettingsManager.match_settings.PASSIVE_SPELL_WEIGHTS.get(new_slot_counter.PassiveSpellID) if SettingsManager.match_settings.PASSIVE_SPELL_WEIGHTS.has(new_slot_counter.PassiveSpellID) else 0
      # the folling line adds mercy weights, but first we need some way to determine how many times the player has been defeated.
      #new_slot_counter.Weight += ( SettingsManager.match_settings.PASSIVE_MERCY_WEIGHTS.get(new_slot_counter.PassiveSpellID) * _defeatcount) if SettingsManager.match_settings.PASSIVE_MERCY_WEIGHTS.has(new_slot_counter.PassiveSpellID) else 0
      SpellList.append(new_slot_counter)
   current_slot_count = SettingsManager.match_settings.DEFAULT_PRISM_SHOW_COUNT
   reroll_count = 0
   BUTTON_REROLL.disabled = false
   BUTTON_CONFIRM.disabled = true if SettingsManager.match_settings.MIN_SPELL_FROM_PRISM > 0 else false
   BUTTON_REROLL.text = "REROLL (" + str(SettingsManager.match_settings.PRISM_REROLL_COUNT) + ")"
   BUTTON_CONFIRM.text = "CONFIRM (" + str(SettingsManager.match_settings.MAX_SPELL_FROM_PRISM) + ")"
   gridmap_setup(current_slot_count)
   roll_slots()
func gridmap_setup(slot_number : int):
   ## CLEAR PREVIOUS SPELL SLOTS
   for i in SPELL_GRIDMAP.get_children(): i.queue_free()
   ## RESIZE GRID AND FILL WITH SPELL SLOTS
   SPELL_GRIDMAP.columns = ceil( slot_number / floor( sqrt( slot_number ) ) )
   SlotPointers.resize(slot_number)
   for i in range(slot_number):
      SlotPointers[i] = PrismSlotCounter.new()
      var new_slot_instance = SpellSlotInstance.instantiate()
      SPELL_GRIDMAP.add_child(new_slot_instance)
      new_slot_instance.name = "Spell Slot " + str(i)
      SlotPointers[i].IconTextureRect   = new_slot_instance.get_child(0)              as TextureRect
      SlotPointers[i].IconTextureButton = new_slot_instance.get_child(0).get_child(1) as TextureButton
      SlotPointers[i].IconLabel         = new_slot_instance.get_child(1)              as Label
   ## CONNECT BUTTONS TOGETHER
   for i in range(slot_number):
      SlotPointers[i].IconTextureButton.pressed.connect(_on_spell_icon_button_pressed)
      SlotPointers[i].IconTextureButton.mouse_entered.connect(_on_spell_icon_mouseover.bind(SlotPointers[i].IconTextureButton))
      if i == 0:
         SlotPointers[i].IconTextureButton.focus_previous = BUTTON_CANCEL.get_path()
         if slot_number > 1: SlotPointers[i].IconTextureButton.focus_next = SlotPointers[i+1].IconTextureButton.get_path()
         BUTTON_REROLL.focus_previous = SlotPointers[i].IconTextureButton.get_path()
      elif i == slot_number - 1:
         SlotPointers[i].IconTextureButton.focus_previous = SlotPointers[i-1].IconTextureButton.get_path()
         SlotPointers[i].IconTextureButton.focus_next = BUTTON_REROLL.get_path()
         BUTTON_CANCEL.focus_next = SlotPointers[i].IconTextureButton.get_path()
      else:
         SlotPointers[i].IconTextureButton.focus_previous = SlotPointers[i-1].IconTextureButton.get_path()
         SlotPointers[i].IconTextureButton.focus_next = SlotPointers[i+1].IconTextureButton.get_path()
   SlotPointers[0].IconTextureButton.grab_focus()
func roll_slots():
   for i in range(current_slot_count):
      ## IF FORCE_ACTIVE_ABILITIES, DETERMINE ACTIVE-PASSIVE
      ## the SlotIsActive array is true at a given position if the spell in that slot should be an active ability
      if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true:
         SlotPointers[i].is_active = true if randf() <= SettingsManager.match_settings.ACTIVE_ABILITIES_PERCENT else false
      
      ## ROLL A RANDOM NUMBER
      ## the weights of relevant spells (depending on FORCE_ACTIVE_ABILITIES and current is_active values) are summed together.
      ## then a random number is generated whose maximum value is equal to the weight sum.
      ## if PRISM_FORCE_ACTIVE_ABILITIES is true, the weight sum is just the weights of passives OR actives. if false, the weight sum is the sum of all spell weights (both passive and active)
      var weight_sum : int = 0
      for j in range(SpellList.size()):
         if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true:
            if     SlotPointers[i].is_active and     SpellList[j].is_active: weight_sum += SpellList[j].Weight
            if not SlotPointers[i].is_active and not SpellList[j].is_active: weight_sum += SpellList[j].Weight
         else:
            weight_sum += SpellList[j].Weight
      var random_number = randi_range(1,weight_sum)
      
      ## CHECK AGAINST WEIGHTS
      ## loop through all the active and passive weights, subtracting their values from the randomly-generated number.
      ## once the generated number reaches 0, the position currently in the loop is the chosen spell
      var slot_position : int = -1
      var offset = passive_spell_offset if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true and not SlotPointers[i].is_active else 0
      for j in range(SpellList.size()):
         random_number -= SpellList[j+offset].Weight
         if random_number <= 0:
            slot_position = j + offset
            break
      if slot_position == -1:
         printerr("Slot position not found. Weight Sum = ", weight_sum, ". Random number reduced to ", random_number, ". See prism_menu.gd roll_slots() to debug.")
         continue
         
      ## GET ID AND UPDATE TEXTURE
      SlotPointers[i].is_active      = SpellList[slot_position].is_active
      SlotPointers[i].ActiveSpellID  = SpellList[slot_position].ActiveSpellID
      SlotPointers[i].PassiveSpellID = SpellList[slot_position].PassiveSpellID
      SlotPointers[i].Stacks         = SpellList[slot_position].Stacks
      SlotPointers[i].slot_location  = slot_position
      var new_texture = AtlasTexture.new()
      new_texture.margin = ICONMARGIN
      new_texture.atlas = load(SpellData.ActiveSpells.get(SlotPointers[i].ActiveSpellID).get(SpellData.SpellFields.IconPath)) if SlotPointers[i].is_active else load(SpellData.PassiveSpells.get(SlotPointers[i].PassiveSpellID).get(SpellData.SpellFields.IconPath))
      new_texture.region = SpellData.ActiveSpells.get(SlotPointers[i].ActiveSpellID).get(SpellData.SpellFields.IconRect) if SlotPointers[i].is_active else SpellData.PassiveSpells.get(SlotPointers[i].PassiveSpellID).get(SpellData.SpellFields.IconRect)
      SlotPointers[i].IconTextureRect.texture = new_texture
      if not SlotPointers[i].is_active:
         SlotPointers[i].IconLabel.visible = true
         SlotPointers[i].IconLabel.text = "x" + str(SlotPointers[i].Stacks)
      
      ## REMOVE FROM POOL
      ## need to find a way to keep this from bricking the program if it empties the array
      pass

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
   var selected_count : int = 0
   for i in SpellList: if i.is_selected: selected_count += 1
   if CurrentButton.get_parent().find_child("Selected").visible == false:
      if selected_count >= SettingsManager.match_settings.MAX_SPELL_FROM_PRISM: return
      CurrentButton.get_parent().find_child("Selected").visible = true
   else: CurrentButton.get_parent().find_child("Selected").visible = false
   
   var slot_number = SlotPointers.find_custom(_is_this_button_current.bind(CurrentButton))
   if CurrentButton.get_parent().find_child("Selected").visible:
      SpellList[SlotPointers[slot_number].slot_location].is_selected = true
      selected_count += 1
   else:
      SpellList[SlotPointers[slot_number].slot_location].is_selected = false
      selected_count -= 1
   BUTTON_CONFIRM.text = "CONFIRM (" + str(SettingsManager.match_settings.MAX_SPELL_FROM_PRISM - selected_count ) + ")" if (SettingsManager.match_settings.MAX_SPELL_FROM_PRISM - selected_count ) != 0 else "CONFIRM"
   BUTTON_CONFIRM.disabled = true if ( selected_count < SettingsManager.match_settings.MIN_SPELL_FROM_PRISM ) or ( selected_count > SettingsManager.match_settings.MAX_SPELL_FROM_PRISM ) else false
func _is_this_button_current(slot : PrismSlotCounter, expected : TextureButton): return slot.IconTextureButton == expected

func _on_button_reroll_pressed() -> void:
   if reroll_count < SettingsManager.match_settings.PRISM_REROLL_COUNT:
      reroll_count += 1
      current_slot_count = SettingsManager.match_settings.DEFAULT_PRISM_SHOW_COUNT - ( reroll_count * SettingsManager.match_settings.PRISM_REROLL_DECREMENT )
      for i in SpellList: i.is_selected = false
      gridmap_setup(current_slot_count)
      roll_slots()
   BUTTON_REROLL.text = "REROLL (" + str(SettingsManager.match_settings.PRISM_REROLL_COUNT - reroll_count) + ")" if (SettingsManager.match_settings.PRISM_REROLL_COUNT - reroll_count) != 0 else "NO REROLLS REMAIN"
   if reroll_count >= SettingsManager.match_settings.PRISM_REROLL_COUNT: BUTTON_REROLL.disabled = true
func _on_button_confirm_pressed() -> void:
   var selected_active_list : Array[SpellData.ActiveSpellIDs] = []
   ## GRANT ALL PASSIVES FIRST
   for i in range(SpellList.size()):
      if SpellList[i].is_selected and not SpellList[i].is_active:
         get_parent().get_parent().request_new_passive_spell(SpellList[i].PassiveSpellID, SpellList[i].Stacks)
         SpellList[i].is_selected = false
      if SpellList[i].is_selected and SpellList[i].is_active:
         selected_active_list.append(SpellList[i].ActiveSpellID)
   ## IF THERE ARE ANY ACTIVES SELECTED, MOVE TO ACTIVE SELECTION MENU
   if selected_active_list != []:
      selecting_active = true
      MAIN_MENU.visible = false
      ACTIVE_MENU.visible = true
      setup_active_spell_chooser(selected_active_list)
   ## ... OTHERWISE, CLOSE MENU
   else:
      close_menu.emit(CurrentActivePrism)
func _on_button_cancel_pressed() -> void:
   ## IF THERE IS ANYTHING SELECTED, DESELECT ALL SPELLS
   
   ## IF THERE IS NOTHING SELECTED, CLOSE THE MENU (IF ALLOWED)
   if true:#SettingsManager.match_settings.MIN_SPELL_FROM_PRISM == 0:
      close_menu.emit(CurrentActivePrism)

# ================================ #
#  active spell selection handling #
# ================================ #

func setup_active_spell_chooser(remaining_spells : Array[SpellData.ActiveSpellIDs]):
   print("remaining spells: ", remaining_spells)
   var id : int = remaining_spells.pop_front()
   print("new id to select: ", id)
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
   ActiveButton_Selected.pressed.disconnect(_on_active_spell_chooser_button_press)
   ActiveButton_Left.pressed.disconnect(_on_active_spell_chooser_button_press)
   ActiveButton_Right.pressed.disconnect(_on_active_spell_chooser_button_press)
   ActiveButton_Selected.pressed.connect(_on_active_spell_chooser_button_press.bind(id, remaining_spells))
   ActiveButton_Left.pressed.connect(_on_active_spell_chooser_button_press.bind(id, remaining_spells, 0))
   ActiveButton_Right.pressed.connect(_on_active_spell_chooser_button_press.bind(id, remaining_spells, 1))
func _on_active_spell_chooser_button_press(new_id : SpellData.ActiveSpellIDs, list : Array[SpellData.ActiveSpellIDs], slot : int = -1,):
   if slot != -1: 
      print("place spell ", new_id, " into slot ", slot, ".")
      get_parent().get_parent().request_new_active_spell(new_id, slot)
   if list == []:
      close_menu.emit(CurrentActivePrism)
   else:
      setup_active_spell_chooser(list)

# =========================== #
#  background button handling #
# =========================== #

func _on_focus_changed(control: Control) -> void: CurrentButton = control
func _on_spell_icon_mouseover(button : TextureButton): button.grab_focus()
func _on_button_reroll_mouse_entered() -> void: BUTTON_REROLL.grab_focus()
func _on_button_confirm_mouse_entered() -> void: BUTTON_CONFIRM.grab_focus()
func _on_button_cancel_mouse_entered() -> void: BUTTON_CANCEL.grab_focus()
