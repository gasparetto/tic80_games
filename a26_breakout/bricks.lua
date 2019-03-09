-----------------------------------------------------------
-- BRICKS

-- 6=red 9=orange 4=brown 14=yellow 5=green 2=blue
local BRICK_COLORS = { 6, 9, 4, 14, 5, 2 }
local BRICK_SPEEDS = { 3.0, 2.0, 2.0, 1.5, 1.5, 1.5 }
local BRICK_SFX_NOTES = { 58, 55, 51, 49, 46, 42 }

function init_bricks()
  game.bricks = {}
  for y = 1, 6 do
    for x = 1, 18 do
      game.bricks[#game.bricks + 1] = init_brick(x, y)
    end
  end
end

function init_brick(x, y)
  return {
    id = x.."x"..y,
    x = 20 + x * 10,
    y = 36 + y * 4,
    w = 10,
    h = 4,
    s = BRICK_SPEEDS[y],
    c = BRICK_COLORS[y],
    sfx = BRICK_SFX_NOTES[y],
    score = 1,
    tostring = function(self)
      return string.format(
        "brick { id=%s, x=%d, y=%d, w=%d, h=%d, speed=%.2f, color=%d }",
        self.id, self.x, self.y, self.w, self.h, self.s, self.c)
    end
  }
end

function count_bricks()
  local size = 0
  for _ in pairs(game.bricks) do size = size + 1; end
  return size
end

-- side 1=bottom 2=left 3=right 4=top
function brick_has_neightbour_at_side(brick, side)
  local b = brick
  -- make a copy of the brick
  local b2 = {x = b.x, y = b.y, w = b.w, h = b.h}
  -- translate the brick2
  if side == 1 then b2.y = b2.y + b.h
  elseif side == 2 then b2.x = b2.x - b.w
  elseif side == 3 then b2.x = b2.x + b.w
  elseif side == 4 then b2.y = b2.y - b.h
  end
  -- check if brick2 hit another brick
  for _, v in pairs(game.bricks) do
    if utils_game.rect_overlap(b2, v) then
      return true end
  end
  return false
end

function draw_brick(brick)
  rect(brick.x, brick.y, brick.w, brick.h, brick.c)
end

function draw_bricks()
  for _, brick in pairs(game.bricks) do
    draw_brick(brick)
  end
end

