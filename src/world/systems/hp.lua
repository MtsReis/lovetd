local DrawHpSystem = tiny.processingSystem()
local CONTAINER_SIDE_W = 5
local CONTAINER_H = 15
local CONTAINER_TOP_H = 3
local HEALTHBAR_CONTENT_H = 5

DrawHpSystem.filter = tiny.requireAll("hp", "canvas", "pos", "geometry")

function DrawHpSystem:process(e, dt)
	local container_img_s = DrawHpSystem.world.resources.hp_container_s
	local container_img_c = DrawHpSystem.world.resources.hp_container_c
	local content_img = DrawHpSystem.world.resources.hp_content
	local maxHealthBar = e.hp.max / 2
	local healthContent = math.max(0, e.hp.curr / 2)
	local color = { 241/255, 24/255, 45/255, 1 }

	love.graphics.setCanvas(e.canvas)
	local x, y = e.pos.x - CONTAINER_SIDE_W - maxHealthBar / 2, e.pos.y - e.geometry.h - CONTAINER_H

	love.graphics.draw(container_img_s, x, y, 0, 1, 0.5)
	love.graphics.draw(container_img_c, x + CONTAINER_SIDE_W, y, 0, maxHealthBar, 0.5)
	love.graphics.draw(container_img_s, x + CONTAINER_SIDE_W + maxHealthBar, y, 0, 1, 0.5)

	love.graphics.setColor(color)
	love.graphics.rectangle("fill", x + CONTAINER_SIDE_W, y + CONTAINER_TOP_H / 2, healthContent, HEALTHBAR_CONTENT_H)

	love.graphics.setColor(1, 1, 1)
	love.graphics.setCanvas()
end

return { drawHp = DrawHpSystem }
