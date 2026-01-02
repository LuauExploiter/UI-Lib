Vexona UI Library Documentation

Introduction

A sophisticated, clean, and highly customizable UI library for Roblox scripting with smooth animations and intelligent positioning. Designed with modern aesthetics and intuitive controls.

---

Installation

```lua
local Vexona = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuauExploiter/UI-Lib/refs/heads/main/UI.lua"))()
```

---

Core Features

CreateWindow

Initializes a new window instance with customizable settings.

```lua
local Window = Vexona:CreateWindow(Title: string, Options: table)
```

Parameters:

· Title - Window title displayed in header
· Options - Configuration table with properties:
  · Theme - Color scheme (currently only "Dark")
  · Keybind - Keyboard key to toggle window visibility
  · Scale - UI scaling factor
  · ForcePosition - Initial window placement

Position Options:

```lua
"TopLeft", "TopRight", "MiddleLeft", "MiddleRight", 
"BottomLeft", "BottomRight", "Center"
```

Example:

```lua
local MainWindow = Vexona:CreateWindow("Vexona Hub", {
    Theme = "Dark",
    Keybind = Enum.KeyCode.RightShift,
    Scale = 1,
    ForcePosition = "TopLeft"
})
```

---

Tab System

CreateTab

Adds a new tab container to organize interface elements.

```lua
local Tab = Window:CreateTab(Name: string)
```

Example:

```lua
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")
local PlayerTab = Window:CreateTab("Player")
```

---

Interface Elements

CreateToggle

Creates a binary toggle switch with visual feedback.

```lua
local ToggleInstance = Tab:CreateToggle(Label: string, Callback: function)
```

Callback Signature:

```lua
function(State: boolean)
```

ToggleInstance Methods:

· SetState(State: boolean) - Programmatically change toggle state
· GetState() - Retrieve current toggle state

Example:

```lua
local FlyToggle = MainTab:CreateToggle("Fly Mode", function(Enabled)
    print("Fly Mode:", Enabled)
end)

-- Modify state programmatically
FlyToggle:SetState(true)
local CurrentState = FlyToggle:GetState()
```

CreateButton

Creates an interactive button with hover effects.

```lua
Tab:CreateButton(Label: string, Callback: function)
```

Example:

```lua
MainTab:CreateButton("Teleport to Base", function()
    print("Teleporting...")
end)
```

CreateTextBox

Creates a text input field with placeholder support.

```lua
local TextBoxInstance = Tab:CreateTextBox(Label: string, Placeholder: string, Callback: function)
```

TextBoxInstance Methods:

· SetText(Text: string) - Programmatically set text content
· GetText() - Retrieve current text content

Example:

```lua
local SpeedInput = MainTab:CreateTextBox("Walk Speed", "Enter value 16-100", function(Text)
    print("Speed set to:", Text)
end)

-- Control text programmatically
SpeedInput:SetText("50")
local CurrentText = SpeedInput:GetText()
```

CreateLabel

Creates a non-interactive text label.

```lua
Tab:CreateLabel(Text: string)
```

Example:

```lua
MainTab:CreateLabel("Welcome to Vexona Hub")
```

CreateDropdown

Creates a selection dropdown menu.

```lua
local DropdownInstance = Tab:CreateDropdown(Label: string, Options: table, Callback: function)
```

DropdownInstance Methods:

· SetSelection(Option: string) - Programmatically select option
· GetSelection() - Retrieve current selection

Example:

```lua
local WeaponSelector = MainTab:CreateDropdown("Weapon", {"Sword", "Bow", "Staff", "Axe"}, function(Selected)
    print("Selected weapon:", Selected)
end)

-- Control selection programmatically
WeaponSelector:SetSelection("Bow")
local CurrentWeapon = WeaponSelector:GetSelection()
```

---

Statistics Display

CreateStatsPanel

Creates a dynamic statistics panel with automatic updates.

```lua
local StatsPanel = Window:CreateStatsPanel(Configuration: table)
```

Configuration Options:

· Position - Screen placement position
· Size - Initial panel dimensions
· Stats - Array of stat identifiers to display
· RefreshRate - Update frequency in seconds
· Title - Panel header text

Default Available Stats:

· "FPS" - Frames per second
· "Ping" - Network latency
· "Memory" - Memory usage (MB)
· "Players" - Active player count
· "ServerTime" - Server uptime

StatsPanel Methods:

· AddStat(Name: string, Function: function) - Add custom statistic
· RemoveStat(Name: string) - Remove specific statistic
· SetPosition(Position: string) - Reposition panel
· SetTitle(Title: string) - Update panel header
· Refresh() - Force immediate update
· ToggleMinimize() - Minimize/restore panel
· Destroy() - Remove panel

Example:

```lua
local PerformancePanel = Window:CreateStatsPanel({
    Position = "TopRight",
    Size = UDim2.new(0, 170, 0, 120),
    Stats = {"FPS", "Ping", "Memory"},
    RefreshRate = 1,
    Title = "Performance"
})

-- Add custom statistic
PerformancePanel:AddStat("Uptime", function()
    return math.floor(game:GetService("Workspace").DistributedGameTime/60) .. "m"
end)

-- Control panel
PerformancePanel:ToggleMinimize()
PerformancePanel:SetPosition("BottomRight")
```

---

Notification System

CreateNotification

Displays a temporary notification message.

```lua
Window:CreateNotification(Title: string, Message: string, Type: string, Duration: number)
```

Notification Types:

· "Info" - General information (default)
· "Success" - Success confirmation
· "Warning" - Warning message
· "Error" - Error notification

Example:

```lua
Window:CreateNotification("Welcome", "Vexona UI loaded successfully", "Success", 3)
Window:CreateNotification("Warning", "Memory usage is high", "Warning", 3)
Window:CreateNotification("Error", "Connection lost", "Error", 3)
```

---

Window Management

SetKeybind

Changes the keyboard shortcut for window visibility.

```lua
Window:SetKeybind(KeyCode: Enum.KeyCode)
```

Example:

```lua
Window:SetKeybind(Enum.KeyCode.F2)
```

SetPosition

Repositions the window on screen.

```lua
Window:SetPosition(Position: string)
```

Example:

```lua
Window:SetPosition("MiddleRight")
```

ToggleVisibility

Programmatically shows or hides the window.

```lua
Window:ToggleVisibility()
```

Destroy

Removes the window and all associated elements.

```lua
Window:Destroy()
```

---

Complete Example

```lua
local Vexona = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuauExploiter/UI-Lib/refs/heads/main/UI.lua"))()

local MainWindow = Vexona:CreateWindow("Vexona Hub", {
    Theme = "Dark",
    Keybind = Enum.KeyCode.RightShift,
    Scale = 1,
    ForcePosition = "TopLeft"
})

local MainTab = MainWindow:CreateTab("Main")
local SettingsTab = MainWindow:CreateTab("Settings")

MainTab:CreateLabel("Game Features")

local FlyToggle = MainTab:CreateToggle("Flight Mode", function(Enabled)
    MainWindow:CreateNotification("Flight", Enabled and "Enabled" or "Disabled", 
        Enabled and "Success" or "Info", 2)
end)

MainTab:CreateButton("Collect Resources", function()
    MainWindow:CreateNotification("Collection", "Gathering resources...", "Info", 2)
end)

local SpeedInput = MainTab:CreateTextBox("Speed Multiplier", "1.0-5.0", function(Value)
    MainWindow:CreateNotification("Speed", "Set to " .. Value, "Success", 2)
end)

local TeleportDropdown = MainTab:CreateDropdown("Teleport Location", 
    {"Spawn", "Base", "Secret Area", "Shop"}, function(Location)
    MainWindow:CreateNotification("Teleport", "Warping to " .. Location, "Info", 2)
end)

local StatsPanel = MainWindow:CreateStatsPanel({
    Position = "TopRight",
    Title = "Performance",
    Stats = {"FPS", "Ping", "Memory"}
})

StatsPanel:AddStat("Players", function()
    return #game:GetService("Players"):GetPlayers()
end)

MainWindow:CreateNotification("Welcome", "Vexona Hub initialized", "Success", 4)

print("Vexona UI loaded. Press RightShift to toggle.")
```

---

Design Philosophy

Smart Positioning

· Notifications automatically avoid overlapping with interface elements
· Statistics panels intelligently resize to content
· Elements maintain proper spacing and alignment

Smooth Animations

· Subtle transitions for state changes
· Fluid minimize/maximize effects
· Non-intrusive notification entry/exit

Clean Aesthetics

· Consistent color scheme and typography
· Minimal visual clutter
· Intuitive interaction patterns

Performance Focus

· Efficient update cycles
· Minimal memory footprint
· Responsive user interactions

---

Best Practices

1. Organize Elements Logically
   · Group related features in tabs
   · Use labels for section headers
   · Maintain consistent naming conventions
2. User Experience
   · Provide immediate feedback for actions
   · Use appropriate notification types
   · Keep interface uncluttered
3. Resource Management
   · Remove statistics panels when not needed
   · Use appropriate refresh rates
   · Clean up window instances on script termination

---

Support

For issues or questions:

1. Verify you're using the latest library version
2. Check element positioning and sizing
3. Review callback function implementations
4. Ensure proper cleanup of UI instances

---

License

Free for personal and commercial use. Attribution appreciated but not required.

---

Vexona UI - Elegant interface design for Roblox experiences
