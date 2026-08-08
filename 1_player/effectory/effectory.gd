extends Node3D
class_name Effectory

@export var IsDummy: bool = true

func sync_effects(list_of_actives : Array[SpellData.ActiveSpellIDs], list_of_passives : Array[SpellData.PassiveSpellIDs]):
   ## REMOVE LOOSE NODES
   for child : Node3D in get_children():
      var shall_be_deleted := true
      for active in list_of_actives: if _get_effect_spell_name(active, true) == child.name: shall_be_deleted = false
      for passive in list_of_passives: if _get_effect_spell_name(passive, false) == child.name: shall_be_deleted = false
      if shall_be_deleted: child.queue_free()
   ## ADD NODES FOR NEW SPELLS
   for active in list_of_actives: equip_effect(active, true)
   for passive in list_of_passives: equip_effect(passive, false)
func equip_effect(spell_id: int, is_active: bool) -> void:
   if _get_effect_container(spell_id, is_active):
      return
   
   var container_node := Node3D.new()
   container_node.name = _get_effect_spell_name(spell_id, is_active)
   
   var spell_data: Dictionary = SpellData.get_active_spell_data(spell_id) if is_active else SpellData.get_passive_spell_data(spell_id)
   if not ((is_active and SpellData.is_valid_active_spell(spell_data)) or SpellData.is_valid_passive_spell(spell_data)): return
   var effect_list: Array = spell_data[SpellData.SpellFields.DummyEffects if IsDummy else SpellData.SpellFields.Effects]
   
   for effect in effect_list:
      var effect_node: Node3D = load(effect).instantiate()
      container_node.add_child(effect_node)
   
   add_child(container_node)
func erase_effect(spell_id: int, is_active: bool) -> void:
   if not _get_effect_container(spell_id, is_active): return
func change_effect_state(spell_id: int, is_active: bool, spell_state: int) -> void:
   var effect_container: Node3D = _get_effect_container(spell_id, is_active)
   if not effect_container: return
   for child:Node3D in effect_container.get_children():
      if not child is Effect: continue
      child.change_state(spell_state)

func _get_effect_container(spell_id: int, is_active: bool) -> Node3D:
   var node_title: String = _get_effect_spell_name(spell_id, is_active)
   for child:Node3D in get_children():
      if child.name == node_title:
         return child
   return null
func _get_effect_spell_name(spell_id: int, is_active: bool) -> String: 
   return SpellData.ActiveSpellIDs.find_key(spell_id) if is_active else SpellData.PassiveSpellIDs.find_key(spell_id)
