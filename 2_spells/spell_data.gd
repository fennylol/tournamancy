class_name SpellData

const IS_ACTIVE_SIZE: int = 1
const SPELL_ID_SIZE: int = 2
const SPELL_STATE_SIZE: int = 1
const FAMILIAR_IDX_SIZE: int = 1

enum StatTypes {
   # DEFENSE #
   
   ## (0) Base hit points that can be lost before being knocked out.
   HEARTS,
   ## (1) Bonus hit points which reduce incoming damage by a flat amount equal to [member ARMOR_STRENGTH]. Effective against weak, fast attacks.
   ARMOR,
   ## (2) Bonus hit points which reduce incoming damage by a percent equal to [member WARD_STRENGTH] if the player hasn't been damaged in some time. Effective against strong, slow attacks.
   WARD,
   ## (3) Bonus hit points which exponentially decay over time.
   OVERHEALTH,
   ## (4) The amount of flat reduction which damage against [member ARMOR] is reduced.
   ARMOR_STRENGTH,
   ## (5) The maximum percent reduction which damage against [member WARD] is reduced.
   WARD_STRENGTH,
   ## (6) The percent of damage converted into health regeneration.
   LIFESTEAL,

   # OFFENSE #
   
   ## (7) Damage multiplier for weapon and spell attacks.
   DAMAGE,
   ## (8) Range multiplier for weapon and spell attacks.
   RANGE,
   ## (9) Cooldown multiplier for weapon and spell attacks.
   COOLDOWN,
   ## (10) Effectiveness of push, shove, and other displacement effects. Reduced by the enemy's [member STEADFASTNESS] value.
   FORCE,
   ## (11) Additional damage dealt on a critical hit (Headshots, chance-based attacks, etc).
   CRIT,
   ## (12) Multiplier on chance-based effects.
   LUCK,

   # MOBILITY #
   
   ## (13) Movement speed along the ground.
   SPEED,
   ## (14) Movement speed multiplier when sprinting.
   SPRINT,
   ## (15) Upward strength of player jump.
   JUMP,
   ## (16) Amount of vertical control the player has while airborne.[br]A higher GRAVITY stat means the player falls slower when the "jump" button is held, and they fall faster when the "jump" button is released.
   GRAVITY,
   ## (17) Reduction of enemies' push, shove, and other displacement effects. Reduced by the enemy's [member FORCE] value.
   STEADFASTNESS,

   # MELEE #
   
   ## (18) Flat damage of the player's quick melee attack.
   MELEE_DAMAGE,
   ## (19) Flat range of the player's quick melee attack.
   MELEE_RANGE,
   ## (20) Flat pushing power of the player's quick melee attack.
   MELEE_FORCE,
   ## (21) Cooldown reduction??? of the player's quick melee attack.
   MELEE_COOLDOWN
}
   
enum SpellFields {Name, Description, IconPath, IconRect, ScriptPath, Cooldown, Effects, DummyEffects, Familiars} # may at some point break this into PassiveSpellFields and ActiveSpellFields

## TODO: FOR FUTURE DEBUGGING, TRY TO KEEP THE ACTIVESPELLIDS AND ACTIVESPELLS SORTED ALPHABETICALLY
enum ActiveSpellIDs {
   GreatBallOfFire,
   IronBody,
   ShockstarDisco,
   StarlightBlink,
   Thunderwave,
   ERROR = -1
   }
const ActiveSpells: Dictionary = {
   ActiveSpellIDs.GreatBallOfFire:{
      SpellFields.Name         : "Great Ball o' Fire",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(32,64,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/GreatBallOFire/great_ball_o_fire_script.gd",
      SpellFields.Cooldown     : 0.0,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : ["res://2_spells/actives/GreatBallOFire/familiar/great_ball_of_fire_familiar.gd"]
   },
   ActiveSpellIDs.IronBody:{
      SpellFields.Name         : "Iron Body",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(32,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/IronBody/ironbody_script.gd",
      SpellFields.Cooldown     : 3.0,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   ActiveSpellIDs.ShockstarDisco:{
      SpellFields.Name         : "Shockstar Disco",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(0,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/ShockstarDisco/shockstardisco_script.gd",
      SpellFields.Cooldown     : 0.5,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   ActiveSpellIDs.StarlightBlink:{
      SpellFields.Name         : "Starlight Blink",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(32,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/StarlightBlink/starlightblink_script.gd",
      SpellFields.Cooldown     : 5.0,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   ActiveSpellIDs.Thunderwave:{
      SpellFields.Name         : "Thunderwave",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/Thunderwave/thunderwave_script.gd",
      SpellFields.Cooldown     : 5.0,
      SpellFields.Effects      : ["res://2_spells/actives/Thunderwave/ThunderwaveArea.tscn"],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
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
      SpellFields.Name         : "Heart",
      SpellFields.Description  : "Increases the amount of damage you can take before you are knocked out.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/health_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Armor:{
      SpellFields.Name         : "Armor",
      SpellFields.Description  : "Adds bonus health which reduces incoming damage by a flat amount. Effective against weak, fast attacks",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/armor_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Ward:{
      SpellFields.Name         : "Ward",
      SpellFields.Description  : "Adds bonus health which reduces incoming damage by a percent if you haven't been damaged in some time. Effective against strong, slow attacks.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,64,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/ward_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Overhealth:{
      SpellFields.Name         : "Overhealth",
      SpellFields.Description  : "Adds bonus health which decays over time.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,96,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/overhealth_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Armor_Strength:{
      SpellFields.Name         : "Armor Strength",
      SpellFields.Description  : "Increases the amount that your 'Armor' reduces incoming damage by.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,128,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/armorstrength_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Ward_Strength:{
      SpellFields.Name         : "Ward Strength",
      SpellFields.Description  : "Increases the maximum percentage that your 'Ward' reduces incoming damage by.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,160,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/wardstrength_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Lifesteal:{
      SpellFields.Name         : "Lifesteal",
      SpellFields.Description  : "Increases how much damage you can convert into health.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,192,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/lifesteal_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Damage:{
      SpellFields.Name         : "Damage",
      SpellFields.Description  : "Increases how much damage your spells deal.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,224,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/damage_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Attack_Range:{
      SpellFields.Name         : "Range",
      SpellFields.Description  : "Increases how far your spells can reach.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,256,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/range_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Cooldown:{
      SpellFields.Name         : "Cooldown",
      SpellFields.Description  : "Reduces the time it takes for your active abilities to recharge.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,288,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/cooldown_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Force:{
      SpellFields.Name         : "Force",
      SpellFields.Description  : "Increases the effectiveness of your pushing and shoving effects.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,320,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/force_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Crit:{
      SpellFields.Name         : "Critical",
      SpellFields.Description  : "Causes your spells to deal additional damage on a critical hit.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,352,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/critical_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Luck:{
      SpellFields.Name         : "Luck",
      SpellFields.Description  : "Increases the likelyhood of chance-based effects.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,384,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/luck_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Speed:{
      SpellFields.Name         : "Speed",
      SpellFields.Description  : "Increases how fast you can walk.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,416,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/speed_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Sprint:{
      SpellFields.Name         : "Sprint",
      SpellFields.Description  : "Greatly increases how fast you can run.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,448,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/sprint_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Jump:{
      SpellFields.Name         : "Jump Height",
      SpellFields.Description  : "Increases how high you can jump.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,480,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/jump_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Gravity:{
      SpellFields.Name         : "Gravity",
      SpellFields.Description  : "Enables you to more easily control how fast you fall.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,512,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/gravity_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Steadfastness:{
      SpellFields.Name         : "Steadfastness",
      SpellFields.Description  : "Reduces how far enemies can push and shove you.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,544,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/steadfast_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Melee_Damage:{
      SpellFields.Name         : "Melee Damage",
      SpellFields.Description  : "Increases the damage of your quick melee attack.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,576,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/meleedamage_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Melee_Range:{
      SpellFields.Name         : "Melee Range",
      SpellFields.Description  : "Increases the reach of your quick melee attack.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,608,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/meleerange_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Melee_Force:{
      SpellFields.Name         : "Melee Force",
      SpellFields.Description  : "Increases the distance you shove with your quick melee attack.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,640,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/meleeforce_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.Melee_Cooldown:{
      SpellFields.Name         : "Melee Cooldown",
      SpellFields.Description  : "Makes your quick melee attack faster.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,672,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/meleecooldown_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
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
      SpellFields.Description  : "Allows you to jump in the air one additional time.",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(64,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/MoonJump/moonjump_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],      
      SpellFields.Familiars    : []
   },
}

## Takes a given [param StatTypes] value and returns a [b]float[/b] based on the player's base stat plus any stat contributions from actives and passives.[br][br]By default (for now), an influenced stat is simply [code]BASESTAT * CONTRIBUTION[/code], but more complicated functions are possible.[br][br]
## "🧑‍🔧" indicates the operation has not been checked yet, and it just in the default X*Y format.
static func get_influenced_stat(id: StatTypes, base_value: float, stat_value: float) -> float:
   var influenced_stat : float = -999.0
   match id:
      ## ONE-TO-ONE. Each additional point is one (1.0) additional health.
      StatTypes.HEARTS:         influenced_stat = base_value + stat_value
      ## ONE-TO-ONE. Each additional point is one (1.0) additional armor.
      StatTypes.ARMOR:          influenced_stat = base_value + stat_value
      ## ONE-TO-ONE. Each additional point is one (1.0) additional ward.
      StatTypes.WARD:           influenced_stat = base_value + stat_value
      StatTypes.OVERHEALTH:     influenced_stat = base_value * stat_value ##🧑‍🔧
      StatTypes.ARMOR_STRENGTH: influenced_stat = base_value * stat_value ##🧑‍🔧
      StatTypes.WARD_STRENGTH:  influenced_stat = base_value * stat_value ##🧑‍🔧
      StatTypes.LIFESTEAL:      influenced_stat = base_value * stat_value ##🧑‍🔧
      ## NATURAL LOG. Slow growth as points are added. You need about ~7 stacks for double damage. Not sure if this is a good idea (🧑‍🔧), but it feels decent for now. Needs playtesting.
      StatTypes.DAMAGE:         influenced_stat = log( base_value + stat_value )
      StatTypes.RANGE:          influenced_stat = base_value * stat_value ##🧑‍🔧
      ## ADD FIVE PERCENT. Each additional point causes active ability cooldowns to go 5% faster (20 stacks needed for a 1/2 reduction).
      StatTypes.COOLDOWN:       influenced_stat = 1 + ( ( base_value + stat_value ) * 0.05 )
      StatTypes.FORCE:          influenced_stat = base_value * stat_value ##🧑‍🔧
      StatTypes.CRIT:           influenced_stat = base_value * stat_value ##🧑‍🔧
      StatTypes.LUCK:           influenced_stat = base_value * stat_value ##🧑‍🔧
      ## ADDITIVE. Each additional point of speed increases walk speed by ~1 m/s
      StatTypes.SPEED:          influenced_stat = base_value + stat_value if stat_value >= 0 else base_value / abs(stat_value)
      ## ADDITIVE. Each additional point increases sprint speed by an amount equal to 1/4 walk speed.
      StatTypes.SPRINT:         influenced_stat = base_value + ( stat_value * 0.25 )
      StatTypes.JUMP:           influenced_stat = base_value + stat_value ##🧑‍🔧
      ## PLATFORMER JUMPS. While the "jump" button is held, gravity is low. When the "jump" button is released, gravity is high.
      StatTypes.GRAVITY:        influenced_stat = base_value * pow( 2.0 , ( -( stat_value * 0.25 ) / 2 ) ) if Input.is_action_pressed("jump") else base_value * pow( 2.0 , ( ( stat_value * 0.25 ) / 2 ) )
      StatTypes.STEADFASTNESS:  influenced_stat = base_value * stat_value ##🧑‍🔧
      ## ONE-TO-ONE. Each additional point is one (1.0) additional point of damage.
      StatTypes.MELEE_DAMAGE:   influenced_stat = base_value + stat_value ##🧑‍🔧
      ## ADDITIVE. Each additional point of range increases the Area3D by 0.5m
      StatTypes.MELEE_RANGE:    influenced_stat = base_value + ( stat_value * 0.5 ) ##🧑‍🔧
      ## IDK
      StatTypes.MELEE_FORCE:    influenced_stat = base_value + stat_value ##🧑‍🔧
      StatTypes.MELEE_COOLDOWN: influenced_stat = base_value * stat_value ##🧑‍🔧
   if influenced_stat == -999.0: 
      printerr("SpellData.get_influenced_stat() STAT ", id, " NOT FOUND. RETURNING 0.")
      return 0.0
   else:
      return influenced_stat

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
