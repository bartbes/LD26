require "classes.Level"

local lvl
lvl = class.private "Level1" (Level) {
	__init__ = function(self)
		Level.__init__(self,
			{x = 5, y = 16},
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
}

return lvl
