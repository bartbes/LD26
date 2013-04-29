require "lib.slither"
local cache = require "lib.cache"

local tilesize = 16
local sheetsize = 8 * (tilesize+2)

local function decodeTile(ch)
	ch = ch:byte()
	if ch >= 65 and ch <= 90 then
		return 0 + (ch - 65)
	end
	if ch >= 97 and ch <= 122 then
		return 26 + (ch - 97)
	end
	if ch >= 48 and ch <= 57 then
		return 52 + (ch - 48)
	end

	if ch == 43 then
		return 62
	end
	if ch == 45 then
		return 63
	end

	error("Invalid tile!")
end

local function encodeTile(tile)
	if tile < 26 then
		return string.char(65 + tile - 0)
	end
	if tile < 52 then
		return string.char(97 + tile - 26)
	end
	if tile < 62 then
		return string.char(48 + tile - 52)
	end
	if tile == 62 then
		return "+"
	end
	if tile == 63 then
		return "-"
	end

	error("Invalid tile!")
end

local function generateQuad(tile)
	local x = tile % 8
	local y = math.floor(tile / 8)

	return love.graphics.newQuad(x * (tilesize+2), y * (tilesize+2),
		tilesize, tilesize, sheetsize, sheetsize)
end

class "TileMap" {
	__init__ = function(self, classPath, image, description)
		self.level = love.filesystem.load(classPath)()()
		self.sheet = cache.image(image)

		local maxtiles = 0
		self.tiles = {}
		local tilecount = 0
		for y, line in ipairs(description) do
			self.tiles[y] = {}

			local x = 1
			for tile in line:gmatch(".") do
				self.tiles[y][x] = decodeTile(tile)
				x = x + 1
			end

			if #self.tiles[y] > maxtiles then maxtiles = #self.tiles[y] end

			tilecount = tilecount + #self.tiles[y]
		end

		self.tilecount = tilecount
		self.width = maxtiles * tilesize
		self.height = #self.tiles * tilesize

		self.fires = {}
		local fireLocations = self.level:getFirePositions()
		for i, v in ipairs(fireLocations) do
			self:createFire(v[1], v[2])
		end

		self.batteries = {}
		self.batteryImage = cache.image("gfx/battery.png")

		self:buildBatch()
	end,

	createFire = function(self, x, y)
		local fire = love.graphics.newParticleSystem(cache.image("gfx/particle1.png"), 250)
		fire:setEmissionRate(200)
		fire:setLifetime(-1)
		fire:setParticleLife(0.05, 0.15)
		fire:setDirection(-math.pi/2)
		fire:setSpeed(0, 80)
		fire:setSpin(1, 2)
		fire:setSpread(0.5)

		table.insert(self.fires, {system = fire, x = x, y = y})
	end,

	createBattery = function(self, x, y)
		table.insert(self.batteries, {x = x, y = y})
	end,

	buildBatch = function(self)
		self.batch = love.graphics.newSpriteBatch(self.sheet, self.tilecount, "static")

		local quadcache = {}

		self.batch:bind()
		for y, line in ipairs(self.tiles) do
			for x, tile in ipairs(line) do
				if not quadcache[tile] then
					quadcache[tile] = generateQuad(tile)
				end

				self.batch:addq(quadcache[tile], (x-1)*tilesize, (y-1)*tilesize)
			end
		end
		self.batch:unbind()
	end,

	update = function(self, dt)
		for i, v in ipairs(self.fires) do
			v.system:update(dt)
		end
	end,

	draw = function(self, x, y, ...)
		love.graphics.draw(self.batch, math.floor(x), math.floor(y), ...)
		for i, v in ipairs(self.fires) do
			love.graphics.draw(v.system, (v.x-0.5)*tilesize+x, v.y*tilesize+y)
		end
		for i, v in ipairs(self.batteries) do
			love.graphics.draw(self.batteryImage, (v.x-1)*tilesize+x, (v.y-1)*tilesize+y)
		end
	end,

	isSolid = function(self, x, y)
		if not self.tiles[y] then return false end
		if not self.tiles[y][x] then return false end
		local tile = self.tiles[y][x]
		return self.level:isSolid(encodeTile(tile), tile)
	end,

	isSolidFromBelow = function(self, x, y)
		if not self.tiles[y] then return false end
		if not self.tiles[y][x] then return false end
		local tile = self.tiles[y][x]
		local solid = self.level:isSolidFromBelow(encodeTile(tile), tile)
		if solid == nil then
			solid = self.level:isSolid(encodeTile(tile), tile)
		end

		return solid
	end,

	isOnTile = function(self, x, y)
		for i, v in ipairs(self.batteries) do
			if v.x == x and v.y == y then
				table.remove(self.batteries, i)
				self.state.score = self.state.score + 5
			end
		end
	end,

	isDeadlyTile = function(self, x, y)
		local tile = self.tiles[y][x]
		return self:isFireTile(x, y) or self.level:isDeadlyTile(encodeTile(tile))
	end,

	isWinningTile = function(self, x, y)
		local target = self.level:getTarget()
		if target.x == x and target.y == y then
			return true
		end

		local tile = self.tiles[y][x]
		return self.level:isWinningTile(encodeTile(tile))
	end,

	isFireTile = function(self, x, y)
		for i, v in ipairs(self.fires) do
			if v.x == x and v.y == y then
				return true
			end
		end
		return false
	end,

	extinguishTile = function(self, x, y)
		for i, v in ipairs(self.fires) do
			if v.x == x and v.y == y then
				table.remove(self.fires, i)
				return true
			end
		end
		return false
	end,

	isTerminalTile = function(self, x, y)
		local tile = self.tiles[y][x]
		return self.level:isTerminalTile(encodeTile(tile))
	end,

	activateTerminal = function(self, x, y)
		if not self:isTerminalTile(x, y) then return false end
		self.minigame = self.level:activateTerminal(self, x, y)
		return true
	end,

	isDestructableTile = function(self, x, y)
		local tile = self.tiles[y][x]
		return self.level:isDestructableTile(encodeTile(tile))
	end,

	destroyTile = function(self, x, y)
		if not self:isDestructableTile(x, y) then return false end
		local tile = self.tiles[y][x]
		local newtile = self.level:destroyTile(encodeTile(tile), x, y, self)
		self:modifyTile(x, y, newtile)
		return true
	end,

	modifyTile = function(self, x, y, target, dontRebuild)
		self.tiles[y][x] = decodeTile(target)
		if dontRebuild then return end
		self:buildBatch()
	end,

	getWidth = function(self)
		return self.width
	end,

	getHeight = function(self)
		return self.height
	end,

	fromFile = function(levelfile)
		local desc = {}
		for line in love.filesystem.lines(levelfile) do
			table.insert(desc, line)
		end

		local image = table.remove(desc, 1)
		local classpath = levelfile:gsub("%.[^%.]+$", ".lua")
		return TileMap(classpath, image, desc)
	end,
}
