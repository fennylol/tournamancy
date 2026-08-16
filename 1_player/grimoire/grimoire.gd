class_name Grimoire

var ActiveSlots: int:
   set(slots): ActiveSpells.resize(slots)
   get(): return ActiveSpells.size()
var ActiveSpells: Array[ActiveSpell] = []
var PassiveSpells: Array[PassiveSpell] = []
var StatModifiers: Dictionary = {}

var ThePlayer : Player

signal spell_equipped(spell_id: int, is_active: bool)
signal spell_erased(spell_id: int, is_active: bool)
signal spell_change_state(spell_id: int, is_active: bool, new_state: int)
signal spell_updated(spell_id: int, is_active: bool)

func _init() -> void: ActiveSlots = 2

# =================== #
# _process() handling #
# =================== #

func process_begin(delta: float, player: Player) -> void:
   StatModifiers = calculate_stats()
   for spell:PassiveSpell in PassiveSpells:
      spell._on_process_begin(delta, player)
   for spell:ActiveSpell in ActiveSpells:
      if spell: spell._on_process_begin(delta)

func process_end(delta: float, player: Player) -> void:
   for spell:PassiveSpell in PassiveSpells:
      spell._on_process_end(delta, player)
   #StatModifiers = {} # i dont think theres an advantage to resetting stat modifications after each frame, right?

# =============== #
# stat management #
# =============== #

func calculate_stats() -> Dictionary:
   var stat_dict: Dictionary = {}
   for spell:PassiveSpell in PassiveSpells:
      var spell_stats := spell._get_stat_contributions()
      for stat : SpellData.StatTypes in spell_stats.keys():
         if spell_stats[stat] is int or spell_stats[stat] is float:
            if not stat_dict.keys().has(stat): stat_dict[stat] = 0.0
            stat_dict[stat] += spell_stats[stat]
   return stat_dict

func get_stat(id: SpellData.StatTypes) -> float:
   if StatModifiers.keys().has(id): return StatModifiers[id]
   else: return 0 ##this was previously return 1, but it makes more sense to return 0 if there are no stat modifiers

# ================ #
# spell management #
# ================ #

func add_passive(id: SpellData.PassiveSpellIDs, stacks: int) -> void:
   var data: Dictionary = SpellData.get_passive_spell_data(id)
   if SpellData.is_valid_passive_spell(data):
      var spell: PassiveSpell = load(data[SpellData.SpellFields.ScriptPath]).new(stacks)
      ## CHECK TO SEE IF THE SPELL ALREADY EXISTS. UPDATE IF SO
      var spell_extant : bool = false
      for i in range(PassiveSpells.size()): 
         if PassiveSpells[i].SpellID == id: 
            spell_extant = true
            PassiveSpells[i].Stacks += stacks
            StatModifiers = calculate_stats()
            PassiveSpells[i]._on_update(ThePlayer)
            spell_updated.emit(id, false)
      ## ADD THE SPELL IF NOT EXTANT
      if not spell_extant:
         PassiveSpells.append(spell)
         spell.state_changed.connect(func(new_state: int): spell_change_state.emit(id, false, new_state))
         StatModifiers = calculate_stats()
         spell._on_equip(ThePlayer)
         spell_equipped.emit(id, false)

func add_active(id: SpellData.ActiveSpellIDs, slot: int) -> void:
   var data: Dictionary = SpellData.get_active_spell_data(id)
   if SpellData.is_valid_active_spell(data):
      var capped_slot: int = clampi(slot, 0, ActiveSlots)
      var spell: ActiveSpell = load(data[SpellData.SpellFields.ScriptPath]).new()
      ActiveSpells[capped_slot] = spell
      spell.state_changed.connect(func(new_state: int): spell_change_state.emit(id, true, new_state))
      spell_equipped.emit(id, true)

func remove_passive_step_one(id: SpellData.PassiveSpellIDs) -> void:
   for i in range(PassiveSpells.size()):
      if PassiveSpells[i].SpellID == id:
         PassiveSpells[i].SpellID = SpellData.PassiveSpellIDs.ERROR
         spell_erased.emit(id, false)
         return
func remove_passive_step_two():
   var locked_size : int = PassiveSpells.size() - 1
   for i in range(locked_size + 1):
      if PassiveSpells[locked_size - i].SpellID == SpellData.PassiveSpellIDs.ERROR:
         PassiveSpells.remove_at(locked_size - i)
func remove_active(id: SpellData.ActiveSpellIDs) -> void:
   for i in ActiveSlots:
      var spell:ActiveSpell = ActiveSpells[i]
      if spell and spell.SpellID == id:
         ActiveSpells[i] = null
         spell_erased.emit(id, true)
         return

func adopt_class(id: ClassData.ClassIDs) -> void:
   ## CLEAR SPELLS
   for spell:ActiveSpell  in ActiveSpells:
      if spell: remove_active(spell.SpellID) 
   for spell:PassiveSpell in PassiveSpells:
      remove_passive_step_one(spell.SpellID)
   remove_passive_step_two()
   StatModifiers = {}
   
   ## ADOPT SPELLS
   var class_data: Dictionary = ClassData.get_class_data(id)
   if ClassData.is_valid_class(class_data):
      for i in class_data[ClassData.ClassFields.ACTIVES].size():
         add_active(class_data[ClassData.ClassFields.ACTIVES][i], i)
      for spell_id in class_data[ClassData.ClassFields.PASSIVES]:
         add_passive(spell_id, class_data[ClassData.ClassFields.PASSIVES][spell_id])

func change_spell_state(spell_id: int, is_active: bool, spell_state: int) -> void:
   var spell_array: Array = (ActiveSpells as Array) if is_active else (PassiveSpells as Array)
   for spell:Spell in spell_array:
      if spell.SpellID == spell_id:
         spell.change_state(spell_state)

   
