extends PassiveSpell
class_name MoonJumpSpell

var airjumps_remaining : int = 0

func _init(stacks: int = 1) -> void: super(stacks, SpellData.PassiveSpellIDs.MoonJump)

func _get_stat_contributions() -> Dictionary: return {}

func _on_process_begin(_delta: float, player: Player) -> void:
   if player.is_on_floor():
      airjumps_remaining = Stacks + 1 #the first airjump triggers on a standard grounded jump
   else:
      if Input.is_action_just_pressed("jump") and airjumps_remaining > 0:
         airjumps_remaining -= 1
         player.velocity.y = player.get_influenced_stat(SpellData.StatTypes.JUMP)
func _on_process_end(_delta: float, _player: Player) -> void: pass
func _on_equip(_player: Player) -> void: pass
func _on_unequip(_player: Player) -> void: pass
