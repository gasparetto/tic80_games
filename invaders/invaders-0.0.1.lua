-- title:  Space Invaders
-- author: game developer
-- desc:   short description
-- script: lua

-- $ cd ~/Projects/Games/tic80/invaders
-- $ tic80 invaders.tic -skip -code-watch invaders.lua

--------------------------------------------------------------------------------
-- INPUT

function input ()
  -- coin
  if keyp(32) and credit<99 then -- key 5
    credit=credit+1 
  end
  if game_mode==GM_ATTRACT then
    if keyp(28) and credit>0 then -- key 1
      game_init()
      game_mode=GM_RUN
    end
  elseif game_mode==GM_RUN then
    if player then
      -- player ship movement
      if btn(2) then -- left
        player.x=player.x-1
        if player.x<30 then player.x=30 end
      end
      if btn(3) then -- right
        player.x=player.x+1
        if player.x>194 then player.x=194 end
      end
      -- update player rect
      player.rx1=player.x+2
      player.rx2=player.x+15
      if btn(4) and player_shot==nil then -- button A = key Z
        player_shot_new()
      end
    end
  end
end

--------------------------------------------------------------------------------
-- UPDATE

function invdrs_shot_new ()
  local k=math.random(1,1000)
  if invdrs[k] then
    -- randomly choose one of the three shot types
    local i=math.random(1,3)
    if i==1 then id=32 elseif i==2 then id=36 elseif i==3 then id=40 end
    invdrs_shot={id=id,t=0,x=invdrs[k].x+8,y=invdrs[k].y+16}
  end
end

function player_shot_new ()
  if player then
    player_shot={x=player.x+8,y=player.y}
  end
end

function player_shot_collision ()
  for k,v in pairs(invdrs) do
    local invdr = v
    if player_shot.x>=invdr.rx1 and player_shot.x<=invdr.rx2 then
      if player_shot.y>=invdr.ry1 and player_shot.y<=invdr.ry2 then
        invdrs_expl={id=12,t=6,x=invdr.x,y=invdr.y}
        invdrs[k]=nil
        player_shot=nil
        score_1=score_1+invdr.val
        return
      end
    end
  end
end

function invdrs_shot_collision ()
  if player then
    if invdrs_shot.x>=player.rx1 and invdrs_shot.x<=player.rx2 then
      if invdrs_shot.y>=player.ry1 and invdrs_shot.y<=player.ry2 then
        player_expl={id=50,t=6,x=player.x,y=player.y}
        player=nil
        invdrs_shot=nil
        lives=lives-1
        return
      end
    end
  end
end

function invdrs_shot_update ()
  if invdrs_shot then
    invdrs_shot.y=invdrs_shot.y+1
    if invdrs_shot.y<128 then
      if invdrs_shot.t<16 then
        invdrs_shot.t=invdrs_shot.t+1
      else
        invdrs_shot.t=0
      end
      invdrs_shot_collision()
    else
      invdrs_shot=nil
    end
  else
    invdrs_shot_new()
  end
end

function player_shot_update ()
  if player_shot then 
    player_shot.y=player_shot.y-3
    if player_shot.y>0 then
      player_shot_collision()
    else
      player_shot=nil
    end
  end
end

function update ()
  if game_mode==GM_DEMO or game_mode==GM_RUN then
    player_shot_update()
    invdrs_shot_update()
  end
end

--------------------------------------------------------------------------------
-- DRAW

function invdrs_shot_draw ()
  if invdrs_shot then
    spr(invdrs_shot.id+(invdrs_shot.t/4),invdrs_shot.x-3,invdrs_shot.y-7,0)
  end
end

function player_shot_draw ()
  if player_shot then 
    spr(54,player_shot.x-3,player_shot.y-8,0)
  end
end

function invdrs_expl_draw ()
  if invdrs_expl then
    spr(invdrs_expl.id,invdrs_expl.x,invdrs_expl.y,-1,1,0,0,2,1)
    invdrs_expl.t=invdrs_expl.t-1
    if invdrs_expl.t==0 then invdrs_expl=nil end
  end
end

function player_expl_draw ()
  if player_expl then
    spr(player_expl.id,player_expl.x,player_expl.y,-1,1,0,0,2,1)
    player_expl.t=player_expl.t-1
    if player_expl.t==0 then
      player_expl=nil
      player_init()
    end
  end
end

function shields_draw ()
  spr(64,48,96,-1,1,0,0,3,2)
  spr(64,88,96,-1,1,0,0,3,2)
  spr(64,128,96,-1,1,0,0,3,2)
  spr(64,168,96,-1,1,0,0,3,2)
end

function invdrs_draw ()
  local s=t%60//30*2
  for k,v in pairs(invdrs) do
    local invdr = v
    spr(invdr.id+s,invdr.x,invdr.y,-1,1,0,0,2,1)
  end
end

function player_draw ()
  if player then
    spr(player.id,player.x,player.y,-1,1,0,0,2,1)
  end
end

function draw_game ()
  -- score
  font("SCORE<1> HI-SCORE SCORE<2>",16,0,0,8,0,1,1)
  font(string.format("%04d    %04d      %04d",score_1,hi_score,score_2),
    32,10,0,8,0,1,1)
  if lives>0 then
    -- invaders
    invdrs_draw()
    invdrs_expl_draw()
    invdrs_shot_draw()
  else
    -- game over
    font("GAME OVER",84,50,0,8,0,1,1)
  end
  -- shields, player
  shields_draw()
  player_draw()
  player_expl_draw()
  player_shot_draw()
  -- lives, remaining ships
  line(0,127,240,127,11)
  for i=1,lives-1 do
    spr(48,4+(i*16),128,-1,1,0,0,2,1)
  end
  font(tonumber(lives),4,128,0,8,0,1,1)
  -- credit
  font(string.format("CREDIT %02d",credit),150,128,0,8,0,1,1)
end

function draw_attract_screen ()
  -- score
  font("SCORE<1> HI-SCORE SCORE<2>",16,0,0,8,0,1,1)
  font(string.format("%04d    %04d      %04d",score_1,hi_score,score_2),
    32,10,0,8,0,1,1)
  -- center of screen change every 3 secs
  if ((t//180)%2)==0
  then
    -- score advance table
    font("SPACE  INVADERS",60,36,3,8,0,1,1)
    font("*SCORE ADVANCE TABLE*",36,60,0,8,0,1,1)
    spr(16,64,y+10,-1,1,0,0,3,1)
    font("=? MYSTERY",86,70,0,8,0,1,1)
    spr(8,68,y+20,-1,1,0,0,2,1)
    font("=30 POINTS",86,80,0,8,0,1,1)
    spr(4,68,y+30,-1,1,0,0,2,1)
    font("=20 POINTS",86,90,0,8,0,1,1)
    spr(0,68,y+40,-1,1,0,0,2,1)
    font("=10 POINTS",86,100,0,8,0,1,1)
  else
    -- insert coin
    font("INSERT COIN",76,46,3,8,0,1,1)
    font("<1 OR 2 PLAYERS>",56,66,3,8,0,1,1)
    font("*1 PLAYER  1 COIN",56,76,3,8,0,1,1)
    font("*2 PLAYERS 2 COINS",56,86,3,8,0,1,1)
    font("3",4,128,0,8,0,1,1)
    spr(48,20,128,-1,1,0,0,2,1)
    spr(48,36,128,-1,1,0,0,2,1)
  end
  -- credit
  font(string.format("CREDIT %02d",credit),150,128,0,8,0,1,1)
end

function draw ()
  cls(0)
  if game_mode==GM_ATTRACT then
    draw_attract_screen()
  elseif game_mode==GM_DEMO or game_mode==GM_RUN then
    draw_game()
  end
end

--------------------------------------------------------------------------------
-- INIT

function player_init ()
  -- fixme player rect
  player={id=48,x=30,y=116,rx1=32,ry1=116,rx2=45,ry2=124}
  player_expl=nil
  player_shot=nil
end

function invdrs_init ()
  invdrs={}
  for x=1,8 do
    x=24+(x*20); y=30
    invdrs[#invdrs+1]={id=8,val=30,x=x,y=y,rx1=x+4,ry1=y,rx2=x+12,ry2=y+8}
  end
  for x=1,8 do
    x=24+(x*20); y=44
    invdrs[#invdrs+1]={id=4,val=20,x=x,y=y,rx1=x+2,ry1=y,rx2=x+13,ry2=y+8}
  end
  for x=1,8 do
    x=24+(x*20); y=58
    invdrs[#invdrs+1]={id=0,val=10,x=x,y=y,rx1=x+2,ry1=y,rx2=x+14,ry2=y+8}
  end
  invdrs_expl=nil
  invdrs_shot=nil
end

function game_init ()
  -- reset game state
  score_1=0
  score_2=0
  lives=3
  player_init()
  invdrs_init()
end

function game_over ()
  for i=1,#invdrs do
    invdrs[i]=nil
  end
end

function init ()
  t=0
  -- game mode
  GM_ATTRACT,GM_DEMO,GM_RUN=0,1,2
  game_mode=GM_RUN
  -- game state
  credit=0
  lives=0
  hi_score=0
  score_1=0
  score_2=0
  game_init()
end

init()

--------------------------------------------------------------------------------
-- MAIN LOOP

function TIC ()
  t=t+1
  input()
  update()
  draw()
end

--------------------------------------------------------------------------------
