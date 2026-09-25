----------------------------------------
-- Funções Auxiliares
----------------------------------------

---@param action string
---@return boolean
-- confere se é do tipo de ação que acontece só quando a tecla é inicialmente pressionada
local function isDiscreteAction(action)
	if
		action == ACT_ML
		or action == ACT_MR
		or action == ACT_MU
		or action == ACT_MD
		or action == ACT_ATK
		or action == ACT_DEF
	then
		return false
	end
	return true
end

----------------------------------------
-- Classe Controls
----------------------------------------

---@class Controls
---@field owner Player?
---@field keybinds table<string, string>
---@field inputBuffer InputBuffer
---@field hold table<string, number>
---@field blockAttackUntilRelease boolean

---@param config table
---@return Controls

Controls = {}
Controls.__index = Controls
Controls.type = CONTROLS

---@param keybinds table<string, string>
---@param owner? Player
---@return table
-- cria um novo controle, possivelmente associado a um jogador
function Controls.new(keybinds, owner)
	local controls = setmetatable({}, Controls)
	controls.owner = owner
	controls.keybinds = keybinds
	controls.blockAttackUntilRelease = false

	-- Atributos fixos na instanciação
	controls.inputBuffer = InputBuffer.new(owner)
	controls.keyStates = {}
	for action, _ in pairs(keybinds) do
		controls.keyStates[action] = {
			isDown = false,
			justPressed = false,
			justReleased = false,
			holdTime = 0,
		}
	end
	return controls
end

---@param dt number
function Controls:update(dt)
	for action, binding in pairs(self.keybinds) do
		local state = self.keyStates[action]
		local wasDown = state.isDown
		-- atualizando os estados de cada ação
		state.isDown = self:isDown(action)
		state.justPressed = state.isDown and not wasDown
		state.justReleased = not state.isDown and wasDown

		-- atualizando o tempo de hold
		if state.isDown then
			state.holdTime = state.holdTime + dt
		else
			state.holdTime = 0
		end
	end

	if self.blockAttackUntilRelease and not self.keyStates[ACT_ATK].isDown then
		self.blockAttackUntilRelease = false
	end
end

---@param action string
---@param isBuffered boolean
---@return boolean
function Controls:checkAction(action, isBuffered)
	local inputState = self.keyStates[action]
	-- o ataque é um caso especial pois envolve o input buffer
	if action ~= ACT_ATK then
		-- separando ações contínuas e discretas
		if isDiscreteAction(action) then
			return inputState.justPressed
		else
			return inputState.isDown
		end
	end

	if
		not inputState.isDown
		or self.blockAttackUntilRelease
		or self.owner.building
		or self.owner.uiManager:hasActiveScene()
		or self.owner.state == DEFENDING
		or self.owner.inDialogue
		or self.owner.state == DYING
		or not self.owner.weapon
	then
		return false
	end

	-- controlará se iremos bufferizar o input atual ou não
	local shouldBuffer = false

	if self.owner.weapon then
		if not isBuffered then
			shouldBuffer = not self.owner.weapon.atk.canAttack
		else
			if self.owner.weapon.atk.canAttack then
				self.inputBuffer:pop(self.keybinds[action])
				return true
			end
			return false
		end
	end

	if shouldBuffer then
		self.inputBuffer:buffer(self.keybinds[action])
		return false
	end
	return true
end

---@param action string
---@return boolean
function Controls:isDown(action)
	if action == ACT_CW then
		-- !TODO: implementar a rodinha do mouse
		return false
	end

	if self.keybinds[action]:sub(1, 5) == "mouse" then
		return love.mouse.isDown(tonumber(self.keybinds[action]:sub(6, 6)))
	else
		return love.keyboard.isDown(self.keybinds[action])
	end
end

---@param action string
---@return boolean
function Controls:justPressed(action)
	return self.keyStates[action].justPressed
end

---@param action string
---@return boolean
function Controls:justReleased(action)
	return self.keyStates[action].justReleased
end

----------------------------------------
-- Funções Globais
----------------------------------------

function newKeybind(ML, MR, MU, MD, ATK, DEF, UA, CW, CA, OUI, MAP, INT, CON, EXT, QA, PA)
	return {
		[ACT_ML] = ML,
		[ACT_MR] = MR,
		[ACT_MU] = MU,
		[ACT_MD] = MD,
		[ACT_ATK] = ATK,
		[ACT_DEF] = DEF,
		[ACT_UA] = UA,
		[ACT_CW] = CW,
		[ACT_CA] = CA,
		[ACT_OUI] = OUI,
		[ACT_MAP] = MAP,
		[ACT_INT] = INT,
		[ACT_CON] = CON,
		[ACT_EXT] = EXT,
		[ACT_QA] = QA,
		[ACT_PA] = PA,
	}
end

function _newDefaultControl()
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
		"space",
		"escape",
		"lshift",
		"escape"
	)
	return Controls.new(keybinds)
end
