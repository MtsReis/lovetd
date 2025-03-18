Persistence = require("system.persistence")

amora = require("system.amora")
amora.debugMode = pl.tablex.find(arg, "-debug") -- Whether '-debug' is present as an arg

input = require("system.input")

local lovelyMoon = require("lib.lovelyMoon")

function love.load()
	-- Load and enable the bootstrapper
	state.add(require("states.Bootstrap"), "Bootstrap", 50)
	state.enable("Bootstrap")
end

function love.update(dt)
	input:update(dt)
	lovelyMoon.update(dt)
end

function love.draw()
	lovelyMoon.draw()
end

function love.keypressed(key, scancode)
	input:keypressed(key, scancode)
end

function love.keyreleased(key, scancode)
	input:keyreleased(key, scancode)
end

function love.textinput(text)
	lovelyMoon.textinput(text)
end

function love.mousemoved(x, y, dx, dy, istouch)
	lovelyMoon.mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button)
	input:keypressed("MOUSE_"..button, "MOUSE_"..button)
end

function love.mousereleased(x, y, button)
	input:keyreleased("MOUSE_"..button, "MOUSE_"..button)
end

function love.wheelmoved(x, y)
	lovelyMoon.wheelmoved(x, y)
end

function love.resize(w, h)
  log.debug("Updating video settings: ", pw(amora.settings.video))
	amora.settings.video.h = h
	amora.settings.video.w = w
end

function love.quit()
	Persistence.saveINI() -- amora.settings -> settings.cfg
	return false
end
