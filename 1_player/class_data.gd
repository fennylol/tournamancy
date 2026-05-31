class_name ClassData


enum ClassIDs {Test_A, Test_B}
enum ClassFields {ACTIVES, PASSIVES}

const ClassRecipes: Dictionary = {
   ClassIDs.Test_A : {
      ClassFields.ACTIVES : [AbilityData.ActiveAbilityIDs.Teleport],
      ClassFields.PASSIVES: []
   },
   
   ClassIDs.Test_B : {
      ClassFields.ACTIVES : [],
      ClassFields.PASSIVES: []
   }
}
