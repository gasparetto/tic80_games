-- title:  Atari 7800 Galaga
-- author: game developer
-- desc:   short description
-- script: lua

-- $ cd ~/Projects/Games/tic80/galaga
-- $ tic80 a78_galaga.tic -code a78_galaga.lua

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

function linear_orientation (xa, ya, xb, yb)
  local o=-math.atan(ya-yb,xb-xa) -- y is reversed in screen coords
  if o<0 then o=o+math.pi*2 elseif o>=math.pi*2 then o=o-math.pi*2 end
  return o
end

--------------------------------------------------------------------------------
-- PATH

function path_init (path)
  local x=path.x; local y=path.y; local t=path.t
  for i,step in ipairs(path.steps) do
    if not step.o then
      if path.o then
        step.o=path.o
      else
        step.o=linear_orientation(x,y,step.x,step.y)
      end
    end
    step.s=linear_distance(x,y,step.x,step.y)
    step.t=t+(step.s/path.v)
    x=step.x; y=step.y; t=step.t
  end
end

function path_update (path, t)
  if t>=path.t then
    for i,step in ipairs(path.steps) do
      if step.t>t then
        local x0=path.x; local y0=path.y; local t0=path.t;
        if i>1 then
          local prev=path.steps[i-1]
          x0=prev.x; y0=prev.y; t0=prev.t;
        end
        local s=path.v*(t-t0)
        x,y=linear_interpolation(x0,y0,step.x,step.y,step.s,s)
        return x,y,step.o
      end
    end
  end
  return nil,nil,nil
end

function path_draw (path)
  local x=path.x; local y=path.y
  for i,step in ipairs(path.steps) do
    line(x,y,step.x,step.y,7)
    x=step.x; y=step.y
  end
end

function path_translate (path, x, y)
  path.x=path.x+x; path.y=path.y+y
  for i,step in ipairs(path.steps) do
    step.x=step.x+x; step.y=step.y+y
  end
end

function path_flip_horizontal (path)
  path.x=240-path.x
  for i,step in ipairs(path.steps) do
    step.x=240-step.x
  end
end

--------------------------------------------------------------------------------
-- GAME MODE -> DEMO

function init_invaders_wave_1 (invaders, t)
  -- define paths
  path_1_1={
    x=110,y=0,t=0,v=1,steps={
      {x=110,y=13}, {x=205,y=40}, {x=216,y=46}, {x=220,y=55}, {x=216,y=64},
      {x=205,y=70}, {x=158,y=70}, {x=148,y=67}, {x=139,y=61}, {x=134,y=53},
      {x=108,y=16,o=math.pi*1.5}
    }
  }
  path_2_1=table_deepcopy(path_1_1)
  path_3_1=table_deepcopy(path_1_1)
  path_4_1=table_deepcopy(path_1_1)
  -- change paths starting time
  local td=25
  path_1_1.t=t
  path_2_1.t=t+(td*1)
  path_3_1.t=t+(td*2)
  path_4_1.t=t+(td*3)
  -- duplicate paths
  path_5_1=table_deepcopy(path_1_1)
  path_6_1=table_deepcopy(path_2_1)
  path_7_1=table_deepcopy(path_3_1)
  path_8_1=table_deepcopy(path_4_1)
  -- -- flip paths
  path_flip_horizontal(path_5_1)
  path_flip_horizontal(path_6_1)
  path_flip_horizontal(path_7_1)
  path_flip_horizontal(path_8_1)
  -- change paths final step
  path_2_1.steps[#path_2_1.steps]={x=125,y=16,o=math.pi*1.5}
  path_3_1.steps[#path_3_1.steps]={x=108,y=28,o=math.pi*1.5}
  path_4_1.steps[#path_4_1.steps]={x=125,y=28,o=math.pi*1.5}
  path_5_1.steps[#path_5_1.steps]={x=108,y=40,o=math.pi*1.5}
  path_6_1.steps[#path_6_1.steps]={x=125,y=40,o=math.pi*1.5}
  path_7_1.steps[#path_7_1.steps]={x=108,y=52,o=math.pi*1.5}
  path_8_1.steps[#path_8_1.steps]={x=125,y=52,o=math.pi*1.5}
  -- init paths
  path_init(path_1_1)
  path_init(path_2_1)
  path_init(path_3_1)
  path_init(path_4_1)
  path_init(path_5_1)
  path_init(path_6_1)
  path_init(path_7_1)
  path_init(path_8_1)
  -- define paths 2
  -- path_1_2={
  --   x=0,y=0,t=0,v=0.2,o=math.pi*1.5,steps={
  --     {x=-17,y=0}, {x=17,y=0}, {x=-17,y=0}, {x=17,y=0},
  --     {x=-17,y=0}, {x=17,y=0}, {x=-17,y=0}, {x=17,y=0},
  --     {x=-17,y=0}, {x=17,y=0}, {x=-17,y=0}, {x=17,y=0},
  --   }
  -- }
  -- path_2_2=table_deepcopy(path_1_2)
  -- path_3_2=table_deepcopy(path_1_2)
  -- path_4_2=table_deepcopy(path_1_2)
  -- path_5_2=table_deepcopy(path_1_2)
  -- path_6_2=table_deepcopy(path_1_2)
  -- path_7_2=table_deepcopy(path_1_2)
  -- path_8_2=table_deepcopy(path_1_2)
  -- -- change paths 2 starting time
  -- t=path_8_1.steps[#path_8_1.steps].t
  -- path_1_2.t=t; path_2_2.t=t; path_3_2.t=t; path_4_2.t=t
  -- path_5_2.t=t; path_6_2.t=t; path_7_2.t=t; path_8_2.t=t
  -- -- translate paths 2
  -- path_translate(path_1_2,108,16)
  -- path_translate(path_2_2,125,16)
  -- path_translate(path_3_2,108,28)
  -- path_translate(path_4_2,125,28)
  -- path_translate(path_5_2,108,40)
  -- path_translate(path_6_2,125,40)
  -- path_translate(path_7_2,108,52)
  -- path_translate(path_8_2,125,52)
  -- -- init paths 2
  -- path_init(path_1_2)
  -- path_init(path_2_2)
  -- path_init(path_3_2)
  -- path_init(path_4_2)
  -- path_init(path_5_2)
  -- path_init(path_6_2)
  -- path_init(path_7_2)
  -- path_init(path_8_2)
  -- invaders
  table.insert(invaders,{id=2,od=0,xd=-4,yd=-4,paths={path_1_1}})
  table.insert(invaders,{id=2,od=0,xd=-4,yd=-4,paths={path_2_1}})
  table.insert(invaders,{id=2,od=0,xd=-4,yd=-4,paths={path_3_1}})
  table.insert(invaders,{id=2,od=0,xd=-4,yd=-4,paths={path_4_1}})
  table.insert(invaders,{id=4,od=0,xd=-4,yd=-4,paths={path_5_1}})
  table.insert(invaders,{id=4,od=0,xd=-4,yd=-4,paths={path_6_1}})
  table.insert(invaders,{id=4,od=0,xd=-4,yd=-4,paths={path_7_1}})
  table.insert(invaders,{id=4,od=0,xd=-4,yd=-4,paths={path_8_1}})
  -- return final time of paths 1
  return t
end

function init_invaders_wave_2 (invaders, t)
  -- define paths
  path_1_1={
    x=0,y=110,t=0,v=1,steps={
      {x=63,y=95}, {x=105,y=75}, {x=105,y=70}, {x=90,y=57}, {x=76,y=57},
      {x=59,y=64}, {x=62,y=75}, {x=80,y=80}, {x=100,y=80}, {x=105,y=70},
      {x=110,y=60}, {x=91,y=4,o=math.pi*1.5},
    }
  }
  path_2_1=table_deepcopy(path_1_1)
  path_3_1=table_deepcopy(path_1_1)
  path_4_1=table_deepcopy(path_1_1)
  path_5_1=table_deepcopy(path_1_1)
  path_6_1=table_deepcopy(path_1_1)
  path_7_1=table_deepcopy(path_1_1)
  path_8_1=table_deepcopy(path_1_1)
  -- change paths final step
  path_2_1.steps[#path_2_1.steps]={x=91,y=16,o=math.pi*1.5}
  path_3_1.steps[#path_3_1.steps]={x=108,y=4,o=math.pi*1.5}
  path_4_1.steps[#path_4_1.steps]={x=142,y=16,o=math.pi*1.5}
  path_5_1.steps[#path_5_1.steps]={x=125,y=4,o=math.pi*1.5}
  path_6_1.steps[#path_6_1.steps]={x=91,y=28,o=math.pi*1.5}
  path_7_1.steps[#path_7_1.steps]={x=142,y=4,o=math.pi*1.5}
  path_8_1.steps[#path_8_1.steps]={x=142,y=28,o=math.pi*1.5}
  -- change paths starting time
  local td=25
  path_1_1.t=t
  path_2_1.t=t+(td*1)
  path_3_1.t=t+(td*2)
  path_4_1.t=t+(td*3)
  path_5_1.t=t+(td*4)
  path_6_1.t=t+(td*5)
  path_7_1.t=t+(td*6)
  path_8_1.t=t+(td*7)
  -- init paths
  path_init(path_1_1)
  path_init(path_2_1)
  path_init(path_3_1)
  path_init(path_4_1)
  path_init(path_5_1)
  path_init(path_6_1)
  path_init(path_7_1)
  path_init(path_8_1)
  -- define paths 2
  path_1_2={
    x=0,y=0,t=0,v=0.2,o=math.pi*1.5,steps={
      {x=-17,y=0}, {x=17,y=0}, {x=-17,y=0}, {x=17,y=0},
      {x=-17,y=0}, {x=17,y=0}, {x=-17,y=0}, {x=17,y=0},
    }
  }
  path_2_2=table_deepcopy(path_1_2)
  path_3_2=table_deepcopy(path_1_2)
  path_4_2=table_deepcopy(path_1_2)
  path_5_2=table_deepcopy(path_1_2)
  path_6_2=table_deepcopy(path_1_2)
  path_7_2=table_deepcopy(path_1_2)
  path_8_2=table_deepcopy(path_1_2)
  -- change paths 2 starting time
  t=path_8_1.steps[#path_8_1.steps].t
  path_1_2.t=t; path_2_2.t=t; path_3_2.t=t; path_4_2.t=t
  path_5_2.t=t; path_6_2.t=t; path_7_2.t=t; path_8_2.t=t
  -- translate paths 2
  path_translate(path_1_2,91,4)
  path_translate(path_2_2,91,16)
  path_translate(path_3_2,108,4)
  path_translate(path_4_2,142,16)
  path_translate(path_5_2,125,4)
  path_translate(path_6_2,91,28)
  path_translate(path_7_2,142,4)
  path_translate(path_8_2,142,28)
  -- init paths 2
  path_init(path_1_2)
  path_init(path_2_2)
  path_init(path_3_2)
  path_init(path_4_2)
  path_init(path_5_2)
  path_init(path_6_2)
  path_init(path_7_2)
  path_init(path_8_2)
  -- invaders
  table.insert(invaders,{id=6,od=0,xd=-4,yd=-4,paths={path_1_1,path_1_2}})
  table.insert(invaders,{id=2,od=0,xd=-4,yd=-4,paths={path_2_1,path_2_2}})
  table.insert(invaders,{id=6,od=0,xd=-4,yd=-4,paths={path_3_1,path_3_2}})
  table.insert(invaders,{id=2,od=0,xd=-4,yd=-4,paths={path_4_1,path_4_2}})
  table.insert(invaders,{id=6,od=0,xd=-4,yd=-4,paths={path_5_1,path_5_2}})
  table.insert(invaders,{id=2,od=0,xd=-4,yd=-4,paths={path_6_1,path_6_2}})
  table.insert(invaders,{id=6,od=0,xd=-4,yd=-4,paths={path_7_1,path_7_2}})
  table.insert(invaders,{id=2,od=0,xd=-4,yd=-4,paths={path_8_1,path_8_2}})
  -- return final time of paths 1
  return t
end

function init_mode_demo ()
  game_mode=GM_DEMO
  --tick=1000

  --invaders
  invaders={}
  local t=tick
  t=init_invaders_wave_1(invaders,0) --t+200
  --t=init_invaders_wave_2(invaders,t+220)

  -- player
  plyr_path={
    x=116,y=116,t=0,v=1.5,o=0,steps={
      {x=72,y=116}, {x=140,y=116}, {x=100,y=116}, {x=120,y=116},
      {x=40,y=116}, {x=100,y=116}, {x=80,y=116}, {x=180,y=116},
      {x=80,y=116}, {x=120,y=116}, {x=100,y=116}, {x=116,y=116},
      {x=72,y=116}, {x=140,y=116}, {x=100,y=116}, {x=120,y=116},
      {x=40,y=116}, {x=100,y=116}, {x=80,y=116}, {x=180,y=116},
      {x=80,y=116}, {x=120,y=116}, {x=100,y=116}, {x=116,y=116},
      {x=72,y=116}, {x=140,y=116}, {x=100,y=116}, {x=120,y=116},
      {x=40,y=116}, {x=100,y=116}, {x=80,y=116}, {x=180,y=116},
      {x=80,y=116}, {x=120,y=116}, {x=100,y=116}, {x=116,y=116},
      {x=72,y=116}, {x=140,y=116}, {x=100,y=116}, {x=120,y=116},
      {x=40,y=116}, {x=100,y=116}, {x=80,y=116}, {x=180,y=116},
      {x=80,y=116}, {x=120,y=116}, {x=100,y=116}, {x=116,y=116},
    }
  }
  path_init(plyr_path)
  plyr={id=0,x=116,y=116,path=plyr_path,shots={}}
end

function update_invader (invd)
  for _,path in pairs(invd.paths) do
    if tick>=path.t and tick<path.steps[#path.steps].t then
      --log("tick:"..tick.." path.t:"..path.t.." path.steps[#path.steps].t:"..path.steps[#path.steps].t)
      xn,yn,on=path_update(path,tick)
      --log("xn:"..(xn or "nil").." yn:"..(yn or "nil").." on:"..(on or "nil"))
      invd.x=xn+invd.xd
      invd.y=yn+invd.yd
      invd.o=on+invd.od
      break
    end
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

function update_mode_demo ()
  --invaders
  for _,invd in pairs(invaders) do
    update_invader(invd)
  end
  --player
  update_player()
end

orientation_f=8/(math.pi*2)

function get_spr_id_offset_and_flip (orientation)
  orientation=math.floor(orientation*orientation_f)
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

function draw_player ()
  spr(plyr.id,plyr.x,plyr.y,0,1,0,0,2,1)
  for i,shot in ipairs(plyr.shots) do
    spr(32,shot.x,shot.y,0)
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

function draw_mode_demo ()
  --ships
  spr(plyr.id,0,128,0,1,0,0,2,1)
  spr(plyr.id,18,128,0,1,0,0,2,1)
  spr(plyr.id,36,128,0,1,0,0,2,1)
  print("READY",104,66,2)
  print("1",224,126,10,true,2)
  --invaders
  for _,invd in pairs(invaders) do
    draw_invd(invd)
  end
  -- test_draw_all_invaders()
  --player
  --draw_player()
end

--------------------------------------------------------------------------------
-- GAME MODE -> INGAME

function init_mode_ingame ()
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
-- GAME MODE -> ATTRACT

function init_mode_attract ()
  game_mode=GM_ATTRACT

  BLINK_SPR={
    {s=384,w=1,h=1,dx=-3,dy=-1}, {s=385,w=2,h=1,dx=-5,dy=-2},
    {s=387,w=2,h=1,dx=-7,dy=-3}, {s=389,w=3,h=2,dx=-9,dy=-5},
    {s=392,w=4,h=2,dx=-13,dy=-7}, {s=396,w=4,h=2,dx=-13,dy=-7},
    {s=392,w=4,h=2,dx=-13,dy=-7}, {s=389,w=3,h=2,dx=-9,dy=-5},
    {s=387,w=2,h=1,dx=-7,dy=-3}, {s=385,w=2,h=1,dx=-5,dy=-2},
    {s=384,w=1,h=1,dx=-3,dy=-1}
  }
  BLINKS_POS={
    {x=130,y=52}, {x=150,y=74}, {x=144,y=60}, {x=70,y=64}, {x=130,y=52},
    {x=110,y=48}, {x=98,y=60}, {x=52,y=48}, {x=194,y=54}, {x=150,y=74},
    {x=144,y=60}, {x=70,y=64}, {x=130,y=52}, {x=110,y=48}, {x=98,y=60},
    {x=52,y=48}
  }
  blink={pos=1,t=tick}
end

function update_mode_attract ()
  blink.t=blink.t+1
  if blink.t==34 then
    blink.t=1
    blink.pos=blink.pos+1
    if blink.pos>#BLINKS_POS then init_mode_demo() end
  end
end

function draw_mode_attract ()
  --logo
  spr(256,20,48,0,1,0,0,10,3)
  spr(266,100,48,0,1,0,0,6,5)
  spr(304,148,48,0,1,0,0,9,5)
  --copyright
  print("2018",116,75,8)
  print("TIC-80",105,82,8)
  --blinks
  bspr=BLINK_SPR[math.ceil(blink.t/3)]
  bpos=BLINKS_POS[blink.pos]
  spr(bspr.s,bpos.x+bspr.dx,bpos.y+bspr.dy,0,1,0,0,bspr.w,bspr.h)
end

--------------------------------------------------------------------------------
-- GAME MODE -> ALL

function init_stars ()
  STARS_XY={
    110,19,108,46,139,217,164,111,79,257,132,82,206,50,178,47,210,389,52,218,
    130,340,201,95,72,332,107,170,146,376,149,26,237,28,43,226,147,344,202,374,
    120,156,33,142,123,351,114,154,203,275,223,155,129,305,150,333,142,28,62,79,
    2,350,63,397,226,175,134,221,71,159,117,317,189,250,36,119,120,248,163,138,
    74,243,176,337,89,142,162,384,102,371,38,172,192,167,101,297,205,391,70,58,
    90,311,225,63,96,33,109,360,169,53,58,3,177,390,204,42,79,208,16,301,
    107,88,44,99,153,240,237,194,139,112,151,379,14,226,25,182,156,222,85,139,
    165,238,85,169,136,81,127,358,173,236,155,67,194,330,99,177,102,160,223,400,
    163,222,227,293,29,20,45,306,145,215,27,115,32,187,170,279,161,94,142,155,
    198,94,133,253,14,386,18,192,87,400,115,16,133,169,185,269,113,382,105,29,
    118,219,86,249,4,27,77,272,73,364,16,50,34,248,182,79,140,332,163,378,
    199,62,236,151,139,300,12,19,169,194,29,78,8,191,197,18,131,54,174,338,
    11,316,233,74,99,290,92,397,133,23,225,151,51,367,181,314,160,321,200,148,
    69,380,136,126,102,153,86,387,124,33,195,224,209,311,178,112,120,49,65,20,
    43,82,102,155,29,72,42,315,236,1,38,106,228,288,139,150,25,375,82,247
  }
end

function draw_stars ()
  for i=1,#STARS_XY/2,2 do
    pix(STARS_XY[i],(STARS_XY[i+1]+(tick/5))%400,8)
  end
end

--------------------------------------------------------------------------------
-- MAIN

function init ()
  tick=0
  --game mode
  GM_ATTRACT,GM_DEMO,GM_INGAME=0,1,2
  --init
  init_stars()
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
  draw_stars()
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
