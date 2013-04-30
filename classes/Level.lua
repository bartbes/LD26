require "lib.slither"

class "Level" {
	__init__ = function(self, spawn, target, abilities)
		self.spawn = assert(spawn, "No spawn point given")
		self.target = assert(target, "No target given")
		self.abilities = assert(abilities, "No abilities given")
	end,

	levelStarted = function(self, map)
	end,

	canWin = function(self)
		return false
	end,

	getTarget = function(self)
		return self.target
	end,

	getSpawn = function(self)
		return self.spawn
	end,

	getFirePositions = function(self)
		return {}
	end,
	
	getSparkPositions = function(self)
		return {}
	end,

	getBatteryPositions = function(self)
		return {}
	end,

	isSolid = function(self, tile, tilenum)
		return tilenum < 52
	end,

	isSolidFromBelow = function(self, tile, tilenum)
		-- returning nothing/nil means same as isSolid
	end,

	isDeadlyTile = function(self, tile)
		return false
	end,

	isWinningTile = function(self, tile)
		return false
	end,

	isFireTile = function(self, tile)
		return false
	end,

	isTerminalTile = function(self, tile)
		return false
	end,

	isDestructableTile = function(self, tile)
		return false
	end,

	extinguishTile = function(self, tile)
		return "0"
	end,

	activateTerminal = function(self, x, y)
	end,

	destroyTile = function(self, tile, x, y)
		return "0"
	end,

	transferAbilities = function(self, sam)
		for i, v in pairs(sam.abilities) do
			if self.abilities[i] ~= nil then
				sam.abilities[i] = self.abilities[i]
			end
		end
	end,

	-- Implemented in child
	getNextLevel = function(self)
		error("Not implemented")
	end,

	getLevelFile = function(self)
		error("Not implemented")
	end,
}
