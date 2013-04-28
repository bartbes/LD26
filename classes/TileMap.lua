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

local function generateQuad(tile)
	local x = tile % 8
	local y = math.floor(tile / 8)

	return love.graphics.newQuad(x * (tilesize+2), y * (tilesize+2),
		tilesize, tilesize, sheetsize, sheetsize)
end

class "TileMap" {
	__init__ = function(self, classPath, image, description)
		self.level = love.filesystem.load(classPath)()
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

		self:buildBatch()
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

	draw = function(self, x, y, ...)
		return love.graphics.draw(self.batch, math.floor(x), math.floor(y), ...)
	end,

	isSolid = function(self, x, y)
		if not self.tiles[y] then return false end
		if not self.tiles[y][x] then return false end
		return self.tiles[y][x] < 52 -- 0 and on
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
