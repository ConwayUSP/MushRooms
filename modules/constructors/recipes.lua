require("modules.systems.recipe")

FIRECAMP_RECIPE = Recipe.new({ craftInput(WOOD, 10), craftInput(STONE, 3) }, FIRECAMP)

CHEST_RECIPE = Recipe.new({ craftInput(WOOD, 15), craftInput(IRON, 3) }, CHEST)

ENGINEERING_TABLE_RECIPE =
	Recipe.new({ craftInput(WOOD, 20), craftInput(STONE, 10), craftInput(IRON, 5) }, ENGINEERING_TABLE)

KITCHEN_RECIPE = Recipe.new({ craftInput(WOOD, 10), craftInput(BREAD, 10) }, KITCHEN)

FURNACE_RECIPE = Recipe.new({ craftInput(STONE, 20), craftInput(IRON, 10) }, FURNACE)

DRILL_RECIPE = Recipe.new({ craftInput(IRON, 5), craftInput(GOLD, 5) }, DRILL)

TRAP_RECIPE = Recipe.new({ craftInput(BONE, 10), craftInput(FEATHER, 12) }, TRAP)

LADDER_RECIPE = Recipe.new({ craftInput(WOOD, 30), craftInput(STONE, 10) }, LADDER)

BLESSER_RECIPE = Recipe.new({ craftInput(GOLD, 10), craftInput(BREAD, 10), craftInput(FEATHER, 10) }, BLESSER)

FORGE_RECIPE = Recipe.new({ craftInput(STONE, 5), craftInput(IRON, 10), craftInput(GOLD, 5) }, FORGE)
