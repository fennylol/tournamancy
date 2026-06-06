class_name Grimoire

var ActiveSlots: int:
   set(slots):
      ActiveSpells.resize(slots)
   get():
      return ActiveSpells.size()
var ActiveSpells: Array[ActiveSpell] = []
var PassiveSpells: Array[PassiveSpell] = []
var StatModifiers: Dictionary = {}

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
   for Spell:PassiveSpell in PassiveSpells:
      var spell_stats := Spell._get_stat_contributions()
      for stat:SpellData.StatTypes in spell_stats.keys():
         if spell_stats[stat] is int or spell_stats[stat] is float:
            if not stat_dict.keys().has(stat): stat_dict[stat] = 1
            stat_dict[stat] += spell_stats[stat]
   return stat_dict

func get_stat(id: SpellData.StatTypes) -> float:
   if StatModifiers.keys().has(id): return StatModifiers[id]
   else: return 1

# ================ #
# spell management #
# ================ #
func add_passive(id: SpellData.PassiveSpellIDs, stacks: int) -> void:
   var data: Dictionary = SpellData.get_passive_spell_data(id)
   if SpellData.is_valid_passive_spell(data):
      var spell = load(data[SpellData.SpellFields.ScriptPath]).new(stacks)
      PassiveSpells.append(spell)

func add_active(id: SpellData.ActiveSpellIDs, slot: int) -> void:
   var data: Dictionary = SpellData.get_active_spell_data(id)
   if SpellData.is_valid_active_spell(data):
      var capped_slot: int = clampi(slot, 0, ActiveSlots)
      var spell: ActiveSpell = load(data[SpellData.SpellFields.ScriptPath]).new()
      ActiveSpells[capped_slot] = spell

func clear_class() -> void:
   var trust_me_this_is_the_best_way_to_do_it: int = ActiveSlots
   ActiveSlots = 0
   ActiveSlots = trust_me_this_is_the_best_way_to_do_it
   PassiveSpells.clear()
   StatModifiers = {}

func adopt_class(id: ClassData.ClassIDs) -> void:
   clear_class()
   var class_data: Dictionary = ClassData.get_class_data(id)
   if ClassData.is_valid_class(class_data):
      for i in class_data[ClassData.ClassFields.ACTIVES].size():
         add_active(class_data[ClassData.ClassFields.ACTIVES][i], i)
      for spell_id in class_data[ClassData.ClassFields.PASSIVES]:
         add_passive(spell_id, class_data[ClassData.ClassFields.PASSIVES][spell_id])
