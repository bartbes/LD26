require "classes.TileMap"
require "classes.Sam"
local cache = require "lib.cache"

local game = {}

function game:load()
	self.timer = 0
	samTex = cache.image("gfx/sam.png")
	sam = Sam({x=400,y=100},{x=0,y=0}, samTex)
	self.map = TileMap.fromFile("gfx/tileset.png", "levels/lvl1.txt")

	love.graphics.setBackgroundColor(200, 100, 120)
end

function game:update(dt)
	self.timer = self.timer + dt
	sam:update(dt)
end

function game:draw()
	love.graphics.scale(2, 2)
	self.map:draw(sam.scroll.x, sam.scroll.y)
	sam:draw()
	drawFuelGuage()
end

function game:keypressed(key, unicode)
	if key == " " then
		sam:jump()
	elseif key == "b" then
		sam:dash()
	elseif key == "escape" then
		love.event.push("quit")
	end
end

function drawFuelGuage()
	length = 32*(sam.fuel/100)
	if sam.fuel < 25 then
		love.graphics.setColor(191,55,59)
	elseif sam.fuel < 50 then
		love.graphics.setColor(233,235,58)
	else
		love.graphics.setColor(97,202,94)
	end
	love.graphics.rectangle("fill", 550, 10, length, 8 )
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line", 550, 10, 32, 8 )
	love.graphics.setColor(255,255,255)
end

return game
