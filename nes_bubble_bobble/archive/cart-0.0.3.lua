-- title:  nes_bubble_bobble
-- author: game developer
-- desc:   short description
-- script: lua

---------------------------------------------------------
-- player class

p = {
  x=0,y=0,dx=0,dy=0,flip=0,
  tick=0,state=0,speed=1.0,speed_fly=0.4,
  jump={idx=0,w=33,h=33,s=60,left=false,right=false},
  fly=false,
  id={
    {16, 16, 18, 18}, -- wait
    {20, 22, 16, 18}, -- run
    {24, 24, 26, 26}, -- jump
    {28, 28, 30, 30}, -- fly
  }
  ,
  collide = function (self,dx,dy)
    local x=self.x+dx; local y=self.y+dy
    return mget(level.x+x//8,level.y+(y+15)//8)>0 or
        mget(level.x+(x+15)//8,level.y+(y+15)//8)>0
  end --collide
  ,
  collide_bounds = function (self)
    local x=self.x+self.dx
    return x<16 or (x+15)>224
  end --collide_bounds
  ,
  init = function (self)
    self.x=17
    self.y=104
    local j=self.jump
    j.path=build_jump_path(j.w,j.h,j.s)
  end
  ,
  input = function (self,left,right,jump,shot)
    self.dx=0
    self.dy=0
    if left then
      self.dx=-self.speed
      self.flip=1
    elseif right then
      self.dx=self.speed
      self.flip=0
    end
    if jump then
      if self.jump.idx==0 and not self.fly then
        self.jump.idx=1
        self.jump.left=left
        self.jump.right=right
      end
    end
  end --input
  ,
  update = function (self)
    self.tick=self.tick+1
    --slow down speed if jump or fly
    if self.jump.idx>0 or self.fly then
      self.dx=self.dx*self.speed_fly
    end
    --jump step
    local jump_step=nil
    if self.jump.idx>0 then
      jump_step=self.jump.path[self.jump.idx]
      self.jump.idx=(self.jump.idx<#self.jump.path)
          and (self.jump.idx+1) or 0
      if self.jump.left then
        self.dx=(self.dx>0) and self.dx or 0
        self.dx=self.dx-jump_step.x
      elseif self.jump.right then
        self.dx=(self.dx<0) and self.dx or 0
        self.dx=self.dx+jump_step.x
      end
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
    -- player state
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
  end --update
  ,
  draw = function (self)
    -- 1|2|3|4 every 1/4 secs
    local frame = (self.tick%60//15)+1
    local id=p.id[self.state][frame]
    spr(id,self.x,self.y+1,0,1,self.flip,0,2,2)
  end --draw
  ,
  tostring = function (self)
    return string.format(
      "x=%.2f,y=%.2f,dx=%.2f,dy=%.2f,j=%d",
      self.x,self.y,self.dx,self.dy,self.jump.idx)
  end --tostring
}
setmetatable (p, {
  __tostring = function (t) return t:tostring() end
})

---------------------------------------------------------

-- return an array with the "jump path" steps
-- params: width, height, steps
function build_jump_path(w,h,s)
  local arr={}; local x0=0; local y0=0
  for i=1,s do
    local x=i/(s/2)
    -- https://www.desmos.com/calculator
    -- y=1-(x-1)^2
    local y=1-(x-1)^2
    arr[i]={x=w*(x-x0),y=h*(y-y0)}
    x0=x; y0=y
  end
  return arr
end

---------------------------------------------------------

GRAVITY=0.75

tick=0
game={score1=0,score2=0,lives=2}
level={i=1,c=1,x=0,y=0}
--level={i=2,c=12,x=30,y=0}
--level={i=3,c=9,x=60,y=0}

p:init()

---------------------------------------------------------

function input()
  p:input(btn(2),btn(3),btn(4),btn(5))
end

function update()
  tick = tick+1
  p:update()
end

function draw()
  map(level.x,level.y)
  p:draw()
  local c = level.c
  print(string.format("%02d",level.i),115,10,c,true,1)
  print(string.format("%01d",game.lives),10,122,c,true,1)
  print(string.format("%07d",game.score1),22,0,c,true,1)
  print(string.format("%07d",game.score2),178,0,c,true,1)
  --print(p,0,0,c)
end

function TIC()
  input()
  update()
  draw()
end
