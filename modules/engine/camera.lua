----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.player")
require("modules.utils.easing")
require("modules.utils.utils")

----------------------------------------
-- Variáveis
----------------------------------------
cameras = {}

----------------------------------------
-- Classe Camera
----------------------------------------

---@class Camera
---@field playerAttached Player
---@field target Player | Npc | Enemy Alvo que a câmera segue
---@field viewport Size
---@field canvas table
---@field canvasPos Vec
---@field cx number
---@field cy number
---@field targetPos Vec
---@field transitionSpeed number
---@field shakeOffset Vec
---@field shakeIntensity number
---@field shakeDuration number
---@field shakeTimer number
---@field startingZoom number
---@field zoom number
---@field targetZoom number
---@field zoomSpeed number
---@field cinematicTimer number
---@field viewPos function
---@field changeTarget function

Camera = {}
Camera.__index = Camera

---@param pos Vec
---@param viewport Size
---@param canvas table
---@param canvasPos Vec
---@param player Player
---@return Camera
-- cria uma câmera atrelada a um jogador e um canvas
function Camera.new(pos, viewport, canvas, canvasPos, player)
	local camera = setmetatable({}, Camera)

	camera.playerAttached = player -- jogador associado à câmera
	camera.target = player      -- alvo que a câmera segue (inicialmente o player)
	camera.viewport = viewport  -- tamanho da câmera (o espaço que ela enxerga)
	camera.canvas = canvas      -- canvas associado à câmera
	camera.canvasPos = canvasPos -- posição do canvas na tela
	camera.cx = pos.x
	camera.cy = pos.y
	camera.targetPos = { x = pos.x, y = pos.y } -- onde a câmera deve ir
	-- atributos fixos na instanciação
	camera.transitionSpeed = 6               -- controla a suavidade da transição
	camera.shakeOffset = { x = 0, y = 0 }    -- deslocamento atual do shake
	camera.shakeIntensity = 0                -- intensidade do shake
	camera.shakeDuration = 0                 -- duração total do shake
	camera.shakeTimer = 0                    -- tempo restante do shake
	-- atributos de zoom
	camera.startingZoom = camera:calculateZoom()
	camera.zoom = camera.startingZoom + 0.1
	camera.targetZoom = camera.startingZoom -- zoom desejado
	camera.zoomSpeed = 3                 -- velocidade da transição
	-- atributos de cinemática
	camera.cinematicTimer = 0

	player.uiManager:setParentCanvas(canvas, canvasPos)
	return camera
end

---@param dt number
-- atualiza a posição da câmera com certa suavização ao seguir o alvo
function Camera:updatePosition(dt)
	-- suaviza o zoom atual
	self.zoom = lerp(self.zoom, self.targetZoom, dt * self.zoomSpeed)

	-- ajusda o viewport de acordo com o zoom
	local viewportZoomed = {
		width = self.viewport.width / self.zoom,
		height = self.viewport.height / self.zoom,
	}
	-- TODO: câmera única quando os jogadores estão próximos
	if #cameras == 1 and #players > 1 then
		local pos = { x = 0, y = 0 }
		for _, p in pairs(players) do
			pos.x = pos.x + p.pos.x
			pos.y = pos.y + p.pos.y
		end
		self.targetPos.x = pos.x / #players - viewportZoomed.width / 2
		self.targetPos.y = pos.y / #players - viewportZoomed.height / 2
	else
		-- a câmera segue o target (que pode ser o player ou outra entidade)
		if self.target and self.target.pos and self.target.room then
			local room = self.target.room

			if room then
				-- limita a posição da câmera ao hitbox da sala
				self.targetPos.x = clamp(
					self.target.pos.x,
					room.limits.p1.x - Room.spacingH / 2 + viewportZoomed.width / 2,
					room.limits.p2.x + Room.spacingH / 2 - viewportZoomed.width / 2
				)
				self.targetPos.y = clamp(
					self.target.pos.y,
					room.limits.p1.y + viewportZoomed.height / 2,
					room.limits.p2.y - Room.spacingV / 2 - viewportZoomed.height / 2
				)
			end
		end
	end

	self:updateShake(dt)
	self:updateCinematic(dt)

	self.cx = lerp(self.cx, self.targetPos.x, dt * self.transitionSpeed) + self.shakeOffset.x
	self.cy = lerp(self.cy, self.targetPos.y, dt * self.transitionSpeed) + self.shakeOffset.y
end

---@param intensity number
---@param duration number
-- causa um tremor na câmera com certa intensidade e duração
function Camera:shake(intensity, duration)
	self.shakeIntensity = intensity or 10
	self.shakeDuration = duration or 0.3
	self.shakeTimer = self.shakeDuration
end

---@param dt number
-- atualiza o estado do tremor da câmera
function Camera:updateShake(dt)
	-- atualiza shake se estiver ativo
	if self.shakeTimer > 0 then
		self.shakeTimer = self.shakeTimer - dt
		local progress = self.shakeTimer / self.shakeDuration

		-- gera deslocamento aleatório (intensidade decresce)
		local intensity = self.shakeIntensity * progress
		self.shakeOffset.x = (math.random() - 0.5) * intensity
		self.shakeOffset.y = (math.random() - 0.5) * intensity

		if self.shakeTimer <= 0 then
			self.shakeOffset.x = 0
			self.shakeOffset.y = 0
		end
	end
end

---@param dt number
-- atualiza o timer de uma cena - que por proxy define o tamanho
-- das barras horizontais na câmera
function Camera:updateCinematic(dt)
	if self.playerAttached and self.playerAttached.inDialogue then
		self.cinematicTimer = self.cinematicTimer + dt
	else
		self.cinematicTimer = 0
	end
end

-- calcula o zoom atual da câmera
function Camera:calculateZoom()
	if not self.playerAttached then
		return 1
	end

	local roomDim = self.playerAttached.room.stdDim
	local rawZoom = self.viewport.width / window.width
	local rightZoom
	if #players == 1 or #players == 3 then
		rightZoom = remap(rawZoom, (1 / 3), 1, 0.6, 0.9)
	elseif #players == 2 then
		rightZoom = remap(rawZoom, (1 / 3), 1, 0.65, 1.1)
	else
		rightZoom = remap(rawZoom, (1 / 3), 1, 0.45, 0.7)
	end

	return clamp(rightZoom, self.viewport.width / roomDim.width, 2)
end

---@param target Player | Npc | Enemy
-- muda o alvo que a câmera deve seguir
function Camera:changeTarget(target)
	self.target = target
end

---@param entityPos Vec
---@return Vec
-- retorna a posição da entidade dada pelo parâmetro `entityPos`
-- no frame de referência relativo à posição da câmera
function Camera:viewPos(entityPos)
	return {
		x = entityPos.x - self.cx + self.viewport.width / 2,
		y = entityPos.y - self.cy + self.viewport.height / 2,
	}
end

----------------------------------------
-- Função de Renderização
----------------------------------------

-- renderiza o conteúdo visto pela câmera no `canvas`
-- associado à ela
function Camera:draw()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear(0.0, 0.0, 0.0, 1.0)
	love.graphics.push()

	-- centraliza o zoom
	love.graphics.translate(self.viewport.width / 2, self.viewport.height / 2)
	love.graphics.scale(self.zoom)
	love.graphics.translate(-self.viewport.width / 2, -self.viewport.height / 2)

	-- renderiza mundo
	renderRooms(self)
	-- renderiza links de todas as salas
	renderLinks(self)
	-- renderiza entidades com Y-sorting
	renderEntities(self)
	-- renderiza as hitboxes ativas (debug)
	renderHitboxes(self)
	-- renderiza caixas de diálogo por cima de tudo
	renderDialogues(self)

	love.graphics.pop()

	-- barras pretas em espaço de tela (fora do canvas/zoom)
	renderBlackBars(self)
	-- renderiza a UI do jogador associado
	renderPlayerUIs(self)

	love.graphics.setCanvas()

	love.graphics.push()
	love.graphics.scale(window.scale)

	-- renderizando os canvas na janela
	love.graphics.draw(self.canvas, self.canvasPos.x, self.canvasPos.y)

	love.graphics.pop()
end

----------------------------------------
-- Funções Globais
----------------------------------------

---@param camera Camera
-- renderiza barras pretas em no topo e na base do canvas
function renderBlackBars(camera)
	local maxBarHeight = camera.canvas:getHeight() / 10
	local barHeight = Easing.outQuad(clamp(camera.cinematicTimer, 0, 1)) * maxBarHeight

	-- desenha barras relativas à região do canvas da câmera
	local x = 0
	local w = camera.viewport.width * 10
	local h = camera.viewport.height
	local y = 0

	love.graphics.setColor(0, 0, 0, 1)
	-- barra superior
	love.graphics.rectangle("fill", x, y, w, barHeight)
	-- barra inferior
	love.graphics.rectangle("fill", x, y + h - barHeight, w, barHeight)
	love.graphics.setColor(1, 1, 1, 1)
end

---@param player Player
---@return Camera | nil
--- retorna a câmera associada ao `player` passado como argumento
function getCameraByPlayer(player)
	for _, cam in pairs(cameras) do
		if cam.playerAttached == player then
			return cam
		end
	end
	return nil
end

---@param oldCamera Camera
---@param newCamera Camera
-- para quando redimensionamos a tela e precisamos criar câmeras novas
function transferCameraState(oldCamera, newCamera)
	newCamera.zoom = oldCamera.zoom
	newCamera.targetZoom = oldCamera.targetZoom
	newCamera.zoomSpeed = oldCamera.zoomSpeed
	newCamera.target = oldCamera.target
	newCamera.targetPos = oldCamera.targetPos
	newCamera.shakeDuration = oldCamera.shakeDuration
	newCamera.shakeIntensity = oldCamera.shakeIntensity
	newCamera.shakeOffset = oldCamera.shakeOffset
	newCamera.shakeTimer = oldCamera.shakeTimer
	newCamera.cinematicTimer = oldCamera.cinematicTimer
end

-- cria uma câmera nova para cada player
function newCameras()
	local numOfCams = #players
	-- fazendo backup das câmeras antigas para transferir estado se necessário
	local oldCameras = {}
	for i = 1, numOfCams do
		if cameras[i] then
			oldCameras[i] = cameras[i]
		end
	end
	cameras = {}

	for i = 1, numOfCams do
		if numOfCams <= 3 then
			local camera = Camera.new(
				players[i].pos,
				{ width = window.width / numOfCams, height = window.height },
				love.graphics.newCanvas(window.width / numOfCams, window.height),
				{ x = (i - 1) * (window.width / numOfCams), y = 0 },
				players[i]
			)
			if oldCameras[i] then
				transferCameraState(camera, oldCameras[i])
			end
			table.insert(cameras, camera)
		else -- no caso de 4 câmeras
			local canvasPositions = {
				{ x = 0,                y = 0 },
				{ x = window.width / 2, y = 0 },
				{ x = 0,                y = window.height / 2 },
				{ x = window.width / 2, y = window.height / 2 },
			}
			local camera = Camera.new(
				players[i].pos,
				{ width = window.width / 2, height = window.height / 2 },
				love.graphics.newCanvas(window.width / 2, window.height / 2),
				canvasPositions[i],
				players[i]
			)
			if oldCameras[i] then
				transferCameraState(camera, oldCameras[i])
			end
			table.insert(cameras, camera)
		end
	end
end
