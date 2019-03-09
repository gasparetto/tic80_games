-----------------------------------------------------------
-- TIC80 SHIM

-- check for the TIC80 runtime
-- (if the function 'spr' is defined)
local tic80 = (spr~=nil)

if not tic80 then
  -- mock the TIC80 functions
  btn = function (id) end
  btnp = function (id, hold, period) end
  clip = function (x, y, w, h) end
  cls = function (color) end
  circ = function (x, y, radius, color) end
  circb = function (x, y, radius, color) end
  exit = function () os.exit() end
  font = function (text, x, y, colorkey, char_width,
                   char_height, fixed, scale) end
  key = function (code) end
  keyp = function (code, hold, period) end
  line = function (x0, y0, x1, y1, color) end
  mouse = function () end
  peek = function (addr) end
  peek4 = function (addr4) end
  pix = function (x, y, color) end
  poke = function (addr, val) end
  poke4 = function (addr4, val) end
  rect = function (x, y, w, h, color) end
  rectb = function (x, y, w, h, color) end
  reset = function () end
  sfx = function (id, note, duration, channel, volume,
                  speed) end
  spr = function (id, x, y, colorkey, scale, flip, rotate,
                  w, h) end
  trace = function (msg, col)
    print(string.format("%6d: %s", game.tick, msg))
  end
end

function main()
  if not tic80 then
    print("------: main start")
    while(true) do TIC()end
  end
end

