local state = require "state"
local intro = require "states.intro"

function love.load()
	love.graphics.setDefaultImageFilter("nearest", "nearest")
	state.hook()
	state.switch(intro)
end
