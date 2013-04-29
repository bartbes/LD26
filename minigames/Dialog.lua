require "classes.Minigame"
local cache = require "lib.cache"

local Dialog
Dialog = class.private "Dialog" (Minigame) {
	__init__ = function(self, text, speed)
		Minigame.__init__(self)

		self.speed = speed or 10
		self.text = text
		self.pos = 1

		self.font = cache.font("fonts/PrStart.ttf:16")
	end,

	update = function(self, dt)
		Minigame.update(self, dt)

		self.pos = self.pos + self.speed * dt

		if self.pos > #self.text + 15 then
			self:close()
		end
	end,

	keypressed = function(self, key, unicode)
		Minigame.keypressed(self, key, unicode)

		if key == " " or key == "return" then
			if self.pos < #self.text then
				self.pos = #self.text
			else
				self:close()
			end
		elseif key == "escape" then
			self:close()
		end
	end,

	draw = function(self)
		love.graphics.setFont(self.font)
		love.graphics.setColor(37, 41, 49)
		love.graphics.rectangle('fill', 490, 240, 300, 80)

		love.graphics.setColor(106, 217, 245)
		love.graphics.printf(self.text:sub(1, math.floor(self.pos)),
			500, 250, 280, "left")

		if math.floor(self.pos)%4 < 2 then
			if self.pos < #self.text then
				love.graphics.polygon('fill', 770, 300, 780, 300, 775, 310)
			else
				love.graphics.polygon('fill', 770, 300, 780, 300, 780, 310, 770, 310)
			end
		end

		love.graphics.setColor(255, 255, 255)
	end,
}

return Dialog
