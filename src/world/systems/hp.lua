local HPSystem = tiny.processingSystem()

HPSystem.filter = tiny.requireAll("hp")

function HPSystem:process(e, dt)
	if e.hp.curr <= 0 then
        HPSystem.world:removeEntity(e)
    end
end

return { hp = HPSystem }
