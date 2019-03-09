-- title:  nes_bubble_bobble
-- author: game developer
-- desc:   short description
-- script: lua

-- https://www.youtube.com/watch?v=O49OgQ_kogw

-- check collision on map
function coll(spr,dx,dy)
  return mget((spr.x+dx)//8,(spr.y+dy)//8)>0 or
      mget((spr.x+dx+15)//8,(spr.y+dy)//8)>0
end

JUMP = {4,4,3,3,3,2,2,2,1,1,1,1,1,1,0,0,
  0,0,-1,-1,-1,-1,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4}
JUMP_X = {0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,
  -0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75,-0.75}
SHOT = {2,2,2,2,2,2,2,2,4,4,4,4,4,4,6,6,6,6,6,6,8,8,8,8}

-- 0=stop,1=go-left,2=go-right,3=flip-left,4=flip-right
-- 5=jump,6=jump-left,7=jump-right,8=shot
--ENEMY1 = {
--  {i=0,a=3},   --flip-left
--  {i=60,a=1},  --go-left
--  {i=225,a=0}, --stop
--  {i=15,a=4},  --flip-right
--  {i=15,a=3},  --flip-left
--  {i=1,a=5},   --jump
--  {i=50,a=1},  --go-left
--  {i=10,a=7},  --jump-right
--  {i=15,a=2},  --go-right
--  {i=85,a=0},  --stop
--  {i=15,a=3},  --flip-left
--  {i=15,a=4},  --flip-right
--  {i=1,a=5},   --jump
--}

function update_enemy(body)
  if not coll(body,0,16) then
    body.y = body.y+gravity
    return
  end
  follow_action(body)
  local x = body.x
  if x==40 or x==80 or x==160 or x==200 then
    if math.random(1,10)==10 then
      
    end
  end
  
end

function follow_action(body)
-- 0=stop,1=go-left,2=go-right,3=flip-left,4=flip-right
-- 5=jump,6=jump-left,7=jump-right,8=shot
  if body.a==1 then move_x(body,-speed)
  elseif body.a==2 then move_x(body,speed)
  elseif body.a==3 then body.flip=1
  elseif body.a==4 then body.flip=0
--  elseif body.a==5 then jump(body)
--  elseif body.a==6 then jump(body,-1)
--  elseif body.a==7 then jump(body,1)
--  elseif body.a==8 then shot(body)
  end
end

function move_x(body,dx)
  if not coll(body,dx,0) then
    body.x = body.x+dx
    body.flip = (dx<0) and 1 or 0
  else
    body.a = (body.a==2) and 1 or 2
    body.flip = (body.flip==0) and 1 or 0
  end
end

---------------------------------------------------------

function init()
  tick = 0
  game = {level=1,score1=0,score2=0,lives=2}
  speed = 0.75
  gravity = 0.75
--  player = {x=17,y=104,flip=0,jump=nil,shot=nil}
  enemy1 = {x=112,y=-20,flip=1,a=1}
--  for i,v in ipairs(ENEMY1) do if i>1 then v.i=v.i+ENEMY1[i-1].i end end
end

init()

--function input()
--  if btn(2) then move_x(player,-speed) end
--  if btn(3) then move_x(player,speed) end
--  if btn(4) then jump(player) end
--  if btn(5) then shot(player) end
--end

function jump(body,speed)
  speed = speed or 0
  if not body.jump then body.jump={i=0,dx=speed} end
end

--function shot(body)
--  if not body.shot then
--    local v = body
--    v.shot = {x=v.x,y=v.y,flip=v.flip,i=0}
--  end
--end

function update_jump(body)
  local arr = (body.jump.dx~=0) and JUMP_X or JUMP
  if body.jump.i<#arr then
    body.jump.i = body.jump.i+1
    local y = arr[body.jump.i]
    body.x = body.x+body.jump.dx
    body.y = body.y-y
    if y<=0 and coll(body,0,16) then
      body.jump = nil
    end
  else
    body.jump = nil
  end
end

--function update_player_shot()
--  if player.shot.i<#SHOT then
--    player.shot.i = player.shot.i+1
--    player.shot.id = 20+SHOT[player.shot.i]
--    local f = (player.shot.flip==0) and 1 or -1
--    player.shot.x = player.shot.x+(f*2)
--  else
--    player.shot = nil
--  end
--end

--function update_player()
--  if player.shot then update_player_shot() end
--  if player.jump then update_jump(player)
--  elseif not coll(player,0,16) then
--    player.y = player.y+gravity
--  end
--end

--function update_enemies()
--  --scripted path actions
--  for _,ia in ipairs(ENEMY1) do
--    if ia.i==tick then enemy1.a=ia.a end
--  end
--  if enemy1.jump then update_jump(enemy1)
--  elseif not coll(enemy1,0,16) then
--    enemy1.y = enemy1.y+gravity
--    return
--  end
---- 0=stop,1=go-left,2=go-right,3=flip-left,4=flip-right
---- 5=jump,6=jump-left,7=jump-right,8=shot
--  if enemy1.a==1 then move_x(enemy1,-speed)
--  elseif enemy1.a==2 then move_x(enemy1,speed)
--  elseif enemy1.a==3 then enemy1.flip=1; enemy1.a=0
--  elseif enemy1.a==4 then enemy1.flip=0; enemy1.a=0
--  elseif enemy1.a==5 then jump(enemy1); enemy1.a=0
--  elseif enemy1.a==6 then jump(enemy1,-1); enemy1.flip=1; enemy1.a=0
--  elseif enemy1.a==7 then jump(enemy1,1); enemy1.flip=0; enemy1.a=0
--  elseif enemy1.a==8 then shot(enemy1); enemy1.a=0
--  end
--end

function update()
  tick = tick+1
--  update_player()
--  update_enemies()
  update_enemy(enemy1)
end

--function draw_player_shot()
--  local s = player.shot
--  spr(s.id,s.x,s.y,0,1,0,0,2,2)
--end

--function draw_player()
--  if player.shot then
--    draw_player_shot()
--    spr(20,player.x,player.y+1,0,1,player.flip,0,2,2)
--  else
--    local s = tick%60//30 -- 0|1 every 1/2 secs
--    spr(16+(s*2),player.x,player.y+1,0,1,player.flip,0,2,2)
--  end
--end

function draw_enemy()
  local s = tick%20//10 -- 0|1 every 1/6 secs
  spr(48+(s*2),enemy1.x,enemy1.y+1,0,1,enemy1.flip,0,2,2)
end

function draw()
  map()
--  draw_player()
  draw_enemy()
  print(string.format("%02d",game.level),115,10,1,true,1)
  print(string.format("%01d",game.lives),10,122,1,true,1)
  print(string.format("%06d",game.score1),40,0,1,true,1)
--  print(string.format("%06d",game.score2),180,0,1,true,1)
  print(string.format("%06d",tick),180,0,1,true,1)
end

function TIC()
--  input()
  update()
  draw()
end
