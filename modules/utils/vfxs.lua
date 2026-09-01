require("modules.utils.types")
require("modules.constructors.particles")

---------------------------------------
-- Encapsulamento de Partículas
----------------------------------------

---@alias AtkParticles table<string, string>

---@param onAtk? string
---@param projTrail? string
---@param onBreak? string
---@return ArkParticles
-- facilitador para configurar partículas de ataques
-- onAtk: é emitido quando o ataque é gerado
-- projTrail: segue o projétil até ele ser destruído
-- onBreak: é emitido quando o ataque acaba
function atkParticles(onAtk, projTrail, onBreak)
	return {
		onAtk = onAtk,
		projTrail = projTrail,
		onBreak = onBreak,
	}
end

----------------------------------------
-- Tabelas de Configurações
----------------------------------------

----------------------------------------------------------------------
--- Todas as configurações de partículas do jogo
--- devem ser definidas aqui. Cada tipo de partícula deve
--- ter uma função que retorna um sistema de partículas configurado.
----------------------------------------------------------------------

PARTICLES_SETTINGS = {
	[PARTICLE_DEFENSE] = {
		constructor = function(color1, color2)
			return newDefenseParticles(color1, color2)
		end,
	},
	[PARTICLE_WALKING] = {
		constructor = function()
			return newWalkingParticles()
		end,
	},
	[PARTICLE_BREAKING] = {
		constructor = function()
			return newBreakingParticles()
		end,
		blendMode = "add",
	},
	[PARTICLE_SEED] = {
		constructor = function()
			return newSeedParticles()
		end,
		blendMode = "add",
	},
	[PARTICLE_KATANA] = {
		constructor = function()
			return newKatanaParticles()
		end,
		blendMode = "add",
	},
	[PARTICLE_BLACK_HOLE] = {
		constructor = function()
			return newBlackHoleParticles()
		end,
	},
}

VFX_ANIMATIONS_TABLE = {
	[PARTICLE_EXPLOSION] = newAnimSetting(10, { width = 32, height = 32 }, 0.01, false, 0, 0, vec(0, 0), nil),
}
