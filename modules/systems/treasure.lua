----------------------------------------
-- Recompensas de salas de tesouro
----------------------------------------
require("modules.constructors.artifacts")
require("modules.constructors.blessings")
require("modules.constructors.weapons")
require("modules.utils.types")

local rewardFactories = {
	[WEAPON] = { newKatana, newSlingShot, newBoomerangue, newSkullShooter, newBlackholer, newFlowergun },
	-- [ARTIFACT] = { newInvisibilityRing, newRainbowDash },
	[BLESSING] = { newArcherBlessing, newFireBlessing, newPigmeuBlessing, newGomuGomuBlessing },
}

local rewardTypes = { 
	WEAPON, 
	-- ARTIFACT, 
	BLESSING
}

---@param rng RNG
---@return any[]
-- cria uma dupla distinta da mesma categoria
-- TODO: aprimorar no futuro para uma lógica mais complexa de geração de recompensas
function createTreasureRewards(rng)
	local rewardType = rewardTypes[rng:random(#rewardTypes)]
	local factories = rewardFactories[rewardType]
	local firstIndex = rng:random(#factories)
	local secondIndex = rng:random(#factories - 1)
	
	if secondIndex >= firstIndex then
		secondIndex = secondIndex + 1
	end

	return { factories[firstIndex](), factories[secondIndex]() }
end

---@param player Player
---@param reward any
---@return boolean
-- concede uma recompensa sem consumir a escolha quando o jogador não pode recebê-la.
function grantTreasureReward(player, reward)
	if reward.type == WEAPON then
		if not player:collectWeapon(reward) then
			return false
		end
		player:equipWeapon(reward.name)
	elseif reward.type == ARTIFACT then
		reward:setOwner(player)
		if not player:collectArtifact(reward) then
			return false
		end
	elseif reward.type == BLESSING then
		player.blessingManager:equip(reward)
	else
		return false
	end

	globalAudioManager:play(AUDIO_COLLECT, player, "pop")
	player:notifyItemCollected(reward)
	return true
end
