require "lib/slither"

class "Sam"
{	
	__init__ = function(self, position, velocity, tex)
		self.position = position or {x=0,y=0}
		self.velocity = {x=0,y=0}
		self.acceleration = {x=0,y=0}
		self.scroll = scroll or{x=0,y=0}
		self.screenPosition = {x =0, y=0}
		self.tex = tex
		self.onGround = true
	end,
	
	draw = function(self)
		love.graphics.draw(self.tex, self.screenPosition.x, self.screenPosition.y)
	end,
	
	
	update = function(self,dt)
	
		-- fall when not on ground
		if self.onGround then
			self.acceleration.y = 0
			self.velocity.y = 0
		else 
			self.acceleration.y = 100
		end
	
		self.velocity.x = self.velocity.x + self.acceleration.x * dt
		self.velocity.y = self.velocity.y + self.acceleration.y * dt
	
		self.position.x = self.position.x + self.velocity.x * dt
		self.position.y = self.position.y + self.velocity.y * dt

		if love.keyboard.isDown("left") then
			self.position.x = self.position.x - (50 * dt)
		end
		
		if love.keyboard.isDown("right") then
			self.position.x = self.position.x + (50 * dt)
		end

		self.screenPosition.x = self.position.x - self.scroll.x
		self.screenPosition.y = self.position.y - self.scroll.y
		
		if self.position.y < 500 then
			self.onGround = false
		else
			self.onGround = true
		end
		
		
	end
}
