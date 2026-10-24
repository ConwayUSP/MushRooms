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
		constructor = newDefenseParticles,
	},
	[PARTICLE_WALKING] = {
		constructor = newWalkingParticles,
		directed = true, -- a direção da emissão importa
		invDirection = true, -- a direção da partícula vai em oposição à entidade
	},
	[PARTICLE_TREASURE_DISAPPEAR] = {
		constructor = newTreasureDisappearParticles,
		emitAtStart = 12,
	},
	[PARTICLE_MOAI_BOSS_STARTING] = {
		constructor = newMoaisBossStartingParticles,
	},
	[PARTICLE_PUZZLE_STONE_MOVING] = {
		constructor = newPuzzleStoneMovingParticles,
	},
	[PARTICLE_BREAKING] = {
		constructor = newBreakingParticles,
		blendMode = "add",
	},
	[PARTICLE_SEED] = {
		constructor = newSeedParticles,
		blendMode = "add",
	},
	[PARTICLE_KATANA] = {
		constructor = newKatanaParticles,
		blendMode = "add",
	},
	[PARTICLE_BLACK_HOLE] = {
		constructor = newBlackHoleParticles,
	},
	[PARTICLE_FLOWER_SHOT] = {
		constructor = newFlowerShotParticles,
		emitAtStart = 10, -- emite 40 particulas de uma vez no início
		directed = true,
		ownerInertia = true, -- considera a velocidade do owner na velocidade das partículas (exclusivo para ataques)
		offset = vec(0, 5),
	},
	[PARTICLE_DEMON_DIE] = {
		constructor = newDemonDieParticles,
		emitAtStart = 40, -- estouro de brasas de uma vez
		offset = vec(0, 10),
	},
	[PARTICLE_DEMON_TRAIL] = {
		constructor = newDemonTrailParticles,
		directed = true,
		invDirection = true,
		offset = vec(0, 14),
	},
	[PARTICLE_FEATHER] = {
		constructor = newFeatherParticles,
		offset = vec(0, -25),
	},
	[PARTICLE_RUSH_DUST] = {
		constructor = newRushDustParticles,
		directed = true,
		invDirection = true,
		offset = vec(0, 22),
	},
	[PARTICLE_RADIATION] = {
		constructor = newRadiationParticles,
		blendMode = "add",
	},
	[PARTICLE_RADIATION_GLOW] = {
		constructor = newRadiationGlowParticles,
		blendMode = "add",
		offset = vec(0, -8),
	},
	[PARTICLE_PEBBLE_BREAK] = {
		constructor = newPebbleBreakParticles,
		emitAtStart = 14,
	},
	[PARTICLE_BREAK_BONE] = {
		constructor = newBoneBreakParticles,
		emitAtStart = 20,
	},
	[PARTICLE_BREAK_ROCK] = {
		constructor = newRockBreakParticles,
		emitAtStart = 26,
	},
	[PARTICLE_BREAK_COAL] = {
		constructor = newCoalBreakParticles,
		emitAtStart = 24,
	},
	[PARTICLE_BREAK_WOOD] = {
		constructor = newWoodBreakParticles,
		emitAtStart = 22,
	},
	[PARTICLE_BREAK_GRASS] = {
		constructor = newGrassBreakParticles,
		emitAtStart = 16,
	},
	[PARTICLE_WALL_HIT] = {
		constructor = newWallHitParticles,
		-- burst via emissionRate × emitterLifetime: se repete a cada batida
	},
	[PARTICLE_RAINBOW_DASH] = {
		constructor = newRainbowDashParticles,
		blendMode = "add",
		emitAtStart = 10,
	},
}

VFX_ANIMATIONS_TABLE = {
	[PARTICLE_EXPLOSION] = newAnimSetting(10, { width = 32, height = 32 }, 0.01, false, 0, 0, vec(0, 0), nil),
}
