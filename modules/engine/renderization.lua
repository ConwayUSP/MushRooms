----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.camera")
require("modules.systems.dialogue")
require("modules.utils.anchors")

----------------------------------------
-- Funções Globais
----------------------------------------

---@param camera Camera
-- renderiza as salas na perspectiva da `camera`
function renderRooms(camera)
	for i = rooms.minIndex, rooms.maxIndex do
		for j = rooms[i].minIndex, rooms[i].maxIndex do
			local r = rooms[i][j]
			if not r then
				goto nextroom
			end

			local roomViewPos = addVec(camera:viewPos(r.limits.p1), vec(Room.spacingH / 2, Room.spacingV / 2))
			love.graphics.draw(r.sprites.floor, roomViewPos.x, roomViewPos.y, 0, 3, 3)

			::nextroom::
		end
	end
end

----------------------------------------
-- Funções de Renderização Global
----------------------------------------

---@param camera Camera
-- renderiza os links de todas as salas na perspectiva da `camera`
function renderLinks(camera)
	for _, r in activeRooms:iter() do
		r.linkManager:draw(camera)
	end
end

---@param camera Camera
-- renderiza as demais entidades (além das salas) na perspecitiva da `camera`
function renderEntities(camera)
	local drawList = {}

	for _, r in activeRooms:iter() do
		-- Adiciona destrutíveis
		for _, d in pairs(r.destructibles) do
			table.insert(drawList, {
				it = d,
				y = d.pos.y + getAnchor(d, FLOOR),
				draw = function()
					d:draw(camera)
				end,
			})
		end
		-- Adiciona objetos interativos
		for _, i in pairs(r.interactives) do
			table.insert(drawList, {
				it = i,
				y = i.pos.y + getAnchor(i, FLOOR),
				draw = function()
					i:draw(camera)
				end,
			})
		end
		-- Adiciona portas
		for _, d in pairs(r.doors) do
			table.insert(drawList, {
				it = d,
				y = d.pos.y + getAnchor(d, FLOOR),
				draw = function()
					d:draw(camera)
				end,
			})
		end
		-- Adiciona drops
		for _, i in pairs(r.drops) do
			local dropScale = (i.object and i.object.type == RESOURCE) and 1.875 or 3

			i.scale = dropScale
			table.insert(drawList, {
				it = i,
				y = i.floorY + getAnchor(i, FLOOR, dropScale),
				draw = function()
					i:draw(camera)
				end,
			})
		end
		-- Adiciona inimigos
		for _, e in pairs(r.enemies) do
			table.insert(drawList, {
				it = e,
				y = e.pos.y + getAnchor(e, FLOOR),
				draw = function()
					e:draw(camera)
				end,
			})
			-- Adiciona ataques de inimigos
			for _, a in pairs(e.atk) do
				for _, ev in pairs(a.events) do
					table.insert(drawList, {
						it = ev,
						y = ev.pos.y + getAnchor(ev, FLOOR) + getAnchor(e, FLOOR),
						draw = function()
							ev:draw(camera)
						end,
					})
				end
			end
		end

		-- Adiciona NPCs
		for _, npc in pairs(r.npcs) do
			table.insert(drawList, {
				it = npc,
				y = npc.pos.y + getAnchor(npc, FLOOR),
				draw = function()
					npc:draw(camera)
				end,
			})
		end

		-- Adiciona obstáculos
		for _, obs in pairs(r.obstacles) do
			table.insert(drawList, {
				it = obs,
				y = obs.pos.y + getAnchor(obs, FLOOR),
				draw = function()
					obs:draw(camera)
				end,
			})
		end
	end

	-- Adiciona jogadores e suas possíveis armas e construções
	for _, p in pairs(players) do
		table.insert(drawList, {
			it = p,
			y = p.pos.y + getAnchor(p, FLOOR),
			draw = function()
				p:draw(camera)
			end,
		})

		if p.weapon then
			local w = p.weapon
			local offsetY = (w.rotation >= 0) and 4 or -4
			table.insert(drawList, {
				it = w,
				y = p.pos.y + getAnchor(p, FLOOR) + offsetY, -- mesma altura do jogador, mas deslocado para frente ou para trás
				draw = function()
					w:draw(camera)
				end,
			})
		end

		for _, w in pairs(p.weapons) do
			for _, e in pairs(w.atk.events) do
				table.insert(drawList, {
					it = e,
					y = e.pos.y + getAnchor(e, FLOOR) + getAnchor(p, FLOOR),
					draw = function()
						e:draw(camera)
					end,
				})
			end
		end

		if p.building then
			local b = p.building
			table.insert(drawList, {
				it = b,
				y = b.pos.y + getAnchor(b, FLOOR),
				draw = function()
					b:draw(camera)
				end,
			})
		end
	end

	-- Construir sombras separadamente para não mutar drawList durante iteração
	local shadows = {}
	for _, obj in ipairs(drawList) do
		if obj.it and obj.it.hasShadow then
			local sx = (obj.it.pos and obj.it.pos.x) or 0
			local sy = obj.y - 1

			local frameWidth
			local scale = obj.it.scale or 3

			if obj.it.shadowWidth then
				frameWidth = obj.it.shadowWidth * scale
			else
				frameWidth = 16 * scale
			end

			-- largura da sombra proporcional à largura do sprite
			local rx = frameWidth / 2
			local ry = rx * 0.4

			table.insert(shadows, {
				y = sy,
				draw = function()
					love.graphics.setColor(0, 0, 0.1, 1.0)
					love.graphics.setShader(ditherShadowShader)
					local viewPos = camera:viewPos(vec(sx, sy))
					ditherShadowShader:send("shadow_center", { viewPos.x, viewPos.y })
					ditherShadowShader:send("shadow_radii", { rx, ry })
					ditherShadowShader:send("time", love.timer.getTime())
					ditherShadowShader:send("zoom", camera.zoom)
					ditherShadowShader:send("viewport_size", { camera.viewport.width, camera.viewport.height })

					love.graphics.circle("fill", viewPos.x, viewPos.y, rx)

					love.graphics.setColor(1, 1, 1, 1)
					love.graphics.setShader()
				end,
			})
		end
	end

	-- Ordena por posição Y
	table.sort(drawList, function(a, b)
		return a.y < b.y
	end)

	for _, s in ipairs(shadows) do
		s.draw()
	end

	love.graphics.setBlendMode("alpha")

	-- Desenha na ordem correta
	for _, obj in ipairs(drawList) do
		obj.draw()
	end
end

function renderPlayerUIs(camera)
	camera.playerAttached.uiManager:draw(camera)
	camera.playerAttached.room.uiManager:draw(camera)
end

---@param camera Camera
-- renderiza os diálogos ativos na perspectiva da `camera`
function renderDialogues(camera)
	for _, dialogue in pairs(DialogueManager.dialogues) do
		if dialogue.active then
			dialogue:draw(camera)
		end
	end
end

---@param camera Camera
-- renderiza as hitboxes de todas as entidades na perspectiva da `camera`
function renderHitboxes(camera)
	if not debugMode then
		return
	end

	---@type table<string, table<Entity, Hitboxes>>
	local registry = collisionManager.registry

	love.graphics.setLineWidth(3)
	for _, reg in pairs(registry) do
		for entity, hitboxes in pairs(reg) do
			renderSolids(camera, hitboxes.solids, entity)
			renderDefaults(camera, hitboxes.default, entity)
			renderTriggers(camera, hitboxes.triggers, entity)
		end
	end
	love.graphics.setLineWidth(1)
end

---@param camera Camera
---@param hitboxes Hitbox[]
---@param entity Entity
-- renderiza as hitboxes sólidas na perspectiva da `camera`
function renderSolids(camera, hitboxes, entity)
	if #hitboxes == 0 then
		return
	end

	love.graphics.setColor(1, 0.3, 0.3, 0.8)
	for _, hb in ipairs(hitboxes) do
		renderByShape(camera, hb, entity)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

---@param camera Camera
---@param hitboxes Hitbox[]
---@param entity Entity
-- renderiza as hitboxes padrão na perspectiva da `camera`
function renderDefaults(camera, hitboxes, entity)
	if #hitboxes == 0 then
		return
	end

	love.graphics.setColor(0.3, 0.3, 1, 0.8)
	for _, hb in ipairs(hitboxes) do
		renderByShape(camera, hb, entity)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

---@param camera Camera
---@param hitboxes Hitbox[]
---@param entity Entity
-- renderiza as hitboxes de gatilho na perspectiva da `camera`
function renderTriggers(camera, hitboxes, entity)
	if #hitboxes == 0 then
		return
	end

	love.graphics.setColor(0.3, 1, 0.3, 0.8)
	for _, hb in ipairs(hitboxes) do
		renderByShape(camera, hb, entity)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

function renderByShape(camera, hitbox, entity)
	local worldHb = buildWorldHitbox(hitbox, entity.pos)

	if worldHb.shape.shape == CIRCLE then
		renderCircleHitbox(camera, worldHb)
	elseif worldHb.shape.shape == RECTANGLE then
		renderRectangleHitbox(camera, worldHb)
	elseif worldHb.shape.shape == LINE then
		renderLineHitbox(camera, worldHb)
	end
end

---@param camera Camera
---@param hitbox CircleHitbox
--- renderiza a hitbox circular na perspectiva da `camera`
function renderCircleHitbox(camera, hitbox)
	local viewPos = camera:viewPos(hitbox.offset)
	love.graphics.circle("line", viewPos.x, viewPos.y, hitbox.shape.radius)
end

---@param camera Camera
---@param hitbox RectHitbox
--- renderiza a hitbox retangular na perspectiva da `camera`
function renderRectangleHitbox(camera, hitbox)
	local viewPos = camera:viewPos(hitbox.offset)
	love.graphics.rectangle(
		"line",
		viewPos.x - hitbox.shape.width / 2,
		viewPos.y - hitbox.shape.height / 2,
		hitbox.shape.width,
		hitbox.shape.height
	)
end

---@param camera Camera
---@param hitbox LineHitbox
--- renderiza a hitbox em formato de linha na perspectiva da `camera` (precisa de revisão)
function renderLineHitbox(camera, hitbox)
	local viewPos = camera:viewPos(hitbox.offset)
	local endPos = addVec(hitbox.offset, polarToVec(hitbox.shape.angle, hitbox.shape.length))
	local viewEndPos = camera:viewPos(endPos)
	love.graphics.line(viewPos.x, viewPos.y, viewEndPos.x, viewEndPos.y)
end
