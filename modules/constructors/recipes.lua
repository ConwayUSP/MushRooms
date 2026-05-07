require("modules.systems.recipe")
require("modules.utils.entities")

FIRECAMP_RECIPE = Recipe.new({ craftInput(CASKIN, 10), craftInput(PEDACITO, 3) }, FIRECAMP)

CHEST_RECIPE = Recipe.new({ craftInput(CASKIN, 15), craftInput(PORRO, 3) }, CHEST)

ENGINEERING_TABLE_RECIPE =
	Recipe.new({ craftInput(CASKIN, 20), craftInput(PEDACITO, 10), craftInput(PORRO, 5) }, ENGINEERING_TABLE)

KITCHEN_RECIPE = Recipe.new({ craftInput(CASKIN, 10), craftInput(JIFOFA, 10) }, KITCHEN)

FURNACE_RECIPE = Recipe.new({ craftInput(PEDACITO, 20), craftInput(PORRO, 10) }, FURNACE)

DRILL_RECIPE = Recipe.new({ craftInput(PORRO, 5), craftInput(WAW, 5) }, DRILL)

TRAP_RECIPE = Recipe.new({ craftInput(TUNTUN, 10), craftInput(PUFF, 12) }, TRAP)

LADDER_RECIPE = Recipe.new({ craftInput(CASKIN, 30), craftInput(PEDACITO, 10) }, LADDER)

BLESSER_RECIPE = Recipe.new({ craftInput(WAW, 10), craftInput(JIFOFA, 10), craftInput(PUFF, 10) }, BLESSER)

FORGE_RECIPE = Recipe.new({ craftInput(PEDACITO, 5), craftInput(PORRO, 10), craftInput(WAW, 5) }, FORGE)
