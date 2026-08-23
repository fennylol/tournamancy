extends Effect

@onready var DAMAGE_AREA : Area3D = $Area3D

var SPELL_DAMAGE : float = 3.5
var SPELL_FORCE  : float = 5.0
var SPELL_RANGE  : float = 4.0

func _init() -> void: FollowsEyes = true

func on_state_changed(new_state: ThunderwaveSpell.States) -> void:
   var new_range : float = SPELL_RANGE * SpellData.get_influenced_stat(SpellData.StatTypes.RANGE, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.RANGE], ThePlayer.SpellBook.get_stat(SpellData.StatTypes.RANGE))
   DAMAGE_AREA.get_child(0).shape.size.z = new_range
   DAMAGE_AREA.get_child(0).position.z = -(new_range / 2)
   
   if new_state == ThunderwaveSpell.States.DAMAGE_WAVE:
      for i in DAMAGE_AREA.get_overlapping_bodies():
         if i.get_parent() is Dummy: 
            send_damage(i.get_parent())
   
   var pos : Vector3 = to_global(position)
   var rot : Vector3 = global_rotation
   var siz : Vector3 = Vector3(DAMAGE_AREA.get_child(0).shape.size.x , DAMAGE_AREA.get_child(0).shape.size.y , 0.15)
   var rch : float   = new_range
   var new_fam := ThunderwaveFamiliar.new(ThePlayer.NETWORK_ID, pos, rot, siz, rch)
   var data := new_fam.reduce_to_byte_array()
   ThePlayer.spawn_familiar(true, SpellData.ActiveSpellIDs.Thunderwave, ThunderwaveSpell.FamiliarIDs.WAVE, data)

func send_damage(enemy : Dummy):
   var stat_influenced_damage : float = SPELL_DAMAGE * SpellData.get_influenced_stat(SpellData.StatTypes.DAMAGE, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.DAMAGE], ThePlayer.SpellBook.get_stat(SpellData.StatTypes.DAMAGE))
   var stat_influenced_force  : float = SPELL_FORCE  * SpellData.get_influenced_stat(SpellData.StatTypes.FORCE, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.FORCE], ThePlayer.SpellBook.get_stat(SpellData.StatTypes.FORCE))
   
   var new_damage_package = DamagePackage.new()
   new_damage_package.id_from = ThePlayer.NETWORK_ID
   new_damage_package.id_to = enemy.NETWORK_ID
   new_damage_package.location_source = ThePlayer.global_position
   new_damage_package.location_receipt = enemy.global_position
   new_damage_package.amount = stat_influenced_damage
   new_damage_package.type = DamagePackage.DamageType.ENERGY
   new_damage_package.force = stat_influenced_force
   ThePlayer.send_damage_package(new_damage_package)
