-- StarterPlayer.StarterPlayerScripts.VEXORA
-- VEXORA 5.0
-- Standalone local interface. No HTTP, no loadstring, no remote scripts.
-- Paste into a client executor, or save as a LocalScript under StarterPlayerScripts.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local ContentProvider = game:GetService("ContentProvider")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
if not player then
	warn("[VEXORA] LocalPlayer is missing. Run this on the client.")
	return
end

local playerGui = player:WaitForChild("PlayerGui")
local existing = playerGui:FindFirstChild("VEXORA_5")
if existing then
	existing:Destroy()
end

local WIN_W = 780
local WIN_H = 524
local SIDE = 70
local HEADER = 56
local DOCK_CLOSED = 58
local DOCK_OPEN = 286

local C = {
	bg = Color3.fromRGB(7, 8, 10),
	panel = Color3.fromRGB(13, 14, 17),
	card = Color3.fromRGB(20, 21, 25),
	hover = Color3.fromRGB(30, 31, 36),
	border = Color3.fromRGB(53, 56, 63),
	white = Color3.fromRGB(248, 249, 251),
	muted = Color3.fromRGB(145, 149, 159),
	cyan = Color3.fromRGB(88, 210, 235),
	violet = Color3.fromRGB(166, 126, 255),
	green = Color3.fromRGB(84, 210, 157),
	red = Color3.fromRGB(238, 95, 110),
}

local ACCENTS = {
	Cyan = C.cyan,
	Violet = C.violet,
	Green = C.green,
	White = C.white,
}

local COLOR_CHOICES = { "White", "Cyan", "Violet", "Green", "Red" }
local COLOR_VALUES = {
	White = C.white,
	Cyan = C.cyan,
	Violet = C.violet,
	Green = C.green,
	Red = C.red,
}

local GAMES = {
	{
		id = "urban",
		name = "Urban Reload",
		blurb = "Local profile for this shooter. Nothing here changes the server.",
		placeId = 84448037861644,
		universeId = 10769552054,
		link = "https://www.roblox.com/games/84448037861644/Urban-Reload",
	},
	{
		id = "universal",
		name = "Universal",
		blurb = "Camera, interface, and client tools in any experience.",
	},
}

local NAV = {
	{ id = "Home", icon = "home", tip = "Home" },
	{ id = "Games", icon = "gamepad", tip = "Games" },
	{ id = "Universal", icon = "sliders", tip = "Universal" },
	{ id = "Urban", icon = "monitor", tip = "Urban Reload" },
	{ id = "Settings", icon = "settings", tip = "Settings" },
}

local function defaultProfile()
	return {
		fov = nil,
		smoothFov = true,
		uiScale = 1,
		opacity = 1,
		accent = "Cyan",
		grid = true,
		pulses = true,
		anim = 1,
		reducedMotion = false,
		notifications = true,
		crosshair = {
			enabled = false,
			style = "Cross",
			size = 8,
			thickness = 2,
			gap = 4,
			opacity = 1,
			color = "White",
		},
		hud = { visible = false, x = 16, y = 16 },
		lowGraphics = false,
	}
end

local function defaultGlobal()
	local profiles = { Default = defaultProfile() }
	return {
		sidebar = true,
		dock = true,
		binds = { toggle = "RightShift", palette = "K" },
		favorites = {},
		recents = {},
		presets = {},
		perGame = {},
		profiles = profiles,
		activeProfile = "Default",
	}
end

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for key, item in pairs(value) do
		out[key] = deepCopy(item)
	end
	return out
end

local function validKey(name)
	if type(name) ~= "string" then
		return false
	end
	local ok, value = pcall(function()
		return Enum.KeyCode[name]
	end)
	return ok and value ~= nil and value ~= Enum.KeyCode.Unknown
end

local function sanitizeProfile(source)
	local profile = defaultProfile()
	if type(source) ~= "table" then
		return profile
	end
	if type(source.fov) == "number" then
		profile.fov = math.clamp(source.fov, 50, 110)
	end
	if type(source.smoothFov) == "boolean" then
		profile.smoothFov = source.smoothFov
	end
	if type(source.uiScale) == "number" then
		profile.uiScale = math.clamp(source.uiScale, 0.85, 1.15)
	end
	if type(source.opacity) == "number" then
		profile.opacity = math.clamp(source.opacity, 0.7, 1)
	end
	if ACCENTS[source.accent] then
		profile.accent = source.accent
	end
	if type(source.grid) == "boolean" then
		profile.grid = source.grid
	end
	if type(source.pulses) == "boolean" then
		profile.pulses = source.pulses
	end
	if type(source.anim) == "number" then
		profile.anim = math.clamp(source.anim, 0.6, 1.4)
	end
	if type(source.reducedMotion) == "boolean" then
		profile.reducedMotion = source.reducedMotion
	end
	if type(source.notifications) == "boolean" then
		profile.notifications = source.notifications
	end
	if type(source.lowGraphics) == "boolean" then
		profile.lowGraphics = source.lowGraphics
	end
	if type(source.crosshair) == "table" then
		local crosshair = source.crosshair
		if type(crosshair.enabled) == "boolean" then
			profile.crosshair.enabled = crosshair.enabled
		end
		if crosshair.style == "Dot" or crosshair.style == "Cross" or crosshair.style == "Circle" or crosshair.style == "Minimal" then
			profile.crosshair.style = crosshair.style
		end
		if type(crosshair.size) == "number" then
			profile.crosshair.size = math.clamp(crosshair.size, 2, 18)
		end
		if type(crosshair.thickness) == "number" then
			profile.crosshair.thickness = math.clamp(crosshair.thickness, 1, 6)
		end
		if type(crosshair.gap) == "number" then
			profile.crosshair.gap = math.clamp(crosshair.gap, 0, 16)
		end
		if type(crosshair.opacity) == "number" then
			profile.crosshair.opacity = math.clamp(crosshair.opacity, 0.25, 1)
		end
		if COLOR_VALUES[crosshair.color] then
			profile.crosshair.color = crosshair.color
		end
	end
	if type(source.hud) == "table" then
		if type(source.hud.visible) == "boolean" then
			profile.hud.visible = source.hud.visible
		end
		if type(source.hud.x) == "number" then
			profile.hud.x = source.hud.x
		end
		if type(source.hud.y) == "number" then
			profile.hud.y = source.hud.y
		end
	end
	return profile
end

local function sanitizeGlobal(source)
	local global = defaultGlobal()
	if type(source) ~= "table" then
		return global
	end
	if type(source.sidebar) == "boolean" then
		global.sidebar = source.sidebar
	end
	if type(source.dock) == "boolean" then
		global.dock = source.dock
	end
	if global.sidebar == false and global.dock == false then
		global.dock = true
	end
	if type(source.binds) == "table" then
		if validKey(source.binds.toggle) then
			global.binds.toggle = source.binds.toggle
		end
		if validKey(source.binds.palette) then
			global.binds.palette = source.binds.palette
		end
	end
	if type(source.favorites) == "table" then
		for id, on in pairs(source.favorites) do
			if type(id) == "string" and on == true then
				global.favorites[id] = true
			end
		end
	end
	if type(source.recents) == "table" then
		for _, id in ipairs(source.recents) do
			if type(id) == "string" and #global.recents < 8 then
				table.insert(global.recents, id)
			end
		end
	end
	if type(source.presets) == "table" then
		local count = 0
		for name, preset in pairs(source.presets) do
			if type(name) == "string" and #name <= 24 and count < 16 then
				local clean = sanitizeProfile({ crosshair = preset }).crosshair
				global.presets[name] = clean
				count += 1
			end
		end
	end
	if type(source.perGame) == "table" then
		for placeId, choice in pairs(source.perGame) do
			if type(placeId) == "string" and type(choice) == "string" then
				global.perGame[placeId] = choice
			end
		end
	end
	if type(source.profiles) == "table" then
		local profiles = {}
		local count = 0
		for name, profile in pairs(source.profiles) do
			if type(name) == "string" and #name > 0 and #name <= 24 and count < 12 then
				profiles[name] = sanitizeProfile(profile)
				count += 1
			end
		end
		if next(profiles) then
			global.profiles = profiles
		end
	end
	if type(source.activeProfile) == "string" and global.profiles[source.activeProfile] then
		global.activeProfile = source.activeProfile
	end
	if not global.profiles[global.activeProfile] then
		global.activeProfile = "Default"
		if not global.profiles.Default then
			global.profiles.Default = defaultProfile()
		end
	end
	return global
end

local G = defaultGlobal()
local P = G.profiles.Default
local storageMode = "session"
local storageNote = "Settings last for this run. Export a copy if you want to keep them."
local saveWarned = false
local saveQueued = false

local selectedId = nil
local experienceName = "Place " .. tostring(game.PlaceId)
local infoReady = false
local originalFOV = 70
local previousQuality = nil
local bootDone = false
local alive = true
local windowOpen = false
local dockExpanded = false
local paletteOpen = false
local modalOpen = false
local capturing = nil
local suppressEscape = false
local currentPage = nil
local currentTab = "Camera"
local navToken = 0
local tipToken = 0
local paletteIndex = 1
local fpsValue = nil
local fpsAccum = 0
local fpsFrames = 0
local fpsHistory = table.create(28, 0)
local fpsCursor = 0
local sessionStart = os.clock()
local lastInput = UserInputService:GetLastInputType()
local history = {}
local recentQueries = {}
local features = {}
local featureOrder = {}
local navButtons = {}
local accentNodes = {}
local watchers = {}
local conns = {}
local pageConns = {}
local chartBars = nil
local onPlayersChanged = nil
local dropdownCallback = nil
local dropdownOptions = {}
local paletteRows = {}
local hudDrag = false
local windowDrag = false
local dragStart = nil
local dragOrigin = nil

if workspace.CurrentCamera then
	originalFOV = workspace.CurrentCamera.FieldOfView
end

local graphicsAvailable = false
pcall(function()
	local level = UserSettings():GetService("UserGameSettings").SavedQualityLevel
	graphicsAvailable = level ~= nil
end)

local pingAvailable = true

do
	local loadedNote = nil
	if typeof(readfile) == "function" then
		local ok, raw = pcall(readfile, "VEXORA_5_settings.json")
		if ok and type(raw) == "string" and raw ~= "" then
			local decodedOk, data = pcall(function()
				return HttpService:JSONDecode(raw)
			end)
			if decodedOk and type(data) == "table" and data.version == 5 and type(data.global) == "table" then
				G = sanitizeGlobal(data.global)
				P = G.profiles[G.activeProfile]
				storageMode = "file"
				storageNote = "Loaded VEXORA_5_settings.json from this device."
			else
				loadedNote = "A settings file was found and ignored because it is not VEXORA 5."
			end
		end
	end
	G._loadNote = loadedNote
end

local rememberedProfile = G.perGame[tostring(game.PlaceId)]
if rememberedProfile == "urban" or rememberedProfile == "universal" then
	selectedId = rememberedProfile
end

local function track(conn)
	table.insert(conns, conn)
	return conn
end

local function trackPage(conn)
	table.insert(pageConns, conn)
	return conn
end

local function clearPageConns()
	for _, conn in ipairs(pageConns) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(pageConns)
end

local function duration(base)
	if P and P.reducedMotion then
		return 0
	end
	local scale = (P and P.anim) or 1
	return base * math.clamp(scale, 0.6, 1.4)
end

local function tween(obj, seconds, props)
	local function finished()
		local event = Instance.new("BindableEvent")
		task.defer(function()
			event:Fire()
		end)
		return { Completed = event.Event, Play = function() end }
	end
	if not obj or duration(seconds) <= 0 then
		if obj and props then
			for key, value in pairs(props) do
				pcall(function()
					obj[key] = value
				end)
			end
		end
		return finished()
	end
	local info = TweenInfo.new(duration(seconds), Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local ok, result = pcall(function()
		return TweenService:Create(obj, info, props)
	end)
	if not ok then
		for key, value in pairs(props) do
			pcall(function()
				obj[key] = value
			end)
		end
		return finished()
	end
	result:Play()
	return result
end

local function make(className, props, parent)
	local obj = Instance.new(className)
	for key, value in pairs(props or {}) do
		obj[key] = value
	end
	obj.Parent = parent
	return obj
end

local function corner(obj, radius)
	make("UICorner", { CornerRadius = UDim.new(0, radius) }, obj)
end

local function stroke(obj, transparency, color)
	return make("UIStroke", {
		Color = color or C.border,
		Transparency = transparency or 0.35,
		Thickness = 1,
	}, obj)
end

local function lay(parent)
	local nextOrder = (parent:GetAttribute("Lay") or 0) + 1
	parent:SetAttribute("Lay", nextOrder)
	return nextOrder
end

local function accentColor()
	return ACCENTS[P.accent] or C.cyan
end

local function trackAccent(obj, prop)
	table.insert(accentNodes, { obj, prop })
	obj[prop] = accentColor()
end

local function applyAccent()
	local color = accentColor()
	for index = #accentNodes, 1, -1 do
		local item = accentNodes[index]
		if item[1].Parent then
			item[1][item[2]] = color
		else
			table.remove(accentNodes, index)
		end
	end
end

local function watch(key, label)
	watchers[key] = watchers[key] or {}
	table.insert(watchers[key], label)
end

local function setWatch(key, text)
	local list = watchers[key]
	if not list then
		return
	end
	for index = #list, 1, -1 do
		local label = list[index]
		if label.Parent then
			label.Text = text
		else
			table.remove(list, index)
		end
	end
end

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor(seconds % 3600 / 60)
	local secs = seconds % 60
	if hours > 0 then
		return string.format("%d:%02d:%02d", hours, minutes, secs)
	end
	return string.format("%02d:%02d", minutes, secs)
end

local function gameById(id)
	for _, entry in ipairs(GAMES) do
		if entry.id == id then
			return entry
		end
	end
	return nil
end

local function inUrban()
	return game.PlaceId == 84448037861644
end

local function platformText()
	if GuiService:IsTenFootInterface() then
		return "Console"
	end
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		return "Touch"
	end
	if UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
		return "Gamepad"
	end
	if UserInputService.KeyboardEnabled then
		return "Keyboard"
	end
	return "Unknown"
end

local function resolutionText()
	local camera = workspace.CurrentCamera
	if not camera then
		return "Unavailable"
	end
	local view = camera.ViewportSize
	return string.format("%d x %d", math.floor(view.X + 0.5), math.floor(view.Y + 0.5))
end

local function fovText()
	local camera = workspace.CurrentCamera
	if not camera then
		return "Unavailable"
	end
	return tostring(math.floor(camera.FieldOfView + 0.5))
end

local function pingText()
	if not pingAvailable then
		return "Ping (estimate)    Unavailable"
	end
	local ok, sample = pcall(function()
		return player:GetNetworkPing()
	end)
	if not ok or type(sample) ~= "number" then
		return "Ping (estimate)    Unavailable"
	end
	return string.format("Ping (estimate)    %d ms", math.floor(sample * 1000 + 0.5))
end

local function memoryText()
	local ok, mb = pcall(function()
		return Stats:GetTotalMemoryUsageMb()
	end)
	if ok and type(mb) == "number" then
		return string.format("Memory    %.0f MB", mb)
	end
	return "Memory    Unavailable"
end

local function graphicsText()
	local ok, level = pcall(function()
		return UserSettings():GetService("UserGameSettings").SavedQualityLevel.Name
	end)
	if ok and type(level) == "string" then
		return level
	end
	return "Unavailable"
end

local function shownTransparency()
	return 1 - math.clamp(P.opacity or 1, 0.7, 1)
end

local function fitScale()
	local camera = workspace.CurrentCamera
	local view = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local sx = (view.X - 24) / WIN_W
	local sy = (view.Y - 96) / WIN_H
	return math.min(1, sx, sy)
end

local function computeScale()
	return math.clamp(fitScale() * (P.uiScale or 1), 0.68, 1.15)
end

local function recolor(root, color)
	if not root then
		return
	end
	for _, child in ipairs(root:GetDescendants()) do
		if child:IsA("UIStroke") then
			child.Color = color
		elseif child:IsA("Frame") then
			child.BackgroundColor3 = color
		end
	end
end

local function paintIcon(holder, name, color, pixel)
	local thick = math.max(1, math.floor((pixel or 18) * 0.08 + 0.5))
	local function scale(value)
		return value / 24
	end
	local function bar(cx, cy, len, rot)
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(scale(cx), scale(cy))
		frame.Size = UDim2.fromScale(scale(len), scale(1.7))
		frame.Rotation = rot or 0
		frame.BackgroundColor3 = color
		frame.BorderSizePixel = 0
		local radius = Instance.new("UICorner")
		radius.CornerRadius = UDim.new(1, 0)
		radius.Parent = frame
		frame.Parent = holder
	end
	local function ring(cx, cy, diameter, gap)
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(scale(cx), scale(cy))
		frame.Size = UDim2.fromScale(scale(diameter), scale(diameter))
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		local radius = Instance.new("UICorner")
		radius.CornerRadius = UDim.new(1, 0)
		radius.Parent = frame
		local outline = Instance.new("UIStroke")
		outline.Color = color
		outline.Thickness = thick
		outline.Parent = frame
		if gap then
			local gradient = Instance.new("UIGradient")
			gradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.72, 0),
				NumberSequenceKeypoint.new(0.86, 1),
				NumberSequenceKeypoint.new(1, 1),
			})
			gradient.Rotation = 30
			gradient.Parent = outline
		end
		frame.Parent = holder
	end
	local function box(x, y, w, h)
		local frame = Instance.new("Frame")
		frame.Position = UDim2.fromScale(scale(x), scale(y))
		frame.Size = UDim2.fromScale(scale(w), scale(h))
		frame.BackgroundColor3 = color
		frame.BorderSizePixel = 0
		local radius = Instance.new("UICorner")
		radius.CornerRadius = UDim.new(0, 2)
		radius.Parent = frame
		frame.Parent = holder
	end
	local function hollow(x, y, w, h)
		local frame = Instance.new("Frame")
		frame.Position = UDim2.fromScale(scale(x), scale(y))
		frame.Size = UDim2.fromScale(scale(w), scale(h))
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		local radius = Instance.new("UICorner")
		radius.CornerRadius = UDim.new(0, 3)
		radius.Parent = frame
		local outline = Instance.new("UIStroke")
		outline.Color = color
		outline.Thickness = thick
		outline.Parent = frame
		frame.Parent = holder
	end
	local function dot(cx, cy, diameter)
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(scale(cx), scale(cy))
		frame.Size = UDim2.fromScale(scale(diameter), scale(diameter))
		frame.BackgroundColor3 = color
		frame.BorderSizePixel = 0
		local radius = Instance.new("UICorner")
		radius.CornerRadius = UDim.new(1, 0)
		radius.Parent = frame
		frame.Parent = holder
	end

	if name == "home" then
		bar(9.2, 11, 11, -50)
		bar(14.8, 11, 11, 50)
		box(8, 12, 8, 8)
	elseif name == "gamepad" then
		hollow(3, 8, 18, 10)
		dot(8, 13, 2.4)
		dot(16, 11.5, 2.2)
		dot(18.2, 14.2, 2.2)
	elseif name == "search" then
		ring(10, 10, 8, false)
		bar(16, 16, 6, 45)
	elseif name == "users" then
		ring(9, 9, 6, false)
		ring(15, 10, 5, false)
		box(6, 14, 7, 5)
		box(12, 15, 6, 4)
	elseif name == "settings" then
		ring(12, 12, 7, false)
		bar(12, 12, 16, 0)
		bar(12, 12, 16, 90)
		bar(12, 12, 16, 45)
		bar(12, 12, 16, -45)
	elseif name == "sliders" then
		bar(12, 7, 16, 0)
		bar(12, 12, 16, 0)
		bar(12, 17, 16, 0)
		dot(8, 7, 3.4)
		dot(15, 12, 3.4)
		dot(10, 17, 3.4)
	elseif name == "monitor" then
		hollow(4, 4, 16, 11)
		bar(12, 18, 8, 0)
		bar(12, 20.5, 4, 0)
	elseif name == "camera" then
		hollow(3, 8, 18, 11)
		ring(12, 13.5, 5, false)
		box(8, 5, 6, 3)
	elseif name == "heart" then
		ring(9, 9, 5, false)
		ring(15, 9, 5, false)
		bar(9.2, 16, 8, 58)
		bar(14.8, 16, 8, -58)
	elseif name == "save" then
		hollow(6, 3, 12, 17)
		bar(12, 7, 8, 0)
		box(9, 13, 6, 4)
	elseif name == "clock" then
		ring(12, 12, 14, false)
		bar(12, 9.5, 6, 90)
		bar(13.2, 13, 5, 40)
	elseif name == "info" then
		ring(12, 12, 14, false)
		dot(12, 8, 2)
		bar(12, 14.5, 6, 90)
	elseif name == "chevronRight" then
		bar(11, 8.5, 7, 45)
		bar(11, 15.5, 7, -45)
	elseif name == "chevronLeft" then
		bar(13, 8.5, 7, -45)
		bar(13, 15.5, 7, 45)
	elseif name == "chevronDown" then
		bar(8.5, 11, 7, -45)
		bar(15.5, 11, 7, 45)
	elseif name == "chevronUp" then
		bar(8.5, 13, 7, 45)
		bar(15.5, 13, 7, -45)
	elseif name == "check" then
		bar(9, 13, 6, 40)
		bar(14.5, 11, 10, -48)
	elseif name == "close" then
		bar(12, 12, 12, 45)
		bar(12, 12, 12, -45)
	elseif name == "refresh" then
		ring(12, 12, 13, true)
		bar(17.2, 6.5, 5, 40)
		bar(17.2, 6.5, 5, -30)
	elseif name == "keyboard" then
		hollow(3, 6, 18, 12)
		box(5, 9, 2.2, 2)
		box(9, 9, 2.2, 2)
		box(13, 9, 2.2, 2)
		box(17, 9, 2.2, 2)
		box(7, 13, 10, 2)
	elseif name == "bell" then
		box(8, 7, 8, 8)
		bar(12, 16.5, 10, 0)
		dot(12, 18.5, 2.4)
		box(11, 4, 2, 3)
	elseif name == "minus" then
		bar(12, 12, 12, 0)
	elseif name == "copy" then
		hollow(8, 7, 10, 12)
		hollow(5, 4, 10, 12)
	else
		dot(12, 12, 3)
		warn("[VEXORA] Missing icon drawing for " .. tostring(name))
	end
end

local function icon(parent, name, pixel, color)
	local holder = make("Frame", {
		Name = "Icon",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(pixel, pixel),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
	}, parent)
	paintIcon(holder, name, color or C.white, pixel)
	return holder
end

local gui = make("ScreenGui", {
	Name = "VEXORA_5",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 200,
}, playerGui)

local crosshairRoot = make("Frame", {
	Name = "Crosshair",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 1,
	Active = false,
}, gui)

local hud = make("TextButton", {
	Name = "Hud",
	AutoButtonColor = false,
	Text = "",
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
	Size = UDim2.fromOffset(176, 78),
	Position = UDim2.fromOffset(16, 16),
	Visible = false,
	ZIndex = 2,
	Active = true,
}, gui)
corner(hud, 12)
stroke(hud, 0.25)

local hudFps = make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(12, 8),
	Size = UDim2.new(1, -24, 0, 18),
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.white,
	Text = "FPS    …",
}, hud)
local hudPing = make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(12, 28),
	Size = UDim2.new(1, -24, 0, 16),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.muted,
	Text = "Ping    …",
}, hud)
local hudTime = make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(12, 48),
	Size = UDim2.new(1, -24, 0, 16),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.muted,
	Text = "Session    00:00",
}, hud)
watch("fps", hudFps)
watch("ping", hudPing)
watch("session", hudTime)

local window = make("CanvasGroup", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(WIN_W, WIN_H),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
	ClipsDescendants = true,
	ZIndex = 3,
	Active = true,
}, gui)
corner(window, 16)
stroke(window, 0.12)
local uiScale = make("UIScale", { Scale = 1 }, window)

make("TextButton", {
	Name = "Sink",
	Text = "",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	Modal = true,
	ZIndex = 0,
}, window)

local grid = make("Frame", {
	Name = "Grid",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ClipsDescendants = true,
	ZIndex = 1,
}, window)
for x = 0, WIN_W, 26 do
	make("Frame", {
		Position = UDim2.fromOffset(x, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = C.white,
		BackgroundTransparency = 0.965,
		BorderSizePixel = 0,
	}, grid)
end
for y = 0, WIN_H, 26 do
	make("Frame", {
		Position = UDim2.fromOffset(0, y),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = C.white,
		BackgroundTransparency = 0.965,
		BorderSizePixel = 0,
	}, grid)
end

local pulseLayer = make("Frame", {
	Name = "Pulses",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ClipsDescendants = true,
	ZIndex = 2,
}, grid)

local glow = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.fromScale(0.5, 1),
	Size = UDim2.new(1, 0, 0, 150),
	BackgroundColor3 = C.violet,
	BackgroundTransparency = 0.96,
	BorderSizePixel = 0,
	ZIndex = 2,
}, window)
make("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0.2),
	}),
}, glow)

local sidebar = make("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, SIDE, 1, 0),
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
	ZIndex = 4,
}, window)
make("Frame", {
	Position = UDim2.new(1, -1, 0, 0),
	Size = UDim2.new(0, 1, 1, 0),
	BackgroundColor3 = C.border,
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
}, sidebar)

local logo = make("TextLabel", {
	Position = UDim2.fromOffset(15, 14),
	Size = UDim2.fromOffset(40, 40),
	BackgroundColor3 = C.white,
	Text = "V",
	TextColor3 = C.bg,
	TextSize = 22,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
}, sidebar)
corner(logo, 12)

local main = make("Frame", {
	Name = "Main",
	Position = UDim2.fromOffset(SIDE, 0),
	Size = UDim2.new(1, -SIDE, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 4,
}, window)

local header = make("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, HEADER),
	BackgroundTransparency = 1,
}, main)
make("Frame", {
	Position = UDim2.new(0, 0, 1, -1),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = C.border,
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
}, header)

local title = make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 8),
	Size = UDim2.new(1, -320, 0, 24),
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.white,
	Text = "Games",
	TextTruncate = Enum.TextTruncate.AtEnd,
}, header)
local subtitle = make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 32),
	Size = UDim2.new(1, -320, 0, 16),
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.muted,
	Text = "VEXORA   /   5.0",
	TextTruncate = Enum.TextTruncate.AtEnd,
}, header)

local searchButton = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -84, 0.5, 0),
	Size = UDim2.fromOffset(176, 32),
	BackgroundColor3 = C.card,
	Text = "",
	AutoButtonColor = false,
	BorderSizePixel = 0,
}, header)
corner(searchButton, 8)
stroke(searchButton, 0.4)
icon(searchButton, "search", 14, C.muted).Position = UDim2.fromOffset(16, 16)
make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(28, 0),
	Size = UDim2.new(1, -36, 1, 0),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.muted,
	Text = "Search    Ctrl K",
}, searchButton)

local minButton = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -48, 0.5, 0),
	Size = UDim2.fromOffset(28, 28),
	BackgroundColor3 = C.card,
	Text = "",
	AutoButtonColor = false,
	BorderSizePixel = 0,
}, header)
corner(minButton, 8)
icon(minButton, "minus", 14, C.muted)

local closeButton = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -12, 0.5, 0),
	Size = UDim2.fromOffset(28, 28),
	BackgroundColor3 = C.card,
	Text = "",
	AutoButtonColor = false,
	BorderSizePixel = 0,
}, header)
corner(closeButton, 8)
icon(closeButton, "close", 14, C.muted)

local body = make("Frame", {
	Name = "Body",
	Position = UDim2.fromOffset(0, HEADER),
	Size = UDim2.new(1, 0, 1, -HEADER),
	BackgroundTransparency = 1,
}, main)

local tabBar = make("ScrollingFrame", {
	Name = "Tabs",
	Visible = false,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 0),
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.X,
	ScrollBarThickness = 0,
	ScrollingDirection = Enum.ScrollingDirection.X,
	ElasticBehavior = Enum.ElasticBehavior.Never,
}, body)
make("UIPadding", {
	PaddingLeft = UDim.new(0, 12),
	PaddingRight = UDim.new(0, 12),
	PaddingTop = UDim.new(0, 8),
}, tabBar)
local tabLayout = make("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, tabBar)

local content = make("CanvasGroup", {
	Name = "Content",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	GroupTransparency = 0,
}, body)
local scroll = make("ScrollingFrame", {
	Name = "Scroll",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = C.border,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
}, content)

local dock = make("Frame", {
	Name = "Dock",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -16),
	Size = UDim2.fromOffset(DOCK_CLOSED, 52),
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
	Visible = false,
	ClipsDescendants = true,
	ZIndex = 6,
	Active = true,
}, gui)
corner(dock, 18)
stroke(dock, 0.12)
local dockScale = make("UIScale", { Scale = 1 }, dock)
local dockLogo = make("TextButton", {
	Position = UDim2.fromOffset(11, 8),
	Size = UDim2.fromOffset(36, 36),
	BackgroundColor3 = C.white,
	Text = "V",
	TextColor3 = C.bg,
	TextSize = 18,
	Font = Enum.Font.GothamBold,
	AutoButtonColor = false,
	BorderSizePixel = 0,
}, dock)
corner(dockLogo, 12)
local dockItems = make("Frame", {
	Position = UDim2.fromOffset(54, 8),
	Size = UDim2.fromOffset(220, 36),
	BackgroundTransparency = 1,
}, dock)

local tip = make("Frame", {
	Visible = false,
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
	Size = UDim2.fromOffset(80, 26),
	ZIndex = 15,
}, gui)
corner(tip, 8)
stroke(tip, 0.2)
local tipLabel = make("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = C.white,
	Text = "",
}, tip)

local dropdownCatcher = make("TextButton", {
	Visible = false,
	Text = "",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 20,
}, gui)
local dropdownPanel = make("Frame", {
	Visible = false,
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
	ZIndex = 21,
	ClipsDescendants = true,
}, gui)
corner(dropdownPanel, 10)
stroke(dropdownPanel, 0.15)
local dropdownSearch = make("TextBox", {
	Visible = false,
	Position = UDim2.fromOffset(8, 8),
	Size = UDim2.new(1, -16, 0, 28),
	BackgroundColor3 = C.card,
	Text = "",
	PlaceholderText = "Filter",
	PlaceholderColor3 = C.muted,
	TextColor3 = C.white,
	Font = Enum.Font.Gotham,
	TextSize = 13,
	ClearTextOnFocus = false,
	BorderSizePixel = 0,
}, dropdownPanel)
corner(dropdownSearch, 7)
local dropdownList = make("ScrollingFrame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(6, 8),
	Size = UDim2.new(1, -12, 1, -14),
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = C.border,
	ElasticBehavior = Enum.ElasticBehavior.Never,
}, dropdownPanel)

local modalDim = make("TextButton", {
	Visible = false,
	Text = "",
	AutoButtonColor = false,
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 30,
}, gui)
local modalPanel = make("Frame", {
	Visible = false,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(420, 250),
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
	ZIndex = 31,
}, gui)
corner(modalPanel, 14)
stroke(modalPanel, 0.12)
local modalTitle = make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 16),
	Size = UDim2.new(1, -36, 0, 24),
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.white,
	Text = "",
}, modalPanel)
local modalBody = make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 46),
	Size = UDim2.new(1, -36, 0, 58),
	Font = Enum.Font.Gotham,
	TextSize = 13,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextColor3 = C.muted,
	Text = "",
}, modalPanel)
local modalBox = make("TextBox", {
	Visible = false,
	Position = UDim2.fromOffset(18, 112),
	Size = UDim2.new(1, -36, 0, 64),
	BackgroundColor3 = C.card,
	Text = "",
	TextColor3 = C.white,
	PlaceholderColor3 = C.muted,
	Font = Enum.Font.Gotham,
	TextSize = 13,
	TextWrapped = true,
	ClearTextOnFocus = false,
	MultiLine = true,
	BorderSizePixel = 0,
}, modalPanel)
corner(modalBox, 8)
local modalButtons = make("Frame", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 0, 1, -14),
	Size = UDim2.new(1, 0, 0, 34),
}, modalPanel)

local paletteDim = make("TextButton", {
	Visible = false,
	Text = "",
	AutoButtonColor = false,
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 40,
}, gui)
local palettePanel = make("CanvasGroup", {
	Visible = false,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.46),
	Size = UDim2.fromOffset(520, 420),
	BackgroundColor3 = C.panel,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	ZIndex = 41,
	ClipsDescendants = true,
}, gui)
corner(palettePanel, 14)
stroke(palettePanel, 0.12)
local paletteBox = make("TextBox", {
	Position = UDim2.fromOffset(14, 14),
	Size = UDim2.new(1, -28, 0, 36),
	BackgroundColor3 = C.card,
	Text = "",
	PlaceholderText = "Search features",
	PlaceholderColor3 = C.muted,
	TextColor3 = C.white,
	Font = Enum.Font.Gotham,
	TextSize = 15,
	ClearTextOnFocus = false,
	BorderSizePixel = 0,
}, palettePanel)
corner(paletteBox, 8)
local paletteList = make("ScrollingFrame", {
	Position = UDim2.fromOffset(10, 60),
	Size = UDim2.new(1, -20, 1, -72),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = C.border,
	ElasticBehavior = Enum.ElasticBehavior.Never,
}, palettePanel)

local toastLayer = make("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 50,
}, gui)

local notify, requestSave, applyChrome, applyCrosshair, applyFov, applyHud, applyAll
local setLowGraphics, navigate, renderPage, toggleWindow, ensureWindow, refreshHeader, refreshNav
local openPalette, closePalette, closeDropdown, openModal, closeModal, confirm, promptBox, copyText
local pushRecent, useFeature, bindHover, bindTip

local function feature(def)
	features[def.id] = def
	table.insert(featureOrder, def.id)
end

local function scoreFeature(query, def)
	if query == "" then
		return 1
	end
	local name = string.lower(def.name)
	local category = string.lower(def.category or "")
	local description = string.lower(def.description or "")
	if name == query then
		return 100
	end
	local found = string.find(name, query, 1, true)
	if found == 1 then
		return 90
	end
	if found then
		return 75
	end
	if string.find(category, query, 1, true) then
		return 55
	end
	if string.find(description, query, 1, true) then
		return 40
	end
	local index = 1
	for character in string.gmatch(query, ".") do
		local at = string.find(name, character, index, true)
		if not at then
			return 0
		end
		index = at + 1
	end
	return 18
end

bindHover = function(button, rest, over, press)
	button.AutoButtonColor = false
	button:SetAttribute("Rest", nil)
	button.MouseEnter:Connect(function()
		if button:GetAttribute("Disabled") then
			return
		end
		tween(button, 0.12, { BackgroundColor3 = over })
	end)
	button.MouseLeave:Connect(function()
		if button:GetAttribute("Disabled") then
			return
		end
		local selected = button:GetAttribute("Selected")
		tween(button, 0.12, { BackgroundColor3 = selected and C.hover or rest })
	end)
	button.MouseButton1Down:Connect(function()
		if button:GetAttribute("Disabled") then
			return
		end
		tween(button, 0.06, { BackgroundColor3 = press or C.bg })
	end)
	button.MouseButton1Up:Connect(function()
		if button:GetAttribute("Disabled") then
			return
		end
		tween(button, 0.1, { BackgroundColor3 = over })
	end)
end

bindTip = function(target, text)
	target.MouseEnter:Connect(function()
		tipToken += 1
		local token = tipToken
		task.delay(P.reducedMotion and 0 or 0.35, function()
			if token ~= tipToken or not alive or not target.Parent then
				return
			end
			tipLabel.Text = text
			local width = math.clamp(#text * 7 + 18, 52, 200)
			tip.Size = UDim2.fromOffset(width, 26)
			tip.Visible = true
			local camera = workspace.CurrentCamera
			local view = camera and camera.ViewportSize or Vector2.new(1280, 720)
			local x = target.AbsolutePosition.X + target.AbsoluteSize.X * 0.5 - width * 0.5
			local y = target.AbsolutePosition.Y - 32
			if y < 8 then
				y = target.AbsolutePosition.Y + target.AbsoluteSize.Y + 8
			end
			x = math.clamp(x, 8, math.max(8, view.X - width - 8))
			tip.Position = UDim2.fromOffset(x, y)
		end)
	end)
	target.MouseLeave:Connect(function()
		tipToken += 1
		tip.Visible = false
	end)
end

local function clearScroll()
	clearPageConns()
	chartBars = nil
	onPlayersChanged = nil
	for _, child in ipairs(scroll:GetChildren()) do
		child:Destroy()
	end
	scroll:SetAttribute("Lay", 0)
	make("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 16),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	}, scroll)
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, scroll)
	scroll.CanvasPosition = Vector2.zero
end

local function stack(parent, padding)
	local frame = make("Frame", {
		LayoutOrder = lay(parent),
		BackgroundColor3 = C.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, parent)
	corner(frame, 12)
	stroke(frame, 0.5)
	make("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	}, frame)
	make("UIListLayout", {
		Padding = UDim.new(0, padding or 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, frame)
	frame:SetAttribute("Lay", 0)
	return frame
end

local function fixedRow(parent, height, color)
	return make("Frame", {
		LayoutOrder = lay(parent),
		BackgroundColor3 = color or C.card,
		BackgroundTransparency = color and 0 or 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height),
	}, parent)
end

local function textLabel(parent, text, size, color, bold, height)
	return make("TextLabel", {
		LayoutOrder = lay(parent),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height or (bold and 22 or 16)),
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextSize = size,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextColor3 = color or C.white,
		Text = text,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
end

local function button(parent, textValue, callback, opts)
	opts = opts or {}
	local item = make("TextButton", {
		LayoutOrder = opts.order or lay(parent),
		Size = opts.size or UDim2.new(1, 0, 0, 34),
		Position = opts.position or UDim2.fromOffset(0, 0),
		AnchorPoint = opts.anchor or Vector2.new(0, 0),
		BackgroundColor3 = opts.primary and C.white or C.hover,
		Text = textValue,
		TextColor3 = opts.primary and C.bg or C.white,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, parent)
	corner(item, 8)
	bindHover(item, opts.primary and C.white or C.hover, opts.primary and Color3.fromRGB(226, 228, 232) or C.border, opts.primary and Color3.fromRGB(210, 212, 216) or C.bg)
	item.Activated:Connect(function()
		if item:GetAttribute("Disabled") then
			if opts.disabledReason then
				notify(opts.disabledReason, "warning")
			end
			return
		end
		callback()
	end)
	if opts.disabled then
		item:SetAttribute("Disabled", true)
		item.TextColor3 = C.muted
		item.BackgroundColor3 = C.card
	end
	return item
end

local function setFavourite(id, on)
	if on then
		G.favorites[id] = true
	else
		G.favorites[id] = nil
	end
	requestSave()
end

local function heartButton(parent, featureId, xOffset)
	local item = make("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.fromOffset(24, 24),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, xOffset, 0.5, 0),
		AutoButtonColor = false,
	}, parent)
	local holder = icon(item, "heart", 14, G.favorites[featureId] and C.violet or C.muted)
	item.Activated:Connect(function()
		local on = G.favorites[featureId] ~= true
		setFavourite(featureId, on)
		recolor(holder, on and C.violet or C.muted)
		notify(on and "Saved to favourites." or "Removed from favourites.", "info")
	end)
	return item
end

local function toggle(parent, labelText, value, featureId, callback)
	local row = fixedRow(parent, 36)
	if featureId then
		local holder = icon(row, "heart", 14, G.favorites[featureId] and C.violet or C.muted)
		holder.AnchorPoint = Vector2.new(0, 0.5)
		holder.Position = UDim2.new(0, 0, 0.5, 0)
		local hit = make("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.fromOffset(0, 6),
			AutoButtonColor = false,
		}, row)
		hit.Activated:Connect(function()
			local on = G.favorites[featureId] ~= true
			setFavourite(featureId, on)
			recolor(holder, on and C.violet or C.muted)
		end)
	end
	local inset = featureId and 28 or 0
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(inset, 0),
		Size = UDim2.new(1, -(78 + inset), 1, 0),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.white,
		Text = labelText,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	local switch = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(44, 24),
		BackgroundColor3 = value and C.white or C.hover,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, row)
	corner(switch, 12)
	local knob = make("Frame", {
		Position = value and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = value and C.bg or C.muted,
		BorderSizePixel = 0,
	}, switch)
	corner(knob, 9)
	local on = value == true
	switch.Activated:Connect(function()
		local nextValue = not on
		local result = callback(nextValue)
		if result == false then
			return
		end
		on = nextValue
		tween(switch, 0.16, { BackgroundColor3 = on and C.white or C.hover })
		tween(knob, 0.16, {
			Position = on and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = on and C.bg or C.muted,
		})
	end)
	return row
end

local function slider(parent, labelText, minValue, maxValue, value, step, featureId, callback)
	local row = fixedRow(parent, 52)
	local inset = 0
	if featureId then
		inset = 28
		local holder = icon(row, "heart", 14, G.favorites[featureId] and C.violet or C.muted)
		holder.Position = UDim2.fromOffset(12, 4)
		holder.AnchorPoint = Vector2.new(0, 0)
		local hit = make("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.fromOffset(0, 0),
			AutoButtonColor = false,
		}, row)
		hit.Activated:Connect(function()
			local on = G.favorites[featureId] ~= true
			setFavourite(featureId, on)
			recolor(holder, on and C.violet or C.muted)
		end)
	end
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(inset, 2),
		Size = UDim2.new(1, -(72 + inset), 0, 18),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.white,
		Text = labelText,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	local valueLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 2),
		Size = UDim2.fromOffset(64, 18),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = C.white,
		Text = "",
	}, row)
	local hit = make("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 0, 18),
	}, row)
	local track = make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = C.hover,
		BorderSizePixel = 0,
	}, hit)
	corner(track, 4)
	local fill = make("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = C.white,
		BorderSizePixel = 0,
	}, track)
	corner(fill, 4)
	local knob = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = C.white,
		BorderSizePixel = 0,
	}, hit)
	corner(knob, 8)
	local current = math.clamp(value, minValue, maxValue)
	local function format(number)
		if step >= 1 then
			return tostring(math.floor(number + 0.5))
		end
		return string.format("%.2f", number)
	end
	local function paint(number)
		local alpha = (number - minValue) / (maxValue - minValue)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = format(number)
	end
	paint(current)
	local dragging = false
	local function fromX(x)
		local width = math.max(track.AbsoluteSize.X, 1)
		local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
		local nextValue = minValue + (maxValue - minValue) * alpha
		if step > 0 then
			nextValue = math.floor(nextValue / step + 0.5) * step
		end
		nextValue = math.clamp(nextValue, minValue, maxValue)
		current = nextValue
		paint(nextValue)
		callback(nextValue, false)
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			fromX(input.Position.X)
		end
	end)
	trackPage(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			fromX(input.Position.X)
		end
	end))
	trackPage(UserInputService.InputEnded:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			callback(current, true)
		end
	end))
end

local function closeDropdown()
	dropdownCatcher.Visible = false
	dropdownPanel.Visible = false
	dropdownCallback = nil
	dropdownSearch.Text = ""
end

local function fillDropdown(filter)
	for _, child in ipairs(dropdownList:GetChildren()) do
		child:Destroy()
	end
	make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, dropdownList)
	local shown = 0
	filter = string.lower(filter or "")
	for _, option in ipairs(dropdownOptions) do
		if filter == "" or string.find(string.lower(option), filter, 1, true) then
			shown += 1
			local item = make("TextButton", {
				LayoutOrder = shown,
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundColor3 = C.panel,
				Text = option,
				TextColor3 = C.white,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				AutoButtonColor = false,
				BorderSizePixel = 0,
			}, dropdownList)
			corner(item, 6)
			bindHover(item, C.panel, C.hover, C.bg)
			item.Activated:Connect(function()
				local callback = dropdownCallback
				closeDropdown()
				if callback then
					callback(option)
				end
			end)
		end
	end
	if shown == 0 then
		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 28),
			Text = "No matches",
			TextColor3 = C.muted,
			Font = Enum.Font.Gotham,
			TextSize = 13,
		}, dropdownList)
	end
end

local function openDropdown(anchor, options, callback)
	closeDropdown()
	dropdownOptions = options
	dropdownCallback = callback
	local showSearch = #options > 6
	dropdownSearch.Visible = showSearch
	dropdownList.Position = UDim2.fromOffset(6, showSearch and 42 or 6)
	dropdownList.Size = UDim2.new(1, -12, 1, showSearch and -48 or -12)
	fillDropdown("")
	local rows = math.min(#options, 6)
	local height = rows * 30 + (showSearch and 46 or 12)
	local camera = workspace.CurrentCamera
	local view = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local width = math.max(anchor.AbsoluteSize.X, 180)
	local x = anchor.AbsolutePosition.X
	local y = anchor.AbsolutePosition.Y + anchor.AbsoluteSize.Y + 6
	if x + width > view.X - 8 then
		x = math.max(8, view.X - width - 8)
	end
	if y + height > view.Y - 8 then
		y = math.max(8, anchor.AbsolutePosition.Y - height - 6)
	end
	dropdownPanel.Position = UDim2.fromOffset(x, y)
	dropdownPanel.Size = UDim2.fromOffset(width, height)
	dropdownCatcher.Visible = true
	dropdownPanel.Visible = true
end

dropdownSearch:GetPropertyChangedSignal("Text"):Connect(function()
	if dropdownPanel.Visible then
		fillDropdown(dropdownSearch.Text)
	end
end)
dropdownCatcher.Activated:Connect(closeDropdown)

local function dropdown(parent, labelText, options, value, callback)
	local row = fixedRow(parent, 36)
	make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -168, 1, 0),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.white,
		Text = labelText,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	local picker = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(156, 28),
		BackgroundColor3 = C.hover,
		Text = "  " .. tostring(value),
		TextColor3 = C.white,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, row)
	corner(picker, 8)
	icon(picker, "chevronDown", 12, C.muted).Position = UDim2.new(1, -16, 0.5, 0)
	bindHover(picker, C.hover, C.border, C.bg)
	picker.Activated:Connect(function()
		openDropdown(picker, options, function(choice)
			picker.Text = "  " .. choice
			callback(choice)
		end)
	end)
	return picker
end

notify = function(text, kind)
	kind = kind or "info"
	table.insert(history, 1, { text = text, kind = kind, at = os.clock() })
	while #history > 20 do
		table.remove(history)
	end
	if not P.notifications and kind ~= "error" then
		return
	end
	local last = toastLayer:FindFirstChild("Last")
	if last and last:GetAttribute("Body") == text and os.clock() - (last:GetAttribute("At") or 0) < 1.2 then
		return
	end
	local count = 0
	for _, child in ipairs(toastLayer:GetChildren()) do
		if child:IsA("Frame") then
			count += 1
		end
	end
	if count >= 4 then
		local oldest = toastLayer:FindFirstChild("Toast1") or toastLayer:FindFirstChildWhichIsA("Frame")
		if oldest then
			oldest:Destroy()
		end
	end
	local colors = { success = C.green, info = C.cyan, warning = C.violet, error = C.red }
	local frame = make("Frame", {
		Name = "Toast",
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.fromOffset(286, 56),
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
	}, toastLayer)
	frame:SetAttribute("Body", text)
	frame:SetAttribute("At", os.clock())
	frame:SetAttribute("Last", true)
	local previous = toastLayer:FindFirstChild("LastMark")
	if previous then
		previous.Name = "Toast"
	end
	frame.Name = "LastMark"
	corner(frame, 10)
	stroke(frame, 0.2)
	make("Frame", {
		Size = UDim2.new(0, 3, 1, -16),
		Position = UDim2.fromOffset(8, 8),
		BackgroundColor3 = colors[kind] or C.cyan,
		BorderSizePixel = 0,
	}, frame)
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 8),
		Size = UDim2.new(1, -48, 1, -16),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextColor3 = C.white,
		Text = text,
	}, frame)
	local dismiss
	local closer = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
	}, frame)
	icon(closer, "close", 12, C.muted)
	dismiss = function()
		if frame.Parent then
			frame:Destroy()
			local y = 16
			for _, child in ipairs(toastLayer:GetChildren()) do
				if child:IsA("Frame") then
					child.Position = UDim2.new(1, -16, 0, y)
					y += 64
				end
			end
		end
	end
	closer.Activated:Connect(dismiss)
	local y = 16
	for _, child in ipairs(toastLayer:GetChildren()) do
		if child:IsA("Frame") then
			child.Position = UDim2.new(1, -16, 0, y)
			y += 64
		end
	end
	task.delay(3.4, dismiss)
end

requestSave = function()
	if saveQueued or typeof(writefile) ~= "function" then
		return
	end
	saveQueued = true
	task.delay(0.45, function()
		saveQueued = false
		if not alive then
			return
		end
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode({ version = 5, global = G })
		end)
		if not ok then
			warn("[VEXORA] Could not encode settings: " .. tostring(encoded))
			return
		end
		local wrote, err = pcall(writefile, "VEXORA_5_settings.json", encoded)
		if wrote then
			storageMode = "file"
			storageNote = "Saved in VEXORA_5_settings.json on this device."
		else
			storageMode = "session"
			storageNote = "Couldn't write the settings file. Export a copy to keep it."
			if not saveWarned then
				saveWarned = true
				warn("[VEXORA] Settings file was not written: " .. tostring(err))
				notify("Settings stayed in this session. The file could not be written.", "warning")
			end
		end
	end)
end

applyCrosshair = function()
	for _, child in ipairs(crosshairRoot:GetChildren()) do
		child:Destroy()
	end
	local crosshair = P.crosshair
	if not crosshair.enabled then
		return
	end
	local color = COLOR_VALUES[crosshair.color] or C.white
	local transparency = 1 - math.clamp(crosshair.opacity, 0.25, 1)
	local arm = crosshair.size
	local thick = crosshair.thickness
	local gap = crosshair.gap
	local function part(ox, oy, w, h, roundAll, hollow)
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0.5, ox, 0.5, oy)
		frame.Size = UDim2.fromOffset(math.max(1, w), math.max(1, h))
		frame.BackgroundColor3 = color
		frame.BackgroundTransparency = hollow and 1 or transparency
		frame.BorderSizePixel = 0
		frame.Active = false
		frame.ZIndex = 1
		if roundAll then
			local radius = Instance.new("UICorner")
			radius.CornerRadius = UDim.new(1, 0)
			radius.Parent = frame
		end
		if hollow then
			local outline = Instance.new("UIStroke")
			outline.Color = color
			outline.Thickness = thick
			outline.Transparency = transparency
			outline.Parent = frame
		end
		frame.Parent = crosshairRoot
	end
	if crosshair.style == "Dot" then
		part(0, 0, thick + 2, thick + 2, true, false)
	elseif crosshair.style == "Circle" then
		part(0, 0, math.max(8, arm * 2), math.max(8, arm * 2), true, true)
	else
		local length = crosshair.style == "Minimal" and math.max(3, math.floor(arm * 0.55)) or arm
		local reach = gap / 2 + length / 2
		part(-reach, 0, length, thick, true, false)
		part(reach, 0, length, thick, true, false)
		part(0, -reach, thick, length, true, false)
		part(0, reach, thick, length, true, false)
	end
end

applyFov = function(smooth)
	if type(P.fov) ~= "number" then
		return
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local goal = P.fov
	if smooth and P.smoothFov and not P.reducedMotion then
		TweenService:Create(camera, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			FieldOfView = goal,
		}):Play()
	else
		camera.FieldOfView = goal
	end
	setWatch("fov", "Field of view    " .. fovText())
end

applyHud = function()
	hud.Visible = bootDone and P.hud.visible == true
	if not hudDrag then
		hud.Position = UDim2.fromOffset(P.hud.x or 16, P.hud.y or 16)
	end
end

setLowGraphics = function(on)
	local ok, err = pcall(function()
		local settings = UserSettings():GetService("UserGameSettings")
		if on then
			if previousQuality == nil then
				previousQuality = settings.SavedQualityLevel
			end
			settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
		else
			if previousQuality ~= nil then
				settings.SavedQualityLevel = previousQuality
			end
			previousQuality = nil
		end
	end)
	if not ok then
		P.lowGraphics = false
		warn("[VEXORA] Graphics quality was not changed: " .. tostring(err))
		notify("Graphics quality can't be changed on this client.", "error")
		return false
	end
	P.lowGraphics = on
	setWatch("graphics", "Graphics    " .. graphicsText())
	return true
end

applyChrome = function()
	if not G.sidebar and not G.dock then
		G.dock = true
	end
	sidebar.Visible = G.sidebar
	local side = G.sidebar and SIDE or 0
	main.Position = UDim2.fromOffset(side, 0)
	main.Size = UDim2.new(1, -side, 1, 0)
	grid.Visible = P.grid ~= false
	pulseLayer.Visible = P.pulses ~= false and P.reducedMotion ~= true
	glow.Visible = true
	dock.Visible = G.dock and bootDone
	uiScale.Scale = computeScale()
	local camera = workspace.CurrentCamera
	if camera then
		dockScale.Scale = math.clamp(math.min(1, (camera.ViewportSize.X - 24) / 340), 0.75, 1)
	end
	if windowOpen then
		window.GroupTransparency = shownTransparency()
	end
end

applyAll = function()
	applyChrome()
	applyAccent()
	applyCrosshair()
	applyHud()
	applyFov(false)
	if graphicsAvailable then
		setLowGraphics(P.lowGraphics == true)
	end
end

refreshHeader = function()
	local names = {
		Home = "Home",
		Games = "Games",
		Universal = "Universal",
		Urban = "Urban Reload",
		Settings = "Settings",
	}
	title.Text = names[currentPage] or "VEXORA"
	local selected = gameById(selectedId)
	subtitle.Text = "VEXORA   /   5.0   /   " .. (selected and selected.name or "No profile")
end

refreshNav = function()
	for page, group in pairs(navButtons) do
		local selected = page == currentPage
		for _, buttonObj in ipairs({ group.side, group.dock }) do
			if buttonObj then
				buttonObj:SetAttribute("Selected", selected)
				buttonObj.BackgroundColor3 = selected and C.hover or (buttonObj.Parent == dockItems and C.card or C.panel)
				local holder = buttonObj:FindFirstChild("Icon")
				if holder then
					recolor(holder, selected and C.white or C.muted)
				end
				local mark = buttonObj:FindFirstChild("Mark")
				if mark then
					mark.Visible = selected
					mark.BackgroundColor3 = accentColor()
				end
			end
		end
	end
end

local function layoutBody()
	local showTabs = currentPage == "Universal"
	tabBar.Visible = showTabs
	tabBar.Size = UDim2.new(1, 0, 0, showTabs and 40 or 0)
	content.Position = UDim2.fromOffset(0, showTabs and 40 or 0)
	content.Size = UDim2.new(1, 0, 1, showTabs and -40 or 0)
	for _, child in ipairs(tabBar:GetChildren()) do
		if child:IsA("TextButton") then
			local on = child.Name == currentTab
			child.BackgroundColor3 = on and C.hover or C.bg
			child.TextColor3 = on and C.white or C.muted
		end
	end
end

local function note(parent, text)
	local rows = math.clamp(math.ceil(#text / 62), 2, 6)
	local label = textLabel(parent, text, 12, C.muted, false, rows * 16)
	label.TextWrapped = true
	label.TextTruncate = Enum.TextTruncate.None
	label.TextYAlignment = Enum.TextYAlignment.Top
	return label
end

local function stat(parent, text, key)
	local label = textLabel(parent, text, 13, C.white, false, 18)
	if key then
		watch(key, label)
	end
	return label
end

closeModal = function()
	if not modalOpen then
		return
	end
	modalOpen = false
	local fade = tween(modalDim, 0.14, { BackgroundTransparency = 1 })
	tween(modalPanel, 0.14, { Position = UDim2.new(0.5, 0, 0.5, 10) })
	fade.Completed:Connect(function()
		if not modalOpen then
			modalDim.Visible = false
			modalPanel.Visible = false
		end
	end)
end

openModal = function(opts)
	closeDropdown()
	if paletteOpen then
		closePalette()
	end
	modalOpen = true
	modalTitle.Text = opts.title or ""
	modalBody.Text = opts.body or ""
	modalBox.Visible = opts.text ~= nil or opts.editable == true
	modalBox.Text = opts.text or ""
	modalBox.PlaceholderText = opts.placeholder or ""
	modalBox.TextEditable = opts.editable ~= false
	if opts.editable then
		modalBox.TextEditable = true
	end
	if opts.text and opts.editable == nil then
		modalBox.TextEditable = true
	end
	for _, child in ipairs(modalButtons:GetChildren()) do
		child:Destroy()
	end
	local list = opts.buttons or { { text = "Close", primary = true } }
	for index, spec in ipairs(list) do
		local item = button(modalButtons, spec.text, function()
			local value = modalBox.Text
			closeModal()
			if spec.action then
				spec.action(value)
			end
		end, {
			primary = spec.primary,
			anchor = Vector2.new(1, 0.5),
			position = UDim2.new(1, -16 - (#list - index) * 110, 0.5, 0),
			size = UDim2.fromOffset(100, 32),
			order = index,
		})
		item.Parent = modalButtons
	end
	modalDim.Visible = true
	modalDim.BackgroundTransparency = 1
	modalPanel.Visible = true
	modalPanel.Position = UDim2.new(0.5, 0, 0.5, 12)
	tween(modalDim, 0.16, { BackgroundTransparency = 0.42 })
	tween(modalPanel, 0.18, { Position = UDim2.fromScale(0.5, 0.5) })
	if modalBox.Visible then
		task.defer(function()
			if modalBox.Parent and modalOpen then
				modalBox:CaptureFocus()
				if opts.text then
					modalBox.CursorPosition = #modalBox.Text + 1
					modalBox.SelectionStart = 1
				end
			end
		end)
	end
end

confirm = function(titleText, bodyText, onYes)
	openModal({
		title = titleText,
		body = bodyText,
		buttons = {
			{ text = "Cancel" },
			{ text = "Confirm", primary = true, action = function()
				onYes()
			end },
		},
	})
end

promptBox = function(titleText, placeholder, onYes)
	openModal({
		title = titleText,
		body = "Enter a name.",
		placeholder = placeholder,
		editable = true,
		text = "",
		buttons = {
			{ text = "Cancel" },
			{ text = "Save", primary = true, action = function(value)
				if type(value) == "string" and value ~= "" then
					onYes(value)
				else
					notify("Enter a name first.", "warning")
				end
			end },
		},
	})
end

copyText = function(value, label)
	local text = tostring(value)
	if typeof(setclipboard) == "function" then
		local ok = pcall(setclipboard, text)
		if ok then
			notify("Copied " .. label .. ".", "success")
			return
		end
	end
	openModal({
		title = "Copy " .. label,
		body = "Clipboard write isn't available here. Select the text and copy it.",
		text = text,
		buttons = { { text = "Close", primary = true } },
	})
end

pushRecent = function(id)
	for index = #G.recents, 1, -1 do
		if G.recents[index] == id then
			table.remove(G.recents, index)
		end
	end
	table.insert(G.recents, 1, id)
	while #G.recents > 8 do
		table.remove(G.recents)
	end
	requestSave()
end

local function rememberQuery(query)
	if query == nil or query == "" then
		return
	end
	for index = #recentQueries, 1, -1 do
		if recentQueries[index] == query then
			table.remove(recentQueries, index)
		end
	end
	table.insert(recentQueries, 1, query)
	while #recentQueries > 6 do
		table.remove(recentQueries)
	end
end

local function fillPalette()
	for _, child in ipairs(paletteList:GetChildren()) do
		child:Destroy()
	end
	make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, paletteList)
	table.clear(paletteRows)
	local query = string.lower(paletteBox.Text or "")
	local order = 0
	local function addHeader(text)
		order += 1
		local label = make("TextLabel", {
			LayoutOrder = order,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.muted,
			Text = string.upper(text),
		}, paletteList)
		table.insert(paletteRows, { header = true, button = label })
	end
	local function addFeature(def, score)
		order += 1
		local row = make("TextButton", {
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundColor3 = C.card,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
		}, paletteList)
		corner(row, 8)
		icon(row, def.icon or "info", 16, C.white).Position = UDim2.fromOffset(20, 24)
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(40, 6),
			Size = UDim2.new(1, -130, 0, 18),
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.white,
			Text = def.name,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(40, 26),
			Size = UDim2.new(1, -56, 0, 16),
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.muted,
			Text = def.description or "",
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)
		make("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, 8),
			Size = UDim2.fromOffset(80, 16),
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = C.muted,
			Text = def.category or "",
		}, row)
		row.Activated:Connect(function()
			rememberQuery(paletteBox.Text)
			useFeature(def.id)
		end)
		table.insert(paletteRows, { feature = def, score = score, button = row })
	end
	if query == "" and #G.recents > 0 then
		addHeader("Recent")
		for index = 1, math.min(4, #G.recents) do
			local def = features[G.recents[index]]
			if def then
				addFeature(def, 1)
			end
		end
		addHeader("All")
	end
	local ranked = {}
	for _, id in ipairs(featureOrder) do
		local def = features[id]
		local value = scoreFeature(query, def)
		if value > 0 then
			table.insert(ranked, { def = def, score = value })
		end
	end
	table.sort(ranked, function(a, b)
		if a.score == b.score then
			return a.def.name < b.def.name
		end
		return a.score > b.score
	end)
	if #ranked == 0 then
		order += 1
		make("TextLabel", {
			LayoutOrder = order,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 48),
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = C.muted,
			Text = "No matching features",
		}, paletteList)
	end
	for _, item in ipairs(ranked) do
		addFeature(item.def, item.score)
	end
	local selectable = 0
	for _, row in ipairs(paletteRows) do
		if row.feature then
			selectable += 1
			row.button.BackgroundColor3 = selectable == paletteIndex and C.hover or C.card
		end
	end
	if selectable == 0 then
		paletteIndex = 1
	else
		paletteIndex = math.clamp(paletteIndex, 1, selectable)
	end
end

local function selectedPaletteFeature()
	local index = 0
	for _, row in ipairs(paletteRows) do
		if row.feature then
			index += 1
			if index == paletteIndex then
				return row.feature
			end
		end
	end
	return nil
end

local function movePalette(delta)
	local count = 0
	for _, row in ipairs(paletteRows) do
		if row.feature then
			count += 1
		end
	end
	if count == 0 then
		return
	end
	paletteIndex = math.clamp(paletteIndex + delta, 1, count)
	local index = 0
	for _, row in ipairs(paletteRows) do
		if row.feature then
			index += 1
			row.button.BackgroundColor3 = index == paletteIndex and C.hover or C.card
		end
	end
end

closePalette = function()
	if not paletteOpen then
		return
	end
	paletteOpen = false
	pcall(function()
		ContextActionService:UnbindAction("VEXORA_Palette")
	end)
	tween(paletteDim, 0.12, { BackgroundTransparency = 1 })
	local fade = tween(palettePanel, 0.12, { GroupTransparency = 1 })
	fade.Completed:Connect(function()
		if not paletteOpen then
			paletteDim.Visible = false
			palettePanel.Visible = false
		end
	end)
end

openPalette = function()
	if not bootDone then
		return
	end
	closeDropdown()
	if modalOpen then
		closeModal()
	end
	if paletteOpen then
		paletteBox:CaptureFocus()
		return
	end
	paletteOpen = true
	paletteDim.Visible = true
	paletteDim.BackgroundTransparency = 1
	palettePanel.Visible = true
	palettePanel.GroupTransparency = 1
	paletteBox.Text = ""
	paletteIndex = 1
	fillPalette()
	tween(paletteDim, 0.16, { BackgroundTransparency = 0.4 })
	tween(palettePanel, 0.16, { GroupTransparency = 0 })
	ContextActionService:BindActionAtPriority("VEXORA_Palette", function(_, state, input)
		if state ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end
		if input.KeyCode == Enum.KeyCode.Up then
			movePalette(-1)
			return Enum.ContextActionResult.Sink
		elseif input.KeyCode == Enum.KeyCode.Down then
			movePalette(1)
			return Enum.ContextActionResult.Sink
		elseif input.KeyCode == Enum.KeyCode.Return then
			local def = selectedPaletteFeature()
			local query = paletteBox.Text
			if def then
				rememberQuery(query)
				useFeature(def.id)
			end
			return Enum.ContextActionResult.Sink
		elseif input.KeyCode == Enum.KeyCode.Escape then
			suppressEscape = true
			closePalette()
			task.delay(0.05, function()
				suppressEscape = false
			end)
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, 3000, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Return, Enum.KeyCode.Escape)
	task.defer(function()
		if paletteOpen then
			paletteBox:CaptureFocus()
		end
	end)
end

paletteBox:GetPropertyChangedSignal("Text"):Connect(function()
	if paletteOpen then
		paletteIndex = 1
		fillPalette()
	end
end)
paletteDim.Activated:Connect(function()
	closePalette()
end)

ensureWindow = function()
	if windowOpen then
		return
	end
	windowOpen = true
	window.Visible = true
	window.Position = UDim2.new(0.5, 0, 0.5, 12)
	tween(window, 0.26, {
		GroupTransparency = shownTransparency(),
		Position = UDim2.fromScale(0.5, 0.5),
	})
end

toggleWindow = function()
	if not bootDone then
		return
	end
	if windowOpen then
		windowOpen = false
		local fade = tween(window, 0.18, { GroupTransparency = 1 })
		fade.Completed:Connect(function()
			if not windowOpen and window.Parent then
				window.Visible = false
			end
		end)
	else
		ensureWindow()
	end
end

navigate = function(page, tab, force)
	if page == "Universal" then
		tab = tab or currentTab or "Camera"
	else
		tab = nil
	end
	if not force and page == currentPage and tab == currentTab then
		refreshNav()
		layoutBody()
		refreshHeader()
		return
	end
	navToken += 1
	local token = navToken
	ensureWindow()
	local fade = tween(content, 0.12, { GroupTransparency = 1 })
	pcall(function()
		fade.Completed:Wait()
	end)
	if token ~= navToken or not alive then
		return
	end
	currentPage = page
	if tab then
		currentTab = tab
	end
	closeDropdown()
	refreshHeader()
	refreshNav()
	layoutBody()
	local ok, err = xpcall(function()
		renderPage()
	end, debug.traceback)
	if not ok then
		warn("[VEXORA] Page failed: " .. tostring(err))
		notify("That page hit an error. The details are in the output.", "error")
	end
	tween(content, 0.18, { GroupTransparency = 0 })
end

useFeature = function(id)
	local def = features[id]
	if not def then
		notify("That feature is missing.", "error")
		return
	end
	pushRecent(id)
	closePalette()
	if def.opens == false then
		def.run()
		return
	end
	ensureWindow()
	def.run()
end

local function presetNames()
	local list = {}
	for name in pairs(G.presets) do
		table.insert(list, name)
	end
	table.sort(list)
	return list
end

local function applyCrosshairPreset(preset, label)
	P.crosshair = deepCopy(preset)
	applyCrosshair()
	requestSave()
	notify(label .. " crosshair applied on your screen.", "success")
end

local BUILTIN_PRESETS = {
	Precise = { enabled = true, style = "Cross", size = 6, thickness = 1, gap = 3, opacity = 1, color = "White" },
	Dot = { enabled = true, style = "Dot", size = 4, thickness = 2, gap = 0, opacity = 1, color = "White" },
	Open = { enabled = true, style = "Cross", size = 12, thickness = 2, gap = 7, opacity = 1, color = "Cyan" },
	Minimal = { enabled = true, style = "Minimal", size = 6, thickness = 1, gap = 2, opacity = 0.9, color = "White" },
}

local function savePreset()
	promptBox("Save crosshair preset", "Name", function(name)
		if #name > 24 then
			notify("Use 24 characters or fewer.", "warning")
			return
		end
		G.presets[name] = deepCopy(P.crosshair)
		requestSave()
		notify("Preset \"" .. name .. "\" saved for this session" .. (storageMode == "file" and " and file." or "."), "success")
		if currentPage == "Universal" and currentTab == "Crosshair" then
			renderPage()
		end
	end)
end

local function renderHome()
	local profile = make("Frame", {
		LayoutOrder = lay(scroll),
		BackgroundColor3 = C.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 108),
	}, scroll)
	corner(profile, 12)
	stroke(profile, 0.5)
	local avatar = make("ImageLabel", {
		Position = UDim2.fromOffset(14, 22),
		Size = UDim2.fromOffset(64, 64),
		BackgroundColor3 = C.hover,
		BorderSizePixel = 0,
	}, profile)
	corner(avatar, 12)
	task.spawn(function()
		local ok, image = pcall(function()
			return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)
		if ok and avatar.Parent and type(image) == "string" then
			avatar.Image = image
		end
	end)
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(94, 16),
		Size = UDim2.new(1, -110, 0, 22),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.white,
		Text = player.DisplayName,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, profile)
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(94, 38),
		Size = UDim2.new(1, -110, 0, 16),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.muted,
		Text = "@" .. player.Name,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, profile)
	local experience = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(94, 58),
		Size = UDim2.new(1, -110, 0, 16),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.muted,
		Text = "Experience    " .. experienceName,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, profile)
	watch("experience", experience)
	local sessionLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(94, 76),
		Size = UDim2.new(1, -110, 0, 16),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.white,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "",
	}, profile)
	local function profileLine()
		local selected = gameById(selectedId)
		return (selected and selected.name or "No profile") .. "    ·    Session " .. formatTime(os.clock() - sessionStart)
	end
	sessionLabel.Text = profileLine()
	watch("profileLine", sessionLabel)

	local columns = make("Frame", {
		LayoutOrder = lay(scroll),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 360),
	}, scroll)
	local function column(x, width)
		local frame = make("Frame", {
			Position = UDim2.new(x, x == 0 and 0 or 4, 0, 0),
			Size = UDim2.new(width, x == 0 and -4 or -4, 1, 0),
			BackgroundColor3 = C.card,
			BorderSizePixel = 0,
		}, columns)
		corner(frame, 12)
		stroke(frame, 0.5)
		make("UIPadding", {
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}, frame)
		make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, frame)
		frame:SetAttribute("Lay", 0)
		return frame
	end
	local server = column(0, 0.5)
	local environment = column(0.5, 0.5)
	textLabel(server, "Server", 15, C.white, true, 20)
	textLabel(server, "This server, not your session clock", 11, C.muted, false, 16)
	stat(server, string.format("Players    %d / %d", #Players:GetPlayers(), Players.MaxPlayers), "players")
	stat(server, "Place ID    " .. tostring(game.PlaceId), nil)
	stat(server, game.JobId == "" and "Job ID    Empty in this session" or ("Job ID    " .. string.sub(game.JobId, 1, 16)), "job")
	stat(server, fpsValue and string.format("FPS    %d", math.floor(fpsValue + 0.5)) or "FPS    …", "fps")
	stat(server, pingText(), "ping")
	stat(server, "Session    " .. formatTime(os.clock() - sessionStart), "session")
	textLabel(server, "Server uptime    Not available on the client", 12, C.muted, false, 18)
	button(server, "Copy place ID", function()
		copyText(game.PlaceId, "place ID")
	end)
	button(server, "Copy job ID", function()
		if game.JobId == "" then
			notify("This session has no Job ID to copy.", "warning")
			return
		end
		copyText(game.JobId, "job ID")
	end)

	textLabel(environment, "Environment", 15, C.white, true, 20)
	textLabel(environment, "This client", 11, C.muted, false, 16)
	stat(environment, "Platform    " .. platformText(), nil)
	stat(environment, "Input    " .. tostring(lastInput.Name), "input")
	stat(environment, "Resolution    " .. resolutionText(), "res")
	stat(environment, "Field of view    " .. fovText(), "fov")
	stat(environment, memoryText(), "mem")
	stat(environment, "Graphics    " .. graphicsText(), "graphics")
	stat(environment, "Clipboard    " .. (typeof(setclipboard) == "function" and "Write available" or "Manual copy"), nil)
	stat(environment, "Storage    " .. (storageMode == "file" and "Local file" or "This session"), "storage")
	stat(environment, "Menu    Ready", nil)

	local actions = make("Frame", {
		LayoutOrder = lay(scroll),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 80),
	}, scroll)
	local actionGrid = make("UIGridLayout", {
		CellPadding = UDim2.fromOffset(8, 8),
		CellSize = UDim2.new(0.333, -8, 0, 36),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, actions)
	local actionList = {
		{ "Change profile", "choose-profile" },
		{ "Universal tools", "open-universal" },
		{ "Toggle HUD", "toggle-hud" },
		{ "Settings", "open-settings" },
		{ "Reset position", "reset-position" },
		{ "Minimise", "minimise" },
	}
	for index, item in ipairs(actionList) do
		button(actions, item[1], function()
			useFeature(item[2])
		end, {
			order = index,
			size = UDim2.fromScale(1, 1),
		})
	end
	actionGrid.Parent = actions

	local favouriteCard = stack(scroll, 4)
	textLabel(favouriteCard, "Favourites", 15, C.white, true, 20)
	local anyFavourite = false
	for _, id in ipairs(featureOrder) do
		if G.favorites[id] and features[id] then
			anyFavourite = true
			button(favouriteCard, features[id].name, function()
				useFeature(id)
			end)
		end
	end
	if not anyFavourite then
		note(favouriteCard, "Star a tool and it will show up here.")
	end
end

local function renderGames()
	textLabel(scroll, "Which game would you like to use VEXORA with?", 20, C.white, true, 28)
	note(scroll, "You are in " .. experienceName .. ". Pick a profile. A profile only changes this menu and your local client settings.")
	local row = nil
	for index, entry in ipairs(GAMES) do
		if (index - 1) % 2 == 0 then
			row = make("Frame", {
				LayoutOrder = lay(scroll),
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 292),
			}, scroll)
		end
		local column = (index - 1) % 2
		local card = make("Frame", {
			Position = UDim2.new(column * 0.5, column == 0 and 0 or 4, 0, 0),
			Size = UDim2.new(0.5, -4, 1, 0),
			BackgroundColor3 = C.card,
			BorderSizePixel = 0,
		}, row)
		corner(card, 12)
		local outline = stroke(card, selectedId == entry.id and 0 or 0.45, selectedId == entry.id and accentColor() or C.border)
		if selectedId == entry.id then
			trackAccent(outline, "Color")
		end
		card.MouseEnter:Connect(function()
			tween(card, 0.14, { BackgroundColor3 = C.hover })
		end)
		card.MouseLeave:Connect(function()
			tween(card, 0.14, { BackgroundColor3 = C.card })
		end)
		local shot = make("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.new(1, -24, 0, 140),
			BackgroundColor3 = C.hover,
			BorderSizePixel = 0,
			ClipsDescendants = true,
		}, card)
		corner(shot, 10)
		local mark = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 42,
			TextColor3 = C.white,
			Text = "V",
		}, shot)
		if entry.universeId then
			local image = make("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ScaleType = Enum.ScaleType.Crop,
				BorderSizePixel = 0,
				ZIndex = 2,
				Image = "rbxthumb://type=GameThumbnail&id=" .. tostring(entry.universeId) .. "&w=768&h=432",
			}, shot)
			local badgeIcon = make("ImageLabel", {
				BackgroundColor3 = C.panel,
				Position = UDim2.new(0, 8, 1, -36),
				Size = UDim2.fromOffset(28, 28),
				ScaleType = Enum.ScaleType.Crop,
				ZIndex = 3,
				Image = "rbxthumb://type=GameIcon&id=" .. tostring(entry.universeId) .. "&w=150&h=150",
			}, shot)
			corner(badgeIcon, 8)
			image.Parent = shot
			mark.ZIndex = 1
		else
			for gx = 0, 8 do
				make("Frame", {
					Position = UDim2.new(gx / 8, 0, 0, 0),
					Size = UDim2.new(0, 1, 1, 0),
					BackgroundColor3 = C.white,
					BackgroundTransparency = 0.9,
					BorderSizePixel = 0,
				}, shot)
			end
			mark.Text = "V"
		end
		if entry.id == "urban" and inUrban() then
			local badge = make("TextLabel", {
				Position = UDim2.fromOffset(8, 8),
				Size = UDim2.fromOffset(108, 20),
				BackgroundColor3 = C.bg,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = C.green,
				Text = "Recommended",
				ZIndex = 4,
				BorderSizePixel = 0,
			}, shot)
			corner(badge, 6)
		end
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 160),
			Size = UDim2.new(1, -24, 0, 22),
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.white,
			Text = entry.name,
		}, card)
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 184),
			Size = UDim2.new(1, -24, 0, 32),
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = C.muted,
			Text = entry.blurb,
		}, card)
		local statusText = "Ready in this experience"
		local statusColor = C.cyan
		if entry.placeId then
			if game.PlaceId == entry.placeId then
				statusText = "In this game"
				statusColor = C.green
			else
				statusText = "Not in this game · local profile only"
				statusColor = C.muted
			end
		end
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 218),
			Size = UDim2.new(1, -24, 0, 16),
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = statusColor,
			Text = statusText,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, card)
		button(card, selectedId == entry.id and "Selected" or "Use this profile", function()
			selectedId = entry.id
			G.perGame[tostring(game.PlaceId)] = entry.id
			requestSave()
			notify(entry.name .. " is the active profile.", "success")
			navigate("Home", nil, true)
		end, {
			primary = true,
			position = UDim2.fromOffset(12, 244),
			size = UDim2.new(1, -24, 0, 32),
		})
	end
end

local function renderCamera()
	textLabel(scroll, "Camera", 20, C.white, true, 26)
	note(scroll, "These change your camera only. The game can set its own field of view again afterwards.")
	local card = stack(scroll, 8)
	local currentFov = P.fov or (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or originalFOV
	slider(card, "Field of view", 50, 110, currentFov, 1, "fov", function(value, final)
		P.fov = value
		applyFov(final and P.smoothFov)
		requestSave()
	end)
	toggle(card, "Smooth field-of-view changes", P.smoothFov, "smooth-fov", function(on)
		P.smoothFov = on
		requestSave()
	end)
	textLabel(card, "Camera type    " .. tostring(workspace.CurrentCamera and workspace.CurrentCamera.CameraType.Name or "Unavailable"), 13, C.white, false, 18)
	note(card, "Camera type stays with the game. VEXORA does not take over the camera.")
	button(card, "Restore original field of view", function()
		useFeature("fov-reset")
	end)
end

local function renderInterface()
	textLabel(scroll, "Interface", 20, C.white, true, 26)
	note(scroll, "Appearance of this menu. Reduced motion turns off the travelling pulses and shortens transitions.")
	local card = stack(scroll, 8)
	slider(card, "UI scale", 0.85, 1.15, P.uiScale, 0.01, "ui-scale", function(value)
		P.uiScale = value
		applyChrome()
		requestSave()
	end)
	slider(card, "Opacity", 0.7, 1, P.opacity, 0.01, "opacity", function(value)
		P.opacity = value
		applyChrome()
		requestSave()
	end)
	slider(card, "Animation intensity", 0.6, 1.4, P.anim, 0.05, "anim", function(value)
		P.anim = value
		requestSave()
	end)
	dropdown(card, "Accent", { "Cyan", "Violet", "Green", "White" }, P.accent, function(choice)
		P.accent = choice
		applyAccent()
		refreshNav()
		requestSave()
		renderPage()
	end)
	toggle(card, "Grid background", P.grid, "grid", function(on)
		P.grid = on
		applyChrome()
		requestSave()
	end)
	toggle(card, "RGB pulses", P.pulses, "pulses", function(on)
		P.pulses = on
		applyChrome()
		requestSave()
	end)
	toggle(card, "Reduced motion", P.reducedMotion, "motion", function(on)
		P.reducedMotion = on
		applyChrome()
		requestSave()
	end)
	toggle(card, "Notifications", P.notifications, "notifications", function(on)
		P.notifications = on
		requestSave()
		if on then
			notify("Notifications are on.", "info")
		end
	end)
	toggle(card, "Sidebar", G.sidebar, nil, function(on)
		G.sidebar = on
		if not G.sidebar and not G.dock then
			G.dock = true
			notify("The dock stays on so navigation is still reachable.", "warning")
		end
		applyChrome()
		requestSave()
		renderPage()
	end)
	toggle(card, "Bottom dock", G.dock, nil, function(on)
		G.dock = on
		if not G.sidebar and not G.dock then
			G.sidebar = true
			notify("The sidebar stays on so navigation is still reachable.", "warning")
		end
		applyChrome()
		requestSave()
		renderPage()
	end)
	toggle(card, "Performance HUD", P.hud.visible, "toggle-hud", function(on)
		P.hud.visible = on
		applyHud()
		requestSave()
	end)
	button(card, "Reset HUD position", function()
		useFeature("reset-hud")
	end)
	button(card, "Reset menu position", function()
		useFeature("reset-position")
	end)
end

local function renderCrosshair()
	textLabel(scroll, "Crosshair", 20, C.white, true, 26)
	note(scroll, "Drawn on your screen only. It does not aim, shoot, or read other players.")
	local card = stack(scroll, 8)
	toggle(card, "Show crosshair", P.crosshair.enabled, "crosshair", function(on)
		P.crosshair.enabled = on
		applyCrosshair()
		requestSave()
	end)
	dropdown(card, "Style", { "Cross", "Dot", "Circle", "Minimal" }, P.crosshair.style, function(choice)
		P.crosshair.style = choice
		P.crosshair.enabled = true
		applyCrosshair()
		requestSave()
		renderPage()
	end)
	dropdown(card, "Colour", COLOR_CHOICES, P.crosshair.color, function(choice)
		P.crosshair.color = choice
		applyCrosshair()
		requestSave()
	end)
	slider(card, "Size", 2, 18, P.crosshair.size, 1, nil, function(value)
		P.crosshair.size = value
		P.crosshair.enabled = true
		applyCrosshair()
		requestSave()
	end)
	slider(card, "Thickness", 1, 6, P.crosshair.thickness, 1, nil, function(value)
		P.crosshair.thickness = value
		applyCrosshair()
		requestSave()
	end)
	slider(card, "Gap", 0, 16, P.crosshair.gap, 1, nil, function(value)
		P.crosshair.gap = value
		applyCrosshair()
		requestSave()
	end)
	slider(card, "Opacity", 0.25, 1, P.crosshair.opacity, 0.05, nil, function(value)
		P.crosshair.opacity = value
		applyCrosshair()
		requestSave()
	end)
	for _, name in ipairs({ "Precise", "Dot", "Open", "Minimal" }) do
		button(card, name .. " preset", function()
			applyCrosshairPreset(BUILTIN_PRESETS[name], name)
			renderPage()
		end)
	end
	local saved = presetNames()
	if #saved > 0 then
		dropdown(card, "Saved presets", saved, saved[1], function(choice)
			if G.presets[choice] then
				applyCrosshairPreset(G.presets[choice], choice)
				renderPage()
			end
		end)
	end
	button(card, "Save preset", function()
		savePreset()
	end, { primary = true })
	button(card, "Reset crosshair", function()
		P.crosshair = defaultProfile().crosshair
		applyCrosshair()
		requestSave()
		notify("Crosshair reset.", "info")
		renderPage()
	end)
end

local function renderPerformance()
	textLabel(scroll, "Performance", 20, C.white, true, 26)
	note(scroll, "Readings come from this client. Low graphics changes only your quality setting and can be turned back off.")
	local card = stack(scroll, 6)
	stat(card, fpsValue and string.format("FPS    %d", math.floor(fpsValue + 0.5)) or "FPS    …", "fps")
	stat(card, pingText(), "ping")
	stat(card, "Session    " .. formatTime(os.clock() - sessionStart), "session")
	stat(card, memoryText(), "mem")
	textLabel(card, "FPS history", 13, C.white, true, 18)
	local chart = make("Frame", {
		LayoutOrder = lay(card),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 72),
	}, card)
	chartBars = {}
	local chartLayout = make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 3),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, chart)
	for index = 1, 28 do
		local slot = make("Frame", {
			LayoutOrder = index,
			BackgroundTransparency = 1,
			Size = UDim2.new(1 / 28, -3, 1, 0),
		}, chart)
		local bar = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.new(1, 0, 0.08, 0),
			BackgroundColor3 = C.white,
			BorderSizePixel = 0,
		}, slot)
		corner(bar, 2)
		chartBars[index] = bar
	end
	chartLayout.Parent = chart
	if graphicsAvailable then
		toggle(card, "Low graphics", P.lowGraphics, "low-graphics", function(on)
			local ok = setLowGraphics(on)
			if ok == false then
				return false
			end
			requestSave()
			notify(on and "Graphics quality lowered on this client." or "Previous graphics quality restored.", "info")
		end)
		note(card, "This sets your saved graphics quality to the lowest level, then restores the previous level when you turn it off.")
	else
		note(card, "Graphics quality can't be changed from this client, so the low-graphics control is hidden.")
	end
	toggle(card, "Show the HUD", P.hud.visible, nil, function(on)
		P.hud.visible = on
		applyHud()
		requestSave()
	end)
end

local function renderPlayers()
	textLabel(scroll, "Players", 20, C.white, true, 26)
	note(scroll, "People in this server. Friend status uses Roblox's friend check and can be unavailable.")
	local controls = fixedRow(scroll, 36)
	controls.BackgroundTransparency = 1
	local filter = make("TextBox", {
		Size = UDim2.new(1, -44, 1, 0),
		BackgroundColor3 = C.card,
		Text = "",
		PlaceholderText = "Search players",
		PlaceholderColor3 = C.muted,
		TextColor3 = C.white,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		ClearTextOnFocus = false,
		BorderSizePixel = 0,
	}, controls)
	corner(filter, 8)
	local refresh = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = C.card,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, controls)
	corner(refresh, 8)
	icon(refresh, "refresh", 16, C.white)
	local list = make("ScrollingFrame", {
		LayoutOrder = lay(scroll),
		BackgroundColor3 = C.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 220),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = C.border,
		ElasticBehavior = Enum.ElasticBehavior.Never,
	}, scroll)
	corner(list, 12)
	local detail = stack(scroll, 4)
	local selectedUser = player.UserId
	local detailName = textLabel(detail, "", 16, C.white, true, 22)
	local detailUser = textLabel(detail, "", 12, C.muted, false, 16)
	local detailId = textLabel(detail, "", 12, C.muted, false, 16)
	local detailFriend = textLabel(detail, "", 12, C.white, false, 16)
	local function showDetail(target)
		selectedUser = target.UserId
		detailName.Text = target.DisplayName
		detailUser.Text = "@" .. target.Name
		detailId.Text = "User ID    " .. tostring(target.UserId)
		if target.UserId == player.UserId then
			detailFriend.Text = "This is you"
			return
		end
		detailFriend.Text = "Friend status    Checking"
		task.spawn(function()
			local ok, isFriend = pcall(function()
				return player:IsFriendsWith(target.UserId)
			end)
			if not detailFriend.Parent or selectedUser ~= target.UserId then
				return
			end
			if ok then
				detailFriend.Text = isFriend and "Friends" or "Not friends"
			else
				detailFriend.Text = "Friend status unavailable"
			end
		end)
	end
	button(detail, "Copy username", function()
		local target = Players:GetPlayerByUserId(selectedUser)
		if target then
			copyText(target.Name, "username")
		else
			notify("That player left the server.", "warning")
		end
	end)
	button(detail, "Copy user ID", function()
		copyText(selectedUser, "user ID")
	end)
	local function buildList()
		for _, child in ipairs(list:GetChildren()) do
			child:Destroy()
		end
		make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, list)
		make("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, list)
		local query = string.lower(filter.Text)
		local shown = 0
		local people = Players:GetPlayers()
		table.sort(people, function(a, b)
			return string.lower(a.DisplayName) < string.lower(b.DisplayName)
		end)
		for _, other in ipairs(people) do
			local haystack = string.lower(other.DisplayName .. " " .. other.Name .. " " .. tostring(other.UserId))
			if query == "" or string.find(haystack, query, 1, true) then
				shown += 1
				local row = make("TextButton", {
					LayoutOrder = shown,
					Size = UDim2.new(1, 0, 0, 48),
					BackgroundColor3 = other.UserId == selectedUser and C.hover or C.panel,
					Text = "",
					AutoButtonColor = false,
					BorderSizePixel = 0,
				}, list)
				corner(row, 8)
				local photo = make("ImageLabel", {
					Position = UDim2.fromOffset(8, 8),
					Size = UDim2.fromOffset(32, 32),
					BackgroundColor3 = C.hover,
					BorderSizePixel = 0,
				}, row)
				corner(photo, 8)
				task.spawn(function()
					local ok, image = pcall(function()
						return Players:GetUserThumbnailAsync(other.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
					end)
					if ok and photo.Parent and type(image) == "string" then
						photo.Image = image
					end
				end)
				make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(48, 6),
					Size = UDim2.new(1, -56, 0, 18),
					Font = Enum.Font.GothamBold,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = C.white,
					Text = other.DisplayName,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}, row)
				make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(48, 24),
					Size = UDim2.new(1, -56, 0, 16),
					Font = Enum.Font.Gotham,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = C.muted,
					Text = "@" .. other.Name,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}, row)
				row.Activated:Connect(function()
					showDetail(other)
					buildList()
				end)
			end
		end
		if shown == 0 then
			make("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 36),
				Text = "No players match that search.",
				TextColor3 = C.muted,
				Font = Enum.Font.Gotham,
				TextSize = 13,
			}, list)
		end
	end
	filter:GetPropertyChangedSignal("Text"):Connect(buildList)
	refresh.Activated:Connect(buildList)
	onPlayersChanged = buildList
	trackPage(Players.PlayerAdded:Connect(function()
		if onPlayersChanged then
			onPlayersChanged()
		end
	end))
	trackPage(Players.PlayerRemoving:Connect(function(leaving)
		if leaving.UserId == selectedUser then
			selectedUser = player.UserId
			showDetail(player)
		end
		if onPlayersChanged then
			onPlayersChanged()
		end
	end))
	showDetail(player)
	buildList()
end

local function renderUtilities()
	textLabel(scroll, "Utilities", 20, C.white, true, 26)
	note(scroll, storageNote)
	local card = stack(scroll, 6)
	button(card, "Copy place ID", function()
		copyText(game.PlaceId, "place ID")
	end)
	button(card, "Copy job ID", function()
		if game.JobId == "" then
			notify("This session has no Job ID.", "warning")
			return
		end
		copyText(game.JobId, "job ID")
	end)
	button(card, "Export settings", function()
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode({ version = 5, global = G })
		end)
		if not ok then
			notify("Settings could not be encoded.", "error")
			warn("[VEXORA] Export failed: " .. tostring(encoded))
			return
		end
		openModal({
			title = "Export settings",
			body = "This text is the full settings file. Copy it if you want a backup.",
			text = encoded,
			buttons = {
				{ text = "Close" },
				{ text = "Copy", primary = true, action = function(value)
					copyText(value, "settings")
				end },
			},
		})
	end, { primary = true })
	button(card, "Import settings", function()
		openModal({
			title = "Import settings",
			body = "Paste a VEXORA 5 export. Invalid text is rejected.",
			placeholder = "{ \"version\": 5 }",
			editable = true,
			text = "",
			buttons = {
				{ text = "Cancel" },
				{ text = "Import", primary = true, action = function(value)
					local ok, data = pcall(function()
						return HttpService:JSONDecode(value)
					end)
					if not ok or type(data) ~= "table" or data.version ~= 5 or type(data.global) ~= "table" then
						notify("That text isn't a VEXORA 5 settings file.", "error")
						return
					end
					if P.lowGraphics then
						setLowGraphics(false)
					end
					G = sanitizeGlobal(data.global)
					P = G.profiles[G.activeProfile]
					applyAll()
					requestSave()
					notify("Settings imported.", "success")
					renderPage()
					refreshNav()
				end },
			},
		})
	end)
	textLabel(card, "Toggle menu    " .. G.binds.toggle, 13, C.white, false, 18)
	textLabel(card, "Command palette    Ctrl + " .. G.binds.palette, 13, C.white, false, 18)
	button(card, "Change menu key", function()
		capturing = "toggle"
		notify("Press a key for the menu toggle.", "info")
	end)
	button(card, "Change palette key", function()
		capturing = "palette"
		notify("Press a key for the command palette.", "info")
	end)
	button(card, "Reset all settings", function()
		confirm("Reset everything?", "Clears profiles, shortcuts, favourites, and local menu settings.", function()
			if P.lowGraphics then
				setLowGraphics(false)
			end
			G = defaultGlobal()
			P = G.profiles.Default
			selectedId = nil
			applyAll()
			local camera = workspace.CurrentCamera
			if camera then
				camera.FieldOfView = originalFOV
			end
			requestSave()
			notify("Settings reset for this session.", "success")
			navigate("Games", nil, true)
		end)
	end)
	textLabel(card, "Notification history", 15, C.white, true, 22)
	if #history == 0 then
		note(card, "No notifications yet.")
	else
		for index = 1, math.min(8, #history) do
			textLabel(card, history[index].text, 12, C.muted, false, 18)
		end
	end
	textLabel(card, "Recently used", 15, C.white, true, 22)
	if #G.recents == 0 then
		note(card, "Tools you open from search will show up here.")
	else
		for _, id in ipairs(G.recents) do
			local def = features[id]
			if def then
				button(card, def.name, function()
					useFeature(id)
				end)
			end
		end
	end
end

local function renderUniversal()
	if currentTab == "Camera" then
		renderCamera()
	elseif currentTab == "Interface" then
		renderInterface()
	elseif currentTab == "Crosshair" then
		renderCrosshair()
	elseif currentTab == "Performance" then
		renderPerformance()
	elseif currentTab == "Players" then
		renderPlayers()
	else
		renderUtilities()
	end
end

local function renderUrban()
	local entry = gameById("urban")
	local banner = make("Frame", {
		LayoutOrder = lay(scroll),
		BackgroundColor3 = C.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 176),
		ClipsDescendants = true,
	}, scroll)
	corner(banner, 12)
	stroke(banner, 0.45)
	make("ImageLabel", {
		BackgroundColor3 = C.hover,
		Size = UDim2.fromScale(1, 1),
		ScaleType = Enum.ScaleType.Crop,
		BorderSizePixel = 0,
		Image = "rbxthumb://type=GameThumbnail&id=" .. tostring(entry.universeId) .. "&w=768&h=432",
	}, banner)
	local scrim = make("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 78),
		BackgroundColor3 = C.bg,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, banner)
	make("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0.15),
		}),
	}, scrim)
	make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 14, 1, -30),
		Size = UDim2.new(1, -28, 0, 24),
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.white,
		Text = entry.name,
		ZIndex = 3,
	}, banner)
	make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 14, 1, -10),
		Size = UDim2.new(1, -28, 0, 16),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = inUrban() and C.green or C.muted,
		Text = inUrban() and "In this game" or "Not in this game",
		ZIndex = 3,
	}, banner)

	local info = stack(scroll, 4)
	textLabel(info, "Session", 15, C.white, true, 20)
	note(info, inUrban() and "You are in Urban Reload. The tools below are still local: crosshair, camera, and the HUD." or "You are not in Urban Reload. These controls still edit your local crosshair, camera, and HUD, and they do not change that game.")
	textLabel(info, "Place ID    " .. tostring(entry.placeId), 13, C.white, false, 18)
	textLabel(info, "Universe ID    " .. tostring(entry.universeId), 13, C.white, false, 18)
	textLabel(info, "Experience    " .. experienceName, 13, C.muted, false, 18)
	button(info, "Copy game link", function()
		copyText(entry.link, "game link")
	end)

	local aim = stack(scroll, 6)
	textLabel(aim, "Crosshair presets", 15, C.white, true, 20)
	note(aim, "Screen drawings only. They do not change weapons, hit detection, or other players.")
	for _, name in ipairs({ "Precise", "Dot", "Open", "Minimal" }) do
		button(aim, name, function()
			applyCrosshairPreset(BUILTIN_PRESETS[name], name)
		end)
	end
	button(aim, "Open full crosshair settings", function()
		navigate("Universal", "Crosshair", true)
	end, { primary = true })

	local overlay = stack(scroll, 6)
	textLabel(overlay, "Overlay", 15, C.white, true, 20)
	toggle(overlay, "FPS, ping, and session HUD", P.hud.visible, nil, function(on)
		P.hud.visible = on
		applyHud()
		requestSave()
	end)
	stat(overlay, "Session    " .. formatTime(os.clock() - sessionStart), "session")
	stat(overlay, fpsValue and string.format("FPS    %d", math.floor(fpsValue + 0.5)) or "FPS    …", "fps")
	stat(overlay, pingText(), "ping")

	local cameraCard = stack(scroll, 6)
	textLabel(cameraCard, "Camera", 15, C.white, true, 20)
	local currentFov = P.fov or (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or originalFOV
	slider(cameraCard, "Field of view", 50, 110, currentFov, 1, nil, function(value, final)
		P.fov = value
		applyFov(final and P.smoothFov)
		requestSave()
	end)
	button(cameraCard, "Open camera tools", function()
		navigate("Universal", "Camera", true)
	end)

	local favouriteCard = stack(scroll, 4)
	textLabel(favouriteCard, "Favourites", 15, C.white, true, 20)
	local anyFavourite = false
	for _, id in ipairs(featureOrder) do
		if G.favorites[id] and features[id] then
			anyFavourite = true
			button(favouriteCard, features[id].name, function()
				useFeature(id)
			end)
		end
	end
	if not anyFavourite then
		note(favouriteCard, "Star a tool from Universal and it will be listed here.")
	end
end

local function renderSettings()
	textLabel(scroll, "Settings", 20, C.white, true, 26)
	note(scroll, storageNote)
	local card = stack(scroll, 6)
	textLabel(card, "Profile    " .. G.activeProfile, 14, C.white, true, 20)
	local names = {}
	for name in pairs(G.profiles) do
		table.insert(names, name)
	end
	table.sort(names)
	dropdown(card, "Active profile", names, G.activeProfile, function(choice)
		if G.profiles[choice] then
			G.activeProfile = choice
			P = G.profiles[choice]
			applyAll()
			requestSave()
			notify("Using profile " .. choice .. ".", "success")
			renderPage()
		end
	end)
	button(card, "New profile from current", function()
		promptBox("New profile", "Name", function(name)
			if G.profiles[name] then
				notify("That profile name already exists.", "warning")
				return
			end
			if #name > 24 then
				notify("Use 24 characters or fewer.", "warning")
				return
			end
			G.profiles[name] = deepCopy(P)
			G.activeProfile = name
			P = G.profiles[name]
			requestSave()
			notify("Profile " .. name .. " is active.", "success")
			renderPage()
		end)
	end, { primary = true })
	button(card, "Delete active profile", function()
		if G.activeProfile == "Default" then
			notify("The Default profile stays so there is always one to use.", "warning")
			return
		end
		local name = G.activeProfile
		confirm("Delete " .. name .. "?", "The Default profile becomes active.", function()
			G.profiles[name] = nil
			G.activeProfile = "Default"
			if not G.profiles.Default then
				G.profiles.Default = defaultProfile()
			end
			P = G.profiles.Default
			applyAll()
			requestSave()
			notify("Deleted " .. name .. ".", "info")
			renderPage()
		end)
	end)
	button(card, "Reset active profile", function()
		confirm("Reset " .. G.activeProfile .. "?", "Restores this profile's menu settings. Favourites and other profiles stay.", function()
			if P.lowGraphics then
				setLowGraphics(false)
			end
			local fresh = defaultProfile()
			G.profiles[G.activeProfile] = fresh
			P = fresh
			applyAll()
			local camera = workspace.CurrentCamera
			if camera then
				camera.FieldOfView = originalFOV
			end
			requestSave()
			notify("Profile reset.", "success")
			renderPage()
		end)
	end)
	button(card, "Appearance and navigation", function()
		navigate("Universal", "Interface", true)
	end)
	textLabel(card, "About", 15, C.white, true, 22)
	note(card, "VEXORA 5.0 is a local client menu. It does not change other players, server gameplay, or Roblox protection systems.")
	local storageLabel = textLabel(card, storageNote, 12, C.muted, false, 48)
	storageLabel.TextWrapped = true
	storageLabel.TextTruncate = Enum.TextTruncate.None
	storageLabel.TextYAlignment = Enum.TextYAlignment.Top
end

renderPage = function()
	clearScroll()
	if currentPage == "Home" then
		renderHome()
	elseif currentPage == "Games" then
		renderGames()
	elseif currentPage == "Universal" then
		renderUniversal()
	elseif currentPage == "Urban" then
		renderUrban()
	elseif currentPage == "Settings" then
		renderSettings()
	end
end

local function registerFeatures()
	feature({ id = "choose-profile", name = "Change game profile", category = "Menu", icon = "gamepad", description = "Open the game picker.", run = function()
		navigate("Games", nil, true)
	end })
	feature({ id = "open-universal", name = "Universal tools", category = "Menu", icon = "sliders", description = "Camera, HUD, crosshair, players, and utilities.", run = function()
		navigate("Universal", "Camera", true)
	end })
	feature({ id = "open-settings", name = "Open settings", category = "Menu", icon = "settings", description = "Profiles, reset, and storage.", run = function()
		navigate("Settings", nil, true)
	end })
	feature({ id = "toggle-hud", name = "Toggle HUD", category = "Interface", icon = "monitor", description = "Show or hide FPS, ping, and the session timer.", run = function()
		P.hud.visible = not P.hud.visible
		applyHud()
		requestSave()
		notify(P.hud.visible and "HUD on." or "HUD off.", "info")
	end })
	feature({ id = "reset-position", name = "Reset menu position", category = "Interface", icon = "refresh", description = "Center the window.", run = function()
		window.Position = UDim2.fromScale(0.5, 0.5)
		notify("Menu centered.", "info")
	end })
	feature({ id = "reset-hud", name = "Reset HUD position", category = "Interface", icon = "monitor", description = "Move the HUD back to the top left.", run = function()
		P.hud.x = 16
		P.hud.y = 16
		applyHud()
		requestSave()
		notify("HUD moved to the top left.", "info")
	end })
	feature({ id = "minimise", name = "Minimise menu", category = "Menu", icon = "minus", description = "Hide the window. Right Shift opens it again.", opens = false, run = function()
		if windowOpen then
			toggleWindow()
		end
	end })
	feature({ id = "fov", name = "Field of view", category = "Camera", icon = "camera", description = "Set your local camera field of view.", run = function()
		navigate("Universal", "Camera", true)
	end })
	feature({ id = "fov-reset", name = "Restore field of view", category = "Camera", icon = "camera", description = "Put the camera back to the field of view from when VEXORA started.", run = function()
		local camera = workspace.CurrentCamera
		if camera then
			camera.FieldOfView = originalFOV
		end
		P.fov = originalFOV
		requestSave()
		notify("Field of view restored.", "success")
		if currentPage == "Universal" and currentTab == "Camera" then
			renderPage()
		end
	end })
	feature({ id = "smooth-fov", name = "Smooth field of view", category = "Camera", icon = "camera", description = "Ease field-of-view changes.", run = function()
		navigate("Universal", "Camera", true)
	end })
	feature({ id = "ui-scale", name = "UI scale", category = "Interface", icon = "sliders", description = "Scale the VEXORA window.", run = function()
		navigate("Universal", "Interface", true)
	end })
	feature({ id = "opacity", name = "Interface opacity", category = "Interface", icon = "sliders", description = "Fade the window.", run = function()
		navigate("Universal", "Interface", true)
	end })
	feature({ id = "grid", name = "Grid background", category = "Interface", icon = "sliders", description = "Show or hide the grid.", run = function()
		navigate("Universal", "Interface", true)
	end })
	feature({ id = "pulses", name = "RGB pulses", category = "Interface", icon = "sliders", description = "Travelling light on the grid.", run = function()
		navigate("Universal", "Interface", true)
	end })
	feature({ id = "motion", name = "Reduced motion", category = "Interface", icon = "sliders", description = "Shorten animation and stop pulses.", run = function()
		navigate("Universal", "Interface", true)
	end })
	feature({ id = "crosshair", name = "Crosshair", category = "Crosshair", icon = "camera", description = "Local crosshair shape, size, and colour.", run = function()
		navigate("Universal", "Crosshair", true)
	end })
	feature({ id = "players", name = "Player browser", category = "Players", icon = "users", description = "Search people in this server.", run = function()
		navigate("Universal", "Players", true)
	end })
	feature({ id = "low-graphics", name = "Low graphics", category = "Performance", icon = "monitor", description = "Lower your local graphics quality.", run = function()
		navigate("Universal", "Performance", true)
	end })
	feature({ id = "export", name = "Export settings", category = "Settings", icon = "save", description = "Copy settings as text.", run = function()
		navigate("Universal", "Utilities", true)
	end })
	feature({ id = "shortcuts", name = "Keyboard shortcuts", category = "Settings", icon = "keyboard", description = "View and change menu keys.", run = function()
		navigate("Universal", "Utilities", true)
	end })
end

local function makeNavButton(parent, item, dockButton)
	local buttonObj = make("TextButton", {
		Position = dockButton and UDim2.fromOffset((table.find(NAV, item) - 1) * 44, 0) or UDim2.fromOffset(15, 72 + (table.find(NAV, item) - 1) * 48),
		Size = dockButton and UDim2.fromOffset(40, 36) or UDim2.fromOffset(40, 40),
		BackgroundColor3 = dockButton and C.card or C.panel,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, parent)
	corner(buttonObj, 10)
	icon(buttonObj, item.icon, dockButton and 16 or 18, C.muted)
	if not dockButton then
		local mark = make("Frame", {
			Name = "Mark",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(2, 16),
			BackgroundColor3 = accentColor(),
			BorderSizePixel = 0,
			Visible = false,
		}, buttonObj)
		corner(mark, 2)
		trackAccent(mark, "BackgroundColor3")
	end
	bindHover(buttonObj, dockButton and C.card or C.panel, C.hover, C.bg)
	bindTip(buttonObj, item.tip)
	buttonObj.Activated:Connect(function()
		navigate(item.id)
	end)
	navButtons[item.id] = navButtons[item.id] or {}
	if dockButton then
		navButtons[item.id].dock = buttonObj
	else
		navButtons[item.id].side = buttonObj
	end
end

for _, item in ipairs(NAV) do
	makeNavButton(sidebar, item, false)
	makeNavButton(dockItems, item, true)
end

local TABS = {
	{ "Camera", "camera" },
	{ "Interface", "sliders" },
	{ "Crosshair", "camera" },
	{ "Performance", "monitor" },
	{ "Players", "users" },
	{ "Utilities", "keyboard" },
}
for index, tab in ipairs(TABS) do
	local tabButton = make("TextButton", {
		Name = tab[1],
		LayoutOrder = index,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 28),
		BackgroundColor3 = C.bg,
		Text = "   " .. tab[1] .. "   ",
		TextColor3 = C.muted,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, tabBar)
	corner(tabButton, 8)
	tabButton.Activated:Connect(function()
		navigate("Universal", tab[1], true)
	end)
end

searchButton.Activated:Connect(openPalette)
minButton.Activated:Connect(function()
	useFeature("minimise")
end)
closeButton.Activated:Connect(function()
	if windowOpen then
		toggleWindow()
	end
end)
bindTip(minButton, "Minimise")
bindTip(closeButton, "Close")
bindTip(searchButton, "Search")

header.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local localX = input.Position.X - header.AbsolutePosition.X
	if localX > header.AbsoluteSize.X - 280 then
		return
	end
	windowDrag = true
	dragStart = input.Position
	dragOrigin = window.Position
end)

hud.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	hudDrag = true
	dragStart = input.Position
	dragOrigin = hud.Position
end)

track(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	if hudDrag then
		hudDrag = false
		local camera = workspace.CurrentCamera
		local view = camera and camera.ViewportSize or Vector2.new(1280, 720)
		P.hud.x = math.clamp(hud.Position.X.Offset, 8, math.max(8, view.X - 184))
		P.hud.y = math.clamp(hud.Position.Y.Offset, 8, math.max(8, view.Y - 90))
		hud.Position = UDim2.fromOffset(P.hud.x, P.hud.y)
		requestSave()
	end
	windowDrag = false
end))

track(UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	if windowDrag and dragStart and dragOrigin then
		local delta = input.Position - dragStart
		window.Position = UDim2.new(dragOrigin.X.Scale, dragOrigin.X.Offset + delta.X, dragOrigin.Y.Scale, dragOrigin.Y.Offset + delta.Y)
	elseif hudDrag and dragStart and dragOrigin then
		local delta = input.Position - dragStart
		hud.Position = UDim2.fromOffset(dragOrigin.X.Offset + delta.X, dragOrigin.Y.Offset + delta.Y)
	end
end))

track(UserInputService.InputBegan:Connect(function(input, processed)
	if not alive then
		return
	end
	if capturing then
		if input.KeyCode == Enum.KeyCode.Escape then
			capturing = nil
			notify("Shortcut change cancelled.", "info")
			return
		end
		if input.KeyCode ~= Enum.KeyCode.Unknown and validKey(input.KeyCode.Name) then
			local which = capturing
			capturing = nil
			G.binds[which] = input.KeyCode.Name
			requestSave()
			notify("Shortcut set to " .. input.KeyCode.Name .. ".", "success")
			if currentPage == "Universal" and currentTab == "Utilities" then
				renderPage()
			end
		end
		return
	end
	if input.KeyCode == Enum.KeyCode.Escape then
		if suppressEscape or paletteOpen then
			return
		end
		local focused = UserInputService:GetFocusedTextBox()
		if focused then
			focused:ReleaseFocus()
			return
		end
		if modalOpen then
			closeModal()
			return
		end
		if dropdownPanel.Visible then
			closeDropdown()
			return
		end
		if windowOpen then
			toggleWindow()
		end
		return
	end
	local toggleKey = validKey(G.binds.toggle) and Enum.KeyCode[G.binds.toggle] or Enum.KeyCode.RightShift
	if input.KeyCode == toggleKey then
		toggleWindow()
		return
	end
	if processed then
		return
	end
	local paletteKey = validKey(G.binds.palette) and Enum.KeyCode[G.binds.palette] or Enum.KeyCode.K
	if input.KeyCode == paletteKey and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
		if paletteOpen then
			closePalette()
		else
			openPalette()
		end
	end
end))

track(UserInputService.LastInputTypeChanged:Connect(function(inputType)
	lastInput = inputType
	setWatch("input", "Input    " .. inputType.Name)
end))

local function bindViewport()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	track(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		applyChrome()
		setWatch("res", "Resolution    " .. resolutionText())
	end))
end
bindViewport()
track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	bindViewport()
	if type(P.fov) == "number" then
		task.defer(function()
			applyFov(false)
		end)
	end
	setWatch("fov", "Field of view    " .. fovText())
end))
track(player.CharacterAdded:Connect(function()
	task.defer(function()
		bindViewport()
		if type(P.fov) == "number" then
			applyFov(false)
		end
	end)
end))

track(RunService.Heartbeat:Connect(function(dt)
	if not alive then
		return
	end
	fpsFrames += 1
	fpsAccum += dt
	if fpsAccum < 0.5 then
		return
	end
	fpsValue = fpsFrames / fpsAccum
	fpsFrames = 0
	fpsAccum = 0
	fpsCursor = fpsCursor % 28 + 1
	fpsHistory[fpsCursor] = fpsValue
	local text = string.format("FPS    %d", math.floor(fpsValue + 0.5))
	setWatch("fps", text)
	if chartBars then
		for index = 1, 28 do
			local sampleIndex = (fpsCursor - (28 - index) - 1) % 28 + 1
			local sample = fpsHistory[sampleIndex] or 0
			local bar = chartBars[index]
			if bar and bar.Parent then
				bar.Size = UDim2.new(1, 0, math.clamp(sample / 120, 0.06, 1), 0)
			end
		end
	end
end))

task.spawn(function()
	while alive do
		task.wait(1)
		if not alive then
			break
		end
		setWatch("players", string.format("Players    %d / %d", #Players:GetPlayers(), Players.MaxPlayers))
		setWatch("ping", pingText())
		setWatch("session", "Session    " .. formatTime(os.clock() - sessionStart))
		setWatch("profileLine", (function()
			local selected = gameById(selectedId)
			return (selected and selected.name or "No profile") .. "    ·    Session " .. formatTime(os.clock() - sessionStart)
		end)())
		setWatch("mem", memoryText())
		setWatch("fov", "Field of view    " .. fovText())
		setWatch("res", "Resolution    " .. resolutionText())
		setWatch("graphics", "Graphics    " .. graphicsText())
		local job = game.JobId == "" and "Job ID    Empty in this session" or ("Job ID    " .. string.sub(game.JobId, 1, 16))
		setWatch("job", job)
	end
end)

local pulseColors = { C.cyan, C.violet, C.green, C.red }
for index = 1, 4 do
	local horizontal = index % 2 == 0
	local pulse = make("Frame", {
		Position = horizontal and UDim2.fromOffset(-120, 70 + index * 36) or UDim2.fromOffset(80 + index * 40, -120),
		Size = horizontal and UDim2.fromOffset(110, 2) or UDim2.fromOffset(2, 110),
		BackgroundColor3 = pulseColors[index],
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Visible = false,
	}, pulseLayer)
	local gradient = make("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}, pulse)
	if not horizontal then
		gradient.Rotation = 90
	end
	task.spawn(function()
		task.wait(index * 0.35)
		while alive and pulse.Parent do
			local moving = bootDone and windowOpen and P.pulses and not P.reducedMotion and grid.Visible
			if moving then
				pulse.Visible = true
				pulse.Position = horizontal and UDim2.fromOffset(-120, 70 + index * 36) or UDim2.fromOffset(80 + index * 40, -120)
				local goal = horizontal and UDim2.fromOffset(WIN_W + 40, 70 + index * 36) or UDim2.fromOffset(80 + index * 40, WIN_H + 40)
				local travel = tween(pulse, (3.1 + index * 0.35) / math.clamp(P.anim or 1, 0.6, 1.4), { Position = goal })
				pcall(function()
					travel.Completed:Wait()
				end)
				task.wait(0.35)
			else
				pulse.Visible = false
				task.wait(0.3)
			end
		end
	end)
end

if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
	dockExpanded = true
	dock.Size = UDim2.fromOffset(DOCK_OPEN, 52)
end

dock.MouseEnter:Connect(function()
	if UserInputService.MouseEnabled then
		if not dockExpanded then
			dockExpanded = true
			tween(dock, 0.28, { Size = UDim2.fromOffset(DOCK_OPEN, 52) })
		end
	end
end)
dock.MouseLeave:Connect(function()
	if UserInputService.MouseEnabled and not (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) then
		if dockExpanded then
			dockExpanded = false
			tween(dock, 0.28, { Size = UDim2.fromOffset(DOCK_CLOSED, 52) })
		end
	end
end)
dockLogo.Activated:Connect(function()
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		dockExpanded = not dockExpanded
		tween(dock, 0.28, { Size = UDim2.fromOffset(dockExpanded and DOCK_OPEN or DOCK_CLOSED, 52) })
		if dockExpanded then
			ensureWindow()
		end
	else
		toggleWindow()
	end
end)

modalDim.Activated:Connect(function()
	closeModal()
end)

gui.Destroying:Connect(function()
	alive = false
	pcall(function()
		ContextActionService:UnbindAction("VEXORA_Palette")
	end)
	for _, conn in ipairs(conns) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	clearPageConns()
	if previousQuality ~= nil then
		pcall(function()
			UserSettings():GetService("UserGameSettings").SavedQualityLevel = previousQuality
		end)
	end
end)

registerFeatures()
applyChrome()
applyCrosshair()

task.spawn(function()
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	if ok and type(info) == "table" and type(info.Name) == "string" then
		experienceName = info.Name
		setWatch("experience", "Experience    " .. experienceName)
	end
	infoReady = true
end)

task.spawn(function()
	local assets = {}
	for _, entry in ipairs(GAMES) do
		if entry.universeId then
			table.insert(assets, "rbxthumb://type=GameThumbnail&id=" .. tostring(entry.universeId) .. "&w=768&h=432")
			table.insert(assets, "rbxthumb://type=GameIcon&id=" .. tostring(entry.universeId) .. "&w=150&h=150")
		end
	end
	if #assets > 0 then
		pcall(function()
			ContentProvider:PreloadAsync(assets)
		end)
	end
end)

local splash = make("CanvasGroup", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(360, 210),
	BackgroundColor3 = C.bg,
	GroupTransparency = 1,
	ZIndex = 8,
}, gui)
corner(splash, 16)
stroke(splash, 0.15)
local splashScale = make("UIScale", { Scale = 1 }, splash)
local splashGrid = make("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ClipsDescendants = true }, splash)
for x = 0, 360, 26 do
	make("Frame", {
		Position = UDim2.fromOffset(x, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = C.white,
		BackgroundTransparency = 0.96,
		BorderSizePixel = 0,
	}, splashGrid)
end
for y = 0, 210, 26 do
	make("Frame", {
		Position = UDim2.fromOffset(0, y),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = C.white,
		BackgroundTransparency = 0.96,
		BorderSizePixel = 0,
	}, splashGrid)
end
local splashLogo = make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 28),
	Size = UDim2.fromOffset(48, 48),
	BackgroundColor3 = C.white,
	Text = "V",
	TextColor3 = C.bg,
	Font = Enum.Font.GothamBold,
	TextSize = 26,
	BorderSizePixel = 0,
}, splash)
corner(splashLogo, 12)
local splashTitle = make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 86),
	Size = UDim2.new(1, 0, 0, 28),
	Font = Enum.Font.GothamBold,
	TextSize = 26,
	TextColor3 = C.white,
	Text = "VEXORA",
}, splash)
local splashSub = make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 116),
	Size = UDim2.new(1, 0, 0, 16),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = C.muted,
	Text = "Opening",
}, splash)
local splashTrack = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 156),
	Size = UDim2.fromOffset(220, 3),
	BackgroundColor3 = C.hover,
	BorderSizePixel = 0,
}, splash)
corner(splashTrack, 3)
local splashFill = make("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = C.white,
	BorderSizePixel = 0,
}, splashTrack)
corner(splashFill, 3)

local function boot()
	local camera = workspace.CurrentCamera
	if camera then
		splashScale.Scale = math.clamp(math.min(1, (camera.ViewportSize.X - 24) / 360), 0.7, 1)
	end
	tween(splash, 0.35, { GroupTransparency = 0 })
	local steps = {
		{ 0.22, "Opening VEXORA" },
		{ 0.48, "Identifying this experience" },
		{ 0.74, "Preparing profiles" },
		{ 1, "Choose a profile" },
	}
	for _, step in ipairs(steps) do
		if not alive then
			return
		end
		splashSub.Text = step[2]
		local fillTween = tween(splashFill, 0.28, { Size = UDim2.fromScale(step[1], 1) })
		pcall(function()
			fillTween.Completed:Wait()
		end)
		task.wait(0.08)
	end
	local deadline = os.clock() + 1.2
	while alive and not infoReady and os.clock() < deadline do
		task.wait(0.05)
	end
	if not alive then
		return
	end
	splashSub.Text = "You are in " .. experienceName
	task.wait(0.18)
	local fade = tween(splash, 0.22, { GroupTransparency = 1 })
	pcall(function()
		fade.Completed:Wait()
	end)
	if splash.Parent then
		splash:Destroy()
	end
	bootDone = true
	applyAll()
	dock.Visible = G.dock
	navigate("Games", nil, true)
	if G._loadNote then
		notify(G._loadNote, "warning")
		G._loadNote = nil
	elseif storageMode == "file" then
		notify("Settings loaded from this device.", "info")
	else
		notify("Settings last for this run. Export a copy to keep them.", "info")
	end
	print("[VEXORA] 5.0 loaded")
end

task.spawn(boot)
