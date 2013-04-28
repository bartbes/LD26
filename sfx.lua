local cache = require "lib.cache"

local sfx = {}

function sfx.play(name, looping, volume)
	local sd = cache.soundData("sfx/" .. name .. ".ogg")
	local sfx = love.audio.newSource(sd)

	if looping then
		sfx:setLooping(true)
	end

	if volume then
		sfx:setVolume(volume)
	end

	sfx:play()
	return sfx
end

return sfx
