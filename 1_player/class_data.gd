class_name ClassData


enum ClassIDs {NakedManChallenge, Test_A, Test_B}
enum ClassFields {ACTIVES, PASSIVES}

const ClassRecipes: Dictionary = {
   ClassIDs.NakedManChallenge : {
      ClassFields.ACTIVES : [],
      ClassFields.PASSIVES: {}
   },
   
   ClassIDs.Test_A : {
      ClassFields.ACTIVES : [SpellData.ActiveSpellIDs.Teleport],
      ClassFields.PASSIVES: {
         SpellData.PassiveSpellIDs.SpeedUp : 5
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
