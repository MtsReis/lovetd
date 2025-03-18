local collisionSystem = tiny.processingSystem()

collisionSystem.filter = tiny.requireAll("pos", "collisionbox")

function collisionSystem:process(e, dt)
    e.collisionbox.shape:moveTo(e.pos.x, e.pos.y)

    if e.pos.x + e.collisionbox.w >= collisionSystem.world.properties.width then
        e.pos.x = 0
    end
end

----------------------------------------
local worldBoundariesSystem = tiny.processingSystem()

worldBoundariesSystem.filter = tiny.requireAll("pos")

function worldBoundariesSystem:process(e, dt)
    if e.pos.x < 0 then
        e.pos.x = 0
    end

    if e.pos.x > collisionSystem.world.properties.width then
        e.pos.x = collisionSystem.world.properties.width
    end

    if e.pos.y < 0 then
        e.pos.y = 0
    end

    if e.pos.y > collisionSystem.world.properties.height then
        e.pos.y = collisionSystem.world.properties.height
    end
end

return { collision = collisionSystem, worldBoundaries = worldBoundariesSystem }
