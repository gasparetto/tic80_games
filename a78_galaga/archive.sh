#!/usr/bin/env bash

GAME=a78_galaga

FILE=${GAME}-$(date +%Y%m%d%H%M).tar.gz

echo "Compressing game "${GAME}" in file "${FILE}

tar zcf archive/${FILE} \
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
  archive.sh \
  build.sh \
  cart.tic

echo "Done"
