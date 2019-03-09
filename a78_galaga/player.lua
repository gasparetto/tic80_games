-----------------------------------------------------------
-- PLAYER

local player

function player_move_left()
  player.x = player.x - 2
end

function player_move_right()
  player.x = player.x + 2
end

function player_new_shot()
  if #player.shots < 2 then
    table.insert(player.shots,
      { x = player.x + 6, y = player.y - 4 })
  end
end

function init_player_demo()
  local rand_x = {
    72, 140, 100, 120, 40, 100, 80, 180, 80, 120, 100, 116,
    72, 140, 100, 120, 40, 100, 80, 180, 80, 120, 100, 116,
    72, 140, 100, 120, 40, 100, 80, 180, 80, 120, 100, 116,
    72, 140, 100, 120, 40, 100, 80, 180, 80, 120, 100, 116
  }
  local y = 116
  local steps = {}
  for _, x in pairs(rand_x) do
    table.insert(steps, { x = x, y = y })
  end
  local path = {
    x = 116,
    y = 116,
    t = 0,
    v = 1.5,
    o = 6,
    steps = steps
  }
  path2d.init(path)
  player = {
    id = 0,
    x = 116,
    y = 116,
    path = path,
    shots = {},
    lives = 3,
    score = 0,
  }
end

function init_player_ingame()
  player = {
    id = 0,
    x = 116,
    y = 116,
    shots = {},
    lives = 3,
    score = 0,
  }
end

function update_player_shots()
  for k, shot in ipairs(player.shots) do
    local invd_k = get_invader_k_from_collision(shot.x,
      shot.y)
    if invd_k then
      player.score = player.score
          + explode_invader_k_and_get_score(invd_k)
      table.remove(player.shots, k)
    else
      shot.y = shot.y - 3
      if shot.y < 0 then
        table.remove(player.shots, k)
      end
    end
  end
end

function update_player_demo()
  -- player follow a path
  if game.tick >= player.path.t and
      game.tick < player.path.steps[#player.path.steps].t then
    local xn; local yn; local on
    xn, yn, on = path2d.update(player.path, game.tick)
    player.x = xn; player.y = yn
  end
  -- player shot at interval
  if (game.tick % 120) == 0 and game.tick < 1500 then -- 1 sec
    player_new_shot()
  end
  update_player_shots()
end

function update_player_ingame()
  update_player_shots()
end

function draw_player()
  -- player ship
  spr(player.id, player.x, player.y, 0, 1, 0, 0, 2, 1)
  -- shots
  for _, shot in ipairs(player.shots) do
    spr(32, shot.x, shot.y, 0)
  end
  -- lives (remaining ships)
  for i = 1, player.lives do
    spr(player.id, i * 18, 128, 0, 1, 0, 0, 2, 1)
  end
  -- score
  print(string.format("%d", player.score), 32, 0, 10, true,
    2)
end

