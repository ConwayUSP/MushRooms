----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.destructibles")
require("modules.constructors.buildings")
require("modules.constructors.interactives")
require("modules.constructors.enemies")
require("modules.constructors.npcs")
require("modules.constructors.player")
require("modules.constructors.obstacles")
require("modules.constructors.resources")
require("modules.utils.types")
require("modules.utils.entities")

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
	[TURTLE.name] = newTurtle,
}

CONSTRUCTORS[RESOURCE] = {
	[CASKIN.name] = newCaskin,
	[PEDACITO.name] = newPedacito,
	[PORRO.name] = newPorro,
	[WAW.name] = newWaw,
	[FAFOGO.name] = newFafogo,
	[PUFF.name] = newPuff,
	[COSECA.name] = newCoseca,
	[ARDURO.name] = newArduro,
	[COGUMELIUM.name] = newCogumelium,
	[MOLLE.name] = newMolle,
	[EWW.name] = newEww,
	[COBRITA.name] = newCobrita,
	[FALHO.name] = newFalho,
	[TUMBU.name] = newTumbu,
	[FUNPO.name] = newFunpo,
	[GRAAH.name] = newGraah,
	[JIFOFA.name] = newJifofa,
	[CHUBO.name] = newChubo,
	[BIFF.name] = newBiff,
	[YULI.name] = newYuli,
	[NHAM.name] = newNham,
	[PLOP.name] = newPlop,
	[BOUBA.name] = newBouba,
	[MELSH.name] = newMelsh,
	[CHONGO.name] = newChongo,
	[WAMOLI.name] = newWamoli,
	[ZUB.name] = newZub,
}

CONSTRUCTORS[PRODUCT] = {
	[CHEST.name] = newChest,
	[FIRECAMP.name] = newFirecamp,
}
