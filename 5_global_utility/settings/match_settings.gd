extends Resource
class_name MatchSettings

# ==================== #
#    WIN CONDITIONS    #
# ==================== #

## A player wins the match when they have this many points.
var POINTS_TO_WIN : int = 10
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
## Determines how a player's points are affected by various game circumstances.
var POINT_RULES : Dictionary = {
   PointConditions.self_KO_opponent : 1,
   PointConditions.opponent_KO_self : 0,
   PointConditions.self_KO_self : -1
}

# ==================== #
#    ARENA CREATION    #
# ==================== #

## future

# =================== #
#    ARENA EFFECTS    #
# =================== #

## future

# ===================== #
#    PLAYER SPAWNING    #
# ===================== #

## A list of possible "sets of locations" which are considered valid spots for player spawning
enum PlayerSpawnLocationOptions {
   ## Any point in the arena is a valid spawn location
   any,
   ## A finite list of points are valid spawn locations
   list,
   ## all points within a few meters of the arena's edge are valid spawn locations
   edge}
## if PLAYER_SPAWN_LOCATION is set to "list," this determines the list of valid points.
var PLAYER_SPAWN_LOCATION_LIST : Array[Vector3] = []
## if PLAYER_SPAWN_LOCATION is set to "edge," this determines the distance (in meters) to the edge which is valid for spawning.
var PLAYER_SPAWN_LOCATION_EDGE : float = 1.0
## Determines where in the map is a valid spot for player spawning
var PLAYER_SPAWN_LOCATION : PlayerSpawnLocationOptions = PlayerSpawnLocationOptions.any
## A list of possible "methods of choosing" which valid spawn location will actually recieve the spawned player.
enum PlayerSpawnLocationChooser {
   ## The spawn location is chosen randomly from the valid points.
   random,
   ## The player is allowed to choose from the valid points.
   player_select,
   ## From the valid points, the point furthest from any other player is chosen.
   furthest,
   ## From the valid points, the point nearest the most number of "points of interest" (wellsprings, prisms, other players) is chosen.
   nearest}
## Determines which point from the list of valid spawn points will be chosen for player spawning
var PLAYER_SPAWN_CHOICE : PlayerSpawnLocationChooser = PlayerSpawnLocationChooser.furthest
## The default number of seconds a knocked-out player must remain in the class selection lobby before they are allowed to return to the match.
var MIN_RESPAWN_LOBBY_TIME : float = 10.0
## A list of circumstances which might affect how long a player must remain in the lobby
enum RespawnDeltaConditions {
   ## The number of times the player has been knocked out (by themselves, allies, or opponents)
   times_KOed
}
## The number of additional seconds a knocked out player must remain in the lobby for each defeat.
var RESPAWN_LOBBY_TIME_DELTA : Dictionary = {
   RespawnDeltaConditions.times_KOed : 0.0
}
## The amount of OVERHEALTH a returning player enters the match with.
var RETURNING_PLAYER_OVERHEALTH : float = 100.0

# ============ #
#    PRISMS    #
# ============ #

## The number of seconds in between new prisms spawning into the arena
var NEW_PRISM_COOLDOWN : float = 45.0
## A list of possible "sets of locations" which are considered valid spots for prism spawning
enum PrismSpawnLocationOptions {
   ## Any point in the arena is a valid spawn location
   any,
   ## A finite list of points are valid spawn locations
   list,
   ## all points within a few meters of the arena's edge are valid spawn locations
   edge}
## if PRISM_SPAWN_LOCATION is set to "list," this determines the list of valid points.
var PRISM_SPAWN_LOCATION_LIST : Array[Vector3] = []
## if PRISM_SPAWN_LOCATIONS is set to "edge," this determines the distance (in meters) to the edge which is valid for spawning.
var PRISM_SPAWN_LOCATION_EDGE : float = 5.0
## Determines where in the map is a valid spot for prism spawning
var PRISM_SPAWN_LOCATION : PrismSpawnLocationOptions = PrismSpawnLocationOptions.any
## A list of possible "methods of choosing" which valid spawn location will actually recieve the spawned prism.
enum PrismSpawnLocationChooser {
   ## The spawn location is chosen randomly from the valid points.
   random,
   ## From the valid points, the point furthest from all players is chosen.
   furthest,
   ## From the valid points, the point nearest the most number of "points of interest" (wellsprings, prisms, and players) is chosen.
   nearest}
## Determines which point from the list of valid spawn points will be chosen for prism spawning
var PRISM_SPAWN_CHOICE : PrismSpawnLocationChooser = PrismSpawnLocationChooser.random
## The number of seconds a naturally-spawned prism will last in the world before despawning
var NATURAL_PRISM_DESPAWN_COOLDOWN : float = 120.0
## The number of seconds a player-dropped prism will last in the world before despawning
var PLAYER_PRISM_DESPAWN_COOLDOWN : float = 120.0
## The number of players which can open a prism before it is destroyed
var PRISM_CRACK_COUNT : int = 1
## The minimum number of spells which can be withdrawn from a prism.[br][br]A minimum of -1 indicates that ALL spells must be withdrawn.
var MIN_SPELL_FROM_PRISM : int = 1
## The maximum number of spells which can be withdrawn from a prism.
var MAX_SPELL_FROM_PRISM : int = 1
## The number of spells an opened prism first reveals.
var DEFAULT_PRISM_SHOW_COUNT : int = 3
## The number of times a player can "reroll" a prism's spells
var PRISM_REROLL_COUNT : int = 2
## When a player "rerolls" a prism's spells, the number of spells shown is reduced by this amount.
var PRISM_REROLL_DECREMENT : int = 1
## The maximum number of spells a player can "lock," which will remain in place during a reroll.
var MAX_PRISM_REROLL_LOCK : int = 1
## If true, a prism will force active abilities to appear a set percentage of the time.
var PRISM_FORCE_ACTIVE_ABILITIES : bool = true
## If PRISM_FORCE_ACTIVE_ABILITIES is true, the percent chance of an active ability to be shown.
var PRISM_FORCE_ACTIVE_ABILITIES_PERCENT : float = 0.10
##
var SPELL_WEIGHTS : Dictionary = {}
##
var MERCY_WEIGHTS : Dictionary = {}
## The number of times a player must be knocked out before the mercy weights are applied.
var KOS_PER_MERCY_WEIGHT : int = 2
## The maximum number of times mercy weights can be applied.[br][br]Mercy weights are be applied a number of times equal to a player's number of kock-outs divided by KOS_PER_MERCY_WEIGHT, to a maximum of MAX_MERCY_WEIGHT_APPLICATION.[br][br]A value of -1 indicates that mercy weights can be applied infinitely.
var MAX_MERCY_WEIGHT_APPLICATION : int = -1

# ============= #
#    PLAYERS    #
# ============= #

## Determines the base statistics of all players (such as hearts and speed) without modifying passive loadouts.
var PLAYER_BASE_STATS : Dictionary = {
   SpellData.StatTypes.HEARTS         : 20.0,
   SpellData.StatTypes.ARMOR          :  0.0,
   SpellData.StatTypes.WARD           :  0.0,
   SpellData.StatTypes.OVERHEALTH     :  0.0,
   SpellData.StatTypes.ARMOR_STRENGTH :  0.0,
   SpellData.StatTypes.WARD_STRENGTH  :  0.0,
   SpellData.StatTypes.LIFESTEAL      :  0.0,
   SpellData.StatTypes.DAMAGE         :  1.0,
   SpellData.StatTypes.RANGE          :  1.0,
   SpellData.StatTypes.COOLDOWN       :  0.0,
   SpellData.StatTypes.FORCE          :  0.0,
   SpellData.StatTypes.CRIT           :  0.0,
   SpellData.StatTypes.LUCK           :  0.0,
   SpellData.StatTypes.SPEED          :  5.0,
   SpellData.StatTypes.SPRINT         : 10.0,
   SpellData.StatTypes.JUMP           :  4.5,
   SpellData.StatTypes.GRAVITY        :  9.8,
   SpellData.StatTypes.STEADFASTNESS  :  0.0,
   SpellData.StatTypes.MELEE_DAMAGE   :  2.0,
   SpellData.StatTypes.MELEE_RANGE    :  1.0,
   SpellData.StatTypes.MELEE_FORCE    :  0.0,
   SpellData.StatTypes.MELEE_COOLDOWN :  0.0
}
## Determines a default loadout of passives which are given to every player in addition to whichever class they select.
var PLAYER_BASE_LOADOUT : Dictionary = {}
## If true, the spell weights for prisms dropped by defeated players can be modified independently from spawned prisms.
var PLAYER_SPELL_WEIGHT_OVERRIDE : bool = false
## Determines the spell weights for prisms dropped by defeated players, only while PLAYER_SPELL_WEIGHT_OVERRIDE is true.
var PLAYER_SPELL_WEIGHT_OVERRIDES : Dictionary = {}

# ============== #
#    GAMEPLAY    #
# ============== #

## After all players have spawned in, the number of seconds that must pass before the match begins
var MATCH_START_COUNTDOWN : float = 5.0
## During MATCH_START_COUNTDOWN, can a player take damage.
var MATCH_START_VULNERABILITY : bool = false
## During MATCH_START_COUNTDOWN, can a player move their camera to look around.
var MATCH_START_CAMERA_MOVEMENT : bool = true
## During MATCH_START_COUNTDOWN, can a player move and jump.
var MATCH_START_MOVE_AND_JUMP : bool = false
## During MATCH_START_COUNTDOWN, can a player activate abilities.
var MATCH_START_ACTIVE_ABILITIES : bool = false
## A list of visibility options for various inventory objects.
enum InventoryViewOptions {
   ## The inventory object is visible to all players.
   all,
   ## The inventory object is visible to only the player who controls it.
   self_only,
   ## The inventory object is visible to the player who controls it and their allies.
   team,
   ## The inventory object is not visible to any players.
   none 
}
## Determines who can see a player's health.
var PLAYER_HEALTH_VISIBLE : InventoryViewOptions = InventoryViewOptions.all
## Determines who can see a player's statistics.
var PLAYER_STATS_VISIBLE : InventoryViewOptions = InventoryViewOptions.self_only
## Determines who can see a player's passive spells.
var PLAYER_PASSIVES_VISIBLE : InventoryViewOptions = InventoryViewOptions.self_only
## Determines who can see a player's active spells.
var PLAYER_ACTIVES_VISIBLE : InventoryViewOptions = InventoryViewOptions.self_only
## Determines the half-life of OVERHEALTH for all players
var OVERHEALTH_DECAY_RATE : float = 2.0
## List of options for what can happen to prisms under various conditions.
enum PrismRelocationOptions {
   ## The prism remains where it is.
   stationary,
   ## The prism is relocated to the nearest point inside the arena.
   to_arena,
   ## The prism is destroyed.
   destroy
}
## Determines what occurs to a prism that finds itself outside the bounds of the arena.
var PRISM_RELOCATION : PrismRelocationOptions = PrismRelocationOptions.destroy
##
