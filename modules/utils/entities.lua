require("modules.utils.types")

----------------------------------------
-- Registro das entidades do jogo
----------------------------------------

---@class EntityReg
---@field type Type
---@field name string
---@field description string?

---@param type Type
---@param name string
---@param description string?
---@return EntityReg
function registerEntity(type, name, description)
	return { type = type, name = name, description = description }
end

--------------- INIMIGOS ---------------
SPIDER_DUCK = registerEntity(ENEMY, "Spider Duck")
NUCLEAR_CAT = registerEntity(ENEMY, "Nuclear Cat")

----------------- NPCs -----------------
GLOB = registerEntity(NPC, "Glob")

---------------- ARMAS -----------------
KATANA = registerEntity(WEAPON, "Katana")
SLING_SHOT = registerEntity(WEAPON, "Sling Shot")
BOOMERANGUE = registerEntity(WEAPON, "Boomerangue")
SKULL_SHOOTER = registerEntity(WEAPON, "Skull Shooter")
BLACKHOLER = registerEntity(WEAPON, "Blackholer")
FLOWERGUN = registerEntity(WEAPON, "Flowergun")

--------------- ATAQUES ---------------
PEBBLE_SHOT = registerEntity(ATTACK, "Pebble Shot")
NUCLEAR_SHOT = registerEntity(ATTACK, "Nuclear Shot")
SKULL_SHOT = registerEntity(ATTACK, "Skull Shot")
BOOMERANGUE_SHOT = registerEntity(ATTACK, "Boomerangue Shot")
ROTATORY = registerEntity(ATTACK, "Rotatory Attack")
BLACKHOLE_SHOT = registerEntity(ATTACK, "Blackhole Shot")
SEED_SHOT = registerEntity(ATTACK, "Seed Shot")

-------------- ARTEFATOS ---------------
INVISIBILITY_RING = registerEntity(ARTIFACT, "Invisibility Ring")

------------- DESTRUTÍVEIS -------------
JAR = registerEntity(DESTRUCTIBLE, "jar")
BARREL = registerEntity(DESTRUCTIBLE, "barrel")

----------------- DROP -----------------
COIN = registerEntity(DROP, "coin")

-------------- RECURSOS ----------------
CASKIN = registerEntity(RESOURCE, "caskin")
PEDACITO = registerEntity(RESOURCE, "pedacito")
PORRO = registerEntity(RESOURCE, "porro")
WAW = registerEntity(RESOURCE, "waw")
FAFOGO = registerEntity(RESOURCE, "fafogo")
PUFF = registerEntity(RESOURCE, "puff")
COSECA = registerEntity(RESOURCE, "coseca")
ARDURO = registerEntity(RESOURCE, "arduro")
COGUMELIUM = registerEntity(RESOURCE, "cogumelium")
BLUB = registerEntity(RESOURCE, "blub")
MOLLE = registerEntity(RESOURCE, "molle")
EWW = registerEntity(RESOURCE, "eww")
COBRITA = registerEntity(RESOURCE, "cobrita")
-- daqui pra baixo são ingredientes
FALHO = registerEntity(RESOURCE, "falho")
TUMBU = registerEntity(RESOURCE, "tumbu")
FRONCHO = registerEntity(RESOURCE, "froncho")
FUNPO = registerEntity(RESOURCE, "funpo")
GRAAH = registerEntity(RESOURCE, "graah")
CABRA = registerEntity(RESOURCE, "cabra")
CHUBO = registerEntity(RESOURCE, "chubo")
JIFOFA = registerEntity(RESOURCE, "jifofa")
BIFF = registerEntity(RESOURCE, "biff")
YULI = registerEntity(RESOURCE, "yuli")
NHAM = registerEntity(RESOURCE, "nham")
PLOP = registerEntity(RESOURCE, "plop")
BOUBA = registerEntity(RESOURCE, "bouba")
MELSH = registerEntity(RESOURCE, "melsh")
CHONGO = registerEntity(RESOURCE, "chongo")
WAMOLI = registerEntity(RESOURCE, "wamoli")
ZUB = registerEntity(RESOURCE, "zub")

----------------- SALA -----------------

------------- OBSTÁCULO ----------------
PILLAR = registerEntity(OBSTACLE, "pillar")
WALL_UP = registerEntity(OBSTACLE, "wall up")
WALL_DOWN = registerEntity(OBSTACLE, "wall down")
WALL_LEFT_BACK = registerEntity(OBSTACLE, "wall left back")
WALL_LEFT_FRONT = registerEntity(OBSTACLE, "wall left front")
WALL_RIGHT_BACK = registerEntity(OBSTACLE, "wall right back")
WALL_RIGHT_FRONT = registerEntity(OBSTACLE, "wall right front")

------------------ BUILDINGS -----------------
FIRECAMP = registerEntity(BUILDING, "firecamp", "It can be simple and small, but it is warm and attracts good creatures")
CHEST = registerEntity(BUILDING, "chest", "It's bigger on the inside than it looks... and it's made with love")
ENGINEERING_TABLE = registerEntity(BUILDING, "engineering table")
KITCHEN = registerEntity(BUILDING, "kitchen")
FURNACE = registerEntity(BUILDING, "furnace")
DRILL = registerEntity(BUILDING, "drill")
TRAP = registerEntity(BUILDING, "trap")
LADDER = registerEntity(BUILDING, "ladder")
BLESSER = registerEntity(BUILDING, "blesser")
FORGE = registerEntity(BUILDING, "forge")

------------- INTERATIVO ---------------
DOOR_UP = registerEntity(INTERACTIVE, "door up")
DOOR_LEFT = registerEntity(INTERACTIVE, "door left")
DOOR_RIGHT = registerEntity(INTERACTIVE, "door right")
DOOR_DOWN = registerEntity(INTERACTIVE, "door down")
TURTLE = registerEntity(INTERACTIVE, "turtle")

------------ BLESSINGS ---------------
ARCHER_BLESSING = registerEntity(BLESSING, "archer blessing")
FIRE_BLESSING = registerEntity(BLESSING, "fire blessing")
