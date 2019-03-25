-- title:  Minesweeper
-- author: game developer
-- desc:   short description
-- script: lua

-- https://en.wikipedia.org/wiki/Minesweeper_(video_game)
-- https://en.wikipedia.org/wiki/Microsoft_Minesweeper

COLS=8; ROWS=8; CELLS=ROWS*COLS; MINES=10
tick=0
game=0 -- game state 0=ingame 1=lost 2=win
mines=0 -- number of mines not flagged
cells={}
pressed=false -- mouse guard

----------------------------------------------------------
-- INIT methods

-- s cell state 0=closed 1=flagged 2=open
-- v cell value 0=empty 1-9=numbers 10=mine
function init_cells()
  local cells={}
  for y=1,ROWS do
    for x=1,COLS do
      table.insert(cells,{x=x,y=y,v=0,s=0})
    end
  end
  return cells
end

function init_mines(cells)
  for i=1,MINES do
    local c=0
    repeat
      c=math.random(1,CELLS)
    until cells[c].v==0
    cells[c].v=10
  end
end

function neightbors(cells,cell)
  local x=cell.x; local y=cell.y
  return {
    get_cell(cells,x-1,y-1),
    get_cell(cells,x-1,y),
    get_cell(cells,x-1,y+1),
    get_cell(cells,x,y-1),
    get_cell(cells,x,y+1),
    get_cell(cells,x+1,y-1),
    get_cell(cells,x+1,y),
    get_cell(cells,x+1,y+1)
  }
end

function init_cell_numbers(cells,cell)
  local cells1=neightbors(cells,cell)
  for _,cell1 in pairs(cells1) do
    if cell1 and cell1.v==10 then -- neightbor has mine
      cell.v=cell.v+1
    end
  end
end

function init_numbers(cells)
  for y=1,ROWS do
    for x=1,COLS do
      local cell=get_cell(cells,x,y)
      if cell.v==0 then
        init_cell_numbers(cells,cell)
      end
    end
  end
end

function init()
  tick=0
  game=0
  cells=init_cells()
  init_mines(cells)
  init_numbers(cells)
end

----------------------------------------------------------
-- GAME methods

function toggle_flag(cell)
  if cell.s==0 then cell.s=1
  elseif cell.s==1 then cell.s=0 end
end

function open(cell)
  if cell.s==0 then
    -- open cell
    cell.s=2
    if cell.v==0 then
      -- empty cell, so open also neightbors
      local cells1=neightbors(cells,cell)
      for _,cell1 in pairs(cells1) do
        if cell1 then open(cell1) end
      end
    elseif cell.v==10 then
      -- mine
      lost(cell)
    end
  end
end

function lost(cell)
  game=1
  cell.v=11 -- red mine
  for _,cell in pairs(cells) do
    if cell.s==0 then
      cell.s=2 -- open all cells
    elseif cell.s==1 and cell.v~=10 then
      cell.s=3 -- wrong flag
    end
  end
end

function win()
  game=2
  for _,cell in pairs(cells) do
    if cell.s==0 and cell.v==10 then
      cell.s=1 -- set flags
    end
  end
end

function get_cell(cells,x,y)
  if x>0 and x<=ROWS and y>0 and y<=COLS then
    return cells[(y-1)*COLS+x]
  end
end

function get_cell_by_coords(cells,px,py)
  local x=(px//16)+1
  local y=(py//16)+1
  return get_cell(cells,x,y)
end

----------------------------------------------------------
-- INPUT methods

function input()
  x,y,pl,_,pr=mouse()
  if pl or pr then
    if pressed then return end
    pressed=true
    if pl and x>172 and x<204 and y>52 and y<84 then
      init() -- reset game
      return
    end
    cell=get_cell_by_coords(cells,x-4,y-4)
    if pl and cell then
      open(cell)
    elseif pr and cell then
      toggle_flag(cell)
    end
  else
    pressed=false
  end
end

----------------------------------------------------------
-- UPDATE methods

function update()
  if game==0 then
    tick=tick+1
    -- count flagged cells
    mines=MINES
    for _,cell in pairs(cells) do
      if cell.s==1 then mines=mines-1 end
    end
    -- check for game complete
    local complete=true
    for _,cell in pairs(cells) do
      -- if cell closed or flag and no mine then no win
      if (cell.s==0 or cell.s==1) and cell.v~=10 then
        complete=false
        break
      end
    end
    if complete then win() end
  end
end

----------------------------------------------------------
-- DRAW methods

-- convert cell state and value to sprite id
function cell_id(cell)
  if cell.s==0 then return 2 end -- closed
  if cell.s==1 then return 4 end -- closed with flag
  if cell.s==3 then return 6 end -- wrong flag
  if cell.s==2 then -- open
    if cell.v==0 then return 12 end -- empty
    if cell.v<9 then return 32+((cell.v-1)*2) end -- num
    if cell.v==10 then return 8 end -- mine
    if cell.v==11 then return 10 end -- red mine
  end
  return 0
end

-- convert number to sprite id
function lcd_id(v)
  if v>=0 and v<8 then return 128+(v*2)
  else return 192+((v-8)*2) end
end

function draw_lcd(x,y,v)
  if v<0 then v=0 elseif v>999 then v=999 end
  spr(lcd_id(v//100),x,y,0,1,0,0,2,4)
  spr(lcd_id((v//10)%10),x+16,y,0,1,0,0,2,4)
  spr(lcd_id(v%10),x+32,y,0,1,0,0,2,4)
end

function draw()
  cls(14)
  -- column left
  tri(133,133,133,2,2,133,15) -- white
  tri(2,2,133,2,2,133,13) -- gray
  -- column right
  tri(238,133,238,2,141,133,15) -- white
  tri(141,2,238,2,141,133,13) -- gray
  -- cells
  for _,cell in pairs(cells) do
    local id=cell_id(cell)
    spr(id,(cell.x-1)*16+4,(cell.y-1)*16+4,0,1,0,0,2,2)
  end
  -- score
  rect(143,4,94,128,14)
  spr(64+(game*4),172,52,0,1,0,0,4,4)
  draw_lcd(164,12,mines)
  draw_lcd(164,93,tick//60)
end

init()

function TIC()
  input()
  update()
  draw()
end
