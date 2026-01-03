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

CreateEntryContainer

Creates a scrollable container for dynamic content entries.

```lua
local Container = Tab:CreateEntryContainer()
```

Example:

```lua
local EntriesContainer = MainTab:CreateEntryContainer()
```

CreateBrainrotEntry

Creates a styled entry card for displaying structured data.

```lua
local Entry = Tab:CreateBrainrotEntry(ParentFrame: Instance, AnimalData: table, Index: number, TeleportCallback: function)
```

Parameters:

· ParentFrame - The container to parent the entry to
· AnimalData - Table containing entry data: {Name, GenText, Mutation}
· Index - Display order index
· TeleportCallback - Function called when TP button is clicked

Example:

```lua
local entry = Tab:CreateBrainrotEntry(EntriesContainer, {
    Name = "Dragon",
    GenText = "Generation 3",
    Mutation = "Fire Breath"
}, 1, function(data)
    print("Teleporting to:", data.Name)
end)
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

Example:

```lua
-- Toggle window visibility
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

-- Create an entry container and add entries
local EntriesContainer = MainTab:CreateEntryContainer()
for i = 1, 5 do
    Tab:CreateBrainrotEntry(EntriesContainer, {
        Name = "Pet " .. i,
        GenText = "Generation " .. math.random(1, 10),
        Mutation = math.random(1, 3) == 1 and "Special" or "None"
    }, i, function(data)
        print("Selected:", data.Name)
    end)
end

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
· Automatic device scaling for different screen sizes

Smooth Animations

· Subtle transitions for state changes
· Fluid minimize/maximize effects
· Non-intrusive notification entry/exit
· Interactive hover effects on buttons

Clean Aesthetics

· Consistent color scheme and typography
· Minimal visual clutter
· Intuitive interaction patterns
· Modern dark theme with accent colors

Performance Focus

· Efficient update cycles
· Minimal memory footprint
· Responsive user interactions
· Optimized rendering for Roblox engine

---

Best Practices

1. Organization

```lua
-- Group related features
local CombatTab = Window:CreateTab("Combat")
local MovementTab = Window:CreateTab("Movement")
local VisualTab = Window:CreateTab("Visuals")

-- Use labels for sections
CombatTab:CreateLabel("Weapon Modifications")
CombatTab:CreateLabel("Player Modifications")
```

2. User Experience

```lua
-- Provide feedback for actions
Tab:CreateButton("Execute", function()
    Window:CreateNotification("Success", "Script executed", "Success", 2)
end)

-- Use appropriate notification types
Window:CreateNotification("Error", "Invalid input", "Error", 3)
```

3. Resource Management

```lua
-- Clean up when done
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if StatsPanel then
        StatsPanel:Destroy()
    end
end)
```

4. Tab Management

· Each tab has isolated content
· First tab is automatically selected
· Smooth transitions between tabs
· Tab content is properly scoped

---

Troubleshooting

Common Issues:

1. Elements not appearing in correct tab?
   · Ensure you're creating elements on the correct tab instance
   · Each tab has its own content frame
2. Window not responding to keybind?
   · Check if another script is using the same key
   · Verify the keycode is correct: Enum.KeyCode.RightShift
3. Notifications overlapping?
   · Notifications automatically stack vertically
   · Each notification has a unique position calculation
4. Performance issues?
   · Reduce stats panel refresh rate
   · Minimize animations on low-end devices
   · Use appropriate scaling factor

---

Changelog

v1.2.0

· Fixed tab system: Each tab now has isolated content
· First tab automatically selected on window creation
· Improved scrolling frame management
· Enhanced entry system with styled cards

v1.1.0

· Added stats panel system
· Added notification system
· Improved animations and transitions
· Added device scaling support

v1.0.0

· Initial release
· Basic UI components
· Tab system
· Theme support

---

Support

For issues or questions:

1. GitHub Issues: Open an issue on the repository
2. Discord: Join our Discord server for support
3. Documentation: Refer to this documentation for examples

Before reporting issues:

· Verify you're using the latest version
· Check if the issue is reproducible
· Provide code snippets and error messages

---

License

Free for personal and commercial use. Attribution appreciated but not required.

---

Vexona UI - Elegant interface design for Roblox experiences
Clean • Performant • Customizable
