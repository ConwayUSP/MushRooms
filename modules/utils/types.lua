----------------------------------------
-- Enum dos tipos do jogo
----------------------------------------
---@alias Type string

---------- ENTIDADES ----------
PLAYER = "player"
ENEMY = "enemy"
NPC = "npc"
WEAPON = "weapon"
DROP = "drop"
DESTRUCTIBLE = "destructible"
INTERACTIVE = "interactive"
OBSTACLE = "obstacle"

---------- ATAQUES ----------
ATTACK = "attack"
MELEE_ATTACK = "melee attack"
RANGED_ATTACK = "ranged attack"
PLAYER_ATTACK = "player attack"
ENEMY_ATTACK = "enemy attack"
ATTACK_EVENT = "attack event"

---------- SALAS ----------
ROOM = "room"
BLUEPRINT = "blueprint"
SPAWNPOINT = "spawnpoint"
SPAWN_DATA = "spawn data"

---------- SISTEMAS ----------
COLLISION_MANAGER = "collision manager"
DIALOGUE = "dialogue"
INVENTORY = "inventory"

---------- CRAFTING ----------
CRAFTING_MANAGER = "crafting manager"
RECIPE = "recipe"
RESOURCE = "resource"
MATERIAL = "material"
INGREDIENT = "ingredient"
PRODUCT = "product"
BUILDING = "building"
FOOD = "food"

---------- UI ----------
UI_MANAGER = "UI manager"
UI_SCENE = "UI scene"
UI_ELEMENT = "UI element"
UI_IMAGE_ELEM = "UI image element"
UI_BUTTON_ELEM = "UI button element"
UI_TEXT_ELEM = "UI text element"
UI_MENU_SCENE = "UI menu scene"
UI_EQUIPMENT_SCENE = "UI player equipment scene"
UI_INVENTORY_SCENE = "UI player inventory scene"
UI_MAP_SCENE = "UI player map scene"
UI_BESTIARY_SCENE = "UI player bestiary scene"
UI_CRAFTING_SCENE = "UI player crafting scene"

---------- OUTROS ----------
COLOR = "color"
LOOT = "loot"

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

------------- DESTRUTÍVEIS -------------
JAR = registerEntity(DESTRUCTIBLE, "jar")
BARREL = registerEntity(DESTRUCTIBLE, "barrel")

----------------- DROP -----------------
COIN = registerEntity(DROP, "coin")

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
WALL = registerEntity(OBSTACLE, "wall")

------------------ BUILDINGS -----------------
FIRECAMP =
	registerEntity(BUILDING, "firecamp", "It can be simple and small, but it is warm and attracts good creatures")
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
DOOR = registerEntity(INTERACTIVE, "door")
TURTLE = registerEntity(INTERACTIVE, "turtle")
