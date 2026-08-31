class_name ClassData


enum ClassIDs {NakedManChallenge, Tank, Ranger, Speedster, FireGuy, JohnCarter, Test_A,}
enum ClassFields {ACTIVES, PASSIVES, NAME, DESCRIPTION}

const ClassRecipes: Dictionary = {
   ClassIDs.NakedManChallenge : {
      ClassFields.NAME : "Naked Man Challenge",
      ClassFields.DESCRIPTION : "No additional spells.",
      ClassFields.ACTIVES : [],
      ClassFields.PASSIVES: {}
   },
   
   ClassIDs.Tank : {
      ClassFields.NAME : "The Adamant",
      ClassFields.DESCRIPTION : "Moves slowly, but comes with extra health and a spell that packs a punch.",
      ClassFields.ACTIVES : [SpellData.ActiveSpellIDs.Thunderwave, SpellData.ActiveSpellIDs.IronBody],
      ClassFields.PASSIVES: {
         SpellData.PassiveSpellIDs.Speed : -2,
         SpellData.PassiveSpellIDs.Damage : 5,
         SpellData.PassiveSpellIDs.Heart : 4,
         SpellData.PassiveSpellIDs.Steadfastness : 1,
         SpellData.PassiveSpellIDs.Resist_Impact : 1
      }
   },
   
   ClassIDs.Speedster : {
      ClassFields.NAME : "Dancekiller",
      ClassFields.DESCRIPTION : "Moves fast and jumps high with a bouncing attack and a short teleport.[br]🕺💃",
      ClassFields.ACTIVES : [SpellData.ActiveSpellIDs.ShockstarDisco, SpellData.ActiveSpellIDs.PolytopeParty],
      ClassFields.PASSIVES: {
         SpellData.PassiveSpellIDs.Speed : 5,
         SpellData.PassiveSpellIDs.Gravity : 4,
         SpellData.PassiveSpellIDs.Jump : 1
      }
   },
   
   ClassIDs.Ranger : {
      ClassFields.NAME : "Beam and Shadow",
      ClassFields.DESCRIPTION : "Moves swiftly and silently to attack from a distance. Threatened by enemies nearby.",
      ClassFields.ACTIVES  : [SpellData.ActiveSpellIDs.PulsarsBreath, SpellData.ActiveSpellIDs.CrimsonThorn],
      ClassFields.PASSIVES : {
         SpellData.PassiveSpellIDs.PhantomFlight: 1,
         SpellData.PassiveSpellIDs.Gravity : 2,
         SpellData.PassiveSpellIDs.Cooldown : 2,
         SpellData.PassiveSpellIDs.Resist_Sharp : 1,
      }
   },
   
   ClassIDs.FireGuy : {
      ClassFields.NAME : "Pyro Technica",
      ClassFields.DESCRIPTION : "Burns hot and bright, but not for very long. Has some of the strongest spells, but comes with low health and survivability.",
      ClassFields.ACTIVES : [SpellData.ActiveSpellIDs.GreatBallOfFire],
      ClassFields.PASSIVES: {
         ## super resistant to fire but weakness to every other type. lots of damage boosts.
      }
   },
   
   ClassIDs.JohnCarter : {
      ClassFields.NAME : "Moonlight Angler",
      ClassFields.DESCRIPTION : "A fisher who lives high up in the sky, throwing their line to those below. High control, low damage.",
      ClassFields.ACTIVES : [SpellData.ActiveSpellIDs.LunarTowline, SpellData.ActiveSpellIDs.CelestialAnchor],
      ClassFields.PASSIVES: {
         SpellData.PassiveSpellIDs.MoonJump : 2,
         SpellData.PassiveSpellIDs.Jump : 5,
         SpellData.PassiveSpellIDs.Attack_Range : 3,
         SpellData.PassiveSpellIDs.Force : 1,
         SpellData.PassiveSpellIDs.Gravity : 4,
         SpellData.PassiveSpellIDs.Damage : -2
      }
   },
   
   ClassIDs.Test_A : {
      ClassFields.NAME : "TEST_A",
      ClassFields.DESCRIPTION : "comes with a free JBL speaker!",
      ClassFields.ACTIVES : [],
      ClassFields.PASSIVES: {
         SpellData.PassiveSpellIDs.JBLSpeaker : 1
      }
   },
}

static func get_class_data(id: ClassIDs) -> Dictionary:
   if ClassRecipes.keys().has(id): return ClassRecipes[id]
   else: return {}

static func is_valid_class(class_data: Dictionary) -> bool:
   if not class_data.keys().has(ClassFields.ACTIVES): return false
   if not class_data[ClassFields.ACTIVES] is Array: return false
   for id in class_data[ClassFields.ACTIVES]:
      if not id is SpellData.ActiveSpellIDs: return false
   
   if not class_data.keys().has(ClassFields.PASSIVES): return false
   if not class_data[ClassFields.PASSIVES] is Dictionary: return false
   for id in class_data[ClassFields.PASSIVES]:
      if not id is SpellData.PassiveSpellIDs: return false
      if not class_data[ClassFields.PASSIVES][id] is int: return false
   
   return true
