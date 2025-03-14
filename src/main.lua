Persistence = require 'system.persistence'
amora = require 'system.amora'
amora.debugMode = pl.tablex.find(arg, "-debug") -- Whether '-debug' is present as an arg

local lovelyMoon = require 'lib.lovelyMoon'

function love.load()
  -- Load and enable the bootstrapper
  state.add(require 'states.Bootstrap', "Bootstrap", 3)
  state.enable("Bootstrap")
end

function love.update(dt)
  lovelyMoon.update(dt)
end

function love.draw()
  lovelyMoon.draw()
end

function love.keypressed(key, scancode)
  lovelyMoon.keypressed(key, scancode)
end

function love.keyreleased(key, scancode)
  lovelyMoon.keyreleased(key, scancode)
end

function love.textinput(text)
  lovelyMoon.textinput(text)
end

function love.mousemoved(x, y, dx, dy, istouch)
  lovelyMoon.mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button)
  lovelyMoon.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  lovelyMoon.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
  lovelyMoon.wheelmoved(x, y)
end

function love.quit()
  Persistence.saveINI() -- amora.settings -> settings.cfg
  return false
end