----------------------------------------
-- Enum dos tipos do jogo
----------------------------------------
---@alias Type string
PLAYER = "player"
ENEMY = "enemy"
NPC = "npc"
ROOM = "room"
WEAPON = "weapon"
RESOURCE = "resource"
ITEM = "item"
DESTRUCTIBLE = "destructible"
INTERACTIVE = "interactive"
COLOR = "color"
LOOT = "loot"
ATTACK = "attack"
MELEE_ATTACK = "melee attack"
RANGED_ATTACK = "ranged attack"
PLAYER_ATTACK = "player attack"
ENEMY_ATTACK = "enemy attack"
ATTACK_EVENT = "attack event"
BLUEPRINT = "blueprint"
SPAWNPOINT = "spawnpoint"
SPAWN_DATA = "spawn data"
COLLISION_MANAGER = "collision manager"
DIALOGUE = "dialogue"
INVENTORY = "inventory"
CRAFTING = "crafting"
RECIPE = "recipe"
BUILDING = "building"
DISH = "dish"
OBSTACLE = "obstacle"
UI_MANAGER = "UI manager"
UI_SCENE = "UI scene"
UI_ELEMENT = "UI element"
UI_IMAGE_ELEM = "UI image element"
UI_BUTTON_ELEM = "UI button element"
UI_MENU_SCENE = "UI menu scene"
UI_EQUIPMENT_SCENE = "UI player equipment scene"
UI_INVENTORY_SCENE = "UI player inventory scene"
UI_MAP_SCENE = "UI player map scene"
UI_BESTIARY_SCENE = "UI player bestiary scene"
UI_CRAFTING_SCENE = "UI player crafting scene"

----------------------------------------
-- Registro das entidades do jogo
----------------------------------------

---@class EntityReg
---@field type Type
---@field name string

---@param type Type
---@param name string
---@return EntityReg
function registerEntity(type, name)
	return { type = type, name = name }
end

--------------- INIMIGOS ---------------
SPIDER_DUCK = registerEntity(ENEMY, "Spider Duck")
NUCLEAR_CAT = registerEntity(ENEMY, "Nuclear Cat")

----------------- NPCs -----------------
GLOB = registerEntity(NPC, "Glob")

---------------- ARMAS -----------------
KATANA = registerEntity(WEAPON, "Katana")
SLING_SHOT = registerEntity(WEAPON, "Sling Shot")

------------- DESTRUTÍVEIS -------------
JAR = registerEntity(DESTRUCTIBLE, "jar")
BARREL = registerEntity(DESTRUCTIBLE, "barrel")

----------------- ITEM -----------------
COIN = registerEntity(ITEM, "coin")

-------------- RECURSOS ----------------
WOOD = registerEntity(RESOURCE, "wood")
STONE = registerEntity(RESOURCE, "stone")
BREAD = registerEntity(RESOURCE, "bread")
BONE = registerEntity(RESOURCE, "bone")
FEATHER = registerEntity(RESOURCE, "feather")
IRON = registerEntity(RESOURCE, "iron")
GOLD = registerEntity(RESOURCE, "gold")

----------------- SALA -----------------

------------- OBSTÁCULO ----------------
PILLAR = registerEntity(OBSTACLE, "pillar")

------------------ BUILDINGS -----------------
FIRECAMP = registerEntity(BUILDING, "firecamp")
CHEST = registerEntity(BUILDING, "chest")
ENGINEERING_TABLE = registerEntity(BUILDING, "engineering table")
KITCHEN_STATION = registerEntity(BUILDING, "kitchen station")
FURNACE = registerEntity(BUILDING, "furnace")
DRILL = registerEntity(BUILDING, "drill")
TRAP = registerEntity(BUILDING, "trap")
LADDER = registerEntity(BUILDING, "ladder")
BLESSER = registerEntity(BUILDING, "blesser")
FORGE = registerEntity(BUILDING, "forge")

------------------ DISHES -----------------
WALL = registerEntity(OBSTACLE, "wall")

------------- INTERATIVO ---------------
DOOR = registerEntity(INTERACTIVE, "door")
