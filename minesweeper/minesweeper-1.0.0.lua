-- title:  Minesweeper
-- author: game developer
-- desc:   short description
-- script: lua

-- https://en.wikipedia.org/wiki/Minesweeper_(video_game)
-- https://en.wikipedia.org/wiki/Microsoft_Minesweeper

COLS=8; ROWS=8; CELLS=ROWS*COLS; MINES=10
tick=0
game=0 -- game state 0=play 1=win 2=die
mines=MINES -- remaining mines not flagged
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

function init_mines()
  for i=1,MINES do
    local c=0
    repeat
      c=math.random(1,CELLS)
    until cells[c].v==0
    cells[c].v=10
  end
end

function init_number(cell)
  cell.v=0
  local cells1=neightbors(cell)
  for _,cell1 in pairs(cells1) do
    if cell1 and cell1.v==10 then -- neightbor has mine
      cell.v=cell.v+1
    end
  end
end

function init_numbers()
  for y=1,ROWS do
    for x=1,COLS do
      local cell=get_cell(x,y)
      if cell.v==0 then init_number(cell) end
    end
  end
end

function init()
  tick=0
  game=0
  mines=MINES
  cells=init_cells()
  init_mines()
  init_numbers()
end

----------------------------------------------------------
-- GAME methods

function update_remaining_mines()
  local flags=0
  for _,cell in pairs(cells) do
    if cell.s==1 then flags=flags+1 end
  end
  mines=MINES-flags
end

function toggle_flag(cell)
  if cell.s==0 then cell.s=1
  elseif cell.s==1 then cell.s=0 end
  update_remaining_mines()
end

function neightbors(cell)
  local x=cell.x; local y=cell.y
  return {
    get_cell(x-1,y-1),
    get_cell(x-1,y),
    get_cell(x-1,y+1),
    get_cell(x,y-1),
    get_cell(x,y+1),
    get_cell(x+1,y-1),
    get_cell(x+1,y),
    get_cell(x+1,y+1)
  }
end

function open(cell)
  if cell.s==0 then
    -- open cell
    cell.s=2
    if cell.v==0 then
      -- empty cell, so open also neightbors
      local cells1=neightbors(cell)
      for _,cell1 in pairs(cells1) do
        if cell1 then open(cell1) end
      end
    elseif cell.v==10 then
      -- mine
      cell.v=11 -- set red mine
      die()
    end
  end
end

function win()
  game=1
  -- flag all mines
  for _,cell in pairs(cells) do
    if cell.s==0 and cell.v==10 then
      cell.s=1
    end
  end
end

function die()
  game=2
  -- open all cells and mark wrong flags
  for _,cell in pairs(cells) do
    if cell.s==0 then
      cell.s=2
    elseif cell.s==1 and cell.v~=10 then
      cell.s=3
    end
  end
end

function check_board()
  for _,cell in pairs(cells) do
    -- if cell closed or flagged and has no mine
    if (cell.s==0 or cell.s==1) and cell.v~=10 then
      return false
    end
  end
  return true
end

function get_cell(x,y)
  if x>0 and x<=ROWS and y>0 and y<=COLS then
    return cells[(y-1)*COLS+x]
  end
end

function get_cell_by_coords(px,py)
  local x=(px//16)+1
  local y=(py//16)+1
  return get_cell(x,y)
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
    cell=get_cell_by_coords(x-4,y-4)
    if pl and cell then
      open(cell)
    elseif pr and cell then
      toggle_flag(cell)
    end
    if game==0 and check_board() then
      win()
      update_remaining_mines()
    end
  else
    pressed=false
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
  -- cells
  for _,cell in pairs(cells) do
    local id=cell_id(cell)
    local x=4+(cell.x-1)*16
    local y=4+(cell.y-1)*16
    spr(id,x,y,0,1,0,0,2,2)
  end
  -- column right
  tri(238,133,238,2,141,133,15) -- white
  tri(141,2,238,2,141,133,13) -- gray
  -- score
  rect(143,4,94,128,14)
  spr(64+(game*4),172,52,0,1,0,0,4,4)
  draw_lcd(164,12,mines)
  draw_lcd(164,93,tick//60)
end

init()

function TIC()
  if game==0 then
    tick=tick+1
  end
  input()
  draw()
end
