local DrawHpSystem = tiny.processingSystem()
local CONTAINER_SIDE_W = 5
local CONTAINER_H = 15
local CONTAINER_TOP_H = 3
local HEALTHBAR_CONTENT_H = 5

DrawHpSystem.filter = tiny.requireAll("hp", "canvas", "pos", "geometry")

function DrawHpSystem:process(e, dt)
	local font = self.world.resources.statsFont
	local textH = font:getHeight()

	local container_img_s = self.world.resources.hp_container_s
	local container_img_c = self.world.resources.hp_container_c
	local hp_tower = self.world.resources.hp_tower
	local hp_tower_scale = 0.3
	local content_img = self.world.resources.hp_content

	local atk_icon = self.world.resources.atk
	local atk_spd_icon = self.world.resources.atk_spd

	local maxHealthBar = e.hp.max / 2
	local healthContent = math.max(0, e.hp.curr / 2)
	local color = e.team and e.team == 1 and { 114 / 255, 234 / 255, 78 / 255, 1 }
		or { 241 / 255, 24 / 255, 45 / 255, 1 }
	local width = e.sprite and e.sprite.img:getWidth() or e.geometry.w
	local height = e.sprite and e.sprite.img:getHeight() or e.geometry.h
	height = height * e.sprite.sy

	love.graphics.setCanvas(e.canvas)
	local x, y = e.pos.x - CONTAINER_SIDE_W - maxHealthBar / 2, e.pos.y - height - CONTAINER_H / 2

	if y <= 0 then
		y = 5
	end

	if self.world.properties.showHP or e == self.world.player.main_tower then
		love.graphics.draw(container_img_s, x, y, 0, 1, 0.5)
		love.graphics.draw(container_img_c, x + CONTAINER_SIDE_W, y, 0, maxHealthBar, 0.5)
		love.graphics.draw(container_img_s, x + CONTAINER_SIDE_W + maxHealthBar, y, 0, 1, 0.5)

		love.graphics.setColor(color)
		love.graphics.rectangle(
			"fill",
			x + CONTAINER_SIDE_W,
			y + CONTAINER_TOP_H / 2,
			healthContent,
			HEALTHBAR_CONTENT_H
		)

		love.graphics.setColor(1, 1, 1)

		if e == self.world.player.main_tower then
			love.graphics.draw(
				hp_tower,
				x - hp_tower:getWidth() * hp_tower_scale / 2,
				y - hp_tower:getHeight() * hp_tower_scale / 2,
				0,
				hp_tower_scale,
				hp_tower_scale
			)
		end
	end

	-- Stats
	if self.world.properties.selectedEntity == e and e.attack then
		love.graphics.setFont(font)
		local min, max =
			e.attack.baseDamage - e.attack.minDamageDecrement, e.attack.baseDamage + e.attack.maxDamageIncrement

		local text = "%(min)d - %(max)d" % { min = min, max = max }
		local textW = font:getWidth(text)
		love.graphics.print(text, e.pos.x - textW / 2, y + CONTAINER_H + 1)
		love.graphics.draw(atk_icon, e.pos.x - textW / 2 - 20, y + CONTAINER_H + 1, 0, 0.7, 0.7)

		if e.attack.cooldownTime % 1 == 0 then
			text = "%(dps)d"
		elseif e.attack.cooldownTime * 10 % 1 == 0 then
			text = "%(dps).1f"
		else
			text = "%(dps).2f"
		end

		text = text % { dps = e.attack.cooldownTime }

		textW = font:getWidth(text)
		love.graphics.print(text, e.pos.x - textW / 2, y + CONTAINER_H + textH + 1)
		love.graphics.draw(atk_spd_icon, e.pos.x - textW / 2 - 20, y + CONTAINER_H + textH + 1, 0, 0.7, 0.7)
	end

	love.graphics.setCanvas()
end

return { drawHp = DrawHpSystem }
