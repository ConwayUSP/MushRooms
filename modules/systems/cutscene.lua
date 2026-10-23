----------------------------------------
-- Cutscenes
----------------------------------------

---@class CutscenePlayerState
---@field player Player
---@field camera Camera?
---@field inCutscene boolean
---@field target Player|Npc|Enemy|nil
---@field targetZoom number?

---@class Cutscene
---@field focus Player|Npc|Enemy
---@field players CutscenePlayerState[]
---@field zoom number
---@field onFinish function?
---@field active boolean
Cutscene = {}
Cutscene.__index = Cutscene

---@param focus Player|Npc|Enemy
---@param players Set
---@param zoom number
---@param onFinish? function
---@return Cutscene
function Cutscene.new(focus, players, zoom, onFinish)
	local cutscene = setmetatable({}, Cutscene)
	cutscene.focus = focus
	cutscene.players = {}
	cutscene.zoom = zoom
	cutscene.onFinish = onFinish
	cutscene.active = false

	for _, player in players:iter() do
		local camera = getCameraByPlayer(player)
		table.insert(cutscene.players, {
			player = player,
			camera = camera,
			inCutscene = player.inCutscene,
			target = camera and camera.target or nil,
			targetZoom = camera and camera.targetZoom or nil,
		})
	end

	return cutscene
end

-- bloqueia os participantes e direciona suas câmeras ao foco da cena.
function Cutscene:start()
	if self.active then
		return
	end

	self.active = true
	for _, state in ipairs(self.players) do
		state.player.inCutscene = true
		stopMovement(state.player)
		if state.camera then
			state.camera:changeTarget(self.focus)
			state.camera.targetZoom = state.camera.startingZoom + self.zoom
		end
	end
end

-- restaura o estado dos participantes antes de executar a consequência da cena.
function Cutscene:finish()
	if not self.active then
		return
	end

	self.active = false
	for _, state in ipairs(self.players) do
		state.player.inCutscene = state.inCutscene
		if state.camera then
			state.camera.target = state.target
			state.camera.targetZoom = state.targetZoom
		end
	end

	if self.onFinish then
		self.onFinish()
	end
end

---@class CutsceneManager
---@field current Cutscene?
CutsceneManager = {}
CutsceneManager.current = nil

---@param cutscene Cutscene
---@return boolean
function CutsceneManager:start(cutscene)
	if self.current then
		return false
	end

	self.current = cutscene
	cutscene:start()
	return true
end

---@param cutscene Cutscene
function CutsceneManager:finish(cutscene)
	if self.current ~= cutscene then
		return
	end

	self.current = nil
	cutscene:finish()
end
