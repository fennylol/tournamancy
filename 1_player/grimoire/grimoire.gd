class_name Grimoire

var ActiveSlots: int:
   set(slots): ActiveSpells.resize(slots)
   get(): return ActiveSpells.size()
var ActiveSpells: Array[ActiveSpell] = []
var PassiveSpells: Array[PassiveSpell] = []
var StatModifiers: Dictionary = {}

var ThePlayer : Player

signal spell_equipped(spell_id: int, is_active: bool)
#signal spell_erased(spell_id: int, is_active: bool)
signal spell_change_state(spell_id: int, is_active: bool, new_state: int)

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
   print(StatModifiers)
   
   if StatModifiers.keys().has(id): return StatModifiers[id]
   else: return 0 ##this was previously return 1, but it makes more sense to return 0 if there are no stat modifiers

# ================ #
# spell management #
# ================ #

func add_passive(id: SpellData.PassiveSpellIDs, stacks: int) -> void:
   var data: Dictionary = SpellData.get_passive_spell_data(id)
   if SpellData.is_valid_passive_spell(data):
      var spell: PassiveSpell = load(data[SpellData.SpellFields.ScriptPath]).new(stacks)
      PassiveSpells.append(spell) ## TODO: check if spell already exists and just sum the stacks together if so
      spell.StateChanged.connect(func(new_state: int): spell_change_state.emit(id, false, new_state))
      StatModifiers = calculate_stats()
      spell._on_equip(ThePlayer)
      spell_equipped.emit(id, false)
func add_active(id: SpellData.ActiveSpellIDs, slot: int) -> void:
   var data: Dictionary = SpellData.get_active_spell_data(id)
   if SpellData.is_valid_active_spell(data):
      var capped_slot: int = clampi(slot, 0, ActiveSlots)
      var spell: ActiveSpell = load(data[SpellData.SpellFields.ScriptPath]).new()
      ActiveSpells[capped_slot] = spell
      spell.StateChanged.connect(func(new_state: int): spell_change_state.emit(id, true, new_state))
      spell_equipped.emit(id, true)
func adopt_class(id: ClassData.ClassIDs) -> void:
   ## CLEAR CLASS
   var trust_me_this_is_the_best_way_to_do_it: int = ActiveSlots
   ActiveSlots = 0
   ActiveSlots = trust_me_this_is_the_best_way_to_do_it
   PassiveSpells.clear()
   StatModifiers = {}
   
   ## ADOPT SPELLS
   var class_data: Dictionary = ClassData.get_class_data(id)
   if ClassData.is_valid_class(class_data):
      for i in class_data[ClassData.ClassFields.ACTIVES].size():
         add_active(class_data[ClassData.ClassFields.ACTIVES][i], i)
      for spell_id in class_data[ClassData.ClassFields.PASSIVES]:
         add_passive(spell_id, class_data[ClassData.ClassFields.PASSIVES][spell_id])
   
   
   ## SYNC EFFECTORY
   var list_of_active_spells : Array[SpellData.ActiveSpellIDs]
   var list_of_passive_spells : Array[SpellData.PassiveSpellIDs]
   for a in ActiveSpells: if a is ActiveSpell: list_of_active_spells.append(a.SpellID)
   for p in PassiveSpells: list_of_passive_spells.append(p.SpellID)
   ThePlayer.sync_effectory(list_of_active_spells,list_of_passive_spells)

# ============= #
# locate player #
# ============= #

## I realize this is probably bad practice, but if it works it works. Feel free to clean it up at any point.
func i_am_the_player(player : Player): ThePlayer = player
