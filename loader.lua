-- Paste this into your executor. It downloads VEXORA and runs it.
local urls = {
	"https://raw.githubusercontent.com/Criminaltheclown/vexora/main/VEXORA_5.0.lua",
	"https://cdn.jsdelivr.net/gh/Criminaltheclown/vexora@main/VEXORA_5.0.lua",
}

local function fetch(target)
	if typeof(game.HttpGet) == "function" then
		return game:HttpGet(target)
	end
	if type(httpget) == "function" then
		return httpget(target)
	end
	local requester = (type(syn) == "table" and syn.request) or http_request or (type(http) == "table" and http.request) or request
	if type(requester) == "function" then
		local response = requester({ Url = target, Method = "GET" })
		return response and (response.Body or response.body)
	end
	error("This executor cannot download files")
end

local source, reason
for _, url in ipairs(urls) do
	local ok, result = pcall(fetch, url)
	if ok and type(result) == "string" and string.find(result, "VEXORA 5.0", 1, true) then
		source = result
		break
	end
	reason = ok and "the download was not VEXORA" or result
end

if not source then
	warn("[VEXORA] Could not download the script. " .. tostring(reason))
	return
end

local run, err = loadstring(source)
if not run then
	warn("[VEXORA] Could not load the script. " .. tostring(err))
	return
end

run()
