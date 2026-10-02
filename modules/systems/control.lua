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
---@field gamepad table?
---@field hold table<string, number>
---@field blockAttackUntilRelease boolean
---@field update fun(dt)
---@field checkAction fun(string, boolean) : boolean
---@field isDown fun(string) : boolean
---@field justPressed fun(string) : boolean
---@field justReleased fun(string) : boolean
---@field getStickAngle fun(string) : table<number, number, number> | nil
---@field setOwner fun(Player)
---@field newKeybinds function : table
---@field newDefaultControl fun() : Controls
---@field newJoystickControl fun(gamepad: table) : Controls

---@param config table
---@return Controls

Controls = {}
Controls.__index = Controls
Controls.type = CONTROLS

---@param keybinds table<string, string>
---@param gamepad? table
---@return table
-- cria um novo controle, possivelmente associado a um jogador
function Controls.new(keybinds, gamepad)
    local controls = setmetatable({}, Controls)
    controls.keybinds = keybinds
    controls.blockAttackUntilRelease = false

    -- atributos que variam
    controls.gamepad = gamepad
    -- atributos fixos na instanciação
    controls.keyStates = {}
    for action, _ in pairs(keybinds) do
        controls.keyStates[action] = {
            isDown = false,
            justPressed = false,
            justReleased = false,
            holdTime = 0,
            analogVal = 0,
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
        state.analogVal = 0
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
        or self.inDialogue
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
                self.inputBuffer:pop(action)
                return true
            end
            return false
        end
    end

    if shouldBuffer then
        self.inputBuffer:buffer(action)
        return false
    end
    return true
end

---@param action string
---@return boolean
function Controls:isDown(action)
    local act = self.keybinds[action]
    if not self.gamepad then -- se não é gamepad, é teclado/mouse
        -- !TODO: implementar a troca de arma com a rodinha do mouse

        if act:sub(1, 5) == "mouse" then
            return love.mouse.isDown(tonumber(act:sub(6, 6)) or 1)
        else
            return love.keyboard.isDown(act)
        end
    else
        local gp = self.gamepad
        local dz = 0.2 -- deadzone dos analógicos
        if act:sub(1, 7) == "trigger" then
            local axis = gp:getGamepadAxis(act)
            if axis > dz then
                self.keyStates[action].analogVal = axis
                return true
            end
            return false
        elseif act == "leftx" then
            local axis = gp:getGamepadAxis(act)
            if (axis > dz or axis < -dz) then
                if action == ACT_MR then
                    self.keyStates[action].analogVal = axis
                    return axis > 0
                elseif action == ACT_ML then
                    self.keyStates[action].analogVal = -axis
                    return axis < 0
                end
            end
            return false
        elseif act == "lefty" then
            local axis = gp:getGamepadAxis(act)
            if (axis > dz or axis < -dz) then
                if action == ACT_MD then
                    self.keyStates[action].analogVal = axis
                    return axis > 0
                elseif action == ACT_MU then
                    self.keyStates[action].analogVal = -axis
                    return axis < 0
                end
            end
            return false
        elseif act == "dpup dpdown" then
            local dpup = gp:isGamepadDown("dpup")
            local dpdown = gp:isGamepadDown("dpdown")
            return dpup or dpdown
        else
            return gp:isGamepadDown(act)
        end
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

---@param stick string
---@return number?, number?
-- nos dá o ângulo em radianos que o analógico aponta para termos movimento e mira precisos
function Controls:getStickDir(stick)
    if self.gamepad then
        local y = self.gamepad:getGamepadAxis(stick .. "y")
        local x = self.gamepad:getGamepadAxis(stick .. "x")
        if math.sqrt(x * x + y * y) >= 0.2 then
            return x, y
        end
    end

    return nil
end

---@param player Player
--
function Controls:setOwner(player)
    self.owner = player
    self.inputBuffer = InputBuffer.new(player)
end

----------------------------------------
-- Funções Globais
----------------------------------------

function newKeybind(ML, MR, MU, MD, ATK, DEF, UA, NW, PW, CA, OUI, MAP, INT, CON, EXT, QA, PS)
    return {
        [ACT_ML] = ML,
        [ACT_MR] = MR,
        [ACT_MU] = MU,
        [ACT_MD] = MD,
        [ACT_ATK] = ATK,
        [ACT_DEF] = DEF,
        [ACT_UA] = UA,
        [ACT_NW] = NW,
        [ACT_PW] = PW,
        [ACT_CA] = CA,
        [ACT_OUI] = OUI,
        [ACT_MAP] = MAP,
        [ACT_INT] = INT,
        [ACT_CON] = CON,
        [ACT_EXT] = EXT,
        [ACT_QA] = QA,
        [ACT_PS] = PS,
    }
end

function newDefaultControl()
    local keybinds = newKeybind(
        "left",
        "right",
        "up",
        "down",
        "mouse1",
        "mouse2",
        "q",
        "mousewheel",
        "mousewheel",
        "r",
        "e",
        "tab",
        "space",
        "space",
        "escape",
        "lshift",
        "escape"
    )
    return Controls.new(keybinds)
end

function newJoystickControl(gamepad)
    local keybinds = newKeybind(
        "leftx",
        "leftx",
        "lefty",
        "lefty",
        "triggerright",
        "triggerleft",
        "rightshoulder",
        "dpright",
        "dpleft",
        "dpup dpdown",
        "x",
        "leftshoulder",
        "a",
        "a",
        "b",
        "y",
        "start"
    )
    return Controls.new(keybinds, gamepad)
end
