require "classes.Minigame"
local cache = require "lib.cache"

local keys = {"0", "1"}
local passwordList = {
	"NARPAS SWORD",
	"JUSTIN BAILEY",
	"IDDQD",
	"IDKFA",
	"BIG DADDY",
	"XYZZY",
	"COMEFLYWITHME",
	"BETTERTHANWALKING",
}

local Hacking
Hacking = class.private "Hacking" (Minigame) {
	__init__ = function(self)
		Minigame.__init__(self)

		self.password = {}
		for i = 1, 8 do
			local i = math.random(#keys)
			table.insert(self.password, keys[i])
		end

		self.address = math.random(0x10000000, 0x7FFFFFFF)
		self.address = ("0x%08x"):format(self.address)
		self.fakePassword = passwordList[math.random(#passwordList)]

		self.pos = 1
		self.timer = 0

		self.font = cache.font("fonts/PrStart.ttf:16")
		self.overlay = cache.image("gfx/hackOverlay.png")
		self.scanlines = cache.image("gfx/scanLines.png")
	end,

	update = function(self, dt)
		Minigame.update(self, dt)

		self.timer = self.timer + dt
		if self.timer > 3 and self.pos ~= #self.password then
			self:close(false)
		elseif self.timer > 6 then
			self:close(true)
		end
	end,

	keypressed = function(self, key, unicode)
		Minigame.keypressed(self, key, unicode)

		key = key:match("^kp(%d)$") or key:match("%d")
		if not key or self.pos == #self.password or self.failed then return end
		if key == self.password[self.pos] then
			self.pos = self.pos + 1
			self.timer = 0
		else 
			self.failed = true
		end
	end,

	draw = function(self)
		love.graphics.setFont(self.font)
		love.graphics.setColor(37, 41, 49)
		love.graphics.rectangle('fill', 240, 60, 800, 600)
		love.graphics.setColor(106, 217, 245)

		love.graphics.print("TMNL v4.6", 260, 80)
		love.graphics.print("root$ run sam.io", 260, 100)

		love.graphics.print(">" .. self.address:sub(1, self.pos+1), 260, 140)
		if self.pos < #self.password and not self.failed then
			love.graphics.printf("Press", 240, 310, 800, "center")
			love.graphics.printf(self.password[self.pos], 240, 330, 800, "center")
		elseif not self.failed then
			repeat
				love.graphics.print(">ACCESSING...", 260, 160)
				if self.timer < 0.3 then break end
				love.graphics.print(">.", 260, 180)
				if self.timer < 0.6 then break end
				love.graphics.print(">.", 260, 200)
				if self.timer < 0.9 then break end
				love.graphics.print(">FOUND '" .. self.fakePassword .. "'", 260, 220)
				if self.timer < 1.1 then break end
				love.graphics.print(">.", 260, 240)
				if self.timer < 1.2 then break end
				love.graphics.print(">MATCH!", 260, 260)
				if self.timer < 1.5 then break end
				love.graphics.print(">[ACCESS GRANTED]", 260, 280)
				if self.timer < 2.2 then break end

				love.graphics.print("root$ logout", 260, 320)
				if self.timer < 2.5 then break end
				love.graphics.print("[process Completed]", 260, 340)
			until true
		else
			love.graphics.print(">INTRUSION DETECTED, SHUTTING DOWN", 260, 160)
		end

		love.graphics.setScissor(240, 60, 800, 600)
		love.graphics.setBlendMode("multiplicative")
		love.graphics.setColor(255, 255, 255, 120)
		love.graphics.draw(self.scanlines, 240, 60)
		love.graphics.setScissor()

		love.graphics.setBlendMode("alpha")
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.overlay, 240, 60)
	end,
}

return Hacking
