class_name AbilityData

enum StatTypes {HEALTH, SPEED, JUMP, GRAVITY}

enum AbilityFields {Name, IconPath, ScriptPath} # may at some point break this into PassiveAbilityFields and ActiveAbilityFields

enum ActiveAbilityIDs {Teleport, Fireball}
const ActiveAbilities: Dictionary = {
   ActiveAbilityIDs.Teleport : {
      AbilityFields.Name : "Warpstone",
      AbilityFields.IconPath : "res://2_actives/Teleport/teleport_icon.png",
      AbilityFields.ScriptPath : "res://2_actives/Teleport/teleport_script.gd"
   }
   
}

enum PassiveAbilityIDs {SpeedUp, JumpUp, GravityUp}
const PassiveAbilities: Dictionary = {
   PassiveAbilityIDs.SpeedUp : {
      AbilityFields.Name : "Speed Boost",
      AbilityFields.IconPath : "",
      AbilityFields.ScriptPath : ""
   },
   
}
