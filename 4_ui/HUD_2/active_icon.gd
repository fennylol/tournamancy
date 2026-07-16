extends Node2D

@onready var icon : Sprite2D = $Icon
@onready var cooldown_bar : TextureProgressBar = $Cooldown

func _process(delta: float) -> void:
   if Input.is_physical_key_pressed(KEY_R): _reset_cooldown()
   ## TODO: MAKE THE COOLDOWN VISUALIZER PULL COOLDOWN INFORMATION FROM THE PLAYER, RATHER THAN DOING THE CALCULATIONS ITSELF
   if cooldown_bar.value > 0.0: cooldown_bar.value -= delta

func _update_icon(id : int = -1):
   if id == -1 or not SpellData.ActiveSpells.has(id): 
      icon.texture = ImageTexture.new()
      cooldown_bar.max_value = 1.0
   else:
      icon.texture = load(SpellData.ActiveSpells.get(id).get(SpellData.SpellFields.IconPath))
      #cooldown_bar.max_value = SpellData.ActiveSpells.get(id).get(SpellData.SpellFields.Cooldown)

func _reset_cooldown():
   cooldown_bar.value = cooldown_bar.max_value
