extends Control
class_name PrismMenu

@onready var MAIN_MENU      : HBoxContainer   = $ButtonContainer
@onready var SPELL_GRIDMAP  : GridContainer   = $ButtonContainer/VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/GridContainer
@onready var BUTTON_REROLL  : Button          = $ButtonContainer/VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Reroll
@onready var BUTTON_CONFIRM : Button          = $ButtonContainer/VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Confirm
@onready var BUTTON_CANCEL  : Button          = $ButtonContainer/VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Cancel

@onready var ACTIVE_MENU    : HBoxContainer   = $ActiveConfirm
@onready var ACTIVE_SEL     : CenterContainer = $ActiveConfirm/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/SpellInstance_SELECTED
@onready var ACTIVE_CL      : CenterContainer = $ActiveConfirm/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/SpellInstance_CLEFT
@onready var ACTIVE_CR      : CenterContainer = $ActiveConfirm/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/SpellInstanceCRIGHT

@onready var CURSOR         : Marker2D        = $Cursor

@onready var SpellSlotInstance : PackedScene = load("res://0_maps/assets/interactables/prism/prism_spell_instance.tscn")

const ICONMARGIN : Rect2 = Rect2(8,8,16,16)

var CurrentActivePrism : Prism

signal close_menu()

var SpellSlotPool    : Array[PrismSlotCounter] = []
var SlotPointers : Array[PrismSlotCounter] = []
var passive_spell_offset : int = 0

var CurrentButton : Control
var current_slot_count : int = 0
var reroll_count : int = 0

var accept_inputs    : bool = false

var selecting_active        : bool = false
var ActiveButton_Selected   : TextureButton
var ActiveButton_Left       : TextureButton
var ActiveButton_Right      : TextureButton
var remaining_active_spells : Array[PrismSlotCounter]
var new_active_spell        : PrismSlotCounter

# ========= #
#   setup   #
# ========= #

func _ready() -> void: 
   get_viewport().gui_focus_changed.connect(_on_focus_changed)
   ActiveButton_Selected = ACTIVE_SEL.get_child(0).get_child(1)
   ActiveButton_Left = ACTIVE_CL.get_child(0).get_child(1)
   ActiveButton_Right = ACTIVE_CR.get_child(0).get_child(1)
func setup(the_prism_in_question : Prism) -> void:
   MAIN_MENU.visible = true
   ACTIVE_MENU.visible = false
   CurrentActivePrism = the_prism_in_question
   SpellSlotPool.clear()
   for i : ActiveSpell in CurrentActivePrism.get_active_spells():
      var new_slot_counter = PrismSlotCounter.new()
      new_slot_counter.is_active = true
      new_slot_counter.ActiveSpellID = i.SpellID
      new_slot_counter.Weight = SettingsManager.match_settings.ACTIVE_SPELL_WEIGHTS.get(new_slot_counter.ActiveSpellID) if SettingsManager.match_settings.ACTIVE_SPELL_WEIGHTS.has(new_slot_counter.ActiveSpellID) else 0
      # the folling line adds mercy weights, but first we need some way to determine how many times the player has been defeated.
      #new_slot_counter.Weight += ( SettingsManager.match_settings.ACTIVE_MERCY_WEIGHTS.get(new_slot_counter.ActiveSpellID) * _defeatcount) if SettingsManager.match_settings.ACTIVE_MERCY_WEIGHTS.has(new_slot_counter.ActiveSpellID) else 0
      SpellSlotPool.append(new_slot_counter)
   passive_spell_offset = SpellSlotPool.size()
   for i : PassiveSpell in CurrentActivePrism.get_passive_spells():
      var new_slot_counter = PrismSlotCounter.new()
      new_slot_counter.is_active = false
      new_slot_counter.PassiveSpellID = i.SpellID
      new_slot_counter.Stacks = i.Stacks
      new_slot_counter.Weight = SettingsManager.match_settings.PASSIVE_SPELL_WEIGHTS.get(new_slot_counter.PassiveSpellID) if SettingsManager.match_settings.PASSIVE_SPELL_WEIGHTS.has(new_slot_counter.PassiveSpellID) else 0
      # the folling line adds mercy weights, but first we need some way to determine how many times the player has been defeated.
      #new_slot_counter.Weight += ( SettingsManager.match_settings.PASSIVE_MERCY_WEIGHTS.get(new_slot_counter.PassiveSpellID) * _defeatcount) if SettingsManager.match_settings.PASSIVE_MERCY_WEIGHTS.has(new_slot_counter.PassiveSpellID) else 0
      SpellSlotPool.append(new_slot_counter)
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
      SlotPointers[i].IconTextureButton.mouse_entered.connect(_on_spell_icon_mouseover.bind(SlotPointers[i]))
      SlotPointers[i].IconTextureButton.mouse_exited.connect(_on_spell_icon_mouse_exit)
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
   accept_inputs = false
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
      for j in range(SpellSlotPool.size()):
         if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true:
            if     SlotPointers[i].is_active and     SpellSlotPool[j].is_active: weight_sum += SpellSlotPool[j].Weight
            if not SlotPointers[i].is_active and not SpellSlotPool[j].is_active: weight_sum += SpellSlotPool[j].Weight
         else:
            weight_sum += SpellSlotPool[j].Weight
      var random_number = randi_range(1,weight_sum)
      
      ## CHECK AGAINST WEIGHTS
      ## loop through all the active and passive weights, subtracting their values from the randomly-generated number.
      ## once the generated number reaches 0, the position currently in the loop is the chosen spell
      var slot_position : int = -1
      var offset = passive_spell_offset if SettingsManager.match_settings.PRISM_FORCE_ACTIVE_ABILITIES == true and not SlotPointers[i].is_active else 0
      for j in range(SpellSlotPool.size()):
         random_number -= SpellSlotPool[j+offset].Weight
         if random_number <= 0:
            slot_position = j + offset
            break
      if slot_position == -1:
         printerr("Slot position not found. Weight Sum = ", weight_sum, ". Random number reduced to ", random_number, ". See prism_menu.gd roll_slots() to debug.")
         continue
         
      ## GET ID AND UPDATE TEXTURE
      SlotPointers[i].is_active      = SpellSlotPool[slot_position].is_active
      SlotPointers[i].ActiveSpellID  = SpellSlotPool[slot_position].ActiveSpellID
      SlotPointers[i].PassiveSpellID = SpellSlotPool[slot_position].PassiveSpellID
      SlotPointers[i].Stacks         = SpellSlotPool[slot_position].Stacks
      SlotPointers[i].slot_location  = slot_position
      var new_texture = AtlasTexture.new()
      new_texture.margin = ICONMARGIN
      new_texture.atlas = SpellList.get_active_spell_data(SlotPointers[i].ActiveSpellID).get(SpellData.SpellFields.IconPath) if SlotPointers[i].is_active else SpellList.get_passive_spell_data(SlotPointers[i].PassiveSpellID).get(SpellData.SpellFields.IconPath)
      new_texture.region = SpellList.get_active_spell_data(SlotPointers[i].ActiveSpellID).get(SpellData.SpellFields.IconRect) if SlotPointers[i].is_active else SpellList.get_passive_spell_data(SlotPointers[i].PassiveSpellID).get(SpellData.SpellFields.IconRect)
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
   if Input.get_last_mouse_velocity() != Vector2.ZERO: CURSOR.position = get_global_mouse_position()
   
   ## Prevent inputs when menu is closed or if it was *just* opened
   if self.visible == false: return
   if accept_inputs == false and ( Input.is_action_just_released("interact") or Input.is_action_just_released("select") ): 
      accept_inputs = true
      _remove_all_selections()
      return
   if accept_inputs == false: return
   
   if Input.is_action_just_pressed("select"):
      if CurrentButton is Button: CurrentButton.pressed.emit()
      if CurrentButton is TextureButton: 
         if selecting_active:
            if accept_inputs == false: return
            match CurrentButton:
               ActiveButton_Selected: _on_active_spell_chooser_button_press(-1)
               ActiveButton_Left:     _on_active_spell_chooser_button_press(0)
               ActiveButton_Right:    _on_active_spell_chooser_button_press(1)
         else:
            _on_spell_icon_button_pressed()
   if Input.is_action_just_released("cancel"): _on_button_cancel_pressed()
   if Input.is_action_just_released("lock"): pass
   if Input.is_action_just_released("reroll"): _on_button_reroll_pressed()
   
   if Input.is_action_just_pressed("cursor_left"): pass
   if Input.is_action_just_pressed("cursor_down"): pass
   if Input.is_action_just_pressed("cursor_right"): pass
   if Input.is_action_just_pressed("cursor_up"): pass
func _on_spell_icon_button_pressed() ->void:
   ## DON'T ALLOW SELECTION IF YOU'VE SELECTED TO MANY, OTHERWISE TOGGLE SELECTED SYMBOL
   var selected_count : int = 0
   for i in SpellSlotPool: if i.is_selected: selected_count += 1
   if CurrentButton.get_parent().find_child("Selected").visible == false:
      if selected_count >= SettingsManager.match_settings.MAX_SPELL_FROM_PRISM: return
      CurrentButton.get_parent().find_child("Selected").visible = true
   else: CurrentButton.get_parent().find_child("Selected").visible = false
   
   var slot_number = SlotPointers.find_custom(_is_this_button_current.bind(CurrentButton))
   if CurrentButton.get_parent().find_child("Selected").visible:
      SpellSlotPool[SlotPointers[slot_number].slot_location].is_selected = true
      selected_count += 1
   else:
      SpellSlotPool[SlotPointers[slot_number].slot_location].is_selected = false
      selected_count -= 1
   BUTTON_CONFIRM.text = "CONFIRM (" + str(SettingsManager.match_settings.MAX_SPELL_FROM_PRISM - selected_count ) + ")" if (SettingsManager.match_settings.MAX_SPELL_FROM_PRISM - selected_count ) != 0 else "CONFIRM"
   BUTTON_CONFIRM.disabled = true if ( selected_count < SettingsManager.match_settings.MIN_SPELL_FROM_PRISM ) or ( selected_count > SettingsManager.match_settings.MAX_SPELL_FROM_PRISM ) else false
func _is_this_button_current(slot : PrismSlotCounter, expected : TextureButton): return slot.IconTextureButton == expected
func _remove_all_selections():
   for i in range(SpellSlotPool.size()):
      SpellSlotPool[i].is_selected = false
   for i in range(SlotPointers.size()):
      SlotPointers[i].IconTextureRect.find_child("Selected").visible = false

func _on_button_reroll_pressed() -> void:
   if reroll_count < SettingsManager.match_settings.PRISM_REROLL_COUNT:
      reroll_count += 1
      current_slot_count = SettingsManager.match_settings.DEFAULT_PRISM_SHOW_COUNT - ( reroll_count * SettingsManager.match_settings.PRISM_REROLL_DECREMENT )
      for i in SpellSlotPool: i.is_selected = false
      gridmap_setup(current_slot_count)
      roll_slots()
   BUTTON_REROLL.text = "REROLL (" + str(SettingsManager.match_settings.PRISM_REROLL_COUNT - reroll_count) + ")" if (SettingsManager.match_settings.PRISM_REROLL_COUNT - reroll_count) != 0 else "NO REROLLS REMAIN"
   if reroll_count >= SettingsManager.match_settings.PRISM_REROLL_COUNT: BUTTON_REROLL.disabled = true
func _on_button_confirm_pressed() -> void:
   var selected_active_list : Array[PrismSlotCounter] = []
   ## GRANT ALL PASSIVES FIRST
   for i in range(SpellSlotPool.size()):
      if SpellSlotPool[i].is_selected and not SpellSlotPool[i].is_active:
         get_parent().get_parent().request_new_passive_spell(SpellSlotPool[i].PassiveSpellID, SpellSlotPool[i].Stacks)
         SpellSlotPool[i].is_selected = false
      if SpellSlotPool[i].is_selected and SpellSlotPool[i].is_active:
         selected_active_list.append(SpellSlotPool[i].duplicate_self())
   ## IF THERE ARE ANY ACTIVES SELECTED, MOVE TO ACTIVE SELECTION MENU
   if selected_active_list != []:
      selecting_active = true
      MAIN_MENU.visible = false
      ACTIVE_MENU.visible = true
      remaining_active_spells = selected_active_list
      setup_active_spell_chooser()
   ## ... OTHERWISE, CLOSE MENU
   else:
      _attempt_close_menu()
func _on_button_cancel_pressed() -> void:
   ## IF THERE IS ANYTHING SELECTED, DESELECT ALL SPELLS
   
   ## IF THERE IS NOTHING SELECTED, CLOSE THE MENU (IF ALLOWED)
   if true:#SettingsManager.match_settings.MIN_SPELL_FROM_PRISM == 0:
      _attempt_close_menu()
func _attempt_close_menu():
   accept_inputs = false
   close_menu.emit(CurrentActivePrism)

# ======================== #
#   inspect descriptions   #
# ======================== #

func _setup_description_box(spell : PrismSlotCounter):
   if ( spell.is_active and spell.ActiveSpellID == SpellData.ActiveSpellIDs.ERROR ) or ( not spell.is_active and spell.PassiveSpellID == SpellData.PassiveSpellIDs.ERROR ):
      for i in CURSOR.get_child(0).get_child(0).get_children():
         i.text = ""
      CURSOR.get_child(0).get_child(0).get_child(1).text = "Empty Hand"
   else:
      var spell_name : String = SpellList.get_active_spell_data(spell.ActiveSpellID).get(SpellData.SpellFields.Name) if spell.is_active else SpellList.get_passive_spell_data(spell.PassiveSpellID).get(SpellData.SpellFields.Name)
      var spell_desc : String = SpellList.get_active_spell_data(spell.ActiveSpellID).get(SpellData.SpellFields.Description) if spell.is_active else SpellList.get_passive_spell_data(spell.PassiveSpellID).get(SpellData.SpellFields.Description)
      CURSOR.get_child(0).get_child(0).get_child(0).text = "ACTIVE" if spell.is_active else "PASSIVE"
      CURSOR.get_child(0).get_child(0).get_child(0).label_settings.font_color = Color.ORANGE if spell.is_active else Color.CYAN
      CURSOR.get_child(0).get_child(0).get_child(1).text = spell_name
      CURSOR.get_child(0).get_child(0).get_child(2).text = "[font_size=" + str(SettingsManager.personal_settings.TEXTSIZE) + "]" + spell_desc + "[/font_size]"

# ================================ #
#  active spell selection handling #
# ================================ #

func setup_active_spell_chooser():
   accept_inputs = false
   new_active_spell = remaining_active_spells.pop_front()
   ## SELECTED SPELL TEXTURE
   new_active_spell.IconTextureButton = ActiveButton_Selected
   new_active_spell.atlastexture.margin = ICONMARGIN
   new_active_spell.atlastexture.atlas = SpellList.get_active_spell_data(new_active_spell.ActiveSpellID).get(SpellData.SpellFields.IconPath)
   new_active_spell.atlastexture.region = SpellList.get_active_spell_data(new_active_spell.ActiveSpellID).get(SpellData.SpellFields.IconRect)
   ACTIVE_SEL.get_child(0).texture = new_active_spell.atlastexture
   ActiveButton_Left.grab_focus()
   
   ## CURRENT SPELLS TEXTURE
   ## if we add more active ability slots beyond just left and right hand, we'll have to refactor how we calculate 
   ## current_slots.resize() and ACTIVE_CL.get_child(0).texture (and also _CR)
   var current_slots : Array[PrismSlotCounter]
   current_slots.resize(2)
   for i in range(current_slots.size()):
      current_slots[i] = PrismSlotCounter.new()
      current_slots[i].ActiveSpellID = get_parent().get_parent().get_active(i)
      if current_slots[i].ActiveSpellID == SpellData.ActiveSpellIDs.ERROR:
         current_slots[i].atlastexture.atlas = load("res://0_maps/assets/interactables/prism/prism_buttons.png")
         current_slots[i].atlastexture.region = Rect2((48*i),48,48,48)
      else:
         current_slots[i].atlastexture.margin = ICONMARGIN
         current_slots[i].atlastexture.atlas = SpellList.get_active_spell_data(current_slots[i].ActiveSpellID).get(SpellData.SpellFields.IconPath)
         current_slots[i].atlastexture.region = SpellList.get_active_spell_data(current_slots[i].ActiveSpellID).get(SpellData.SpellFields.IconRect)
   current_slots[0].IconTextureButton = ActiveButton_Left
   current_slots[1].IconTextureButton = ActiveButton_Right
   ACTIVE_CL.get_child(0).texture = current_slots[0].atlastexture
   ACTIVE_CR.get_child(0).texture = current_slots[1].atlastexture
   
   ## BUTTON SETUP
   if ActiveButton_Selected.mouse_entered.has_connections(): ActiveButton_Selected.mouse_entered.disconnect(_on_spell_icon_mouseover)
   if ActiveButton_Left.mouse_entered.has_connections(): ActiveButton_Left.mouse_entered.disconnect(_on_spell_icon_mouseover)
   if ActiveButton_Right.mouse_entered.has_connections(): ActiveButton_Right.mouse_entered.disconnect(_on_spell_icon_mouseover)
   ActiveButton_Selected.mouse_entered.connect(_on_spell_icon_mouseover.bind(new_active_spell))
   ActiveButton_Left.mouse_entered.connect(_on_spell_icon_mouseover.bind(current_slots[0]))
   ActiveButton_Right.mouse_entered.connect(_on_spell_icon_mouseover.bind(current_slots[1]))
   if ActiveButton_Selected.mouse_exited.has_connections(): ActiveButton_Selected.mouse_exited.disconnect(_on_spell_icon_mouse_exit)
   if ActiveButton_Left.mouse_exited.has_connections(): ActiveButton_Left.mouse_exited.disconnect(_on_spell_icon_mouse_exit)
   if ActiveButton_Right.mouse_exited.has_connections(): ActiveButton_Right.mouse_exited.disconnect(_on_spell_icon_mouse_exit)
   ActiveButton_Selected.mouse_exited.connect(_on_spell_icon_mouse_exit)
   ActiveButton_Left.mouse_exited.connect(_on_spell_icon_mouse_exit)
   ActiveButton_Right.mouse_exited.connect(_on_spell_icon_mouse_exit)
   if ActiveButton_Selected.pressed.has_connections(): ActiveButton_Selected.pressed.disconnect(_on_active_spell_chooser_button_press)
   if ActiveButton_Left.pressed.has_connections(): ActiveButton_Left.pressed.disconnect(_on_active_spell_chooser_button_press)
   if ActiveButton_Right.pressed.has_connections(): ActiveButton_Right.pressed.disconnect(_on_active_spell_chooser_button_press)
   ActiveButton_Selected.pressed.connect(_on_active_spell_chooser_button_press.bind(-1))
   ActiveButton_Left.pressed.connect(_on_active_spell_chooser_button_press.bind(0))
   ActiveButton_Right.pressed.connect(_on_active_spell_chooser_button_press.bind(1))
func _on_active_spell_chooser_button_press(slot : int = -1,):
   if slot != -1: 
      get_parent().get_parent().request_new_active_spell(new_active_spell.ActiveSpellID, slot)
   if remaining_active_spells == []:
      _attempt_close_menu()
   else:
      setup_active_spell_chooser()

# =========================== #
#  background button handling #
# =========================== #

func _on_focus_changed(control: Control) -> void: CurrentButton = control
func _on_spell_icon_mouseover(spellslot : PrismSlotCounter):
   spellslot.IconTextureButton.grab_focus()
   CURSOR.visible = true
   _setup_description_box(spellslot)
func _on_spell_icon_mouse_exit():
   CURSOR.visible = false
func _on_button_reroll_mouse_entered() -> void: BUTTON_REROLL.grab_focus()
func _on_button_confirm_mouse_entered() -> void: BUTTON_CONFIRM.grab_focus()
func _on_button_cancel_mouse_entered() -> void: BUTTON_CANCEL.grab_focus()
