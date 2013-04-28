require "lib/slither"
require "classes.TileMap"
local sfx = require "sfx"

class "Sam"
{	
	__init__ = function(self, position, tex, map)
		self.spawnPos = position
		self.tex = tex
		self.texWidth = tex:getWidth()
		self.texHeight = tex:getHeight()
		self.sfx = {}

		self.abilities = {
			rocketJump = true,
			boost = true,
		}
		map.level:transferAbilities(self)

		self.map = map
		self:spawn()
	end,
	
	spawn = function(self)
		self.position = {x=self.spawnPos.x,y=self.spawnPos.y}
		self.velocity = {x=0,y=0}
		self.acceleration = {x=0,y=0}
		self.scroll = scroll or{x=0,y=0}
		self.screenPosition = {x =0, y=0}
		self.onGround = true
		self.fuel = 100
		self.facingRight = true
		self.leftFoot = {x=0,y=0}
		self.rightFoot = {x=0,y=0}
		self.rightHand = {x=0,y=0}
		self.leftHand = {x=0,y=0}
		self.jumping = false
		self.alive = true
		self.levelComplete = false
		self.extiguishing = false
		self.adjacentTile = {x=0,y=0}
		self.flashlight = false
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
			self.jumping = true
			sfx.play("jumpValve")
		end
	end,
	
	dash = function(self)
		if self.fuel >= 25 and self.abilities.boost then
			self.fuel = self.fuel - 25
			if self.facingRight then
				self.velocity.x = 200
			else
				self.velocity.x = -200
			end
		 end
	end,
	
	toggleLight = function(self)
		self.flashlight = not self.flashlight
	end
	
	interactWithTerminal = function(self)
		if self.map:isTerminalTile(self.adjacentTile.x,self.adjacentTile.y) then
			self.map.activateTerminal(self.adjacentTile.x,self.adjacentTile.y)
		end
	end,
		
		
	
		
	
	update = function(self,dt)
	--ACCELERATION
	
		self.acceleration.y = 0
		-- fall when not on ground
		if not self.onGround then
			self.acceleration.y =self.acceleration.y + 100
		end
		
		if not self.onGround and not self.jumping and love.keyboard.isDown(" ") and self.fuel > 0 and self.abilities.rocketJump then
			if not self.sfx.jetpack then
				self.sfx.jetpack = sfx.play("jetpack")
			end
			self.fuel = self.fuel - (80 * dt)
			self.acceleration.y =self.acceleration.y - 200
		elseif self.sfx.jetpack then
			self.sfx.jetpack:stop()
			self.sfx.jetpack = nil
		end
		
		self.acceleration.x = - self.velocity.x

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
		
		if self.jumping and self.velocity.y >=0 then
			self.jumping = false
		end
		
		if  self.onGround and not self.dashing and self.velocity.x == 0 then
			self.fuel = self.fuel + (70 * dt)
		end
		
		if self.fuel > 100 then
			self.fuel = 100
		elseif self.fuel < 0 then
			self.fuel = 0
		end
		
	--POSITION
		self.position.x = self.position.x + self.velocity.x * dt
		self.position.y = self.position.y + self.velocity.y * dt

		local moving = false
		if love.keyboard.isDown("left", "a") then
			moving = true
			self.position.x = self.position.x - (70 * dt)
			self.facingRight = false
		end
	
		if love.keyboard.isDown("right", "d") then
			moving = true
			self.position.x = self.position.x + (70 * dt)
			self.facingRight = true
		end

		if moving and not self.sfx.motor then
			self.sfx.motor = sfx.play("motor")
			self.sfx.motor:setLooping(true)
		end
		if not moving and self.sfx.motor then
			self.sfx.motor:stop()
			self.sfx.motor = nil
		end
		
		

		
		self:updateSensors()
		
		--ceiling
		if self.map:isSolid(math.ceil((self.leftHand.x+3)/16),math.ceil((self.leftHand.y)/16)) 
			or self.map:isSolid(math.ceil((self.rightHand.x-3)/16)-1,math.ceil(self.rightHand.y/16)) then
			self.position.y = (math.ceil((self.position.y +7 )/16) * 16 ) -7
			self.velocity.y = 0
			self:updateSensors()
		end
		
		--floor
		if self.map:isSolid(math.ceil((self.leftFoot.x+3)/16),math.floor(self.leftFoot.y/16)+1) 
			or	self.map:isSolid(math.ceil((self.rightFoot.x-3)/16)-1,math.floor(self.rightFoot.y/16)+1)	then
			self.position.y = math.floor(self.position.y/16) * 16 

			if not self.onGround then
				sfx.play("land")
			end
			self.onGround = true
			self:updateSensors()
		else
			self.onGround = false
		end
		
		--left
		if self.map:isSolid(math.ceil(self.leftFoot.x/16),math.ceil((self.leftFoot.y-3)/16))
			or self.map:isSolid(math.ceil(self.leftHand.x/16),math.ceil((self.leftHand.y+3)/16))	then
			self.position.x =  math.ceil(self.position.x/16) * 16 
			self.velocity.x = 0
			self:updateSensors()
		end
		
		--right
		if self.map:isSolid(math.floor((self.rightFoot.x)/16),math.ceil((self.rightFoot.y-3)/16))
			or self.map:isSolid(math.floor((self.rightHand.x)/16),math.ceil((self.rightHand.y+3)/16))	then
			self.position.x = (math.floor((self.position.x )/16) * 16) 
			self.velocity.x = 0
			self:updateSensors()
		end
		
		
		
		--inWinningTile
		if self.map:isWinningTile(math.ceil((self.leftFoot.x+3)/16),math.floor(self.leftFoot.y/16)) 
			or	self.map:isWinningTile(math.ceil((self.rightFoot.x-3)/16)-1,math.floor(self.rightFoot.y/16))	then
			self.levelComplete = true
			self:updateSensors()
		end
		
		--inDeadlyTile
		if self.map:isDeadlyTile(math.ceil((self.leftFoot.x+3)/16),math.floor(self.leftFoot.y/16)) 
			or self.map:isDeadlyTile(math.ceil((self.rightFoot.x-3)/16)-1,math.floor(self.rightFoot.y/16))
			or self.map:isDeadlyTile(math.ceil((self.leftHand.x+3)/16),math.ceil((self.leftHand.y)/16)+1) 
			or self.map:isDeadlyTile(math.ceil((self.rightHand.x-3)/16)-1,math.ceil(self.rightHand.y/16)+1) then
			self.alive = false
		end
		
		if self.facingRight then
				self.adjacentTile.x = math.ceil((self.rightFoot.x-3)/16)
				self.adjacentTile.y = math.floor(self.rightFoot.y/16)
			else
				self.adjacentTile.x = math.ceil((self.leftFoot.x+3)/16)-1
				self.adjacentTile.y = math.floor(self.rightFoot.y/16)
		end
		
		
		if love.keyboard.isDown("x") then
			self.extiguishing = true
		else
			self.extiguishing = false
		end
				
		if self.extiguishing and self.map:isFireTile(self.adjacentTile.x,self.adjacentTile.y) then
			self.map.extinguishTile(self.adjacentTile.x,self.adjacentTile.y)
		end
		
		--TODO flashlight
		
		if(self.position.y > 720) then
			self.alive = false
		end
		
		self.scroll.x = math.min(0, -self.position.x + 300)
		self.scroll.x = math.max(self.scroll.x, -self.map:getWidth()+640)
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
