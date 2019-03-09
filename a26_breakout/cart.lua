-- title:  a26_breakout
-- author: game developer
-- desc:   Atari 2600 Breakout
-- script: lua
-- input:  gamepad

-----------------------------------------------------------
-- UTILS GAME

local utils_game = {}

function utils_game.set_palette_to_string(pal)
  for i = 0, 15 do
    local i6 = i * 6
    local r = tonumber(string.sub(pal, i6 + 1, i6 + 2), 16)
    local g = tonumber(string.sub(pal, i6 + 3, i6 + 4), 16)
    local b = tonumber(string.sub(pal, i6 + 5, i6 + 6), 16)
    poke(0x3FC0 + (i * 3) + 0, r)
    poke(0x3FC0 + (i * 3) + 1, g)
    poke(0x3FC0 + (i * 3) + 2, b)
  end
end

function utils_game.change_palette_to_random()
  for i = 0, 47 do
    poke(0x3FC0 + i, math.random(0, 255))
  end
end

function utils_game.set_mouse_cursor_to_spr(spr)
  poke(0x3FFB, spr)
end

-- https://stackoverflow.com/a/306332/942043
function utils_game.rect_overlap(a, b)
  return a.x < (b.x + b.w) and (a.x + a.w) > b.x
      and a.y < (b.y + b.h) and (a.y + a.h) > b.y
end

-- https://gamedev.stackexchange.com/a/29796
-- return 0=no collision 1=bottom 2=left 3=right 4=top
function utils_game.rect_collision(a, b)
  local w = 0.5 * (a.w + b.w)
  local h = 0.5 * (a.h + b.h)
  local dx = (a.x + (a.w / 2.0)) - (b.x + (b.w / 2.0))
  local dy = (a.y + (a.h / 2.0)) - (b.y + (b.h / 2.0))
  if math.abs(dx) < w and math.abs(dy) < h then
    local wy = w * dy
    local hx = h * dx
    if wy > hx then
      if wy > -hx then return 1 else return 2 end
    else
      if wy > -hx then return 3 else return 4 end
    end
  end
  return 0
end

-----------------------------------------------------------
-- TESTS

function test1()
  init_ball()
  game.ball.x = 56; game.ball.y = 90
  game.ball.dx = -0.2; game.ball.dy = -0.8
  game.ball.speed = 1.5
  game.bricks[(18*4)+1]=nil
  game.bricks[(18*4)+4]=nil
  game.bricks[(18*5)+1]=nil
  game.bricks[(18*5)+4]=nil
end

function test2()
  init_ball()
  game.ball.x = 56; game.ball.y = 90
  game.ball.dx = -0.2; game.ball.dy = -0.8
  game.ball.speed = 1.5
  game.bricks[(18*3)+3]=nil
  game.bricks[(18*4)+3]=nil
  game.bricks[(18*5)+3]=nil
end

function test3()
  init_ball()
  game.ball.x = 179.83; game.ball.y = 59.60
  game.ball.dx = 0.31; game.ball.dy = -0.69
  game.ball.speed = 1.86
  game.bricks[(18*5)+16]=nil
end
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

-----------------------------------------------------------
-- PADDLE

function init_paddle()
  game.paddle = {
    x = 60,
    y = 132,
    w = 20,
    h = 3,
    color = 6,
    sfx = 62,
    speed = 6,
    tostring = function(self)
      return string.format(
        "paddle { x=%.2f, y=%.2f, w=%d, h=%d, color=%d, speed=%.2f }",
        self.x, self.y, self.w, self.h, self.color, self.speed)
    end
  }
end

function move_paddle_left()
  local p = game.paddle
  p.x = math.max(p.x - p.speed, 30)
end

function move_paddle_right()
  local p = game.paddle
  p.x = math.min(p.x + p.speed, 190)
end

function move_paddle_to(x)
  local p = game.paddle
  p.x = math.min(math.max(x, 30), 190)
end

function draw_paddle()
  local p = game.paddle
  rect(p.x, p.y, p.w, p.h, p.color)
end

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

-----------------------------------------------------------
-- COLLISION

function collision_check_ball_with_bricks()
  local b = game.ball
  for k, brick in pairs(game.bricks) do
    local side =
      utils_game.rect_collision(b, brick)
    if side > 0 then
      ball_hit_brick(brick, side)
      -- remove the brick, set the score, play sound
      game.bricks[k] = nil
      game.score = game.score + brick.score
      sfx(0, brick.sfx, 8, 0)
      -- if there are no more bricks then reset the wall
      if count_bricks() == 0 then
        init_bricks()
      end
      break
    end
  end
end

function collision_check_ball_with_paddle()
  local b = game.ball
  local p = game.paddle
  if utils_game.rect_overlap(p, b) then
    -- calculate the offset of the hit on paddle
    local offset = (b.x + (b.w / 2.0))
        - (p.x + (p.w / 2.0)) -- offset = -13|0|+13
    -- set ball direction and speed, play sound
    ball_hit_paddle(offset)
    sfx(0, p.sfx, 8, 0)
  end
end

function collision_check_ball_with_border()
  local b = game.ball
  if b.x < 30 then
    b.x = 30
    b.dx = -b.dx
    sfx(0, 72, 8, 0)
  elseif b.x > 207 then
    b.x = 207
    b.dx = -b.dx
    sfx(0, 72, 8, 0)
  end
  if b.y < 17 then
    b.y = 17
    b.dy = -b.dy
    sfx(0, 62, 8, 0)
  elseif b.y > 136 then
    -- ball out of bottom screen, a live is lost
    ball_lost()
  end
end

-----------------------------------------------------------
-- MAIN

game = {
  tick = 0,
  bricks = nil,
  paddle = nil,
  ball = nil,
  score = 0,
  lives = 0,
  player = 1
}

PAL = "140c1c442434444cc64e4a4eb279384c9d4cc6484c8d8d8d"
    .. "597dcec26d408595a1449d81d2aa996dc2caa1a138deeed6"

function init()
  utils_game.set_palette_to_string(PAL)
  utils_game.set_mouse_cursor_to_spr(0x255)
  init_bricks()
  init_paddle()
end

function input_gamepad()
  if btn(2) then -- pad left
    move_paddle_left()
  end
  if btn(3) then -- pad right
    move_paddle_right()
  end
  if btn(4) then -- pad button A = key Z
    if game.ball == nil and game.lives > 0 then
      init_ball()
      sfx(0, 72, 8, 0)
    end
  end
  if btn(5) then -- pad button B = key X
    init()
    game.lives = 5
  end
end

function input_mouse()
  local x; local y; local p
  x, y, p = mouse()
  move_paddle_to(x)
  if p then
    if game.ball == nil and game.lives > 0 then
      init_ball()
      sfx(0, 72, 8, 0)
    end
  end
end

function input()
  input_gamepad()
  --input_mouse()
end

function update()
  if game.ball then
    update_ball()
    collision_check_ball_with_bricks()
    collision_check_ball_with_paddle()
    collision_check_ball_with_border()
  else
    if game.lives == 0 then
      if (game.tick % 300) == 0 then -- every 5 secs
        utils_game.change_palette_to_random()
      end
    end
  end
end

function draw_border()
  rect(20, 7, 200, 10, 7)
  rect(20, 17, 10, 115, 7)
  rect(210, 17, 10, 115, 7)
  rect(20, 132, 10, 4, 11)
  rect(210, 132, 10, 4, 6)
end

function draw()
  cls(0)
  -- header
  local text = string.format("%03d  %d  %d",
    game.score, game.lives, game.player)
  font(text, 120, -2, 0, 8, 8, true, 1)
  draw_border()
  draw_bricks()
  draw_paddle()
  if game.ball then
    draw_ball()
  end
end

function gameover()
  -- nothing to do
end

init()

--test1()
--test2()
--test3()

-- main loop
function TIC()
  game.tick = game.tick + 1
  input()
  update()
  draw()
end

