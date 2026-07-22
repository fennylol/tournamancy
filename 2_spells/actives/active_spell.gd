extends Spell
class_name ActiveSpell

var Cooldown: float = 0.0:
   set(new_cd):
      Cooldown = new_cd
      TimeSinceActivation = new_cd
var TimeSinceActivation: float = 0.0
var Player_Self : Player

func _init(id: SpellData.ActiveSpellIDs = SpellData.ActiveSpellIDs.ERROR) -> void: super(id)

func _on_process_begin(delta: float) -> void: TimeSinceActivation += delta * ( 1 + ( Player_Self.SpellBook.get_stat(SpellData.StatTypes.COOLDOWN) * 0.01 ) )
func _can_activate(cooldown_reduction: float = 0.0) -> bool: return TimeSinceActivation > ( Cooldown + cooldown_reduction )
func _on_activate(_activator: Player) -> void: printerr("ERROR: _on_activate() not overridden but called.")

func identify_player(player_id : Player): Player_Self = player_id
func get_cooldown() -> float: return TimeSinceActivation
