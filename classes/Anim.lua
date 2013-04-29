require "lib.slither"
local cache = require "lib.cache"

class "Anim" {
	__init__ = function(self, image, w, h, speed)
		self.image = image
		self.speed = speed
		self.timer = 0
		self.curquad = 1
		self.playing = false
		self.width = w
		self.height = h

		self.quads = {}
		for y = 0, self.image:getHeight()-1, h do
			for x = 0, self.image:getWidth()-1, w do
				table.insert(self.quads, love.graphics.newQuad(x, y, w, h, self.image:getWidth(), self.image:getHeight()))
			end
		end
		assert(#self.quads >= 1, "Needs at least 1 frame!")
	end,

	play = function(self)
		self.playing = true
	end,

	stop = function(self)
		self.playing = false
	end,

	rewind = function(self)
		self.curquad = 1
	end,

	getWidth = function(self)
		return self.width
	end,

	getHeight = function(self)
		return self.height
	end,

	update = function(self, dt)
		if not self.playing then return end
		self.timer = self.timer + dt
		while self.timer > self.speed do
			self.timer = self.timer - self.speed
			self.curquad = self.curquad%#self.quads + 1
		end
	end,

	draw = function(self, ...)
		return love.graphics.drawq(self.image, self.quads[self.curquad], ...)
	end,
}
