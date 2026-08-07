extends Spell
class_name ActiveSpell

var Cooldown: float = 0.0:
   set(new_cd):
      Cooldown = new_cd
      TimeSinceActivation = new_cd
var TimeSinceActivation: float = 0.0
var Player_Self : Player

func _init(id: SpellData.ActiveSpellIDs = SpellData.ActiveSpellIDs.ERROR) -> void:
   super(id)
   Cooldown = SpellData.ActiveSpells.get(SpellID).get(SpellData.SpellFields.Cooldown)

func _on_process_begin(delta: float) -> void: TimeSinceActivation += delta * Player_Self.get_cooldown()
func _can_activate(cooldown_reduction: float = 0.0) -> bool: return TimeSinceActivation > ( Cooldown + cooldown_reduction )
func _on_activate(_activator: Player) -> void: printerr("ERROR: _on_activate() not overridden but called.")

func identify_player(player_id : Player): Player_Self = player_id
func get_cooldown() -> float: return TimeSinceActivation
