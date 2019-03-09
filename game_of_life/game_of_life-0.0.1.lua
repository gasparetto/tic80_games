-- title:  Conway's Game of Life
-- author: game developer
-- desc:   short description
-- script: lua

-- https://www.wikiwand.com/en/Conway%27s_Game_of_Life
--[[
Rules
The universe of the Game of Life is an infinite, two-dimensional orthogonal grid of square cells, each of which is in one of two possible states, alive or dead, (or populated and unpopulated, respectively). Every cell interacts with its eight neighbours, which are the cells that are horizontally, vertically, or diagonally adjacent. At each step in time, the following transitions occur:

1. Any live cell with fewer than two live neighbors dies, as if by underpopulation.
2. Any live cell with two or three live neighbors lives on to the next generation.
3. Any live cell with more than three live neighbors dies, as if by overpopulation.
4. Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.
The initial pattern constitutes the seed of the system. The first generation is created by applying the above rules simultaneously to every cell in the seed; births and deaths occur simultaneously, and the discrete moment at which this happens is sometimes called a tick. Each generation is a pure function of the preceding one. The rules continue to be applied repeatedly to create further generations.
]]

--constants
SCREEN_W=240-8*2
SCREEN_H=136-8*2
COLOR_BG=3
COLOR_CELL=11
--parameters
MAX_CELLS=SCREEN_W*SCREEN_H
INITIAL_CELLS=2000

tick = 0
generation = 0
cells = {}

--local pretty = require 'pl.pretty'
--require 'tic80shim'

function init()
  for i=1,MAX_CELLS do cells[i] = 0 end
  for i=1,INITIAL_CELLS do
    local cell = math.random(MAX_CELLS-1)
    cells[cell] = 1
  end
end

init()

function get_cell(i)
  if i<1 or i>MAX_CELLS then return 0 end
  return cells[i]
end

function count_neighbors_of_cell(i)
  return get_cell(i-SCREEN_W-1) + get_cell(i-SCREEN_W) + get_cell(i-SCREEN_W+1)
      + get_cell(i-1) + get_cell(i+1)
      + get_cell(i+SCREEN_W-1) + get_cell(i+SCREEN_W) + get_cell(i+SCREEN_W+1)
end

function apply_rules_on_cell(i,v)
  local n = count_neighbors_of_cell(i)
  if v==1 then
    --1. Any live cell with fewer than two live neighbors dies, as if by underpopulation.
    if n<2 then return 0 end
    --2. Any live cell with two or three live neighbors lives on to the next generation.
    if n==2 or n==3 then return v end
    --3. Any live cell with more than three live neighbors dies, as if by overpopulation.
    if n>3 then return 0 end
  else
    --4. Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.
    if n==3 then return 1 end
  end
  return v
end

function update()
  generation = generation+1
  --backup cells
  local cells2 = {}
  for i=1,MAX_CELLS do cells2[i] = cells[i] end
  --update cells
  for i=1,MAX_CELLS do cells2[i] = apply_rules_on_cell(i,cells2[i]) end
  --restore cells
  for i=1,MAX_CELLS do cells[i] = cells2[i] end
end

function draw_cell(i,color)
  if cells[i]==1 then
    color = color or COLOR_CELL
    local offset = i-1
    local y = offset//SCREEN_W
    local x = offset%SCREEN_W
    pix(8+x,8+y,color)
  end
end

function draw()
  map()
  print(string.format("%07d",generation),28,1,COLOR_BG,true,1)
  for i=1,MAX_CELLS do draw_cell(i) end
end

function TIC()
  tick = tick+1
  --if (tick%10)==0 then
    update()
    draw()
  --end
end

TIC()
