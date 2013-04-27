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
		self.fuel = 100
	end,
	
	draw = function(self)
		love.graphics.draw(self.tex, self.screenPosition.x, self.screenPosition.y)
	end,
	
	
	jump = function(self)
		if self.onGround then
			self.velocity.y = - 100
		end
	end,
		
	
	update = function(self,dt)
	--ACCELERATION
	
		self.acceleration.y = 0
		-- fall when not on ground
		if not self.onGround then
			self.acceleration.y =self.acceleration.y + 100
		end
		
		if  self.onGround then
			self.fuel = self.fuel + (160 * dt)
		elseif love.keyboard.isDown(" ") and self.fuel > 0 then
			self.fuel = self.fuel - (80 * dt)
			self.acceleration.y =self.acceleration.y - 150
		end
		
		if self.fuel > 100 then
			self.fuel = 100
		elseif self.fuel < 0 then
			self.fuel = 0
		end
	
	-- VELOCITY
		self.velocity.x = self.velocity.x + self.acceleration.x * dt
		self.velocity.y = self.velocity.y + self.acceleration.y * dt

		-- cap velocitiy
		if self.velocity.x > 600 then
			self.velocity.x = 600
		elseif self.velocity.x < -600 then
			self.velocity.x = -600
		end
		
		if self.velocity.y > 600 then
			self.velocity.y = 600
		elseif self.velocity.y < -600 then
			self.velocity.y = -600
		end
		
		if self.onGround and self.velocity.y > 0 then
			self.velocity.y = 0
		end
		
	--POSITION
		self.position.x = self.position.x + self.velocity.x * dt
		self.position.y = self.position.y + self.velocity.y * dt

		if love.keyboard.isDown("left", "a") then
			self.position.x = self.position.x - (50 * dt)
		end
		
		if love.keyboard.isDown("right", "d") then
			self.position.x = self.position.x + (50 * dt)
		end

		-- hit ground
		if self.position.y >= 300 and self.velocity.y >= 0 then
			self.onGround = true
			self.position.y = 300
		else
			self.onGround = false
		end
		
		self.screenPosition.x = self.position.x - self.scroll.x
		self.screenPosition.y = self.position.y - self.scroll.y	
		
		
	end
}
