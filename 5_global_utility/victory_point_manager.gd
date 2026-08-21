extends Resource
## An object that contains all victory point data for player and opponents
class_name VictoryPointManager

var LOCAL_PEER_ID : int = -1
## A list of all available PointConditions and the number of times the player has fulfilled them. Multiplied against MatchSettings.POINT_RULES to get a total Victory Point sum.
var PLAYER_CONDITION_TOTALS : Dictionary[PointConditions,int] = {
   PointConditions.self_KO_opponent : 0,
   PointConditions.opponent_KO_self : 0,
   PointConditions.self_KO_self     : 0,
   PointConditions.self_KO_ally     : 0,
   PointConditions.ally_KO_self     : 0
}
## A list of opponents (by peer_id) and a PointCondition total for each. An opponent's Victory Point total can be found by multiplying their condition totals with MatchSettings.POINT_RULES.
var OPPONENT_CONDITION_TOTALS : Dictionary[int,Dictionary] = {}

const ID_SIZE : int = 4
const VALUE_SIZE : int = 4

## A list of circumstances that might affect a player's point total.
enum PointConditions {
   ## Occurs when the player knocks out an opposing player.
   self_KO_opponent,
   ## Occurs when an opposing player knocks out the player
   opponent_KO_self,
   ## Occurs when the player knocks themselves out.
   self_KO_self,
   ## Occurs when the player knocks out a player on their own team.
   self_KO_ally,
   ## Occurs when the player is knocked out by a player on their own team.
   ally_KO_self}

# ======================= #
#  DICTIONARY MANAGEMENT  #
# ======================= #

## Gets local peer_id from tournamancy.gd
func set_personal_id(id : int) -> void:
   LOCAL_PEER_ID = id
## Checks if OPPONENT_CONDITION_TOTALS is currently tracking peer_id. Returns true if so, otherwise returns false.
func has_peer_id(peer_id : int) -> bool:
   return OPPONENT_CONDITION_TOTALS.has(peer_id)
##
func create_new_dict_entry() -> Dictionary[PointConditions,int]:
   var new_entry : Dictionary[PointConditions,int]
   for i : int in range(PointConditions.size()):
      new_entry.merge({i as PointConditions : 0})
   return new_entry
## Adds a new entry to OPPONENT_CONDITION_TOTALS to begin tracking PointConditions
func add_opponent_by_peer_id(peer_id : int) -> void:
   if OPPONENT_CONDITION_TOTALS.has(peer_id) or peer_id == LOCAL_PEER_ID:
      printerr("Cannot add peer_id ", peer_id, "to OPPONENT_CONDITION_TOTALS. peer_id already exists.")
   else:
      OPPONENT_CONDITION_TOTALS.merge({peer_id : create_new_dict_entry()})
## Removes the entry peer_id from OPPONENT_CONDITION_TOTALS. Returns true if entry was extant and removed. returns false if not.
func remove_opponent_by_peer_id(peer_id : int) -> bool:
   if OPPONENT_CONDITION_TOTALS.has(peer_id):
      return OPPONENT_CONDITION_TOTALS.erase(peer_id)
   else: return false
## Returns a full dictionary of all player and opponent peer_ids paired with PointCondition sums.
func get_full_dictionary() -> Dictionary:
   var full_dict : Dictionary = OPPONENT_CONDITION_TOTALS.duplicate_deep()
   full_dict.merge({ LOCAL_PEER_ID : PLAYER_CONDITION_TOTALS })
   return full_dict
## Takes a full dictionary and attempts to overwrite all current values with new values. If only_higher is true, this function will check to see if any new values are found to be lower than their current values, and will always favor higher values. This function will return false if any lower values were skipped, otherwise it will always return true.
func overwrite_dictionary(import_dictionary : Dictionary, only_higher : bool = true):
   var import_dictionary_self : Dictionary = import_dictionary.get(LOCAL_PEER_ID).duplicate_deep()
   import_dictionary.erase(LOCAL_PEER_ID)
   if only_higher:
      var successful : bool = true
      for i : int in range(PointConditions.size()):
         var condition = i as PointConditions
         var higher : int = maxi( PLAYER_CONDITION_TOTALS.get(condition) , import_dictionary_self.get(condition) )
         if higher != import_dictionary_self.get(condition): successful = false
         PLAYER_CONDITION_TOTALS.set(condition,higher)
         for peer_id in import_dictionary.keys():
            if not OPPONENT_CONDITION_TOTALS.has(peer_id): add_opponent_by_peer_id(peer_id)
            var id_higher : int = maxi( OPPONENT_CONDITION_TOTALS.get(peer_id).get(condition) , import_dictionary.get(peer_id).get(condition) )
            if id_higher != import_dictionary.get(peer_id).get(condition): successful = false
            OPPONENT_CONDITION_TOTALS.get(peer_id).set(condition,id_higher)
      return successful
   else:
      OPPONENT_CONDITION_TOTALS.clear()
      PLAYER_CONDITION_TOTALS.clear()
      OPPONENT_CONDITION_TOTALS.merge(import_dictionary)
      PLAYER_CONDITION_TOTALS.merge(import_dictionary_self)
      return true
## Overwrites a single peer's condition totals in OPPONENT_CONDITION_TOTALS. If only_higher is true, this function will check to see if any new values are found to be lower than their current values, and will always favor higher values. This function will return false if any lower values were skipped, otherwise it will always return true.
func import_single_peer_dict(peer_id : int, import_dictionary : Dictionary[PointConditions,int], only_higher : bool = true) -> bool:
   if peer_id == LOCAL_PEER_ID : return false
   if only_higher:
      if not OPPONENT_CONDITION_TOTALS.has(peer_id): add_opponent_by_peer_id(peer_id)
      var successful : bool = true
      for i : int in range(PointConditions.size()):
         var condition = i as PointConditions
         var higher : int = maxi( OPPONENT_CONDITION_TOTALS.get(peer_id).get(condition) , import_dictionary.get(condition) )
         if higher != import_dictionary.get(condition): successful = false
         OPPONENT_CONDITION_TOTALS.get(peer_id).set(condition,higher)
      return successful
   else:
      OPPONENT_CONDITION_TOTALS.erase(peer_id)
      OPPONENT_CONDITION_TOTALS.merge({peer_id:import_dictionary})
      return true

# ====================== #
#   CONDITION HANDLING   #
# ====================== #

## Finds the player or opponent by peer_id (-1 indicates the local player) and updates the PointCondition total for a given condition by delta. Returns true if the operation was successful. returns false if it was not.
func update_condition_total(condition : PointConditions, delta : int, peer_id : int = -1) -> bool:
   if peer_id == -1 or peer_id == LOCAL_PEER_ID: 
      return PLAYER_CONDITION_TOTALS.set(condition , ( PLAYER_CONDITION_TOTALS.get(condition) + delta ) )
   elif OPPONENT_CONDITION_TOTALS.has(peer_id):  
      return OPPONENT_CONDITION_TOTALS.get(peer_id).set(condition , ( OPPONENT_CONDITION_TOTALS.get(peer_id).get(condition) + delta ) )
   else:
      printerr("[get_point_condition] peer_id", peer_id, "not found in VictoryPointManager.OPPONENT_CONDITION_TOTALS")
      return false
## Finds an opponent by peer_id (find self with your own peer id or -1) and returns the total for a given PointCondition.
func get_condition_total(condition : PointConditions, peer_id : int = -1) -> int:
   if peer_id == -1 or peer_id == LOCAL_PEER_ID: return PLAYER_CONDITION_TOTALS.get(condition)
   elif OPPONENT_CONDITION_TOTALS.has(peer_id):  return OPPONENT_CONDITION_TOTALS.get(peer_id).get(condition)
   else:
      printerr("[get_point_condition] peer_id", peer_id, "not found in VictoryPointManager.OPPONENT_CONDITION_TOTALS")
      return 0
## Finds an opponent by peer_id (find self with your own peer id or -1) and returns their victory point total by multiplying each PointCondition total by the associated POINT_RULES in MatchSettings.
func get_point_total(peer_id : int = -1) -> int:
   var total : int = 0
   for i : int in range(PointConditions.size()):
      var condition = i as PointConditions
      if peer_id == -1 or peer_id == LOCAL_PEER_ID: total += SettingsManager.match_settings.POINT_RULES.get(condition) * PLAYER_CONDITION_TOTALS.get(condition)
      elif OPPONENT_CONDITION_TOTALS.has(peer_id):  total += SettingsManager.match_settings.POINT_RULES.get(condition) * OPPONENT_CONDITION_TOTALS.get(peer_id).get(condition)
      else:
         printerr("[get_point_total] peer_id", peer_id, "not found in VictoryPointManager.OPPONENT_CONDITION_TOTALS")
         return 0
   return total

# ================ #
#    NETWORKING    #
# ================ #

## Returns a PackedByteArray containing all current victory point data to be sent over the network. Can be unpacked using VictoryPointManager.PackedByteArray_to_peer_Dictionary().
func self_dictionary_to_PackedByteArray() -> PackedByteArray:
   var data: PackedByteArray = []
   data.resize( ID_SIZE + ( VALUE_SIZE * ( PointConditions.size() + 1 ) ) )
   data.encode_u32(0, LOCAL_PEER_ID)
   for i : int in range(PointConditions.size()):
      var offset : int = ID_SIZE + ( VALUE_SIZE * i )
      var total : int = PLAYER_CONDITION_TOTALS.get(i as PointConditions)
      data.encode_s32(offset,total)
   return data
## From a given PackedByteArray - packed using VictoryPointManager.self_dictionary_to_PackedByteArray() - constructs and returns a valid victory point dictionary containing the same data.
func PackedByteArray_to_peer_Dictionary(data : PackedByteArray) -> Dictionary:
   var import_peer_id : int = data.decode_u32(0)
   var import_peer_dict : Dictionary[PointConditions,int] = create_new_dict_entry()
   var dict_data = data.slice(ID_SIZE)
   for i : int in range(PointConditions.size()):
      import_peer_dict.set(i as PointConditions, dict_data.decode_s32(VALUE_SIZE * i))
   return {import_peer_id:import_peer_dict}

# =========== #
#    DEBUG    #
# =========== #

## Returns a dictionary entry as a string for print debug purposes
func get_dict_as_string(peer_id : int = -1) -> String:
   if peer_id == -1 or peer_id == LOCAL_PEER_ID:
      return str(PLAYER_CONDITION_TOTALS)
   elif OPPONENT_CONDITION_TOTALS.has(peer_id):
      return str(OPPONENT_CONDITION_TOTALS.get(peer_id))
   else:
      return ""
