Creating a Spell:
1. SpellData.gd:
   a. Add a New SpellID to ActiveSpellIDs or PassiveSpellIDs
   b. Add a new dictionary entry to ActiveSpells or PassiveSpells with your new SpellID as the key. the dictionary will contain:
      1. Name         : the in-game display name for the spell
      2. Description  : the in-game description of the spell
      3. IconPath     : a path to an image file that contains the icon
      4. IconRect     : a Rect2 containing the pixel coordinates for the origin, width, and height of the icon within the IconPath 
      5. ScriptPath   : a path to the Spell script (see below)
      6. Effects      : a list of Effects scenes (see below) to be used in first-person/the owning player
      7. DummyEffects : a list of Effects scenes (see below) to be used in third-person/other players' Dummies
      8. Familiars    : a list Familiar scrips (see below) that can be spawned by the spell. 

2a. The Spell Script (Passives)
   1. you must override: 
      a. _on_process_begin
      b. _on_process_end
      c. _on_equip
      d. _on_update
      e. _on_unequip
   2. you MAY override:
      f. state_changed
2b. The Spell Script (Actives)
   1. you must override: 
      a. _on_process_begin
         b. note if overridden, you should call super(delta) to correctly update the spell cooldown.
      b. _can_activate
      c. _on_activate
   2. you MAY override:
      a. state_changed

3. Effects
   a. These are ANY extra nodes a spell might need as support. Major ones include:
      1. Area3D
      2. AudioStreamPlayer3d
      3. ParticleEmitters
      4. etc
   b. Should be a scene (.tscn file) where each instance is identical
   c. Will get equipped when the Spell does

4. Familiars
   a. override these for sure:
      1. static func create_from_byte_array() -> Familiar
      2. func reduce_to_byte_array() -> PackedByteArray
         a. note this should ALWAYS queue_free() itself during this call.
   b. these are any spawned entities.
   c. oddly enough, these should be script that generates the relevant Node3D tree.
   d. spells will call Player.spawn_familiar
   


Creating a Class
1. ActiveSpells is an array of 2 (TWO) Active spells.
2. PassiveSpells is an dictionary of PassiveSpellID (key) and stack number (value)
