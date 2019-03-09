-- title:  nes_bubble_bobble
-- author: game developer
-- desc:   short description
-- script: lua

-- check collision on map
function coll(spr,dx,dy)
  return mget((spr.x+dx)//8,(spr.y+dy)//8)>0 or
      mget((spr.x+dx+15)//8,(spr.y+dy)//8)>0
end

JUMP = {4,4,3,3,3,2,2,2,1,1,1,1,1,1,0,0,
  0,0,-1,-1,-1,-1,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4}
SHOT = {2,2,2,2,2,2,2,2,4,4,4,4,4,4,6,6,6,6,6,6,8,8,8,8}

function init()
  tick = 0
  level = 1
  score1 = 0
  score2 = 0
  lives = 2
  player = {x=17,y=104,flip=0}
  jump = nil
  shot = nil
  enemy1 = {x=70,y=56,flip=0}
end

init()

function input()
  if btn(2) then player_move_x(-1) end
  if btn(3) then player_move_x(1) end
  if btn(4) then player_jump() end
  if btn(5) then player_shot() end
end

function player_move_x(x)
  if not coll(player,x,0) then
    player.x = player.x+x
    player.flip = (x<0) and 1 or 0
  end
end

function player_jump()
  if not jump then jump = {i=0} end
end

function player_shot()
  if not shot then
    shot = {x=player.x,y=player.y,flip=player.flip,i=0}
  end
end

function update_player_jump()
  if jump.i<#JUMP then
    jump.i = jump.i+1
    local y = JUMP[jump.i]
    player.y = player.y-y
    if y<=0 and coll(player,0,16) then
      jump = nil
    end
  else
    jump = nil
  end
end

function update_player_shot()
  if shot.i<#SHOT then
    shot.i = shot.i+1
    shot.id = 20+SHOT[shot.i]
    local f = (shot.flip==0) and 1 or -1
    shot.x = shot.x+(f*2)
  else
    shot = nil
  end
end

function update_player()
  if shot then update_player_shot() end
  if jump then update_player_jump()
  --gravity
  elseif not coll(player,0,16) then
    player.y = player.y+1
  end
end

function update()
  update_player()
end

function draw_player_shot()
  local s = shot
  spr(s.id,s.x,s.y,0,1,0,0,2,2)
end

function draw_player()
  if shot then
    draw_player_shot()
    spr(20,player.x,player.y+1,0,1,player.flip,0,2,2)
  else
    local s = tick%60//30 -- 0|1 every 1/2 secs
    spr(16+(s*2),player.x,player.y+1,0,1,player.flip,0,2,2)
  end
end

function draw_enemies()
  local s = tick%20//10 -- 0|1 every 1/6 secs
  spr(48+(s*2),enemy1.x,enemy1.y+1,0,1,enemy1.flip,0,2,2)
end

function draw()
  map()
  draw_player()
  draw_enemies()
  print(string.format("%02d",level),115,10,1,true,1)
  print(string.format("%01d",lives),10,122,1,true,1)
  print(string.format("%06d",score1),40,0,1,true,1)
  print(string.format("%06d",score2),180,0,1,true,1)
end

function TIC()
  tick = tick+1
  input()
  update()
  draw()
end
