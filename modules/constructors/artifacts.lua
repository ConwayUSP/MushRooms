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
	local a = Artifact.new(INVISIBILITY_RING.name, INVISIBILITY_RING.description, 20, onUse, customData, customUpdate)
	return a
end
