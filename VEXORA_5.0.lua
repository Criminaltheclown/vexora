local VX = {}
-- StarterPlayer.StarterPlayerScripts.VEXORA
-- VEXORA 5.0
-- Standalone local interface. No HTTP, no loadstring, no remote scripts.
-- Paste into a client executor, or save as a LocalScript under StarterPlayerScripts.

 VX.Players = game:GetService("Players")
 VX.TweenService = game:GetService("TweenService")
 VX.UserInputService = game:GetService("UserInputService")
 VX.RunService = game:GetService("RunService")
 VX.ContextActionService = game:GetService("ContextActionService")
 VX.HttpService = game:GetService("HttpService")
 VX.GuiService = game:GetService("GuiService")
 VX.MarketplaceService = game:GetService("MarketplaceService")
 VX.ContentProvider = game:GetService("ContentProvider")
 VX.Stats = game:GetService("Stats")

 VX.player = VX.Players.LocalPlayer
if not VX.player then
	warn("[VEXORA] LocalPlayer is missing. Run this on the client.")
	return
end

 VX.playerGui = VX.player:WaitForChild("PlayerGui")
 VX.existing = VX.playerGui:FindFirstChild("VEXORA_5")
if VX.existing then
	VX.existing:Destroy()
end

 VX.WIN_W = 780
 VX.WIN_H = 524
 VX.SIDE = 70
 VX.HEADER = 56
 VX.DOCK_CLOSED = 58
 VX.DOCK_OPEN = 286

 VX.C = {
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

 VX.ACCENTS = {
	Cyan = VX.C.cyan,
	Violet = VX.C.violet,
	Green = VX.C.green,
	White = VX.C.white,
}

 VX.COLOR_CHOICES = { "White", "Cyan", "Violet", "Green", "Red" }
 VX.COLOR_VALUES = {
	White = VX.C.white,
	Cyan = VX.C.cyan,
	Violet = VX.C.violet,
	Green = VX.C.green,
	Red = VX.C.red,
}

 VX.GAMES = {
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

 VX.NAV = {
	{ id = "Home", icon = "home", tip = "Home" },
	{ id = "Games", icon = "gamepad", tip = "Games" },
	{ id = "Universal", icon = "sliders", tip = "Universal" },
	{ id = "Urban", icon = "monitor", tip = "Urban Reload" },
	{ id = "Settings", icon = "settings", tip = "Settings" },
}

 function VX.defaultProfile()
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

 function VX.defaultGlobal()
	local profiles = { Default = VX.defaultProfile() }
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

 function VX.deepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for key, item in pairs(value) do
		out[key] = VX.deepCopy(item)
	end
	return out
end

 function VX.validKey(name)
	if type(name) ~= "string" then
		return false
	end
	local ok, value = pcall(function()
		return Enum.KeyCode[name]
	end)
	return ok and value ~= nil and value ~= Enum.KeyCode.Unknown
end

 function VX.sanitizeProfile(source)
	local profile = VX.defaultProfile()
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
	if VX.ACCENTS[source.accent] then
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
		if VX.COLOR_VALUES[crosshair.color] then
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

 function VX.sanitizeGlobal(source)
	local global = VX.defaultGlobal()
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
		if VX.validKey(source.binds.toggle) then
			global.binds.toggle = source.binds.toggle
		end
		if VX.validKey(source.binds.palette) then
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
				local clean = VX.sanitizeProfile({ crosshair = preset }).crosshair
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
				profiles[name] = VX.sanitizeProfile(profile)
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
			global.profiles.Default = VX.defaultProfile()
		end
	end
	return global
end

 VX.G = VX.defaultGlobal()
 VX.P = VX.G.profiles.Default
 VX.storageMode = "session"
 VX.storageNote = "Settings last for this run. Export a copy if you want to keep them."
 VX.saveWarned = false
 VX.saveQueued = false

 VX.selectedId = nil
 VX.experienceName = "Place " .. tostring(game.PlaceId)
 VX.infoReady = false
 VX.originalFOV = 70
 VX.previousQuality = nil
 VX.bootDone = false
 VX.alive = true
 VX.windowOpen = false
 VX.dockExpanded = false
 VX.paletteOpen = false
 VX.modalOpen = false
 VX.capturing = nil
 VX.suppressEscape = false
 VX.currentPage = nil
 VX.currentTab = "Camera"
 VX.navToken = 0
 VX.tipToken = 0
 VX.paletteIndex = 1
 VX.fpsValue = nil
 VX.fpsAccum = 0
 VX.fpsFrames = 0
 VX.fpsHistory = table.create(28, 0)
 VX.fpsCursor = 0
 VX.sessionStart = os.clock()
 VX.lastInput = VX.UserInputService:GetLastInputType()
 VX.history = {}
 VX.recentQueries = {}
 VX.features = {}
 VX.featureOrder = {}
 VX.navButtons = {}
 VX.accentNodes = {}
 VX.watchers = {}
 VX.conns = {}
 VX.pageConns = {}
 VX.chartBars = nil
 VX.onPlayersChanged = nil
 VX.dropdownCallback = nil
 VX.dropdownOptions = {}
 VX.paletteRows = {}
 VX.hudDrag = false
 VX.windowDrag = false
 VX.dragStart = nil
 VX.dragOrigin = nil

if workspace.CurrentCamera then
	VX.originalFOV = workspace.CurrentCamera.FieldOfView
end

 VX.graphicsAvailable = false
pcall(function()
	local level = UserSettings():GetService("UserGameSettings").SavedQualityLevel
	VX.graphicsAvailable = level ~= nil
end)

 VX.pingAvailable = true

do
	local loadedNote = nil
	if typeof(readfile) == "function" then
		local ok, raw = pcall(readfile, "VEXORA_5_settings.json")
		if ok and type(raw) == "string" and raw ~= "" then
			local decodedOk, data = pcall(function()
				return VX.HttpService:JSONDecode(raw)
			end)
			if decodedOk and type(data) == "table" and data.version == 5 and type(data.global) == "table" then
				VX.G = VX.sanitizeGlobal(data.global)
				VX.P = VX.G.profiles[VX.G.activeProfile]
				VX.storageMode = "file"
				VX.storageNote = "Loaded VEXORA_5_settings.json from this device."
			else
				loadedNote = "A settings file was found and ignored because it is not VEXORA 5."
			end
		end
	end
	VX.G._loadNote = loadedNote
end

 VX.rememberedProfile = VX.G.perGame[tostring(game.PlaceId)]
if VX.rememberedProfile == "urban" or VX.rememberedProfile == "universal" then
	VX.selectedId = VX.rememberedProfile
end

 function VX.track(conn)
	table.insert(VX.conns, conn)
	return conn
end

 function VX.trackPage(conn)
	table.insert(VX.pageConns, conn)
	return conn
end

 function VX.clearPageConns()
	for _, conn in ipairs(VX.pageConns) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(VX.pageConns)
end

 function VX.duration(base)
	if VX.P and VX.P.reducedMotion then
		return 0
	end
	local scale = (VX.P and VX.P.anim) or 1
	return base * math.clamp(scale, 0.6, 1.4)
end

 function VX.tween(obj, seconds, props)
	local function finished()
		local event = Instance.new("BindableEvent")
		task.defer(function()
			event:Fire()
		end)
		return { Completed = event.Event, Play = function() end }
	end
	if not obj or VX.duration(seconds) <= 0 then
		if obj and props then
			for key, value in pairs(props) do
				pcall(function()
					obj[key] = value
				end)
			end
		end
		return finished()
	end
	local info = TweenInfo.new(VX.duration(seconds), Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local ok, result = pcall(function()
		return VX.TweenService:Create(obj, info, props)
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

 function VX.make(className, props, parent)
	local obj = Instance.new(className)
	for key, value in pairs(props or {}) do
		obj[key] = value
	end
	obj.Parent = parent
	return obj
end

 function VX.corner(obj, radius)
	VX.make("UICorner", { CornerRadius = UDim.new(0, radius) }, obj)
end

 function VX.stroke(obj, transparency, color)
	return VX.make("UIStroke", {
		Color = color or VX.C.border,
		Transparency = transparency or 0.35,
		Thickness = 1,
	}, obj)
end

 function VX.lay(parent)
	local nextOrder = (parent:GetAttribute("Lay") or 0) + 1
	parent:SetAttribute("Lay", nextOrder)
	return nextOrder
end

 function VX.accentColor()
	return VX.ACCENTS[VX.P.accent] or VX.C.cyan
end

 function VX.trackAccent(obj, prop)
	table.insert(VX.accentNodes, { obj, prop })
	obj[prop] = VX.accentColor()
end

 function VX.applyAccent()
	local color = VX.accentColor()
	for index = #VX.accentNodes, 1, -1 do
		local item = VX.accentNodes[index]
		if item[1].Parent then
			item[1][item[2]] = color
		else
			table.remove(VX.accentNodes, index)
		end
	end
end

 function VX.watch(key, label)
	VX.watchers[key] = VX.watchers[key] or {}
	table.insert(VX.watchers[key], label)
end

 function VX.setWatch(key, text)
	local list = VX.watchers[key]
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

 function VX.formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor(seconds % 3600 / 60)
	local secs = seconds % 60
	if hours > 0 then
		return string.format("%d:%02d:%02d", hours, minutes, secs)
	end
	return string.format("%02d:%02d", minutes, secs)
end

 function VX.gameById(id)
	for _, entry in ipairs(VX.GAMES) do
		if entry.id == id then
			return entry
		end
	end
	return nil
end

 function VX.inUrban()
	return game.PlaceId == 84448037861644
end

 function VX.platformText()
	if VX.GuiService:IsTenFootInterface() then
		return "Console"
	end
	if VX.UserInputService.TouchEnabled and not VX.UserInputService.MouseEnabled then
		return "Touch"
	end
	if VX.UserInputService.GamepadEnabled and not VX.UserInputService.KeyboardEnabled then
		return "Gamepad"
	end
	if VX.UserInputService.KeyboardEnabled then
		return "Keyboard"
	end
	return "Unknown"
end

 function VX.resolutionText()
	local camera = workspace.CurrentCamera
	if not camera then
		return "Unavailable"
	end
	local view = camera.ViewportSize
	return string.format("%d x %d", math.floor(view.X + 0.5), math.floor(view.Y + 0.5))
end

 function VX.fovText()
	local camera = workspace.CurrentCamera
	if not camera then
		return "Unavailable"
	end
	return tostring(math.floor(camera.FieldOfView + 0.5))
end

 function VX.pingText()
	if not VX.pingAvailable then
		return "Ping (estimate)    Unavailable"
	end
	local ok, sample = pcall(function()
		return VX.player:GetNetworkPing()
	end)
	if not ok or type(sample) ~= "number" then
		return "Ping (estimate)    Unavailable"
	end
	return string.format("Ping (estimate)    %d ms", math.floor(sample * 1000 + 0.5))
end

 function VX.memoryText()
	local ok, mb = pcall(function()
		return VX.Stats:GetTotalMemoryUsageMb()
	end)
	if ok and type(mb) == "number" then
		return string.format("Memory    %.0f MB", mb)
	end
	return "Memory    Unavailable"
end

 function VX.graphicsText()
	local ok, level = pcall(function()
		return UserSettings():GetService("UserGameSettings").SavedQualityLevel.Name
	end)
	if ok and type(level) == "string" then
		return level
	end
	return "Unavailable"
end

 function VX.shownTransparency()
	return 1 - math.clamp(VX.P.opacity or 1, 0.7, 1)
end

 function VX.fitScale()
	local camera = workspace.CurrentCamera
	local view = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local sx = (view.X - 24) / VX.WIN_W
	local sy = (view.Y - 96) / VX.WIN_H
	return math.min(1, sx, sy)
end

 function VX.computeScale()
	return math.clamp(VX.fitScale() * (VX.P.uiScale or 1), 0.68, 1.15)
end

 function VX.recolor(root, color)
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

 function VX.paintIcon(holder, name, color, pixel)
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

 function VX.icon(parent, name, pixel, color)
	local holder = VX.make("Frame", {
		Name = "Icon",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(pixel, pixel),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
	}, parent)
	VX.paintIcon(holder, name, color or VX.C.white, pixel)
	return holder
end

 VX.gui = VX.make("ScreenGui", {
	Name = "VEXORA_5",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 200,
}, VX.playerGui)

 VX.crosshairRoot = VX.make("Frame", {
	Name = "Crosshair",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 1,
	Active = false,
}, VX.gui)

 VX.hud = VX.make("TextButton", {
	Name = "Hud",
	AutoButtonColor = false,
	Text = "",
	BackgroundColor3 = VX.C.panel,
	BorderSizePixel = 0,
	Size = UDim2.fromOffset(176, 78),
	Position = UDim2.fromOffset(16, 16),
	Visible = false,
	ZIndex = 2,
	Active = true,
}, VX.gui)
VX.corner(VX.hud, 12)
VX.stroke(VX.hud, 0.25)

 VX.hudFps = VX.make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(12, 8),
	Size = UDim2.new(1, -24, 0, 18),
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = VX.C.white,
	Text = "FPS    …",
}, VX.hud)
 VX.hudPing = VX.make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(12, 28),
	Size = UDim2.new(1, -24, 0, 16),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = VX.C.muted,
	Text = "Ping    …",
}, VX.hud)
 VX.hudTime = VX.make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(12, 48),
	Size = UDim2.new(1, -24, 0, 16),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = VX.C.muted,
	Text = "Session    00:00",
}, VX.hud)
VX.watch("fps", VX.hudFps)
VX.watch("ping", VX.hudPing)
VX.watch("session", VX.hudTime)

 VX.window = VX.make("CanvasGroup", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(VX.WIN_W, VX.WIN_H),
	BackgroundColor3 = VX.C.bg,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
	ClipsDescendants = true,
	ZIndex = 3,
	Active = true,
}, VX.gui)
VX.corner(VX.window, 16)
VX.stroke(VX.window, 0.12)
 VX.uiScale = VX.make("UIScale", { Scale = 1 }, VX.window)

VX.make("TextButton", {
	Name = "Sink",
	Text = "",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	Modal = true,
	ZIndex = 0,
}, VX.window)

 VX.grid = VX.make("Frame", {
	Name = "Grid",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ClipsDescendants = true,
	ZIndex = 1,
}, VX.window)
for x = 0, VX.WIN_W, 26 do
	VX.make("Frame", {
		Position = UDim2.fromOffset(x, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = VX.C.white,
		BackgroundTransparency = 0.965,
		BorderSizePixel = 0,
	}, VX.grid)
end
for y = 0, VX.WIN_H, 26 do
	VX.make("Frame", {
		Position = UDim2.fromOffset(0, y),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = VX.C.white,
		BackgroundTransparency = 0.965,
		BorderSizePixel = 0,
	}, VX.grid)
end

 VX.pulseLayer = VX.make("Frame", {
	Name = "Pulses",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ClipsDescendants = true,
	ZIndex = 2,
}, VX.grid)

 VX.glow = VX.make("Frame", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.fromScale(0.5, 1),
	Size = UDim2.new(1, 0, 0, 150),
	BackgroundColor3 = VX.C.violet,
	BackgroundTransparency = 0.96,
	BorderSizePixel = 0,
	ZIndex = 2,
}, VX.window)
VX.make("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0.2),
	}),
}, VX.glow)

 VX.sidebar = VX.make("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, VX.SIDE, 1, 0),
	BackgroundColor3 = VX.C.panel,
	BorderSizePixel = 0,
	ZIndex = 4,
}, VX.window)
VX.make("Frame", {
	Position = UDim2.new(1, -1, 0, 0),
	Size = UDim2.new(0, 1, 1, 0),
	BackgroundColor3 = VX.C.border,
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
}, VX.sidebar)

 VX.logo = VX.make("TextLabel", {
	Position = UDim2.fromOffset(15, 14),
	Size = UDim2.fromOffset(40, 40),
	BackgroundColor3 = VX.C.white,
	Text = "V",
	TextColor3 = VX.C.bg,
	TextSize = 22,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
}, VX.sidebar)
VX.corner(VX.logo, 12)

 VX.main = VX.make("Frame", {
	Name = "Main",
	Position = UDim2.fromOffset(VX.SIDE, 0),
	Size = UDim2.new(1, -VX.SIDE, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 4,
}, VX.window)

 VX.header = VX.make("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, VX.HEADER),
	BackgroundTransparency = 1,
}, VX.main)
VX.make("Frame", {
	Position = UDim2.new(0, 0, 1, -1),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = VX.C.border,
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
}, VX.header)

 VX.title = VX.make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 8),
	Size = UDim2.new(1, -320, 0, 24),
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = VX.C.white,
	Text = "Games",
	TextTruncate = Enum.TextTruncate.AtEnd,
}, VX.header)
 VX.subtitle = VX.make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 32),
	Size = UDim2.new(1, -320, 0, 16),
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = VX.C.muted,
	Text = "VEXORA   /   5.0",
	TextTruncate = Enum.TextTruncate.AtEnd,
}, VX.header)

 VX.searchButton = VX.make("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -84, 0.5, 0),
	Size = UDim2.fromOffset(176, 32),
	BackgroundColor3 = VX.C.card,
	Text = "",
	AutoButtonColor = false,
	BorderSizePixel = 0,
}, VX.header)
VX.corner(VX.searchButton, 8)
VX.stroke(VX.searchButton, 0.4)
VX.icon(VX.searchButton, "search", 14, VX.C.muted).Position = UDim2.fromOffset(16, 16)
VX.make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(28, 0),
	Size = UDim2.new(1, -36, 1, 0),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = VX.C.muted,
	Text = "Search    Ctrl K",
}, VX.searchButton)

 VX.minButton = VX.make("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -48, 0.5, 0),
	Size = UDim2.fromOffset(28, 28),
	BackgroundColor3 = VX.C.card,
	Text = "",
	AutoButtonColor = false,
	BorderSizePixel = 0,
}, VX.header)
VX.corner(VX.minButton, 8)
VX.icon(VX.minButton, "minus", 14, VX.C.muted)

 VX.closeButton = VX.make("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -12, 0.5, 0),
	Size = UDim2.fromOffset(28, 28),
	BackgroundColor3 = VX.C.card,
	Text = "",
	AutoButtonColor = false,
	BorderSizePixel = 0,
}, VX.header)
VX.corner(VX.closeButton, 8)
VX.icon(VX.closeButton, "close", 14, VX.C.muted)

 VX.body = VX.make("Frame", {
	Name = "Body",
	Position = UDim2.fromOffset(0, VX.HEADER),
	Size = UDim2.new(1, 0, 1, -VX.HEADER),
	BackgroundTransparency = 1,
}, VX.main)

 VX.tabBar = VX.make("ScrollingFrame", {
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
}, VX.body)
VX.make("UIPadding", {
	PaddingLeft = UDim.new(0, 12),
	PaddingRight = UDim.new(0, 12),
	PaddingTop = UDim.new(0, 8),
}, VX.tabBar)
 VX.tabLayout = VX.make("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, VX.tabBar)

 VX.content = VX.make("CanvasGroup", {
	Name = "Content",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	GroupTransparency = 0,
}, VX.body)
 VX.scroll = VX.make("ScrollingFrame", {
	Name = "Scroll",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = VX.C.border,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
}, VX.content)

 VX.dock = VX.make("Frame", {
	Name = "Dock",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -16),
	Size = UDim2.fromOffset(VX.DOCK_CLOSED, 52),
	BackgroundColor3 = VX.C.panel,
	BorderSizePixel = 0,
	Visible = false,
	ClipsDescendants = true,
	ZIndex = 6,
	Active = true,
}, VX.gui)
VX.corner(VX.dock, 18)
VX.stroke(VX.dock, 0.12)
 VX.dockScale = VX.make("UIScale", { Scale = 1 }, VX.dock)
 VX.dockLogo = VX.make("TextButton", {
	Position = UDim2.fromOffset(11, 8),
	Size = UDim2.fromOffset(36, 36),
	BackgroundColor3 = VX.C.white,
	Text = "V",
	TextColor3 = VX.C.bg,
	TextSize = 18,
	Font = Enum.Font.GothamBold,
	AutoButtonColor = false,
	BorderSizePixel = 0,
}, VX.dock)
VX.corner(VX.dockLogo, 12)
 VX.dockItems = VX.make("Frame", {
	Position = UDim2.fromOffset(54, 8),
	Size = UDim2.fromOffset(220, 36),
	BackgroundTransparency = 1,
}, VX.dock)

 VX.tip = VX.make("Frame", {
	Visible = false,
	BackgroundColor3 = VX.C.panel,
	BorderSizePixel = 0,
	Size = UDim2.fromOffset(80, 26),
	ZIndex = 15,
}, VX.gui)
VX.corner(VX.tip, 8)
VX.stroke(VX.tip, 0.2)
 VX.tipLabel = VX.make("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = VX.C.white,
	Text = "",
}, VX.tip)

 VX.dropdownCatcher = VX.make("TextButton", {
	Visible = false,
	Text = "",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 20,
}, VX.gui)
 VX.dropdownPanel = VX.make("Frame", {
	Visible = false,
	BackgroundColor3 = VX.C.panel,
	BorderSizePixel = 0,
	ZIndex = 21,
	ClipsDescendants = true,
}, VX.gui)
VX.corner(VX.dropdownPanel, 10)
VX.stroke(VX.dropdownPanel, 0.15)
 VX.dropdownSearch = VX.make("TextBox", {
	Visible = false,
	Position = UDim2.fromOffset(8, 8),
	Size = UDim2.new(1, -16, 0, 28),
	BackgroundColor3 = VX.C.card,
	Text = "",
	PlaceholderText = "Filter",
	PlaceholderColor3 = VX.C.muted,
	TextColor3 = VX.C.white,
	Font = Enum.Font.Gotham,
	TextSize = 13,
	ClearTextOnFocus = false,
	BorderSizePixel = 0,
}, VX.dropdownPanel)
VX.corner(VX.dropdownSearch, 7)
 VX.dropdownList = VX.make("ScrollingFrame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(6, 8),
	Size = UDim2.new(1, -12, 1, -14),
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = VX.C.border,
	ElasticBehavior = Enum.ElasticBehavior.Never,
}, VX.dropdownPanel)

 VX.modalDim = VX.make("TextButton", {
	Visible = false,
	Text = "",
	AutoButtonColor = false,
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 30,
}, VX.gui)
 VX.modalPanel = VX.make("Frame", {
	Visible = false,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(420, 250),
	BackgroundColor3 = VX.C.panel,
	BorderSizePixel = 0,
	ZIndex = 31,
}, VX.gui)
VX.corner(VX.modalPanel, 14)
VX.stroke(VX.modalPanel, 0.12)
 VX.modalTitle = VX.make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 16),
	Size = UDim2.new(1, -36, 0, 24),
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = VX.C.white,
	Text = "",
}, VX.modalPanel)
 VX.modalBody = VX.make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 46),
	Size = UDim2.new(1, -36, 0, 58),
	Font = Enum.Font.Gotham,
	TextSize = 13,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextColor3 = VX.C.muted,
	Text = "",
}, VX.modalPanel)
 VX.modalBox = VX.make("TextBox", {
	Visible = false,
	Position = UDim2.fromOffset(18, 112),
	Size = UDim2.new(1, -36, 0, 64),
	BackgroundColor3 = VX.C.card,
	Text = "",
	TextColor3 = VX.C.white,
	PlaceholderColor3 = VX.C.muted,
	Font = Enum.Font.Gotham,
	TextSize = 13,
	TextWrapped = true,
	ClearTextOnFocus = false,
	MultiLine = true,
	BorderSizePixel = 0,
}, VX.modalPanel)
VX.corner(VX.modalBox, 8)
 VX.modalButtons = VX.make("Frame", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 0, 1, -14),
	Size = UDim2.new(1, 0, 0, 34),
}, VX.modalPanel)

 VX.paletteDim = VX.make("TextButton", {
	Visible = false,
	Text = "",
	AutoButtonColor = false,
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 40,
}, VX.gui)
 VX.palettePanel = VX.make("CanvasGroup", {
	Visible = false,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.46),
	Size = UDim2.fromOffset(520, 420),
	BackgroundColor3 = VX.C.panel,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	ZIndex = 41,
	ClipsDescendants = true,
}, VX.gui)
VX.corner(VX.palettePanel, 14)
VX.stroke(VX.palettePanel, 0.12)
 VX.paletteBox = VX.make("TextBox", {
	Position = UDim2.fromOffset(14, 14),
	Size = UDim2.new(1, -28, 0, 36),
	BackgroundColor3 = VX.C.card,
	Text = "",
	PlaceholderText = "Search features",
	PlaceholderColor3 = VX.C.muted,
	TextColor3 = VX.C.white,
	Font = Enum.Font.Gotham,
	TextSize = 15,
	ClearTextOnFocus = false,
	BorderSizePixel = 0,
}, VX.palettePanel)
VX.corner(VX.paletteBox, 8)
 VX.paletteList = VX.make("ScrollingFrame", {
	Position = UDim2.fromOffset(10, 60),
	Size = UDim2.new(1, -20, 1, -72),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = VX.C.border,
	ElasticBehavior = Enum.ElasticBehavior.Never,
}, VX.palettePanel)

 VX.toastLayer = VX.make("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 50,
}, VX.gui)






 function VX.feature(def)
	VX.features[def.id] = def
	table.insert(VX.featureOrder, def.id)
end

 function VX.scoreFeature(query, def)
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

VX.bindHover = function(button, rest, over, press)
	button.AutoButtonColor = false
	button:SetAttribute("Rest", nil)
	button.MouseEnter:Connect(function()
		if button:GetAttribute("Disabled") then
			return
		end
		VX.tween(button, 0.12, { BackgroundColor3 = over })
	end)
	button.MouseLeave:Connect(function()
		if button:GetAttribute("Disabled") then
			return
		end
		local selected = button:GetAttribute("Selected")
		VX.tween(button, 0.12, { BackgroundColor3 = selected and VX.C.hover or rest })
	end)
	button.MouseButton1Down:Connect(function()
		if button:GetAttribute("Disabled") then
			return
		end
		VX.tween(button, 0.06, { BackgroundColor3 = press or VX.C.bg })
	end)
	button.MouseButton1Up:Connect(function()
		if button:GetAttribute("Disabled") then
			return
		end
		VX.tween(button, 0.1, { BackgroundColor3 = over })
	end)
end

VX.bindTip = function(target, text)
	target.MouseEnter:Connect(function()
		VX.tipToken += 1
		local token = VX.tipToken
		task.delay(VX.P.reducedMotion and 0 or 0.35, function()
			if token ~= VX.tipToken or not VX.alive or not target.Parent then
				return
			end
			VX.tipLabel.Text = text
			local width = math.clamp(#text * 7 + 18, 52, 200)
			VX.tip.Size = UDim2.fromOffset(width, 26)
			VX.tip.Visible = true
			local camera = workspace.CurrentCamera
			local view = camera and camera.ViewportSize or Vector2.new(1280, 720)
			local x = target.AbsolutePosition.X + target.AbsoluteSize.X * 0.5 - width * 0.5
			local y = target.AbsolutePosition.Y - 32
			if y < 8 then
				y = target.AbsolutePosition.Y + target.AbsoluteSize.Y + 8
			end
			x = math.clamp(x, 8, math.max(8, view.X - width - 8))
			VX.tip.Position = UDim2.fromOffset(x, y)
		end)
	end)
	target.MouseLeave:Connect(function()
		VX.tipToken += 1
		VX.tip.Visible = false
	end)
end

 function VX.clearScroll()
	VX.clearPageConns()
	VX.chartBars = nil
	VX.onPlayersChanged = nil
	for _, child in ipairs(VX.scroll:GetChildren()) do
		child:Destroy()
	end
	VX.scroll:SetAttribute("Lay", 0)
	VX.make("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 16),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	}, VX.scroll)
	VX.make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, VX.scroll)
	VX.scroll.CanvasPosition = Vector2.zero
end

 function VX.stack(parent, padding)
	local frame = VX.make("Frame", {
		LayoutOrder = VX.lay(parent),
		BackgroundColor3 = VX.C.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, parent)
	VX.corner(frame, 12)
	VX.stroke(frame, 0.5)
	VX.make("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	}, frame)
	VX.make("UIListLayout", {
		Padding = UDim.new(0, padding or 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, frame)
	frame:SetAttribute("Lay", 0)
	return frame
end

 function VX.fixedRow(parent, height, color)
	return VX.make("Frame", {
		LayoutOrder = VX.lay(parent),
		BackgroundColor3 = color or VX.C.card,
		BackgroundTransparency = color and 0 or 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height),
	}, parent)
end

 function VX.textLabel(parent, text, size, color, bold, height)
	return VX.make("TextLabel", {
		LayoutOrder = VX.lay(parent),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height or (bold and 22 or 16)),
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextSize = size,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextColor3 = color or VX.C.white,
		Text = text,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
end

 function VX.button(parent, textValue, callback, opts)
	opts = opts or {}
	local item = VX.make("TextButton", {
		LayoutOrder = opts.order or VX.lay(parent),
		Size = opts.size or UDim2.new(1, 0, 0, 34),
		Position = opts.position or UDim2.fromOffset(0, 0),
		AnchorPoint = opts.anchor or Vector2.new(0, 0),
		BackgroundColor3 = opts.primary and VX.C.white or VX.C.hover,
		Text = textValue,
		TextColor3 = opts.primary and VX.C.bg or VX.C.white,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, parent)
	VX.corner(item, 8)
	VX.bindHover(item, opts.primary and VX.C.white or VX.C.hover, opts.primary and Color3.fromRGB(226, 228, 232) or VX.C.border, opts.primary and Color3.fromRGB(210, 212, 216) or VX.C.bg)
	item.Activated:Connect(function()
		if item:GetAttribute("Disabled") then
			if opts.disabledReason then
				VX.notify(opts.disabledReason, "warning")
			end
			return
		end
		callback()
	end)
	if opts.disabled then
		item:SetAttribute("Disabled", true)
		item.TextColor3 = VX.C.muted
		item.BackgroundColor3 = VX.C.card
	end
	return item
end

 function VX.setFavourite(id, on)
	if on then
		VX.G.favorites[id] = true
	else
		VX.G.favorites[id] = nil
	end
	VX.requestSave()
end

 function VX.heartButton(parent, featureId, xOffset)
	local item = VX.make("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.fromOffset(24, 24),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, xOffset, 0.5, 0),
		AutoButtonColor = false,
	}, parent)
	local holder = VX.icon(item, "heart", 14, VX.G.favorites[featureId] and VX.C.violet or VX.C.muted)
	item.Activated:Connect(function()
		local on = VX.G.favorites[featureId] ~= true
		VX.setFavourite(featureId, on)
		VX.recolor(holder, on and VX.C.violet or VX.C.muted)
		VX.notify(on and "Saved to favourites." or "Removed from favourites.", "info")
	end)
	return item
end

 function VX.toggle(parent, labelText, value, featureId, callback)
	local row = VX.fixedRow(parent, 36)
	if featureId then
		local holder = VX.icon(row, "heart", 14, VX.G.favorites[featureId] and VX.C.violet or VX.C.muted)
		holder.AnchorPoint = Vector2.new(0, 0.5)
		holder.Position = UDim2.new(0, 0, 0.5, 0)
		local hit = VX.make("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.fromOffset(0, 6),
			AutoButtonColor = false,
		}, row)
		hit.Activated:Connect(function()
			local on = VX.G.favorites[featureId] ~= true
			VX.setFavourite(featureId, on)
			VX.recolor(holder, on and VX.C.violet or VX.C.muted)
		end)
	end
	local inset = featureId and 28 or 0
	VX.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(inset, 0),
		Size = UDim2.new(1, -(78 + inset), 1, 0),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = VX.C.white,
		Text = labelText,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	local switch = VX.make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(44, 24),
		BackgroundColor3 = value and VX.C.white or VX.C.hover,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, row)
	VX.corner(switch, 12)
	local knob = VX.make("Frame", {
		Position = value and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = value and VX.C.bg or VX.C.muted,
		BorderSizePixel = 0,
	}, switch)
	VX.corner(knob, 9)
	local on = value == true
	switch.Activated:Connect(function()
		local nextValue = not on
		local result = callback(nextValue)
		if result == false then
			return
		end
		on = nextValue
		VX.tween(switch, 0.16, { BackgroundColor3 = on and VX.C.white or VX.C.hover })
		VX.tween(knob, 0.16, {
			Position = on and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = on and VX.C.bg or VX.C.muted,
		})
	end)
	return row
end

 function VX.slider(parent, labelText, minValue, maxValue, value, step, featureId, callback)
	local row = VX.fixedRow(parent, 52)
	local inset = 0
	if featureId then
		inset = 28
		local holder = VX.icon(row, "heart", 14, VX.G.favorites[featureId] and VX.C.violet or VX.C.muted)
		holder.Position = UDim2.fromOffset(12, 4)
		holder.AnchorPoint = Vector2.new(0, 0)
		local hit = VX.make("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.fromOffset(0, 0),
			AutoButtonColor = false,
		}, row)
		hit.Activated:Connect(function()
			local on = VX.G.favorites[featureId] ~= true
			VX.setFavourite(featureId, on)
			VX.recolor(holder, on and VX.C.violet or VX.C.muted)
		end)
	end
	VX.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(inset, 2),
		Size = UDim2.new(1, -(72 + inset), 0, 18),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = VX.C.white,
		Text = labelText,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	local valueLabel = VX.make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 2),
		Size = UDim2.fromOffset(64, 18),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = VX.C.white,
		Text = "",
	}, row)
	local hit = VX.make("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 0, 18),
	}, row)
	local track = VX.make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = VX.C.hover,
		BorderSizePixel = 0,
	}, hit)
	VX.corner(track, 4)
	local fill = VX.make("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = VX.C.white,
		BorderSizePixel = 0,
	}, track)
	VX.corner(fill, 4)
	local knob = VX.make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = VX.C.white,
		BorderSizePixel = 0,
	}, hit)
	VX.corner(knob, 8)
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
	VX.trackPage(VX.UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			fromX(input.Position.X)
		end
	end))
	VX.trackPage(VX.UserInputService.InputEnded:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			callback(current, true)
		end
	end))
end

 function VX.closeDropdown()
	VX.dropdownCatcher.Visible = false
	VX.dropdownPanel.Visible = false
	VX.dropdownCallback = nil
	VX.dropdownSearch.Text = ""
end

 function VX.fillDropdown(filter)
	for _, child in ipairs(VX.dropdownList:GetChildren()) do
		child:Destroy()
	end
	VX.make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, VX.dropdownList)
	local shown = 0
	filter = string.lower(filter or "")
	for _, option in ipairs(VX.dropdownOptions) do
		if filter == "" or string.find(string.lower(option), filter, 1, true) then
			shown += 1
			local item = VX.make("TextButton", {
				LayoutOrder = shown,
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundColor3 = VX.C.panel,
				Text = option,
				TextColor3 = VX.C.white,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				AutoButtonColor = false,
				BorderSizePixel = 0,
			}, VX.dropdownList)
			VX.corner(item, 6)
			VX.bindHover(item, VX.C.panel, VX.C.hover, VX.C.bg)
			item.Activated:Connect(function()
				local callback = VX.dropdownCallback
				VX.closeDropdown()
				if callback then
					callback(option)
				end
			end)
		end
	end
	if shown == 0 then
		VX.make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 28),
			Text = "No matches",
			TextColor3 = VX.C.muted,
			Font = Enum.Font.Gotham,
			TextSize = 13,
		}, VX.dropdownList)
	end
end

 function VX.openDropdown(anchor, options, callback)
	VX.closeDropdown()
	VX.dropdownOptions = options
	VX.dropdownCallback = callback
	local showSearch = #options > 6
	VX.dropdownSearch.Visible = showSearch
	VX.dropdownList.Position = UDim2.fromOffset(6, showSearch and 42 or 6)
	VX.dropdownList.Size = UDim2.new(1, -12, 1, showSearch and -48 or -12)
	VX.fillDropdown("")
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
	VX.dropdownPanel.Position = UDim2.fromOffset(x, y)
	VX.dropdownPanel.Size = UDim2.fromOffset(width, height)
	VX.dropdownCatcher.Visible = true
	VX.dropdownPanel.Visible = true
end

VX.dropdownSearch:GetPropertyChangedSignal("Text"):Connect(function()
	if VX.dropdownPanel.Visible then
		VX.fillDropdown(VX.dropdownSearch.Text)
	end
end)
VX.dropdownCatcher.Activated:Connect(VX.closeDropdown)

 function VX.dropdown(parent, labelText, options, value, callback)
	local row = VX.fixedRow(parent, 36)
	VX.make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -168, 1, 0),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = VX.C.white,
		Text = labelText,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	local picker = VX.make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(156, 28),
		BackgroundColor3 = VX.C.hover,
		Text = "  " .. tostring(value),
		TextColor3 = VX.C.white,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, row)
	VX.corner(picker, 8)
	VX.icon(picker, "chevronDown", 12, VX.C.muted).Position = UDim2.new(1, -16, 0.5, 0)
	VX.bindHover(picker, VX.C.hover, VX.C.border, VX.C.bg)
	picker.Activated:Connect(function()
		VX.openDropdown(picker, options, function(choice)
			picker.Text = "  " .. choice
			callback(choice)
		end)
	end)
	return picker
end

VX.notify = function(text, kind)
	kind = kind or "info"
	table.insert(VX.history, 1, { text = text, kind = kind, at = os.clock() })
	while #VX.history > 20 do
		table.remove(VX.history)
	end
	if not VX.P.notifications and kind ~= "error" then
		return
	end
	local last = VX.toastLayer:FindFirstChild("Last")
	if last and last:GetAttribute("Body") == text and os.clock() - (last:GetAttribute("At") or 0) < 1.2 then
		return
	end
	local count = 0
	for _, child in ipairs(VX.toastLayer:GetChildren()) do
		if child:IsA("Frame") then
			count += 1
		end
	end
	if count >= 4 then
		local oldest = VX.toastLayer:FindFirstChild("Toast1") or VX.toastLayer:FindFirstChildWhichIsA("Frame")
		if oldest then
			oldest:Destroy()
		end
	end
	local colors = { success = VX.C.green, info = VX.C.cyan, warning = VX.C.violet, error = VX.C.red }
	local frame = VX.make("Frame", {
		Name = "Toast",
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.fromOffset(286, 56),
		BackgroundColor3 = VX.C.panel,
		BorderSizePixel = 0,
	}, VX.toastLayer)
	frame:SetAttribute("Body", text)
	frame:SetAttribute("At", os.clock())
	frame:SetAttribute("Last", true)
	local previous = VX.toastLayer:FindFirstChild("LastMark")
	if previous then
		previous.Name = "Toast"
	end
	frame.Name = "LastMark"
	VX.corner(frame, 10)
	VX.stroke(frame, 0.2)
	VX.make("Frame", {
		Size = UDim2.new(0, 3, 1, -16),
		Position = UDim2.fromOffset(8, 8),
		BackgroundColor3 = colors[kind] or VX.C.cyan,
		BorderSizePixel = 0,
	}, frame)
	VX.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 8),
		Size = UDim2.new(1, -48, 1, -16),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextColor3 = VX.C.white,
		Text = text,
	}, frame)
	local dismiss
	local closer = VX.make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
	}, frame)
	VX.icon(closer, "close", 12, VX.C.muted)
	dismiss = function()
		if frame.Parent then
			frame:Destroy()
			local y = 16
			for _, child in ipairs(VX.toastLayer:GetChildren()) do
				if child:IsA("Frame") then
					child.Position = UDim2.new(1, -16, 0, y)
					y += 64
				end
			end
		end
	end
	closer.Activated:Connect(dismiss)
	local y = 16
	for _, child in ipairs(VX.toastLayer:GetChildren()) do
		if child:IsA("Frame") then
			child.Position = UDim2.new(1, -16, 0, y)
			y += 64
		end
	end
	task.delay(3.4, dismiss)
end

VX.requestSave = function()
	if VX.saveQueued or typeof(writefile) ~= "function" then
		return
	end
	VX.saveQueued = true
	task.delay(0.45, function()
		VX.saveQueued = false
		if not VX.alive then
			return
		end
		local ok, encoded = pcall(function()
			return VX.HttpService:JSONEncode({ version = 5, global = VX.G })
		end)
		if not ok then
			warn("[VEXORA] Could not encode settings: " .. tostring(encoded))
			return
		end
		local wrote, err = pcall(writefile, "VEXORA_5_settings.json", encoded)
		if wrote then
			VX.storageMode = "file"
			VX.storageNote = "Saved in VEXORA_5_settings.json on this device."
		else
			VX.storageMode = "session"
			VX.storageNote = "Couldn't write the settings file. Export a copy to keep it."
			if not VX.saveWarned then
				VX.saveWarned = true
				warn("[VEXORA] Settings file was not written: " .. tostring(err))
				VX.notify("Settings stayed in this session. The file could not be written.", "warning")
			end
		end
	end)
end

VX.applyCrosshair = function()
	for _, child in ipairs(VX.crosshairRoot:GetChildren()) do
		child:Destroy()
	end
	local crosshair = VX.P.crosshair
	if not crosshair.enabled then
		return
	end
	local color = VX.COLOR_VALUES[crosshair.color] or VX.C.white
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
		frame.Parent = VX.crosshairRoot
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

VX.applyFov = function(smooth)
	if type(VX.P.fov) ~= "number" then
		return
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local goal = VX.P.fov
	if smooth and VX.P.smoothFov and not VX.P.reducedMotion then
		VX.TweenService:Create(camera, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			FieldOfView = goal,
		}):Play()
	else
		camera.FieldOfView = goal
	end
	VX.setWatch("fov", "Field of view    " .. VX.fovText())
end

VX.applyHud = function()
	VX.hud.Visible = VX.bootDone and VX.P.hud.visible == true
	if not VX.hudDrag then
		VX.hud.Position = UDim2.fromOffset(VX.P.hud.x or 16, VX.P.hud.y or 16)
	end
end

VX.setLowGraphics = function(on)
	local ok, err = pcall(function()
		local settings = UserSettings():GetService("UserGameSettings")
		if on then
			if VX.previousQuality == nil then
				VX.previousQuality = settings.SavedQualityLevel
			end
			settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
		else
			if VX.previousQuality ~= nil then
				settings.SavedQualityLevel = VX.previousQuality
			end
			VX.previousQuality = nil
		end
	end)
	if not ok then
		VX.P.lowGraphics = false
		warn("[VEXORA] Graphics quality was not changed: " .. tostring(err))
		VX.notify("Graphics quality can't be changed on this client.", "error")
		return false
	end
	VX.P.lowGraphics = on
	VX.setWatch("graphics", "Graphics    " .. VX.graphicsText())
	return true
end

VX.applyChrome = function()
	if not VX.G.sidebar and not VX.G.dock then
		VX.G.dock = true
	end
	VX.sidebar.Visible = VX.G.sidebar
	local side = VX.G.sidebar and VX.SIDE or 0
	VX.main.Position = UDim2.fromOffset(side, 0)
	VX.main.Size = UDim2.new(1, -side, 1, 0)
	VX.grid.Visible = VX.P.grid ~= false
	VX.pulseLayer.Visible = VX.P.pulses ~= false and VX.P.reducedMotion ~= true
	VX.glow.Visible = true
	VX.dock.Visible = VX.G.dock and VX.bootDone
	VX.uiScale.Scale = VX.computeScale()
	local camera = workspace.CurrentCamera
	if camera then
		VX.dockScale.Scale = math.clamp(math.min(1, (camera.ViewportSize.X - 24) / 340), 0.75, 1)
	end
	if VX.windowOpen then
		VX.window.GroupTransparency = VX.shownTransparency()
	end
end

VX.applyAll = function()
	VX.applyChrome()
	VX.applyAccent()
	VX.applyCrosshair()
	VX.applyHud()
	VX.applyFov(false)
	if VX.graphicsAvailable then
		VX.setLowGraphics(VX.P.lowGraphics == true)
	end
end

VX.refreshHeader = function()
	local names = {
		Home = "Home",
		Games = "Games",
		Universal = "Universal",
		Urban = "Urban Reload",
		Settings = "Settings",
	}
	VX.title.Text = names[VX.currentPage] or "VEXORA"
	local selected = VX.gameById(VX.selectedId)
	VX.subtitle.Text = "VEXORA   /   5.0   /   " .. (selected and selected.name or "No profile")
end

VX.refreshNav = function()
	for page, group in pairs(VX.navButtons) do
		local selected = page == VX.currentPage
		for _, buttonObj in ipairs({ group.side, group.dock }) do
			if buttonObj then
				buttonObj:SetAttribute("Selected", selected)
				buttonObj.BackgroundColor3 = selected and VX.C.hover or (buttonObj.Parent == VX.dockItems and VX.C.card or VX.C.panel)
				local holder = buttonObj:FindFirstChild("Icon")
				if holder then
					VX.recolor(holder, selected and VX.C.white or VX.C.muted)
				end
				local mark = buttonObj:FindFirstChild("Mark")
				if mark then
					mark.Visible = selected
					mark.BackgroundColor3 = VX.accentColor()
				end
			end
		end
	end
end

 function VX.layoutBody()
	local showTabs = VX.currentPage == "Universal"
	VX.tabBar.Visible = showTabs
	VX.tabBar.Size = UDim2.new(1, 0, 0, showTabs and 40 or 0)
	VX.content.Position = UDim2.fromOffset(0, showTabs and 40 or 0)
	VX.content.Size = UDim2.new(1, 0, 1, showTabs and -40 or 0)
	for _, child in ipairs(VX.tabBar:GetChildren()) do
		if child:IsA("TextButton") then
			local on = child.Name == VX.currentTab
			child.BackgroundColor3 = on and VX.C.hover or VX.C.bg
			child.TextColor3 = on and VX.C.white or VX.C.muted
		end
	end
end

 function VX.note(parent, text)
	local rows = math.clamp(math.ceil(#text / 62), 2, 6)
	local label = VX.textLabel(parent, text, 12, VX.C.muted, false, rows * 16)
	label.TextWrapped = true
	label.TextTruncate = Enum.TextTruncate.None
	label.TextYAlignment = Enum.TextYAlignment.Top
	return label
end

 function VX.stat(parent, text, key)
	local label = VX.textLabel(parent, text, 13, VX.C.white, false, 18)
	if key then
		VX.watch(key, label)
	end
	return label
end

VX.closeModal = function()
	if not VX.modalOpen then
		return
	end
	VX.modalOpen = false
	local fade = VX.tween(VX.modalDim, 0.14, { BackgroundTransparency = 1 })
	VX.tween(VX.modalPanel, 0.14, { Position = UDim2.new(0.5, 0, 0.5, 10) })
	fade.Completed:Connect(function()
		if not VX.modalOpen then
			VX.modalDim.Visible = false
			VX.modalPanel.Visible = false
		end
	end)
end

VX.openModal = function(opts)
	VX.closeDropdown()
	if VX.paletteOpen then
		VX.closePalette()
	end
	VX.modalOpen = true
	VX.modalTitle.Text = opts.title or ""
	VX.modalBody.Text = opts.body or ""
	VX.modalBox.Visible = opts.text ~= nil or opts.editable == true
	VX.modalBox.Text = opts.text or ""
	VX.modalBox.PlaceholderText = opts.placeholder or ""
	VX.modalBox.TextEditable = opts.editable ~= false
	if opts.editable then
		VX.modalBox.TextEditable = true
	end
	if opts.text and opts.editable == nil then
		VX.modalBox.TextEditable = true
	end
	for _, child in ipairs(VX.modalButtons:GetChildren()) do
		child:Destroy()
	end
	local list = opts.buttons or { { text = "Close", primary = true } }
	for index, spec in ipairs(list) do
		local item = VX.button(VX.modalButtons, spec.text, function()
			local value = VX.modalBox.Text
			VX.closeModal()
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
		item.Parent = VX.modalButtons
	end
	VX.modalDim.Visible = true
	VX.modalDim.BackgroundTransparency = 1
	VX.modalPanel.Visible = true
	VX.modalPanel.Position = UDim2.new(0.5, 0, 0.5, 12)
	VX.tween(VX.modalDim, 0.16, { BackgroundTransparency = 0.42 })
	VX.tween(VX.modalPanel, 0.18, { Position = UDim2.fromScale(0.5, 0.5) })
	if VX.modalBox.Visible then
		task.defer(function()
			if VX.modalBox.Parent and VX.modalOpen then
				VX.modalBox:CaptureFocus()
				if opts.text then
					VX.modalBox.CursorPosition = #VX.modalBox.Text + 1
					VX.modalBox.SelectionStart = 1
				end
			end
		end)
	end
end

VX.confirm = function(titleText, bodyText, onYes)
	VX.openModal({
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

VX.promptBox = function(titleText, placeholder, onYes)
	VX.openModal({
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
					VX.notify("Enter a name first.", "warning")
				end
			end },
		},
	})
end

VX.copyText = function(value, label)
	local text = tostring(value)
	if typeof(setclipboard) == "function" then
		local ok = pcall(setclipboard, text)
		if ok then
			VX.notify("Copied " .. label .. ".", "success")
			return
		end
	end
	VX.openModal({
		title = "Copy " .. label,
		body = "Clipboard write isn't available here. Select the text and copy it.",
		text = text,
		buttons = { { text = "Close", primary = true } },
	})
end

VX.pushRecent = function(id)
	for index = #VX.G.recents, 1, -1 do
		if VX.G.recents[index] == id then
			table.remove(VX.G.recents, index)
		end
	end
	table.insert(VX.G.recents, 1, id)
	while #VX.G.recents > 8 do
		table.remove(VX.G.recents)
	end
	VX.requestSave()
end

 function VX.rememberQuery(query)
	if query == nil or query == "" then
		return
	end
	for index = #VX.recentQueries, 1, -1 do
		if VX.recentQueries[index] == query then
			table.remove(VX.recentQueries, index)
		end
	end
	table.insert(VX.recentQueries, 1, query)
	while #VX.recentQueries > 6 do
		table.remove(VX.recentQueries)
	end
end

 function VX.fillPalette()
	for _, child in ipairs(VX.paletteList:GetChildren()) do
		child:Destroy()
	end
	VX.make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, VX.paletteList)
	table.clear(VX.paletteRows)
	local query = string.lower(VX.paletteBox.Text or "")
	local order = 0
	local function addHeader(text)
		order += 1
		local label = VX.make("TextLabel", {
			LayoutOrder = order,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = VX.C.muted,
			Text = string.upper(text),
		}, VX.paletteList)
		table.insert(VX.paletteRows, { header = true, button = label })
	end
	local function addFeature(def, score)
		order += 1
		local row = VX.make("TextButton", {
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundColor3 = VX.C.card,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
		}, VX.paletteList)
		VX.corner(row, 8)
		VX.icon(row, def.icon or "info", 16, VX.C.white).Position = UDim2.fromOffset(20, 24)
		VX.make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(40, 6),
			Size = UDim2.new(1, -130, 0, 18),
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = VX.C.white,
			Text = def.name,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)
		VX.make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(40, 26),
			Size = UDim2.new(1, -56, 0, 16),
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = VX.C.muted,
			Text = def.description or "",
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)
		VX.make("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, 8),
			Size = UDim2.fromOffset(80, 16),
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = VX.C.muted,
			Text = def.category or "",
		}, row)
		row.Activated:Connect(function()
			VX.rememberQuery(VX.paletteBox.Text)
			VX.useFeature(def.id)
		end)
		table.insert(VX.paletteRows, { feature = def, score = score, button = row })
	end
	if query == "" and #VX.G.recents > 0 then
		addHeader("Recent")
		for index = 1, math.min(4, #VX.G.recents) do
			local def = VX.features[VX.G.recents[index]]
			if def then
				addFeature(def, 1)
			end
		end
		addHeader("All")
	end
	local ranked = {}
	for _, id in ipairs(VX.featureOrder) do
		local def = VX.features[id]
		local value = VX.scoreFeature(query, def)
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
		VX.make("TextLabel", {
			LayoutOrder = order,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 48),
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = VX.C.muted,
			Text = "No matching features",
		}, VX.paletteList)
	end
	for _, item in ipairs(ranked) do
		addFeature(item.def, item.score)
	end
	local selectable = 0
	for _, row in ipairs(VX.paletteRows) do
		if row.feature then
			selectable += 1
			row.button.BackgroundColor3 = selectable == VX.paletteIndex and VX.C.hover or VX.C.card
		end
	end
	if selectable == 0 then
		VX.paletteIndex = 1
	else
		VX.paletteIndex = math.clamp(VX.paletteIndex, 1, selectable)
	end
end

 function VX.selectedPaletteFeature()
	local index = 0
	for _, row in ipairs(VX.paletteRows) do
		if row.feature then
			index += 1
			if index == VX.paletteIndex then
				return row.feature
			end
		end
	end
	return nil
end

 function VX.movePalette(delta)
	local count = 0
	for _, row in ipairs(VX.paletteRows) do
		if row.feature then
			count += 1
		end
	end
	if count == 0 then
		return
	end
	VX.paletteIndex = math.clamp(VX.paletteIndex + delta, 1, count)
	local index = 0
	for _, row in ipairs(VX.paletteRows) do
		if row.feature then
			index += 1
			row.button.BackgroundColor3 = index == VX.paletteIndex and VX.C.hover or VX.C.card
		end
	end
end

VX.closePalette = function()
	if not VX.paletteOpen then
		return
	end
	VX.paletteOpen = false
	pcall(function()
		VX.ContextActionService:UnbindAction("VEXORA_Palette")
	end)
	VX.tween(VX.paletteDim, 0.12, { BackgroundTransparency = 1 })
	local fade = VX.tween(VX.palettePanel, 0.12, { GroupTransparency = 1 })
	fade.Completed:Connect(function()
		if not VX.paletteOpen then
			VX.paletteDim.Visible = false
			VX.palettePanel.Visible = false
		end
	end)
end

VX.openPalette = function()
	if not VX.bootDone then
		return
	end
	VX.closeDropdown()
	if VX.modalOpen then
		VX.closeModal()
	end
	if VX.paletteOpen then
		VX.paletteBox:CaptureFocus()
		return
	end
	VX.paletteOpen = true
	VX.paletteDim.Visible = true
	VX.paletteDim.BackgroundTransparency = 1
	VX.palettePanel.Visible = true
	VX.palettePanel.GroupTransparency = 1
	VX.paletteBox.Text = ""
	VX.paletteIndex = 1
	VX.fillPalette()
	VX.tween(VX.paletteDim, 0.16, { BackgroundTransparency = 0.4 })
	VX.tween(VX.palettePanel, 0.16, { GroupTransparency = 0 })
	VX.ContextActionService:BindActionAtPriority("VEXORA_Palette", function(_, state, input)
		if state ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end
		if input.KeyCode == Enum.KeyCode.Up then
			VX.movePalette(-1)
			return Enum.ContextActionResult.Sink
		elseif input.KeyCode == Enum.KeyCode.Down then
			VX.movePalette(1)
			return Enum.ContextActionResult.Sink
		elseif input.KeyCode == Enum.KeyCode.Return then
			local def = VX.selectedPaletteFeature()
			local query = VX.paletteBox.Text
			if def then
				VX.rememberQuery(query)
				VX.useFeature(def.id)
			end
			return Enum.ContextActionResult.Sink
		elseif input.KeyCode == Enum.KeyCode.Escape then
			VX.suppressEscape = true
			VX.closePalette()
			task.delay(0.05, function()
				VX.suppressEscape = false
			end)
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, 3000, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Return, Enum.KeyCode.Escape)
	task.defer(function()
		if VX.paletteOpen then
			VX.paletteBox:CaptureFocus()
		end
	end)
end

VX.paletteBox:GetPropertyChangedSignal("Text"):Connect(function()
	if VX.paletteOpen then
		VX.paletteIndex = 1
		VX.fillPalette()
	end
end)
VX.paletteDim.Activated:Connect(function()
	VX.closePalette()
end)

VX.ensureWindow = function()
	if VX.windowOpen then
		return
	end
	VX.windowOpen = true
	VX.window.Visible = true
	VX.window.Position = UDim2.new(0.5, 0, 0.5, 12)
	VX.tween(VX.window, 0.26, {
		GroupTransparency = VX.shownTransparency(),
		Position = UDim2.fromScale(0.5, 0.5),
	})
end

VX.toggleWindow = function()
	if not VX.bootDone then
		return
	end
	if VX.windowOpen then
		VX.windowOpen = false
		local fade = VX.tween(VX.window, 0.18, { GroupTransparency = 1 })
		fade.Completed:Connect(function()
			if not VX.windowOpen and VX.window.Parent then
				VX.window.Visible = false
			end
		end)
	else
		VX.ensureWindow()
	end
end

VX.navigate = function(page, tab, force)
	if page == "Universal" then
		tab = tab or VX.currentTab or "Camera"
	else
		tab = nil
	end
	if not force and page == VX.currentPage and tab == VX.currentTab then
		VX.refreshNav()
		VX.layoutBody()
		VX.refreshHeader()
		return
	end
	VX.navToken += 1
	local token = VX.navToken
	VX.ensureWindow()
	local fade = VX.tween(VX.content, 0.12, { GroupTransparency = 1 })
	pcall(function()
		fade.Completed:Wait()
	end)
	if token ~= VX.navToken or not VX.alive then
		return
	end
	VX.currentPage = page
	if tab then
		VX.currentTab = tab
	end
	VX.closeDropdown()
	VX.refreshHeader()
	VX.refreshNav()
	VX.layoutBody()
	local ok, err = xpcall(function()
		VX.renderPage()
	end, debug.traceback)
	if not ok then
		warn("[VEXORA] Page failed: " .. tostring(err))
		VX.notify("That page hit an error. The details are in the output.", "error")
	end
	VX.tween(VX.content, 0.18, { GroupTransparency = 0 })
end

VX.useFeature = function(id)
	local def = VX.features[id]
	if not def then
		VX.notify("That feature is missing.", "error")
		return
	end
	VX.pushRecent(id)
	VX.closePalette()
	if def.opens == false then
		def.run()
		return
	end
	VX.ensureWindow()
	def.run()
end

 function VX.presetNames()
	local list = {}
	for name in pairs(VX.G.presets) do
		table.insert(list, name)
	end
	table.sort(list)
	return list
end

 function VX.applyCrosshairPreset(preset, label)
	VX.P.crosshair = VX.deepCopy(preset)
	VX.applyCrosshair()
	VX.requestSave()
	VX.notify(label .. " crosshair applied on your screen.", "success")
end

 VX.BUILTIN_PRESETS = {
	Precise = { enabled = true, style = "Cross", size = 6, thickness = 1, gap = 3, opacity = 1, color = "White" },
	Dot = { enabled = true, style = "Dot", size = 4, thickness = 2, gap = 0, opacity = 1, color = "White" },
	Open = { enabled = true, style = "Cross", size = 12, thickness = 2, gap = 7, opacity = 1, color = "Cyan" },
	Minimal = { enabled = true, style = "Minimal", size = 6, thickness = 1, gap = 2, opacity = 0.9, color = "White" },
}

 function VX.savePreset()
	VX.promptBox("Save crosshair preset", "Name", function(name)
		if #name > 24 then
			VX.notify("Use 24 characters or fewer.", "warning")
			return
		end
		VX.G.presets[name] = VX.deepCopy(VX.P.crosshair)
		VX.requestSave()
		VX.notify("Preset \"" .. name .. "\" saved for this session" .. (VX.storageMode == "file" and " and file." or "."), "success")
		if VX.currentPage == "Universal" and VX.currentTab == "Crosshair" then
			VX.renderPage()
		end
	end)
end

 function VX.renderHome()
	local profile = VX.make("Frame", {
		LayoutOrder = VX.lay(VX.scroll),
		BackgroundColor3 = VX.C.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 108),
	}, VX.scroll)
	VX.corner(profile, 12)
	VX.stroke(profile, 0.5)
	local avatar = VX.make("ImageLabel", {
		Position = UDim2.fromOffset(14, 22),
		Size = UDim2.fromOffset(64, 64),
		BackgroundColor3 = VX.C.hover,
		BorderSizePixel = 0,
	}, profile)
	VX.corner(avatar, 12)
	task.spawn(function()
		local ok, image = pcall(function()
			return VX.Players:GetUserThumbnailAsync(VX.player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)
		if ok and avatar.Parent and type(image) == "string" then
			avatar.Image = image
		end
	end)
	VX.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(94, 16),
		Size = UDim2.new(1, -110, 0, 22),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = VX.C.white,
		Text = VX.player.DisplayName,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, profile)
	VX.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(94, 38),
		Size = UDim2.new(1, -110, 0, 16),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = VX.C.muted,
		Text = "@" .. VX.player.Name,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, profile)
	local experience = VX.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(94, 58),
		Size = UDim2.new(1, -110, 0, 16),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = VX.C.muted,
		Text = "Experience    " .. VX.experienceName,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, profile)
	VX.watch("experience", experience)
	local sessionLabel = VX.make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(94, 76),
		Size = UDim2.new(1, -110, 0, 16),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = VX.C.white,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "",
	}, profile)
	local function profileLine()
		local selected = VX.gameById(VX.selectedId)
		return (selected and selected.name or "No profile") .. "    ·    Session " .. VX.formatTime(os.clock() - VX.sessionStart)
	end
	sessionLabel.Text = profileLine()
	VX.watch("profileLine", sessionLabel)

	local columns = VX.make("Frame", {
		LayoutOrder = VX.lay(VX.scroll),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 360),
	}, VX.scroll)
	local function column(x, width)
		local frame = VX.make("Frame", {
			Position = UDim2.new(x, x == 0 and 0 or 4, 0, 0),
			Size = UDim2.new(width, x == 0 and -4 or -4, 1, 0),
			BackgroundColor3 = VX.C.card,
			BorderSizePixel = 0,
		}, columns)
		VX.corner(frame, 12)
		VX.stroke(frame, 0.5)
		VX.make("UIPadding", {
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}, frame)
		VX.make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, frame)
		frame:SetAttribute("Lay", 0)
		return frame
	end
	local server = column(0, 0.5)
	local environment = column(0.5, 0.5)
	VX.textLabel(server, "Server", 15, VX.C.white, true, 20)
	VX.textLabel(server, "This server, not your session clock", 11, VX.C.muted, false, 16)
	VX.stat(server, string.format("Players    %d / %d", #VX.Players:GetPlayers(), VX.Players.MaxPlayers), "players")
	VX.stat(server, "Place ID    " .. tostring(game.PlaceId), nil)
	VX.stat(server, game.JobId == "" and "Job ID    Empty in this session" or ("Job ID    " .. string.sub(game.JobId, 1, 16)), "job")
	VX.stat(server, VX.fpsValue and string.format("FPS    %d", math.floor(VX.fpsValue + 0.5)) or "FPS    …", "fps")
	VX.stat(server, VX.pingText(), "ping")
	VX.stat(server, "Session    " .. VX.formatTime(os.clock() - VX.sessionStart), "session")
	VX.textLabel(server, "Server uptime    Not available on the client", 12, VX.C.muted, false, 18)
	VX.button(server, "Copy place ID", function()
		VX.copyText(game.PlaceId, "place ID")
	end)
	VX.button(server, "Copy job ID", function()
		if game.JobId == "" then
			VX.notify("This session has no Job ID to copy.", "warning")
			return
		end
		VX.copyText(game.JobId, "job ID")
	end)

	VX.textLabel(environment, "Environment", 15, VX.C.white, true, 20)
	VX.textLabel(environment, "This client", 11, VX.C.muted, false, 16)
	VX.stat(environment, "Platform    " .. VX.platformText(), nil)
	VX.stat(environment, "Input    " .. tostring(VX.lastInput.Name), "input")
	VX.stat(environment, "Resolution    " .. VX.resolutionText(), "res")
	VX.stat(environment, "Field of view    " .. VX.fovText(), "fov")
	VX.stat(environment, VX.memoryText(), "mem")
	VX.stat(environment, "Graphics    " .. VX.graphicsText(), "graphics")
	VX.stat(environment, "Clipboard    " .. (typeof(setclipboard) == "function" and "Write available" or "Manual copy"), nil)
	VX.stat(environment, "Storage    " .. (VX.storageMode == "file" and "Local file" or "This session"), "storage")
	VX.stat(environment, "Menu    Ready", nil)

	local actions = VX.make("Frame", {
		LayoutOrder = VX.lay(VX.scroll),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 80),
	}, VX.scroll)
	local actionGrid = VX.make("UIGridLayout", {
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
		VX.button(actions, item[1], function()
			VX.useFeature(item[2])
		end, {
			order = index,
			size = UDim2.fromScale(1, 1),
		})
	end
	actionGrid.Parent = actions

	local favouriteCard = VX.stack(VX.scroll, 4)
	VX.textLabel(favouriteCard, "Favourites", 15, VX.C.white, true, 20)
	local anyFavourite = false
	for _, id in ipairs(VX.featureOrder) do
		if VX.G.favorites[id] and VX.features[id] then
			anyFavourite = true
			VX.button(favouriteCard, VX.features[id].name, function()
				VX.useFeature(id)
			end)
		end
	end
	if not anyFavourite then
		VX.note(favouriteCard, "Star a tool and it will show up here.")
	end
end

 function VX.renderGames()
	VX.textLabel(VX.scroll, "Which game would you like to use VEXORA with?", 20, VX.C.white, true, 28)
	VX.note(VX.scroll, "You are in " .. VX.experienceName .. ". Pick a profile. A profile only changes this menu and your local client settings.")
	local row = nil
	for index, entry in ipairs(VX.GAMES) do
		if (index - 1) % 2 == 0 then
			row = VX.make("Frame", {
				LayoutOrder = VX.lay(VX.scroll),
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 292),
			}, VX.scroll)
		end
		local column = (index - 1) % 2
		local card = VX.make("Frame", {
			Position = UDim2.new(column * 0.5, column == 0 and 0 or 4, 0, 0),
			Size = UDim2.new(0.5, -4, 1, 0),
			BackgroundColor3 = VX.C.card,
			BorderSizePixel = 0,
		}, row)
		VX.corner(card, 12)
		local outline = VX.stroke(card, VX.selectedId == entry.id and 0 or 0.45, VX.selectedId == entry.id and VX.accentColor() or VX.C.border)
		if VX.selectedId == entry.id then
			VX.trackAccent(outline, "Color")
		end
		card.MouseEnter:Connect(function()
			VX.tween(card, 0.14, { BackgroundColor3 = VX.C.hover })
		end)
		card.MouseLeave:Connect(function()
			VX.tween(card, 0.14, { BackgroundColor3 = VX.C.card })
		end)
		local shot = VX.make("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.new(1, -24, 0, 140),
			BackgroundColor3 = VX.C.hover,
			BorderSizePixel = 0,
			ClipsDescendants = true,
		}, card)
		VX.corner(shot, 10)
		local mark = VX.make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 42,
			TextColor3 = VX.C.white,
			Text = "V",
		}, shot)
		if entry.universeId then
			local image = VX.make("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ScaleType = Enum.ScaleType.Crop,
				BorderSizePixel = 0,
				ZIndex = 2,
				Image = "rbxthumb://type=GameThumbnail&id=" .. tostring(entry.universeId) .. "&w=768&h=432",
			}, shot)
			local badgeIcon = VX.make("ImageLabel", {
				BackgroundColor3 = VX.C.panel,
				Position = UDim2.new(0, 8, 1, -36),
				Size = UDim2.fromOffset(28, 28),
				ScaleType = Enum.ScaleType.Crop,
				ZIndex = 3,
				Image = "rbxthumb://type=GameIcon&id=" .. tostring(entry.universeId) .. "&w=150&h=150",
			}, shot)
			VX.corner(badgeIcon, 8)
			image.Parent = shot
			mark.ZIndex = 1
		else
			for gx = 0, 8 do
				VX.make("Frame", {
					Position = UDim2.new(gx / 8, 0, 0, 0),
					Size = UDim2.new(0, 1, 1, 0),
					BackgroundColor3 = VX.C.white,
					BackgroundTransparency = 0.9,
					BorderSizePixel = 0,
				}, shot)
			end
			mark.Text = "V"
		end
		if entry.id == "urban" and VX.inUrban() then
			local badge = VX.make("TextLabel", {
				Position = UDim2.fromOffset(8, 8),
				Size = UDim2.fromOffset(108, 20),
				BackgroundColor3 = VX.C.bg,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = VX.C.green,
				Text = "Recommended",
				ZIndex = 4,
				BorderSizePixel = 0,
			}, shot)
			VX.corner(badge, 6)
		end
		VX.make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 160),
			Size = UDim2.new(1, -24, 0, 22),
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = VX.C.white,
			Text = entry.name,
		}, card)
		VX.make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 184),
			Size = UDim2.new(1, -24, 0, 32),
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = VX.C.muted,
			Text = entry.blurb,
		}, card)
		local statusText = "Ready in this experience"
		local statusColor = VX.C.cyan
		if entry.placeId then
			if game.PlaceId == entry.placeId then
				statusText = "In this game"
				statusColor = VX.C.green
			else
				statusText = "Not in this game · local profile only"
				statusColor = VX.C.muted
			end
		end
		VX.make("TextLabel", {
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
		VX.button(card, VX.selectedId == entry.id and "Selected" or "Use this profile", function()
			VX.selectedId = entry.id
			VX.G.perGame[tostring(game.PlaceId)] = entry.id
			VX.requestSave()
			VX.notify(entry.name .. " is the active profile.", "success")
			VX.navigate("Home", nil, true)
		end, {
			primary = true,
			position = UDim2.fromOffset(12, 244),
			size = UDim2.new(1, -24, 0, 32),
		})
	end
end

 function VX.renderCamera()
	VX.textLabel(VX.scroll, "Camera", 20, VX.C.white, true, 26)
	VX.note(VX.scroll, "These change your camera only. The game can set its own field of view again afterwards.")
	local card = VX.stack(VX.scroll, 8)
	local currentFov = VX.P.fov or (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or VX.originalFOV
	VX.slider(card, "Field of view", 50, 110, currentFov, 1, "fov", function(value, final)
		VX.P.fov = value
		VX.applyFov(final and VX.P.smoothFov)
		VX.requestSave()
	end)
	VX.toggle(card, "Smooth field-of-view changes", VX.P.smoothFov, "smooth-fov", function(on)
		VX.P.smoothFov = on
		VX.requestSave()
	end)
	VX.textLabel(card, "Camera type    " .. tostring(workspace.CurrentCamera and workspace.CurrentCamera.CameraType.Name or "Unavailable"), 13, VX.C.white, false, 18)
	VX.note(card, "Camera type stays with the game. VEXORA does not take over the camera.")
	VX.button(card, "Restore original field of view", function()
		VX.useFeature("fov-reset")
	end)
end

 function VX.renderInterface()
	VX.textLabel(VX.scroll, "Interface", 20, VX.C.white, true, 26)
	VX.note(VX.scroll, "Appearance of this menu. Reduced motion turns off the travelling pulses and shortens transitions.")
	local card = VX.stack(VX.scroll, 8)
	VX.slider(card, "UI scale", 0.85, 1.15, VX.P.uiScale, 0.01, "ui-scale", function(value)
		VX.P.uiScale = value
		VX.applyChrome()
		VX.requestSave()
	end)
	VX.slider(card, "Opacity", 0.7, 1, VX.P.opacity, 0.01, "opacity", function(value)
		VX.P.opacity = value
		VX.applyChrome()
		VX.requestSave()
	end)
	VX.slider(card, "Animation intensity", 0.6, 1.4, VX.P.anim, 0.05, "anim", function(value)
		VX.P.anim = value
		VX.requestSave()
	end)
	VX.dropdown(card, "Accent", { "Cyan", "Violet", "Green", "White" }, VX.P.accent, function(choice)
		VX.P.accent = choice
		VX.applyAccent()
		VX.refreshNav()
		VX.requestSave()
		VX.renderPage()
	end)
	VX.toggle(card, "Grid background", VX.P.grid, "grid", function(on)
		VX.P.grid = on
		VX.applyChrome()
		VX.requestSave()
	end)
	VX.toggle(card, "RGB pulses", VX.P.pulses, "pulses", function(on)
		VX.P.pulses = on
		VX.applyChrome()
		VX.requestSave()
	end)
	VX.toggle(card, "Reduced motion", VX.P.reducedMotion, "motion", function(on)
		VX.P.reducedMotion = on
		VX.applyChrome()
		VX.requestSave()
	end)
	VX.toggle(card, "Notifications", VX.P.notifications, "notifications", function(on)
		VX.P.notifications = on
		VX.requestSave()
		if on then
			VX.notify("Notifications are on.", "info")
		end
	end)
	VX.toggle(card, "Sidebar", VX.G.sidebar, nil, function(on)
		VX.G.sidebar = on
		if not VX.G.sidebar and not VX.G.dock then
			VX.G.dock = true
			VX.notify("The dock stays on so navigation is still reachable.", "warning")
		end
		VX.applyChrome()
		VX.requestSave()
		VX.renderPage()
	end)
	VX.toggle(card, "Bottom dock", VX.G.dock, nil, function(on)
		VX.G.dock = on
		if not VX.G.sidebar and not VX.G.dock then
			VX.G.sidebar = true
			VX.notify("The sidebar stays on so navigation is still reachable.", "warning")
		end
		VX.applyChrome()
		VX.requestSave()
		VX.renderPage()
	end)
	VX.toggle(card, "Performance HUD", VX.P.hud.visible, "toggle-hud", function(on)
		VX.P.hud.visible = on
		VX.applyHud()
		VX.requestSave()
	end)
	VX.button(card, "Reset HUD position", function()
		VX.useFeature("reset-hud")
	end)
	VX.button(card, "Reset menu position", function()
		VX.useFeature("reset-position")
	end)
end

 function VX.renderCrosshair()
	VX.textLabel(VX.scroll, "Crosshair", 20, VX.C.white, true, 26)
	VX.note(VX.scroll, "Drawn on your screen only. It does not aim, shoot, or read other players.")
	local card = VX.stack(VX.scroll, 8)
	VX.toggle(card, "Show crosshair", VX.P.crosshair.enabled, "crosshair", function(on)
		VX.P.crosshair.enabled = on
		VX.applyCrosshair()
		VX.requestSave()
	end)
	VX.dropdown(card, "Style", { "Cross", "Dot", "Circle", "Minimal" }, VX.P.crosshair.style, function(choice)
		VX.P.crosshair.style = choice
		VX.P.crosshair.enabled = true
		VX.applyCrosshair()
		VX.requestSave()
		VX.renderPage()
	end)
	VX.dropdown(card, "Colour", VX.COLOR_CHOICES, VX.P.crosshair.color, function(choice)
		VX.P.crosshair.color = choice
		VX.applyCrosshair()
		VX.requestSave()
	end)
	VX.slider(card, "Size", 2, 18, VX.P.crosshair.size, 1, nil, function(value)
		VX.P.crosshair.size = value
		VX.P.crosshair.enabled = true
		VX.applyCrosshair()
		VX.requestSave()
	end)
	VX.slider(card, "Thickness", 1, 6, VX.P.crosshair.thickness, 1, nil, function(value)
		VX.P.crosshair.thickness = value
		VX.applyCrosshair()
		VX.requestSave()
	end)
	VX.slider(card, "Gap", 0, 16, VX.P.crosshair.gap, 1, nil, function(value)
		VX.P.crosshair.gap = value
		VX.applyCrosshair()
		VX.requestSave()
	end)
	VX.slider(card, "Opacity", 0.25, 1, VX.P.crosshair.opacity, 0.05, nil, function(value)
		VX.P.crosshair.opacity = value
		VX.applyCrosshair()
		VX.requestSave()
	end)
	for _, name in ipairs({ "Precise", "Dot", "Open", "Minimal" }) do
		VX.button(card, name .. " preset", function()
			VX.applyCrosshairPreset(VX.BUILTIN_PRESETS[name], name)
			VX.renderPage()
		end)
	end
	local saved = VX.presetNames()
	if #saved > 0 then
		VX.dropdown(card, "Saved presets", saved, saved[1], function(choice)
			if VX.G.presets[choice] then
				VX.applyCrosshairPreset(VX.G.presets[choice], choice)
				VX.renderPage()
			end
		end)
	end
	VX.button(card, "Save preset", function()
		VX.savePreset()
	end, { primary = true })
	VX.button(card, "Reset crosshair", function()
		VX.P.crosshair = VX.defaultProfile().crosshair
		VX.applyCrosshair()
		VX.requestSave()
		VX.notify("Crosshair reset.", "info")
		VX.renderPage()
	end)
end

 function VX.renderPerformance()
	VX.textLabel(VX.scroll, "Performance", 20, VX.C.white, true, 26)
	VX.note(VX.scroll, "Readings come from this client. Low graphics changes only your quality setting and can be turned back off.")
	local card = VX.stack(VX.scroll, 6)
	VX.stat(card, VX.fpsValue and string.format("FPS    %d", math.floor(VX.fpsValue + 0.5)) or "FPS    …", "fps")
	VX.stat(card, VX.pingText(), "ping")
	VX.stat(card, "Session    " .. VX.formatTime(os.clock() - VX.sessionStart), "session")
	VX.stat(card, VX.memoryText(), "mem")
	VX.textLabel(card, "FPS history", 13, VX.C.white, true, 18)
	local chart = VX.make("Frame", {
		LayoutOrder = VX.lay(card),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 72),
	}, card)
	VX.chartBars = {}
	local chartLayout = VX.make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 3),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, chart)
	for index = 1, 28 do
		local slot = VX.make("Frame", {
			LayoutOrder = index,
			BackgroundTransparency = 1,
			Size = UDim2.new(1 / 28, -3, 1, 0),
		}, chart)
		local bar = VX.make("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.new(1, 0, 0.08, 0),
			BackgroundColor3 = VX.C.white,
			BorderSizePixel = 0,
		}, slot)
		VX.corner(bar, 2)
		VX.chartBars[index] = bar
	end
	chartLayout.Parent = chart
	if VX.graphicsAvailable then
		VX.toggle(card, "Low graphics", VX.P.lowGraphics, "low-graphics", function(on)
			local ok = VX.setLowGraphics(on)
			if ok == false then
				return false
			end
			VX.requestSave()
			VX.notify(on and "Graphics quality lowered on this client." or "Previous graphics quality restored.", "info")
		end)
		VX.note(card, "This sets your saved graphics quality to the lowest level, then restores the previous level when you turn it off.")
	else
		VX.note(card, "Graphics quality can't be changed from this client, so the low-graphics control is hidden.")
	end
	VX.toggle(card, "Show the HUD", VX.P.hud.visible, nil, function(on)
		VX.P.hud.visible = on
		VX.applyHud()
		VX.requestSave()
	end)
end

 function VX.renderPlayers()
	VX.textLabel(VX.scroll, "Players", 20, VX.C.white, true, 26)
	VX.note(VX.scroll, "People in this server. Friend status uses Roblox's friend check and can be unavailable.")
	local controls = VX.fixedRow(VX.scroll, 36)
	controls.BackgroundTransparency = 1
	local filter = VX.make("TextBox", {
		Size = UDim2.new(1, -44, 1, 0),
		BackgroundColor3 = VX.C.card,
		Text = "",
		PlaceholderText = "Search players",
		PlaceholderColor3 = VX.C.muted,
		TextColor3 = VX.C.white,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		ClearTextOnFocus = false,
		BorderSizePixel = 0,
	}, controls)
	VX.corner(filter, 8)
	local refresh = VX.make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = VX.C.card,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, controls)
	VX.corner(refresh, 8)
	VX.icon(refresh, "refresh", 16, VX.C.white)
	local list = VX.make("ScrollingFrame", {
		LayoutOrder = VX.lay(VX.scroll),
		BackgroundColor3 = VX.C.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 220),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = VX.C.border,
		ElasticBehavior = Enum.ElasticBehavior.Never,
	}, VX.scroll)
	VX.corner(list, 12)
	local detail = VX.stack(VX.scroll, 4)
	local selectedUser = VX.player.UserId
	local detailName = VX.textLabel(detail, "", 16, VX.C.white, true, 22)
	local detailUser = VX.textLabel(detail, "", 12, VX.C.muted, false, 16)
	local detailId = VX.textLabel(detail, "", 12, VX.C.muted, false, 16)
	local detailFriend = VX.textLabel(detail, "", 12, VX.C.white, false, 16)
	local function showDetail(target)
		selectedUser = target.UserId
		detailName.Text = target.DisplayName
		detailUser.Text = "@" .. target.Name
		detailId.Text = "User ID    " .. tostring(target.UserId)
		if target.UserId == VX.player.UserId then
			detailFriend.Text = "This is you"
			return
		end
		detailFriend.Text = "Friend status    Checking"
		task.spawn(function()
			local ok, isFriend = pcall(function()
				return VX.player:IsFriendsWith(target.UserId)
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
	VX.button(detail, "Copy username", function()
		local target = VX.Players:GetPlayerByUserId(selectedUser)
		if target then
			VX.copyText(target.Name, "username")
		else
			VX.notify("That player left the server.", "warning")
		end
	end)
	VX.button(detail, "Copy user ID", function()
		VX.copyText(selectedUser, "user ID")
	end)
	local function buildList()
		for _, child in ipairs(list:GetChildren()) do
			child:Destroy()
		end
		VX.make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, list)
		VX.make("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, list)
		local query = string.lower(filter.Text)
		local shown = 0
		local people = VX.Players:GetPlayers()
		table.sort(people, function(a, b)
			return string.lower(a.DisplayName) < string.lower(b.DisplayName)
		end)
		for _, other in ipairs(people) do
			local haystack = string.lower(other.DisplayName .. " " .. other.Name .. " " .. tostring(other.UserId))
			if query == "" or string.find(haystack, query, 1, true) then
				shown += 1
				local row = VX.make("TextButton", {
					LayoutOrder = shown,
					Size = UDim2.new(1, 0, 0, 48),
					BackgroundColor3 = other.UserId == selectedUser and VX.C.hover or VX.C.panel,
					Text = "",
					AutoButtonColor = false,
					BorderSizePixel = 0,
				}, list)
				VX.corner(row, 8)
				local photo = VX.make("ImageLabel", {
					Position = UDim2.fromOffset(8, 8),
					Size = UDim2.fromOffset(32, 32),
					BackgroundColor3 = VX.C.hover,
					BorderSizePixel = 0,
				}, row)
				VX.corner(photo, 8)
				task.spawn(function()
					local ok, image = pcall(function()
						return VX.Players:GetUserThumbnailAsync(other.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
					end)
					if ok and photo.Parent and type(image) == "string" then
						photo.Image = image
					end
				end)
				VX.make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(48, 6),
					Size = UDim2.new(1, -56, 0, 18),
					Font = Enum.Font.GothamBold,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = VX.C.white,
					Text = other.DisplayName,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}, row)
				VX.make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(48, 24),
					Size = UDim2.new(1, -56, 0, 16),
					Font = Enum.Font.Gotham,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = VX.C.muted,
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
			VX.make("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 36),
				Text = "No players match that search.",
				TextColor3 = VX.C.muted,
				Font = Enum.Font.Gotham,
				TextSize = 13,
			}, list)
		end
	end
	filter:GetPropertyChangedSignal("Text"):Connect(buildList)
	refresh.Activated:Connect(buildList)
	VX.onPlayersChanged = buildList
	VX.trackPage(VX.Players.PlayerAdded:Connect(function()
		if VX.onPlayersChanged then
			VX.onPlayersChanged()
		end
	end))
	VX.trackPage(VX.Players.PlayerRemoving:Connect(function(leaving)
		if leaving.UserId == selectedUser then
			selectedUser = VX.player.UserId
			showDetail(VX.player)
		end
		if VX.onPlayersChanged then
			VX.onPlayersChanged()
		end
	end))
	showDetail(VX.player)
	buildList()
end

 function VX.renderUtilities()
	VX.textLabel(VX.scroll, "Utilities", 20, VX.C.white, true, 26)
	VX.note(VX.scroll, VX.storageNote)
	local card = VX.stack(VX.scroll, 6)
	VX.button(card, "Copy place ID", function()
		VX.copyText(game.PlaceId, "place ID")
	end)
	VX.button(card, "Copy job ID", function()
		if game.JobId == "" then
			VX.notify("This session has no Job ID.", "warning")
			return
		end
		VX.copyText(game.JobId, "job ID")
	end)
	VX.button(card, "Export settings", function()
		local ok, encoded = pcall(function()
			return VX.HttpService:JSONEncode({ version = 5, global = VX.G })
		end)
		if not ok then
			VX.notify("Settings could not be encoded.", "error")
			warn("[VEXORA] Export failed: " .. tostring(encoded))
			return
		end
		VX.openModal({
			title = "Export settings",
			body = "This text is the full settings file. Copy it if you want a backup.",
			text = encoded,
			buttons = {
				{ text = "Close" },
				{ text = "Copy", primary = true, action = function(value)
					VX.copyText(value, "settings")
				end },
			},
		})
	end, { primary = true })
	VX.button(card, "Import settings", function()
		VX.openModal({
			title = "Import settings",
			body = "Paste a VEXORA 5 export. Invalid text is rejected.",
			placeholder = "{ \"version\": 5 }",
			editable = true,
			text = "",
			buttons = {
				{ text = "Cancel" },
				{ text = "Import", primary = true, action = function(value)
					local ok, data = pcall(function()
						return VX.HttpService:JSONDecode(value)
					end)
					if not ok or type(data) ~= "table" or data.version ~= 5 or type(data.global) ~= "table" then
						VX.notify("That text isn't a VEXORA 5 settings file.", "error")
						return
					end
					if VX.P.lowGraphics then
						VX.setLowGraphics(false)
					end
					VX.G = VX.sanitizeGlobal(data.global)
					VX.P = VX.G.profiles[VX.G.activeProfile]
					VX.applyAll()
					VX.requestSave()
					VX.notify("Settings imported.", "success")
					VX.renderPage()
					VX.refreshNav()
				end },
			},
		})
	end)
	VX.textLabel(card, "Toggle menu    " .. VX.G.binds.toggle, 13, VX.C.white, false, 18)
	VX.textLabel(card, "Command palette    Ctrl + " .. VX.G.binds.palette, 13, VX.C.white, false, 18)
	VX.button(card, "Change menu key", function()
		VX.capturing = "toggle"
		VX.notify("Press a key for the menu toggle.", "info")
	end)
	VX.button(card, "Change palette key", function()
		VX.capturing = "palette"
		VX.notify("Press a key for the command palette.", "info")
	end)
	VX.button(card, "Reset all settings", function()
		VX.confirm("Reset everything?", "Clears profiles, shortcuts, favourites, and local menu settings.", function()
			if VX.P.lowGraphics then
				VX.setLowGraphics(false)
			end
			VX.G = VX.defaultGlobal()
			VX.P = VX.G.profiles.Default
			VX.selectedId = nil
			VX.applyAll()
			local camera = workspace.CurrentCamera
			if camera then
				camera.FieldOfView = VX.originalFOV
			end
			VX.requestSave()
			VX.notify("Settings reset for this session.", "success")
			VX.navigate("Games", nil, true)
		end)
	end)
	VX.textLabel(card, "Notification history", 15, VX.C.white, true, 22)
	if #VX.history == 0 then
		VX.note(card, "No notifications yet.")
	else
		for index = 1, math.min(8, #VX.history) do
			VX.textLabel(card, VX.history[index].text, 12, VX.C.muted, false, 18)
		end
	end
	VX.textLabel(card, "Recently used", 15, VX.C.white, true, 22)
	if #VX.G.recents == 0 then
		VX.note(card, "Tools you open from search will show up here.")
	else
		for _, id in ipairs(VX.G.recents) do
			local def = VX.features[id]
			if def then
				VX.button(card, def.name, function()
					VX.useFeature(id)
				end)
			end
		end
	end
end

 function VX.renderUniversal()
	if VX.currentTab == "Camera" then
		VX.renderCamera()
	elseif VX.currentTab == "Interface" then
		VX.renderInterface()
	elseif VX.currentTab == "Crosshair" then
		VX.renderCrosshair()
	elseif VX.currentTab == "Performance" then
		VX.renderPerformance()
	elseif VX.currentTab == "Players" then
		VX.renderPlayers()
	else
		VX.renderUtilities()
	end
end

 function VX.renderUrban()
	local entry = VX.gameById("urban")
	local banner = VX.make("Frame", {
		LayoutOrder = VX.lay(VX.scroll),
		BackgroundColor3 = VX.C.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 176),
		ClipsDescendants = true,
	}, VX.scroll)
	VX.corner(banner, 12)
	VX.stroke(banner, 0.45)
	VX.make("ImageLabel", {
		BackgroundColor3 = VX.C.hover,
		Size = UDim2.fromScale(1, 1),
		ScaleType = Enum.ScaleType.Crop,
		BorderSizePixel = 0,
		Image = "rbxthumb://type=GameThumbnail&id=" .. tostring(entry.universeId) .. "&w=768&h=432",
	}, banner)
	local scrim = VX.make("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 78),
		BackgroundColor3 = VX.C.bg,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, banner)
	VX.make("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0.15),
		}),
	}, scrim)
	VX.make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 14, 1, -30),
		Size = UDim2.new(1, -28, 0, 24),
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = VX.C.white,
		Text = entry.name,
		ZIndex = 3,
	}, banner)
	VX.make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 14, 1, -10),
		Size = UDim2.new(1, -28, 0, 16),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = VX.inUrban() and VX.C.green or VX.C.muted,
		Text = VX.inUrban() and "In this game" or "Not in this game",
		ZIndex = 3,
	}, banner)

	local info = VX.stack(VX.scroll, 4)
	VX.textLabel(info, "Session", 15, VX.C.white, true, 20)
	VX.note(info, VX.inUrban() and "You are in Urban Reload. The tools below are still local: crosshair, camera, and the HUD." or "You are not in Urban Reload. These controls still edit your local crosshair, camera, and HUD, and they do not change that game.")
	VX.textLabel(info, "Place ID    " .. tostring(entry.placeId), 13, VX.C.white, false, 18)
	VX.textLabel(info, "Universe ID    " .. tostring(entry.universeId), 13, VX.C.white, false, 18)
	VX.textLabel(info, "Experience    " .. VX.experienceName, 13, VX.C.muted, false, 18)
	VX.button(info, "Copy game link", function()
		VX.copyText(entry.link, "game link")
	end)

	local aim = VX.stack(VX.scroll, 6)
	VX.textLabel(aim, "Crosshair presets", 15, VX.C.white, true, 20)
	VX.note(aim, "Screen drawings only. They do not change weapons, hit detection, or other players.")
	for _, name in ipairs({ "Precise", "Dot", "Open", "Minimal" }) do
		VX.button(aim, name, function()
			VX.applyCrosshairPreset(VX.BUILTIN_PRESETS[name], name)
		end)
	end
	VX.button(aim, "Open full crosshair settings", function()
		VX.navigate("Universal", "Crosshair", true)
	end, { primary = true })

	local overlay = VX.stack(VX.scroll, 6)
	VX.textLabel(overlay, "Overlay", 15, VX.C.white, true, 20)
	VX.toggle(overlay, "FPS, ping, and session HUD", VX.P.hud.visible, nil, function(on)
		VX.P.hud.visible = on
		VX.applyHud()
		VX.requestSave()
	end)
	VX.stat(overlay, "Session    " .. VX.formatTime(os.clock() - VX.sessionStart), "session")
	VX.stat(overlay, VX.fpsValue and string.format("FPS    %d", math.floor(VX.fpsValue + 0.5)) or "FPS    …", "fps")
	VX.stat(overlay, VX.pingText(), "ping")

	local cameraCard = VX.stack(VX.scroll, 6)
	VX.textLabel(cameraCard, "Camera", 15, VX.C.white, true, 20)
	local currentFov = VX.P.fov or (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or VX.originalFOV
	VX.slider(cameraCard, "Field of view", 50, 110, currentFov, 1, nil, function(value, final)
		VX.P.fov = value
		VX.applyFov(final and VX.P.smoothFov)
		VX.requestSave()
	end)
	VX.button(cameraCard, "Open camera tools", function()
		VX.navigate("Universal", "Camera", true)
	end)

	local favouriteCard = VX.stack(VX.scroll, 4)
	VX.textLabel(favouriteCard, "Favourites", 15, VX.C.white, true, 20)
	local anyFavourite = false
	for _, id in ipairs(VX.featureOrder) do
		if VX.G.favorites[id] and VX.features[id] then
			anyFavourite = true
			VX.button(favouriteCard, VX.features[id].name, function()
				VX.useFeature(id)
			end)
		end
	end
	if not anyFavourite then
		VX.note(favouriteCard, "Star a tool from Universal and it will be listed here.")
	end
end

 function VX.renderSettings()
	VX.textLabel(VX.scroll, "Settings", 20, VX.C.white, true, 26)
	VX.note(VX.scroll, VX.storageNote)
	local card = VX.stack(VX.scroll, 6)
	VX.textLabel(card, "Profile    " .. VX.G.activeProfile, 14, VX.C.white, true, 20)
	local names = {}
	for name in pairs(VX.G.profiles) do
		table.insert(names, name)
	end
	table.sort(names)
	VX.dropdown(card, "Active profile", names, VX.G.activeProfile, function(choice)
		if VX.G.profiles[choice] then
			VX.G.activeProfile = choice
			VX.P = VX.G.profiles[choice]
			VX.applyAll()
			VX.requestSave()
			VX.notify("Using profile " .. choice .. ".", "success")
			VX.renderPage()
		end
	end)
	VX.button(card, "New profile from current", function()
		VX.promptBox("New profile", "Name", function(name)
			if VX.G.profiles[name] then
				VX.notify("That profile name already exists.", "warning")
				return
			end
			if #name > 24 then
				VX.notify("Use 24 characters or fewer.", "warning")
				return
			end
			VX.G.profiles[name] = VX.deepCopy(VX.P)
			VX.G.activeProfile = name
			VX.P = VX.G.profiles[name]
			VX.requestSave()
			VX.notify("Profile " .. name .. " is active.", "success")
			VX.renderPage()
		end)
	end, { primary = true })
	VX.button(card, "Delete active profile", function()
		if VX.G.activeProfile == "Default" then
			VX.notify("The Default profile stays so there is always one to use.", "warning")
			return
		end
		local name = VX.G.activeProfile
		VX.confirm("Delete " .. name .. "?", "The Default profile becomes active.", function()
			VX.G.profiles[name] = nil
			VX.G.activeProfile = "Default"
			if not VX.G.profiles.Default then
				VX.G.profiles.Default = VX.defaultProfile()
			end
			VX.P = VX.G.profiles.Default
			VX.applyAll()
			VX.requestSave()
			VX.notify("Deleted " .. name .. ".", "info")
			VX.renderPage()
		end)
	end)
	VX.button(card, "Reset active profile", function()
		VX.confirm("Reset " .. VX.G.activeProfile .. "?", "Restores this profile's menu settings. Favourites and other profiles stay.", function()
			if VX.P.lowGraphics then
				VX.setLowGraphics(false)
			end
			local fresh = VX.defaultProfile()
			VX.G.profiles[VX.G.activeProfile] = fresh
			VX.P = fresh
			VX.applyAll()
			local camera = workspace.CurrentCamera
			if camera then
				camera.FieldOfView = VX.originalFOV
			end
			VX.requestSave()
			VX.notify("Profile reset.", "success")
			VX.renderPage()
		end)
	end)
	VX.button(card, "Appearance and navigation", function()
		VX.navigate("Universal", "Interface", true)
	end)
	VX.textLabel(card, "About", 15, VX.C.white, true, 22)
	VX.note(card, "VEXORA 5.0 is a local client menu. It does not change other players, server gameplay, or Roblox protection systems.")
	local storageLabel = VX.textLabel(card, VX.storageNote, 12, VX.C.muted, false, 48)
	storageLabel.TextWrapped = true
	storageLabel.TextTruncate = Enum.TextTruncate.None
	storageLabel.TextYAlignment = Enum.TextYAlignment.Top
end

VX.renderPage = function()
	VX.clearScroll()
	if VX.currentPage == "Home" then
		VX.renderHome()
	elseif VX.currentPage == "Games" then
		VX.renderGames()
	elseif VX.currentPage == "Universal" then
		VX.renderUniversal()
	elseif VX.currentPage == "Urban" then
		VX.renderUrban()
	elseif VX.currentPage == "Settings" then
		VX.renderSettings()
	end
end

 function VX.registerFeatures()
	VX.feature({ id = "choose-profile", name = "Change game profile", category = "Menu", icon = "gamepad", description = "Open the game picker.", run = function()
		VX.navigate("Games", nil, true)
	end })
	VX.feature({ id = "open-universal", name = "Universal tools", category = "Menu", icon = "sliders", description = "Camera, HUD, crosshair, players, and utilities.", run = function()
		VX.navigate("Universal", "Camera", true)
	end })
	VX.feature({ id = "open-settings", name = "Open settings", category = "Menu", icon = "settings", description = "Profiles, reset, and storage.", run = function()
		VX.navigate("Settings", nil, true)
	end })
	VX.feature({ id = "toggle-hud", name = "Toggle HUD", category = "Interface", icon = "monitor", description = "Show or hide FPS, ping, and the session timer.", run = function()
		VX.P.hud.visible = not VX.P.hud.visible
		VX.applyHud()
		VX.requestSave()
		VX.notify(VX.P.hud.visible and "HUD on." or "HUD off.", "info")
	end })
	VX.feature({ id = "reset-position", name = "Reset menu position", category = "Interface", icon = "refresh", description = "Center the window.", run = function()
		VX.window.Position = UDim2.fromScale(0.5, 0.5)
		VX.notify("Menu centered.", "info")
	end })
	VX.feature({ id = "reset-hud", name = "Reset HUD position", category = "Interface", icon = "monitor", description = "Move the HUD back to the top left.", run = function()
		VX.P.hud.x = 16
		VX.P.hud.y = 16
		VX.applyHud()
		VX.requestSave()
		VX.notify("HUD moved to the top left.", "info")
	end })
	VX.feature({ id = "minimise", name = "Minimise menu", category = "Menu", icon = "minus", description = "Hide the window. Right Shift opens it again.", opens = false, run = function()
		if VX.windowOpen then
			VX.toggleWindow()
		end
	end })
	VX.feature({ id = "fov", name = "Field of view", category = "Camera", icon = "camera", description = "Set your local camera field of view.", run = function()
		VX.navigate("Universal", "Camera", true)
	end })
	VX.feature({ id = "fov-reset", name = "Restore field of view", category = "Camera", icon = "camera", description = "Put the camera back to the field of view from when VEXORA started.", run = function()
		local camera = workspace.CurrentCamera
		if camera then
			camera.FieldOfView = VX.originalFOV
		end
		VX.P.fov = VX.originalFOV
		VX.requestSave()
		VX.notify("Field of view restored.", "success")
		if VX.currentPage == "Universal" and VX.currentTab == "Camera" then
			VX.renderPage()
		end
	end })
	VX.feature({ id = "smooth-fov", name = "Smooth field of view", category = "Camera", icon = "camera", description = "Ease field-of-view changes.", run = function()
		VX.navigate("Universal", "Camera", true)
	end })
	VX.feature({ id = "ui-scale", name = "UI scale", category = "Interface", icon = "sliders", description = "Scale the VEXORA window.", run = function()
		VX.navigate("Universal", "Interface", true)
	end })
	VX.feature({ id = "opacity", name = "Interface opacity", category = "Interface", icon = "sliders", description = "Fade the window.", run = function()
		VX.navigate("Universal", "Interface", true)
	end })
	VX.feature({ id = "grid", name = "Grid background", category = "Interface", icon = "sliders", description = "Show or hide the grid.", run = function()
		VX.navigate("Universal", "Interface", true)
	end })
	VX.feature({ id = "pulses", name = "RGB pulses", category = "Interface", icon = "sliders", description = "Travelling light on the grid.", run = function()
		VX.navigate("Universal", "Interface", true)
	end })
	VX.feature({ id = "motion", name = "Reduced motion", category = "Interface", icon = "sliders", description = "Shorten animation and stop pulses.", run = function()
		VX.navigate("Universal", "Interface", true)
	end })
	VX.feature({ id = "crosshair", name = "Crosshair", category = "Crosshair", icon = "camera", description = "Local crosshair shape, size, and colour.", run = function()
		VX.navigate("Universal", "Crosshair", true)
	end })
	VX.feature({ id = "players", name = "Player browser", category = "Players", icon = "users", description = "Search people in this server.", run = function()
		VX.navigate("Universal", "Players", true)
	end })
	VX.feature({ id = "low-graphics", name = "Low graphics", category = "Performance", icon = "monitor", description = "Lower your local graphics quality.", run = function()
		VX.navigate("Universal", "Performance", true)
	end })
	VX.feature({ id = "export", name = "Export settings", category = "Settings", icon = "save", description = "Copy settings as text.", run = function()
		VX.navigate("Universal", "Utilities", true)
	end })
	VX.feature({ id = "shortcuts", name = "Keyboard shortcuts", category = "Settings", icon = "keyboard", description = "View and change menu keys.", run = function()
		VX.navigate("Universal", "Utilities", true)
	end })
end

 function VX.makeNavButton(parent, item, dockButton)
	local buttonObj = VX.make("TextButton", {
		Position = dockButton and UDim2.fromOffset((table.find(VX.NAV, item) - 1) * 44, 0) or UDim2.fromOffset(15, 72 + (table.find(VX.NAV, item) - 1) * 48),
		Size = dockButton and UDim2.fromOffset(40, 36) or UDim2.fromOffset(40, 40),
		BackgroundColor3 = dockButton and VX.C.card or VX.C.panel,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, parent)
	VX.corner(buttonObj, 10)
	VX.icon(buttonObj, item.icon, dockButton and 16 or 18, VX.C.muted)
	if not dockButton then
		local mark = VX.make("Frame", {
			Name = "Mark",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(2, 16),
			BackgroundColor3 = VX.accentColor(),
			BorderSizePixel = 0,
			Visible = false,
		}, buttonObj)
		VX.corner(mark, 2)
		VX.trackAccent(mark, "BackgroundColor3")
	end
	VX.bindHover(buttonObj, dockButton and VX.C.card or VX.C.panel, VX.C.hover, VX.C.bg)
	VX.bindTip(buttonObj, item.tip)
	buttonObj.Activated:Connect(function()
		VX.navigate(item.id)
	end)
	VX.navButtons[item.id] = VX.navButtons[item.id] or {}
	if dockButton then
		VX.navButtons[item.id].dock = buttonObj
	else
		VX.navButtons[item.id].side = buttonObj
	end
end

for _, item in ipairs(VX.NAV) do
	VX.makeNavButton(VX.sidebar, item, false)
	VX.makeNavButton(VX.dockItems, item, true)
end

 VX.TABS = {
	{ "Camera", "camera" },
	{ "Interface", "sliders" },
	{ "Crosshair", "camera" },
	{ "Performance", "monitor" },
	{ "Players", "users" },
	{ "Utilities", "keyboard" },
}
for index, tab in ipairs(VX.TABS) do
	local tabButton = VX.make("TextButton", {
		Name = tab[1],
		LayoutOrder = index,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 28),
		BackgroundColor3 = VX.C.bg,
		Text = "   " .. tab[1] .. "   ",
		TextColor3 = VX.C.muted,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, VX.tabBar)
	VX.corner(tabButton, 8)
	tabButton.Activated:Connect(function()
		VX.navigate("Universal", tab[1], true)
	end)
end

VX.searchButton.Activated:Connect(VX.openPalette)
VX.minButton.Activated:Connect(function()
	VX.useFeature("minimise")
end)
VX.closeButton.Activated:Connect(function()
	if VX.windowOpen then
		VX.toggleWindow()
	end
end)
VX.bindTip(VX.minButton, "Minimise")
VX.bindTip(VX.closeButton, "Close")
VX.bindTip(VX.searchButton, "Search")

VX.header.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local localX = input.Position.X - VX.header.AbsolutePosition.X
	if localX > VX.header.AbsoluteSize.X - 280 then
		return
	end
	VX.windowDrag = true
	VX.dragStart = input.Position
	VX.dragOrigin = VX.window.Position
end)

VX.hud.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	VX.hudDrag = true
	VX.dragStart = input.Position
	VX.dragOrigin = VX.hud.Position
end)

VX.track(VX.UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	if VX.hudDrag then
		VX.hudDrag = false
		local camera = workspace.CurrentCamera
		local view = camera and camera.ViewportSize or Vector2.new(1280, 720)
		VX.P.hud.x = math.clamp(VX.hud.Position.X.Offset, 8, math.max(8, view.X - 184))
		VX.P.hud.y = math.clamp(VX.hud.Position.Y.Offset, 8, math.max(8, view.Y - 90))
		VX.hud.Position = UDim2.fromOffset(VX.P.hud.x, VX.P.hud.y)
		VX.requestSave()
	end
	VX.windowDrag = false
end))

VX.track(VX.UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	if VX.windowDrag and VX.dragStart and VX.dragOrigin then
		local delta = input.Position - VX.dragStart
		VX.window.Position = UDim2.new(VX.dragOrigin.X.Scale, VX.dragOrigin.X.Offset + delta.X, VX.dragOrigin.Y.Scale, VX.dragOrigin.Y.Offset + delta.Y)
	elseif VX.hudDrag and VX.dragStart and VX.dragOrigin then
		local delta = input.Position - VX.dragStart
		VX.hud.Position = UDim2.fromOffset(VX.dragOrigin.X.Offset + delta.X, VX.dragOrigin.Y.Offset + delta.Y)
	end
end))

VX.track(VX.UserInputService.InputBegan:Connect(function(input, processed)
	if not VX.alive then
		return
	end
	if VX.capturing then
		if input.KeyCode == Enum.KeyCode.Escape then
			VX.capturing = nil
			VX.notify("Shortcut change cancelled.", "info")
			return
		end
		if input.KeyCode ~= Enum.KeyCode.Unknown and VX.validKey(input.KeyCode.Name) then
			local which = VX.capturing
			VX.capturing = nil
			VX.G.binds[which] = input.KeyCode.Name
			VX.requestSave()
			VX.notify("Shortcut set to " .. input.KeyCode.Name .. ".", "success")
			if VX.currentPage == "Universal" and VX.currentTab == "Utilities" then
				VX.renderPage()
			end
		end
		return
	end
	if input.KeyCode == Enum.KeyCode.Escape then
		if VX.suppressEscape or VX.paletteOpen then
			return
		end
		local focused = VX.UserInputService:GetFocusedTextBox()
		if focused then
			focused:ReleaseFocus()
			return
		end
		if VX.modalOpen then
			VX.closeModal()
			return
		end
		if VX.dropdownPanel.Visible then
			VX.closeDropdown()
			return
		end
		if VX.windowOpen then
			VX.toggleWindow()
		end
		return
	end
	local toggleKey = VX.validKey(VX.G.binds.toggle) and Enum.KeyCode[VX.G.binds.toggle] or Enum.KeyCode.RightShift
	if input.KeyCode == toggleKey then
		VX.toggleWindow()
		return
	end
	if processed then
		return
	end
	local paletteKey = VX.validKey(VX.G.binds.palette) and Enum.KeyCode[VX.G.binds.palette] or Enum.KeyCode.K
	if input.KeyCode == paletteKey and (VX.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or VX.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
		if VX.paletteOpen then
			VX.closePalette()
		else
			VX.openPalette()
		end
	end
end))

VX.track(VX.UserInputService.LastInputTypeChanged:Connect(function(inputType)
	VX.lastInput = inputType
	VX.setWatch("input", "Input    " .. inputType.Name)
end))

 function VX.bindViewport()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	VX.track(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		VX.applyChrome()
		VX.setWatch("res", "Resolution    " .. VX.resolutionText())
	end))
end
VX.bindViewport()
VX.track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	VX.bindViewport()
	if type(VX.P.fov) == "number" then
		task.defer(function()
			VX.applyFov(false)
		end)
	end
	VX.setWatch("fov", "Field of view    " .. VX.fovText())
end))
VX.track(VX.player.CharacterAdded:Connect(function()
	task.defer(function()
		VX.bindViewport()
		if type(VX.P.fov) == "number" then
			VX.applyFov(false)
		end
	end)
end))

VX.track(VX.RunService.Heartbeat:Connect(function(dt)
	if not VX.alive then
		return
	end
	VX.fpsFrames += 1
	VX.fpsAccum += dt
	if VX.fpsAccum < 0.5 then
		return
	end
	VX.fpsValue = VX.fpsFrames / VX.fpsAccum
	VX.fpsFrames = 0
	VX.fpsAccum = 0
	VX.fpsCursor = VX.fpsCursor % 28 + 1
	VX.fpsHistory[VX.fpsCursor] = VX.fpsValue
	local text = string.format("FPS    %d", math.floor(VX.fpsValue + 0.5))
	VX.setWatch("fps", text)
	if VX.chartBars then
		for index = 1, 28 do
			local sampleIndex = (VX.fpsCursor - (28 - index) - 1) % 28 + 1
			local sample = VX.fpsHistory[sampleIndex] or 0
			local bar = VX.chartBars[index]
			if bar and bar.Parent then
				bar.Size = UDim2.new(1, 0, math.clamp(sample / 120, 0.06, 1), 0)
			end
		end
	end
end))

task.spawn(function()
	while VX.alive do
		task.wait(1)
		if not VX.alive then
			break
		end
		VX.setWatch("players", string.format("Players    %d / %d", #VX.Players:GetPlayers(), VX.Players.MaxPlayers))
		VX.setWatch("ping", VX.pingText())
		VX.setWatch("session", "Session    " .. VX.formatTime(os.clock() - VX.sessionStart))
		VX.setWatch("profileLine", (function()
			local selected = VX.gameById(VX.selectedId)
			return (selected and selected.name or "No profile") .. "    ·    Session " .. VX.formatTime(os.clock() - VX.sessionStart)
		end)())
		VX.setWatch("mem", VX.memoryText())
		VX.setWatch("fov", "Field of view    " .. VX.fovText())
		VX.setWatch("res", "Resolution    " .. VX.resolutionText())
		VX.setWatch("graphics", "Graphics    " .. VX.graphicsText())
		local job = game.JobId == "" and "Job ID    Empty in this session" or ("Job ID    " .. string.sub(game.JobId, 1, 16))
		VX.setWatch("job", job)
	end
end)

 VX.pulseColors = { VX.C.cyan, VX.C.violet, VX.C.green, VX.C.red }
for index = 1, 4 do
	local horizontal = index % 2 == 0
	local pulse = VX.make("Frame", {
		Position = horizontal and UDim2.fromOffset(-120, 70 + index * 36) or UDim2.fromOffset(80 + index * 40, -120),
		Size = horizontal and UDim2.fromOffset(110, 2) or UDim2.fromOffset(2, 110),
		BackgroundColor3 = VX.pulseColors[index],
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Visible = false,
	}, VX.pulseLayer)
	local gradient = VX.make("UIGradient", {
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
		while VX.alive and pulse.Parent do
			local moving = VX.bootDone and VX.windowOpen and VX.P.pulses and not VX.P.reducedMotion and VX.grid.Visible
			if moving then
				pulse.Visible = true
				pulse.Position = horizontal and UDim2.fromOffset(-120, 70 + index * 36) or UDim2.fromOffset(80 + index * 40, -120)
				local goal = horizontal and UDim2.fromOffset(VX.WIN_W + 40, 70 + index * 36) or UDim2.fromOffset(80 + index * 40, VX.WIN_H + 40)
				local travel = VX.tween(pulse, (3.1 + index * 0.35) / math.clamp(VX.P.anim or 1, 0.6, 1.4), { Position = goal })
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

if VX.UserInputService.TouchEnabled and not VX.UserInputService.MouseEnabled then
	VX.dockExpanded = true
	VX.dock.Size = UDim2.fromOffset(VX.DOCK_OPEN, 52)
end

VX.dock.MouseEnter:Connect(function()
	if VX.UserInputService.MouseEnabled then
		if not VX.dockExpanded then
			VX.dockExpanded = true
			VX.tween(VX.dock, 0.28, { Size = UDim2.fromOffset(VX.DOCK_OPEN, 52) })
		end
	end
end)
VX.dock.MouseLeave:Connect(function()
	if VX.UserInputService.MouseEnabled and not (VX.UserInputService.TouchEnabled and not VX.UserInputService.MouseEnabled) then
		if VX.dockExpanded then
			VX.dockExpanded = false
			VX.tween(VX.dock, 0.28, { Size = UDim2.fromOffset(VX.DOCK_CLOSED, 52) })
		end
	end
end)
VX.dockLogo.Activated:Connect(function()
	if VX.UserInputService.TouchEnabled and not VX.UserInputService.MouseEnabled then
		VX.dockExpanded = not VX.dockExpanded
		VX.tween(VX.dock, 0.28, { Size = UDim2.fromOffset(VX.dockExpanded and VX.DOCK_OPEN or VX.DOCK_CLOSED, 52) })
		if VX.dockExpanded then
			VX.ensureWindow()
		end
	else
		VX.toggleWindow()
	end
end)

VX.modalDim.Activated:Connect(function()
	VX.closeModal()
end)

VX.gui.Destroying:Connect(function()
	VX.alive = false
	pcall(function()
		VX.ContextActionService:UnbindAction("VEXORA_Palette")
	end)
	for _, conn in ipairs(VX.conns) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	VX.clearPageConns()
	if VX.previousQuality ~= nil then
		pcall(function()
			UserSettings():GetService("UserGameSettings").SavedQualityLevel = VX.previousQuality
		end)
	end
end)

VX.registerFeatures()
VX.applyChrome()
VX.applyCrosshair()

task.spawn(function()
	local ok, info = pcall(function()
		return VX.MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	if ok and type(info) == "table" and type(info.Name) == "string" then
		VX.experienceName = info.Name
		VX.setWatch("experience", "Experience    " .. VX.experienceName)
	end
	VX.infoReady = true
end)

task.spawn(function()
	local assets = {}
	for _, entry in ipairs(VX.GAMES) do
		if entry.universeId then
			table.insert(assets, "rbxthumb://type=GameThumbnail&id=" .. tostring(entry.universeId) .. "&w=768&h=432")
			table.insert(assets, "rbxthumb://type=GameIcon&id=" .. tostring(entry.universeId) .. "&w=150&h=150")
		end
	end
	if #assets > 0 then
		pcall(function()
			VX.ContentProvider:PreloadAsync(assets)
		end)
	end
end)

 VX.splash = VX.make("CanvasGroup", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(360, 210),
	BackgroundColor3 = VX.C.bg,
	GroupTransparency = 1,
	ZIndex = 8,
}, VX.gui)
VX.corner(VX.splash, 16)
VX.stroke(VX.splash, 0.15)
 VX.splashScale = VX.make("UIScale", { Scale = 1 }, VX.splash)
 VX.splashGrid = VX.make("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ClipsDescendants = true }, VX.splash)
for x = 0, 360, 26 do
	VX.make("Frame", {
		Position = UDim2.fromOffset(x, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = VX.C.white,
		BackgroundTransparency = 0.96,
		BorderSizePixel = 0,
	}, VX.splashGrid)
end
for y = 0, 210, 26 do
	VX.make("Frame", {
		Position = UDim2.fromOffset(0, y),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = VX.C.white,
		BackgroundTransparency = 0.96,
		BorderSizePixel = 0,
	}, VX.splashGrid)
end
 VX.splashLogo = VX.make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 28),
	Size = UDim2.fromOffset(48, 48),
	BackgroundColor3 = VX.C.white,
	Text = "V",
	TextColor3 = VX.C.bg,
	Font = Enum.Font.GothamBold,
	TextSize = 26,
	BorderSizePixel = 0,
}, VX.splash)
VX.corner(VX.splashLogo, 12)
 VX.splashTitle = VX.make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 86),
	Size = UDim2.new(1, 0, 0, 28),
	Font = Enum.Font.GothamBold,
	TextSize = 26,
	TextColor3 = VX.C.white,
	Text = "VEXORA",
}, VX.splash)
 VX.splashSub = VX.make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 116),
	Size = UDim2.new(1, 0, 0, 16),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = VX.C.muted,
	Text = "Opening",
}, VX.splash)
 VX.splashTrack = VX.make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 156),
	Size = UDim2.fromOffset(220, 3),
	BackgroundColor3 = VX.C.hover,
	BorderSizePixel = 0,
}, VX.splash)
VX.corner(VX.splashTrack, 3)
 VX.splashFill = VX.make("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = VX.C.white,
	BorderSizePixel = 0,
}, VX.splashTrack)
VX.corner(VX.splashFill, 3)

 function VX.boot()
	local camera = workspace.CurrentCamera
	if camera then
		VX.splashScale.Scale = math.clamp(math.min(1, (camera.ViewportSize.X - 24) / 360), 0.7, 1)
	end
	VX.tween(VX.splash, 0.35, { GroupTransparency = 0 })
	local steps = {
		{ 0.22, "Opening VEXORA" },
		{ 0.48, "Identifying this experience" },
		{ 0.74, "Preparing profiles" },
		{ 1, "Choose a profile" },
	}
	for _, step in ipairs(steps) do
		if not VX.alive then
			return
		end
		VX.splashSub.Text = step[2]
		local fillTween = VX.tween(VX.splashFill, 0.28, { Size = UDim2.fromScale(step[1], 1) })
		pcall(function()
			fillTween.Completed:Wait()
		end)
		task.wait(0.08)
	end
	local deadline = os.clock() + 1.2
	while VX.alive and not VX.infoReady and os.clock() < deadline do
		task.wait(0.05)
	end
	if not VX.alive then
		return
	end
	VX.splashSub.Text = "You are in " .. VX.experienceName
	task.wait(0.18)
	local fade = VX.tween(VX.splash, 0.22, { GroupTransparency = 1 })
	pcall(function()
		fade.Completed:Wait()
	end)
	if VX.splash.Parent then
		VX.splash:Destroy()
	end
	VX.bootDone = true
	VX.applyAll()
	VX.dock.Visible = VX.G.dock
	VX.navigate("Games", nil, true)
	if VX.G._loadNote then
		VX.notify(VX.G._loadNote, "warning")
		VX.G._loadNote = nil
	elseif VX.storageMode == "file" then
		VX.notify("Settings loaded from this device.", "info")
	else
		VX.notify("Settings last for this run. Export a copy to keep them.", "info")
	end
	print("[VEXORA] 5.0 loaded")
end

task.spawn(VX.boot)
