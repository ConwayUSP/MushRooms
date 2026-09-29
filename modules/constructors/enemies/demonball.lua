----------------------------------------------
--- Bolota Demoníaca
----------------------------------------------

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Bolota Demoníaca (essa bolota é uma gambiarra do caralho)
function newDemonBall(spawnPos, room)
	-- movimentação em "pulos"
	local movementFunc = jumpToTargetMovement(0.65, 0.65, 35, Easing.outCubic, 0.9)
	local jumpDur = 1.12
	local atkDur = jumpDur / 2
	local jumpAtk = newDemonJumpAttack(atkDur)
	local emberAtk = newEmberMarkAttack(false)

	-- o movimento de ataque kamikaze
	local movements = {
		[jumpAtk.name] = function()
			local dashMove = dashToTargetMovement(jumpDur - 0.4, 0, Easing.outCubic, 0, 1.5)
			local time = 0
			local hasStopped = false
			return function(entity, dt)
				time = time + dt
				if not hasStopped then
					entity.friction = 4
					hasStopped = true
				end
				if time >= 0.4 then
					dashMove(entity, dt)
				end

				-- se o dash terminou e a bolota ainda não morreu
				if time >= jumpDur and entity.state ~= DYING then
					-- spawna a marca de brasa no local atual
					AttackEvent.new(emberAtk, entity, addVec(entity.pos, vec(0, 30)), 0)
					-- mata a bolota
					entity.hp = 0
					entity:die()
				end
			end
		end,
	}

	-- configs do ataque kamikaze
	local atkFrames = {
		[jumpAtk.name] = 10,
	}
	local attackAnimSettings = {
		[jumpAtk.name] = newAnimSetting(18, { width = 18, height = 36 }, 0.056, false),
	}

	-- física e hitboxes
	local atks = { jumpAtk, emberAtk }
	local hb = hitbox(Circle.new(10), vec(0, 10))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.6, 60, 1)

	local enemy = Enemy.new(DEMON_BALL.name, 1, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames, movements)

	-- a bolota demoníaca não tem sombra
	enemy.hasShadow = false

	-- animações
	local idleAnimSettings = newAnimSetting(2, { width = 18, height = 36 }, 0.45, true, 1)
	local walkingAnimSettings = newAnimSetting(14, { width = 18, height = 36 }, 0.08, true, 1)
	local dyingAnimSettings = newAnimSetting(1, { width = 1, height = 1 }, 0.1, false)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, dyingAnimSettings, attackAnimSettings)

	-- o ataque mira no player mas tem um raio de ação
	local function seekPlayerInRange(tm, target)
		seekClosestPlayer(tm, target)
		-- se achou um alvo, mas está mais longe que certa distância, remove o peso do alvo para não atacar ainda
		if target.weight > 0 and dist(tm.owner.pos, target.pos) > 200 then
			target.weight = 0
		end
	end
	enemy.atkTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekPlayerInRange)
	-- o movimento mira sempre no player
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)

	return enemy
end
