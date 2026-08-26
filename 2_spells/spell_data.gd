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
   MELEE_COOLDOWN,
   
   # DAMAGE TYPE MODIFIERS #
   
   BOOST_IMPACT,
   BOOST_SHARP,
   BOOST_ENERGY,
   BOOST_FIRE,
   BOOST_COLD,
   BOOST_ZAP,
   BOOST_ROT,
   BOOST_NATURAL,
   RESIST_IMPACT,
   RESIST_SHARP,
   RESIST_ENERGY,
   RESIST_FIRE,
   RESIST_COLD,
   RESIST_ZAP,
   RESIST_ROT,
   RESIST_NATURAL
}
   
enum SpellFields {Name, Description, IconPath, IconRect, ScriptPath, Cooldown, Effects, DummyEffects, Familiars} # may at some point break this into PassiveSpellFields and ActiveSpellFields

## TODO: FOR FUTURE DEBUGGING, TRY TO KEEP THE ACTIVESPELLIDS AND ACTIVESPELLS SORTED ALPHABETICALLY
enum ActiveSpellIDs {
   CelestialAnchor,
   CrimsonThorn,
   GreatBallOfFire,
   IronBody,
   LunarTowline,
   PulsarsBreath,
   ShockstarDisco,
   StarlightBlink,
   Thunderwave,
   ERROR = -1
   }
const ActiveSpells: Dictionary = {
   #ActiveSpellIDs.:{
      #SpellFields.Name         : "",
      #SpellFields.Description  : "",
      #SpellFields.IconPath     : ,
      #SpellFields.IconRect     : Rect2(0,0,32,32),
      #SpellFields.ScriptPath   : ,
      #SpellFields.Cooldown     : 1.0,
      #SpellFields.Effects      : [],
      #SpellFields.DummyEffects : [],
      #SpellFields.Familiars    : []
   #},
   ActiveSpellIDs.CelestialAnchor:{
      SpellFields.Name         : "Celestial Anchor",
      SpellFields.Description  : "Lock yourself to the sky for a moment, so you cannot fall or rise.",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(32,128,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/CelestialAnchor/celestialanchor_script.gd",
      SpellFields.Cooldown     : 10.0,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []
   },
   ActiveSpellIDs.CrimsonThorn:{
      SpellFields.Name         : "Crimson Thorn",
      SpellFields.Description  : "Drop a small bramble on the ground which harms anyone who walks over it.",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(0,64,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/CrimsonThorn/crimsonthorn_script.gd",
      SpellFields.Cooldown     : 1.0,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []
   },
   ActiveSpellIDs.GreatBallOfFire:{
      SpellFields.Name         : "Great Ball o' Fire",
      SpellFields.Description  : "Launches a small (but powerful) fireball.",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(96,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/GreatBallOFire/great_ball_o_fire_script.gd",
      SpellFields.Cooldown     : 0.5,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : ["res://2_spells/actives/GreatBallOFire/familiar/great_ball_of_fire_familiar.gd"]
   },
   ActiveSpellIDs.IronBody:{
      SpellFields.Name         : "Iron Body",
      SpellFields.Description  : "Immediately grants a boost of health that fades over time.",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(32,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/IronBody/ironbody_script.gd",
      SpellFields.Cooldown     : 10.0,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []
   },
   ActiveSpellIDs.LunarTowline:{
      SpellFields.Name         : "Lunar Towline",
      SpellFields.Description  : "Cast a fishing line to snag an enemy, then pull them towards you.",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(0,128,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/LunarTowline/lunartowline_script.gd",
      SpellFields.Cooldown     : 3.0,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : ["res://2_spells/actives/LunarTowline/familiar/lunartowline_hook.gd"]
   },
   ActiveSpellIDs.ShockstarDisco:{
      SpellFields.Name         : "Shockstar Disco",
      SpellFields.Description  : "Fires a bounding disco ball that damages nearby enemies.",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(0,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/ShockstarDisco/shockstardisco_script.gd",
      SpellFields.Cooldown     : 0.5,
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : ["res://2_spells/actives/ShockstarDisco/familiar/disco_ball_familiar.gd"]
   },
   ActiveSpellIDs.StarlightBlink:{
      SpellFields.Name         : "Starlight Blink",
      SpellFields.Description  : "Teleport a short distance forward in an instant.",
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
      SpellFields.Description  : "Projects a wave of energy that damages and shoves enemies away from you.",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/Thunderwave/thunderwave_script.gd",
      SpellFields.Cooldown     : 4.0,
      SpellFields.Effects      : ["res://2_spells/actives/Thunderwave/Effects/ThunderwaveArea.tscn"],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : ["res://2_spells/actives/Thunderwave/Familiar/thunderwave_familiar.gd"]
   },
   ActiveSpellIDs.PulsarsBreath:{
      SpellFields.Name         : "Pulsar's Breath",
      SpellFields.Description  : "An instant beam of high energy, reaching light-years away in an instant.",
      SpellFields.IconPath     : "res://2_spells/actives/PulsarsBreath/icon.png",
      SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/actives/PulsarsBreath/pulsars_breath_script.gd",
      SpellFields.Cooldown     : 0.0,
      SpellFields.Effects      : ["res://2_spells/actives/PulsarsBreath/Effects/pulsars_breath_raycast.tscn"],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : ["res://2_spells/actives/PulsarsBreath/Familiar/pulsars_breath_familiar.gd"]
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
   ## DAMAGE MODIFIERS
   Boost_Impact, Boost_Sharp, Boost_Energy, Boost_Fire, Boost_Cold, Boost_Zap, Boost_Rot, Boost_Natural,
   Resist_Impact, Resist_Sharp, Resist_Energy, Resist_Fire, Resist_Cold, Resist_Zap, Resist_Rot, Resist_Natural,
   ## OTHER
   JBLSpeaker, MoonJump, PhantomFlight,
   ## ERROR
   ERROR = -1
   }
const PassiveSpells: Dictionary = {
   #PassiveSpellIDs. : {
      #SpellFields.Name         : "",
      #SpellFields.Description  : "",
      #SpellFields.IconPath     : ,
      #SpellFields.IconRect     : Rect2(0,0,32,32),
      #SpellFields.ScriptPath   : ,
      #SpellFields.Cooldown     : 1.0,
      #SpellFields.Effects      : [],
      #SpellFields.DummyEffects : [],
      #SpellFields.Familiars    : []
   #}
   PassiveSpellIDs.JBLSpeaker : {
      SpellFields.Name         : "BigAssSpeaker",
      SpellFields.Description  : "",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(96,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/JBL_Speaker/jbl_speaker_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : ["res://2_spells/passives/JBL_Speaker/JBLSpeakerSoundEffect.tscn"],
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.MoonJump : {
      SpellFields.Name         : "Moon Jump",
      SpellFields.Description  : "Allows you to jump in the air one additional time.",
      SpellFields.IconPath     : "res://2_spells/actives/misc_active_icons.png",
      SpellFields.IconRect     : Rect2(64,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/MoonJump/moonjump_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []
   },
   PassiveSpellIDs.PhantomFlight : {
      SpellFields.Name         : "Phantom Flight",
      SpellFields.Description  : "Move faster when no one is nearby. Most slower when they are.",
      SpellFields.IconPath     : "res://2_spells/passives/PhantomFlight/icon.png",
      SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/PhantomFlight/phantom_flight_script.gd",
      SpellFields.Effects      : [
         "res://2_spells/passives/PhantomFlight/effects/PhantomFlightAreaEffect.tscn",
         "res://2_spells/passives/PhantomFlight/effects/phantom_flight_visual_indicator.tscn"
      ],
      SpellFields.DummyEffects : ["res://2_spells/passives/PhantomFlight/effects/phantom_flight_visual_indicator.tscn"],
      SpellFields.Familiars    : []
   },
   
   # ==================================== #
   # STAT PASSIVES FROM THIS POINT ONWARD #
   # ==================================== #
   PassiveSpellIDs.Heart : {
      SpellFields.Name         : "Heart",
      SpellFields.Description  : "Increases the amount of damage you can take before you are knocked out.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/health_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Armor : {
      SpellFields.Name         : "Armor",
      SpellFields.Description  : "Adds bonus health which reduces incoming damage by a flat amount. Effective against weak, fast attacks",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/armor_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Ward : {
      SpellFields.Name         : "Ward",
      SpellFields.Description  : "Adds bonus health which reduces incoming damage by a percent if you haven't been damaged in some time. Effective against strong, slow attacks.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,64,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/ward_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Overhealth : {
      SpellFields.Name         : "Overhealth",
      SpellFields.Description  : "Adds bonus health which decays over time.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,96,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/overhealth_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Armor_Strength : {
      SpellFields.Name         : "Armor Strength",
      SpellFields.Description  : "Increases the amount that your 'Armor' reduces incoming damage by.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,128,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/armorstrength_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Ward_Strength : {
      SpellFields.Name         : "Ward Strength",
      SpellFields.Description  : "Increases the maximum percentage that your 'Ward' reduces incoming damage by.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,160,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/wardstrength_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Lifesteal : {
      SpellFields.Name         : "Lifesteal",
      SpellFields.Description  : "Increases how much damage you can convert into health.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,192,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/lifesteal_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Damage : {
      SpellFields.Name         : "Damage",
      SpellFields.Description  : "Increases how much damage your spells deal.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,224,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/damage_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Attack_Range : {
      SpellFields.Name         : "Range",
      SpellFields.Description  : "Increases how far your spells can reach.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,256,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/range_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Cooldown : {
      SpellFields.Name         : "Cooldown",
      SpellFields.Description  : "Reduces the time it takes for your active abilities to recharge.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,288,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/cooldown_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Force : {
      SpellFields.Name         : "Force",
      SpellFields.Description  : "Increases the effectiveness of your pushing and shoving effects.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,320,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/force_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Crit : {
      SpellFields.Name         : "Critical",
      SpellFields.Description  : "Causes your spells to deal additional damage on a critical hit.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,352,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/critical_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Luck : {
      SpellFields.Name         : "Luck",
      SpellFields.Description  : "Increases the likelyhood of chance-based effects.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,384,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/luck_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Speed : {
      SpellFields.Name         : "Speed",
      SpellFields.Description  : "Increases how fast you can walk.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,416,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/speed_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Sprint : {
      SpellFields.Name         : "Sprint",
      SpellFields.Description  : "Greatly increases how fast you can run.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,448,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/sprint_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Jump : {
      SpellFields.Name         : "Jump Height",
      SpellFields.Description  : "Increases how high you can jump.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,480,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/jump_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Gravity : {
      SpellFields.Name         : "Gravity",
      SpellFields.Description  : "Enables you to more easily control how fast you fall.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,512,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/gravity_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Steadfastness : {
      SpellFields.Name         : "Steadfastness",
      SpellFields.Description  : "Reduces how far enemies can push and shove you.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,544,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/steadfast_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Melee_Damage : {
      SpellFields.Name         : "Melee Damage",
      SpellFields.Description  : "Increases the damage of your quick melee attack.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,576,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/meleedamage_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Melee_Range : {
      SpellFields.Name         : "Melee Range",
      SpellFields.Description  : "Increases the reach of your quick melee attack.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,608,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/meleerange_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Melee_Force : {
      SpellFields.Name         : "Melee Force",
      SpellFields.Description  : "Increases the distance you shove with your quick melee attack.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,640,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/meleeforce_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Melee_Cooldown : {
      SpellFields.Name         : "Melee Cooldown",
      SpellFields.Description  : "Makes your quick melee attack faster.",
      SpellFields.IconPath     : "res://2_spells/passives/00Stat_Passives/passive_icons.png",
      SpellFields.IconRect     : Rect2(0,672,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/00Stat_Passives/meleecooldown_script.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   
   # ======================================= #
   # DAMAGE MODIFIERS FROM THIS POINT ONWARD #
   # ======================================= #
   PassiveSpellIDs.Boost_Impact : {
      SpellFields.Name         : "Impact Boost",
      SpellFields.Description  : "Increases the power of your IMPACT damage.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/impact_boost.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Boost_Sharp : {
      SpellFields.Name         : "Sharp Boost",
      SpellFields.Description  : "Increases the power of your SHARP damage.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(32,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/sharp_boost.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Boost_Energy : {
      SpellFields.Name         : "Energy Boost",
      SpellFields.Description  : "Increases the power of your ENERGY damage.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(64,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/energy_boost.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Boost_Fire : {
      SpellFields.Name         : "Fire Boost",
      SpellFields.Description  : "Increases the power of your FIRE damage.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(96,0,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/fire_boost.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Boost_Cold : {
      SpellFields.Name         : "Cold Boost",
      SpellFields.Description  : "Increases the power of your COLD damage.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(0,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/cold_boost.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Boost_Zap : {
      SpellFields.Name         : "Zap Boost",
      SpellFields.Description  : "Increases the power of your ZAP damage.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(32,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/zap_boost.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Boost_Rot : {
      SpellFields.Name         : "Rot Boost",
      SpellFields.Description  : "Increases the power of your ROT damage.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(64,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/rot_boost.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Boost_Natural : {
      SpellFields.Name         : "Natural Boost",
      SpellFields.Description  : "Increases the power of your NATURAL damage.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(96,32,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/natural_boost.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Resist_Impact : {
      SpellFields.Name         : "Impact Resistance",
      SpellFields.Description  : "Reduces the amount of IMPACT damage you take.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(0,64,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/impact_resist.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Resist_Sharp : {
      SpellFields.Name         : "Sharp Resistance",
      SpellFields.Description  : "Reduces the amount of SHARP damage you take.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(32,64,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/sharp_resist.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Resist_Energy : {
      SpellFields.Name         : "Energy Resistance",
      SpellFields.Description  : "Reduces the amount of ENERGY damage you take.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(64,64,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/energy_resist.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Resist_Fire : {
      SpellFields.Name         : "Fire Resistance",
      SpellFields.Description  : "Reduces the amount of FIRE damage you take.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(96,64,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/fire_resist.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Resist_Cold : {
      SpellFields.Name         : "Cold Resistance",
      SpellFields.Description  : "Reduces the amount of COLD damage you take.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(0,96,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/cold_resist.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Resist_Zap : {
      SpellFields.Name         : "Zap Resistance",
      SpellFields.Description  : "Reduces the amount of ZAP damage you take.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(32,96,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/zap_resist.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Resist_Rot : {
      SpellFields.Name         : "Rot Resistance",
      SpellFields.Description  : "Reduces the amount of ROT damage you take.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(64,96,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/rot_resist.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
   PassiveSpellIDs.Resist_Natural : {
      SpellFields.Name         : "Natural Resistance",
      SpellFields.Description  : "Reduces the amount of NATURAL damage you take.",
      SpellFields.IconPath     : "res://2_spells/passives/01DmgType_Modifiers/damage_types.png",
      SpellFields.IconRect     : Rect2(96,96,32,32),
      SpellFields.ScriptPath   : "res://2_spells/passives/01DmgType_Modifiers/natural_resist.gd",
      SpellFields.Effects      : [],
      SpellFields.DummyEffects : [],
      SpellFields.Familiars    : []},
}

## a smooth, continuous S-shaped curve bounded by (0, INF) and crossing the point (0, base_value)
## copy and paste the following lines into desmos: (B = base_stat, x = stat_value, S = scaling_factor)
## B+B\operatorname{arcsinh}\left(\frac{Sx}{B}\right)\left\{0\le x\right\}
## B+B\tanh\left(\frac{Sx}{B}\right)\ \left\{x<0\right\}
static func _half_bounded_hyperbolic(base_value: float, stat_value: float, scaling_factor: float) -> float:
   return base_value + (base_value * (asinh((stat_value * scaling_factor)/base_value) if stat_value >= 0 else tanh((stat_value * scaling_factor)/base_value)))

## a smooth, continuous L-shaped curve bounded by (0, INF) and crossing the point (0, base_value)
## copy and paste the following lines into desmos: (B = base_stat, x = stat_value, S = scaling_factor)
## B+Sx\left\{0\le x\right\}
## B+B\tanh\left(\frac{Sx}{B}\right)\ \left\{x<0\right\}
static func _half_bounded_linear(base_value: float, stat_value: float, scaling_factor: float) -> float:
   return base_value + ((stat_value * scaling_factor) if stat_value >= 0 else tanh((stat_value * scaling_factor)/base_value))

## Takes a given [param StatTypes] value and returns a [b]float[/b] based on the player's base stat plus any stat contributions from actives and passives.[br][br]By default (for now), an influenced stat is simply [code]BASESTAT * CONTRIBUTION[/code], but more complicated functions are possible.[br][br]
## "🧑‍🔧" indicates the operation has not been checked yet, and it just in the default X*Y format.
static func get_influenced_stat(id: StatTypes, base_value: float, stat_value: float) -> float:
   match id:
      ## ONE-TO-ONE. Each additional point is one (1.0) additional health.
      StatTypes.HEARTS:         return base_value + stat_value
      ## ONE-TO-ONE. Each additional point is one (1.0) additional armor.
      StatTypes.ARMOR:          return base_value + stat_value
      ## ONE-TO-ONE. Each additional point is one (1.0) additional ward.
      StatTypes.WARD:           return base_value + stat_value
      ## ONE-TO-ONE. Each additional point is one (1.0) additional overhealth.
      StatTypes.OVERHEALTH:     return base_value + stat_value
      StatTypes.ARMOR_STRENGTH: return base_value * stat_value ##🧑‍🔧
      StatTypes.WARD_STRENGTH:  return base_value * stat_value ##🧑‍🔧
      StatTypes.LIFESTEAL:      return base_value * stat_value ##🧑‍🔧
      ## HALF-BOUNDED HYPERBOLIC. Diminishing growth. 2x damage at 5 stacks, 3x at 15, 4x at 40. 
      StatTypes.DAMAGE:         return _half_bounded_hyperbolic(base_value, stat_value, 0.25)
      StatTypes.RANGE:          return _half_bounded_linear(base_value, stat_value, 1)
      ## ADD FIVE PERCENT. Each additional point causes active ability cooldowns to go 5% faster (20 stacks needed for a 1/2 reduction).
      StatTypes.COOLDOWN:       return 1 + ( ( base_value + stat_value ) * 0.05 )
      StatTypes.FORCE:          return _half_bounded_hyperbolic(base_value, stat_value, 0.5)
      StatTypes.CRIT:           return base_value * stat_value ##🧑‍🔧
      StatTypes.LUCK:           return base_value * stat_value ##🧑‍🔧
      ## ADDITIVE. Each additional point of speed increases walk speed by ~1 m/s
      StatTypes.SPEED:          return _half_bounded_linear(base_value, stat_value, 1)
      ## ADDITIVE. Each additional point increases sprint speed by an amount equal to 1/4 walk speed.
      StatTypes.SPRINT:         return base_value + ( stat_value * 0.25 )
      StatTypes.JUMP:           return base_value + stat_value ##🧑‍🔧
      ## PLATFORMER JUMPS. While the "jump" button is held, gravity is low. When the "jump" button is released, gravity is high.
      StatTypes.GRAVITY:        return base_value * pow( 2.0 , ( -( stat_value * 0.25 ) / 2 ) ) if Input.is_action_pressed("jump") else base_value * pow( 2.0 , ( ( stat_value * 0.25 ) / 2 ) )
      StatTypes.STEADFASTNESS:  return _half_bounded_linear(base_value, stat_value, 0.5)
      ## ONE-TO-ONE. Each additional point is one (1.0) additional point of damage.
      StatTypes.MELEE_DAMAGE:   return base_value + stat_value ##🧑‍🔧
      ## ADDITIVE. Each additional point of range increases the Area3D by 0.5m
      StatTypes.MELEE_RANGE:    return base_value + ( stat_value * 0.5 ) ##🧑‍🔧
      StatTypes.MELEE_FORCE:    return base_value + stat_value if (base_value + stat_value) >= 0 else 0.0
      ## ADD FIVE PERCENT. Each additional point causes active ability cooldowns to go 5% faster (20 stacks needed for a 1/2 reduction).
      StatTypes.MELEE_COOLDOWN: return 1 + ( ( base_value + stat_value ) * 0.05 )
      _: printerr("SpellData.get_influenced_stat() STAT ", id, " NOT FOUND. RETURNING 0."); return 0

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
