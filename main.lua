local state = require "state"
local menu = require "states.menu"
local game = require "states.game"

function love.load(args)
	love.graphics.setDefaultImageFilter("nearest", "nearest")
	state.hook()

	if args[2] == "menu" then
		state.switch(menu)
	else
		state.switch(game, "levels/lvl1.txt")
	end
end
