require "classes.TileMap"

local intro = {}

function intro:load()
	self.timer = 0
	self.map = TileMap("gfx/testsheet.png", {
		"ab8YA",
		"77n-+",
	})

	love.graphics.setBackgroundColor(200, 100, 120)
end

function intro:update(dt)
	self.timer = self.timer + dt
end

function intro:draw()
	love.graphics.rectangle('fill',
		500 + 50*math.sin(self.timer),
		500 + 50*math.cos(self.timer),
		100, 100)
	self.map:draw()
end

return intro
