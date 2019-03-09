-----------------------------------------------------------
-- INVADERS

-- invader states
IS_NONE, IS_PATH1, IS_FOLW, IS_CELL, IS_PATH2, IS_EXPL
  = 0, 1, 2, 3, 4, 5
local invaders
local invaders_explosions

function get_invader_score(invd)
  if invd.s == IS_PATH1 or invd.s == IS_FOLW then
    if invd.id == 4 then return 100 end
    if invd.id == 2 then return 120 end
  end
  if invd.s == IS_CELL then
    if invd.id == 4 then return 50 end
    if invd.id == 2 then return 80 end
  end
  return 0
end

function get_invader_k_from_collision(x, y)
  for k, invd in pairs(invaders) do
    if invd.x and invd.y then
      local xa = invd.x; local ya = invd.y
      local xb = xa + 14; local yb = ya + 10
      if x >= xa and x <= xb and y >= ya and y <= yb then
        return k
      end
    end
  end
  return nil
end

function explode_invader_k_and_get_score(k)
  local invd = invaders[k]
  -- green invd turn into cyan
  if invd.id == 6 then
    invd.id = 8
    return 0
  end
  table.remove(invaders, k)
  table.insert(invaders_explosions, {
    x = invd.x,
    y = invd.y,
    t = 0
  })
  return get_invader_score(invd)
end

function init_invaders()
  -- define paths
  local path1_r = {
    t = 0,
    v = 1.5,
    steps = {
      { x = 110, y = 0 }, { x = 110, y = 16 },
      { x = 205, y = 40 }, { x = 216, y = 46 },
      { x = 220, y = 55 }, { x = 216, y = 64 },
      { x = 205, y = 70 }, { x = 158, y = 70 },
      { x = 148, y = 67 }, { x = 139, y = 61 },
      { x = 134, y = 53 }
    }
  }
  local path1_l = path2d.flip(
    utils_lang.table_deepcopy(path1_r), true, false)
  local path2_l = {
    t = 0,
    v = 1.5,
    steps = {
      { x = 0, y = 110 }, { x = 63, y = 95 },
      { x = 105, y = 85 }, { x = 105, y = 80 },
      { x = 90, y = 67 }, { x = 76, y = 67 },
      { x = 59, y = 74 }, { x = 62, y = 85 },
      { x = 80, y = 90 }, { x = 100, y = 90 },
      { x = 105, y = 80 }, { x = 110, y = 70 }
    }
  }
  local path2_r = path2d.flip(
    utils_lang.table_deepcopy(path2_l), true, false)
  -- init paths
  path2d.init(path1_r)
  path2d.init(path1_l)
  path2d.init(path2_l)
  path2d.init(path2_r)
  -- tw = starting time of waves
  local tw1 = game.tick + 180
  local tw2 = game.tick + 600
  local tw3 = game.tick + 1100
  local tw4 = game.tick + 1600
  local tw5 = game.tick + 2100
  local td = 25
  -- invaders list
  invaders = {
    -- invaders wave 1: top-right red and top-left blue ships
    { id = 2, p1 = path1_r, p1_t = (tw1 + td * 0), cx = 5, cy = 2 },
    { id = 2, p1 = path1_r, p1_t = (tw1 + td * 1), cx = 5, cy = 3 },
    { id = 2, p1 = path1_r, p1_t = (tw1 + td * 2), cx = 6, cy = 2 },
    { id = 2, p1 = path1_r, p1_t = (tw1 + td * 3), cx = 6, cy = 3 },
    { id = 4, p1 = path1_l, p1_t = (tw1 + td * 0), cx = 5, cy = 4 },
    { id = 4, p1 = path1_l, p1_t = (tw1 + td * 1), cx = 5, cy = 5 },
    { id = 4, p1 = path1_l, p1_t = (tw1 + td * 2), cx = 6, cy = 4 },
    { id = 4, p1 = path1_l, p1_t = (tw1 + td * 3), cx = 6, cy = 5 },
    -- invaders wave 2: bottom-left green and red ships
    { id = 6, p1 = path2_l, p1_t = (tw2 + td * 0), cx = 4, cy = 1 },
    { id = 2, p1 = path2_l, p1_t = (tw2 + td * 1), cx = 4, cy = 2 },
    { id = 6, p1 = path2_l, p1_t = (tw2 + td * 2), cx = 5, cy = 1 },
    { id = 2, p1 = path2_l, p1_t = (tw2 + td * 3), cx = 7, cy = 2 },
    { id = 6, p1 = path2_l, p1_t = (tw2 + td * 4), cx = 6, cy = 1 },
    { id = 2, p1 = path2_l, p1_t = (tw2 + td * 5), cx = 4, cy = 3 },
    { id = 6, p1 = path2_l, p1_t = (tw2 + td * 6), cx = 7, cy = 1 },
    { id = 2, p1 = path2_l, p1_t = (tw2 + td * 7), cx = 7, cy = 3 },
    -- invaders wave 3: bottom-right red ships
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 0), cx = 9, cy = 2 },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 1), cx = 8, cy = 2 },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 2), cx = 8, cy = 3 },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 3), cx = 9, cy = 3 },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 4), cx = 2, cy = 2 },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 5), cx = 3, cy = 2 },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 6), cx = 3, cy = 3 },
    { id = 2, p1 = path2_r, p1_t = (tw3 + td * 7), cx = 2, cy = 3 },
    -- invaders wave 4: top-left blue ships
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 0), cx = 8, cy = 4 },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 1), cx = 7, cy = 4 },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 2), cx = 8, cy = 5 },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 3), cx = 7, cy = 5 },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 4), cx = 4, cy = 4 },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 5), cx = 3, cy = 4 },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 6), cx = 4, cy = 5 },
    { id = 4, p1 = path1_l, p1_t = (tw4 + td * 7), cx = 3, cy = 5 },
    -- invaders wave 5: top-right blue ships
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 0), cx = 1, cy = 4 },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 1), cx = 2, cy = 4 },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 2), cx = 1, cy = 5 },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 3), cx = 2, cy = 5 },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 4), cx = 9, cy = 4 },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 5), cx = 10, cy = 4 },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 6), cx = 9, cy = 5 },
    { id = 4, p1 = path1_r, p1_t = (tw5 + td * 7), cx = 10, cy = 5 },
  }
  -- invaders common properties
  for _, invader in pairs(invaders) do
    invader.s = IS_NONE
  end
  -- invaders explosions
  invaders_explosions = {}
end

function update_invader(invd, t)
  if invd.s == IS_NONE then
    if t > invd.p1_t then invd.s = IS_PATH1 end
  elseif invd.s == IS_PATH1 then
    local xn; local yn; local on
    xn, yn, on = path2d.update(invd.p1, t - invd.p1_t)
    if xn and yn and on then
      invd.x = xn - 4; invd.y = yn - 4; invd.o = on
    end
    if t > (invd.p1_t
        + invd.p1.steps[#invd.p1.steps].t) then
      invd.s = IS_FOLW
    end
  elseif invd.s == IS_FOLW then
    local cell_x; local cell_y
    cell_x, cell_y = get_x_y_cell_coords(invd.cx, invd.cy)
    local xn; local yn
    xn, yn = path2d.follow(invd.x, invd.y,
      cell_x, cell_y, 1)
    invd.x = xn; invd.y = yn; invd.o = 6
    if math.ceil(xn) == cell_x
        and math.ceil(yn) == cell_y then
      invd.s = IS_CELL
    end
  elseif invd.s == IS_CELL then
    invd.x, invd.y = get_x_y_cell_coords(invd.cx, invd.cy)
    invd.o = 6
  elseif invd.s == IS_PATH2 then
    -- todo
  end
end

function update_invaders()
  for _, invader in pairs(invaders) do
    update_invader(invader, game.tick)
  end
end

function get_spr_id_offset_and_flip(orientation)
  -- 0=No Flip 1=Flip horizontally 2=Flip vertically
  -- 3=Flip both vertically and horizontally
  if orientation == 0 then return 96, 0
  elseif orientation == 1 then return 64, 2
  elseif orientation == 2 then return 32, 2
  elseif orientation == 3 then return 64, 3
  elseif orientation == 4 then return 96, 1
  elseif orientation == 5 then return 64, 1
  elseif orientation == 6 then
    if math.floor(game.tick % 40 / 20) == 0 then
      return 0, 0
    else
      return 32, 0
    end
  elseif orientation == 7 then return 64, 0
  end
end

function draw_invader_explosion(k, expl)
  -- 4 frames x sprite, 2x2, ids: 10,42,74,106,138,170,202
  local id = 10 + (math.floor(expl.t / 4) * 32)
  spr(id, expl.x, expl.y, 0, 1, 0, 0, 2, 2);
  expl.t = expl.t + 1
  if expl.t > 30 then
    table.remove(invaders_explosions, k)
  end
end

function draw_invader(invd)
  if invd.x and invd.y and invd.o then
    local id_offset; local flip
    id_offset, flip = get_spr_id_offset_and_flip(invd.o)
    spr(invd.id + id_offset, invd.x, invd.y, 0, 1, flip,
      0, 2, 2)
  end
end

function draw_invaders()
  for _, invader in pairs(invaders) do
    draw_invader(invader)
  end
  for k, explosion in pairs(invaders_explosions) do
    draw_invader_explosion(k, explosion)
  end
  --print("1", 224, 126, 10, true, 2)
end

