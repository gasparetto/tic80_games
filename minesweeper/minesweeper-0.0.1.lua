-- title:  Minesweeper
-- author: game developer
-- desc:   short description
-- script: lua

-- https://en.wikipedia.org/wiki/Minesweeper_(video_game)
-- https://en.wikipedia.org/wiki/Microsoft_Minesweeper

COLS=8; ROWS=8; CELLS=ROWS*COLS; MINES=10
tick=0
pressed=false
cells={}

----------------------------------------------------------

-- v=cell value (default empty)
--   0=empty 1-9=numbers 10=mine 11=red mine
-- s=cell state (default closed)
--   0=closed 1=flagged 2=open 
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

function toggle_flag(cell)
  if cell.s==0 then cell.s=1
  elseif cell.s==1 then cell.s=0
  end
end

function open_cell(cells,x,y)
  local c=get_cell(cells,x,y)
  if c and c.s==0 then c.s=2 end
end

function open_all(cells)
  for _,cell in pairs(cells) do
    cell.s=2
  end
end

function open(cell)
    if cell.s==0 then cell.s=2 end
    if cell.v==0 then
      local cells1=neightbors(cells,cell)
      for _,cell1 in pairs(cells1) do
        if cell1 and cell1.s==0 then
          open(cell1)
        end
      end
    elseif cell.v==10 then
      cell.v=11
      open_all(cells)
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
  --trace("get cell at coords "..px.."x"..py.." grid "..x.."x"..y)
  return get_cell(cells,x,y)
end

-- convert cell state and value to sprite id
function cell_id(cell)
  if cell.s==0 then return 2 end -- closed
  if cell.s==1 then return 4 end -- closed with flag
  if cell.s==2 then -- open
    if cell.v==0 then return 10 end -- empty
    if cell.v<9 then return 32+((cell.v-1)*2) end -- num
    if cell.v==10 then return 6 end -- mine
    if cell.v==11 then return 8 end -- red mine
  end
  return 0
end

----------------------------------------------------------

function init()
  cells=init_cells()
  init_mines(cells)
  init_numbers(cells)
end

function input()
  x,y,pl,_,pr=mouse()
  if (pl or pr) then
    if pressed then return end
    pressed=true
    cell=get_cell_by_coords(cells,x,y)
    if not cell then return end
    if pl then open(cell)
    elseif pr then toggle_flag(cell)
    end
  else
    pressed=false
  end
end

function update()

end

function draw()
  cls()
  for _,cell in pairs(cells) do
    local id=cell_id(cell)
    spr(id,(cell.x-1)*16,(cell.y-1)*16,0,1,0,0,2,2)
  end
end

init()

function TIC()
  tick=tick+1
  input()
  update()
  draw()
end
