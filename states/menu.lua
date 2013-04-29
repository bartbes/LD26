local state = require "state"
local cache = require "lib.cache"
local game = require "states.game"
local credits = require "states.credits"

local menu = {}

local entries = {
	{"New game", function() state.switch(game, "levels/lvl1.txt") end},
	{"", function() end},
	{"Credits", function() state.switch(credits) end},
	{"Quit", function() love.event.quit() end},
}

function menu:load()
	self.selection = 1

	--self.bigfont = cache.font("fonts/PrStart.ttf:32")
	self.smallfont = cache.font("fonts/PrStart.ttf:26")
	self.title = cache.image("gfx/logotype.jpg")
end

function menu:keypressed(key)
	if key == "down" then
		self.selection = (self.selection % #entries) + 1
	elseif key == "up" then
		self.selection = ((self.selection - 2) % #entries) + 1
	elseif key == "return" then
		entries[self.selection][2]()
	elseif key == "escape" then
		love.event.quit()
	end
end

function menu:draw()
	--love.graphics.setFont(self.bigfont)
	--love.graphics.printf("S.A.M.", 0, 100, 1280, "center")
	--love.graphics.printf("Rescue in Space", 0, 140, 1280, "center")
	love.graphics.draw(self.title, 640, 60, 0, 0.75, 0.75, 400, 0)

	love.graphics.setFont(self.smallfont)
	local left, right = "> ", " <"
	local str
	for i, v in ipairs(entries) do
		str = v[1]
		if i == self.selection then
			str = left .. str .. right
		end

		love.graphics.printf(str, 0, 350+36*i, 1280, "center")
	end
end

return menu
