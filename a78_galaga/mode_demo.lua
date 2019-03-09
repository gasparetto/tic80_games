-----------------------------------------------------------
-- GAME MODE -> DEMO

function init_mode_demo()
  trace("Init demo game mode")
  game.tick = 0
  game.mode = GM_DEMO
  init_grid()
  init_invaders()
  init_player_demo()
end

function input_mode_demo()
  if btn(4) then -- button A = key Z
    init_mode_ingame()
  end
end

function update_mode_demo()
  update_grid()
  update_invaders()
  update_player_demo()
end

function draw_mode_demo()
  if game.tick < 60 then print("READY", 104, 66, 2) end
  -- draw_grid()
  draw_invaders()
  draw_player()
end

