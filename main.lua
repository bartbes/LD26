local state = require "state"
local menu = require "states.menu"
local game = require "states.game"

function love.load(args)
	love.graphics.setDefaultImageFilter("nearest", "nearest")
	state.hook()

	state.switch(menu)
end
