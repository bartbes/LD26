local state = {}

function state.switch(target, ...)
	if state.curstate and state.curstate.unload then
		state.curstate:unload()
	end
	assert(target, "No state to switch to")
	state.curstate = target
	state.curstate:load(...)
end

function state.hook()
	for i, v in ipairs{
			"update", "draw", "keypressed",
			"keyreleased", "mousepressed",
			"mousereleased", "focus", "quit"} do
		love[v] = state[v]
	end
end

function state.update(dt)
	if state.curstate.update then
		local cdt
		while dt > 0 do
			cdt = math.min(dt, 0.033)
			state.curstate:update(cdt)
			dt = dt - cdt
		end
	end
end

function state.draw()
	if state.curstate.draw then
		return state.curstate:draw()
	end
end

function state.keypressed(key, unicode)
	if state.curstate.keypressed then
		return state.curstate:keypressed(key, unicode)
	end
end

function state.keyreleased(key)
	if state.curstate.keyreleased then
		return state.curstate:keyreleased(key)
	end
end

function state.mousepressed(x, y, button)
	if state.curstate.mousepressed then
		return state.curstate:mousepressed(x, y, button)
	end
end

function state.mousereleased(x, y, button)
	if state.curstate.mousereleased then
		return state.curstate:mousereleased(x, y, button)
	end
end

function state.focus(f)
	if state.curstate.focus then
		return state.curstate:focus(f)
	end
end

function state.quit()
	if state.curstate.quit then
		return state.curstate:quit()
	end
end

return state
