# Atari 2600 Breakout

TIC80 screen: 240x136.

Game:
* header top with score 240x20 black
* border top left right gray
  * 20 black - 10 gray - 180 game field black - 10 gray - 20 black
* bricks: 10x4, 18 x 6 rows (4 rows empty on top)
  * blue - green - yellow - brown - orange - red
* paddle 20x3 red - ball 3x3 red
* colors:
  * black-0:0,0,0 gray-7:8e,8e,8e lightgreen-11:46,9d,82
  * blue-2:43,4d,c5 green-5:4c,9f,4c yellow-14:a2,a1,36
  * brown-4:b3,79,37 orange-9:c4,6c,40 red-6:c6,49,4b
* sound notes (note idx:octave+note):
  * paddle|wall_top-62:6D wall_left|wall_right-72:7C
  * blue-42:4F# green-46:4A# yellow-49:5C#
  * brown-51:5D# orange-55:5G red-58:5A#
