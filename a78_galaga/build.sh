#!/usr/bin/env bash

echo "Build game main file"
cat \
  header.lua \
  utils/lang.lua \
  utils/math_2d.lua \
  utils/path_2d.lua \
  stars.lua \
  grid.lua \
  invaders.lua \
  player.lua \
  mode_attract.lua \
  mode_demo.lua \
  mode_ingame.lua \
  main.lua \
  > cart.lua
