require "lib/slither"
require "classes.TileMap"

class "Sam"
{	
	__init__ = function(self, position, velocity, tex, map)
		self.position = position or {x=0,y=0}
		self.velocity = {x=0,y=0}
		self.acceleration = {x=0,y=0}
		self.scroll = scroll or{x=0,y=0}
		self.screenPosition = {x =0, y=0}
		self.tex = tex
		self.onGround = true
		self.fuel = 100
		self.facingRight = true
		self.texWidth = tex:getWidth()
		self.texHeight = tex:getHeight()
		self.map = map
		self.leftFoot = {x=0,y=0}
		self.rightFoot = {x=0,y=0}
		self.rightHand = {x=0,y=0}
		self.leftHand = {x=0,y=0}
	end,
	
	draw = function(self)
		if self.facingRight then
			love.graphics.draw(self.tex, self.screenPosition.x, self.screenPosition.y)
		else
			love.graphics.draw(self.tex, self.screenPosition.x, self.screenPosition.y,0,-1,1,self.texWidth,0)
		end
	end,
	
	
	jump = function(self)
		if self.onGround then
			self.velocity.y = - 100
		end
	end,
	
	dash = function(self)
		if self.fuel > 25 then
			self.fuel = self.fuel - 25
			if self.facingRight then
				self.velocity.x = 200
			else
				self.velocity.x = -200
			end
		 end
	end,
		
	
		
	
	update = function(self,dt)
	--ACCELERATION
	
		self.acceleration.y = 0
		-- fall when not on ground
		if not self.onGround then
			self.acceleration.y =self.acceleration.y + 100
		end
		
		if  self.onGround and not self.dashing then
			self.fuel = self.fuel + (160 * dt)
		end
			
		if not self.onGround and love.keyboard.isDown(" ") and self.fuel > 0 then
			self.fuel = self.fuel - (80 * dt)
			self.acceleration.y =self.acceleration.y - 150
		end
		
		self.acceleration.x = - self.velocity.x
		
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
		
		if self.velocity.x < 50 and self.velocity.x > -50 then
			self.velocity.x = 0
		end
		
		if self.onGround and self.velocity.y > 0 then
			self.velocity.y = 0
		end
		
	--POSITION
		self.position.x = self.position.x + self.velocity.x * dt
		self.position.y = self.position.y + self.velocity.y * dt

			if love.keyboard.isDown("left", "a") then
				self.position.x = self.position.x - (50 * dt)
				self.facingRight = false
			end
		
			if love.keyboard.isDown("right", "d") then
				self.position.x = self.position.x + (50 * dt)
				self.facingRight = true
			end
			
		self:updateSensors()
		
		--ceiling
		if self.map:isSolid(math.ceil((self.leftHand.x+2)/16),math.ceil((self.leftHand.y)/16)) 
			or self.map:isSolid(math.ceil((self.rightHand.x-2)/16)-1,math.ceil(self.rightHand.y/16)) then
			self.position.y = (math.ceil((self.position.y +7 )/16) * 16 ) -7
			self.velocity.y = 0
			self:updateSensors()
		end
		
		--floor
		if self.map:isSolid(math.ceil((self.leftFoot.x+2)/16),math.floor(self.leftFoot.y/16)+1) 
			or	self.map:isSolid(math.ceil((self.rightFoot.x-2)/16)-1,math.floor(self.rightFoot.y/16)+1)	then
			self.position.y = math.floor(self.position.y/16) * 16 
			self.onGround = true
			self:updateSensors()
		else
			self.onGround = false
		end
		
		--left
		if self.map:isSolid(math.ceil(self.leftFoot.x/16),math.ceil((self.leftFoot.y-2)/16))
			or self.map:isSolid(math.ceil(self.leftHand.x/16),math.ceil((self.leftHand.y+2)/16))	then
			self.position.x =  math.ceil(self.position.x/16) * 16 
			self.velocity.x = 0
			self:updateSensors()
		end
		
		--right
		if self.map:isSolid(math.floor((self.rightFoot.x)/16),math.ceil((self.rightFoot.y-2)/16))
			or self.map:isSolid(math.floor((self.rightHand.x)/16),math.ceil((self.rightHand.y+2)/16))	then
			self.position.x = (math.floor((self.position.x )/16) * 16) 
			self.velocity.x = 0
		end
		

		self.scroll.x = -self.position.x + 300
		--self.scroll.x = 20
		self.screenPosition.x = self.position.x + self.scroll.x
		self.screenPosition.y = self.position.y + self.scroll.y	
		
		
	end,
	
	updateSensors = function(self)
		self.leftFoot.x = self.position.x 
		self.leftFoot.y = self.position.y + self.texHeight 
		self.rightFoot.x = self.position.x + self.texHeight 
		self.rightFoot.y = self.position.y + self.texHeight 
		self.rightHand.x = self.position.x + self.texHeight 
		self.rightHand.y = self.position.y +7  --wtf
		self.leftHand.x = self.position.x 
		self.leftHand.y = self.position.y +7 
	end

}
