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
DEMON_BALL = registerEntity(ENEMY, "Demon Ball")
ROLLING_STONE = registerEntity(ENEMY, "Rolling Stone")
SPIDER_DUCK_BOSS = registerEntity(ENEMY, "Spider Duck Boss")
ANCIENT_MOAI = registerEntity(ENEMY, "Ancient Moai")

----------------- NPCs -----------------
TENKAR = registerEntity(NPC, "Tenkar")
SHOUM_SHOUM = registerEntity(NPC, "Shoum Shoum")
BIGUIRI = registerEntity(NPC, "Biguiri")

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
ROTATORY_ATK = registerEntity(ATTACK, "Rotatory Attack")
BLACKHOLE_SHOT = registerEntity(ATTACK, "Blackhole Shot")
SEED_SHOT = registerEntity(ATTACK, "Seed Shot")
EMBER_MARK = registerEntity(ATTACK, "Ember Mark")
DEMON_JUMP = registerEntity(ATTACK, "Demon Jump")
ROLLING_RUSH = registerEntity(ATTACK, "Rolling Rush")
MOAI_RUSH = registerEntity(ATTACK, "Moai Rush")
HEAD_SLAM = registerEntity(ATTACK, "Head Slam")
TORNADO_SHOTS = registerEntity(ATTACK, "Tornado Shots")

-------------- ARTEFATOS ---------------
INVISIBILITY_RING = registerEntity(ARTIFACT, "Invisibility Ring", "Is it made of porro? I feel a strange energy. WAIT! WHY IS EVERYONE IGNORING ME?!")
RAINBOW_DASH = registerEntity(ARTIFACT, "Rainbow Dash", "SooOoOo CoLoRfUlL!!")

------------- DESTRUTÍVEIS -------------
BONE_PILE = registerEntity(DESTRUCTIBLE, "bone pile")
DESTRUCTIBLE_ROCK = registerEntity(DESTRUCTIBLE, "destructible rock")
COAL_ALTAR = registerEntity(DESTRUCTIBLE, "coal altar")
TALL_GRASS = registerEntity(DESTRUCTIBLE, "tall grass")

-------------- RECURSOS ----------------
CASKIN = registerEntity(RESOURCE, "caskin", "The hot thing on the wall likes to eat it. Brown, rough, and full of scratches. We tried to eat it too, but it was too dry. Next time we will try it with some sauce!!")
PEDACITO = registerEntity(RESOURCE, "pedacito", "A little piece of the ceiling that decided to leave home. What a stupid idea!")
FAFOGO = registerEntity(RESOURCE, "fafogo", "A dark and frail pedacito that creates heat. Unfortunately, it makes everything dirty.")
TUNTUN = registerEntity(RESOURCE, "tuntun", "There are piles and more piles of these out there - some are small, while others are even bigger than Shroom. It seems like they come from the creature’s insides… I wonder if I have one of those inside me too.")
COSECA = registerEntity(RESOURCE, "coseca")
PORRO = registerEntity(RESOURCE, "porro")
WAW = registerEntity(RESOURCE, "waw")
PUFF = registerEntity(RESOURCE, "puff")
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

------------- OBSTÁCULO ----------------
WALL_UP = registerEntity(OBSTACLE, "wall up")
WALL_DOWN = registerEntity(OBSTACLE, "wall down")
WALL_LEFT_BACK = registerEntity(OBSTACLE, "wall left back")
WALL_LEFT_FRONT = registerEntity(OBSTACLE, "wall left front")
WALL_RIGHT_BACK = registerEntity(OBSTACLE, "wall right back")
WALL_RIGHT_FRONT = registerEntity(OBSTACLE, "wall right front")
PILLAR = registerEntity(OBSTACLE, "pillar")
PILLAR_BASE = registerEntity(OBSTACLE, "pillar base")

------------- DECORAÇÕES ---------------
CANDLE = registerEntity(OBSTACLE, "candle")
TORCH = registerEntity(OBSTACLE, "torch")
PILLAR_PROP = registerEntity(OBSTACLE, "pillar prop")
CRACKS = registerEntity(OBSTACLE, "cracks")
FLOWERS = registerEntity(OBSTACLE, "flowers")
MOSS = registerEntity(OBSTACLE, "moss")
MOSS_SMALL = registerEntity(OBSTACLE, "moss small")
MOSS_BIG = registerEntity(OBSTACLE, "moss big")
MOSS_LEFT = registerEntity(OBSTACLE, "moss left")
MOSS_RIGHT = registerEntity(OBSTACLE, "moss right")
MOSS_UP = registerEntity(OBSTACLE, "moss up")
SKELETON = registerEntity(OBSTACLE, "skeleton")
NEGATIVE = registerEntity(OBSTACLE, "negative")
PAPER = registerEntity(OBSTACLE, "paper")
RUBBLE_SMALL = registerEntity(OBSTACLE, "rubble small")
RUBBLE_BIG = registerEntity(OBSTACLE, "rubble big")
TILES = registerEntity(OBSTACLE, "tiles")

------------- CONSTRUÇÕES --------------
FIRECAMP =
	registerEntity(BUILDING, "firecamp", "It can be simple and small, but it is warm and attracts good creatures")
CHEST = registerEntity(BUILDING, "chest", "It's bigger than it looks, but you REALLY don't want to get stuck on it. It smells.")
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
TREASURE_PILLAR = registerEntity(INTERACTIVE, "treasure pillar")

--------------- BÊNÇÃOS ----------------
ARCHER_BLESSING = registerEntity(BLESSING, "Archer Blessing")
FIRE_BLESSING = registerEntity(BLESSING, "Fire Blessing")
PIGMEU_BLESSING = registerEntity(BLESSING, "Pigmeu Blessing")
GOMUGOMU_BLESSING = registerEntity(BLESSING, "Gomu Gomu Blessing")
