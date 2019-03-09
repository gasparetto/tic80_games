-- title:  Atari 7800 Galaga
-- author: game developer
-- desc:   short description
-- script: lua

--------------------------------------------------------------------------------
-- UTILS

is_tic80=true

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, key.." = {\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function table_deepcopy (orig)
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

function log (message)
  if is_tic80 then trace(message) else print(message) end
end

--------------------------------------------------------------------------------
-- GAME MODE -> DEMO

function init_grid ()
  local w=17; local h=12
  local xs=w*2; local xm=w*4 -- offset 2 cells, max x mov 4 cells
  local x0=2+xs -- 17 w * 14 cells = 238 px
  grid={x=xs,xd=1,xs=xs,xm=xm,e=0,ed=-0.2,em=5,cells_w=w,cells_h=h,cells={}}
  for y=1,5 do
    for x=1,10 do
      grid.cells[x..","..y]={x=x0+(x-1)*w,y=(y-1)*h}
    end
  end
end

function init_mode_demo ()
  tick=0
  game_mode=GM_DEMO
  -- init_ivds()
  init_grid()
  -- init_plyr()
end

function update_grid ()
  local t=100
  if tick>t and grid.x==grid.xs then
    -- expand and contract grid on x axis
    if grid.e<0 or grid.e>grid.em then grid.ed=-grid.ed end
    grid.e=grid.e+grid.ed
    for y=1,5 do
      for x=1,10 do
        local cell=grid.cells[x..","..y]
        local xd=x-5.5 -- -4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5
        cell.x=cell.x+(xd*grid.ed)
      end
    end
  else
    -- move grid on x axis
    if grid.x==0 or grid.x==grid.xm then grid.xd=-grid.xd end
    grid.x=grid.x+grid.xd
    for _,cell in pairs(grid.cells) do
      cell.x=cell.x+grid.xd
    end
  end
end

function update_mode_demo ()
  -- for _,invd in pairs(ivds) do
  --   update_invader(invd,tick)
  -- end
  if (tick%4)==0 then
    update_grid()
  end
  -- update_plyr()
end

function test_draw_grid ()
  for _,cell in pairs(grid.cells) do
    rectb(cell.x,cell.y,14,10,7)
    -- if k=="5,2" or k=="5,3" or k=="6,2" or k=="6,3" then rectb(v.x,v.y,14,10,6) end
  end
end

function draw_mode_demo ()
  --ships
  -- spr(plyr.id,0,128,0,1,0,0,2,1)
  -- spr(plyr.id,18,128,0,1,0,0,2,1)
  -- spr(plyr.id,36,128,0,1,0,0,2,1)
  -- print("READY",104,66,2)
  -- print("1",224,126,10,true,2)
  --ivds
  -- for _,invd in pairs(ivds) do
  --   draw_invd(invd)
  -- end
  test_draw_grid()
  --plyr
  -- draw_plyr()
end

--------------------------------------------------------------------------------
-- GAME MODE -> INGAME

function init_mode_ingame ()
  tick=0
  game_mode=GM_INGAME

  --todo
end

function update_mode_ingame ()
  --todo
end

function draw_mode_ingame ()
  --todo
end

--------------------------------------------------------------------------------
-- MAIN

function init ()
  tick=0
  --game mode
  GM_ATTRACT,GM_DEMO,GM_INGAME=0,1,2
  --init
  -- init_stars()
  --init_mode_attract()
  init_mode_demo()
end

init()

function input ()
  --todo
end

function update ()
  if game_mode==GM_ATTRACT then
    update_mode_attract()
  elseif game_mode==GM_DEMO then
    update_mode_demo()
  elseif game_mode==GM_INGAME then
    update_mode_ingame()
  end
end

function draw ()
  cls(0)
  -- draw_stars()
  if game_mode==GM_ATTRACT then
    draw_mode_attract()
  elseif game_mode==GM_DEMO then
    draw_mode_demo()
  elseif game_mode==GM_INGAME then
    draw_mode_ingame()
  end
end

function TIC ()
  tick=tick+1
  input()
  update()
  draw()
end

--------------------------------------------------------------------------------
