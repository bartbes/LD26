local bgm = {}

bgm.playlist = {}
for i, v in ipairs(love.filesystem.enumerate("bgm")) do
	local basename = v:match("^(.+)%.ogg$")
	if basename then
		table.insert(bgm.playlist, basename)
	end
end

local function randombag(t)
	local bag
	local function fillbag()
		bag = {unpack(t)}
	end
	fillbag()

	local function get()
		if #bag == 0 then
			fillbag()
		end
		return table.remove(bag, math.random(1, #bag))
	end

	return get
end

function bgm.start()
	if not bgm.playing then
		bgm.restart()
	end
	bgm.playing = true
end

function bgm.restart()
	bgm.bag = randombag(bgm.playlist)
	bgm.nextsong()
end

function bgm.stop()
	bgm.playing = false
	if bgm.cursong then
		bgm.cursong:stop()
	end
end

function bgm.nextsong()
	local songname = bgm.bag()
	bgm.cursong = love.audio.newSource("bgm/" .. songname .. ".ogg")
	bgm.cursong:setVolume(0.7)
	bgm.cursong:play()
end

function bgm.update()
	if bgm.playing and bgm.cursong:isStopped() then
		bgm.nextsong()
	end
end

return bgm
