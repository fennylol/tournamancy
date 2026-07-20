extends Node2D

@onready var icon : Sprite2D = $Icon
@onready var cooldown_bar : TextureProgressBar = $Cooldown
var Player_Self : Player
var held : bool = false

func _ready() -> void:
   var check_for_player : Node = self
   while Player_Self == null:
      check_for_player = check_for_player.get_parent()
      if check_for_player is Player: Player_Self = check_for_player
   _update_icon()
   cooldown_bar.value = 0.0

func _process(delta: float) -> void:
   if cooldown_bar.value > 0.0 and not held:
      var multiplied_delta = delta * ( 1 + ( Player_Self.SpellBook.get_stat(SpellData.StatTypes.COOLDOWN) * 0.01 ) )
      cooldown_bar.value -= multiplied_delta

func _hold():
   if cooldown_bar.value > 0: return
   cooldown_bar.value = cooldown_bar.max_value
   held = true

func _release():
   held = false

func _reset():
   cooldown_bar.value = cooldown_bar.max_value

func _update_icon(id : int = -1):
   if id == -1 or not SpellData.ActiveSpells.has(id): 
      icon.texture = ImageTexture.new()
      cooldown_bar.max_value = 0.0
   else:
      icon.texture = load(SpellData.ActiveSpells.get(id).get(SpellData.SpellFields.IconPath))
      cooldown_bar.max_value = SpellData.ActiveSpells.get(id).get(SpellData.SpellFields.Cooldown)
