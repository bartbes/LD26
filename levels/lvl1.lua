require "classes.Level"

local lvl = class.private "Level1" (Level) {
	__init__ = function(self)
		Level.__init__(self,
			{x = 300, y = 200},
			{x = 299, y = 201},
			{})
	end,

	getNextLevel = function(self)
		return nil
	end,
}

return lvl(...)
