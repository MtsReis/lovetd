local collisionSystem = tiny.processingSystem()

collisionSystem.filter = tiny.requireAll("pos", "collisionbox")

function collisionSystem:process(e, dt)
    e.collisionbox.shape:moveTo(e.pos.x, e.pos.y)

    if e.pos.x + e.collisionbox.w >= collisionSystem.world.properties.width then
        e.pos.x = 0
    end
end

return { collision = collisionSystem }
