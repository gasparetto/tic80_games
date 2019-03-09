#!/usr/bin/env bash

echo "Build game main file"
cat \
  header.lua \
  utils/game.lua \
  tests.lua \
  bricks.lua \
  paddle.lua \
  ball.lua \
  collision.lua \
  main.lua \
  > cart.lua

  #utils/tic80shim.lua \
