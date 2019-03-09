-----------------------------------------------------------
-- COLLISION

function collision_check_ball_with_bricks()
  local b = game.ball
  for k, brick in pairs(game.bricks) do
    local side =
      utils_game.rect_collision(b, brick)
    if side > 0 then
      ball_hit_brick(brick, side)
      -- remove the brick, set the score, play sound
      game.bricks[k] = nil
      game.score = game.score + brick.score
      sfx(0, brick.sfx, 8, 0)
      -- if there are no more bricks then reset the wall
      if count_bricks() == 0 then
        init_bricks()
      end
      break
    end
  end
end

function collision_check_ball_with_paddle()
  local b = game.ball
  local p = game.paddle
  if utils_game.rect_overlap(p, b) then
    -- calculate the offset of the hit on paddle
    local offset = (b.x + (b.w / 2.0))
        - (p.x + (p.w / 2.0)) -- offset = -13|0|+13
    -- set ball direction and speed, play sound
    ball_hit_paddle(offset)
    sfx(0, p.sfx, 8, 0)
  end
end

function collision_check_ball_with_border()
  local b = game.ball
  if b.x < 30 then
    b.x = 30
    b.dx = -b.dx
    sfx(0, 72, 8, 0)
  elseif b.x > 207 then
    b.x = 207
    b.dx = -b.dx
    sfx(0, 72, 8, 0)
  end
  if b.y < 17 then
    b.y = 17
    b.dy = -b.dy
    sfx(0, 62, 8, 0)
  elseif b.y > 136 then
    -- ball out of bottom screen, a live is lost
    ball_lost()
  end
end

