class_name SpellData

enum StatTypes {
   # defense
   HEALTH,           #  0 Max Health
   OVERHEALTH,       #  1 Decaying health
   ARMOR,            #  2 Special Health, good vs small damage
   ARMOR_STRENGTH,   #  3 Effectiveness of Armor
   WARD,             #  4 Special Health, good vs large damage
   WARD_STRENGTH,    #  5 Effectiveness of Ward
   LIFESTEAL,        #  6 Heal from damage

   # offense
   DAMAGE,           #  7 Damage dealt
   RANGE,            #  8 Spell range
   COOLDOWN,         #  9 Spell cooldown reduction
   FORCE,            # 10 Displacement effetiveness
   CRIT,             # 11 Crit damage
   LUCK,             # 12 Random chance multiplier

   # mobility
   SPEED,            # 13 Move speed
   SPRINT,           # 14 Sprint speed
   JUMP,             # 15 Jump strength
   GRAVITY,          # 17 Gravity strength
   STEADFASTNESS,    # 18 Displacement resistence

   # melee
   MELEE_DAMAGE,     # 19 Melee damage
   MELEE_RANGE,      # 20 Melee range
   MELEE_FORCE,      # 21 Melee force
   MELEE_COOLDOWN    # 22 Melee cooldown
}
   
enum SpellFields {Name, IconPath, ScriptPath} # may at some point break this into PassiveSpellFields and ActiveSpellFields

enum ActiveSpellIDs {Teleport, Fireball}
const ActiveSpells: Dictionary = {
   ActiveSpellIDs.Teleport : {
      SpellFields.Name : "Warpstone",
      SpellFields.IconPath : "res://2_actives/Teleport/teleport_icon.png",
      SpellFields.ScriptPath : "res://2_actives/Teleport/teleport_script.gd"
   }
   
}

enum PassiveSpellIDs { Health,
                       Damage,
                       Speed, Jump, Gravity }
const PassiveSpells: Dictionary = {
   PassiveSpellIDs.Health : {
      SpellFields.Name : "HealthSpell",
      SpellFields.IconPath : "res://3_passives/Health/health_icon.png",
      SpellFields.ScriptPath : "res://3_passives/Health/health_script.gd"
   },

   PassiveSpellIDs.Damage : {
      SpellFields.Name : "DamageSpell",
      SpellFields.IconPath : "res://3_passives/Damage/damage_icon.png",
      SpellFields.ScriptPath : "res://3_passives/Damage/damage_script.gd"
   },  

   PassiveSpellIDs.Speed : {
      SpellFields.Name : "SpeedSpell",
      SpellFields.IconPath : "res://3_passives/Speed/speed_icon.png",
      SpellFields.ScriptPath : "res://3_passives/Speed/speed_script.gd"
   },

   PassiveSpellIDs.Gravity : {
      SpellFields.Name : "GravitySpell",
      SpellFields.IconPath : "res://3_passives/Gravity/gravity_icon.png",
      SpellFields.ScriptPath : "res://3_passives/Gravity/gravity_script.gd"
   }
}

static func get_active_spell_data(id: ActiveSpellIDs) -> Dictionary: 
   if ActiveSpells.keys().has(id): return ActiveSpells[id]
   else: return {}

static func is_valid_active_spell(_data: Dictionary) -> bool: 
   return true # TODO: actually check lmao
   
static func get_passive_spell_data(id: PassiveSpellIDs) -> Dictionary: 
   if PassiveSpells.keys().has(id): return PassiveSpells[id]
   else: return {}

static func is_valid_passive_spell(_data: Dictionary) -> bool:
   return true # TODO: actually check lmao
