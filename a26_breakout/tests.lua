-----------------------------------------------------------
-- TESTS

function test1()
  init_ball()
  game.ball.x = 56; game.ball.y = 90
  game.ball.dx = -0.2; game.ball.dy = -0.8
  game.ball.speed = 1.5
  game.bricks[(18*4)+1]=nil
  game.bricks[(18*4)+4]=nil
  game.bricks[(18*5)+1]=nil
  game.bricks[(18*5)+4]=nil
end

function test2()
  init_ball()
  game.ball.x = 56; game.ball.y = 90
  game.ball.dx = -0.2; game.ball.dy = -0.8
  game.ball.speed = 1.5
  game.bricks[(18*3)+3]=nil
  game.bricks[(18*4)+3]=nil
  game.bricks[(18*5)+3]=nil
end

function test3()
  init_ball()
  game.ball.x = 179.83; game.ball.y = 59.60
  game.ball.dx = 0.31; game.ball.dy = -0.69
  game.ball.speed = 1.86
  game.bricks[(18*5)+16]=nil
end
