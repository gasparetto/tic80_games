-- title:  a78_galaga
-- author: game developer
-- desc:   Atari 7800 Galaga
-- script: lua

--------------------------------------------------------------------------------
-- GLOBAL VARS
is_tic80 = true
tick = 0
-- game modes
GM_ATTRACT, GM_DEMO, GM_INGAME = 0, 1, 2
game_mode = GM_ATTRACT
-- invader states
IS_NONE, IS_PATH1, IS_FOLW, IS_CELL, IS_PATH2, IS_EXPL = 0, 1, 2, 3, 4, 5
-- global vars
ivds = null
invd_exps = null
plyr = null
grid = null
stars_xy = null
blinks_spr = null
blinks_pos = null
blink = null

--------------------------------------------------------------------------------
-- UTILS
function table_print(tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs(tt) do
      table.insert(sb, string.rep(" ", indent)) -- indent it
      if type(value) == "table" and not done[value] then
        done[value] = true
        table.insert(sb, key .. " = {\n");
        table.insert(sb, table_print(value, indent + 2, done))
        table.insert(sb, string.rep(" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format("%s = \"%s\"\n", tostring(key),
          tostring(value)))
      end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function table_deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[table_deepcopy(orig_key)] = table_deepcopy(orig_value)
    end
    setmetatable(copy, table_deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function log(message)
  if is_tic80 then trace(message) else print(message) end
end

--------------------------------------------------------------------------------
-- COMMON MATH
function linear_distance(xa, ya, xb, yb)
  return math.sqrt((xa - xb) ^ 2 + (ya - yb) ^ 2)
end

function linear_interpolation(xa, ya, xb, yb, ab, n)
  local f = n / ab
  local xn = xa + (f * (xb - xa))
  local yn = ya + (f * (yb - ya))
  return xn, yn
end

orientation_f = 8 / (math.pi * 2)

function linear_orientation(xa, ya, xb, yb)
  local o = -math.atan(ya - yb, xb - xa) -- y is reversed in screen coords
  if o < 0 then
    o = o + math.pi * 2
  elseif o >= math.pi * 2 then
    o = o - math.pi * 2
  end
  o = math.floor(o * orientation_f)
  return o
end

--------------------------------------------------------------------------------
-- PATH
function path_init(path)
  local x0; local y0; local t0
  for i, step in ipairs(path.steps) do
    if i == 1 then
      step.t = path.t;
      x0 = step.x; y0 = step.y; t0 = step.t
    else
      if not step.o then
        if path.o then
          step.o = path.o
        else
          step.o = linear_orientation(x0, y0, step.x, step.y)
        end
      end
      step.s = linear_distance(x0, y0, step.x, step.y)
      if not step.v then step.v = path.v end
      if step.t and step.t > t0 then
        step.v = step.s / (step.t - t0)
      else
        step.t = t0 + (step.s / step.v)
      end
      -- log("s:"..math.floor(step.s).." "..x0..","..y0.."=>"..step.x..","..step.y
      --   .." t:"..math.floor(step.t-t0).." "..math.floor(t0).."=>"..math.floor(step.t)
      --   .." v:"..string.format("%0.3f",step.v))
      x0 = step.x; y0 = step.y; t0 = step.t
    end
  end
end

function path_update(path, t)
  -- log("path_update t:"..t.." path.t:"..path.t)
  if t >= path.steps[1].t and t < path.steps[#path.steps].t then
    for i, step in ipairs(path.steps) do
      if step.t > t then
        -- log("path_update t:"..t.." step.t:"..step.t)
        local x0 = path.x; local y0 = path.y; local t0 = path.t;
        if i > 1 then
          local prev = path.steps[i - 1]
          x0 = prev.x; y0 = prev.y; t0 = prev.t;
        end
        local s = step.v * (t - t0)
        local x; local y
        x, y = linear_interpolation(x0, y0, step.x, step.y, step.s, s)
        return x, y, step.o
      end
    end
  end
  return nil, nil, nil
end

function path_draw(path)
  local x0; local y0
  for i, step in ipairs(path.steps) do
    if i > 1 then
      line(x0, y0, step.x, step.y, 7)
    end
    x0 = step.x; y0 = step.y
  end
end

function path_translate(path, x, y)
  for i, step in ipairs(path.steps) do
    step.x = step.x + x; step.y = step.y + y
  end
  return path
end

function path_flip(path, is_x, is_y)
  for i, step in ipairs(path.steps) do
    if is_x then step.x = 240 - step.x end
    if is_y then step.y = 136 - step.y end
  end
  return path
end

function path_follow(xa, ya, xb, yb, v)
  -- log("xa:"..xa.." ya:"..ya.." xb:"..xb.." yb:"..yb.." v:"..v)
  if math.abs(xa - xb) < 1 and math.abs(ya - yb) < 1 then
    return xb, yb
  end
  local x = 0; local y = 0; local s
  s = linear_distance(xa, ya, xb, yb)
  x, y = linear_interpolation(xa, ya, xb, yb, s, v)
  -- log("x:"..x.." y:"..y)
  return x, y
  -- return round(x),round(y)
end

--------------------------------------------------------------------------------
-- GAME MODE -> DEMO

function init_ivds()
  -- define paths
  local path1_r = {
    t = 0,
    v = 1,
    steps = {
      { x = 110, y = 0 }, { x = 110, y = 16 }, { x = 205, y = 40 },
      { x = 216, y = 46 }, { x = 220, y = 55 }, { x = 216, y = 64 },
      { x = 205, y = 70 }, { x = 158, y = 70 }, { x = 148, y = 67 },
      { x = 139, y = 61 }, { x = 134, y = 53 }
    }
  }
  local path1_l = path_flip(table_deepcopy(path1_r), true, false)
  local path2_l = {
    t = 0,
    v = 1,
    steps = {
      { x = 0, y = 110 }, { x = 63, y = 95 }, { x = 105, y = 85 },
      { x = 105, y = 80 }, { x = 90, y = 67 }, { x = 76, y = 67 },
      { x = 59, y = 74 }, { x = 62, y = 85 }, { x = 80, y = 90 },
      { x = 100, y = 90 }, { x = 105, y = 80 }, { x = 110, y = 70 }
    }
  }
  local path2_r = path_flip(table_deepcopy(path2_l), true, false)
  -- init paths
  path_init(path1_r)
  path_init(path1_l)
  path_init(path2_l)
  path_init(path2_r)
  -- tw = starting time of waves
  local tw1 = tick + 180
  local tw2 = tick + 600
  local tw3 = tick + 1100
  local tw4 = tick + 1600
  local tw5 = tick + 2100
  local td = 25
  -- invaders list
  ivds = {
    -- invaders wave 1: top-right red and top-left blue ships
    { id = 2, p1 = path1_r, p1_t = (tw1 + td * 0), c = "5,2" },
    { id = 2, p1 = path1_r, p1_t = (tw1 + td * 1), c = "5,3" },
    { id = 2, p1 = path1_r, p1_t = (tw1 + td * 2), c = "6,2" },
    { id = 2, p1 = path1_r, p1_t = (tw1 + td * 3), c = "6,3" },
    { id = 4, p1 = path1_l, p1_t = (tw1 + td * 0), c = "5,4" },
    { id = 4, p1 = path1_l, p1_t = (tw1 + td * 1), c = "5,5" },
    { id = 4, p1 = path1_l, p1_t = (tw1 + td * 2), c = "6,4" },
    { id = 4, p1 = path1_l, p1_t = (tw1 + td * 3), c = "6,5" },
    -- invaders wave 2: bottom-left green and red ships
    { id = 6, p1 = path2_l, p1_t = (tw2 + td * 0), c = "4,1" },
    { id = 2, p1 = path2_l, p1_t = (tw2 + td * 1), c = "4,2" },
    { id = 6, p1 = path2_l, p1_t = (tw2 + td * 2), c = "5,1" },
    { id = 2, p1 = path2_l, p1_t = (tw2 + td * 3), c = "7,2" },
    { id = 6, p1 = path2_l, p1_t = (tw2 + td * 4), c = "6,1" },
    { id = 2, p1 = path2_l, p1_t = (tw2 + td * 5), c = "4,3" },
    { id = 6, p1 = path2_l, p1_t = (tw2 + td * 6), c = "7,1" },
    { id = 2, p1 = path2_l, p1_t = (tw2 + td * 7), c = "7,3" },
    -- invaders wave 3: bottom-right red ships
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 0), c = "9,2" },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 1), c = "8,2" },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 2), c = "8,3" },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 3), c = "9,3" },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 4), c = "2,2" },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 5), c = "3,2" },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 6), c = "3,3" },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 7), c = "2,3" },
    -- invaders wave 4: top-left blue ships
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 0), c = "8,4" },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 1), c = "7,4" },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 2), c = "8,5" },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 3), c = "7,5" },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 4), c = "4,4" },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 5), c = "3,4" },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 6), c = "4,5" },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 7), c = "3,5" },
    -- invaders wave 5: top-right blue ships
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 0), c = "1,4" },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 1), c = "2,4" },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 2), c = "1,5" },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 3), c = "2,5" },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 4), c = "9,4" },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 5), c = "10,4" },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 6), c = "9,5" },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 7), c = "10,5" },
  }
  -- invaders common properties
  for _, invd in pairs(ivds) do
    invd.s = IS_NONE
  end
  -- invaders explosions
  invd_exps = {}
  -- log(table_print(invaders[#invaders]))
end

function init_plyr()
  local y = 116
  local rand_x = {
    72, 140, 100, 120, 40, 100, 80, 180, 80, 120, 100, 116, 72, 140, 100, 120,
    40, 100, 80, 180, 80, 120, 100, 116, 72, 140, 100, 120, 40, 100, 80, 180,
    80, 120, 100, 116, 72, 140, 100, 120, 40, 100, 80, 180, 80, 120, 100, 116
  }
  local steps = {}
  for _, x in pairs(rand_x) do
    table.insert(steps, { x = x, y = y })
  end
  local path = {
    x = 116,
    y = 116,
    t = 0,
    v = 1.5,
    o = 6,
    steps = steps
  }
  path_init(path)
  plyr = { id = 0, x = 116, y = y, path = path, shots = {} }
end

function init_mode_demo()
  tick = 0
  game_mode = GM_DEMO
  init_ivds()
  init_grid()
  init_plyr()
end

function update_plyr_shots()
  for ks, shot in ipairs(plyr.shots) do
    -- check for collision
    for ki, invd in pairs(ivds) do
      if invd.x and invd.y then
        local xa = invd.x; local ya = invd.y
        local xb = xa + 14; local yb = ya + 10
        if shot.x >= xa and shot.x <= xb and shot.y >= ya and shot.y <= yb then
          table.insert(invd_exps, { x = invd.x, y = invd.y, t = 0 })
          table.remove(ivds, ki)
          table.remove(plyr.shots, ks)
          --player.score=player.score+v.val
          break
        end
      end
    end
    -- update y pos
    shot.y = shot.y - 2
    if shot.y < 0 then table.remove(plyr.shots, ks) end
  end
end

function update_invd(invd, t)
  if invd.s == IS_NONE then
    if t > invd.p1_t then invd.s = IS_PATH1 end
  elseif invd.s == IS_PATH1 then
    local xn; local yn; local on
    xn, yn, on = path_update(invd.p1, t - invd.p1_t)
    if xn and yn and on then
      -- log("xn:"..(xn or "nil").." yn:"..(yn or "nil").." on:"..(on or "nil"))
      invd.x = xn - 4; invd.y = yn - 4; invd.o = on
    end
    if t > (invd.p1_t + invd.p1.steps[#invd.p1.steps].t) then
      invd.s = IS_FOLW
    end
  elseif invd.s == IS_FOLW then
    local cell = grid.cells[invd.c]
    local xn; local yn
    xn, yn = path_follow(invd.x, invd.y, cell.x, cell.y, 0.75)
    invd.x = xn; invd.y = yn; invd.o = 6
    if math.ceil(xn) == cell.x and math.ceil(yn) == cell.y then
      invd.s = IS_CELL
    end
  elseif invd.s == IS_CELL then
    local cell = grid.cells[invd.c]
    invd.x = cell.x; invd.y = cell.y; invd.o = 6
  elseif invd.s == IS_PATH2 then
    -- todo
  end
end

function update_plyr()
  -- player path
  if tick >= plyr.path.t and tick < plyr.path.steps[#plyr.path.steps].t then
    local xn; local yn; local on
    xn, yn, on = path_update(plyr.path, tick)
    plyr.x = xn; plyr.y = yn
  end
  -- player shots
  if (tick % 120) == 0 and tick < 1500 then -- 1 sec
    table.insert(plyr.shots, { x = plyr.x + 6, y = plyr.y - 4 })
  end
  update_plyr_shots()
end

function update_mode_demo()
  -- invaders
  for _, invd in pairs(ivds) do
    update_invd(invd, tick)
  end
  if (tick % 4) == 0 then
    update_grid()
  end
  -- player
  update_plyr()
end

function get_spr_id_offset_and_flip(orientation)
  -- 0=No Flip 1=Flip horizontally 2=Flip vertically 3=Flip both vertically
  -- and horizontally
  if orientation == 0 then return 96, 0
  elseif orientation == 1 then return 64, 2
  elseif orientation == 2 then return 32, 2
  elseif orientation == 3 then return 64, 3
  elseif orientation == 4 then return 96, 1
  elseif orientation == 5 then return 64, 1
  elseif orientation == 6 then
    if (tick % 40 / 20) == 0 then return 0, 0 else return 32, 0 end
  elseif orientation == 7 then return 64, 0
  end
end

function draw_invd_expl(k, expl)
  -- 4 frames x sprite, 2x2, ids: 10,42,74,106,138,170,202
  local id = 10 + ((expl.t / 4) * 32)
  spr(id, expl.x, expl.y, 0, 1, 0, 0, 2, 2);
  expl.t = expl.t + 1
  if expl.t > 30 then table.remove(invd_exps, k) end
end

function draw_invd(invd)
  if invd.x and invd.y and invd.o then
    local id_offset = 0
    local flip = 0
    id_offset, flip = get_spr_id_offset_and_flip(invd.o)
    spr(invd.id + id_offset, invd.x, invd.y, 0, 1, flip, 0, 2, 2)
  end
end

function draw_plyr()
  spr(plyr.id, plyr.x, plyr.y, 0, 1, 0, 0, 2, 1)
  for i, shot in ipairs(plyr.shots) do
    spr(32, shot.x, shot.y, 0)
  end
end

function draw_mode_demo()
  -- ships
  spr(plyr.id, 0, 128, 0, 1, 0, 0, 2, 1)
  spr(plyr.id, 18, 128, 0, 1, 0, 0, 2, 1)
  spr(plyr.id, 36, 128, 0, 1, 0, 0, 2, 1)
  if tick < 60 then print("READY", 104, 66, 2) end
  print("1", 224, 126, 10, true, 2)
  -- invaders
  for _, invd in pairs(ivds) do
    draw_invd(invd)
  end
  -- invaders explosions
  for k, expl in pairs(invd_exps) do
    draw_invd_expl(k, expl)
  end
  -- draw_grid()
  -- player
  draw_plyr()
end

--------------------------------------------------------------------------------
-- GAME MODE -> INGAME
function init_mode_ingame()
  tick = 0
  game_mode = GM_INGAME

  --todo
end

function input_mode_ingame()
  if btn(2) then -- pad left (left arrow)
    plyr.x = plyr.x - 1
  end
  if btn(3) then -- pad right (right arrow)
    plyr.x = plyr.x + 1
  end
  if btnp(4) then -- button A (key Z)
    table.insert(plyr.shots, { x = plyr.x + 6, y = plyr.y - 4 })
  end
end

function update_mode_ingame()
  --todo
end

function draw_mode_ingame()
  --todo
end

--------------------------------------------------------------------------------
-- GAME MODE -> ATTRACT
function init_mode_attract()
  tick = 0
  game_mode = GM_ATTRACT

  blinks_spr = {
    { s = 384, w = 1, h = 1, dx = -3, dy = -1 },
    { s = 385, w = 2, h = 1, dx = -5, dy = -2 },
    { s = 387, w = 2, h = 1, dx = -7, dy = -3 },
    { s = 389, w = 3, h = 2, dx = -9, dy = -5 },
    { s = 392, w = 4, h = 2, dx = -13, dy = -7 },
    { s = 396, w = 4, h = 2, dx = -13, dy = -7 },
    { s = 392, w = 4, h = 2, dx = -13, dy = -7 },
    { s = 389, w = 3, h = 2, dx = -9, dy = -5 },
    { s = 387, w = 2, h = 1, dx = -7, dy = -3 },
    { s = 385, w = 2, h = 1, dx = -5, dy = -2 },
    { s = 384, w = 1, h = 1, dx = -3, dy = -1 }
  }
  blinks_pos = {
    { x = 130, y = 52 }, { x = 150, y = 74 }, { x = 144, y = 60 },
    { x = 70, y = 64 }, { x = 130, y = 52 }, { x = 110, y = 48 },
    { x = 98, y = 60 }, { x = 52, y = 48 }, { x = 194, y = 54 },
    { x = 150, y = 74 }, { x = 144, y = 60 }, { x = 70, y = 64 },
    { x = 130, y = 52 }, { x = 110, y = 48 }, { x = 98, y = 60 },
    { x = 52, y = 48 }
  }
  blink = { pos = 1, t = tick }
end

function update_mode_attract()
  blink.t = blink.t + 1
  if blink.t == 34 then
    blink.t = 1
    blink.pos = blink.pos + 1
    if blink.pos > #blinks_pos then init_mode_demo() end
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
  local bspr = blinks_spr[math.ceil(blink.t / 3)]
  local bpos = blinks_pos[blink.pos]
  spr(bspr.s, bpos.x + bspr.dx, bpos.y + bspr.dy, 0, 1, 0, 0, bspr.w, bspr.h)
end

--------------------------------------------------------------------------------
-- GRID
function init_grid()
  local w = 17; local h = 12
  local xs = w * 2; local xm = w * 4 -- offset 2 cells, max x mov 4 cells
  local x0 = 2 + xs -- 17 w * 14 cells = 238 px
  grid = { x = xs, xd = 1, xs = xs, xm = xm, e = 0, ed = -0.2, em = 5,
    cells_w = w, cells_h = h, cells = {} }
  for y = 1, 5 do
    for x = 1, 10 do
      grid.cells[x .. "," .. y] = { x = x0 + (x - 1) * w, y = (y - 1) * h }
    end
  end
end

function update_grid()
  local t = 2500
  if tick > t and grid.x == grid.xs then
    -- expand and contract grid on x axis
    if grid.e < 0 or grid.e > grid.em then grid.ed = -grid.ed end
    grid.e = grid.e + grid.ed
    for y = 1, 5 do
      for x = 1, 10 do
        local cell = grid.cells[x .. "," .. y]
        local xd = x - 5.5 -- -4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5
        cell.x = cell.x + (xd * grid.ed)
      end
    end
  else
    -- move grid on x axis
    if grid.x == 0 or grid.x == grid.xm then grid.xd = -grid.xd end
    grid.x = grid.x + grid.xd
    for _, cell in pairs(grid.cells) do
      cell.x = cell.x + grid.xd
    end
  end
end

function draw_grid()
  for _, cell in pairs(grid.cells) do
    rectb(cell.x, cell.y, 14, 10, 7)
    -- if k=="5,2" or k=="5,3" then rectb(cell.x,cell.y,14,10,6) end
  end
end

--------------------------------------------------------------------------------
-- STARS

function init_stars()
  stars_xy = {
    110, 19, 108, 46, 139, 217, 164, 111, 79, 257, 132, 82, 206, 50, 178, 47,
    210, 389, 52, 218, 130, 340, 201, 95, 72, 332, 107, 170, 146, 376, 149, 26,
    237, 28, 43, 226, 147, 344, 202, 374, 120, 156, 33, 142, 123, 351, 114, 154,
    203, 275, 223, 155, 129, 305, 150, 333, 142, 28, 62, 79, 2, 350, 63, 397,
    226, 175, 134, 221, 71, 159, 117, 317, 189, 250, 36, 119, 120, 248, 163,
    138, 74, 243, 176, 337, 89, 142, 162, 384, 102, 371, 38, 172, 192, 167, 101,
    297, 205, 391, 70, 58, 90, 311, 225, 63, 96, 33, 109, 360, 169, 53, 58, 3,
    177, 390, 204, 42, 79, 208, 16, 301, 107, 88, 44, 99, 153, 240, 237, 194,
    139, 112, 151, 379, 14, 226, 25, 182, 156, 222, 85, 139, 165, 238, 85, 169,
    136, 81, 127, 358, 173, 236, 155, 67, 194, 330, 99, 177, 102, 160, 223, 400,
    163, 222, 227, 293, 29, 20, 45, 306, 145, 215, 27, 115, 32, 187, 170, 279,
    161, 94, 142, 155, 198, 94, 133, 253, 14, 386, 18, 192, 87, 400, 115, 16,
    133, 169, 185, 269, 113, 382, 105, 29, 118, 219, 86, 249, 4, 27, 77, 272,
    73, 364, 16, 50, 34, 248, 182, 79, 140, 332, 163, 378, 199, 62, 236, 151,
    139, 300, 12, 19, 169, 194, 29, 78, 8, 191, 197, 18, 131, 54, 174, 338, 11,
    316, 233, 74, 99, 290, 92, 397, 133, 23, 225, 151, 51, 367, 181, 314, 160,
    321, 200, 148, 69, 380, 136, 126, 102, 153, 86, 387, 124, 33, 195, 224, 209,
    311, 178, 112, 120, 49, 65, 20, 43, 82, 102, 155, 29, 72, 42, 315, 236, 1,
    38, 106, 228, 288, 139, 150, 25, 375, 82, 247
  }
end

function draw_stars()
  for i = 1, #stars_xy / 2, 2 do
    pix(stars_xy[i], (stars_xy[i + 1] + (tick / 5)) % 400, 8)
  end
end

--------------------------------------------------------------------------------
-- MAIN
function init()
  init_stars()
--  init_mode_attract()
--  init_mode_demo()
  init_mode_ingame()
end

init()

function input()
  -- todo
end

function update()
  if game_mode == GM_ATTRACT then
    update_mode_attract()
  elseif game_mode == GM_DEMO then
    update_mode_demo()
  elseif game_mode == GM_INGAME then
    update_mode_ingame()
  end
end

function draw()
  cls(0)
  draw_stars()
  if game_mode == GM_ATTRACT then
    draw_mode_attract()
  elseif game_mode == GM_DEMO then
    draw_mode_demo()
  elseif game_mode == GM_INGAME then
    draw_mode_ingame()
  end
end

function TIC()
  tick = tick + 1
  input()
  update()
  draw()
end

--------------------------------------------------------------------------------
