class_name Grimoire

var ActiveAbilities: Array[ActiveAbility] = []
var ActiveSlots: int = 2:
   set(slots):
      ActiveAbilities.resize(slots)
   get():
      return ActiveAbilities.size()

var PassiveAbilities: Array[PassiveAbility] = []
var PerFrameStatModifiers: Dictionary = {}


func _on_process_begin(owner: Player) -> void:
   PerFrameStatModifiers = {}
   for ability:PassiveAbility in PassiveAbilities:
      ability._on_process_begin(owner)
      var stat_mods := ability._get_stat_contributions()
      for stat in stat_mods.keys(): 
         if stat_mods[stat] is int or stat_mods[stat] is float:
            PerFrameStatModifiers[stat] += stat_mods[stat]


func _on_process_end(owner: Player) -> void:
   for ability:PassiveAbility in PassiveAbilities:
      ability._on_process_end(owner)
