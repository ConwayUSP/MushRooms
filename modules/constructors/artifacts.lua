----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.artifact")
require("modules.utils.timer")
require("modules.utils.types")

----------------------------------------
-- Construtores de Artefatos
----------------------------------------

---@param artifacts Artifact[]
---@return boolean
-- verifica se algum anel de invisibilidade da lista está com o efeito ativo
function hasActiveInvisibility(artifacts)
	for _, a in pairs(artifacts) do
		if a.name == INVISIBILITY_RING.name and a.customData and a.customData.timer.active then
			return true
		end
	end
	return false
end

function newInvisibilityRing()
	-- colocando no customData um timer para a duração do efeito de invisibilidade
	local customData = { timer = Timer.new(5) }
	local onUse = function(self)
		self.customData.timer:start()
		self.owner.invisible = true
	end
	local customUpdate = function(self, dt)
		self.customData.timer:update(dt)
		if self.customData.timer.goingOff then
			-- com dois anéis, só tira a invisibilidade se nenhum outro estiver ativo
			if not hasActiveInvisibility(self.owner.artifacts) then
				self.owner.invisible = false
			end
		end
	end
	local ring = Artifact.new(INVISIBILITY_RING.name, INVISIBILITY_RING.description, 20, onUse, customData, customUpdate)
	return ring
end

function newRainbowDash()
	local onUse = function(self)
		local aim
		if self.owner.controls.gamepad then 
			aim = self.owner.vel
		else 
			aim = self.owner.controls:getAimDir()
		end
		if not aim or self.owner.state == DEFENDING then
			return
		else
			local dur = 0.2
			local dashMove = dashToDirection(aim, dur, 2000)
			self.owner.specialMovement = dashMove
			self.owner:setInvulnerable(dur)
		end
	end
	local dash = Artifact.new(RAINBOW_DASH.name, RAINBOW_DASH.description, 1.5, onUse)
	return dash
end
