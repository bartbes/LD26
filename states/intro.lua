require "classes.TileMap"
require "classes.Sam"
local cache = require "lib.cache"

local intro = {}

function intro:load()
	self.timer = 0
	samTex = cache.image("gfx/sam.png")
	sam = Sam({x=400,y=100},{x=0,y=0}, samTex)
	self.map = TileMap("gfx/testsheet.png", {
		"ab8YA",
		"77n-+",
	})

	love.graphics.setBackgroundColor(200, 100, 120)
end

function intro:update(dt)
	self.timer = self.timer + dt
	sam:update(dt)
end

function intro:draw()
	love.graphics.scale(2, 2)
	self.map:draw()
	sam:draw()
end

function intro:keypressed(key, unicode)
	if key == " " then
		sam:jump()
	end
end

return intro
