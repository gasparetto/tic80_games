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

