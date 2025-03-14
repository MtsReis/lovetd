-- State controlling the bare minimum for the vis execution
local Root = class('Root')

function Root.load()
    if pl.tablex.find(arg, "-editor") then
        state.add(require 'states.scenario.PlayScenario', "ScenarioEditor", 2)
    else
        state.add(require 'states.editor.ScenarioEditor', "PlayScenario", 2)
    end
end

function Root.enable()
    if pl.tablex.find(arg, "-editor") then
        state.enable("ScenarioEditor")
    else
        state.enable("PlayScenario")
    end
end

function Root.disable()
    log.warn("Root state disabled. Shutting down.")
    love.event.quit()

    return true
end

return Root
