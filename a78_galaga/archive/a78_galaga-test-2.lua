-- title:  Atari 7800 Galaga
-- author: game developer
-- desc:   short description
-- script: lua

-- $ cd ~/Projects/Games/tic80/a78_galaga
-- $ tic80 a78_galaga.tic -code a78_galaga-test-2.lua

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
-- COMMON MATH

function linear_distance (xa, ya, xb, yb)
  return math.sqrt((xa-xb)^2+(ya-yb)^2)
end

function linear_interpolation (xa, ya, xb, yb, ab, n)
  local f=n/ab
  local xn=xa+(f*(xb-xa))
  local yn=ya+(f*(yb-ya))
  return xn,yn
end

orientation_f=8/(math.pi*2)

function linear_orientation (xa, ya, xb, yb)
  local o=-math.atan(ya-yb,xb-xa) -- y is reversed in screen coords
  if o<0 then o=o+math.pi*2 elseif o>=math.pi*2 then o=o-math.pi*2 end
  o=math.floor(o*orientation_f)
  return o
end

--------------------------------------------------------------------------------
-- PATH

function paths_init (paths, t)
  -- log("init paths @"..t)
  for i,path in ipairs(paths) do
    -- log("init path "..i.." @"..t)
    path_init(path, t)
    t=path.steps[#path.steps].t
  end
end

function path_init (path, t)
  local x0; local y0; local t0
  for i,step in ipairs(path.steps) do
    if i==1 then
      step.t=t;
      x0=step.x; y0=step.y; t0=step.t
    else
      if not step.o then
        if path.o then
          step.o=path.o
        else
          step.o=linear_orientation(x0,y0,step.x,step.y)
        end
      end
      step.s=linear_distance(x0,y0,step.x,step.y)
      if not step.v then step.v = path.v end
      if step.t and step.t>t0 then
        step.v=step.s/(step.t-t0)
      else
        step.t=t0+(step.s/step.v)
      end
      -- log("s:"..math.floor(step.s).." "..x0..","..y0.."=>"..step.x..","..step.y
      --   .." t:"..math.floor(step.t-t0).." "..math.floor(t0).."=>"..math.floor(step.t)
      --   .." v:"..string.format("%0.3f",step.v))
      x0=step.x; y0=step.y; t0=step.t
    end
  end
end

function paths_update (paths, t)
  for _,path in pairs(paths) do
    if t>=path.steps[1].t and t<path.steps[#path.steps].t then
      return path_update(path,t)
    end
  end
end

function path_update (path, t)
  --log("path_update t:"..t.." path.t:"..path.t)
  if t>=path.steps[1].t then
    for i,step in ipairs(path.steps) do
      if step.t>t then
        --log("path_update t:"..t.." step.t:"..step.t)
        local x0=path.x; local y0=path.y; local t0=path.t;
        if i>1 then
          local prev=path.steps[i-1]
          x0=prev.x; y0=prev.y; t0=prev.t;
        end
        local s=step.v*(t-t0)
        x,y=linear_interpolation(x0,y0,step.x,step.y,step.s,s)
        return x,y,step.o
      end
    end
  end
  return nil,nil,nil
end

function paths_draw (paths)
  for _,path in pairs(paths) do
    path_draw(path)
  end
end

function path_draw (path)
--   local x=path.x; local y=path.y
  for i,step in ipairs(path.steps) do
--     line(x,y,step.x,step.y,7)
--     x=step.x; y=step.y
  end
end

function path_translate (path, x, y)
  for i,step in ipairs(path.steps) do
    step.x=step.x+x; step.y=step.y+y
  end
  return path
end

function path_flip (path, is_x, is_y)
  for i,step in ipairs(path.steps) do
    if is_x then step.x=240-step.x end
    if is_y then step.y=136-step.y end
  end
  return path
end

--------------------------------------------------------------------------------
-- GAME MODE -> DEMO

function init_invaders_wave_1 (t)
  -- define paths
  local xg=113;
  local paths_1={
    {v=1,steps={
      {x=110,y=0}, {x=110,y=16}, {x=205,y=40}, {x=216,y=46}, {x=220,y=55},
      {x=216,y=64}, {x=205,y=70}, {x=158,y=70}, {x=148,y=67}, {x=139,y=61},
      {x=134,y=53}
    }},
    {v=1,o=6,steps={
      {x=134,y=53}, {x=xg,y=48,t=280}, {x=xg,y=16,t=340}
    }},
    {v=0.25,o=6,steps={
      {x=xg,y=16}, {x=91,y=16}
    }},
    {v=0.25,o=6,steps={
      {x=91,y=16}, {x=125,y=16}, {x=91,y=16}, {x=125,y=16},
      {x=91,y=16}, {x=125,y=16}, {x=91,y=16}, {x=125,y=16}
    }}
  }
  local xg=127;
  local paths_2={
    table_deepcopy(paths_1[1]),
    {v=1,o=6,steps={{x=134,y=53}, {x=xg,y=48,t=300}, {x=xg,y=16,t=350}}},
    {v=0.25,o=6,steps={{x=xg,y=16}, {x=108,y=16}}},
    path_translate(table_deepcopy(paths_1[4]),17,0)
  }
  local xg=101;
  local paths_3={
    table_deepcopy(paths_1[1]),
    {v=1,o=6,steps={{x=134,y=53}, {x=xg,y=48,t=320}, {x=xg,y=28,t=360}}},
    {v=0.25,o=6,steps={{x=xg,y=28}, {x=91,y=28}}},
    path_translate(table_deepcopy(paths_1[4]),0,12)
  }
  local xg=115;
  local paths_4={
    table_deepcopy(paths_1[1]),
    {v=1,o=6,steps={{x=134,y=53}, {x=xg,y=48,t=340}, {x=xg,y=28,t=370}}},
    {v=0.25,o=6,steps={{x=xg,y=28}, {x=108,y=28}}},
    path_translate(table_deepcopy(paths_1[4]),17,12)
  }
  -- duplicate paths
  local xg=121;
  local paths_5={
    path_flip(table_deepcopy(paths_1[1]),true,false),
    {v=1,o=6,steps={{x=106,y=53}, {x=xg,y=48,t=280}, {x=xg,y=40,t=340}}},
    {v=0.25,o=6,steps={{x=xg,y=40}, {x=91,y=40}}},
    path_translate(table_deepcopy(paths_1[4]),0,24)
  }
  local xg=130;
  local paths_6={
    path_flip(table_deepcopy(paths_1[1]),true,false),
    {v=1,o=6,steps={{x=106,y=53}, {x=xg,y=48,t=300}, {x=xg,y=40,t=350}}},
    {v=0.25,o=6,steps={{x=xg,y=40}, {x=108,y=40}}},
    path_translate(table_deepcopy(paths_1[4]),17,24)
  }
  local xg=112;
  local paths_7={
    path_flip(table_deepcopy(paths_1[1]),true,false),
    {v=1,o=6,steps={{x=106,y=53}, {x=xg,y=53,t=320}, {x=xg,y=52,t=360}}},
    {v=0.25,o=6,steps={{x=xg,y=52}, {x=91,y=52}}},
    path_translate(table_deepcopy(paths_1[4]),0,36)
  }
  local xg=121;
  local paths_8={
    path_flip(table_deepcopy(paths_1[1]),true,false),
    {v=1,o=6,steps={{x=106,y=53}, {x=xg,y=53,t=340}, {x=xg,y=52,t=370}}},
    {v=0.25,o=6,steps={{x=xg,y=52}, {x=108,y=52}}},
    path_translate(table_deepcopy(paths_1[4]),17,36)
  }
  -- init paths
  local td=25
  paths_init(paths_1,t+td*0)
  paths_init(paths_2,t+td*1)
  paths_init(paths_3,t+td*2)
  paths_init(paths_4,t+td*3)
  paths_init(paths_5,t+td*0)
  paths_init(paths_6,t+td*1)
  paths_init(paths_7,t+td*2)
  paths_init(paths_8,t+td*3)
  -- invaders
  return {
    --right red invaders
    {id=2,od=0,xd=-4,yd=-4,paths=paths_1},
    {id=2,od=0,xd=-4,yd=-4,paths=paths_2},
    {id=2,od=0,xd=-4,yd=-4,paths=paths_3},
    {id=2,od=0,xd=-4,yd=-4,paths=paths_4},
    --left blue invaders
    {id=4,od=0,xd=-4,yd=-4,paths=paths_5},
    {id=4,od=0,xd=-4,yd=-4,paths=paths_6},
    {id=4,od=0,xd=-4,yd=-4,paths=paths_7},
    {id=4,od=0,xd=-4,yd=-4,paths=paths_8}
  }
end

function init_invaders_wave_2 (t)
  -- define paths
  local paths_1={
    {v=1,steps={
      {x=0,y=110}, {x=63,y=95}, {x=105,y=85}, {x=105,y=80}, {x=90,y=67},
      {x=76,y=67}, {x=59,y=74}, {x=62,y=85}, {x=80,y=90}, {x=100,y=90},
      {x=105,y=80}, {x=110,y=70}
    }},
  }
  local paths_2={
    table_deepcopy(paths_1[1]),
  }
  local paths_3={
    table_deepcopy(paths_1[1]),
  }
  local paths_4={
    table_deepcopy(paths_1[1]),
  }
  local paths_5={
    table_deepcopy(paths_1[1]),
  }
  local paths_6={
    table_deepcopy(paths_1[1]),
  }
  local paths_7={
    table_deepcopy(paths_1[1]),
  }
  local paths_8={
    table_deepcopy(paths_1[1]),
  }
  -- init paths
  local td=25
  paths_init(paths_1,t+td*0)
  paths_init(paths_2,t+td*1)
  paths_init(paths_3,t+td*2)
  paths_init(paths_4,t+td*3)
  paths_init(paths_5,t+td*4)
  paths_init(paths_6,t+td*5)
  paths_init(paths_7,t+td*6)
  paths_init(paths_8,t+td*7)
  -- invaders
  return {
    {id=6,od=0,xd=-4,yd=-4,paths=paths_1},
    {id=2,od=0,xd=-4,yd=-4,paths=paths_2},
    {id=6,od=0,xd=-4,yd=-4,paths=paths_3},
    {id=2,od=0,xd=-4,yd=-4,paths=paths_4},
    {id=6,od=0,xd=-4,yd=-4,paths=paths_5},
    {id=2,od=0,xd=-4,yd=-4,paths=paths_6},
    {id=6,od=0,xd=-4,yd=-4,paths=paths_7},
    {id=2,od=0,xd=-4,yd=-4,paths=paths_8}
  }
end

function init_invaders_grid ()
  invaders_grid={}
  invaders_grid_w=17
  invaders_grid_h=12
  invaders_grid_x=invaders_grid_w
  x0=2+invaders_grid_w+invaders_grid_w
  for y=1,5 do
    for x=1,10 do
      invaders_grid[x..","..y]={x=x0+(x-1)*invaders_grid_w,y=(y-1)*invaders_grid_h}
    end
  end
end

function get_final_time (invader)
  last_path=invader.paths[#invader.paths]
  return last_path.steps[#last_path.steps].t
end

function init_mode_demo ()
  game_mode=GM_DEMO

  --invaders
  invaders={}
  for _,v in pairs(init_invaders_wave_1(100)) do
    table.insert(invaders, v)
  end
  for _,v in pairs(init_invaders_wave_2(500)) do
    table.insert(invaders, v)
  end
  --log(table_print(invaders[#invaders]))
  init_invaders_grid()
end

function update_invader (invd)
  xn,yn,on=paths_update(invd.paths,tick)
  --log("xn:"..(xn or "nil").." yn:"..(yn or "nil").." on:"..(on or "nil"))
  if xn and yn and on then
    invd.x=xn+invd.xd; invd.y=yn+invd.yd; invd.o=on+invd.od
  end
end

function update_player ()
  --player path
  if tick>=plyr.path.t and tick<plyr.path.steps[#plyr.path.steps].t then
    xn,yn,_=path_update(plyr.path,tick)
    plyr.x=xn; plyr.y=yn
  end
  --player shots
  -- if ((tick//30)%2)==0 then  -> 1 sec
  if (tick%30)==0 then
    table.insert(plyr.shots,{x=plyr.x+6,y=plyr.y-4})
    --log("plyr.shots"..table_print(plyr.shots))
  end
  for i,shot in ipairs(plyr.shots) do
    shot.y=shot.y-2
    if shot.y<0 then table.remove(plyr.shots,i) end
  end
end

function update_invaders_grid ()
  local x=0
  if invaders_grid_x>0 then x=1 elseif invaders_grid_x<0 then x=-1 end
  invaders_grid_x=invaders_grid_x-x
  if invaders_grid_x==0 then invaders_grid_x=(invaders_grid_w*x*-2) end
  for k,v in pairs(invaders_grid) do
    v.x=v.x+x
  end
end

function update_mode_demo ()
  --invaders
  for _,invd in pairs(invaders) do
    update_invader(invd)
  end
  if (tick%4)==0 then
    update_invaders_grid()
  end
end

function get_spr_id_offset_and_flip (orientation)
  -- 0=No Flip 1=Flip horizontally 2=Flip vertically 3=Flip both vertically and horizontally
  if orientation==0 then return 96,0
  elseif orientation==1 then return 64,2
  elseif orientation==2 then return 32,2
  elseif orientation==3 then return 64,3
  elseif orientation==4 then return 96,1
  elseif orientation==5 then return 64,1
  elseif orientation==6 then
    if (tick%40//20)==0 then return 0,0 else return 32,0 end
  elseif orientation==7 then return 64,0
  end
end

function draw_invd (invd)
  if invd.x and invd.y and invd.o then
    local id_offset=0
    local flip=0
    id_offset,flip=get_spr_id_offset_and_flip(invd.o)
    spr(invd.id+id_offset,invd.x,invd.y,0,1,flip,0,2,2)
  end
end

function test_draw_all_invaders ()
  xd=17; yd=12; od=0
  x0=2+(2*xd)
  if (tick%40//20)==0 then od=32 end
  for i=0,3 do spr(6+od,x0+(3*xd)+(i*xd),(0*yd),0,1,0,0,2,2) end
  for i=0,7 do spr(2+od,x0+(1*xd)+(i*xd),(1*yd),0,1,0,0,2,2) end
  for i=0,7 do spr(2+od,x0+(1*xd)+(i*xd),(2*yd),0,1,0,0,2,2) end
  for i=0,9 do spr(4+od,x0+(0*xd)+(i*xd),(3*yd),0,1,0,0,2,2) end
  for i=0,9 do spr(4+od,x0+(0*xd)+(i*xd),(4*yd),0,1,0,0,2,2) end
end

function draw_invaders_grid ()
  for k,v in pairs(invaders_grid) do
    rectb(v.x,v.y,14,10,7)
    if k=="5,2" or k=="5,3" or k=="6,2" or k=="6,3" then rectb(v.x,v.y,14,10,6) end
  end
end

function draw_mode_demo ()
  --invaders
  for _,invd in pairs(invaders) do
    draw_invd(invd)
  end
  -- test_draw_all_invaders()
  --draw_invaders_grid()
end

--------------------------------------------------------------------------------
-- MAIN

function init ()
  tick=0
  --game mode
  GM_ATTRACT,GM_DEMO,GM_INGAME=0,1,2
  --init
  --init_stars()
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
