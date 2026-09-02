----------------------------------------
-- Importações de módulos
----------------------------------------
require("modules.systems.collision")
require("modules.systems.links")
require("modules.entities.player")
require("modules.entities.room")

----------------------------------------
-- Enums
----------------------------------------
--- contexto atual do jogo
MENU_CTX = "Menu Context"
GAMEPLAY_CTX = "In-game Context"
QUITTING_CTX = "Quitting Context"

respawnRoom = vec(0, 0)
respawnPos = vec(0, 0)

----------------------------------------
-- Funções globais
----------------------------------------

function startGame()
	createInitialRooms()
	respawnPos = vec(rooms[0][0].pos.x, rooms[0][0].pos.y)
	collisionManager = CollisionManager.init()
	newPlayer()
	-- debug -------------------------------------------------
	players[1]:collectWeapon(newSlingShot())
	players[1]:collectWeapon(newKatana())
	players[1]:collectWeapon(newBoomerangue())
	players[1]:collectWeapon(newSkullShooter())
	players[1]:collectWeapon(newBlackholer())
	players[1]:collectWeapon(newFlowergun())
	players[1]:equipWeapon(BOOMERANGUE.name)
	players[1]:collectArtifact(newInvisibilityRing():setOwner(players[1]))
	players[1]:equipArtifact(INVISIBILITY_RING.name)
	players[1].blessingManager:equip(newFireBlessing())
	----------------------------------------------------------
	gameCtx = GAMEPLAY_CTX
	globalUIManager:deactivateAllScenes()
	globalAudioManager:changeMusic(MUSIC_LAYER1)
end

function quitGame()
	gameCtx = QUITTING_CTX
	love.event.quit()
end
