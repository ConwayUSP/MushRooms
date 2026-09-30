require("modules.systems.control")

---@return AnimSettings, AnimSettings, AnimSettings, AnimSettings
-- retorna as configurações das animações de `Player`
function getPlayersAnimSettings()
	local quadSize = { width = 32, height = 32 }
	local idleAnimSettings = newAnimSetting(2, quadSize, 0.5, true, 1)
	local defAnimSettings = newAnimSetting(15, quadSize, 0.05, true, 12)
	local walkAnimSettings = newAnimSetting(4, quadSize, 0.18, true, 1)
	local dyingAnimSettings = newAnimSetting(2, quadSize, 0.1, false)
	return idleAnimSettings, defAnimSettings, walkAnimSettings, dyingAnimSettings
end

-- inicializa o jogador 1 - Mush
function initPlayer1()
	local firstSpawnPoint = { x = rooms[0][0].pos.x, y = rooms[0][0].pos.y }
	local keybinds = newKeybind(
		"a",
		"d",
		"w",
		"s",
		"mouse1",
		"mouse2",
		"q",
		"mousewheel",
		"r",
		"i",
		"tab",
		"e",
		"mouse1",
		"escape",
		"lshift",
		"escape"
	)
	player1 = Player.new("Mush", firstSpawnPoint, keybinds, getP1ColorPalette(), rooms[0][0])
	player1:addAnimations(getPlayersAnimSettings())
	player1.room:onPlayerEnter(player1)
	table.insert(players, player1)
end

-- inicializa o jogador 2 - Shroom
function initPlayer2()
	-- !TODO: colocar keybinds diferentes das do player 1
	local keybinds = newKeybind(
		"left",
		"right",
		"up",
		"down",
		"mouse1",
		"mouse2",
		"q",
		"mousewheel",
		"r",
		"i",
		"tab",
		"e",
		"mouse1",
		"escape",
		"lshift",
		"escape"
	)
	local player2 = Player.new(
		"Shroom",
		{ x = player1.pos.x + 75, y = player1.pos.y },
		keybinds,
		getP2ColorPalette(),
		players[1].room
	)
	player2:addAnimations(getPlayersAnimSettings())
	player2.room:onPlayerEnter(player2)
	table.insert(players, player2)
end

-- inicializa o jogador 3 - Musho
function initPlayer3()
	-- !TODO: colocar keybinds diferentes das do player 1
	local keybinds = newKeybind(
		"a",
		"d",
		"w",
		"s",
		"mouse1",
		"mouse2",
		"q",
		"mousewheel",
		"r",
		"i",
		"tab",
		"e",
		"mouse1",
		"escape",
		"lshift",
		"escape"
	)
	local player3 = Player.new(
		"Musho",
		{ x = player1.pos.x + 75, y = player1.pos.y },
		keybinds,
		getP3ColorPalette(),
		players[1].room
	)
	player3:addAnimations(getPlayersAnimSettings())
	player3.room:onPlayerEnter(player3)
	table.insert(players, player3)
end

-- inicializa o jogador 4 - Roomy
function initPlayer4()
	-- !TODO: colocar keybinds diferentes das do player 1
	local keybinds = newKeybind(
		"a",
		"d",
		"w",
		"s",
		"mouse1",
		"mouse2",
		"q",
		"mousewheel",
		"r",
		"i",
		"tab",
		"e",
		"mouse1",
		"escape",
		"lshift",
		"escape"
	)
	local player4 = Player.new(
		"Roomy",
		{ x = player1.pos.x + 75, y = player1.pos.y },
		keybinds,
		getP4ColorPalette(),
		players[1].room
	)
	player4:addAnimations(getPlayersAnimSettings())
	player4.room:onPlayerEnter(player4)
	table.insert(players, player4)
end
