-----------------------------------------------------------
-- BALL

local BALL_START_POSITIONS = {
  { x = 40, y = 80, dx = 0.7, dy = 0.5 },
  { x = 120, y = 80, dx = 0.7, dy = 0.5 },
  { x = 120, y = 80, dx = -0.7, dy = 0.5 },
  { x = 200, y = 80, dx = -0.7, dy = 0.5 }
}

function init_ball()
  local pos = BALL_START_POSITIONS[math.random(1, 4)]
  game.ball = {
    x = pos.x,
    y = pos.y,
    dx = pos.dx,
    dy = pos.dy,
    w = 3,
    h = 3,
    s = 1.5, -- speed
    ds = 0.0,
    c = 6, -- color
    tostring = function(self)
      return string.format(
        "ball { x=%.2f, y=%.2f, dx=%.2f, dy=%.2f, w=%d, h=%d, speed=%.2f, ds=%.2f, color=%d }",
        self.x, self.y, self.dx, self.dy, self.w, self.h, self.d, self.ds, self.c)
    end
  }
end

function update_ball()
  local b = game.ball
  -- ball speed
  local s = b.s + b.ds
  -- ball movement
  b.x = b.x + (b.dx * s)
  b.y = b.y + (b.dy * s)
end

function draw_ball()
  local b = game.ball
  rect(b.x, b.y, b.w, b.h, b.c)
end

function ball_hit_paddle(offset)
  local b = game.ball
  -- calculate a normalized offset factor
  -- divide by 18 and not 13 to avoid horizontal f
  local f = offset / 18.0 -- f = -0.72|0.0|0.72
  f = math.max(math.min(f, 0.72), -0.72)
  b.dx = f
  b.dy = -1 + math.abs(f)
  b.ds = math.abs(f)
end

-- side 1=bottom 2=left 3=right 4=top
function ball_hit_brick(brick, side)
  local b = game.ball
--  trace(game.tick..": "..b:tostring().." hit "
--    ..brick:tostring().." at brick side "..side)
  -- check if there is another brick at the side
  if side == 1 or side == 4 then
    if brick_has_neightbour_at_side(brick, side) then
      b.dx = -b.dx else b.dy = -b.dy end
  elseif side == 2 or side == 3 then
    if brick_has_neightbour_at_side(brick, side) then
      b.dy = -b.dy else b.dx = -b.dx end
  end
  b.s = brick.s
end

function ball_lost()
  game.ball = nil
  game.lives = game.lives - 1
  if game.lives == 0 then gameover() end
end

