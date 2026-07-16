extends Node2D

@onready var icon_grid : TileMapLayer = $TileMapLayer
var new_icon_offset : Vector2i = Vector2i.ZERO

func _process(delta: float) -> void:
   if Input.is_physical_key_pressed(KEY_P): _add_icon(0)

func _add_icon(id : int):
   if SpellData.ActiveSpells.has(id): 
      icon_grid.set_cell(new_icon_offset,0,Vector2i(0,id))
      new_icon_offset += Vector2i(1,0)
      if new_icon_offset.x > 18: new_icon_offset = Vector2i(0,new_icon_offset.y+1)
