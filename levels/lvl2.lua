require "classes.Level"
local Hacking = require "minigames.Hacking"
local Dialog = require "minigames.Dialog"

local lvl
lvl = class.private "Level2" (Level) {
	__init__ = function(self)
		Level.__init__(self,
			{x = 9, y = 5},
			{x = 121, y = 5},
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
			{45, 60},
			{60, 63},
		}
	end,
	
	getSparkPositions = function(self)
		return {
			{12, 22},
		}
	end,

	getBatteryPositions = function(self)
		return {
			{35, 60},
			{18, 60},
			{90, 67},
			{130, 56},
			{131, 39},
			{88, 46},
			{27, 30},
			{26, 30},
			{25, 30},
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
		return tile == "d"
	end,

	destroyTile = function(self, tile, x, y, map)
		if tile == "d" then
			map:createBattery(x, y)
			return "-"
		end
	end,

	activateTerminal = function(self, map, x, y)
		local minigame = Hacking()

		if y == 66 and x >= 75 and x <= 76 then
			function minigame.callback(success)
				if success then
					map:modifyTile(88, 62, "t")
					map.state.score = map.state.score + 10
					map.minigame = Dialog("Security hatch: UNLOCKED")
				end
			end
		elseif y == 23 and x >= 54 and x <= 55 then
			function minigame.callback(success)
				if success then
					map:modifyTile(58, 4, "t")
					map.state.score = map.state.score + 10
					map.minigame = Dialog("Security hatch: UNLOCKED")
				end
			end
		elseif y == 60 and x >= 21 and x <= 22 then
			function minigame.callback(success)
				if success then
					map:modifyTile(56, 7, "t")
					map.state.score = map.state.score + 10
					map.minigame = Dialog("Security hatch: UNLOCKED")
				end
			end
		elseif y == 31 and x >= 34 and x <= 35 then
			function minigame.callback(success)
				if success then
					map:modifyTile(52, 11, "t")
					map.state.score = map.state.score + 10
					map.minigame = Dialog("Security hatch: UNLOCKED")
				end
			end
		elseif y == 14 and x >= 84 and x <= 85 then
			function minigame.callback(success)
				if success then
					map:modifyTile(101, 9, "t")
					map:modifyTile(121, 5, "+")
					map:modifyTile(121, 4, "2")
					map:modifyTile(121, 3, "2")
					map:modifyTile(121, 2, "2")
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
