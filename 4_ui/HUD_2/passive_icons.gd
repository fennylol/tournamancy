extends Node2D

@onready var icon_grid : TileMapLayer = $TileMapLayer
@onready var icon_stack  : Node2D = $IconStack
@onready var number_node : Node2D = $Numbers
var passive_list : Dictionary[int,int] = {}
var offset_size : int = 32
var timer = 1.0

func _process(delta: float) -> void:
   ## DEMO RECIEVING NEW PASSIVE SPELLS
   timer -= delta
   if Input.is_physical_key_pressed(KEY_P) and timer < 0: 
      _import_passive_spells([0])
      timer = 0.05
   if Input.is_physical_key_pressed(KEY_O) and timer < 0: 
      _import_passive_spells([7])
      timer = 0.05
   if Input.is_physical_key_pressed(KEY_I) and timer < 0: 
      _import_passive_spells([13])
      timer = 0.05

func _import_passive_spells(list : Array[int], full_clear : bool = false):
   if full_clear: passive_list.clear()
   ## IMPORT PASSIVES BASED ON SPELL_ID
   ## KEEP TRACK OF HOW MANY OF EACH ARE EXTANT
   for i in range(list.size()):
      if SpellData.PassiveSpells.has(list[i]):
         var new_entry = {list[i]:passive_list.get(list[i])+1} if passive_list.has(list[i]) else {list[i]:1}
         passive_list.merge(new_entry,true)
   #clear_and_set_as_tilemaplayer()
   clear_and_set_as_nodes()

func clear_and_set_as_nodes():
   ## CLEAR PREVIOUS ICONS AND NUMBERS
   for child in icon_stack.get_children(): child.queue_free()
   for child in number_node.get_children(): child.queue_free()
   var icon_offset : Vector2i = Vector2i(64,32)
   for i in range(passive_list.keys().size()):
      ## CREATE NEW ICON
      var new_icon = Sprite2D.new()
      var new_texture = AtlasTexture.new()
      new_texture.atlas = load(SpellData.PassiveSpells.get(passive_list.keys()[i]).get(SpellData.SpellFields.IconPath))
      new_texture.region = SpellData.PassiveSpells.get(passive_list.keys()[i]).get(SpellData.SpellFields.IconRect)
      new_icon.texture = new_texture
      icon_stack.add_child(new_icon)
      ## SET ICON LOCATION
      new_icon.position = Vector2(icon_offset.x * i,floor(i/9))
      ## CREATE NUMBER
      var new_number = Label.new()
      new_number.text = "x" + str(passive_list.get(passive_list.keys()[i]))
      new_number.size = Vector2(32,32)
      new_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
      new_number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
      number_node.add_child(new_number)
      ## PLACE NUMBER
      new_number.position = Vector2((icon_offset.x * i)+16,(floor(i/9))-16)

## DEPRECIATED
## BUT PERHAPS STILL USEFUL FOR SHOWING MERGED SPELLS IN PRISMS
func clear_and_set_as_tilemaplayer():
   ## CLEAR ICON GRID AND SET CELLS
   icon_grid.clear()
   var icon_offset : Vector2i = Vector2i.ZERO
   for i in passive_list.keys():
      ## CALCULATE HOW MANY OF EACH "SIZE" IS NEEDED
      var accounted_for = 0
      var icon_amounts = [0,0,0,0,0,0,0]
      while accounted_for < passive_list.get(i):
         if passive_list.get(i)-accounted_for >= 1000: 
            icon_amounts[0] += 1
            accounted_for += 1000
         elif passive_list.get(i)-accounted_for >= 500: 
            icon_amounts[1] += 1
            accounted_for += 500
         elif passive_list.get(i)-accounted_for >= 100:
            icon_amounts[2] += 1
            accounted_for += 100
         elif passive_list.get(i)-accounted_for >= 50:
            icon_amounts[3] += 1
            accounted_for += 50
         elif passive_list.get(i)-accounted_for >= 10:
            icon_amounts[4] += 1
            accounted_for += 10
         elif passive_list.get(i)-accounted_for >= 5:
            icon_amounts[5] += 1
            accounted_for += 5
         elif passive_list.get(i)-accounted_for >= 1:
            icon_amounts[6] += 1
            accounted_for += 1
      ## PLACE ICONS IN GRID
      for j in range(icon_amounts.size()):
         while icon_amounts[j] > 0:
            icon_grid.set_cell(icon_offset,0,Vector2i(7-j,i))
            icon_amounts[j] -= 1
            icon_offset += Vector2i(1,0)
            if icon_offset.x > 18: icon_offset = Vector2i(0,icon_offset.y+1)
