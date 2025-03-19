local Root = class("Root")

function Root.load()
	state.add(require("states.UI"), "UI", 12)
end

function Root.enable()
	if pl.tablex.find(arg, "-editor") then
		state.add(require("states.editor.ScenarioEditor"), "ScenarioEditor", 3)
		state.enable("ScenarioEditor")
	else
		state.add(require("states.GameFlow"), "GameFlow", 4)

		state.enable("GameFlow")
	end
end

function Root.keypressed(command)
	if command == "toggle_debug" then
		amora.debugMode = not amora.debugMode
	elseif command == "toggle_fullscreen" then
		amora.settings.video.fullscreen = not amora.settings.video.fullscreen
        amora:updateVideo()
	elseif command == "pause_game" then
		amora.pause = not amora.pause
	end
end

function Root.disable()
	log.warn("Root state disabled. Shutting down.")
	love.event.quit()

	return true
end

return Root
