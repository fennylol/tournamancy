extends Node2D

@onready var icon : Sprite2D = $Icon
@onready var cooldown_bar : TextureProgressBar = $Cooldown
var held : bool = false

func _ready() -> void: 
   _update_icon()
   cooldown_bar.value = 0.0

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

func update_cooldown(time_since_activation : float): cooldown_bar.value = clamp(cooldown_bar.max_value - time_since_activation , 0.0 , cooldown_bar.max_value)
