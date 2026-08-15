class_name ClassData


enum ClassIDs {NakedManChallenge, Tank, Ranger, Speedster, Test_A,}
enum ClassFields {ACTIVES, PASSIVES}

const ClassRecipes: Dictionary = {
   ClassIDs.NakedManChallenge : {
      ClassFields.ACTIVES : [],
      ClassFields.PASSIVES: {}
   },
   
   ClassIDs.Tank : {
      ClassFields.ACTIVES : [SpellData.ActiveSpellIDs.Thunderwave, SpellData.ActiveSpellIDs.IronBody],
      ClassFields.PASSIVES: {
         SpellData.PassiveSpellIDs.Speed : -2,
         #SpellData.PassiveSpellIDs.Gravity : 0,
         SpellData.PassiveSpellIDs.Damage : 5,
         SpellData.PassiveSpellIDs.Heart : 4
      }
   },
   
   ClassIDs.Speedster : {
      ClassFields.ACTIVES : [SpellData.ActiveSpellIDs.ShockstarDisco, SpellData.ActiveSpellIDs.StarlightBlink],
      ClassFields.PASSIVES: {
         SpellData.PassiveSpellIDs.Speed : 5,
         SpellData.PassiveSpellIDs.Gravity : 5,
         SpellData.PassiveSpellIDs.MoonJump : 1
      }
   },
   
   ClassIDs.Ranger : {
      ClassFields.ACTIVES  : [SpellData.ActiveSpellIDs.GreatBallOfFire, SpellData.ActiveSpellIDs.GreatBallOfFire],
      ClassFields.PASSIVES : {
         SpellData.PassiveSpellIDs.PhantomFlight: 1
      }
   },
   
   ClassIDs.Test_A : {
      ClassFields.ACTIVES : [SpellData.ActiveSpellIDs.GreatBallOfFire, SpellData.ActiveSpellIDs.GreatBallOfFire],
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
