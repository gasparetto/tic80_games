-- title:  nes_bubble_bobble
-- author: game developer
-- desc:   short description
-- script: lua

-- https://www.wikiwand.com/it/Bubble_Bobble
-- https://tcrf.net/Bubble_Bobble_(NES)
-- https://www.spriters-resource.com/nes/bublbobl/

---------------------------------------------------------
-- todo
--[[

☑ map
☑ player with sprites, collision, states
☑ player jump
☑ enemy and ai
☑ lua classes and inheritance
☑ levels and loading with keys 1->3
☑︎ player shot
☑ bubble objects and lifecycle
☑ bubble to bubble collision
☑ bubble to map collision
☑ player to bubbles collision
☑ enemy die
☑ player die and respawn
☑ bubble to enemy collision and enemy trap
☐ death animation
☐ hurry-up and enemies rage after 60"
☐ whale after another 15"
☐ better enemy ai
☐ score
☐ gameover
☐ more levels and enemies
☐ bottom holes and wrap to top
☐ items
☐ new level intro
☐ game intro

]]--

---------------------------------------------------------
-- init and constants

math.randomseed(1)

-- delta x added to a body every frame when running
SPEED=1.0
-- delta y added to a body every frame when falling
GRAVITY=0.75
-- when jumping or falling the speed is reduced by
-- this factor
FRICTION=0.4
-- bubbles speed when floating
BUBBLE_SPEED=0.4
-- bubbles top limit
BUBBLE_TOP=20
-- bubbles minimum distance
BUBBLE_DISTANCE=14

tick=0
game={score1=0,score2=0,lives=2}
levels={
  {idx=1,textcolor=1,map={x=0,y=0}},
  {idx=2,textcolor=12,map={x=30,y=0}},
  {idx=3,textcolor=9,map={x=60,y=0}},
}
level=nil
player1=nil
enemies={}
bubbles={}

---------------------------------------------------------
-- utils

-- return the first index of the element in table
function table_findfirst(t,e)
  for i,v in pairs(t) do
    if v==e then return i end
  end
end

-- return an array with the "jump path" steps
-- is an exponential curve like:
-- https://www.desmos.com/calculator
-- y=1-(x-1)^2
-- params: width, height, steps
function build_jump_path(w,h,s)
  local arr={}; local x0=0; local y0=0
  for i=1,s do
    local x=i/(s/2)
    local y=1-(x-1)^2
    arr[i]={x=w*(x-x0),y=h*(y-y0)}
    x0=x; y0=y
  end
  return arr
end

-- return an array with the "shot path" steps
-- is a linear array with sprite id and x delta pos
function build_shot_path()
  local arr={}; local steps=40; local xd=1.5
  for i=1,steps do
    local id=66+(i//(steps/4))*2 -- id={66|68|70|72}
    arr[i]={id=id,x=xd}
  end
  return arr
end

---------------------------------------------------------
-- generic bubble class
-- represent a player bubble

local Bubble = {}
Bubble.__index = Bubble

--constructor
function Bubble.new(x, y)
  local self = {
    -- current position
    x=x, y=y,
    -- frame counter
    tick=0,
    -- state
    -- 0 = float to top
    -- 1 = at top move to center
    -- 2 = exploding
    state=0,
    -- state frame counter
    state_tick=0,
    -- enemy trapped inside
    enemy=nil,
  }
	-- set Bubble as prototype for the new instance
	setmetatable(self, Bubble)
  return self
end --Bubble.new

-- check if the bubble is too close to another
-- bubble, and if so get away
function Bubble:get_away_if_too_close(v)
  -- linear distance to the other bubble
  local d=math.sqrt(
      math.pow(self.x-v.x,2)+math.pow(self.y-v.y,2))
  if d<BUBBLE_DISTANCE then
    local dx=self.x-v.x
    local dy=self.y-v.y
    self.x=self.x+((dx<0) and -2 or 2)
    self.y=self.y+((dy<0) and -1 or 2)
    local limit=BUBBLE_TOP-8
    if self.y<limit then self.y=limit end
  end
end

-- slowly move the bubble to the top
function Bubble:float_to_top()
  if self.y>BUBBLE_TOP then
    self.y=self.y-BUBBLE_SPEED
  end
end

-- slowly move the bubble to the X center
function Bubble:float_to_center()
  local d=120-self.x -- distance to W/2
  if d<-4 or d>4 then
    local dx=(d>0) and 0.2 or -0.2
    self.x=self.x+dx
  end
end

-- shake the bubble vertically
function Bubble:shake_vertically()
  local i=self.tick%10 -- 0->10
  if i==0 then i=-1 elseif i==5 then i=1 else i=0 end
  self.y=self.y+i
end

-- check for bubble end of life
function Bubble:check_for_eol()
  if self.tick>1500 then -- 25 secs
    self:explode()
  end
end

-- start the animation to explode the bubble
function Bubble:explode()
  if self.state<2 then
    self.state=2
    self.state_tick=0
  end
end

function Bubble:update()
  self.tick=self.tick+1
  self.state_tick=self.state_tick+1
  if self.state==0 then
    -- float to top
    self:float_to_top()
    if self.y<BUBBLE_TOP then
      self.state=1
      self.state_tick=0
    end
    self:check_for_eol()
  elseif self.state==1 then
    -- at top move to center
    self:float_to_top()
    self:float_to_center()
    self:shake_vertically()
    self:check_for_eol()
  elseif self.state==2 then
    -- exploding
    if self.state_tick>10 then
      bubble_expired(self)
    end
  end
end

function Bubble:draw()
  if self.state==0 or self.state==1 then
    -- float to top | at top move to center
    local id=0; local flip=0
    if not self.enemy then
      if self.tick>1200 then -- 20 secs
        local i=(self.state_tick%10)//5 -- 0|1
        id=72+(i*2) -- flashing bubble green|red
      elseif self.tick>900 then -- 15 secs
        id=74 -- red bubble
      else
        id=72 -- green bubble
      end
    else
      local i=(self.state_tick%60)//30 -- 0|1
      flip=i
      if self.tick>1200 then -- 20 secs
        id=self.enemy.trapped_id[2] -- trapped red
      else
        id=self.enemy.trapped_id[1] -- trapped green
      end
    end
    spr(id,self.x,self.y+1,0,1,flip,0,2,2)
  elseif self.state==2 then
    -- exploding
    local id=76 -- exploding bubble
    if self.state_tick>5 then id=78 end -- pon
    spr(id,self.x,self.y+1,0,1,0,0,2,2)
  end
end


---------------------------------------------------------
-- generic body class
-- represent a moving actor, like the player or an emeny

local Body = {}
Body.__index = Body

--constructor
function Body.new(x, y)
  local self = {
    -- current position
    x=x, y=y,
    -- desired new position (delta)
    dx=0, dy=0,
    -- direction of the body (-1 face left, 1 right)
    dir=1,
    -- tick is a frame counter for the sprite animation
    -- reset when the body state change
    tick=0,
    -- body state used for sprite selection
    -- 1 wait, 2 run, 3 jump, 4 fly, 5 shot
    state=1,
    -- true when the body is falling (flying)
    fly=false,
    -- true when the body is dying
    die=false,
    die_id=96,
    -- sprite id table
    id={
      {32,32,34,34}, --wait
      {36,38,32,34}, --run
      {40,40,42,42}, --jump
      {46,46,44,44}, --fly
      {64,64,64,64}, --shot
    },
    -- jump properties, are always present
    -- body is jumping when jump.idx is > 0
    jump={
      -- jump direction (0 up, -1 left, +1 right)
      dir=0,
      -- current step index (0->#steps)
      idx=0,
      -- steps: array of x,y values for the jump
      -- values for a jump with X movement
      steps_xy=build_jump_path(30,33,60),
      -- values for an "up" jump without X movement
      steps_y=build_jump_path(0,33,60),
    },
    -- shot properties, are always present
    -- body is shooting when shot.idx is > 0
    shot={
      -- shot position
      x=0,y=0,
      -- shot sprite index
      id=0,
      -- shot direction (-1 left, +1 right)
      dir=0,
      -- current step index (0->#steps)
      idx=0,
      -- steps: array of sprite idx for the shot
      steps=build_shot_path(),
    },
  }
	-- set Body as prototype for the new instance
	setmetatable(self, Body)
  return self
end --Body.new

-- check collision with the map tiles
function Body:collide_map(dx,dy)
  local x=self.x+dx; local y=self.y+dy
  local map=level.map
  return mget(map.x+x//8,map.y+(y+15)//8)>0 or
      mget(map.x+(x+15)//8,map.y+(y+15)//8)>0
end --Body:collide_map

-- set the body for a left move
function Body:go_left()
  self.dx=-SPEED
  self.dir=-1
end

-- set the body for a right move
function Body:go_right()
  self.dx=SPEED
  self.dir=1
end

-- set the body for a jump
-- params: dir 0=up, -1=left, 1=right
function Body:do_jump(dir)
  if self.jump.idx==0 and not self.fly then
    self.jump.idx=1
    self.jump.dir=dir
  end
end

-- set the body for a shot
-- params: dir -1=left, 1=right
function Body:do_shot(dir)
  if self.shot.idx==0 then
    self.shot.idx=1
    self.shot.x=self.x
    self.shot.y=self.y
    self.shot.dir=self.dir
  end
end

-- start the death animation
function Body:do_die()
  if not self.die then
    self.tick=0
    self.jump.idx=0
    self.shot.idx=0
    self.fly=false
    self.die=true
  end
end

-- set the body for the next move
-- input is provided manually
function Body:input(left,right,jump,shot)
  if self.die then return end
  if left then
    self:go_left()
  elseif right then
    self:go_right()
  end
  local dir=left and -1 or (right and 1 or 0)
  if jump then self:do_jump(dir)end
  if shot then self:do_shot() end
end --Body:input

function Body:update_shot()
  if self.shot.idx==0 then return end
  local step=self.shot.steps[self.shot.idx]
  self.shot.id=step.id
  local dx=step.x*self.shot.dir
  if not collide_bounds(self.shot.x+dx) then
    self.shot.x=self.shot.x+dx
  end
  self.shot.idx=self.shot.idx+1
  if self.shot.idx>#self.shot.steps then
    self.shot.idx=0
    add_bubble(self.shot.x, self.shot.y)
  end
end

function Body:update_jump()
  if self.jump.idx==0 then return nil end
  local step=nil
  local steps=self.jump.dir~=0
      and self.jump.steps_xy or self.jump.steps_y
  step=steps[self.jump.idx]
  if self.jump.dir<0 then
    self.dx=(self.dx>0) and self.dx or 0
  elseif self.jump.dir>0 then
    self.dx=(self.dx<0) and self.dx or 0
  end
  self.dx=self.dx+(step.x*self.jump.dir)
  self.dy=self.dy-step.y
  self.jump.idx=(self.jump.idx<#steps)
      and (self.jump.idx+1) or 0
  return step
end

-- update the body position and action according to the
-- last input changes
function Body:update()
  self.tick=self.tick+1
  --slow down speed if jump or fly
  if self.jump.idx>0 or self.fly then
    self.dx=self.dx*FRICTION
  end
  --shot
  self:update_shot()
  --jump
  local jump_step=self:update_jump()
  --move
  if self.dx~=0 or self.dy~=0 then
    if jump_step then
      --jumping
      if self.dy<0 then --jumping up
        --jumping up so no collision with platforms
        if collide_bounds(self.x+self.dx) then
          self.y=self.y+self.dy
        else
          self.x=self.x+self.dx
          self.y=self.y+self.dy
        end
      else --jumping down
        if self:collide_map(self.dx,self.dy) then
          self.jump.idx=0        
        else
          self.x=self.x+self.dx
          self.y=self.y+self.dy
        end
      end
    else --if jump_step
      --running or flying
      if not self:collide_map(self.dx,self.dy) then
        self.x=self.x+self.dx
        self.y=self.y+self.dy
      end
    end
  end --if self.dx~=0 or self.dy~=0
  --check gravity if not jumping
  if not jump_step then
    self.fly=false
    if not self:collide_map(0,GRAVITY) then
      self.fly=true
      self.dy=GRAVITY
      self.y=self.y+self.dy
    end
  end
  -- movement state
  local state=1 --wait
  if self.shot.idx>0 then
    state=5 --shot
  elseif jump_step and jump_step.y>0 then
    state=3 --jump
  elseif (jump_step and jump_step.y<0) or self.fly then
    state=4 --fly
  elseif self.dx~=0 then
    state=2 --run
  end
  if self.state~=state then self.tick=0 end
  self.state=state
  -- cleanup
  self.dx=0
  self.dy=0
end --Body:update

-- draw the body on the screen
function Body:draw()
  -- draw shot
  if self.shot.idx>0 then
    local shot=self.shot
    spr(shot.id,shot.x,shot.y,0,1,0,0,2,2)
  end
  -- draw body
  local id=0; local flip=0; local rotate=0
  flip=(self.dir==-1) and 1 or 0
  -- 1|2|3|4 every 1/4 secs
  local frame=(self.tick%60//15)+1
  if self.die then -- sprite is rotating
    id=self.die_id
    -- 0|1|2|3 every 1/6 secs
    rotate=(self.tick%40//10)+1
  else -- normal sprite based on movement state
    id=self.id[self.state][frame]
  end
  spr(id,self.x,self.y+1,0,1,flip,rotate,2,2)
end --Body:draw

function Body:tostring()
  return string.format(
    "x=%.0f,y=%.0f,dx=%.2f,dy=%.2f,j=%d,f=%d,s=%d",
    self.x,self.y,self.dx,self.dy,self.jump.idx,
    self.fly and 1 or 0,self.state)
end --Body:tostring


---------------------------------------------------------
-- player class

local Player = setmetatable({}, {__index = Body})
Player.__index = Player

function Player.new(x, y)
	local self = setmetatable(Body.new(x, y), Player)
  -- true when the body is respawning (is invincible)
  self.respawn=false
  self.respawn_tick=0
	return self
end

function Player:update()
  if self.die then
    self.tick=self.tick+1
    if self.tick>120 then self:do_respawn() end
    return
  end
  if self.respawn then
    self.respawn_tick=self.respawn_tick+1
    if self.respawn_tick>120 then self.respawn=false end
  end
  Body.update(self)
end

function Player:draw()
  if self.respawn then -- sprite is flashing
    -- 0|1 every 1/12 secs
    local flash=(self.respawn_tick%10//5)
    if flash==1 then return end
  end
  Body.draw(self)
end

function Player:do_respawn()
  if not self.respawn then
    self.x=17; self.y=104
    self.respawn=true
    self.respawn_tick=0
    self.jump.idx=0
    self.shot.idx=0
    self.fly=false
    self.die=false
  end
end


---------------------------------------------------------
-- enemy class

local Enemy = setmetatable({}, {__index = Body})
Enemy.__index = Enemy

function Enemy.new(x, y)
	local self = setmetatable(Body.new(x, y), Enemy)
  self.state=4 -- start flying
  self.dir=-1
  self.id={256,258}
  self.trapped_id={266,268}
  self.die_id=264
  local j=self.jump
  j.steps_xy=build_jump_path(33,20,60)
  j.steps_y=build_jump_path(0,33,60)
	return self
end

-- move the enemy based on AI rules
function Enemy:input(left,right,jump,shot)
  --do nothing if jumping or flying
  if self.state==3 or self.state==4 then return end
  --randomly jump or fall if next to a hole
  if self:collide_map(14*self.dir,1)
      and not self:collide_map(15*self.dir,1) then
    local v = math.random(100)
    if v>50 then self:do_jump(self.dir); return end
  end
  --randomly jump up if on a spot
  local x=math.floor(self.x)
  local y=math.floor(self.y)
  if (x==68 or x==156) and y~=40 then
    local v = math.random(100)
    --trace("v:"..v..",x:"..x..",y:"..y)
    if v>50 then self:do_jump(0); return end
  end
  --flip if colliding with a wall
  if self:collide_map(self.dir,-1) then
    self.dir=self.dir*-1
  end
  --run
  if self.dir==-1 then
    self:go_left()
  elseif self.dir==1 then
    self:go_right()
  end
end

function Enemy:update()
  if self.die then
    self.tick=self.tick+1
    if self.tick>120 then remove_enemy(self) end
    return
  end
  Body.update(self)
end

function Enemy:draw()
  local id=0; local flip=0; local rotate=0
  flip=(self.dir==-1) and 1 or 0
  if self.die then -- sprite is rotating
    id=self.die_id
    -- 0|1|2|3 every 1/6 secs
    rotate=(self.tick%40//10)+1
  else -- normal sprite based on movement state
  -- 1|2 every 1/4 secs
    local frame=(tick%20//10)+1
    id=self.id[frame]
  end
  spr(id,self.x,self.y+1,0,1,flip,rotate,2,2)
end


---------------------------------------------------------

function init_level(i)
  level=levels[i]
  player1=Player.new(17,104)
  bubbles={}
  enemies={}
  add_enemy(112,-20)
  add_enemy(112,-34)
  add_enemy(112,-48)
end

-- check collision with the X left and right bounds
function collide_bounds(x)
  return x<16 or (x+15)>224
end

-- https://stackoverflow.com/a/306332/942043
function rect_overlap(a,b)
  return a.x<(b.x+16) and (a.x+16)>b.x
      and a.y<(b.y+16) and (a.y+16)>b.y
end

function add_bubble(x,y)
  local bubble=Bubble.new(x, y)
  table.insert(bubbles,bubble)
  return bubble
end

function remove_bubble(v)
  local i=table_findfirst(bubbles,v)
  table.remove(bubbles,i)
end

function add_enemy(x,y)
  local enemy=Enemy.new(x, y)
  table.insert(enemies,enemy)
  return enemy
end

function remove_enemy(v)
  local i=table_findfirst(enemies,v)
  table.remove(enemies,i)
end

-- remove the bubble and free the trapped enemy
function bubble_expired(v)
  if v.enemy then free_enemy_from_bubble(v) end
  remove_bubble(v)
end

function trap_enemy(enemy)
  local bubble=add_bubble(enemy.x,enemy.y)
  bubble.enemy=enemy
  remove_enemy(enemy)
end

function free_enemy_from_bubble(bubble)
  local enemy=bubble.enemy
  enemy.x=bubble.x; enemy.y=bubble.y
  table.insert(enemies,enemy)    
  bubble.enemy=nil
  return enemy
end

function distribute_bubbles()
  for _,v1 in pairs(bubbles) do
    for _,v2 in pairs(bubbles) do
      if v1~=v2 then v1:get_away_if_too_close(v2) end
    end
  end
end

function check_player_shot_vs_enemies()
  local shot=player1.shot
  if shot.idx==0 then return end
  for _,v in pairs(enemies) do
    if rect_overlap(shot,v) then
      shot.idx=0
      trap_enemy(v)
      break
    end
  end
end

function check_player_vs_enemies()
  if player1.respawn then return end -- invincible
  for _,v in pairs(enemies) do
    if not v.die and rect_overlap(player1,v) then
      player1:do_die()
    end
  end
end

function check_player_vs_bubbles()
  for _,v in pairs(bubbles) do
    if rect_overlap(player1,v) then
      if v.enemy then
        local enemy=free_enemy_from_bubble(v)
        enemy:do_die()
      end
      v:explode()
    end
  end
end

function input()
  if key(28) then init_level(1)
    elseif key(29) then init_level(2)
    elseif key(30) then init_level(3)
  end
  player1:input(btn(2),btn(3),btn(4),btn(5))
  for _,e in pairs(enemies) do e:input() end
end

function update()
  tick = tick+1
  -- update actors
  player1:update()
  for _,v in pairs(enemies) do v:update() end
  for _,v in pairs(bubbles) do v:update() end
  -- game logic
  local i=tick%10
  if i==0 then -- every 1/6 sec
    check_player_shot_vs_enemies()
    check_player_vs_enemies()
    check_player_vs_bubbles()
    distribute_bubbles()
  end
end

function draw()
  map(level.map.x,level.map.y)
  player1:draw()
  for _,v in pairs(enemies) do v:draw() end
  for _,v in pairs(bubbles) do v:draw() end
  local c = level.textcolor
  print(string.format("%02d",level.idx),115,10,c,true,1)
  print(string.format("%01d",game.lives),10,122,c,true,1)
  print(string.format("%07d",game.score1),22,0,c,true,1)
  print(string.format("%07d",game.score2),178,0,c,true,1)
  --print(player1:tostring(),0,0,c)
end

init_level(1)

function TIC()
  input()
  update()
  draw()
end
