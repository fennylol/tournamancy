extends Control
class_name PrismMenu

@onready var SPELL_GRIDMAP  : GridContainer = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/GridContainer
@onready var BUTTON_REROLL  : Button        = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Reroll
@onready var BUTTON_CONFIRM : Button        = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Confirm
@onready var BUTTON_CANCEL  : Button        = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainerD/VBoxContainer/Button_Cancel

@onready var SpellSlotInstance : PackedScene = load("res://0_maps/assets/interactables/prism/prism_spell_instance.tscn")

signal close_menu()

var ActiveSpellList : Array[SpellData.ActiveSpellIDs]
var PassiveSpellList : Array[SpellData.PassiveSpellIDs]
var SlotTextureList : Array[TextureRect]
var SlotButtonList : Array[TextureButton]
var CurrentButton : Control

var current_slot_count : int = 0
var reroll_count : int = 0

func _ready() -> void: get_viewport().gui_focus_changed.connect(_on_focus_changed)
func setup() -> void:
   current_slot_count = SettingsManager.match_settings.DEFAULT_PRISM_SHOW_COUNT
   gridmap_setup(current_slot_count)
   SlotButtonList[0].grab_focus()
   roll_slots()

func import_spells( activespells : Array[SpellData.ActiveSpellIDs] , passivespells : Array[SpellData.PassiveSpellIDs] ):
   ActiveSpellList = activespells
   PassiveSpellList = passivespells

func gridmap_setup(slot_number : int):
   ## CLEAR PREVIOUS SPELL SLOTS
   for i in SPELL_GRIDMAP.get_children(): i.queue_free()
   ## RESIZE GRID AND FILL WITH SPELL SLOTS
   SPELL_GRIDMAP.columns = ceil( slot_number / floor( sqrt( slot_number ) ) )
   SlotButtonList.resize(slot_number)
   SlotTextureList.resize(slot_number)
   for i in range(slot_number):
      var new_slot_instance = SpellSlotInstance.instantiate()
      SPELL_GRIDMAP.add_child(new_slot_instance)
      new_slot_instance.name = "Spell Slot " + str(i)
      SlotTextureList[i] = new_slot_instance.get_child(0) as TextureRect
      SlotButtonList[i] = new_slot_instance.get_child(0).get_child(1) as TextureButton
   ## CONNECT BUTTONS TOGETHER
   for i in range(SlotButtonList.size()):
      SlotButtonList[i].pressed.connect(_on_spell_icon_button_pressed)
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
   pass

func _process(_delta: float) -> void:
   if Input.is_action_just_pressed("select"):
      if CurrentButton is Button: CurrentButton.pressed.emit()
      if CurrentButton is TextureButton: _on_spell_icon_button_pressed()

func _on_focus_changed(control: Control) -> void: CurrentButton = control
func _on_button_reroll_pressed() -> void:
   if reroll_count < SettingsManager.match_settings.PRISM_REROLL_COUNT:
      reroll_count += 1
      current_slot_count = SettingsManager.match_settings.DEFAULT_PRISM_SHOW_COUNT - ( reroll_count * SettingsManager.match_settings.PRISM_REROLL_DECREMENT )
      gridmap_setup(current_slot_count)
      roll_slots()
func _on_button_confirm_pressed() -> void:
   pass
func _on_button_cancel_pressed() -> void:
   close_menu.emit()

func _on_spell_icon_button_pressed() ->void:
   print(CurrentButton, " pressed")
