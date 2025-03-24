local GameFlow = class("GameFlow")

local UI

local scene = ""

local _player = {}
local _gameScenes = {
	main_menu = {},
	load_game = {},
	save_game = {},
	level_selection = {},
	gameplay = {},
	game_results = {},
}

function GameFlow.load()
end

function GameFlow:enable()
	state.enable("UI", "MainMenu")
	UI = state.get("UI")

	self.changeScene("main_menu")
end

function GameFlow.changeScene(newScene)
	-- Default scene
	newScene = _gameScenes[newScene] and newScene or "main_menu"

	if newScene ~= scene or newScene == "gameplay" then
		log.debug("Ending scene '%(s)s'" % { s = scene })
		local _ = _gameScenes[scene] and _gameScenes[scene].endScene and _gameScenes[scene]:endScene()

		log.debug("Starting scene '%(s)s'" % { s = newScene })
		_ = _gameScenes[newScene].startScene and _gameScenes[newScene]:startScene()
		scene = newScene
	end
end

--------= Main Menu =--------

function _gameScenes.main_menu:startScene()
	UI:changePresentation("MainMenu", {
		onNewGame = function()
			GameFlow.changeScene("gameplay")
		end,
		onSettings = function()
			print("Check options!")
		end,
	})
end

function _gameScenes.main_menu:endScene() end

--------= Load Game =--------

function _gameScenes.load_game:startScene() end

function _gameScenes.load_game:endScene() end

--------= Save Game =--------

function _gameScenes.save_game:startScene() end

function _gameScenes.save_game:endScene() end

--------= Gameplay =--------

function _gameScenes.gameplay:startScene()
	state.add(require("states.scenario.PlayScenario"), "PlayScenario", 3)
	state.enable("PlayScenario")
end

function _gameScenes.gameplay:endScene()
	state.disable("PlayScenario")
	state.destroy("PlayScenario")
end

--------= Level Selection =--------

function _gameScenes.level_selection:startScene()
	print("Escolha level")
end

function _gameScenes.level_selection:endScene() end

--------= Game Results =--------

function _gameScenes.game_results:startScene() end

function _gameScenes.game_results:endScene() end

return GameFlow
