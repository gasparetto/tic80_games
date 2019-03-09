-- title:  Conway's Game of Life
-- author: game developer
-- desc:   short description
-- script: lua

-- https://www.wikiwand.com/en/Conway%27s_Game_of_Life

-- constants
SCREEN_W=240-8*2
SCREEN_H=136-8*2
MAX_CELLS=SCREEN_W*SCREEN_H
COLOR_BG=3
COLOR_CELL=11
-- parameters
INITIAL_CELLS=2500
-- global vars
generation = 0
cells = {}

-- init all cells to zero (dead)
for i=1,MAX_CELLS do cells[i] = 0 end
-- init some random cells to one (alive)
for i=1,INITIAL_CELLS do
  cells[math.random(MAX_CELLS-1)] = 1
end

function get_cell(i)
  if i<1 or i>MAX_CELLS then return 0 end
  return cells[i]
end

function count_cell_neighbors(i)
  local c1 = get_cell(i-SCREEN_W-1) -- top left
  local c2 = get_cell(i-SCREEN_W) -- top
  local c3 = get_cell(i-SCREEN_W+1) -- top right
  local c4 = get_cell(i-1) -- left
  -- c5 is the cell itself
  local c6 = get_cell(i+1) -- right
  local c7 = get_cell(i+SCREEN_W-1) -- bottom left
  local c8 = get_cell(i+SCREEN_W) -- bottom
  local c9 = get_cell(i+SCREEN_W+1) -- bottom right
  return c1+c2+c3+c4+c6+c7+c8+c9
end

function apply_rules_on_cell(v,n)
  if v==1 then
    -- Any live cell with fewer than two live neighbors
    -- dies, as if by underpopulation.
    if n<2 then return 0 end
    -- Any live cell with two or three live neighbors
    -- lives on to the next generation.
    if n==2 or n==3 then return v end
    -- Any live cell with more than three live neighbors
    -- dies, as if by overpopulation.
    if n>3 then return 0 end
  else
    -- Any dead cell with exactly three live neighbors
    -- becomes a live cell, as if by reproduction.
    if n==3 then return 1 end
  end
  return v
end

function update()
  -- increase generation counter
  generation = generation+1
  -- create temporary cell buffer
  local tmp = {}
  -- update temp cells
  for i=1,MAX_CELLS do
    local v = get_cell(i)
    local n = count_cell_neighbors(i)
    tmp[i] = apply_rules_on_cell(v,n)
  end
  -- restore cells from temp
  cells = tmp
end

function draw()
  -- draw border
  map()
  -- draw generation counter
  print(string.format("%07d",generation),28,1,COLOR_BG,true,1)
  -- draw cells
  for y=0,SCREEN_H-1 do
    for x=0,SCREEN_W-1 do
      local v = get_cell(y*SCREEN_W+x)
      if v==1 then pix(8+x,8+y,COLOR_CELL) end
    end
  end
end

function TIC()
  update()
  draw()
end
