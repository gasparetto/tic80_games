-----------------------------------------------------------
-- MATH 2D

local math2d = {}

function math2d.distance(xa, ya, xb, yb)
  return math.sqrt((xa - xb) ^ 2 + (ya - yb) ^ 2)
end

function math2d.interpolation(xa, ya, xb, yb, ab, n)
  local f = n / ab
  local xn = xa + (f * (xb - xa))
  local yn = ya + (f * (yb - ya))
  return xn, yn
end

local orientation_f = 8 / (math.pi * 2)

function math2d.orientation(xa, ya, xb, yb)
  local o = -math.atan(ya - yb, xb - xa)
  if o < 0 then
    o = o + math.pi * 2
  elseif o >= math.pi * 2 then
    o = o - math.pi * 2
  end
  o = math.floor(o * orientation_f)
  return o
end

