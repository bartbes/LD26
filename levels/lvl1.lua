require "classes.Level"
local Hacking = require "minigames.Hacking"
local Dialog = require "minigames.Dialog"

local lvl
lvl = class.private "Level1" (Level) {
	__init__ = function(self)
		Level.__init__(self,
			{x = 6, y = 34},
			{x = 4, y = 6},
			{})
	end,

	isDeadlyTile = function(self, tile)
		if tile == "5" then
			return true
		end
		return false
	end,

	getNextLevel = function(self)
		return lvl
	end,

	getLevelFile = function(self)
		return "levels/lvl1.txt"
	end,

	getFirePositions = function(self)
		return {{26, 19}}
	end,

	isTerminalTile = function(self, tile)
		return tile == "z" or tile == "0"
	end,

	isSolidFromBelow = function(self, tile, tilenum)
		if tile:match("[FGO]") then
			return false
		end
	end,

	isSolid = function(self, tile)
		return not tile:match("[EJKLMfenrstz02378+-]")
	end,

	isDestructableTile = function(self, tile)
		return tile == "d" or tile == "u"
	end,

	destroyTile = function(self, tile, x, y, map)
		if tile == "u" then
			self:destroyVent(map, x, y)
			return "E"
		end
		if tile == "d" then
			map:createBattery(x, y)
			return "-"
		end
	end,

	destroyVent = function(self, map, x, y)
		if map.tiles[y][x] ~= 46 then return end
		map:modifyTile(x, y, "E", true)
		self:destroyVent(map, x-1, y)
		self:destroyVent(map, x+1, y)
		self:destroyVent(map, x, y-1)
		self:destroyVent(map, x, y+1)
	end,

	activateTerminal = function(self, map, x, y)
		local minigame = Hacking()

		if y == 29 and x >= 76 and x <= 77 then
			function minigame.callback(success)
				if success then
					map:modifyTile(58, 38, "t")
					map.state.score = map.state.score + 10
					map.minigame = Dialog("Security hatch: UNLOCKED")
				end
			end
		end
		return minigame
	end,
}

return lvl
