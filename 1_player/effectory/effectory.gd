extends Node3D
class_name Effectory

@export var IsDummy: bool = true

func equip_effect(spell_id: int, is_active: bool) -> void:
   if _get_effect(spell_id, is_active):
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
   if not _get_effect(spell_id, is_active): return
func change_effect_state(spell_id: int, is_active: bool, _spell_state: int) -> void:
   if not _get_effect(spell_id, is_active): return

func _get_effect(spell_id: int, is_active: bool) -> Node3D:
   var node_title: String = _get_effect_spell_name(spell_id, is_active)
   for child:Node3D in get_children():
      if child.name == node_title:
         return child
   return null
func _get_effect_spell_name(spell_id: int, is_active: bool) -> String: 
   return SpellData.ActiveSpellIDs.find_key(spell_id) if is_active else SpellData.PassiveSpellIDs.find_key(spell_id)
