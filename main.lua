local state = require "state"
local game = require "states.game"

function love.load()
	love.graphics.setDefaultImageFilter("nearest", "nearest")
	state.hook()
	state.switch(game)
end
