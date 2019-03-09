-----------------------------------------------------------
-- GAME MODE -> ATTRACT

local blinks_spr
local blinks_pos
local blink

function init_mode_attract()
  trace("Init attract game mode")
  game.tick = 0
  game.mode = GM_ATTRACT

  blinks_spr = {
    {s = 384, w = 1, h = 1, dx = -3, dy = -1 },
    {s = 385, w = 2, h = 1, dx = -5, dy = -2 },
    {s = 387, w = 2, h = 1, dx = -7, dy = -3 },
    {s = 389, w = 3, h = 2, dx = -9, dy = -5 },
    {s = 392, w = 4, h = 2, dx = -13, dy = -7 },
    {s = 396, w = 4, h = 2, dx = -13, dy = -7 },
    {s = 392, w = 4, h = 2, dx = -13, dy = -7 },
    {s = 389, w = 3, h = 2, dx = -9, dy = -5 },
    {s = 387, w = 2, h = 1, dx = -7, dy = -3 },
    {s = 385, w = 2, h = 1, dx = -5, dy = -2 },
    {s = 384, w = 1, h = 1, dx = -3, dy = -1 }
  }
  blinks_pos = {
    { x = 130, y = 52 }, { x = 150, y = 74 },
    { x = 144, y = 60 }, { x = 70, y = 64 },
    { x = 130, y = 52 }, { x = 110, y = 48 },
    { x = 98, y = 60 }, { x = 52, y = 48 },
    { x = 194, y = 54 }, { x = 150, y = 74 },
    { x = 144, y = 60 }, { x = 70, y = 64 },
    { x = 130, y = 52 }, { x = 110, y = 48 },
    { x = 98, y = 60 }, { x = 52, y = 48 }
  }
  blink = { pos = 1, t = game.tick }
end

function input_mode_attract()
  if btn(4) then -- button A = key Z
    init_mode_ingame()
  end
end

function update_mode_attract()
  blink.t = blink.t + 1
  if blink.t == 34 then
    blink.t = 1
    blink.pos = blink.pos + 1
    if blink.pos > #blinks_pos then
      init_mode_demo()
    end
  end
end

function draw_mode_attract()
  -- logo
  spr(256, 20, 48, 0, 1, 0, 0, 10, 3)
  spr(266, 100, 48, 0, 1, 0, 0, 6, 5)
  spr(304, 148, 48, 0, 1, 0, 0, 9, 5)
  -- copyright
  print("2018", 116, 75, 8)
  print("TIC-80", 105, 82, 8)
  -- blinks
  local s = blinks_spr[math.ceil(blink.t / 3)]
  local p = blinks_pos[blink.pos]
  spr(s.s, p.x + s.dx, p.y + s.dy, 0, 1, 0, 0, s.w, s.h)
end

