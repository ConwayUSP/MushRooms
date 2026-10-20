require("modules.entities.resource")

---@return Resource
-- cria um recurso do tipo Madeira
function newCaskin()
	local wood = Resource.new(MATERIAL, CASKIN.name, CASKIN.description)
	return wood
end

---@return Resource
-- cria um recurso do tipo Pedra
function newPedacito()
	local stone = Resource.new(MATERIAL, PEDACITO.name, PEDACITO.description)
	return stone
end

---@return Resource
-- cria um recurso do tipo Carvão
function newFafogo()
	local coal = Resource.new(MATERIAL, FAFOGO.name, FAFOGO.description)
	return coal
end

---@return Resource
-- cria um recurso do tipo Osso
function newTuntun()
	local bone = Resource.new(MATERIAL, TUNTUN.name, TUNTUN.description)
	return bone
end

---@return Resource
-- cria um recurso do tipo Ferro
function newPorro()
	local iron = Resource.new(MATERIAL, PORRO.name, PORRO.description)
	return iron
end

---@return Resource
-- cria um recurso do tipo Ouro
function newWaw()
	local gold = Resource.new(MATERIAL, WAW.name, WAW.description)
	return gold
end

---@return Resource
-- cria um recurso do tipo Pena
function newPuff()
	local feather = Resource.new(MATERIAL, PUFF.name, PUFF.description)
	return feather
end

---@return Resource
-- cria um recurso do tipo Corda
function newCoseca()
	local rope = Resource.new(MATERIAL, COSECA.name, COSECA.description)
	return rope
end

---@return Resource
-- cria um recurso do tipo Vidro
function newArduro()
	local glass = Resource.new(MATERIAL, ARDURO.name, ARDURO.description)
	return glass
end

---@return Resource
-- cria um recurso do tipo Cogumélium
function newCogumelium()
	local cogumelium = Resource.new(MATERIAL, COGUMELIUM.name, COGUMELIUM.description)
	return cogumelium
end

---@return Resource
-- cria um recurso do tipo Slime
function newBlub()
	local slime = Resource.new(MATERIAL, BLUB.name, BLUB.description)
	return slime
end

---@return Resource
-- cria um recurso do tipo Argila
function newMolle()
	local clay = Resource.new(MATERIAL, MOLLE.name, MOLLE.description)
	return clay
end

---@return Resource
-- cria um recurso do tipo Óleo
function newEww()
	local oil = Resource.new(MATERIAL, EWW.name, EWW.description)
	return oil
end

---@return Resource
-- cria um recurso do tipo Linha
function newCobrita()
	local line = Resource.new(MATERIAL, COBRITA.name, COBRITA.description)
	return line
end

---@return Resource
-- cria um recurso do tipo Alface
function newFalho()
	local lettuce = Resource.new(MATERIAL, FALHO.name, FALHO.description)
	return lettuce
end

---@return Resource
-- cria um recurso do tipo Grãos
function newTumbu()
	local beans = Resource.new(MATERIAL, TUMBU.name, TUMBU.description)
	return beans
end

---@return Resource
-- cria um recurso do tipo Alho/Cebola
function newFroncho()
	local garlic = Resource.new(MATERIAL, FRONCHO.name, FRONCHO.description)
	return garlic
end

---@return Resource
-- cria um recurso do tipo Ervas/Tempero
function newFunpo()
	local herbs = Resource.new(MATERIAL, FUNPO.name, FUNPO.description)
	return herbs
end

---@return Resource
-- cria um recurso do tipo Pimenta
function newGraah()
	local pepper = Resource.new(MATERIAL, GRAAH.name, GRAAH.description)
	return pepper
end

---@return Resource
-- cria um recurso do tipo Cenoura
function newCabra()
	local carrot = Resource.new(MATERIAL, CABRA.name, CABRA.description)
	return carrot
end

---@return Resource
-- cria um recurso do tipo Batata
function newChubo()
	local potato = Resource.new(MATERIAL, CHUBO.name, CHUBO.description)
	return potato
end

---@return Resource
-- cria um recurso do tipo Trigo
function newJifofa()
	local wheat = Resource.new(MATERIAL, JIFOFA.name, JIFOFA.description)
	return wheat
end

---@return Resource
-- cria um recurso do tipo Carne
function newBiff()
	local meat = Resource.new(MATERIAL, BIFF.name, BIFF.description)
	return meat
end

---@return Resource
-- cria um recurso do tipo Leite
function newYuli()
	local milk = Resource.new(MATERIAL, YULI.name, YULI.description)
	return milk
end

---@return Resource
-- cria um recurso do tipo Açúcar
function newNham()
	local sugar = Resource.new(MATERIAL, NHAM.name, NHAM.description)
	return sugar
end

---@return Resource
-- cria um recurso do tipo Ovo
function newPlop()
	local egg = Resource.new(MATERIAL, PLOP.name, PLOP.description)
	return egg
end

---@return Resource
-- cria um recurso do tipo Fruta Doce Redonda
function newBouba()
	local bouba = Resource.new(MATERIAL, BOUBA.name, BOUBA.description)
	return bouba
end

---@return Resource
-- cria um recurso do tipo Peixe
function newMelsh()
	local fish = Resource.new(MATERIAL, MELSH.name, MELSH.description)
	return fish
end

---@return Resource
-- cria um recurso do tipo Cogumelo
function newChongo()
	local mushroom = Resource.new(MATERIAL, CHONGO.name, CHONGO.description)
	return mushroom
end

---@return Resource
-- cria um recurso do tipo Queijo
function newWamoli()
	local cheese = Resource.new(MATERIAL, WAMOLI.name, WAMOLI.description)
	return cheese
end

---@return Resource
-- cria um recurso do tipo Mel
function newZub()
	local honey = Resource.new(MATERIAL, ZUB.name, ZUB.description)
	return honey
end
