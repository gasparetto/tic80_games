#!/usr/bin/env bash

GAME=a26_breakout

FILE=${GAME}-$(date +%Y%m%d%H%M).tar.gz

echo "Compressing game "${GAME}" in file "${FILE}

tar zcf archive/${FILE} \
  header.lua \
  utils/game.lua \
  bricks.lua \
  paddle.lua \
  ball.lua \
  collision.lua \
  breakout.lua \
  archive.sh \
  build.sh \
  cart.tic

echo "Done"
