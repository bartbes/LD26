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
		return true
	end,

	isSolidFromBelow = function(self, tile, tilenum)
		if tile:match("[FGO]") then
			return false
		end
	end,

	isSolid = function(self, tile)
		return not tile:match("[EJKLMfelnrstz02378+-]")
	end,

	isDestructableTile = function(self, tile)
		return tile == "d"
	end,

	destroyTile = function(self, tile, x, y)
		return "-"
	end,

	activateTerminal = function(self, map, x, y)
		do
			return Dialog("The cake is a lie.")
		end
		local minigame = Hacking()
		function minigame.callback(success)
			if success then
				map:modifyTile(x, y, "9")
			end
		end
		return minigame
	end,
}

return lvl
