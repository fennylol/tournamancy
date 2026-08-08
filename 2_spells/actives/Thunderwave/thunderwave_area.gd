extends Effect

@onready var DAMAGE_AREA : Area3D = $Area3D

var SPELL_DAMAGE : float = 3.5
var SPELL_FORCE  : float = 1.0

func change_state(new_state: ThunderwaveSpell.States) -> void:
   if new_state == ThunderwaveSpell.States.DAMAGE_WAVE:
      for i in DAMAGE_AREA.get_overlapping_bodies():
         if i.get_parent() is Dummy: send_damage(i.get_parent())

func send_damage(enemy : Dummy):
   var stat_influenced_damage : float = SPELL_DAMAGE * SpellData.get_influenced_stat(SpellData.StatTypes.DAMAGE, ThePlayer.BASE_DAMAGE, ThePlayer.SpellBook.get_stat(SpellData.StatTypes.DAMAGE))
   var stat_influenced_force  : float = SPELL_FORCE  * SpellData.get_influenced_stat(SpellData.StatTypes.FORCE, ThePlayer.BASE_FORCE, ThePlayer.SpellBook.get_stat(SpellData.StatTypes.FORCE))
   
   #enemy.recieve_damage(stat_influenced_damage) ## this should probably route through mpm and tournamancy instead of being called directly
   var new_damage_package = DamagePackage.new()
   new_damage_package.id_from = ThePlayer.MY_NETWORK_ID
   new_damage_package.id_to = enemy.NETWORK_ID
   new_damage_package.location_source = ThePlayer.global_position
   new_damage_package.location_receipt = enemy.global_position
   new_damage_package.amount = stat_influenced_damage
   new_damage_package.type = DamagePackage.DamageType.ZAP
   new_damage_package.force = stat_influenced_force
   ThePlayer.send_damage_package(new_damage_package)
