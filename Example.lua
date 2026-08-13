--// Пример использования VHub UI Library (воссоздание интерфейса VexHub)
local VHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/druk131/VhubUILib/main/VHub.lua"))()

local Window = VHub:CreateWindow({
	Name = "VexHub",
	Version = "V6.143",
	ToggleKey = Enum.KeyCode.RightShift, -- клавиша показа/скрытия хаба
	Blur = true, -- блюр фона, пока окно открыто
	-- Logo = "rbxassetid://...", -- своё лого (опционально, иначе первая буква имени)
	-- Theme = { Accent = Color3.fromRGB(88, 101, 242) }, -- кастомные цвета
})

--// Вкладки как в оригинале
local Home = Window:CreateTab({ Name = "Home", Icon = "🏠" })
local Favorites = Window:CreateTab({ Name = "Favorites", Icon = "⭐" })
local Scripts = Window:CreateTab({ Name = "Scripts", Icon = "📜" })
local GUIS = Window:CreateTab({ Name = "GUIS", Icon = "🖥️" })
local Animations = Window:CreateTab({ Name = "Animations", Icon = "🎭" })
local Commands = Window:CreateTab({ Name = "Commands", Icon = "⌨️" })
local OtherHubs = Window:CreateTab({ Name = "Other Hubs", Icon = "🌐" })
local Limited = Window:CreateTab({ Name = "Limited Scripts", Icon = "🔒" })

--// Home
Home:CreateParagraph({
	Title = "Добро пожаловать в VexHub 👋",
	Content = "RightShift — скрыть/показать хаб. Выбери вкладку слева, чтобы открыть раздел.",
})

Home:CreateButton({
	Name = "Discord сервер",
	Callback = function()
		Window:Notify({ Title = "VexHub", Content = "Ссылка скопирована!", Duration = 3 })
	end,
})

--// Scripts — браузер скриптов с карточками и панелью деталей (как на референсе)
local Browser = Scripts:CreateScriptBrowser({
	Cards = {
		{ Name = "Copy Chat Messages", Id = 1001, Creator = "CreatorName", Description = "Копирует сообщения чата.", RigType = "Any", Game = "Universal" },
		{ Tag = "[OP]", Name = "Anti Kick", Id = 1002, Creator = "CreatorName", Description = "Защита от кика.", RigType = "Any", Game = "Universal" },
		{ Tag = "[OP]", Name = "Kill Farm", Id = 1003, Creator = "CreatorName", Description = "Фарм килов.", RigType = "Any", Game = "Universal" },
		{ Tag = "[OP]", Name = "Spy On People's Private Chat", Id = 1004, Creator = "CreatorName", Description = "Просмотр приватного чата.", RigType = "Any", Game = "Universal" },
		{ Tag = "[OP]", Name = "Teleport Tool", Id = 1005, Creator = "CreatorName", Description = "Инструмент телепортации.", RigType = "Any", Game = "Universal" },
		{ Tag = "[OP]", Name = "Telekinesis Gun", Id = 1006, Creator = "CreatorName", Description = "Телекинез-пушка.", RigType = "Any", Game = "Universal" },
	},
	OnExecute = function(card)
		Window:Notify({ Title = "Execute", Content = "Запуск: " .. tostring(card.Name), Duration = 3 })
		-- Здесь подключай сам скрипт, например:
		-- loadstring(game:HttpGet(card.Url))()
	end,
	OnFavorite = function(card, fav)
		Window:Notify({ Title = "Favorites", Content = tostring(card.Name) .. (fav and " добавлен ⭐" or " удалён"), Duration = 2 })
	end,
})

-- Можно добавлять карточки на лету:
-- Browser:AddCard({ Tag = "[NEW]", Name = "Speed Hub", Id = 1007, Creator = "Vex", Description = "...", Callback = function() end })

--// GUIS — примеры стандартных элементов
GUIS:CreateSection("Элементы управления")

GUIS:CreateToggle({
	Name = "Fly",
	Default = false,
	Flag = "Fly",
	Callback = function(v)
		print("Fly:", v)
	end,
})

GUIS:CreateSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 250,
	Default = 16,
	Increment = 1,
	Flag = "Speed",
	Callback = function(v)
		local char = game:GetService("Players").LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = v
		end
	end,
})

GUIS:CreateDropdown({
	Name = "Телепорт",
	Options = { "Spawn", "Base", "Shop" },
	Callback = function(opt)
		print("TP to:", opt)
	end,
})

GUIS:CreateInput({
	Name = "JumpPower",
	Placeholder = "Введи число...",
	Callback = function(text)
		local n = tonumber(text)
		if n then
			print("JumpPower:", n)
		end
	end,
})

GUIS:CreateKeybind({
	Name = "Panic key",
	Default = Enum.KeyCode.P,
	Callback = function()
		Window:Toggle()
	end,
})

--// Остальные вкладки-заглушки
Favorites:CreateLabel("Избранные скрипты появятся здесь.")
Animations:CreateLabel("Раздел анимаций — добавь свои элементы.")
Commands:CreateLabel("Команды хаба.")
OtherHubs:CreateLabel("Другие хабы.")
Limited:CreateLabel("Лимитированные скрипты.")

Window:Notify({
	Title = "VexHub V6.143",
	Content = "UI загружен. RightShift — скрыть/показать.",
	Duration = 5,
})
