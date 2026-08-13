--[[
	VHub UI Library v1.0
	Воссоздание легендарного интерфейса VexHub для Roblox.

	Подключение:
		local VHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/druk131/VhubUILib/main/VHub.lua"))()

	Пример использования: Example.lua
]]

local VHub = {}
VHub.__index = VHub

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

--// Тема по умолчанию (можно переопределить через CreateWindow({ Theme = {...} }))
local Theme = {
	Background = Color3.fromRGB(14, 15, 20),
	Panel = Color3.fromRGB(23, 25, 32),
	PanelHover = Color3.fromRGB(35, 38, 47),
	Element = Color3.fromRGB(30, 32, 40),
	Stroke = Color3.fromRGB(255, 255, 255),
	Text = Color3.fromRGB(237, 239, 246),
	TextDim = Color3.fromRGB(148, 153, 168),
	Accent = Color3.fromRGB(88, 101, 242),
	Green = Color3.fromRGB(87, 242, 135),
	Yellow = Color3.fromRGB(254, 231, 92),
}

--// Хелперы
local function New(className, props, children)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			local ok, err = pcall(function()
				inst[k] = v
			end)
			if not ok then
				warn(("[VHub] Не удалось задать %s.%s: %s"):format(className, tostring(k), tostring(err)))
			end
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function Corner(radius)
	return New("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

local function Stroke(transparency)
	return New("UIStroke", {
		Color = Theme.Stroke,
		Transparency = transparency or 0.92,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function Tween(obj, time, props)
	local t = TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function GetGuiParent()
	local ok, hui = pcall(function()
		return gethui()
	end)
	if ok and typeof(hui) == "Instance" then
		return hui
	end
	local core = game:GetService("CoreGui")
	local ok2 = pcall(function()
		local test = Instance.new("Folder")
		test.Parent = core
		test:Destroy()
	end)
	if ok2 then
		return core
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function MakeDraggable(handle, target)
	local dragging = false
	local dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function Hover(frame, enterProps, leaveProps)
	frame.MouseEnter:Connect(function()
		Tween(frame, 0.15, enterProps)
	end)
	frame.MouseLeave:Connect(function()
		Tween(frame, 0.15, leaveProps)
	end)
end

--// Создание окна
function VHub:CreateWindow(config)
	config = config or {}
	if config.Theme then
		for k, v in pairs(config.Theme) do
			Theme[k] = v
		end
	end

	local windowName = config.Name or "VHub"
	local version = config.Version or "V1.0"
	local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
	local useBlur = config.Blur ~= false
	local width = config.Width or 650
	local height = config.Height or 400

	local Window = { Tabs = {}, Flags = {}, CurrentTab = nil }

	local guiParent = GetGuiParent()
	local old = guiParent:FindFirstChild("VHubUI")
	if old then
		old:Destroy()
	end

	local gui = New("ScreenGui", {
		Name = "VHubUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = guiParent,
	})

	local blur
	if useBlur then
		blur = Lighting:FindFirstChild("VHubBlur") or New("BlurEffect", { Name = "VHubBlur", Size = 0, Parent = Lighting })
		blur.Size = 0
	end

	--// Главный фрейм
	local main = New("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = gui,
	}, { Corner(14), Stroke(0.86) })

	--// Верхняя панель (шапка)
	local topBar = New("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = Theme.Panel,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Parent = main,
	})

	local logo = New("Frame", {
		Name = "Logo",
		Position = UDim2.fromOffset(12, 9),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = topBar,
	}, { Corner(8) })

	if config.Logo then
		New("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = config.Logo,
			ScaleType = Enum.ScaleType.Fit,
			Parent = logo,
		}, { Corner(8) })
	else
		New("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = string.upper(string.sub(windowName, 1, 1)),
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBlack,
			TextSize = 16,
			Parent = logo,
		})
	end

	New("TextLabel", {
		Position = UDim2.fromOffset(52, 7),
		Size = UDim2.fromOffset(240, 20),
		BackgroundTransparency = 1,
		Text = windowName,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar,
	})

	New("TextLabel", {
		Position = UDim2.fromOffset(52, 26),
		Size = UDim2.fromOffset(240, 14),
		BackgroundTransparency = 1,
		Text = version,
		TextColor3 = Theme.TextDim,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar,
	})

	local function TopButton(text, offset)
		return New("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, offset, 0, 10),
			Size = UDim2.fromOffset(28, 28),
			BackgroundColor3 = Theme.Element,
			BackgroundTransparency = 0.3,
			Text = text,
			TextColor3 = Theme.TextDim,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Parent = topBar,
		}, { Corner(8) })
	end

	local closeBtn = TopButton("✕", -12)
	local minBtn = TopButton("–", -46)

	--// Тело окна
	local body = New("Frame", {
		Name = "Body",
		Position = UDim2.fromOffset(0, 52),
		Size = UDim2.new(1, 0, 1, -58),
		BackgroundTransparency = 1,
		Parent = main,
	})

	--// Сайдбар
	local sidebar = New("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(0, 168, 1, 0),
		BackgroundTransparency = 1,
		Parent = body,
	})

	-- Профиль
	local avatarImage = config.Avatar
	if not avatarImage then
		pcall(function()
			avatarImage = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
	end

	local profile = New("Frame", {
		Name = "Profile",
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = Theme.Panel,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Parent = sidebar,
	}, { Corner(10), Stroke(0.92) })

	New("ImageLabel", {
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Theme.Element,
		BorderSizePixel = 0,
		Image = avatarImage or "",
		Parent = profile,
	}, { Corner(15), Stroke(0.9) })

	New("TextLabel", {
		Position = UDim2.fromOffset(46, 7),
		Size = UDim2.new(1, -52, 0, 16),
		BackgroundTransparency = 1,
		Text = config.DisplayName or LocalPlayer.DisplayName,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profile,
	})

	New("TextLabel", {
		Position = UDim2.fromOffset(46, 24),
		Size = UDim2.new(1, -52, 0, 14),
		BackgroundTransparency = 1,
		Text = config.Username or ("@" .. LocalPlayer.Name),
		TextColor3 = Theme.TextDim,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = profile,
	})

	-- Список кнопок вкладок
	local tabList = New("ScrollingFrame", {
		Name = "Tabs",
		Position = UDim2.fromOffset(0, 52),
		Size = UDim2.new(1, 0, 1, -52),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = sidebar,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	--// Контейнер страниц
	local pages = New("Frame", {
		Name = "Pages",
		Position = UDim2.fromOffset(182, 0),
		Size = UDim2.new(1, -190, 1, 0),
		BackgroundTransparency = 1,
		Parent = body,
	})

	--// Вкладка
	function Window:CreateTab(tabCfg)
		tabCfg = tabCfg or {}
		local Tab = {}

		local button = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = Theme.Panel,
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			LayoutOrder = #Window.Tabs + 1,
			Parent = tabList,
		}, { Corner(8) })

		local iconLbl = New("TextLabel", {
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.fromOffset(20, 34),
			BackgroundTransparency = 1,
			Text = tabCfg.Icon or "•",
			TextColor3 = Theme.TextDim,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			Parent = button,
		})

		local nameLbl = New("TextLabel", {
			Position = UDim2.fromOffset(36, 0),
			Size = UDim2.new(1, -42, 1, 0),
			BackgroundTransparency = 1,
			Text = tabCfg.Name or "Tab",
			TextColor3 = Theme.TextDim,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = button,
		})

		local page = New("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Stroke,
			ScrollBarImageTransparency = 0.7,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			ElasticBehavior = Enum.ElasticBehavior.Never,
			Parent = pages,
		}, {
			New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
			New("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 2) }),
		})

		local entry = { Button = button, Page = page, Icon = iconLbl, Name = nameLbl, Obj = Tab }

		local function Activate()
			for _, t in ipairs(Window.Tabs) do
				t.Page.Visible = false
				Tween(t.Button, 0.15, { BackgroundTransparency = 1 })
				t.Icon.TextColor3 = Theme.TextDim
				t.Name.TextColor3 = Theme.TextDim
			end
			page.Visible = true
			Tween(button, 0.15, { BackgroundTransparency = 0.45 })
			iconLbl.TextColor3 = Theme.Text
			nameLbl.TextColor3 = Theme.Text
			Window.CurrentTab = Tab
		end

		button.MouseButton1Click:Connect(Activate)
		button.MouseEnter:Connect(function()
			if Window.CurrentTab ~= Tab then
				Tween(button, 0.15, { BackgroundTransparency = 0.65 })
			end
		end)
		button.MouseLeave:Connect(function()
			if Window.CurrentTab ~= Tab then
				Tween(button, 0.15, { BackgroundTransparency = 1 })
			end
		end)

		table.insert(Window.Tabs, entry)
		if #Window.Tabs == 1 then
			Activate()
		end

		--// База элемента
		local function Base(h)
			return New("Frame", {
				Size = UDim2.new(1, 0, 0, h),
				BackgroundColor3 = Theme.Panel,
				BackgroundTransparency = 0.4,
				BorderSizePixel = 0,
				Parent = page,
			}, { Corner(8), Stroke(0.93) })
		end

		local function ElementLabel(parent, text)
			return New("TextLabel", {
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.new(1, -20, 1, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.Text,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = parent,
			})
		end

		--// Секция (заголовок группы)
		function Tab:CreateSection(text)
			New("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = string.upper(tostring(text or "Section")),
				TextColor3 = Theme.TextDim,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = page,
			})
		end

		--// Текстовая метка
		function Tab:CreateLabel(text)
			local f = Base(30)
			local lbl = ElementLabel(f, tostring(text or "Label"))
			lbl.TextColor3 = Theme.TextDim
			local obj = {}
			function obj:Set(t)
				lbl.Text = tostring(t)
			end
			return obj
		end

		--// Параграф (заголовок + текст)
		function Tab:CreateParagraph(pCfg)
			pCfg = pCfg or {}
			local f = New("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Theme.Panel,
				BackgroundTransparency = 0.4,
				BorderSizePixel = 0,
				Parent = page,
			}, {
				Corner(8),
				Stroke(0.93),
				New("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}),
				New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
			})

			local title = New("TextLabel", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Text = tostring(pCfg.Title or "Title"),
				TextColor3 = Theme.Text,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 1,
				Parent = f,
			})

			local content = New("TextLabel", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Text = tostring(pCfg.Content or ""),
				TextColor3 = Theme.TextDim,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 2,
				Parent = f,
			})

			local obj = {}
			function obj:Set(t, c)
				title.Text = tostring(t)
				if c then
					content.Text = tostring(c)
				end
			end
			return obj
		end

		--// Кнопка
		function Tab:CreateButton(bCfg)
			bCfg = bCfg or {}
			local f = Base(36)
			local lbl = ElementLabel(f, tostring(bCfg.Name or "Button"))
			lbl.Font = Enum.Font.GothamBold

			New("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -10, 0, 0),
				Size = UDim2.fromOffset(16, 36),
				BackgroundTransparency = 1,
				Text = "›",
				TextColor3 = Theme.TextDim,
				Font = Enum.Font.GothamBold,
				TextSize = 16,
				Parent = f,
			})

			local btn = New("TextButton", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = "",
				Parent = f,
			})

			Hover(f, { BackgroundTransparency = 0.2 }, { BackgroundTransparency = 0.4 })

			btn.MouseButton1Click:Connect(function()
				Tween(f, 0.1, { BackgroundColor3 = Theme.PanelHover })
				task.delay(0.15, function()
					Tween(f, 0.2, { BackgroundColor3 = Theme.Panel })
				end)
				if bCfg.Callback then
					task.spawn(bCfg.Callback)
				end
			end)
		end

		--// Тоггл (переключатель)
		function Tab:CreateToggle(tCfg)
			tCfg = tCfg or {}
			local state = tCfg.Default or false
			local f = Base(36)
			ElementLabel(f, tostring(tCfg.Name or "Toggle"))

			local switch = New("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(38, 20),
				BackgroundColor3 = state and Theme.Accent or Theme.Element,
				BorderSizePixel = 0,
				Parent = f,
			}, { Corner(10), Stroke(0.9) })

			local knob = New("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
				Size = UDim2.fromOffset(14, 14),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Parent = switch,
			}, { Corner(7) })

			local function Apply(v, fire)
				state = v and true or false
				Tween(switch, 0.15, { BackgroundColor3 = state and Theme.Accent or Theme.Element })
				Tween(knob, 0.15, { Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
				if tCfg.Flag then
					Window.Flags[tCfg.Flag] = state
				end
				if fire and tCfg.Callback then
					task.spawn(tCfg.Callback, state)
				end
			end

			local btn = New("TextButton", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = "",
				Parent = f,
			})
			btn.MouseButton1Click:Connect(function()
				Apply(not state, true)
			end)

			if tCfg.Flag then
				Window.Flags[tCfg.Flag] = state
			end

			local obj = {}
			function obj:Set(v)
				Apply(v, true)
			end
			function obj:Get()
				return state
			end
			return obj
		end

		--// Слайдер
		function Tab:CreateSlider(sCfg)
			sCfg = sCfg or {}
			local min = sCfg.Min or 0
			local max = sCfg.Max or 100
			local increment = sCfg.Increment or 1
			local suffix = sCfg.Suffix or ""
			local value = sCfg.Default or min

			local f = Base(50)
			local lbl = ElementLabel(f, tostring(sCfg.Name or "Slider"))
			lbl.Position = UDim2.fromOffset(10, 2)
			lbl.Size = UDim2.new(1, -70, 0, 24)

			local valueLbl = New("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -10, 0, 2),
				Size = UDim2.fromOffset(60, 24),
				BackgroundTransparency = 1,
				Text = tostring(value) .. suffix,
				TextColor3 = Theme.TextDim,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = f,
			})

			local bar = New("Frame", {
				Position = UDim2.new(0, 10, 0, 32),
				Size = UDim2.new(1, -20, 0, 6),
				BackgroundColor3 = Theme.Element,
				BorderSizePixel = 0,
				Parent = f,
			}, { Corner(3) })

			local fill = New("Frame", {
				Size = UDim2.fromScale(0, 1),
				BackgroundColor3 = Theme.Accent,
				BorderSizePixel = 0,
				Parent = bar,
			}, { Corner(3) })

			local knob = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromOffset(12, 12),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Parent = bar,
			}, { Corner(6) })

			local function SetValue(v, fire)
				v = math.clamp(v, min, max)
				v = math.floor((v - min) / increment + 0.5) * increment + min
				value = v
				local alpha = (max > min) and ((v - min) / (max - min)) or 0
				Tween(fill, 0.08, { Size = UDim2.fromScale(alpha, 1) })
				Tween(knob, 0.08, { Position = UDim2.fromScale(alpha, 0.5) })
				valueLbl.Text = tostring(v) .. suffix
				if sCfg.Flag then
					Window.Flags[sCfg.Flag] = v
				end
				if fire and sCfg.Callback then
					task.spawn(sCfg.Callback, v)
				end
			end

			local sliding = false
			local function UpdateFromInput(input)
				local x = input.Position.X
				local alpha = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
				SetValue(min + (max - min) * alpha, true)
			end

			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					sliding = true
					UpdateFromInput(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					sliding = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateFromInput(input)
				end
			end)

			SetValue(value, false)

			local obj = {}
			function obj:Set(v)
				SetValue(v, true)
			end
			function obj:Get()
				return value
			end
			return obj
		end

		--// Дропдаун
		function Tab:CreateDropdown(dCfg)
			dCfg = dCfg or {}
			local options = dCfg.Options or {}
			local current = dCfg.Default or options[1] or ""
			local open = false

			local container = New("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.Panel,
				BackgroundTransparency = 0.4,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Parent = page,
			}, { Corner(8), Stroke(0.93) })

			local nameLbl = ElementLabel(container, tostring(dCfg.Name or "Dropdown"))
			nameLbl.Size = UDim2.new(0.5, -10, 0, 36)

			local chevron = New("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -10, 0, 0),
				Size = UDim2.fromOffset(14, 36),
				BackgroundTransparency = 1,
				Text = "▼",
				TextColor3 = Theme.TextDim,
				TextSize = 10,
				Font = Enum.Font.Gotham,
				Parent = container,
			})

			local currentLbl = New("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -28, 0, 0),
				Size = UDim2.new(0.5, -40, 0, 36),
				BackgroundTransparency = 1,
				Text = tostring(current),
				TextColor3 = Theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = container,
			})

			local list = New("Frame", {
				Position = UDim2.fromOffset(6, 38),
				Size = UDim2.new(1, -12, 0, 0),
				BackgroundTransparency = 1,
				Parent = container,
			}, { New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }) })

			local optionObjs = {}
			local function BuildOptions()
				for _, o in pairs(optionObjs) do
					o:Destroy()
				end
				table.clear(optionObjs)
				for i, opt in ipairs(options) do
					local b = New("TextButton", {
						Size = UDim2.new(1, 0, 0, 26),
						BackgroundColor3 = Theme.Element,
						BackgroundTransparency = 0.4,
						Text = tostring(opt),
						TextColor3 = Theme.Text,
						Font = Enum.Font.Gotham,
						TextSize = 12,
						AutoButtonColor = false,
						BorderSizePixel = 0,
						LayoutOrder = i,
						Parent = list,
					}, { Corner(6) })
					Hover(b, { BackgroundColor3 = Theme.PanelHover }, { BackgroundColor3 = Theme.Element })
					b.MouseButton1Click:Connect(function()
						current = opt
						currentLbl.Text = tostring(opt)
						if dCfg.Flag then
							Window.Flags[dCfg.Flag] = opt
						end
						open = false
						Tween(container, 0.2, { Size = UDim2.new(1, 0, 0, 36) })
						chevron.Text = "▼"
						if dCfg.Callback then
							task.spawn(dCfg.Callback, opt)
						end
					end)
					optionObjs[i] = b
				end
			end
			BuildOptions()

			local header = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
				Text = "",
				Parent = container,
			})
			header.MouseButton1Click:Connect(function()
				open = not open
				local target = open and (38 + #options * 29 + 6) or 36
				Tween(container, 0.25, { Size = UDim2.new(1, 0, 0, target) })
				chevron.Text = open and "▲" or "▼"
			end)

			if dCfg.Flag then
				Window.Flags[dCfg.Flag] = current
			end

			local obj = {}
			function obj:Refresh(newOptions, keep)
				options = newOptions or options
				BuildOptions()
				if not keep then
					current = options[1] or ""
					currentLbl.Text = tostring(current)
				end
				if open then
					container.Size = UDim2.new(1, 0, 0, 38 + #options * 29 + 6)
				end
			end
			function obj:Set(opt)
				current = opt
				currentLbl.Text = tostring(opt)
				if dCfg.Callback then
					task.spawn(dCfg.Callback, opt)
				end
			end
			function obj:Get()
				return current
			end
			return obj
		end

		--// Поле ввода
		function Tab:CreateInput(iCfg)
			iCfg = iCfg or {}
			local f = Base(36)
			local nameLbl = ElementLabel(f, tostring(iCfg.Name or "Input"))
			nameLbl.Size = UDim2.new(0.5, -10, 1, 0)

			local box = New("TextBox", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.new(0.5, -16, 0, 26),
				BackgroundColor3 = Theme.Element,
				BackgroundTransparency = 0.3,
				Text = tostring(iCfg.Default or ""),
				PlaceholderText = tostring(iCfg.Placeholder or "..."),
				PlaceholderColor3 = Theme.TextDim,
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				ClearTextOnFocus = false,
				BorderSizePixel = 0,
				Parent = f,
			}, { Corner(6), Stroke(0.92) })

			box.FocusLost:Connect(function(enter)
				if iCfg.Flag then
					Window.Flags[iCfg.Flag] = box.Text
				end
				if iCfg.Callback then
					task.spawn(iCfg.Callback, box.Text, enter)
				end
			end)

			local obj = {}
			function obj:Set(t)
				box.Text = tostring(t)
			end
			function obj:Get()
				return box.Text
			end
			return obj
		end

		--// Бинд клавиши
		function Tab:CreateKeybind(kCfg)
			kCfg = kCfg or {}
			local current = kCfg.Default or Enum.KeyCode.E
			local listening = false

			local f = Base(36)
			local nameLbl = ElementLabel(f, tostring(kCfg.Name or "Keybind"))
			nameLbl.Size = UDim2.new(1, -90, 1, 0)

			local bindBtn = New("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(70, 24),
				BackgroundColor3 = Theme.Element,
				BackgroundTransparency = 0.3,
				Text = current.Name,
				TextColor3 = Theme.Text,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Parent = f,
			}, { Corner(6), Stroke(0.92) })

			bindBtn.MouseButton1Click:Connect(function()
				listening = true
				bindBtn.Text = "..."
			end)

			UserInputService.InputBegan:Connect(function(input, gpe)
				if listening then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						listening = false
						if input.KeyCode ~= Enum.KeyCode.Escape then
							current = input.KeyCode
							if kCfg.Flag then
								Window.Flags[kCfg.Flag] = current
							end
							if kCfg.OnChanged then
								task.spawn(kCfg.OnChanged, current)
							end
						end
						bindBtn.Text = current.Name
					end
					return
				end
				if gpe or UserInputService:GetFocusedTextBox() then
					return
				end
				if input.KeyCode == current and kCfg.Callback then
					task.spawn(kCfg.Callback)
				end
			end)

			if kCfg.Flag then
				Window.Flags[kCfg.Flag] = current
			end

			local obj = {}
			function obj:Get()
				return current
			end
			return obj
		end

		--// Браузер скриптов (поиск + карточки + панель деталей, как в VexHub)
		function Tab:CreateScriptBrowser(bCfg)
			bCfg = bCfg or {}
			local browserHeight = bCfg.Height or 260

			local holder = New("Frame", {
				Size = UDim2.new(1, 0, 0, browserHeight),
				BackgroundTransparency = 1,
				Parent = page,
			})

			-- Левая часть: поиск + сетка карточек
			local left = New("Frame", {
				Size = UDim2.new(1, -198, 1, 0),
				BackgroundTransparency = 1,
				Parent = holder,
			})

			local search = New("TextBox", {
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = Theme.Panel,
				BackgroundTransparency = 0.4,
				Text = "",
				PlaceholderText = tostring(bCfg.SearchPlaceholder or "Search Scripts"),
				PlaceholderColor3 = Theme.TextDim,
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Left,
				BorderSizePixel = 0,
				Parent = left,
			}, {
				Corner(8),
				Stroke(0.93),
				New("UIPadding", { PaddingLeft = UDim.new(0, 32), PaddingRight = UDim.new(0, 8) }),
			})

			New("TextLabel", {
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.fromOffset(16, 32),
				BackgroundTransparency = 1,
				Text = "🔍",
				TextSize = 12,
				Parent = search,
			})

			local grid = New("ScrollingFrame", {
				Position = UDim2.fromOffset(0, 38),
				Size = UDim2.new(1, 0, 1, -38),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 2,
				ScrollBarImageColor3 = Theme.Stroke,
				ScrollBarImageTransparency = 0.7,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(),
				Parent = left,
			}, {
				New("UIGridLayout", {
					CellSize = UDim2.new(0.5, -5, 0, 58),
					CellPadding = UDim2.fromOffset(8, 8),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			})

			-- Правая часть: панель деталей
			local details = New("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 190, 1, 0),
				BackgroundColor3 = Theme.Panel,
				BackgroundTransparency = 0.4,
				BorderSizePixel = 0,
				Parent = holder,
			}, { Corner(10), Stroke(0.93) })

			local info = New("Frame", {
				Position = UDim2.fromOffset(10, 10),
				Size = UDim2.new(1, -20, 1, -56),
				BackgroundTransparency = 1,
				Parent = details,
			}, { New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }) })

			local function InfoLabel(order, text, bold, size, h)
				return New("TextLabel", {
					Size = UDim2.new(1, 0, 0, h or 14),
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = bold and Theme.Text or Theme.TextDim,
					Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
					TextSize = size or 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextTruncate = Enum.TextTruncate.AtEnd,
					LayoutOrder = order,
					Parent = info,
				})
			end

			local nameLbl = InfoLabel(1, "ScriptName", true, 14, 18)
			local byLbl = InfoLabel(2, "By: CreatorName", false, 10, 13)
			InfoLabel(3, "Description:", true, 11, 14)
			local descLbl = New("TextLabel", {
				Size = UDim2.new(1, 0, 0, 66),
				BackgroundTransparency = 1,
				Text = "ScriptDescription",
				TextColor3 = Theme.TextDim,
				Font = Enum.Font.Gotham,
				TextSize = 11,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				LayoutOrder = 4,
				Parent = info,
			})
			local rigLbl = InfoLabel(5, "RigType: Any", false, 10, 13)
			local gameLbl = InfoLabel(6, "Game: Universal", false, 10, 13)
			local idLbl = InfoLabel(7, "Script Id: —", false, 10, 13)

			local executeBtn = New("TextButton", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 10, 1, -10),
				Size = UDim2.new(1, -92, 0, 30),
				BackgroundColor3 = Theme.PanelHover,
				BackgroundTransparency = 0.2,
				Text = "Execute",
				TextColor3 = Theme.Text,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Parent = details,
			}, { Corner(8), Stroke(0.9) })

			local playBtn = New("TextButton", {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -46, 1, -10),
				Size = UDim2.fromOffset(30, 30),
				BackgroundColor3 = Theme.Green,
				Text = "▶",
				TextColor3 = Color3.fromRGB(20, 22, 26),
				TextSize = 12,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Parent = details,
			}, { Corner(8) })

			local starBtn = New("TextButton", {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -10, 1, -10),
				Size = UDim2.fromOffset(30, 30),
				BackgroundColor3 = Theme.Yellow,
				Text = "☆",
				TextColor3 = Color3.fromRGB(20, 22, 26),
				TextSize = 13,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Parent = details,
			}, { Corner(8) })

			-- Карточки
			local selectedCard
			local cardEntries = {}
			local order = 0

			local function SelectCard(entry)
				selectedCard = entry.Card
				for _, e in ipairs(cardEntries) do
					Tween(e.Frame, 0.15, { BackgroundColor3 = Theme.Element })
				end
				Tween(entry.Frame, 0.15, { BackgroundColor3 = Theme.PanelHover })
				local c = entry.Card
				nameLbl.Text = tostring(c.Name or "ScriptName")
				byLbl.Text = "By: " .. tostring(c.Creator or "Unknown")
				descLbl.Text = tostring(c.Description or "No description.")
				rigLbl.Text = "RigType: " .. tostring(c.RigType or "Any")
				gameLbl.Text = "Game: " .. tostring(c.Game or "Universal")
				idLbl.Text = "Script Id: " .. tostring(c.Id or "—")
				starBtn.Text = c.Favorite and "★" or "☆"
			end

			local function AddCard(card)
				order += 1
				local f = New("TextButton", {
					BackgroundColor3 = Theme.Element,
					BackgroundTransparency = 0.3,
					Text = "",
					AutoButtonColor = false,
					BorderSizePixel = 0,
					LayoutOrder = order,
					Parent = grid,
				}, {
					Corner(8),
					Stroke(0.93),
					New("TextLabel", {
						Position = UDim2.fromOffset(8, 6),
						Size = UDim2.new(1, -16, 1, -24),
						BackgroundTransparency = 1,
						Text = (card.Tag and (tostring(card.Tag) .. " ") or "") .. tostring(card.Name or "Script"),
						TextColor3 = Theme.Text,
						Font = Enum.Font.GothamBold,
						TextSize = 12,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
					New("TextLabel", {
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.new(0, 8, 1, -5),
						Size = UDim2.new(1, -16, 0, 12),
						BackgroundTransparency = 1,
						Text = "Id: " .. tostring(card.Id or "—"),
						TextColor3 = Theme.TextDim,
						Font = Enum.Font.Gotham,
						TextSize = 10,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
				})
				local entry = { Frame = f, Card = card }
				table.insert(cardEntries, entry)
				Hover(f, { BackgroundTransparency = 0.1 }, { BackgroundTransparency = 0.3 })
				f.MouseButton1Click:Connect(function()
					SelectCard(entry)
				end)
				return entry
			end

			search:GetPropertyChangedSignal("Text"):Connect(function()
				local q = string.lower(search.Text)
				for _, e in ipairs(cardEntries) do
					local nm = string.lower(tostring(e.Card.Name or ""))
					e.Frame.Visible = (q == "") or (string.find(nm, q, 1, true) ~= nil)
				end
			end)

			local function RunSelected()
				if not selectedCard then
					return
				end
				if selectedCard.Callback then
					task.spawn(selectedCard.Callback, selectedCard)
				end
				if bCfg.OnExecute then
					task.spawn(bCfg.OnExecute, selectedCard)
				end
			end

			executeBtn.MouseButton1Click:Connect(RunSelected)
			playBtn.MouseButton1Click:Connect(RunSelected)

			starBtn.MouseButton1Click:Connect(function()
				if not selectedCard then
					return
				end
				selectedCard.Favorite = not selectedCard.Favorite
				starBtn.Text = selectedCard.Favorite and "★" or "☆"
				if bCfg.OnFavorite then
					task.spawn(bCfg.OnFavorite, selectedCard, selectedCard.Favorite)
				end
			end)

			for _, card in ipairs(bCfg.Cards or {}) do
				AddCard(card)
			end
			if cardEntries[1] then
				SelectCard(cardEntries[1])
			end

			local Browser = {}
			function Browser:AddCard(card)
				return AddCard(card)
			end
			function Browser:GetSelected()
				return selectedCard
			end
			return Browser
		end

		return Tab
	end

	--// Уведомления (правый нижний угол)
	local notifHolder = New("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -14, 1, -14),
		Size = UDim2.fromOffset(280, 500),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	function Window:Notify(nCfg)
		nCfg = nCfg or {}
		local duration = nCfg.Duration or 4

		local n = New("CanvasGroup", {
			Size = UDim2.new(1, 0, 0, 52),
			BackgroundColor3 = Theme.Panel,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			GroupTransparency = 1,
			Parent = notifHolder,
		}, {
			Corner(10),
			Stroke(0.9),
			New("Frame", {
				Size = UDim2.new(0, 3, 1, 0),
				BackgroundColor3 = nCfg.Color or Theme.Accent,
				BorderSizePixel = 0,
			}),
			New("TextLabel", {
				Position = UDim2.fromOffset(14, 7),
				Size = UDim2.new(1, -26, 0, 15),
				BackgroundTransparency = 1,
				Text = tostring(nCfg.Title or windowName),
				TextColor3 = Theme.Text,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}),
			New("TextLabel", {
				Position = UDim2.fromOffset(14, 24),
				Size = UDim2.new(1, -26, 0, 20),
				BackgroundTransparency = 1,
				Text = tostring(nCfg.Content or ""),
				TextColor3 = Theme.TextDim,
				Font = Enum.Font.Gotham,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
			}),
		})

		Tween(n, 0.3, { GroupTransparency = 0 })
		task.delay(duration, function()
			if n and n.Parent then
				local t = Tween(n, 0.3, { GroupTransparency = 1 })
				t.Completed:Wait()
				n:Destroy()
			end
		end)
	end

	--// Показать / скрыть / свернуть / закрыть
	local visible = true
	local function SetVisible(v)
		visible = v
		main.Visible = v
		if blur then
			Tween(blur, 0.3, { Size = v and 14 or 0 })
		end
	end

	function Window:Toggle()
		SetVisible(not visible)
	end
	function Window:Show()
		SetVisible(true)
	end
	function Window:Hide()
		SetVisible(false)
	end
	function Window:Destroy()
		gui:Destroy()
		if blur then
			blur:Destroy()
		end
	end

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then
			return
		end
		if input.KeyCode == toggleKey then
			Window:Toggle()
		end
	end)

	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		body.Visible = not minimized
		Tween(main, 0.25, { Size = minimized and UDim2.fromOffset(width, 48) or UDim2.fromOffset(width, height) })
	end)

	closeBtn.MouseButton1Click:Connect(function()
		Tween(main, 0.25, { Size = UDim2.fromOffset(0, 0) })
		if blur then
			Tween(blur, 0.25, { Size = 0 })
		end
		task.delay(0.3, function()
			gui:Destroy()
			if blur then
				blur:Destroy()
			end
		end)
	end)

	MakeDraggable(topBar, main)

	--// Анимация появления
	Tween(main, 0.35, { Size = UDim2.fromOffset(width, height) })
	if blur then
		Tween(blur, 0.35, { Size = 14 })
	end

	return Window
end

return VHub
