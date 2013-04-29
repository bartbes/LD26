local cache = require "lib.cache"
local state = require "state"

local credits = {}

local text = [[

S.A.M.
Rescue in Space

Brought to you by
Dale James
Joe Mycock
Bart van Strien

Programming
Joe Mycock
Bart van Strien

Graphics
Dale James

Audio
Dale James

Level Designer
Dale James

Entropy Manager
Mao Xing





Thanks for playing!


A winner
You
]]

function credits:load()
	self.pos = 1
	self.largeFont = cache.font("fonts/PrStart.ttf:48")
	self.smallFont = cache.font("fonts/PrStart.ttf:32")
	self.lineheight = self.largeFont:getHeight() + 2

	self.lines = {}
	local font = self.largeFont
	for line in text:gmatch("([^\n]*)\n") do
		table.insert(self.lines,
			{
				font = font,
				text = line
			})
		font = self.smallFont
		if line == "" then
			font = self.largeFont
		end
	end
end

function credits:finish()
	return state.switch(require "states.menu")
end

function credits:update(dt)
	self.pos = self.pos + dt
	if self.pos > #self.lines+2 then
		return self:finish()
	end
end

function credits:keypressed(key, unicode)
	if key == " " or key == "return" or key == "escape" then
		return self:finish()
	end
end

function credits:draw()
	startpos = 720 - self.pos * self.lineheight
	for i, v in ipairs(self.lines) do
		love.graphics.setFont(v.font)
		love.graphics.printf(v.text, 0, startpos, 1280, "center")
		startpos = startpos + self.lineheight
	end
end

return credits
