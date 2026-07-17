extends Node2D

@onready var icon_grid : TileMapLayer = $TileMapLayer
var passive_list : Dictionary[int,int] = {}
   #SpellData.StatTypes.HEARTS         : 0,
   #SpellData.StatTypes.ARMOR          : 0,
   #SpellData.StatTypes.WARD           : 0,
   #SpellData.StatTypes.OVERHEALTH     : 0,
   #SpellData.StatTypes.ARMOR_STRENGTH : 0,
   #SpellData.StatTypes.WARD_STRENGTH  : 0,
   #SpellData.StatTypes.LIFESTEAL      : 0,
   #SpellData.StatTypes.DAMAGE         : 0,
   #SpellData.StatTypes.RANGE          : 0,
   #SpellData.StatTypes.COOLDOWN       : 0,
   #SpellData.StatTypes.FORCE          : 0,
   #SpellData.StatTypes.CRIT           : 0,
   #SpellData.StatTypes.LUCK           : 0,
   #SpellData.StatTypes.SPEED          : 0,
   #SpellData.StatTypes.SPRINT         : 0,
   #SpellData.StatTypes.JUMP           : 0,
   #SpellData.StatTypes.GRAVITY        : 0,
   #SpellData.StatTypes.STEADFASTNESS  : 0,
   #SpellData.StatTypes.MELEE_DAMAGE   : 0,
   #SpellData.StatTypes.MELEE_RANGE    : 0,
   #SpellData.StatTypes.MELEE_FORCE    : 0,
   #SpellData.StatTypes.MELEE_COOLDOWN : 0
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
      print("list[i] = ", list[i])
      print("Passive Spell 0 = ", SpellData.PassiveSpellIDs.get(0))
      if SpellData.PassiveSpells.has(list[i]):
         var new_entry = {list[i]:passive_list.get(list[i])+1} if passive_list.has(list[i]) else {list[i]:1}
         print("new entry: ", new_entry)
         passive_list.merge(new_entry,true)
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
   print(passive_list)
