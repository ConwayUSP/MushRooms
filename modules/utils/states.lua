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
UP = "up"
DOWN = "down"
RIGHT = "right"
LEFT = "left"
HURTING = "hurting" -- tomando dano
DYING = "dying"

DIRECTIONS = { UP, DOWN, LEFT, RIGHT }

------------- DESTRUTÍVEIS / ATAQUES -------------

INTACT = "intact"
BREAKING = "breaking"
BROKEN = "broken"

------------- INTERAGIVEIS -------------

MOVING = "moving"
OPEN = "open"
OPENING = "opening"
CLOSED = "closed"
CLOSING = "closing"

-------------- CONSTRUÇÕES -------------

ACTIVE = "active"

------------ ELEMENTOS DE UI -----------

SELECTED = "selected"
