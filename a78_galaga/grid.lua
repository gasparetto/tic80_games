-----------------------------------------------------------
-- GRID

local grid

function get_x_y_cell_coords(row, col)
  local cell = grid.cells[row..","..col]
  return cell.x, cell.y
end

function init_grid()
  local w = 17
  local h = 12
  -- offset 2 cells, max x mov 4 cells
  local xs = w * 2
  local xm = w * 4
  -- 17 w * 14 cells = 238 px
  local x0 = 2 + xs
  grid = {
    x = xs,
    xd = 1,
    xs = xs,
    xm = xm,
    e = 0,
    ed = -0.2,
    em = 5,
    cells_w = w,
    cells_h = h,
    cells = {}
  }
  for y = 1, 5 do
    for x = 1, 10 do
      grid.cells[x .. "," .. y] = {
        x = x0 + (x - 1) * w,
        y = (y - 1) * h
      }
    end
  end
end

function expand_and_contract_grid_on_x_axis()
  if grid.e < 0 or grid.e > grid.em then
    grid.ed = -grid.ed
  end
  grid.e = grid.e + grid.ed
  for y = 1, 5 do
    for x = 1, 10 do
      local cell = grid.cells[x .. "," .. y]
      -- -4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5
      local xd = x - 5.5
      cell.x = cell.x + (xd * grid.ed)
    end
  end
end

function move_grid_on_x_axis()
  if grid.x == 0 or grid.x == grid.xm then
    grid.xd = -grid.xd
  end
  grid.x = grid.x + grid.xd
  for _, cell in pairs(grid.cells) do
    cell.x = cell.x + grid.xd
  end
end

function update_grid()
  if (game.tick % 4) == 0 then
    local t = 2500
    if game.tick > t and grid.x == grid.xs then
      expand_and_contract_grid_on_x_axis()
    else
      move_grid_on_x_axis()
    end
  end
end

function draw_grid()
  for _, cell in pairs(grid.cells) do
    rectb(cell.x, cell.y, 14, 10, 7)
  end
end

