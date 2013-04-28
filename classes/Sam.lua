require "lib/slither"
require "classes.TileMap"
local sfx = require "sfx"

class "Sam"
{	
	__init__ = function(self, position, tex, map, lightTex)
		self.spawnPos = position
		self.tex = tex
		self.lightTex = lightTex
		self.texWidth = tex:getWidth()
		self.texHeight = tex:getHeight()
		self.lightWidth = lightTex:getWidth()
		self.sfx = {}

		self.abilities = {
			rocketJump = true,
			boost = true,
			flashlight = true,
			extinguisher = true,
			laser = true
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
		self.extinguishing = false
		self.adjacentTile = {x=0,y=0}
		self.flashlight = false
		self.firingLaser = false
		self.laserCordinates = {x=0,y=0,w=0,h=0}
	end,
	
	draw = function(self)
		if self.facingRight then
			love.graphics.draw(self.tex, self.screenPosition.x, self.screenPosition.y)
		else
			love.graphics.draw(self.tex, self.screenPosition.x, self.screenPosition.y,0,-1,1,self.texWidth,0)
		end
		
		if self.firingLaser then
			love.graphics.setColor(191,55,59)
			love.graphics.rectangle("fill", self.laserCordinates.x, self.laserCordinates.y, self.laserCordinates.w, self.laserCordinates.h )
			love.graphics.setColor(255,255,255)
		end

		if self.flashlight then
			local x = self.screenPosition.x - 30
			local sx = 1
			if self.facingRight then
				x = self.screenPosition.x + 46
				sx = -1
			end

			love.graphics.setBlendMode("additive")
			love.graphics.draw(self.lightTex, x, self.screenPosition.y, 0, sx, 1)
			love.graphics.setBlendMode("alpha")
		end
	end,
	
	
	jump = function(self)
		if self.onGround then
			self.velocity.y = - 100
			self.jumping = true
			sfx.play("jumpValve", false, 0.60)
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
			sfx.play("blip")
		 end
	end,
	
	toggleLight = function(self)
		if self.abilities.flashlight then
			self.flashlight = not self.flashlight
		end
	end,
	
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
				self.sfx.jetpackTimer = 0.5
			end
			self.fuel = self.fuel - (80 * dt)
			self.acceleration.y =self.acceleration.y - 200
		elseif self.sfx.jetpack and self.sfx.jetpackTimer > 0 then
			self.sfx.jetpack:setVolume(self.sfx.jetpackTimer*2)
			self.sfx.jetpackTimer = self.sfx.jetpackTimer - dt
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
			self.sfx.motor = sfx.play("motor", true)
		end
		if not moving and self.sfx.motor then
			self.sfx.motor:stop()
			self.sfx.motor = nil
		end
		
		

		
		self:updateSensors()
		
		--ceiling
		if self.map:isSolid(math.ceil((self.leftHand.x+3)/16),math.ceil((self.leftHand.y)/16)) 
			or self.map:isSolid(math.ceil((self.rightHand.x-3)/16),math.ceil(self.rightHand.y/16)) then
			self.position.y = (math.ceil((self.position.y +7 )/16) * 16 ) -7
			self.velocity.y = 0
			self:updateSensors()
		end
		
		--floor
		if self.map:isSolid(math.ceil((self.leftFoot.x+3)/16),math.floor(self.leftFoot.y/16)+1) 
			or	self.map:isSolid(math.ceil((self.rightFoot.x-3)/16),math.floor(self.rightFoot.y/16)+1)	then
			self.position.y = math.floor(self.position.y/16) * 16 

			if not self.onGround then
				sfx.play("land2", false, 0.75)
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
		if self.map:isSolid(math.ceil((self.rightFoot.x)/16),math.ceil((self.rightFoot.y-3)/16))
			or self.map:isSolid(math.ceil((self.rightHand.x)/16),math.ceil((self.rightHand.y+3)/16))	then
			self.position.x = (math.floor((self.position.x )/16) * 16) 
			self.velocity.x = 0
			self:updateSensors()
		end
		
		
		
		--inWinningTile
		if self.map:isWinningTile(math.ceil((self.leftFoot.x+3)/16),math.floor(self.leftFoot.y/16)) 
			or	self.map:isWinningTile(math.ceil((self.rightFoot.x-3)/16),math.floor(self.rightFoot.y/16))	then
			self.levelComplete = true
			self:updateSensors()
		end
		
		--inDeadlyTile
		if self.map:isDeadlyTile(math.ceil((self.leftFoot.x+3)/16),math.floor(self.leftFoot.y/16)) 
			or self.map:isDeadlyTile(math.ceil((self.rightFoot.x-3)/16),math.floor(self.rightFoot.y/16))
			or self.map:isDeadlyTile(math.ceil((self.leftHand.x+3)/16),math.ceil((self.leftHand.y)/16)+1) 
			or self.map:isDeadlyTile(math.ceil((self.rightHand.x-3)/16),math.ceil(self.rightHand.y/16)+1) then
			self.alive = false
		end
		
		-- adjacent Tile
		if self.facingRight then
				self.adjacentTile.x = math.ceil((self.rightFoot.x-3)/16)+1
				self.adjacentTile.y = math.floor(self.rightFoot.y/16)
			else
				self.adjacentTile.x = math.ceil((self.leftFoot.x+3)/16)-1
				self.adjacentTile.y = math.floor(self.rightFoot.y/16)
		end
		
		-- extinguisher
		if self.abilities.extinguisher then
			if love.keyboard.isDown("x") then
				if not self.extinguishing then
					self.sfx.extinguish = sfx.play("extinguish", true)
					self.sfx.extinguishFade = 0
				end
				self.extinguishing = true
			else
				if self.extinguishing then
					self.sfx.extinguish:stop()
					self.sfx.extinguish = nil
				end
				self.extinguishing = false
			end
		end
		

		if self.sfx.extinguish and self.sfx.extinguishFade < 1 then
			self.sfx.extinguishFade = math.min(1, self.sfx.extinguishFade + 6*dt)
			self.sfx.extinguish:setVolume(self.sfx.extinguishFade)
		end
				
		if self.extinguishing and self.map:isFireTile(self.adjacentTile.x,self.adjacentTile.y) then
			self.map.extinguishTile(self.adjacentTile.x,self.adjacentTile.y)
		end
		
		--TODO flashlight
		
	
		--scroll
		self.scroll.x = math.min(0, -self.position.x + 50)
		self.scroll.x = math.max(self.scroll.x, -self.map:getWidth()+426)

		self.scroll.y = math.min(0, -self.position.y + 120)
		self.scroll.y = math.max(self.scroll.y, -self.map:getHeight()+240)

		self.screenPosition.x = self.position.x + self.scroll.x
		self.screenPosition.y = self.position.y + self.scroll.y	
		
				-- Laser
		if love.keyboard.isDown("l") and self.abilities.laser then
			self.firingLaser = true
		else
			self.firingLaser = false
		end
		
		if self.firingLaser then
			if self.facingRight then
				self.laserCordinates.x = self.rightHand.x + self.scroll.x
				self.laserCordinates.y = self.rightHand.y + self.scroll.y
				self.laserCordinates.h = 2	
				
				local i = 0
				while  not self.map:isSolid(math.ceil((self.rightHand.x)/16)+i,math.ceil((self.rightHand.y+3)/16)) do 
					i = i+1
					if self.map:isDestructableTile(math.ceil((self.rightHand.x)/16)+i,math.ceil((self.rightHand.y+3)/16)) then
						self.map:destroyTile(math.ceil((self.rightHand.x)/16)+i,math.ceil((self.rightHand.y+3)/16)) 
					end
				end
				self.laserCordinates.w =  (math.ceil((self.rightHand.x)/16)+i-1)*16 - self.rightHand.x
			else
 				self.laserCordinates.x = self.leftHand.x + self.scroll.x 
				self.laserCordinates.y = self.leftHand.y + self.scroll.y	
				self.laserCordinates.h = 2

				local i = 0
				while  not self.map:isSolid(math.ceil((self.leftHand.x)/16)+i,math.ceil((self.leftHand.y+3)/16)) do 
					i = i-1	
					if self.map:isDestructableTile(math.ceil((self.leftHand.x)/16)+i,math.ceil((self.leftHand.y+3)/16)) then
						self.map:destroyTile(math.ceil((self.leftHand.x)/16)+i,math.ceil((self.leftHand.y+3)/16)) 
					end					
				end
				self.laserCordinates.w =  (math.ceil((self.leftHand.x)/16)+i)*16 - self.leftHand.x
			end		
		end
		
		
	end,
	
	updateSensors = function(self)
		self.leftFoot.x = self.position.x 
		self.leftFoot.y = self.position.y + self.texHeight 
		self.rightFoot.x = self.position.x + self.texWidth 
		self.rightFoot.y = self.position.y + self.texHeight 
		self.rightHand.x = self.position.x + self.texWidth 
		self.rightHand.y = self.position.y +7  --wtf
		self.leftHand.x = self.position.x 
		self.leftHand.y = self.position.y +7 
	end

}
