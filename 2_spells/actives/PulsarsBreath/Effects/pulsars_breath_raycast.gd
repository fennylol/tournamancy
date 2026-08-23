extends Effect

@onready var LOS: RayCast3D = $RayCast3D

func _init() -> void: FollowsEyes = true

func on_state_changed(_new_state: int) -> void:
   var contact_point: Vector3
   
   if LOS.is_colliding():
      var hit_body = LOS.get_collider()
      var parent_node: Node3D = hit_body.get_parent()
      if parent_node and parent_node is Dummy:
         send_damage(parent_node)
      
      contact_point = to_local(LOS.get_collision_point())
   else: contact_point = Vector3(0,0,-100)  
   var ocular_dist: float = 0.25
   var pos    : Vector3 = to_global(position+Vector3(0, 0, (contact_point.z-ocular_dist)/2))
   var rot    : Vector3 = global_rotation + Vector3(PI/2, 0, 0)
   var length : float   = -contact_point.z-ocular_dist

   var new_fam := PulsarsBreathFamiliar.new(ThePlayer.NETWORK_ID, pos, rot, length)
   var data := new_fam.reduce_to_byte_array()
   ThePlayer.spawn_familiar(true, SpellData.ActiveSpellIDs.PulsarsBreath, PulsarsBreath.FamiliarIDs.PULSAR_BEAM, data)
      

func send_damage(enemy : Dummy):
   var stat_influenced_damage : float = PulsarsBreath.SPELL_DAMAGE * SpellData.get_influenced_stat(SpellData.StatTypes.DAMAGE, SettingsManager.match_settings.PLAYER_BASE_STATS[SpellData.StatTypes.DAMAGE], ThePlayer.SpellBook.get_stat(SpellData.StatTypes.DAMAGE))
   var stat_influenced_force  : float = 0.0
   
   var new_damage_package = DamagePackage.new()
   new_damage_package.id_from = ThePlayer.NETWORK_ID
   new_damage_package.id_to = enemy.NETWORK_ID
   new_damage_package.location_source = ThePlayer.global_position
   new_damage_package.location_receipt = enemy.global_position
   new_damage_package.amount = stat_influenced_damage
   new_damage_package.type = DamagePackage.DamageType.ZAP
   new_damage_package.force = stat_influenced_force
   ThePlayer.send_damage_package(new_damage_package)

      
