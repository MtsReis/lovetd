local movementSystem = tiny.processingSystem()

movementSystem.filter = tiny.requireAll("pos", "velocity")

function movementSystem:process(e, dt)
    local velocity = e.velocity.dir * e.velocity.speed * dt
    
    e.pos = e.pos + velocity
end

return { movement = movementSystem }
