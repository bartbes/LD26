require "classes.Level"
local Hacking = require "minigames.Hacking"
local Dialog = require "minigames.Dialog"

local lvl
lvl = class.private "Level2" (Level) {
	__init__ = function(self)
		Level.__init__(self,
			{x = 9, y = 5},
			{x = 127, y = 33},
			{laser = false})

		self.teleporterActive = false
	end,

	levelStarted = function(self, map)
		local dlg1 = Dialog("CHANGE IN MOLECULAR STRUCTURE DETECTED!")
		local dlg2 = Dialog("Laser status: OFFLINE")
		dlg1.callback = function()
			map.minigame = dlg2
		end

		map.minigame = dlg1
	end,

	canWin = function(self)
		return self.teleporterActive
	end,

	isDeadlyTile = function(self, tile)
		return tile:match("[178]")
	end,

	getNextLevel = function(self)
		return nil
	end,

	getLevelFile = function(self)
		return "levels/lvl2.txt"
	end,

	getFirePositions = function(self)
		return {
			{65, 57},
			{26, 37},
			{70, 37},
			{118, 48},
			{94, 57},
		}
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
		return not tile:match("[EJKLMfenrstz012378+-]")
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
		elseif y == 48 and x >= 103 and x <= 104 then
			function minigame.callback(success)
				if success then
					map:modifyTile(98, 49, "t")
					map:modifyTile(127, 33, "+")
					map:modifyTile(127, 32, "2")
					map:modifyTile(127, 31, "2")
					map.state.score = map.state.score + 10
					self.teleporterActive = true
					map.minigame = Dialog("Security hatch: UNLOCKED\nTeleporter: ACTIVATED")
				end
			end
		end
		return minigame
	end,
}

return lvl
