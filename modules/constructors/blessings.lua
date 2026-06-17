----------------------------------------
-- Construtores de Bençãos
----------------------------------------

function newArcherBlessing()
  local applyFuncs = {
    onEquip = function(self)
      print("Equipou")
    end,
    onUnequip = function(self)
      print("Desequipou")
    end,
  }
  local blessing = Blessing.new(ARCHER_BLESSING.name, "Aumenta a velocidade de projéteis em 20% por 10 segundos.", COMBAT, applyFuncs)
  
  return blessing
end