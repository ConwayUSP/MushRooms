----------------------------------------
-- Importações de módulos
----------------------------------------
require("modules.systems.collision")
require("modules.entities.player")
require("modules.entities.room")

----------------------------------------
-- Enums
----------------------------------------
--- contexto atual do jogo
MENU_CTX = "Menu Context"
GAMEPLAY_CTX = "In-game Context"
QUITTING_CTX = "Quitting Context"

----------------------------------------
-- Funções globais
----------------------------------------

function startGame()
	createInitialRooms()
	collisionManager = CollisionManager.init()
	newPlayer()
	-- debug
	players[1]:collectWeapon(newSlingShot())
	players[1]:collectWeapon(newKatana())
	players[1]:collectWeapon(newBoomerangue())
	players[1]:equipWeapon(BOOMERANGUE.name)
	players[1]:collectArtifact(newInvisibilityRing():setOwner(players[1]))
	players[1]:equipArtifact(INVISIBILITY_RING.name)
	players[1].blessingManager:equip(newFireBlessing())
	gameCtx = GAMEPLAY_CTX
	globalUIManager:deactivateAllScenes()
end

function quitGame()
	gameCtx = QUITTING_CTX
	love.event.quit()
end
