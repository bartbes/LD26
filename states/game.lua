require "classes.TileMap"
require "classes.Sam"
local cache = require "lib.cache"
local state = require "state"
local bgm = require "bgm"

local game = {}

function game:load(level)
	self.timer = 0
	self.map = TileMap.fromFile(level)
	samTex = cache.image("gfx/sam.png")
	lightTex = cache.image("gfx/flashlight.png")
	local spawn = self.map.level:getSpawn()
	local pos = {x = (spawn.x-1)*16, y = (spawn.y-1)*16}
	sam = Sam(pos, samTex, self.map, lightTex)

	bgm.start()

	love.graphics.setBackgroundColor(200, 100, 120)
end

function game:unload()
	bgm.stop()
end

function game:update(dt)
	self.timer = self.timer + dt
	bgm.update()
	if sam.alive then
		sam:update(dt)
	else
		sam:spawn()
	end
	if sam.levelComplete then
		local nextlevel = self.map.level:getNextLevel()
		if nextlevel then
			love.timer.sleep(0.100)
			state.switch(self, nextlevel():getLevelFile())
		else
			state.switch(THE_END)
		end
	end
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
	elseif key == "i" then
		sam:interactWithTerminal()
	elseif key == "f" then
		sam:toggleLight()
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
