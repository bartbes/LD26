require "lib.slither"

class "Minigame" {
	__init__ = function(self)
		self.open = true
		self.won = false
	end,

	update = function(self, dt)
	end,

	keypressed = function(self, key, unicode)
		if key == "escape" then
			self:close(false)
		end
	end,

	close = function(self, won)
		self.open = false
		self.won = won
	end,

	draw = function(self)
	end,

	callback = function() end,
}
