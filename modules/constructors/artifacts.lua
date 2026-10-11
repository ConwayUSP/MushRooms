----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.artifact")
require("modules.utils.timer")
require("modules.utils.types")

----------------------------------------
-- Construtores de Artefatos
----------------------------------------

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
			self.owner.invisible = false
		end
	end
	local ring = Artifact.new(INVISIBILITY_RING.name, INVISIBILITY_RING.description, 20, onUse, customData, customUpdate)
	return ring
end

function newRainbowDash()
	local onUse = function(self)
		local aim = self.owner.controls:getAimDir()
		if not aim or self.owner.state == DEFENDING then
			return
		else
			local dur = 0.175
			local dashMove = dashToDirection(aim, dur, 1850)
			self.owner.specialMovement = dashMove
			self.owner:setInvulnerable(dur)
		end 
	end
	local dash = Artifact.new(RAINBOW_DASH.name, RAINBOW_DASH.description, 2, onUse)
	return dash
end
