-----------------------------------------------------------
-- MAIN

game = {
  tick = 0,
  bricks = nil,
  paddle = nil,
  ball = nil,
  score = 0,
  lives = 0,
  player = 1
}

PAL = "140c1c442434444cc64e4a4eb279384c9d4cc6484c8d8d8d"
    .. "597dcec26d408595a1449d81d2aa996dc2caa1a138deeed6"

function init()
  utils_game.set_palette_to_string(PAL)
  utils_game.set_mouse_cursor_to_spr(0x255)
  init_bricks()
  init_paddle()
end

function input_gamepad()
  if btn(2) then -- pad left
    move_paddle_left()
  end
  if btn(3) then -- pad right
    move_paddle_right()
  end
  if btn(4) then -- pad button A = key Z
    if game.ball == nil and game.lives > 0 then
      init_ball()
      sfx(0, 72, 8, 0)
    end
  end
  if btn(5) then -- pad button B = key X
    init()
    game.lives = 5
  end
end

function input_mouse()
  local x; local y; local p
  x, y, p = mouse()
  move_paddle_to(x)
  if p then
    if game.ball == nil and game.lives > 0 then
      init_ball()
      sfx(0, 72, 8, 0)
    end
  end
end

function input()
  input_gamepad()
  --input_mouse()
end

function update()
  if game.ball then
    update_ball()
    collision_check_ball_with_bricks()
    collision_check_ball_with_paddle()
    collision_check_ball_with_border()
  else
    if game.lives == 0 then
      if (game.tick % 300) == 0 then -- every 5 secs
        utils_game.change_palette_to_random()
      end
    end
  end
end

function draw_border()
  rect(20, 7, 200, 10, 7)
  rect(20, 17, 10, 115, 7)
  rect(210, 17, 10, 115, 7)
  rect(20, 132, 10, 4, 11)
  rect(210, 132, 10, 4, 6)
end

function draw()
  cls(0)
  -- header
  local text = string.format("%03d  %d  %d",
    game.score, game.lives, game.player)
  font(text, 120, -2, 0, 8, 8, true, 1)
  draw_border()
  draw_bricks()
  draw_paddle()
  if game.ball then
    draw_ball()
  end
end

function gameover()
  -- nothing to do
end

init()

--test1()
--test2()
--test3()

-- main loop
function TIC()
  game.tick = game.tick + 1
  input()
  update()
  draw()
end

