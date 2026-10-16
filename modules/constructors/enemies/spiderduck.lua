----------------------------------------------
--- Pato Aranha
----------------------------------------------

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Pato Aranha
function newSpiderDuck(spawnPos, room)
	local movementFunc = dashToTargetMovement(1.2, 1.0, Easing.outQuad, math.rad(10), 0.5)
	local atkCooldown = randCooldown(3.0, 4.0)
	local frameDur = 0.1
	local framesAtks = 12
	local atkDur = framesAtks * frameDur
	local framesStart = 5
	local startDur = framesStart * frameDur
	local framesBrake = 22 - framesStart - framesAtks
	local brakeDur = framesBrake * frameDur
	local attack = newRotatoryAttack(false, atkDur, atkCooldown)
	local movements = {
		[attack.name] = function()
			local flightMove = followTargetMovement(4, 1500)
			local elapsed = 0

			return function(entity, dt)
				elapsed = elapsed + dt

				if elapsed <= startDur then
					applySteering(entity, vec(0, 0), 12)
				elseif elapsed <= startDur + atkDur then
					flightMove(entity, dt)
				elseif elapsed <= startDur + atkDur + brakeDur then
					applySteering(entity, vec(0, 0), 20)
				end
			end
		end,
	}
	local atkFrames = {
		[attack.name] = 4,
	}
	local attackAnimSettings = {
		[attack.name] = newAnimSetting(22, { width = 32, height = 50 }, frameDur, false, 1, 4, vec(0, -9)),
	}
	local atks = { attack }
	local hb = hitbox(Circle.new(25))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.8, 300, 5)
	local enemy =
		Enemy.new(SPIDER_DUCK.name, 45, spawnPos, physics, movementFunc, atks, hbs, room, atkFrames, movements)
	local idleAnimSettings = newAnimSetting(2, { width = 32, height = 32 }, 0.4, true, 1)
	local walkingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.15, true, 1)
	local dyingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.1, false)
	enemy:addAnimations(idleAnimSettings, walkingAnimSettings, dyingAnimSettings, attackAnimSettings)
	enemy.shadowWidth = 27
	enemy.moveTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	enemy.atkTargeting:addTarget(Target.new(TG_SEEK, TC_EVERY_FRAME), seekClosestPlayer)
	return enemy
end
