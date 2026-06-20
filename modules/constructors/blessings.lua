----------------------------------------
-- Construtores de Bençãos
----------------------------------------

function newArcherBlessing()
  local applyFuncs = {
    [TP_ON_EQUIP] = function(self)
      print("Equipou " .. ARCHER_BLESSING.name)
    end,
    [TP_ON_UNEQUIP] = function(self)
      print("Desequipou " .. ARCHER_BLESSING.name)
    end,
  }
  local blessing = Blessing.new(ARCHER_BLESSING.name, "Aumenta a velocidade de projéteis em 20% por 10 segundos.", COMBAT, applyFuncs)
  
  return blessing
end

function newFireBlessing()
  local applyFuncs = {
    [TP_ON_EQUIP] = function(self)
      print("Equipou " .. FIRE_BLESSING.name)
    end,
    [TP_ON_UNEQUIP] = function(self)
      print("Desequipou " .. FIRE_BLESSING.name)
    end,
    [TP_ON_ATTACK_ENEMY] = function(self, ctx)
      local enemy = ctx.enemy
      enemy:burn(3, 1)
    end,
  }
  local blessing = Blessing.new(FIRE_BLESSING.name, "Projéteis incendiários causam queimadura por 3 segundos, causando 1 de dano a cada segundo.", COMBAT, applyFuncs)
  
  return blessing
end