-----------------------------------------------------------
-- STARS

local stars_xy

function init_stars()
  stars_xy = {
    110, 19, 108, 46, 139, 217, 164, 111, 79, 257, 132, 82,
    206, 50, 178, 47, 210, 389, 52, 218, 130, 340, 201, 95,
    72, 332, 107, 170, 146, 376, 149, 26, 237, 28, 43, 226,
    147, 344, 202, 374, 120, 156, 33, 142, 123, 351, 114,
    154, 203, 275, 223, 155, 129, 305, 150, 333, 142, 28,
    62, 79, 2, 350, 63, 397, 226, 175, 134, 221, 71, 159,
    117, 317, 189, 250, 36, 119, 120, 248, 163, 138, 74,
    243, 176, 337, 89, 142, 162, 384, 102, 371, 38, 172,
    192, 167, 101, 297, 205, 391, 70, 58, 90, 311, 225, 63,
    96, 33, 109, 360, 169, 53, 58, 3, 177, 390, 204, 42, 79,
    208, 16, 301, 107, 88, 44, 99, 153, 240, 237, 194, 139,
    112, 151, 379, 14, 226, 25, 182, 156, 222, 85, 139, 165,
    238, 85, 169, 136, 81, 127, 358, 173, 236, 155, 67, 194,
    330, 99, 177, 102, 160, 223, 400, 163, 222, 227, 293,
    29, 20, 45, 306, 145, 215, 27, 115, 32, 187, 170, 279,
    161, 94, 142, 155, 198, 94, 133, 253, 14, 386, 18, 192,
    87, 400, 115, 16, 133, 169, 185, 269, 113, 382, 105, 29,
    118, 219, 86, 249, 4, 27, 77, 272, 73, 364, 16, 50, 34,
    248, 182, 79, 140, 332, 163, 378, 199, 62, 236, 151,
    139, 300, 12, 19, 169, 194, 29, 78, 8, 191, 197, 18,
    131, 54, 174, 338, 11, 316, 233, 74, 99, 290, 92, 397,
    133, 23, 225, 151, 51, 367, 181, 314, 160, 321, 200,
    148, 69, 380, 136, 126, 102, 153, 86, 387, 124, 33, 195,
    224, 209, 311, 178, 112, 120, 49, 65, 20, 43, 82, 102,
    155, 29, 72, 42, 315, 236, 1, 38, 106, 228, 288, 139,
    150, 25, 375, 82, 247
  }
end

function draw_stars()
  for i = 1, #stars_xy / 2, 2 do
    pix(stars_xy[i], (stars_xy[i + 1]
        + (game.tick / 5)) % 400, 8)
  end
end

