class_name SpellList

func _jump_to_active_spells() -> void: print("this exists for sidebar navigation.")
#SpellData.ActiveSpellIDs.:{
      #SpellData.SpellFields.Name         : "",
      #SpellData.SpellFields.Description  : "",
      #SpellData.SpellFields.IconPath     : ,
      #SpellData.SpellFields.IconRect     : Rect2(0,0,32,32),
      #SpellData.SpellFields.ScriptPath   : ,
      #SpellData.SpellFields.Cooldown     : 1.0,
      #SpellData.SpellFields.Effects      : [],
      #SpellData.SpellFields.DummyEffects : [],
      #SpellData.SpellFields.Familiars    : []
   #},
const ActiveSpells: Dictionary = {
   SpellData.ActiveSpellIDs.CelestialAnchor:{
      SpellData.SpellFields.Name         : "Celestial Anchor",
      SpellData.SpellFields.Description  : "Lock yourself to the sky for a moment, so you cannot fall or rise.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/actives/misc_active_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(32,128,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/actives/CelestialAnchor/celestialanchor_script.gd"),
      SpellData.SpellFields.Cooldown     : 10.0,
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []
   },
   SpellData.ActiveSpellIDs.CrimsonThorn:{
      SpellData.SpellFields.Name         : "Crimson Thorn",
      SpellData.SpellFields.Description  : "Drop a small bramble on the ground which harms anyone who walks over it.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/actives/misc_active_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,64,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/actives/CrimsonThorn/crimsonthorn_script.gd"),
      SpellData.SpellFields.Cooldown     : 1.0,
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []
   },
   SpellData.ActiveSpellIDs.GreatBallOfFire:{
      SpellData.SpellFields.Name         : "Great Ball o' Fire",
      SpellData.SpellFields.Description  : "Launches a small (but powerful) fireball.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/actives/misc_active_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(96,0,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/actives/GreatBallOFire/great_ball_o_fire_script.gd"),
      SpellData.SpellFields.Cooldown     : 0.5,
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : [preload("res://2_spells/actives/GreatBallOFire/familiar/great_ball_of_fire_familiar.gd")]
   },
   SpellData.ActiveSpellIDs.IronBody:{
      SpellData.SpellFields.Name         : "Iron Body",
      SpellData.SpellFields.Description  : "Immediately grants a boost of health that fades over time.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/actives/misc_active_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(32,0,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/actives/IronBody/ironbody_script.gd"),
      SpellData.SpellFields.Cooldown     : 10.0,
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []
   },
   SpellData.ActiveSpellIDs.LunarTowline:{
      SpellData.SpellFields.Name         : "Lunar Towline",
      SpellData.SpellFields.Description  : "Cast a fishing line to snag an enemy, then pull them towards you.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/actives/misc_active_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,128,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/actives/LunarTowline/lunartowline_script.gd"),
      SpellData.SpellFields.Cooldown     : 3.0,
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : [preload("res://2_spells/actives/LunarTowline/familiar/lunartowline_hook.gd")]
   },
   SpellData.ActiveSpellIDs.ShockstarDisco:{
      SpellData.SpellFields.Name         : "Shockstar Disco",
      SpellData.SpellFields.Description  : "Fires a bounding disco ball that damages nearby enemies.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/actives/misc_active_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,32,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/actives/ShockstarDisco/shockstardisco_script.gd"),
      SpellData.SpellFields.Cooldown     : 0.5,
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : [preload("res://2_spells/actives/ShockstarDisco/familiar/disco_ball_familiar.gd")]
   },
   SpellData.ActiveSpellIDs.StarlightBlink:{
      SpellData.SpellFields.Name         : "Starlight Blink",
      SpellData.SpellFields.Description  : "Teleport a short distance forward in an instant.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/actives/misc_active_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(32,32,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/actives/StarlightBlink/starlightblink_script.gd"),
      SpellData.SpellFields.Cooldown     : 5.0,
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []
   },
   SpellData.ActiveSpellIDs.Thunderwave:{
      SpellData.SpellFields.Name         : "Thunderwave",
      SpellData.SpellFields.Description  : "Projects a wave of energy that damages and shoves enemies away from you.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/actives/misc_active_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/actives/Thunderwave/thunderwave_script.gd"),
      SpellData.SpellFields.Cooldown     : 4.0,
      SpellData.SpellFields.Effects      : [preload("res://2_spells/actives/Thunderwave/Effects/ThunderwaveArea.tscn")],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : [preload("res://2_spells/actives/Thunderwave/Familiar/thunderwave_familiar.gd")]
   },
   SpellData.ActiveSpellIDs.PulsarsBreath:{
      SpellData.SpellFields.Name         : "Pulsar's Breath",
      SpellData.SpellFields.Description  : "An instant beam of high energy, reaching light-years away in an instant.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/actives/PulsarsBreath/icon.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/actives/PulsarsBreath/pulsars_breath_script.gd"),
      SpellData.SpellFields.Cooldown     : 0.0,
      SpellData.SpellFields.Effects      : [preload("res://2_spells/actives/PulsarsBreath/Effects/pulsars_breath_raycast.tscn")],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : [preload("res://2_spells/actives/PulsarsBreath/Familiar/pulsars_breath_familiar.gd")]
   }
}



func _jump_to_passive_spells() -> void: print("this exists for sidebar navigation.")
#SpellData.PassiveSpellIDs. : {
      #SpellData.SpellFields.Name         : "",
      #SpellData.SpellFields.Description  : "",
      #SpellData.SpellFields.IconPath     : ,
      #SpellData.SpellFields.IconRect     : Rect2(0,0,32,32),
      #SpellData.SpellFields.ScriptPath   : ,
      #SpellData.SpellFields.Cooldown     : 1.0,
      #SpellData.SpellFields.Effects      : [],
      #SpellData.SpellFields.DummyEffects : [],
      #SpellData.SpellFields.Familiars    : []
   #}
const PassiveSpells: Dictionary = {
   SpellData.PassiveSpellIDs.JBLSpeaker : {
      SpellData.SpellFields.Name         : "BigAssSpeaker",
      SpellData.SpellFields.Description  : "",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/actives/misc_active_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(96,32,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/JBL_Speaker/jbl_speaker_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [preload("res://2_spells/passives/JBL_Speaker/JBLSpeakerSoundEffect.tscn")],
      SpellData.SpellFields.Familiars    : []
   },
   SpellData.PassiveSpellIDs.MoonJump : {
      SpellData.SpellFields.Name         : "Moon Jump",
      SpellData.SpellFields.Description  : "Allows you to jump in the air one additional time.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/actives/misc_active_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(64,32,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/MoonJump/moonjump_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []
   },
   SpellData.PassiveSpellIDs.PhantomFlight : {
      SpellData.SpellFields.Name         : "Phantom Flight",
      SpellData.SpellFields.Description  : "Move faster when no one is nearby. Most slower when they are.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/PhantomFlight/icon.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/PhantomFlight/phantom_flight_script.gd"),
      SpellData.SpellFields.Effects      : [
         preload("res://2_spells/passives/PhantomFlight/effects/PhantomFlightAreaEffect.tscn"),
         preload("res://2_spells/passives/PhantomFlight/effects/phantom_flight_visual_indicator.tscn")
      ],
      SpellData.SpellFields.DummyEffects : [preload("res://2_spells/passives/PhantomFlight/effects/phantom_flight_visual_indicator.tscn")],
      SpellData.SpellFields.Familiars    : []
   },
   
   # ==================================== #
   # STAT PASSIVES FROM THIS POINT ONWARD #
   # ==================================== #
   SpellData.PassiveSpellIDs.Heart : {
      SpellData.SpellFields.Name         : "Heart",
      SpellData.SpellFields.Description  : "Increases the amount of damage you can take before you are knocked out.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/health_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Armor : {
      SpellData.SpellFields.Name         : "Armor",
      SpellData.SpellFields.Description  : "Adds bonus health which reduces incoming damage by a flat amount. Effective against weak, fast attacks",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,32,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/armor_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Ward : {
      SpellData.SpellFields.Name         : "Ward",
      SpellData.SpellFields.Description  : "Adds bonus health which reduces incoming damage by a percent if you haven't been damaged in some time. Effective against strong, slow attacks.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,64,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/ward_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Overhealth : {
      SpellData.SpellFields.Name         : "Overhealth",
      SpellData.SpellFields.Description  : "Adds bonus health which decays over time.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,96,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/overhealth_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Armor_Strength : {
      SpellData.SpellFields.Name         : "Armor Strength",
      SpellData.SpellFields.Description  : "Increases the amount that your 'Armor' reduces incoming damage by.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,128,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/armorstrength_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Ward_Strength : {
      SpellData.SpellFields.Name         : "Ward Strength",
      SpellData.SpellFields.Description  : "Increases the maximum percentage that your 'Ward' reduces incoming damage by.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,160,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/wardstrength_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Lifesteal : {
      SpellData.SpellFields.Name         : "Lifesteal",
      SpellData.SpellFields.Description  : "Increases how much damage you can convert into health.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,192,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/lifesteal_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Damage : {
      SpellData.SpellFields.Name         : "Damage",
      SpellData.SpellFields.Description  : "Increases how much damage your spells deal.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,224,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/damage_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Attack_Range : {
      SpellData.SpellFields.Name         : "Range",
      SpellData.SpellFields.Description  : "Increases how far your spells can reach.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,256,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/range_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Cooldown : {
      SpellData.SpellFields.Name         : "Cooldown",
      SpellData.SpellFields.Description  : "Reduces the time it takes for your active abilities to recharge.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,288,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/cooldown_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Force : {
      SpellData.SpellFields.Name         : "Force",
      SpellData.SpellFields.Description  : "Increases the effectiveness of your pushing and shoving effects.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,320,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/force_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Crit : {
      SpellData.SpellFields.Name         : "Critical",
      SpellData.SpellFields.Description  : "Causes your spells to deal additional damage on a critical hit.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,352,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/critical_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Luck : {
      SpellData.SpellFields.Name         : "Luck",
      SpellData.SpellFields.Description  : "Increases the likelyhood of chance-based effects.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,384,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/luck_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Speed : {
      SpellData.SpellFields.Name         : "Speed",
      SpellData.SpellFields.Description  : "Increases how fast you can walk.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,416,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/speed_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Sprint : {
      SpellData.SpellFields.Name         : "Sprint",
      SpellData.SpellFields.Description  : "Greatly increases how fast you can run.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,448,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/sprint_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Jump : {
      SpellData.SpellFields.Name         : "Jump Height",
      SpellData.SpellFields.Description  : "Increases how high you can jump.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,480,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/jump_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Gravity : {
      SpellData.SpellFields.Name         : "Gravity",
      SpellData.SpellFields.Description  : "Enables you to more easily control how fast you fall.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,512,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/gravity_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Steadfastness : {
      SpellData.SpellFields.Name         : "Steadfastness",
      SpellData.SpellFields.Description  : "Reduces how far enemies can push and shove you.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,544,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/steadfast_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Melee_Damage : {
      SpellData.SpellFields.Name         : "Melee Damage",
      SpellData.SpellFields.Description  : "Increases the damage of your quick melee attack.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,576,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/meleedamage_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Melee_Range : {
      SpellData.SpellFields.Name         : "Melee Range",
      SpellData.SpellFields.Description  : "Increases the reach of your quick melee attack.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,608,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/meleerange_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Melee_Force : {
      SpellData.SpellFields.Name         : "Melee Force",
      SpellData.SpellFields.Description  : "Increases the distance you shove with your quick melee attack.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,640,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/meleeforce_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Melee_Cooldown : {
      SpellData.SpellFields.Name         : "Melee Cooldown",
      SpellData.SpellFields.Description  : "Makes your quick melee attack faster.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/00Stat_Passives/passive_icons.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,672,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/00Stat_Passives/meleecooldown_script.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   
   # ======================================= #
   # DAMAGE MODIFIERS FROM THIS POINT ONWARD #
   # ======================================= #
   SpellData.PassiveSpellIDs.Boost_Impact : {
      SpellData.SpellFields.Name         : "Impact Boost",
      SpellData.SpellFields.Description  : "Increases the power of your IMPACT damage.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,0,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/impact_boost.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Boost_Sharp : {
      SpellData.SpellFields.Name         : "Sharp Boost",
      SpellData.SpellFields.Description  : "Increases the power of your SHARP damage.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(32,0,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/sharp_boost.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Boost_Energy : {
      SpellData.SpellFields.Name         : "Energy Boost",
      SpellData.SpellFields.Description  : "Increases the power of your ENERGY damage.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(64,0,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/energy_boost.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Boost_Fire : {
      SpellData.SpellFields.Name         : "Fire Boost",
      SpellData.SpellFields.Description  : "Increases the power of your FIRE damage.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(96,0,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/fire_boost.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Boost_Cold : {
      SpellData.SpellFields.Name         : "Cold Boost",
      SpellData.SpellFields.Description  : "Increases the power of your COLD damage.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,32,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/cold_boost.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Boost_Zap : {
      SpellData.SpellFields.Name         : "Zap Boost",
      SpellData.SpellFields.Description  : "Increases the power of your ZAP damage.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(32,32,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/zap_boost.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Boost_Rot : {
      SpellData.SpellFields.Name         : "Rot Boost",
      SpellData.SpellFields.Description  : "Increases the power of your ROT damage.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(64,32,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/rot_boost.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Boost_Natural : {
      SpellData.SpellFields.Name         : "Natural Boost",
      SpellData.SpellFields.Description  : "Increases the power of your NATURAL damage.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(96,32,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/natural_boost.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Resist_Impact : {
      SpellData.SpellFields.Name         : "Impact Resistance",
      SpellData.SpellFields.Description  : "Reduces the amount of IMPACT damage you take.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,64,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/impact_resist.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Resist_Sharp : {
      SpellData.SpellFields.Name         : "Sharp Resistance",
      SpellData.SpellFields.Description  : "Reduces the amount of SHARP damage you take.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(32,64,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/sharp_resist.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Resist_Energy : {
      SpellData.SpellFields.Name         : "Energy Resistance",
      SpellData.SpellFields.Description  : "Reduces the amount of ENERGY damage you take.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(64,64,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/energy_resist.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Resist_Fire : {
      SpellData.SpellFields.Name         : "Fire Resistance",
      SpellData.SpellFields.Description  : "Reduces the amount of FIRE damage you take.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(96,64,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/fire_resist.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Resist_Cold : {
      SpellData.SpellFields.Name         : "Cold Resistance",
      SpellData.SpellFields.Description  : "Reduces the amount of COLD damage you take.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(0,96,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/cold_resist.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Resist_Zap : {
      SpellData.SpellFields.Name         : "Zap Resistance",
      SpellData.SpellFields.Description  : "Reduces the amount of ZAP damage you take.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(32,96,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/zap_resist.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Resist_Rot : {
      SpellData.SpellFields.Name         : "Rot Resistance",
      SpellData.SpellFields.Description  : "Reduces the amount of ROT damage you take.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(64,96,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/rot_resist.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
   SpellData.PassiveSpellIDs.Resist_Natural : {
      SpellData.SpellFields.Name         : "Natural Resistance",
      SpellData.SpellFields.Description  : "Reduces the amount of NATURAL damage you take.",
      SpellData.SpellFields.IconPath     : preload("res://2_spells/passives/01DmgType_Modifiers/damage_types.png"),
      SpellData.SpellFields.IconRect     : Rect2(96,96,32,32),
      SpellData.SpellFields.ScriptPath   : preload("res://2_spells/passives/01DmgType_Modifiers/natural_resist.gd"),
      SpellData.SpellFields.Effects      : [],
      SpellData.SpellFields.DummyEffects : [],
      SpellData.SpellFields.Familiars    : []},
}

static func get_active_spell_data(id: SpellData.ActiveSpellIDs) -> Dictionary:
   if ActiveSpells.keys().has(id): return ActiveSpells[id]
   else: return {}

static func is_valid_active_spell(data: Dictionary) -> bool:
   for field:String in SpellData.SpellFields:
      if not data.keys().has(SpellData.SpellFields.get(field)): return false
   return true

static func get_passive_spell_data(id: SpellData.PassiveSpellIDs) -> Dictionary:
   if PassiveSpells.keys().has(id): return PassiveSpells[id]
   else: return {}

static func is_valid_passive_spell(data: Dictionary) -> bool:
   for field:String in SpellData.SpellFields:
      if field == "Cooldown": continue
      if not data.keys().has(SpellData.SpellFields.get(field)): return false
   return true
