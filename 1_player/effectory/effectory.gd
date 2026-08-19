extends Node3D
class_name Effectory

signal spell_state_changed(spell_id: int, is_active: bool, new_state: int)

# export so we can set the effectory in the player scene to not dummy mode
@export var IsDummy: bool = true
@export var EyeRemote: RemoteTransform3D

var EyesEffects := Node3D.new()
var BodyEffects := Node3D.new()

func _ready() -> void:
   EyesEffects.name = "EyesEffects"
   BodyEffects.name = "BodyEffects"
   add_child(EyesEffects)
   add_child(BodyEffects)
   if EyeRemote: EyeRemote.remote_path = EyesEffects.get_path()

func equip_effect(spell_id: int, is_active: bool) -> void:
   if _get_effect_container(spell_id, is_active):
      return
   
   var eyes_container_node := Node3D.new()
   var body_container_node := Node3D.new()
   eyes_container_node.name = _get_effect_spell_name(spell_id, is_active)
   body_container_node.name = _get_effect_spell_name(spell_id, is_active)
   
   var spell_data: Dictionary = SpellData.get_active_spell_data(spell_id) if is_active else SpellData.get_passive_spell_data(spell_id)
   if not ((is_active and SpellData.is_valid_active_spell(spell_data)) or SpellData.is_valid_passive_spell(spell_data)): return
   var effect_list: Array = spell_data[SpellData.SpellFields.DummyEffects if IsDummy else SpellData.SpellFields.Effects]
   
   for effect in effect_list:
      var effect_node: Effect = load(effect).instantiate()
      if effect_node.FollowsEyes: eyes_container_node.add_child(effect_node)
      else: body_container_node.add_child(effect_node)
      if not IsDummy:
         effect_node.state_changed.connect(func(new_state: int): spell_state_changed.emit(spell_id, is_active, new_state))
         effect_node.ThePlayer = get_parent()
   
   if eyes_container_node.get_child_count(): EyesEffects.add_child(eyes_container_node)
   if body_container_node.get_child_count(): BodyEffects.add_child(body_container_node)
func erase_effect(spell_id: int, is_active: bool) -> void:
   var container: Node3D = _get_effect_container(spell_id, is_active)
   if container:
      if EyesEffects.is_ancestor_of(container): EyesEffects.remove_child(container)
      if BodyEffects.is_ancestor_of(container): BodyEffects.remove_child(container)
      container.queue_free()
func change_effect_state(spell_id: int, is_active: bool, spell_state: int) -> void:
   var effect_container: Node3D = _get_effect_container(spell_id, is_active)
   if not effect_container: return
   for child:Node3D in effect_container.get_children():
      if not child is Effect: continue
      child.on_state_changed(spell_state)

# ======= #
# utility #
# ======= #
func _get_effect_container(spell_id: int, is_active: bool) -> Node3D:
   var node_title: String = _get_effect_spell_name(spell_id, is_active)
   for child:Node3D in EyesEffects.get_children():
      if child.name == node_title:
         return child
   for child:Node3D in BodyEffects.get_children():
      if child.name == node_title:
         return child
   return null
func _get_effect_spell_name(spell_id: int, is_active: bool) -> String: 
   return SpellData.ActiveSpellIDs.find_key(spell_id) if is_active else SpellData.PassiveSpellIDs.find_key(spell_id)
