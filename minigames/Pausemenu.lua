require "classes.Minigame"
local cache = require "lib.cache"

local function toOnline(bool)
	return bool and "ONLINE" or "OFFLINE"
end

local Pausemenu
Pausemenu = class.private "Pausemenu" (Minigame) {
	__init__ = function(self, map, sam)
		Minigame.__init__(self)

		self.time = map.timer
		self.score = map.score

		self.abilities = sam.abilities

		self.font = cache.font("fonts/PrStart.ttf:16")
	end,

	keypressed = function(self, key, unicode)
		if key == "escape" then
			love.event.quit()
		else
			self:close()
		end

		return Minigame.keypressed(self, key, unicode)
	end,

	draw = function(self)
		love.graphics.setFont(self.font)
		love.graphics.setColor(37, 41, 49)
		love.graphics.rectangle('fill', 340, 240, 600, 200)

		love.graphics.setColor(106, 217, 245)
		love.graphics.printf("> PAUSED <", 350, 250, 580, "center")
		love.graphics.printf("Press Esc to quit, and anything else to continue", 350, 270, 580, "center")

		love.graphics.print("Score:        " .. self.score, 350, 330)
		love.graphics.print(("Time:  %.2f"):format(self.time), 700, 330)

		love.graphics.print("Rocket jump:  " .. toOnline(self.abilities.rocketJump), 350, 370)
		love.graphics.print("Flashlight:   " .. toOnline(self.abilities.flashlight), 350, 390)
		love.graphics.print("Extinguisher: " .. toOnline(self.abilities.extinguisher), 350, 410)
		love.graphics.print("Boost: " .. toOnline(self.abilities.boost), 700, 370)
		love.graphics.print("Laser: " .. toOnline(self.abilities.laser), 700, 390)

		love.graphics.setColor(255, 255, 255)
	end,
}

return Pausemenu
