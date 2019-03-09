-- title:  nes_bubble_bobble
-- author: game developer
-- desc:   short description
-- script: lua

---------------------------------------------------------
-- todo
--[[

* player shot
* bubble object and lifecycle
* player to bubbles collision
* bubble to enemy collision and enemy trap
* enemy bubble collision and reward items
* player to enemy collision
* player death and restart
* better enemy ai
* score
* gameover
* more levels and enemies
* bottom holes and wrap to top
* hurry and whale
* items
* new level intro
* game intro

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

tick=0
game={score1=0,score2=0,lives=2}
levels={
  {idx=1,textcolor=1,map={x=0,y=0}},
  {idx=2,textcolor=12,map={x=30,y=0}},
  {idx=3,textcolor=9,map={x=60,y=0}},
}

---------------------------------------------------------
-- utils

-- return an array with the "jump path" steps
-- is an exponential curve like this:
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
    -- 1 wait, 2 run, 3 jump, 4 fly
    state=1,
    -- true when the body is falling (flying)
    fly=false,
    id={
      {16,16,18,18}, --wait
      {20,22,16,18}, --run
      {24,24,26,26}, --jump
      {28,28,30,30}, --fly
    },
    -- jump properties, are always present
    -- body is jumping when jump.idx is > 0
    jump={
      -- current step index (0 to max steps)
      idx=0,
      -- jump direction (0 up, -1 left, +1 right)
      dir=0,
      -- array of x,y values for the jump
      -- values for a jump with X movement
      path_xy=build_jump_path(30,33,60),
      -- values for an "up" jump without X movement
      path_y=build_jump_path(0,33,60),
    },
  }
	-- set Body as prototype for the new instance
	setmetatable(self, Body)
  return self
end --Body.new

-- check collision with the map tiles
function Body:collide(dx,dy)
  local x=self.x+dx; local y=self.y+dy
  local map=level.map
  return mget(map.x+x//8,map.y+(y+15)//8)>0 or
      mget(map.x+(x+15)//8,map.y+(y+15)//8)>0
end --Body:collide

-- check collision only with the X left and right bounds
function Body:collide_bounds()
  local x=self.x+self.dx
  return x<16 or (x+15)>224
end --Body:collide_bounds

-- set the body for a left move
function Body:goleft()
  self.dx=-SPEED
  self.dir=-1
end

-- set the body for a right move
function Body:goright()
  self.dx=SPEED
  self.dir=1
end

-- set the body for a jump
-- params: dir 0=up, -1=left, 1=right
function Body:dojump(dir)
  if self.jump.idx==0 and not self.fly then
    self.jump.idx=1
    self.jump.dir=dir
  end
end

-- set the body for the next move
-- input is provided manually
function Body:input(left,right,jump,shot)
  if left then
    self:goleft()
  elseif right then
    self:goright()
  end
  if jump then
    self:dojump(left and -1 or (right and 1 or 0))
  end
end --Body:input

-- update the body position and action according to the
-- last input changes
function Body:update()
  self.tick=self.tick+1
  --slow down speed if jump or fly
  if self.jump.idx>0 or self.fly then
    self.dx=self.dx*FRICTION
  end
  --jump step
  local jump_step=nil
  local jump_path=self.jump.dir~=0
      and self.jump.path_xy or self.jump.path_y
  if self.jump.idx>0 then
    jump_step=jump_path[self.jump.idx]
    self.jump.idx=(self.jump.idx<#jump_path)
        and (self.jump.idx+1) or 0
    if self.jump.dir<0 then
      self.dx=(self.dx>0) and self.dx or 0
    elseif self.jump.dir>0 then
      self.dx=(self.dx<0) and self.dx or 0
    end
    self.dx=self.dx+(jump_step.x*self.jump.dir)
    self.dy=self.dy-jump_step.y
  end
  --move
  if self.dx~=0 or self.dy~=0 then
    if jump_step then
      --jumping
      if self.dy<0 then
        --jumping up so no collision with platforms
        if self:collide_bounds() then
          self.y=self.y+self.dy
        else
          self.x=self.x+self.dx
          self.y=self.y+self.dy
        end
      else
        if self:collide(self.dx,self.dy) then
          self.jump.idx=0        
        else
          self.x=self.x+self.dx
          self.y=self.y+self.dy
        end
      end
    else
      --running or flying
      if not self:collide(self.dx,self.dy) then
        self.x=self.x+self.dx
        self.y=self.y+self.dy
      end
    end
  end --if self.dx~=0 or self.dy~=0
  --check gravity if not jumping
  if not jump_step then
    self.fly=false
    if not self:collide(0,GRAVITY) then
      self.fly=true
      self.dy=GRAVITY
      self.y=self.y+self.dy
    end
  end
  -- movement state
  local state=1 --wait
  if jump_step and jump_step.y>0 then
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
  -- 1|2|3|4 every 1/4 secs
  local frame=(self.tick%60//15)+1
  local id=self.id[self.state][frame]
  local flip=(self.dir==-1) and 1 or 0
  spr(id,self.x,self.y+1,0,1,flip,0,2,2)
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
	return setmetatable(Body.new(x, y), Player)
end

---------------------------------------------------------
-- enemy class

local Enemy = setmetatable({}, {__index = Body})
Enemy.__index = Enemy

function Enemy.new(x, y)
	local self = setmetatable(Body.new(x, y), Enemy)
  self.state=4 -- start flying
  self.dir=-1
  self.id={80,82}
  local j=self.jump
  j.path_xy=build_jump_path(33,20,60)
  j.path_y=build_jump_path(0,33,60)
	return self
end

-- move the enemy based on AI rules
function Enemy:input(left,right,jump,shot)
  --do nothing if jumping or flying
  if self.state==3 or self.state==4 then return end
  --randomly jump or fall if next to a hole
  if self:collide(14*self.dir,1)
      and not self:collide(15*self.dir,1) then
    local v = math.random(100)
    if v>50 then self:dojump(self.dir); return end
  end
  --randomly jump up if on a spot
  local x=math.floor(self.x)
  local y=math.floor(self.y)
  if (x==68 or x==156) and y~=40 then
    local v = math.random(100)
    --trace("v:"..v..",x:"..x..",y:"..y)
    if v>50 then self:dojump(0); return end
  end
  --flip if colliding with a wall
  if self:collide(self.dir,-1) then
    self.dir=self.dir*-1
  end
  --run
  if self.dir==-1 then
    self:goleft()
  elseif self.dir==1 then
    self:goright()
  end
end

function Enemy:draw()
  -- 1|2 every 1/4 secs
  local frame=(tick%20//10)+1
  local id=self.id[frame]
  local flip=(self.dir==-1) and 1 or 0
  spr(id,self.x,self.y+1,0,1,flip,0,2,2)
end

---------------------------------------------------------

function initlevel(i)
  level=levels[i]
  p=Player.new(17,104)
  e1=Enemy.new(112,-20)
  e2=Enemy.new(112,-34)
  e3=Enemy.new(112,-48)
end

function input()
  if key(28) then initlevel(1)
    elseif key(29) then initlevel(2)
    elseif key(30) then initlevel(3)
  end
  p:input(btn(2),btn(3),btn(4),btn(5))
  e1:input()
  e2:input()
  e3:input()
end

function update()
  tick = tick+1
  p:update()
  e1:update()
  e2:update()
  e3:update()
end

function draw()
  map(level.map.x,level.map.y)
  p:draw()
  e1:draw()
  e2:draw()
  e3:draw()
  local c = level.textcolor
  print(string.format("%02d",level.idx),115,10,c,true,1)
  print(string.format("%01d",game.lives),10,122,c,true,1)
  print(string.format("%07d",game.score1),22,0,c,true,1)
  print(string.format("%07d",game.score2),178,0,c,true,1)
  --print(e1:tostring(),0,0,c)
end

initlevel(1)

function TIC()
  input()
  update()
  draw()
end
