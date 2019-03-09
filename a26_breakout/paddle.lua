-----------------------------------------------------------
-- PADDLE

function init_paddle()
  game.paddle = {
    x = 60,
    y = 132,
    w = 20,
    h = 3,
    color = 6,
    sfx = 62,
    speed = 6,
    tostring = function(self)
      return string.format(
        "paddle { x=%.2f, y=%.2f, w=%d, h=%d, color=%d, speed=%.2f }",
        self.x, self.y, self.w, self.h, self.color, self.speed)
    end
  }
end

function move_paddle_left()
  local p = game.paddle
  p.x = math.max(p.x - p.speed, 30)
end

function move_paddle_right()
  local p = game.paddle
  p.x = math.min(p.x + p.speed, 190)
end

function move_paddle_to(x)
  local p = game.paddle
  p.x = math.min(math.max(x, 30), 190)
end

function draw_paddle()
  local p = game.paddle
  rect(p.x, p.y, p.w, p.h, p.color)
end

