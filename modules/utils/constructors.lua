----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.destructible")
require("modules.constructors.interactives")
require("modules.constructors.enemy")
require("modules.constructors.npc")
require("modules.constructors.player")
require("modules.constructors.obstacle")
require("modules.utils.types")

----------------------------------------
-- Mapa de construtores
----------------------------------------

---@type table<Type, table<string | number, (fun(pos?: Vec, args?: any): any)>>
-- Tabela de construtores indexada pelo tipo da entidade e então
-- pelo nome dela (exceto os players, indexados pelo id).
-- É útil para a lógica de spawn, pois só descobrimos o tipo
-- e o nome da entidade em tempo de execução
CONSTRUCTORS = {}

CONSTRUCTORS[PLAYER] = {
	initPlayer1,
	initPlayer2,
	initPlayer3,
	initPlayer4,
}

CONSTRUCTORS[ENEMY] = {
	[SPIDER_DUCK.name] = newSpiderDuck,
	[NUCLEAR_CAT.name] = newNuclearCat,
}

CONSTRUCTORS[NPC] = {
	[GLOB.name] = initGlob,
}

CONSTRUCTORS[DESTRUCTIBLE] = {
	[BARREL.name] = newBarrel,
	[JAR.name] = newJar,
}

CONSTRUCTORS[OBSTACLE] = {
	[PILLAR.name] = newPillar,
	[WALL.name] = newWall,
}

CONSTRUCTORS[INTERACTIVE] = {
	[DOOR.name] = newDoor,
}
