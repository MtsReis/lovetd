-- State controlling the bare minimum for the vis execution
local Root = class('Root')

function Root.load()
end

function Root.enable()
    if pl.tablex.find(arg, "-editor") then
        state.add(require 'states.editor.ScenarioEditor', "ScenarioEditor", 3)
        state.enable("ScenarioEditor")
    else
        state.add(require 'states.scenario.PlayScenario', "PlayScenario", 3)
        state.enable("PlayScenario")
    end
end

function Root.disable()
    log.warn("Root state disabled. Shutting down.")
    love.event.quit()

    return true
end

return Root
