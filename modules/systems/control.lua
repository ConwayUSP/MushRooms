----------------------------------------
-- Classe Controls
----------------------------------------

---@class Controls
---@field owner Player
---@field keybinds table<string, string>
---@field inputBuffer InputBuffer
---@field hold table<string, number>

---@param config table
---@return Controls

Controls = {}
Controls.__index = Controls
Controls.type = CONTROLS

function Controls.new(owner, keybind)
	local controls = setmetatable({}, Controls)
	controls.owner = owner
    controls.keybinds = keybind

	-- Atributos fixos na instanciação
	controls.inputBuffer = InputBuffer.new(owner)
    controls.hold = {}
	return controls
end

function Controls:update(dt)
    self:updateHold(dt)
end

function Controls:checkAction(action, isBuffered)
	if action ~= ACT_ATK then 
		return self:isDown(action)
	end

    if self.owner.uiManager.activeScene or self.owner.state == DYING or self.owner.state == DEFENDING or not self:isDown(action) then
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

function Controls:updateHold(dt)
	if Controls:isDown(ACT_ATK) and not self.hold[self.keybinds[ACT_ATK]] then
		self.hold[self.keybinds[ACT_ATK]] = 0
	end 
	for button, time in pairs(self.hold) do
        if love.keyboard.isDown(button) then
            self.hold[button] = self.hold[button]+dt
        else
            self.hold[button] = nil
        end
    end
end

function Controls:isDown(action)
	if self.keybinds[action]:sub(1, 5) == "mouse" then
			return love.mouse.isDown(tonumber(self.keybinds[action]:sub(6, 6)))
		else	
			return love.keyboard.isDown(self.keybinds[action])
		
	end
end
			
function newKeybind(ML, MR, MU, MD, ATK, DEF, UA, CW, CA, OUI, MAP, INT, CON, EXT, QA, PA)
    return {[ACT_ML] = ML, [ACT_MR] = MR, [ACT_MU] = MU, [ACT_MD] = MD, [ACT_ATK] = ATK, [ACT_DEF] = DEF, [ACT_UA] = UA, [ACT_CW] = CW, [ACT_CA] = CA, [ACT_OUI] = OUI, [ACT_MAP] = MAP, [ACT_INT] = INT, [ACT_CON] = CON, [ACT_EXT] = EXT, [ACT_QA] = QA, [ACT_PA] = PA}
end

