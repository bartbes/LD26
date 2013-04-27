require "Classes/Sam"

local intro = {}

function intro:load()
	self.timer = 0
	samTex = love.graphics.newImage("SamTest.png")
	sam = Sam({x=400,y=100},{x=0,y=0}, samTex)
end

function intro:update(dt)
	self.timer = self.timer + dt
	sam:update(dt)
end

function intro:draw()
	love.graphics.rectangle('fill',
		500 + 50*math.sin(self.timer),
		500 + 50*math.cos(self.timer),
		100, 100)
		sam:draw()
end

return intro
