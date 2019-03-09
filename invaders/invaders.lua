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
  if keyp(32) and game.credit<99 then -- key 5
    game.credit=game.credit+1 
  end
  if game.mode==GM_ATTRACT then
    if keyp(28) and game.credit>0 then -- key 1
      game.credit=game.credit-1 
      game.mode=GM_RUN
      player_init()
      invdrs_init()
    end
  elseif game.mode==GM_RUN then
    if player.mode==PM_INGAME then
      -- player ship movement
      if btn(2) then -- left
        player.x=player.x-1
        if player.x<30 then player.x=30 end
      end
      if btn(3) then -- right
        player.x=player.x+1
        if player.x>194 then player.x=194 end
      end
      if btn(4) and player.shot==nil then -- button A = key Z
        player_shot_new()
      end
    end
  end
end

--------------------------------------------------------------------------------
-- UPDATE

-- function player_respawn ()
--   -- fixme player rect
--   -- player={id=48,x=30,y=116,rx1=32,ry1=116,rx2=45,ry2=124}
--   -- player_expl=nil
--   -- player_shot=nil
--   if lives>0 then
--     player={
--       mode=PM_INGAME,
--       id=48,x=30,y=116,
--       expl=nil,
--       shot=nil
--     }
--   else
--     player.mode=PM_GAMEOVER
--   end
-- end

function invdrs_shot_new ()
  local col=math.random(1,8)
  local id=nil
  if invdrs[col+16] then
    invdrs_shot={id=40,t=0,x=invdrs[col+16].x+8,y=invdrs[col+16].y+16}
  elseif invdrs[col+8] then
    invdrs_shot={id=36,t=0,x=invdrs[col+8].x+8,y=invdrs[col+8].y+16}
  elseif invdrs[col] then
    invdrs_shot={id=32,t=0,x=invdrs[col].x+8,y=invdrs[col].y+16}
  end
-- local k=math.random(1,1000)
--   if invdrs[k] then
--     -- randomly choose one of the three shot types
--     local i=math.random(1,3)
--     if i==1 then id=32 elseif i==2 then id=36 elseif i==3 then id=40 end
--     invdrs_shot={id=id,t=0,x=invdrs[k].x+8,y=invdrs[k].y+16}
--   end
end

function player_shot_new ()
  player.shot={x=player.x+8,y=player.y}
end

function check_player_shot_collision ()
  for k,v in pairs(invdrs) do
    if v.id==8 then r={x1=v.x+4,y1=v.y,x2=v.x+12,y2=v.y+8}
      elseif v.id==4 then r={x1=v.x+2,y1=v.y,x2=v.x+13,y2=v.y+8}
      elseif v.id==0 then r={x1=v.x+2,y1=v.y,x2=v.x+14,y2=v.y+8}
    end
    if player.shot.x>=r.x1 and player.shot.x<=r.x2 and
        player.shot.y>=r.y1 and player.shot.y<=r.y2 then
      invdrs_expl={id=12,t=0,x=v.x,y=v.y}
      invdrs[k]=nil
      player.shot=nil
      player.score=player.score+v.val
      return
    end
  end
end

function invdrs_shot_collision ()
  r={x1=player.x+2,y1=116,x2=player.x+15,y2=124}
  if invdrs_shot.x>=r.x1 and invdrs_shot.x<=r.x2 and
      invdrs_shot.y>=r.y1 and invdrs_shot.y<=r.y2 then
    player.game=PM_EXPLDNG
    player.expl={id=50,t=0,x=player.x,y=player.y}
    invdrs_shot=nil
    player.lives=player.lives-1
    return
  end
end

function invdrs_update ()
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
  if invdrs_expl then
    invdrs_expl.t=invdrs_expl.t+1
    if invdrs_expl.t==6 then invdrs_expl=nil end
  end
end

function player_update ()
  if player.mode==PM_INGAME then
    if player.shot then 
      player.shot.y=player.shot.y-3
      if player.shot.y>0 then
        check_player_shot_collision()
      else
        player.shot=nil
      end
    end
  elseif player.mode==PM_EXPLDNG then
    player.expl.t=player.expl.t+1
    if player.expl.t==6 then
      player.expl=nil
      player.mode=PM_EXPLDED
    end
  elseif player.mode==PM_EXPLDED then
      -- player_init()
  end
end

function update ()
  if game.mode==GM_DEMO or game.mode==GM_RUN then
    player_update()
    invdrs_update()
  end
end

--------------------------------------------------------------------------------
-- DRAW

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
  if invdrs_expl then
    spr(invdrs_expl.id,invdrs_expl.x,invdrs_expl.y,-1,1,0,0,2,1)
  end
  if invdrs_shot then
    spr(invdrs_shot.id+(invdrs_shot.t/4),invdrs_shot.x-3,invdrs_shot.y-7,0)
  end
end

function player_draw ()
  if player.mode==PM_INGAME then
    spr(player.id,player.x,player.y,-1,1,0,0,2,1)
    if player.shot then 
      spr(54,player.shot.x-3,player.shot.y-8,0)
    end
  elseif player.mode==PM_EXPLDNG then
    spr(player.expl.id,player.expl.x,player.expl.y,-1,1,0,0,2,1)
  end
end

function draw_game ()
  -- score
  font("SCORE<1> HI-SCORE SCORE<2>",16,0,0,8,0,1,1)
  font(string.format("%04d    %04d      %04d",
    player.score,game.hi_score,game.score_2), 32,10,0,8,0,1,1)
  -- invaders
  invdrs_draw()
  -- if lives>0 then
  -- else
  --   -- game over
  --   font("GAME OVER",84,50,0,8,0,1,1)
  -- end
  -- shields
  shields_draw()
  -- player
  player_draw()
  -- lives, remaining ships
  line(0,127,240,127,11)
  for i=1,player.lives-1 do
    spr(48,4+(i*16),128,-1,1,0,0,2,1)
  end
  font(tonumber(player.lives),4,128,0,8,0,1,1)
  -- credit
  font(string.format("CREDIT %02d",game.credit),150,128,0,8,0,1,1)
end

function draw_attract_screen ()
  -- score
  font("SCORE<1> HI-SCORE SCORE<2>",16,0,0,8,0,1,1)
  font(string.format("%04d    %04d      %04d",
    game.score_1,game.hi_score,game.score_2), 32,10,0,8,0,1,1)
  -- center of screen change every 3 secs
  if ((t//180)%2)==0
  then
    -- score advance table
    font("SPACE  INVADERS",60,36,3,8,0,1,1)
    font("*SCORE ADVANCE TABLE*",36,60,0,8,0,1,1)
    spr(16,64,70,-1,1,0,0,3,1)
    font("=? MYSTERY",86,70,0,8,0,1,1)
    spr(8,68,80,-1,1,0,0,2,1)
    font("=30 POINTS",86,80,0,8,0,1,1)
    spr(4,68,90,-1,1,0,0,2,1)
    font("=20 POINTS",86,90,0,8,0,1,1)
    spr(0,68,100,-1,1,0,0,2,1)
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
  font(string.format("CREDIT %02d",game.credit),150,128,0,8,0,1,1)
end

function draw ()
  cls(0)
  if game.mode==GM_ATTRACT then
    draw_attract_screen()
  elseif game.mode==GM_DEMO or game.mode==GM_RUN then
    draw_game()
  end
end

--------------------------------------------------------------------------------
-- INIT

function invdrs_init ()
  invdrs={}
  for col=1,8 do
    x=24+(col*20)
    invdrs[#invdrs+1]={id=8,x=x,y=30,val=30}
    invdrs[#invdrs+1]={id=4,x=x,y=44,val=20}
    invdrs[#invdrs+1]={id=0,x=x,y=58,val=10}
  end
end

function player_init ()
  PM_SCORE,PM_WAIT,PM_INGAME,PM_EXPLDNG,PM_EXPLDED,PM_GAMEOVER=0,1,2,4,8,16
  player={
    mode=PM_INGAME,
    t=0,
    id=48,
    x=30,y=116,
    -- rx1=32,ry1=116,rx2=45,ry2=124,
    -- expl=nil,
    -- shot=nil,
    lives=3,
    score=0
  }
end

-- function game_over ()
--   for i=1,#invdrs do
--     invdrs[i]=nil
--   end
-- end

function init ()
  t=0
  GM_ATTRACT,GM_DEMO,GM_RUN=0,1,2
  game={
    mode=GM_ATTRACT,
    credit=0,
    score_1=0,
    score_2=0,
    hi_score=0
  }
end

init()

--test
-- game.mode=GM_RUN
-- player_init()
-- invdrs_init()

--------------------------------------------------------------------------------
-- MAIN LOOP

function TIC ()
  t=t+1
  input()
  update()
  draw()
end

--------------------------------------------------------------------------------
