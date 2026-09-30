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
function initPlayer1(gamepad)
	local firstSpawnPoint = { x = rooms[0][0].pos.x, y = rooms[0][0].pos.y }
	local control = Controls.new(newKeybind(
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
	))
	player1 = Player.new(
		"Mush",
		firstSpawnPoint,
		control,
		getP1ColorPalette(),
		rooms[0][0]
	)
	control:setOwner(player1)
	player1:addAnimations(getPlayersAnimSettings())
	player1.room:onPlayerEnter(player1)
	table.insert(players, player1)
end

-- inicializa o jogador 2 - Shroom
function initPlayer2(gamepad)
	local control = newJoystickControl(gamepad)
	local player2 = Player.new(
		"Shroom",
		{ x = player1.pos.x + 40, y = player1.pos.y },
		control,
		getP2ColorPalette(),
		players[1].room
	)
	control:setOwner(player2)
	player2:addAnimations(getPlayersAnimSettings())
	player2.room:onPlayerEnter(player2)
	table.insert(players, player2)
end

-- inicializa o jogador 3 - Musho
function initPlayer3(gamepad)
	local control = newJoystickControl(gamepad)
	local player3 = Player.new(
		"Musho",
		{ x = player1.pos.x - 40, y = player1.pos.y },
		control,
		getP3ColorPalette(),
		players[1].room
	)
	control:setOwner(player3)
	player3:addAnimations(getPlayersAnimSettings())
	player3.room:onPlayerEnter(player3)
	table.insert(players, player3)
end

-- inicializa o jogador 4 - Roomy
function initPlayer4(gamepad)
	local control = newJoystickControl(gamepad)
	local player4 = Player.new(
		"Roomy",
		{ x = player1.pos.x, y = player1.pos.y + 40 },
		control,
		getP4ColorPalette(),
		players[1].room
	)
	control:setOwner(player4)
	player4:addAnimations(getPlayersAnimSettings())
	player4.room:onPlayerEnter(player4)
	table.insert(players, player4)
end
