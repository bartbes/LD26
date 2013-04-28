local state = require "state"
local game = require "states.game"
--local credits = require "states.credits"

local menu = {}

local entries = {
	{"New game", function() state.switch(game, "levels/lvl1.txt") end},
	{"", function() end},
	{"Credits", function() state.switch(credits) end},
	{"Quit", function() love.event.quit() end},
}

function menu:load()
	self.selection = 1
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
	love.graphics.printf("S.A.M.", 0, 100, 1280, "center")
	love.graphics.printf("Rescue in Space", 0, 120, 1280, "center")

	local left, right = "> ", " <"
	local str
	for i, v in ipairs(entries) do
		str = v[1]
		if i == self.selection then
			str = left .. str .. right
		end

		love.graphics.printf(str, 0, 200+20*i, 1280, "center")
	end
end

return menu
