require "classes.TileMap"
require "classes.Sam"
local cache = require "lib.cache"
local state = require "state"
local bgm = require "bgm"
local Dialog = require "minigames.Dialog"
local Pausemenu = require "minigames.Pausemenu"

local game = {}

function game:load(level)
	self.timer = 0
	self.score = 0
	self.map = TileMap.fromFile(level)
	self.map.state = self
	samTex = cache.image("gfx/sam.png")
	lightTex = cache.image("gfx/flashlight.png")
	thrustParticle = cache.image("gfx/particle1.png")
	sprayParticle = cache.image("gfx/spray.png")
	local spawn = self.map.level:getSpawn()
	local pos = {x = (spawn.x-1)*16, y = (spawn.y-1)*16}
	sam = Sam(pos, samTex, self.map, lightTex, thrustParticel, sprayParticle)

	bgm.start()
	love.graphics.setBackgroundColor(100, 108, 111)

	self.font = cache.font("fonts/PrStart.ttf:16")
end

function game:unload()
	bgm.stop()
end

function game:update(dt)
	bgm.update()
	if sam.levelComplete then
		if not self.minigame then
			local dialogText = "Time:   %.2f\n" ..
				"Score: %d\n" ..
				"Total: %d\n"
			local scoreTotal = math.floor(math.max(300-self.timer, 0)/5)
			dialogText = dialogText:format(self.timer, self.score, scoreTotal)
			self.minigame = Dialog(dialogText)
		end
		self.minigame:update(dt)
		if self.minigame.open then
			return
		end

		local nextlevel = self.map.level:getNextLevel()
		if nextlevel then
			return state.switch(self, nextlevel():getLevelFile())
		else
			return state.switch(THE_END)
		end
	end

	self.map:update(dt)

	if self.map.minigame then
		self.minigame = self.map.minigame
		self.map.minigame = nil
	end

	if self.minigame then
		self.minigame:update(dt)
		if not self.minigame.open then
			if self.minigame.score then
				self.score = self.score + self.minigame.score
			end

			self.minigame.callback(self.minigame.won)
			self.minigame = nil
		end
		return
	end

	self.timer = self.timer + dt
	if sam.alive then
		sam:update(dt)
	else
		sam:spawn()
	end
end

function game:draw()
	love.graphics.push()
	love.graphics.scale(3, 3)
	self.map:draw(sam.scroll.x, sam.scroll.y)
	sam:draw()
	self:drawFuelGuage()

	love.graphics.pop()
	self:drawScoreAndTime()

	if self.minigame then
		self.minigame:draw()
	end
end

function game:keypressed(key, unicode)
	if self.minigame then
		return self.minigame:keypressed(key, unicode)
	end

	if key == " " then
		sam:jump()
	elseif key == "b" then
		sam:dash()
	elseif key == "i" then
		sam:interactWithTerminal()
	elseif key == "f" then
		sam:toggleLight()
	elseif key == "escape" then
		self.minigame = Pausemenu(self, sam)
	end
end

function game:drawFuelGuage()
	length = 32*(sam.fuel/100)
	if sam.fuel < 25 then
		love.graphics.setColor(191,55,59)
	elseif sam.fuel < 50 then
		love.graphics.setColor(233,235,58)
	else
		love.graphics.setColor(97,202,94)
	end
	love.graphics.rectangle("fill", 350, 6, length, 7 )
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line", 350, 6, 32, 7 )
	love.graphics.setColor(255,255,255)
end

function game:drawScoreAndTime()
	love.graphics.setFont(self.font)
	love.graphics.print(("Time:  %.2f"):format(self.timer), 20, 20)
	love.graphics.print(("Score: %d"):format(self.score), 20, 34)
end

return game
