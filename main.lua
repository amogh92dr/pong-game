
push = require 'push'
Class = require 'class'
require 'Ball'
require 'Paddle'
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
PADDLE_SPEED = 200


--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = true,
    vsync = true,
    canvas = false
  })
  sounds = {
    ['hit_wall'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static')
  }
  smallfont = love.graphics.newFont('font.ttf', 8)
  largefont = love.graphics.newFont('font.ttf', 16)
  scorefont = love.graphics.newFont('font.ttf', 32)
  love.window.setTitle('Pong!');
  math.randomseed(os.time());

  servingPlayer = 1
  winningPlayer = 0
  player1Score = 0
  player2Score = 0
  player1 = Paddle(10, VIRTUAL_HEIGHT / 2 - 10, 5, 20)
  player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT / 2 - 10, 5, 20)
  ball = Ball(4)
  --[[
  gamestates: Start, Serve,Play, Done
  ]]
  gamestate = 'start'
  -- gamemodes: versus, demo, single
  gamemode = 'versus'
end

function love.update(dt)
  if(gamemode == 'single' or gamemode == 'versus') then
    player1:update(dt)
  end
  if(gamemode == 'versus') then
    player2:update(dt)
  end
  if(gamemode == 'demo' and gamestate == 'serve') then
    yballspeed = math.random(-50, 50)
    ball.dy = yballspeed
    if(gamemode == 'single' or gamemode == 'demo') then
      player2.dy = yballspeed
      player1.dy = yballspeed
    end
    if(servingPlayer == 1) then
      ball.dx = math.random(140, 200)
    elseif (servingPlayer == 2) then
      ball.dx = -math.random(140, 200)
    end
    gamestate = 'play'
  end
  if (gamestate == 'serve') then
    yballspeed = math.random(-50, 50)
    ball.dy = yballspeed
    if(gamemode == 'single' or gamemode == 'demo') then
      player2.dy = yballspeed
      player1.dy = yballspeed
    end
    if(servingPlayer == 1) then
      ball.dx = math.random(140, 200)
    elseif (servingPlayer == 2) then
      ball.dx = -math.random(140, 200)
    end
  elseif(gamestate == 'play') then
    ball:update(dt)
    player2:update(dt)
    player1:update(dt)
    if ball:collides(player1) then
      ball.dx = -ball.dx * 1.03
      ball.x = player1.x + 5

      -- keep velocity going in the same direction, but randomize it
      if ball.dy < 0 then
        yballspeed = math.random(10, 150)
        ball.dy = -yballspeed
        if(gamemode == 'single' or gamemode == 'demo') then
          player2.dy = -yballspeed
        end
        if(gamemode == 'demo') then
          player1.dy = -yballspeed
        end
      else
        yballspeed = math.random(10, 150)
        ball.dy = yballspeed
        if(gamemode == 'single' or gamemode == 'demo') then
          player2.dy = yballspeed
        end
        if(gamemode == 'demo') then
          player1.dy = yballspeed
        end
      end

      sounds['paddle_hit']:play()
    end
    if ball:collides(player2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x - 4

      -- keep velocity going in the same direction, but randomize it
      if ball.dy < 0 then
        yballspeed = math.random(10, 150)
        ball.dy = -yballspeed
        if(gamemode == 'single' or gamemode == 'demo') then
          player2.dy = -yballspeed
        end
        if(gamemode == 'demo') then
          player1.dy = -yballspeed
        end
      else
        yballspeed = math.random(10, 150)
        ball.dy = yballspeed
        -- AI will not track ball if it hit player 2 and moving in y positive direction
        if( gamemode == 'demo') then
          player1.dy = yballspeed
        end
      end

      sounds['paddle_hit']:play()
    end
    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
      if(gamemode == 'single' or gamemode == 'demo') then
        player2.dy = -player2.dy
      end
      if(gamemode == 'demo') then
        player1.dy = -player1.dy
      end
      sounds['hit_wall']:play()
    end

    -- -4 to account for the ball's size
    if ball.y >= VIRTUAL_HEIGHT - 4 then
      ball.y = VIRTUAL_HEIGHT - 4
      ball.dy = -ball.dy
      if(gamemode == 'single' or gamemode == 'demo') then
        player2.dy = -player2.dy
      end
      if(gamemode == 'demo') then
        player1.dy = -player1.dy
      end
      sounds['hit_wall']:play()
    end
    if ball.x < 0 then
      servingPlayer = 1
      player2Score = player2Score + 1
      sounds['score']:play()

      -- if we've reached a score of 10, the game is over; set the
      -- state to done so we can show the victory message
      if player2Score == 10 then
        winningPlayer = 2
        gamestate = 'done'
      else
        gamestate = 'serve'
        -- places the ball in the middle of the screen, no velocity
        ball:reset()
        if(gamemode == 'single' or gamemode == 'demo') then
          player2:reset()
        end
        if(gamemode == 'demo') then
          player1:reset()
        end
      end
    end

    if ball.x > VIRTUAL_WIDTH then
      servingPlayer = 2
      player1Score = player1Score + 1
      sounds['score']:play()

      if player1Score == 10 then
        winningPlayer = 1
        gamestate = 'done'
      else
        gamestate = 'serve'
        ball:reset()
        if(gamemode == 'single' or gamemode == 'demo') then
          player2:reset()
        end
        if(gamemode == 'demo') then
          player1:reset()
        end
      end
    end
  end

  if(gamemode == 'versus' or gamemode == 'single') then
    if love.keyboard.isDown('w') then
      player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
      player1.dy = PADDLE_SPEED
    else
      player1.dy = 0
    end
  end
  --player 2
  if(gamemode == 'versus') then
    if love.keyboard.isDown('up') then
      player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
      player2.dy = PADDLE_SPEED
    else
      player2.dy = 0
    end
  end
  -- update our ball based on its DX and DY only if we're in play state;
  -- scale the velocity by dt so movement is framerate-independent
end

function love.keypressed(key)
  if(key == 'escape') then
    love.event.quit()
  end
  if(key == '1' and gamestate == 'start') then
    gamestate = 'serve'
    gamemode = 'versus'
  end
  if(key == '2' and gamestate == 'start') then
    gamestate = 'serve'
    gamemode = 'single'
  end
  if(key == '3' and gamestate == 'start') then
    gamestate = 'serve'
    gamemode = 'demo'
  end
  if(key == 'enter' or key == 'return') then
    if(gamestate == 'start') then
      gamestate = 'serve'
      else if (gamestate == 'serve') then
        gamestate = 'play'
        else if (gamestate == 'done') then
          gamestate = 'serve'
          ball:reset()
          player2:reset()
          player1:reset()
          -- reset scores to 0
          player1Score = 0
          player2Score = 0
          -- decide serving player as the opposite of who won
          if winningPlayer == 1 then
            servingPlayer = 2
          else
            servingPlayer = 1
          end
        end
      end
    end
  end
end
--[[
    Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
  push:start()
  if (gamestate == 'start') then
    love.graphics.setFont(smallfont)
    love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter OR 1 to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter 2 for single player!', 0, 30, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter 3 for demo!', 0, 40, VIRTUAL_WIDTH, 'center')
    else if(gamestate == 'serve') then
      love.graphics.setFont(smallfont)
      if(servingPlayer == 2 and gamemode == 'single') then
        love.graphics.printf('Its AI\'s chance to serve', 0, 10, VIRTUAL_WIDTH, 'center')
      else
        love.graphics.printf('Its player '.. tostring(servingPlayer) .. "'s chance to serve", 0, 10, VIRTUAL_WIDTH, 'center')
      end
      love.graphics.printf('Press Enter to Serve!', 0, 20, VIRTUAL_WIDTH, 'center')
      else if(gamestate == 'play') then
        -- no static Render
        else if (gamestate == 'done') then
          love.graphics.setFont(largefont)
          if(winningPlayer == 2 and gamemode == 'single') then
            love.graphics.printf('AI wins and will now take over the world', 0, 10, VIRTUAL_WIDTH, 'center')
          else
            love.graphics.printf('The Winner is '.. tostring(winningPlayer) .. "!!", 0, 10, VIRTUAL_WIDTH, 'center')
          end
          love.graphics.setFont(smallfont)
          love.graphics.printf('Press Escape key to Quit', 0, 40, VIRTUAL_WIDTH, 'center')
          love.graphics.printf('Press Enter to Restart Game', 0, 50, VIRTUAL_WIDTH, 'center')
        end
      end
    end
  end
  displayScore()

  player1:render()
  player2:render()
  ball:render()
  push:finish()
end

function love.resize(w, h)
  push:resize(w, h)
end

function displayScore()
  -- score display
  love.graphics.setFont(scorefont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
  VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
  VIRTUAL_HEIGHT / 3)
end
