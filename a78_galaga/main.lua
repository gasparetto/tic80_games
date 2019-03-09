-----------------------------------------------------------
-- MAIN

game = {
  mode = nil,
  tick = 0
}

-- game modes
GM_ATTRACT, GM_DEMO, GM_INGAME = 0, 1, 2

function init()
  trace("Init A78 Galaga")
  init_stars()
  init_mode_attract()
  --init_mode_demo()
  --init_mode_ingame()
end

init()

function input()
  if game.mode == GM_ATTRACT then
    input_mode_attract()
  elseif game.mode == GM_DEMO then
    input_mode_demo()
  elseif game.mode == GM_INGAME then
    input_mode_ingame()
  end
end

function update()
  if game.mode == GM_ATTRACT then
    update_mode_attract()
  elseif game.mode == GM_DEMO then
    update_mode_demo()
  elseif game.mode == GM_INGAME then
    update_mode_ingame()
  end
end

function draw()
  cls(0)
  draw_stars()
  if game.mode == GM_ATTRACT then
    draw_mode_attract()
  elseif game.mode == GM_DEMO then
    draw_mode_demo()
  elseif game.mode == GM_INGAME then
    draw_mode_ingame()
  end
end

function TIC()
  game.tick = game.tick + 1
  input()
  update()
  draw()
end

