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

----------- SALAS -----------
PUZZLE_ROOM = "puzzle room"
NPC_ROOM = "npc room"
RESOURCE_ROOM = "resource room"
BATTLE_ROOM = "battle room"
BOSS_ROOM = "boss room"
EVENT_ROOM = "event room"

---@alias RoomType
---| `PUZZLE_ROOM`
---| `NPC_ROOM`
---| `RESOURCE_ROOM`
---| `BATTLE_ROOM`
---| `BOSS_ROOM`
---| `EVENT_ROOM`

---------- ATAQUES ----------
ATTACK = "attack"
MELEE_ATTACK = "melee attack"
RANGED_ATTACK = "ranged attack"
SPAWN_ATTACK = "spawn attack"
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
AUDIO_MANAGER = "audio manager"
VFX_MANAGER = "vfx manager"
DIALOGUE = "dialogue"
INVENTORY = "inventory"
TARGET_MANAGER = "target manager"
TARGET = "target"

---------- CONSTRUÇÃO ----------
CRAFTING_MANAGER = "crafting manager"
RECIPE = "recipe"
RESOURCE = "resource"
MATERIAL = "material"
INGREDIENT = "ingredient"
PRODUCT = "product"
BUILDING = "building"
FOOD = "food"

--------- BENÇÃOS ----------
BLESSING_MANAGER = "blessing manager"
BLESSING = "blessing"
COMBAT = "combat"
UTILITY = "utility"
ELEMENTAL = "elemental"

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
UI_CHEST_SCENE = "UI chest scene"
UI_BOSS_LIFE_BAR_SCENE = "UI boss life bar scene"

---------- ÁUDIOS ----------
MUSIC_MENU = "menu music"
MUSIC_LAYER1 = "layer 1 music"
MUSIC_LAYER2 = "layer 2 music"
MUSIC_LAYER3 = "layer 3 music"
AUDIO_MOVEMENT = "movement audio"
AUDIO_GET_HIT = "get hit audio"
AUDIO_ATTACK = "atk audio"
AUDIO_COLLIDE = "collision audio"

---------- PARTICLES ----------
PARTICLE_WALKING = "walking particle"
PARTICLE_HIT = "hit particle"
PARTICLE_BREAKING = "breaking particle"
PARTICLE_SEED = "seed particle"
PARTICLE_KATANA = "katana particle"
PARTICLE_DEFENSE = "defense particle"
PARTICLE_EXPLOSION = "explosion particle"

---------- OUTROS ----------
COLOR = "color"
LOOT = "loot"

--------------------------------
--- Blessing Trigger Points
--------------------------------

---@alias TriggerPoint string

TP_ON_EQUIP = "onEquip"
TP_ON_UNEQUIP = "onUnequip"
TP_ON_ATTACK_ENEMY = "onAttackEnemy"
TP_ON_ATTACK_PLAYER = "onAttackPlayer"

TRIGGER_POINTS = {
	TP_ON_EQUIP,
	TP_ON_UNEQUIP,
	TP_ON_ATTACK_ENEMY,
	TP_ON_ATTACK_PLAYER,
}

-------------------------------
--- Blessing Stats
-------------------------------

---@alias BlessingStat string
BS_CANCEL = "cancel"
BS_CONTINUE = "continue"
BS_REFLECT = "reflect"
