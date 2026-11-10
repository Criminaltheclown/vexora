-- Paste this into your executor. It downloads VEXORA and runs it.
local urls = {
	"https://raw.githubusercontent.com/Criminaltheclown/vexora/main/VEXORA_5.0.lua?v=2",
	"https://cdn.jsdelivr.net/gh/Criminaltheclown/vexora@main/VEXORA_5.0.lua?v=2",
}

local function bodyOf(result)
	if type(result) == "string" then
		return result
	end
	if type(result) == "table" then
		return result.Body or result.body or result.Data or result.data
	end
end

local function fetch(target)
	local tries = {}
	if type(httpget) == "function" then
		table.insert(tries, function()
			return httpget(target)
		end)
	end
	if type(HttpGet) == "function" then
		table.insert(tries, function()
			return HttpGet(target)
		end)
	end
	if typeof(game.HttpGet) == "function" then
		table.insert(tries, function()
			return game:HttpGet(target)
		end)
	end
	local requester = (type(syn) == "table" and syn.request) or http_request or (type(http) == "table" and http.request) or request
	if type(requester) == "function" then
		table.insert(tries, function()
			return requester({ Url = target, Method = "GET" })
		end)
	end
	table.insert(tries, function()
		return game:GetService("HttpService"):GetAsync(target)
	end)

	local reason = "no download function"
	for _, call in ipairs(tries) do
		local ok, result = pcall(call)
		local body = ok and bodyOf(result) or nil
		if type(body) == "string" and string.find(body, "VEXORA 5.0", 1, true) then
			return body
		end
		reason = ok and "the download was not VEXORA" or result
	end
	error(tostring(reason))
end

local source, reason
for _, url in ipairs(urls) do
	local ok, result = pcall(fetch, url)
	if ok and type(result) == "string" then
		source = result
		break
	end
	reason = result
end

if not source then
	warn("[VEXORA] Could not download the script. " .. tostring(reason))
	return
end

local compile = loadstring or load
if type(compile) ~= "function" then
	warn("[VEXORA] This executor cannot run downloaded scripts.")
	return
end

local run, err = compile(source)
if not run then
	warn("[VEXORA] Could not load the script. " .. tostring(err))
	return
end

run()
