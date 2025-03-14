-- State controlling the bare minimum for the vis execution
local Root = class('Root')

function Root.disable()
    log.warn("Root state disabled. Shutting down.")
    love.event.quit()

    return true
end

return Root
