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
ARTIFACT = "artifact"

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
