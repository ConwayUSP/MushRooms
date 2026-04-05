----------------------------------------
-- Enums de estado
----------------------------------------
-- Cada estado está relacionado a uma animação de uma entidade
---@alias State string

---------- PLAYERS E INIMIGOS ----------

IDLE = "idle"
WALKING_UP = "walking up"
WALKING_DOWN = "walking down"
WALKING_LEFT = "walking left"
WALKING_RIGHT = "walking right"
DEFENDING = "defending"
ATTACKING = "attacking"
ATTACKING_UP = "attacking up"
ATTACKING_DOWN = "attacking down"
ATTACKING_LEFT = "attacking left"
ATTACKING_RIGHT = "attacking right"
HURTING = "hurting" -- tomando dano
DYING = "dying"

------------- DESTRUTÍVEIS -------------

INTACT = "intact"
BREAKING = "breaking"
BROKEN = "broken"

------------- INTERAGIVEIS -------------

MOVING = "moving"
OPEN = "open"
OPENING = "opening"
CLOSED = "closed"
CLOSING = "closing"

------------ ELEMENTOS DE UI -----------

SELECTED = "selected"
