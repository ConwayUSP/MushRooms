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
  local blessing = Blessing.new(ARCHER_BLESSING.name, "Aumenta velocidade de ataque", COMBAT, applyFuncs)
  
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
  local blessing = Blessing.new(FIRE_BLESSING.name, "Projéteis incendeiam", COMBAT, applyFuncs)
  
  return blessing
end

function newPigmeuBlessing()
  local k = 0.7
  local applyFuncs = {
    [TP_ON_EQUIP] = function(owner)
      print("Equipou " .. PIGMEU_BLESSING.name)
      owner.size = owner.size * k
      owner.scale = owner.scale * k
      owner.hb = owner:calcHitboxes()
    end,
    [TP_ON_UNEQUIP] = function(owner)
      print("Desequipou " .. PIGMEU_BLESSING.name)
      owner.size = owner.size / k
      owner.scale = owner.scale / k
      owner.hb = owner:calcHitboxes()
    end
  }
  local blessing = Blessing.new(PIGMEU_BLESSING.name, "Fica pititico", COMBAT, applyFuncs)
  
  return blessing
end

function newGomuGomuBlessing()
  local applyFuncs = {
    [TP_ON_EQUIP] = function(owner)
      print("Equipou " .. GOMUGOMU_BLESSING.name)
    end,
    [TP_ON_UNEQUIP] = function(owner)
      print("Desequipou " .. GOMUGOMU_BLESSING.name)
    end,
    [TP_ON_ATTACK_PLAYER] = function(self, ctx)
      if ctx.player.state == DEFENDING then
        ctx.result = BS_REFLECT
      else
        ctx.result = BS_CONTINUE
      end
    end
  }
  local blessing = Blessing.new(GOMUGOMU_BLESSING.name, "Reflete ataques", COMBAT, applyFuncs)
  
  return blessing
end