require "lib.slither"

class "Level" {
	__init__ = function(self, spawn, target, abilities)
		self.spawn = assert(spawn, "No spawn point given")
		self.target = assert(target, "No target given")
		self.abilities = assert(abilities, "No abilities given")
	end,

	getTarget = function(self)
		return self.target
	end,

	getSpawn = function(self)
		return self.spawn
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
}
