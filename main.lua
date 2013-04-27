local state = require "state"
local intro = require "states.intro"

function love.load()
	state.hook()
	state.switch(intro)
end
