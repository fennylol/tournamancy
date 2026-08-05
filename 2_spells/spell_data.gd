class_name SpellData

const IS_ACTIVE_SIZE: int = 1
const SPELL_ID_SIZE: int = 2
const SPELL_STATE_SIZE: int = 1

enum StatTypes {
   # defense
   HEARTS,           #  0 Default Health
   ARMOR,            #  1 Special Health, good vs small damage
   WARD,             #  2 Special Health, good vs large damage
   OVERHEALTH,       #  3 Decaying health
   ARMOR_STRENGTH,   #  4 Effectiveness of Armor
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
   
enum SpellFields {Name, Description, IconPath, IconRect, ScriptPath, Cooldown, Effects, DummyEffects} # may at some point break this into PassiveSpellFields and ActiveSpellFields

## FOR FUTURE DEBUGGING, TRY TO KEEP THE ACTIVESPELLIDS AND ACTIVESPELLS SORTED ALPHABETICALLY

enum ActiveSpellIDs {
   IronBody,
   ShockstarDisco,
   StarlightBlink,
   Thunderwave,
   ERROR = -1}
const ActiveSpells: Dictionary = {
   ActiveSpellIDs.IronBody:{
      SpellFields.Name         : "Iron Body",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(32,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/IronBody/ironbody_script.gd",
      SpellFields.Cooldown     : 3.0,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   ActiveSpellIDs.ShockstarDisco:{
      SpellFields.Name         : "Shockstar Disco",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(0,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/ShockstarDisco/shockstardisco_script.gd",
      SpellFields.Cooldown     : 0.5,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   ActiveSpellIDs.StarlightBlink:{
      SpellFields.Name         : "Starlight Blink",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(32,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/StarlightBlink/starlightblink_script.gd",
      SpellFields.Cooldown     : 5.0,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   ActiveSpellIDs.Thunderwave:{
      SpellFields.Name         : "Thunderwave",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/Thunderwave/thunderwave_script.gd",
      SpellFields.Cooldown     : 5.0,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   }
}

enum PassiveSpellIDs {
   ## DEFENSE
   Heart, Armor, Ward, Overhealth, Armor_Strength, Ward_Strength, Lifesteal,
   ## OFFENSE
   Damage, Attack_Range, Cooldown, Force, Crit, Luck,
   ## MOVEMENT
   Speed, Sprint, Jump, Gravity, Steadfastness,
   ## MELEE
   Melee_Damage, Melee_Range, Melee_Force, Melee_Cooldown,
   ## OTHER
   JBLSpeaker, MoonJump,
   ## ERROR
   ERROR = -1
   }
const PassiveSpells: Dictionary = {
   PassiveSpellIDs.Heart:{
      SpellFields.Name         : "Health",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/Health/health_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Armor:{
      SpellFields.Name         : "Armor",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,32,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Ward:{
      SpellFields.Name         : "Ward",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,64,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Overhealth:{
      SpellFields.Name         : "Overhealth",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,96,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Armor_Strength:{
      SpellFields.Name         : "Armor Strength",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,128,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Ward_Strength:{
      SpellFields.Name         : "Ward Strength",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,160,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Lifesteal:{
      SpellFields.Name         : "Lifesteal",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,192,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Damage:{
      SpellFields.Name         : "Damage",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,224,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/Damage/damage_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Attack_Range:{
      SpellFields.Name         : "Range",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,256,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Cooldown:{
      SpellFields.Name         : "Cooldown",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,288,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Force:{
      SpellFields.Name         : "Force",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,320,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Crit:{
      SpellFields.Name         : "Critical",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,352,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Luck:{
      SpellFields.Name         : "Luck",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,384,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Speed:{
      SpellFields.Name         : "Speed",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,416,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/Speed/speed_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Sprint:{
      SpellFields.Name         : "Sprint",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,448,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Jump:{
      SpellFields.Name         : "Jump Height",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,480,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Gravity:{
      SpellFields.Name         : "Gravity",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,512,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/Gravity/gravity_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Steadfastness:{
      SpellFields.Name         : "Steadfastness",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,544,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Melee_Damage:{
      SpellFields.Name         : "Melee Damage",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,576,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Melee_Range:{
      SpellFields.Name         : "Melee Range",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,608,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Melee_Force:{
      SpellFields.Name         : "Melee Force",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,640,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   PassiveSpellIDs.Melee_Cooldown:{
      SpellFields.Name         : "Melee Cooldown",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,672,32,32),
      SpellFields.ScriptPath   : "",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
   
   PassiveSpellIDs.JBLSpeaker:{
      SpellFields.Name         : "BigAssSpeaker",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(96,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/JBL_Speaker/jbl_speaker_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : ["res://2_spells/passives/JBL_Speaker/JBLSpeakerSoundEffect.tscn"]
   },
   PassiveSpellIDs.MoonJump:{
      SpellFields.Name         : "Moon Jump",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(64,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/MoonJump/moonjump_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : []
   },
}

static func get_active_spell_data(id: ActiveSpellIDs) -> Dictionary: 
   if ActiveSpells.keys().has(id): return ActiveSpells[id]
   else: return {}

static func is_valid_active_spell(data: Dictionary) -> bool: 
   for field:String in SpellFields:
      if not data.keys().has(SpellFields.get(field)): return false
   return true
   
static func get_passive_spell_data(id: PassiveSpellIDs) -> Dictionary: 
   if PassiveSpells.keys().has(id): return PassiveSpells[id]
   else: return {}

static func is_valid_passive_spell(data: Dictionary) -> bool:
   for field:String in SpellFields: 
      if field == "Cooldown": continue
      if not data.keys().has(SpellFields.get(field)): return false
   return true
