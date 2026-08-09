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

var MIN_SPELL_FROM_PRISM         : int
var MAX_SPELL_FROM_PRISM         : int
var DEFAULT_PRISM_SHOW_COUNT     : int
var PRISM_REROLL_COUNT           : int
var PRISM_REROLL_DECREMENT       : int
var MAX_PRISM_REROLL_LOCK        : int
var PRISM_FORCE_ACTIVE_ABILITIES : bool
var ACTIVE_ABILITIES_PERCENT     : float
var ACTIVE_SPELL_WEIGHTS         : Dictionary
var PASSIVE_SPELL_WEIGHTS        : Dictionary
var ACTIVE_MERCY_WEIGHTS         : Dictionary
var PASSIVE_MERCY_WEIGHTS        : Dictionary
var KOS_PER_MERCY_WEIGHT         : int
var MAX_MERCY_WEIGHT_APPLICATION : int

func _ready() -> void: get_viewport().gui_focus_changed.connect(_on_focus_changed)
func setup() -> void:
   current_slot_count = DEFAULT_PRISM_SHOW_COUNT
   gridmap_setup(current_slot_count)
   SlotButtonList[0].grab_focus()
   roll_slots()

func import_match_settings( min_spell_from_prism : int , max_spell_from_prism : int , default_prism_show_count : int , \
                           prism_reroll_count : int , prism_reroll_decrement : int , max_prism_reroll_lock: int , \
                           prism_force_active_abilities : bool , active_abilities_percent : float , active_spell_weights : Dictionary, \
                           passive_spell_weights : Dictionary, active_mercy_weights : Dictionary, passive_mercy_weights : Dictionary, \
                           kos_per_mercy_weight : int , max_mercy_weight_application : int ):
   MIN_SPELL_FROM_PRISM = min_spell_from_prism
   MAX_SPELL_FROM_PRISM = max_spell_from_prism
   DEFAULT_PRISM_SHOW_COUNT = default_prism_show_count
   PRISM_REROLL_COUNT = prism_reroll_count
   PRISM_REROLL_DECREMENT = prism_reroll_decrement
   MAX_PRISM_REROLL_LOCK = max_prism_reroll_lock
   PRISM_FORCE_ACTIVE_ABILITIES = prism_force_active_abilities
   ACTIVE_ABILITIES_PERCENT = active_abilities_percent
   ACTIVE_SPELL_WEIGHTS = active_spell_weights
   PASSIVE_SPELL_WEIGHTS = passive_spell_weights
   ACTIVE_MERCY_WEIGHTS = active_mercy_weights
   PASSIVE_MERCY_WEIGHTS = passive_mercy_weights
   KOS_PER_MERCY_WEIGHT = kos_per_mercy_weight
   MAX_MERCY_WEIGHT_APPLICATION = max_mercy_weight_application
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

func _process(delta: float) -> void:
   if Input.is_action_just_pressed("select"):
      if CurrentButton is Button: CurrentButton.pressed.emit()
      if CurrentButton is TextureButton: _on_spell_icon_button_pressed()

func _on_focus_changed(control: Control) -> void: CurrentButton = control
func _on_button_reroll_pressed() -> void:
   if reroll_count < PRISM_REROLL_COUNT:
      reroll_count += 1
      current_slot_count = DEFAULT_PRISM_SHOW_COUNT - ( reroll_count * PRISM_REROLL_DECREMENT )
      gridmap_setup(current_slot_count)
      roll_slots()
func _on_button_confirm_pressed() -> void:
   pass
func _on_button_cancel_pressed() -> void:
   close_menu.emit()

func _on_spell_icon_button_pressed() ->void:
   print(CurrentButton, " pressed")
