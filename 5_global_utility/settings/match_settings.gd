extends Resource
class_name MatchSettings

## --------------------
##    WIN CONDITIONS
## --------------------

## A player wins the match when they have this many points.
const POINTS_TO_WIN : int = 10
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
const POINT_RULES : Dictionary = {
   PointConditions.self_KO_opponent : 1,
   PointConditions.opponent_KO_self : 0,
   PointConditions.self_KO_self : -1
}

## --------------------
##    ARENA CREATION
## --------------------

# future

## -------------------
##    ARENA EFFECTS
## -------------------

# future

## ---------------------
##    PLAYER SPAWNING
## ---------------------

## A list of possible "sets of locations" which are considered valid spots for player spawning
enum PlayerSpawnLocationOptions {
   ## Any point in the arena is a valid spawn location
   any,
   ## A finite list of points are valid spawn locations
   list,
   ## all points within a few meters of the arena's edge are valid spawn locations
   edge}
## if PLAYER_SPAWN_LOCATION is set to "list," this determines the list of valid points.
const PLAYER_SPAWN_LOCATION_LIST : Array[Vector3] = []
## if PLAYER_SPAWN_LOCATION is set to "edge," this determines the distance (in meters) to the edge which is valid for spawning.
const PLAYER_SPAWN_LOCATION_EDGE : float = 1.0
## Determines where in the map is a valid spot for player spawning
const PLAYER_SPAWN_LOCATION : PlayerSpawnLocationOptions = PlayerSpawnLocationOptions.any
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
const PLAYER_SPAWN_CHOICE : PlayerSpawnLocationChooser = PlayerSpawnLocationChooser.furthest
## The default number of seconds a knocked-out player must remain in the class selection lobby before they are allowed to return to the match.
const MIN_RESPAWN_LOBBY_TIME : float = 10.0
## A list of circumstances which might affect how long a player must remain in the lobby
enum RespawnDeltaConditions {
   ## The number of times the player has been knocked out (by themselves, allies, or opponents)
   times_KOed
}
## The number of additional seconds a knocked out player must remain in the lobby for each defeat.
const RESPAWN_LOBBY_TIME_DELTA : Dictionary = {
   RespawnDeltaConditions.times_KOed : 0.0
}
## The amount of OVERHEALTH a returning player enters the match with.
const RETURNING_PLAYER_OVERHEALTH : float = 100.0

## ------------
##    PRISMS
## ------------

## The number of seconds in between new prisms spawning into the arena
const NEW_PRISM_COOLDOWN : float = 45.0
## A list of possible "sets of locations" which are considered valid spots for prism spawning
enum PrismSpawnLocationOptions {
   ## Any point in the arena is a valid spawn location
   any,
   ## A finite list of points are valid spawn locations
   list,
   ## all points within a few meters of the arena's edge are valid spawn locations
   edge}
## if PRISM_SPAWN_LOCATION is set to "list," this determines the list of valid points.
const PRISM_SPAWN_LOCATION_LIST : Array[Vector3] = []
## if PRISM_SPAWN_LOCATIONS is set to "edge," this determines the distance (in meters) to the edge which is valid for spawning.
const PRISM_SPAWN_LOCATION_EDGE : float = 5.0
## Determines where in the map is a valid spot for prism spawning
const PRISM_SPAWN_LOCATION : PrismSpawnLocationOptions = PrismSpawnLocationOptions.any
## A list of possible "methods of choosing" which valid spawn location will actually recieve the spawned prism.
enum PrismSpawnLocationChooser {
   ## The spawn location is chosen randomly from the valid points.
   random,
   ## From the valid points, the point furthest from all players is chosen.
   furthest,
   ## From the valid points, the point nearest the most number of "points of interest" (wellsprings, prisms, and players) is chosen.
   nearest}
## Determines which point from the list of valid spawn points will be chosen for prism spawning
const PRISM_SPAWN_CHOICE : PrismSpawnLocationChooser = PrismSpawnLocationChooser.random
## The number of seconds a naturally-spawned prism will last in the world before despawning
const NATURAL_PRISM_DESPAWN_COOLDOWN : float = 120.0
## The number of seconds a player-dropped prism will last in the world before despawning
const PLAYER_PRISM_DESPAWN_COOLDOWN : float = 120.0
## The number of players which can open a prism before it is destroyed
const PRISM_CRACK_COUNT : int = 1
## The minimum number of spells which can be withdrawn from a prism.[br][br]A minimum of -1 indicates that ALL spells must be withdrawn.
const MIN_SPELL_FROM_PRISM : int = 1
## The maximum number of spells which can be withdrawn from a prism.
const MAX_SPELL_FROM_PRISM : int = 1
## The number of spells an opened prism first reveals.
const DEFAULT_PRISM_SHOW_COUNT : int = 3
## The number of times a player can "reroll" a prism's spells
const PRISM_REROLL_COUNT : int = 2
## When a player "rerolls" a prism's spells, the number of spells shown is reduced by this amount.
const PRISM_REROLL_DECREMENT : int = 1
## The maximum number of spells a player can "lock," which will remain in place during a reroll.
const MAX_PRISM_REROLL_LOCK : int = 1
## If true, a prism will force active abilities to appear a set percentage of the time.
const PRISM_FORCE_ACTIVE_ABILITIES : bool = true
## If PRISM_FORCE_ACTIVE_ABILITIES is true, the percent chance of an active ability to be shown.
const PRISM_FORCE_ACTIVE_ABILITIES_PERCENT : float = 0.10
##
const SPELL_WEIGHTS : Dictionary = {}
##
const MERCY_WEIGHTS : Dictionary = {}
## The number of times a player must be knocked out before the mercy weights are applied.
const KOS_PER_MERCY_WEIGHT : int = 2
## The maximum number of times mercy weights can be applied.[br][br]Mercy weights are be applied a number of times equal to a player's number of kock-outs divided by KOS_PER_MERCY_WEIGHT, to a maximum of MAX_MERCY_WEIGHT_APPLICATION.[br][br]A value of -1 indicates that mercy weights can be applied infinitely.
const MAX_MERCY_WEIGHT_APPLICATION : int = -1

## -------------
##    PLAYERS
## -------------

## Determines the base statistics of all players (such as hearts and speed) without modifying passive loadouts.
const PLAYER_BASE_STATS : Dictionary = {}
## Determines a default loadout of passives which are given to every player in addition to whichever class they select.
const PLAYER_BASE_LOADOUT : Dictionary = {}
## If true, the spell weights for prisms dropped by defeated players can be modified independently from spawned prisms.
const PLAYER_SPELL_WEIGHT_OVERRIDE : bool = false
## Determines the spell weights for prisms dropped by defeated players, only while PLAYER_SPELL_WEIGHT_OVERRIDE is true.
const PLAYER_SPELL_WEIGHT_OVERRIDES : Dictionary = {}

## --------------
##    GAMEPLAY
## --------------

## After all players have spawned in, the number of seconds that must pass before the match begins
const MATCH_START_COUNTDOWN : float = 5.0
## During MATCH_START_COUNTDOWN, can a player take damage.
const MATCH_START_VULNERABILITY : bool = false
## During MATCH_START_COUNTDOWN, can a player move their camera to look around.
const MATCH_START_CAMERA_MOVEMENT : bool = true
## During MATCH_START_COUNTDOWN, can a player move and jump.
const MATCH_START_MOVE_AND_JUMP : bool = false
## During MATCH_START_COUNTDOWN, can a player activate abilities.
const MATCH_START_ACTIVE_ABILITIES : bool = false
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
const PLAYER_HEALTH_VISIBLE : InventoryViewOptions = InventoryViewOptions.all
## Determines who can see a player's statistics.
const PLAYER_STATS_VISIBLE : InventoryViewOptions = InventoryViewOptions.self_only
## Determines who can see a player's passive spells.
const PLAYER_PASSIVES_VISIBLE : InventoryViewOptions = InventoryViewOptions.self_only
## Determines who can see a player's active spells.
const PLAYER_ACTIVES_VISIBLE : InventoryViewOptions = InventoryViewOptions.self_only
## Determines the half-life of OVERHEALTH for all players
const OVERHEALTH_DECAY_RATE : float = 2.0
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
const PRISM_RELOCATION : PrismRelocationOptions = PrismRelocationOptions.destroy
##
