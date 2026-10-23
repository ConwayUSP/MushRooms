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
TREASURE_ROOM = "treasure room"
INITIAL_ROOM = "initial room"

---@alias RoomType
---| `PUZZLE_ROOM`
---| `NPC_ROOM`
---| `RESOURCE_ROOM`
---| `BATTLE_ROOM`
---| `BOSS_ROOM`
---| `EVENT_ROOM`
---| `TREASURE_ROOM`
---| `INITIAL_ROOM`

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
CONTROLS = "controls"

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
UI_WORLD_SCENE = "UI world scene"
UI_ELEMENT = "UI element"
UI_IMAGE_ELEM = "UI image element"
UI_BUTTON_ELEM = "UI button element"
UI_TEXTBOX_ELEM = "UI textbox element"
UI_TEXT_ELEM = "UI text element"
UI_INTRO_AMANITA_SCENE = "UI intro Amanita scene"
UI_INTRO_CONWAY_SCENE = "UI intro Conway scene"
UI_CREDITS_SCENE = "UI credits scene"
UI_MENU_SCENE = "UI menu scene"
UI_SETTINGS_SCENE = "UI settings scene"
UI_CONTROLS_SCENE = "UI controls scene"
UI_GRAPHICS_SCENE = "UI graphics settings scene"
UI_EQUIPMENT_SCENE = "UI player equipment scene"
UI_INVENTORY_SCENE = "UI player inventory scene"
UI_MAP_SCENE = "UI player map scene"
UI_BESTIARY_SCENE = "UI player bestiary scene"
UI_CRAFTING_SCENE = "UI player crafting scene"
UI_CHEST_SCENE = "UI chest scene"
UI_BOSS_LIFE_BAR_SCENE = "UI boss life bar scene"
UI_PLAYER_HP_SCENE = "UI player hp scene"
UI_ARTIFACT_EQUIP_SCENE = "UI artifact equip scene"
UI_INTERACTION_PROMPT_SCENE = "UI interaction prompt scene"
UI_ARTIFACT_COOLDOWN_BAR_SCENE = "UI artifact cooldown bar scene"
UI_DEFENSE_COOLDOWN_BAR_SCENE = "UI defense cooldown bar scene"
UI_PAUSE_SCENE = "UI pause scene"
UI_PAUSE_SETTINGS_SCENE = "UI pause settings scene"
UI_LINK_ELEM = "UI link element"

---------- ÁUDIOS ----------
-- o tipo da música é o próprio nome do arquivo em assets/audios/global
-- (o caminho é montado com pathlizeName, então "music std" -> music_std.ogg)
MUSIC_MENU = "music menu"
MUSIC_STD = "music std"
MUSIC_BATTLE = "music battle rooms"
MUSIC_PUZZLE = "music puzzle rooms"
AUDIO_MOVEMENT = "movement audio"
AUDIO_GET_HIT = "get hit audio"
AUDIO_ATTACK = "atk audio"
AUDIO_COLLIDE = "collision audio"
AUDIO_DEFENSE = "defense audio"
AUDIO_DEATH = "death audio"
AUDIO_BREAK = "break audio"
AUDIO_SPEAK = "speak audio"
AUDIO_SELECT = "select audio"
AUDIO_PRESS = "press audio"
AUDIO_SPAWN = "spawn audio"
AUDIO_COLLECT = "collect audio"
AUDIO_OPEN = "open audio"
AUDIO_CLOSE = "close audio"

---------- PARTICLES ----------
PARTICLE_WALKING = "walking particle"
PARTICLE_TREASURE_DISAPPEAR = "treasure disappear particle"
PARTICLE_MOAI_BOSS_STARTING = "moai boss starting particle"
PARTICLE_DEFENSE = "defense particle"
PARTICLE_HIT = "hit particle"
PARTICLE_BREAKING = "breaking particle"
PARTICLE_SEED = "seed particle"
PARTICLE_KATANA = "katana particle"
PARTICLE_EXPLOSION = "explosion particle"
PARTICLE_BLACK_HOLE = "black hole particle"
PARTICLE_FLOWER_SHOT = "flower shot particle"
PARTICLE_PUZZLE_STONE_MOVING = "puzzle stone moving particle"

---------- ACTIONS ----------
ACT_ML = "action move left"
ACT_MR = "action move right"
ACT_MD = "action move down"
ACT_MU = "action move up"
ACT_ATK = "action attack"
ACT_DEF = "action defend"
ACT_UA = "action use artifact"
ACT_NW = "action next weapon"
ACT_PW = "action previous weapon"
ACT_CA = "action change artifact"
ACT_OUI = "action open UI"
ACT_MAP = "action open map"
ACT_INT = "action interact"
ACT_CON = "action confirm"
ACT_EXT = "action exit"
ACT_QA = "action quick action"
ACT_PS = "action pause"

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
