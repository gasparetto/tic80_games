-----------------------------------------------------------
-- GAME MODE -> INGAME

function init_mode_ingame()
  trace("Init ingame game mode")
  game.tick = 0
  game.mode = GM_INGAME
  init_grid()
  init_invaders()
  init_player_demo()
end

function input_mode_ingame()
  if btn(2) then -- pad left (left arrow)
    player_move_left()
  end
  if btn(3) then -- pad right (right arrow)
    player_move_right()
  end
  if btnp(4) then -- button A (key Z)
    player_new_shot()
  end
end

function update_mode_ingame()
  update_grid()
  update_invaders()
  update_player_ingame()
end

function draw_mode_ingame()
  if game.tick < 60 then print("READY", 104, 66, 2) end
  -- draw_grid()
  draw_invaders()
  draw_player()
end

