local intro = {}

function intro:load()
	self.timer = 0
end

function intro:update(dt)
	self.timer = self.timer + dt
end

function intro:draw()
	love.graphics.rectangle('fill',
		500 + 50*math.sin(self.timer),
		500 + 50*math.cos(self.timer),
		100, 100)
end

return intro
