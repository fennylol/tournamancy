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
   PolytopeParty,
   PulsarsBreath,
   ShockstarDisco,
   StarlightBlink,
   Thunderwave,
   ERROR = -1
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
