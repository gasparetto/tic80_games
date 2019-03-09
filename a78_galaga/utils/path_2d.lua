-----------------------------------------------------------
-- PATH 2D

local path2d = {}

function path2d.init(path)
  local x0; local y0; local t0
  for i, step in ipairs(path.steps) do
    if i == 1 then
      step.t = path.t;
      x0 = step.x; y0 = step.y; t0 = step.t
    else
      if not step.o then
        if path.o then
          step.o = path.o
        else
          step.o = math2d.orientation(x0, y0,
            step.x, step.y)
        end
      end
      step.s = math2d.distance(x0, y0,
        step.x, step.y)
      if not step.v then step.v = path.v end
      if step.t and step.t > t0 then
        step.v = step.s / (step.t - t0)
      else
        step.t = t0 + (step.s / step.v)
      end
      x0 = step.x; y0 = step.y; t0 = step.t
    end
  end
end

function path2d.update(path, t)
  if t >= path.steps[1].t
      and t < path.steps[#path.steps].t then
    for i, step in ipairs(path.steps) do
      if step.t > t then
        local x0 = path.x
        local y0 = path.y
        local t0 = path.t;
        if i > 1 then
          local prev = path.steps[i - 1]
          x0 = prev.x; y0 = prev.y; t0 = prev.t;
        end
        local s = step.v * (t - t0)
        local x; local y
        x, y = math2d.interpolation(x0, y0,
          step.x, step.y, step.s, s)
        return x, y, step.o
      end
    end
  end
  return nil, nil, nil
end

function path2d.draw(path)
  local x0; local y0
  for i, step in ipairs(path.steps) do
    if i > 1 then
      line(x0, y0, step.x, step.y, 7)
    end
    x0 = step.x; y0 = step.y
  end
end

function path2d.translate(path, x, y)
  for _, step in ipairs(path.steps) do
    step.x = step.x + x; step.y = step.y + y
  end
  return path
end

function path2d.flip(path, is_x, is_y)
  for _, step in ipairs(path.steps) do
    if is_x then step.x = 240 - step.x end
    if is_y then step.y = 136 - step.y end
  end
  return path
end

function path2d.follow(xa, ya, xb, yb, v)
  if math.abs(xa - xb) < 1 and math.abs(ya - yb) < 1 then
    return xb, yb
  end
  local x; local y; local s
  s = math2d.distance(xa, ya, xb, yb)
  x, y = math2d.interpolation(xa, ya, xb, yb, s, v)
  return x, y
end

