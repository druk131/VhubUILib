# VHub UI Library

GUI-библиотека для Roblox (Lua/Luau), воссоздающая легендарный интерфейс **VexHub**: тёмное «стеклянное» окно, сайдбар с вкладками и профилем игрока, браузер скриптов с карточками и панелью деталей, уведомления, перетаскивание окна и блюр фона.

## Подключение

```lua
local VHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/druk131/VhubUILib/main/VHub.lua"))()
```

Полный рабочий пример — в [Example.lua](Example.lua).

## Быстрый старт

```lua
local Window = VHub:CreateWindow({
    Name = "VexHub",
    Version = "V6.143",
    ToggleKey = Enum.KeyCode.RightShift, -- скрыть/показать
    Blur = true,
})

local Tab = Window:CreateTab({ Name = "Scripts", Icon = "📜" })

Tab:CreateButton({ Name = "Кнопка", Callback = function() print("click") end })
Tab:CreateToggle({ Name = "Тоггл", Default = false, Callback = function(v) print(v) end })
Tab:CreateSlider({ Name = "Слайдер", Min = 0, Max = 100, Default = 50, Callback = function(v) print(v) end })
Tab:CreateDropdown({ Name = "Дропдаун", Options = { "A", "B" }, Callback = function(o) print(o) end })
Tab:CreateInput({ Name = "Инпут", Placeholder = "Текст...", Callback = function(t) print(t) end })
Tab:CreateKeybind({ Name = "Бинд", Default = Enum.KeyCode.E, Callback = function() print("pressed") end })

Window:Notify({ Title = "VexHub", Content = "Готово!", Duration = 3 })
```

## API

### `VHub:CreateWindow(config)`

| Параметр | Тип | По умолчанию | Описание |
|---|---|---|---|
| `Name` | string | `"VHub"` | Название в шапке |
| `Version` | string | `"V1.0"` | Версия под названием |
| `Logo` | string? | `nil` | `rbxassetid://` логотипа (иначе — первая буква имени) |
| `ToggleKey` | Enum.KeyCode | `RightShift` | Клавиша скрыть/показать окно |
| `Blur` | boolean | `true` | Блюр фона, пока окно открыто |
| `Width` / `Height` | number | `650` / `400` | Размер окна |
| `DisplayName` / `Username` / `Avatar` | string? | данные игрока | Профиль в сайдбаре |
| `Theme` | table? | `nil` | Переопределение цветов (`Accent`, `Background`, ...) |

Методы окна: `CreateTab`, `Notify`, `Toggle`, `Show`, `Hide`, `Destroy`.
Значения элементов с полем `Flag` складываются в `Window.Flags[flag]`.

### `Window:CreateTab({ Name, Icon })`

Возвращает вкладку. Элементы вкладки:

- `CreateSection(text)` — заголовок группы
- `CreateLabel(text)` → `:Set(text)`
- `CreateParagraph({ Title, Content })` → `:Set(title, content)`
- `CreateButton({ Name, Callback })`
- `CreateToggle({ Name, Default, Flag, Callback })` → `:Set(v)` / `:Get()`
- `CreateSlider({ Name, Min, Max, Increment, Default, Suffix, Flag, Callback })` → `:Set(v)` / `:Get()`
- `CreateDropdown({ Name, Options, Default, Flag, Callback })` → `:Refresh(options)` / `:Set(opt)` / `:Get()`
- `CreateInput({ Name, Placeholder, Default, Flag, Callback })` → `:Set(t)` / `:Get()`
- `CreateKeybind({ Name, Default, Flag, OnChanged, Callback })` → `:Get()`
- `CreateScriptBrowser({ Cards, SearchPlaceholder, Height, OnExecute, OnFavorite })` → `:AddCard(card)` / `:GetSelected()`

### Браузер скриптов

Формат карточки:

```lua
{
    Tag = "[OP]",              -- необязательный тег перед названием
    Name = "Anti Kick",
    Id = 1002,
    Creator = "CreatorName",
    Description = "Защита от кика.",
    RigType = "Any",
    Game = "Universal",
    Callback = function(card)  -- вызывается по кнопке Execute
        -- loadstring(game:HttpGet(card.Url))()
    end,
}
```

`OnExecute(card)` — общий обработчик запуска, `OnFavorite(card, isFav)` — звёздочка избранного. Поиск фильтрует карточки по имени автоматически.

## Файлы

- `VHub.lua` — сама библиотека (ничего не требует, всё в одном файле)
- `Example.lua` — демо-хаб в стиле VexHub (вкладки Home / Favorites / Scripts / GUIS / ...)

## Дисклеймер

Библиотека — только интерфейс (GUI). Сами скрипты в карточках подключаются вами самостоятельно. Используйте на свой страх и риск.
