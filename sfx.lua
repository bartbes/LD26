local cache = require "lib.cache"

local sfx = {}

function sfx.play(name)
	local sd = cache.soundData("sfx/" .. name .. ".ogg")
	local sfx = love.audio.newSource(sd)
	sfx:play()
	return sfx
end

return sfx
