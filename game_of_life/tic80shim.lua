----------------------------------------------------------
-- TIC80 SHIM

--[[
Specification
  Display          240x136 pixels, 16-color palette
  Input            4 gamepads with 8 buttons / mouse / keyboard
  Sprites          256 8x8 foreground sprites and 256 8x8 background tiles
  Map              240x136 cells, 1920x1088 pixels (240*8 x 136*8)
  Sound            4 channels (with editable waveform envelopes)
  Code             64KB (or 512KB in PRO bankswitching)
  Bankswitching    Up to 8 banks in cart (PRO version only)
]]

-- check for the TIC80 runtime
-- (if the function 'spr' is defined)
if not spr then
  
  --print = function (text,x,y,color,fixed,scale,smallfont) return 0 end
  font = function (text,x,y,colorkey,char_width,char_height,fixed,scale) return 0 end
  clip = function (x,y,w,h) end
  cls = function (color) end
  pix = function (x,y,color) return 0 end
  line = function (x0,y0,x1,y1,color) end
  rect = function (x,y,w,h,color) end
  rectb = function (x,y,w,h,color) end
  circ = function (x,y,radius,color) end
  circb = function (x,y,radius,color) end
  spr = function (id,x,y,colorkey,scale,flip,rotate,w,h) end
  btn = function (id) return false end
  btnp = function (id,hold,period) return false end
  sfx = function (id,note,duration,channel,volume,speed) end
  key = function (code) end
  keyp = function (code,hold,period) end
  map = function (x,y,w,h,sx,sy,colorkey,scale,remap) end
  mget = function (x,y) return 0 end
  mset = function (x,y,id) end
  music = function (track,frame,row,loop) end
  peek = function (addr) return 0 end
  poke = function (addr,val) end
  peek4 = function (addr4) return 0 end
  poke4 = function (addr4,val) end
  reset = function () end
  memcpy = function (toaddr,fromaddr,len) end
  memset = function (addr,val,len) end
  pmem = function (index,val) return 0 end
  trace = function (msg,col) print(string.format("%6d: %s", game.tick, msg)) end
  time = function () return 0 end
  mouse = function () return 0,0,false,false,false end
  sync = function (mask,bank,tocart) end
  tri = function (x1,y1,x2,y2,x3,y3,color) end
  textri = function (x1,y1,x2,y2,x3,y3,u1,v1,u2,v2,u3,v3,use_map,colorkey) end
  exit = function () os.exit() end
end
