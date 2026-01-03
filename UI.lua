local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StatsService = game:GetService("Stats")

local Library = {}
Library.Windows = {}
Library.Notifications = {}
Library.StatsPanels = {}

local Themes = {
    Dark = {
        Background = Color3.fromRGB(12, 12, 12),
        Tab = Color3.fromRGB(20, 20, 20),
        TabSelected = Color3.fromRGB(30, 30, 30),
        Button = Color3.fromRGB(32, 32, 32),
        ButtonHover = Color3.fromRGB(50, 50, 50),
        Toggle = Color3.fromRGB(22, 22, 22),
        ToggleOn = Color3.fromRGB(65, 255, 65),
        ToggleOff = Color3.fromRGB(255, 65, 65),
        TextBox = Color3.fromRGB(22, 22, 22),
        Dropdown = Color3.fromRGB(22, 22, 22),
        DropdownSelected = Color3.fromRGB(40, 40, 40),
        Stroke = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(130, 130, 130),
        Notification = Color3.fromRGB(25, 25, 25),
        NotificationSuccess = Color3.fromRGB(20, 120, 20),
        NotificationError = Color3.fromRGB(120, 20, 20),
        NotificationWarning = Color3.fromRGB(120, 80, 20),
        StatsPanel = Color3.fromRGB(15, 15, 15),
        EntryBackground = Color3.fromRGB(30, 30, 30),
        EntryStroke = Color3.fromRGB(60, 60, 60),
        EntryText = Color3.fromRGB(240, 240, 240),
        EntryTextSecondary = Color3.fromRGB(200, 200, 200),
        EntryTextMuted = Color3.fromRGB(150, 150, 150),
        EntryButton = Color3.fromRGB(80, 80, 80),
        EntryButtonHover = Color3.fromRGB(100, 100, 100),
        EntryButtonStroke = Color3.fromRGB(120, 120, 120),
        EntryMutationGreen = Color3.fromRGB(160, 220, 160)
    }
}

local ScreenSize = workspace.CurrentCamera.ViewportSize

local function GetDeviceScale()
    local BaseScale = 1
    if ScreenSize.Y <= 720 then
        BaseScale = 0.85
    elseif ScreenSize.Y <= 900 then
        BaseScale = 0.9
    elseif ScreenSize.Y >= 1440 then
        BaseScale = 1.1
    end
    return BaseScale
end

local DeviceScale = GetDeviceScale()

function Library:CreateWindow(Title, Options)
    local WindowSettings = Options or {}
    local ThemeName = WindowSettings.Theme or "Dark"
    local Keybind = WindowSettings.Keybind or Enum.KeyCode.RightShift
    local UseKeySystem = WindowSettings.UseKeySystem or false
    local RequiredKey = WindowSettings.RequiredKey or ""
    local Theme = Themes[ThemeName] or Themes.Dark
    local ScaleFactor = WindowSettings.Scale or DeviceScale
    local ForcePosition = WindowSettings.ForcePosition
    
    local Window = {}
    local IsMinimized = false
    local CurrentPage = nil
    local Elements = {}
    local OriginalHeight = 320 * ScaleFactor
    local Tabs = {}
    local TabButtons = {}
    local TabGrid = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Vexona_" .. HttpService:GenerateGUID(false)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    Main.Size = UDim2.new(0, 240 * ScaleFactor, 0, OriginalHeight)
    Main.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Stroke
    MainStroke.Transparency = 0.8
    MainStroke.Thickness = 1 * ScaleFactor
    MainStroke.Parent = Main
    
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 36 * ScaleFactor)
    Header.BackgroundTransparency = 1
    Header.Parent = Main
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -70 * ScaleFactor, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10 * ScaleFactor, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 12 * ScaleFactor
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header
    
    -- Buttons
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 20 * ScaleFactor, 0, 20 * ScaleFactor)
    CloseButton.Position = UDim2.new(1, -26 * ScaleFactor, 0.5, -10 * ScaleFactor)
    CloseButton.BackgroundColor3 = Theme.Background
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(220, 60, 60)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14 * ScaleFactor
    CloseButton.Parent = Header
    
    local CloseButtonCorner = Instance.new("UICorner")
    CloseButtonCorner.CornerRadius = UDim.new(0, 4)
    CloseButtonCorner.Parent = CloseButton
    
    local MinButton = Instance.new("TextButton")
    MinButton.Size = UDim2.new(0, 20 * ScaleFactor, 0, 20 * ScaleFactor)
    MinButton.Position = UDim2.new(1, -52 * ScaleFactor, 0.5, -10 * ScaleFactor)
    MinButton.BackgroundColor3 = Theme.Background
    MinButton.Text = "−"
    MinButton.TextColor3 = Theme.Text
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextSize = 14 * ScaleFactor
    MinButton.Parent = Header
    
    local MinButtonCorner = Instance.new("UICorner")
    MinButtonCorner.CornerRadius = UDim.new(0, 4)
    MinButtonCorner.Parent = MinButton
    
    -- Button hover effects
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        }):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Background
        }):Play()
    end)
    
    MinButton.MouseEnter:Connect(function()
        TweenService:Create(MinButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Button
        }):Play()
    end)
    
    MinButton.MouseLeave:Connect(function()
        TweenService:Create(MinButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Background
        }):Play()
    end)
    
    -- Tab grid system
    local TabGridContainer = Instance.new("Frame")
    TabGridContainer.Size = UDim2.new(1, -16 * ScaleFactor, 0, 56 * ScaleFactor) -- Height for 2 rows
    TabGridContainer.Position = UDim2.new(0, 8 * ScaleFactor, 0, 40 * ScaleFactor)
    TabGridContainer.BackgroundColor3 = Theme.Tab
    TabGridContainer.Parent = Main
    
    local TabGridContainerCorner = Instance.new("UICorner")
    TabGridContainerCorner.CornerRadius = UDim.new(0, 4)
    TabGridContainerCorner.Parent = TabGridContainer
    
    local TabGridScroll = Instance.new("ScrollingFrame")
    TabGridScroll.Size = UDim2.new(1, 0, 1, 0)
    TabGridScroll.BackgroundTransparency = 1
    TabGridScroll.ScrollBarThickness = 2 * ScaleFactor
    TabGridScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    TabGridScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabGridScroll.Parent = TabGridContainer
    
    local TabGridLayout = Instance.new("UIGridLayout")
    TabGridLayout.CellSize = UDim2.new(0.333, -5 * ScaleFactor, 0, 26 * ScaleFactor) -- 3 per row
    TabGridLayout.CellPadding = UDim2.new(0, 4 * ScaleFactor, 0, 4 * ScaleFactor)
    TabGridLayout.FillDirection = Enum.FillDirection.Horizontal
    TabGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    TabGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabGridLayout.Parent = TabGridScroll
    
    TabGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabGridScroll.CanvasSize = UDim2.new(0, 0, 0, TabGridLayout.AbsoluteContentSize.Y)
    end)
    
    local Content = Instance.new("Frame")
    Content.BackgroundTransparency = 1
    Content.Size = UDim2.new(1, 0, 1, -100 * ScaleFactor) -- Adjusted for tab grid
    Content.Position = UDim2.new(0, 0, 0, 100 * ScaleFactor)
    Content.Parent = Main
    
    local function UpdateSize()
        local ContentHeight = CurrentPage and (CurrentPage.CanvasSize.Y.Offset + 20 * ScaleFactor) or 200 * ScaleFactor
        local NewHeight = math.max(350 * ScaleFactor, 100 * ScaleFactor + ContentHeight)
        OriginalHeight = NewHeight
        
        Main.Size = UDim2.new(0, 240 * ScaleFactor, 0, NewHeight)
        Content.Size = UDim2.new(1, 0, 1, -100 * ScaleFactor)
        Content.Position = UDim2.new(0, 0, 0, 100 * ScaleFactor)
    end
    
    if ForcePosition then
        if ForcePosition == "TopLeft" then
            Main.Position = UDim2.new(0, 10, 0, 10)
        elseif ForcePosition == "TopRight" then
            Main.Position = UDim2.new(1, -250 * ScaleFactor, 0, 10)
        elseif ForcePosition == "MiddleLeft" then
            Main.Position = UDim2.new(0, 10, 0.5, -OriginalHeight/2)
        elseif ForcePosition == "MiddleRight" then
            Main.Position = UDim2.new(1, -250 * ScaleFactor, 0.5, -OriginalHeight/2)
        elseif ForcePosition == "BottomLeft" then
            Main.Position = UDim2.new(0, 10, 1, -OriginalHeight - 10)
        elseif ForcePosition == "BottomRight" then
            Main.Position = UDim2.new(1, -250 * ScaleFactor, 1, -OriginalHeight - 10)
        else
            Main.Position = UDim2.new(0.5, -120 * ScaleFactor, 0.5, -OriginalHeight/2)
        end
    else
        Main.Position = UDim2.new(0.5, -120 * ScaleFactor, 0.5, -OriginalHeight/2)
    end
    
    CloseButton.MouseButton1Click:Connect(function()
        local Tween = TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        Tween:Play()
        task.wait(0.2)
        ScreenGui:Destroy()
    end)
    
    MinButton.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        
        if IsMinimized then
            MinButton.Text = "+"
            TweenService:Create(TabGridContainer, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(Content, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.1)
            TabGridContainer.Visible = false
            Content.Visible = false
            
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, Main.Size.X.Offset, 0, 36 * ScaleFactor)
            }):Play()
        else
            MinButton.Text = "−"
            TabGridContainer.Visible = true
            Content.Visible = true
            TweenService:Create(TabGridContainer, TweenInfo.new(0.2), {
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(Content, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, Main.Size.X.Offset, 0, OriginalHeight)
            }):Play()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(Input, Processed)
        if not Processed and Input.KeyCode == Keybind then
            Main.Visible = not Main.Visible
        end
    end)
    
    function Window:SetKeybind(NewKeybind)
        Keybind = NewKeybind
    end
    
    function Window:SetPosition(NewPosition)
        if NewPosition == "TopLeft" then
            Main.Position = UDim2.new(0, 10, 0, 10)
        elseif NewPosition == "TopRight" then
            Main.Position = UDim2.new(1, -250 * ScaleFactor, 0, 10)
        elseif NewPosition == "MiddleLeft" then
            Main.Position = UDim2.new(0, 10, 0.5, -OriginalHeight/2)
        elseif NewPosition == "MiddleRight" then
            Main.Position = UDim2.new(1, -250 * ScaleFactor, 0.5, -OriginalHeight/2)
        elseif NewPosition == "BottomLeft" then
            Main.Position = UDim2.new(0, 10, 1, -OriginalHeight - 10)
        elseif NewPosition == "BottomRight" then
            Main.Position = UDim2.new(1, -250 * ScaleFactor, 1, -OriginalHeight - 10)
        elseif NewPosition == "Center" then
            Main.Position = UDim2.new(0.5, -120 * ScaleFactor, 0.5, -OriginalHeight/2)
        else
            Main.Position = NewPosition
        end
    end
    
    function Window:CreateTab(Name)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = Name
        TabButton.TextColor3 = Theme.TextMuted
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 9 * ScaleFactor
        TabButton.LayoutOrder = #TabGridScroll:GetChildren()
        TabButton.Parent = TabGridScroll
        
        local Page = Instance.new("ScrollingFrame")
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2 * ScaleFactor
        Page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Parent = Content
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 6 * ScaleFactor)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageList.Parent = Page
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
            CurrentPage = Page
            UpdateSize()
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, Child in pairs(Content:GetChildren()) do
                if Child:IsA("ScrollingFrame") then
                    Child.Visible = false
                end
            end
            for _, Child in pairs(TabGridScroll:GetChildren()) do
                if Child:IsA("TextButton") then
                    Child.TextColor3 = Theme.TextMuted
                end
            end
            Page.Visible = true
            TabButton.TextColor3 = Theme.Text
            CurrentPage = Page
            UpdateSize()
        end)
        
        if CurrentPage == nil then
            CurrentPage = Page
            Page.Visible = true
            TabButton.TextColor3 = Theme.Text
            UpdateSize()
        end
        
        Page.Size = UDim2.new(1, -8 * ScaleFactor, 1, -6 * ScaleFactor)
        Page.Position = UDim2.new(0, 4 * ScaleFactor, 0, 3 * ScaleFactor)
        
        local TabItems = {}
        
        function TabItems:CreateToggle(Text, Callback)
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 210 * ScaleFactor, 0, 28 * ScaleFactor)
            ToggleButton.BackgroundColor3 = Theme.Toggle
            ToggleButton.Text = Text .. ": OFF"
            ToggleButton.TextColor3 = Theme.ToggleOff
            ToggleButton.Font = Enum.Font.GothamBold
            ToggleButton.TextSize = 9 * ScaleFactor
            ToggleButton.Parent = Page
            
            Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 5)
            
            local State = false
            
            ToggleButton.MouseButton1Click:Connect(function()
                State = not State
                ToggleButton.Text = Text .. ": " .. (State and "ON" or "OFF")
                local TargetColor = State and Theme.ToggleOn or Theme.ToggleOff
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = TargetColor}):Play()
                Callback(State)
            end)
            
            local ToggleObject = {}
            
            function ToggleObject:SetState(NewState)
                State = NewState
                ToggleButton.Text = Text .. ": " .. (State and "ON" or "OFF")
                local TargetColor = State and Theme.ToggleOn or Theme.ToggleOff
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = TargetColor}):Play()
                Callback(State)
            end
            
            function ToggleObject:GetState()
                return State
            end
            
            table.insert(Elements, ToggleObject)
            return ToggleObject
        end
        
        function TabItems:CreateButton(Text, Callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 210 * ScaleFactor, 0, 28 * ScaleFactor)
            Button.BackgroundColor3 = Theme.Button
            Button.Text = Text
            Button.TextColor3 = Theme.Text
            Button.Font = Enum.Font.GothamBold
            Button.TextSize = 9 * ScaleFactor
            Button.Parent = Page
            
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)
            
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ButtonHover}):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Button}):Play()
            end)
            
            Button.MouseButton1Click:Connect(function()
                local OriginalColor = Button.BackgroundColor3
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                task.wait(0.1)
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = OriginalColor}):Play()
                Callback()
            end)
        end
        
        function TabItems:CreateTextBox(Text, Placeholder, Callback)
            local TextBoxFrame = Instance.new("Frame")
            TextBoxFrame.Size = UDim2.new(0, 210 * ScaleFactor, 0, 40 * ScaleFactor)
            TextBoxFrame.BackgroundTransparency = 1
            TextBoxFrame.Parent = Page
            
            local TextBoxTitle = Instance.new("TextLabel")
            TextBoxTitle.Size = UDim2.new(1, 0, 0, 16 * ScaleFactor)
            TextBoxTitle.BackgroundTransparency = 1
            TextBoxTitle.Text = Text
            TextBoxTitle.TextColor3 = Theme.Text
            TextBoxTitle.Font = Enum.Font.GothamBold
            TextBoxTitle.TextSize = 9 * ScaleFactor
            TextBoxTitle.TextXAlignment = Enum.TextXAlignment.Left
            TextBoxTitle.Parent = TextBoxFrame
            
            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, 0, 0, 20 * ScaleFactor)
            TextBox.Position = UDim2.new(0, 0, 0, 18 * ScaleFactor)
            TextBox.BackgroundColor3 = Theme.TextBox
            TextBox.TextColor3 = Theme.Text
            TextBox.PlaceholderText = Placeholder
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 9 * ScaleFactor
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = TextBoxFrame
            
            Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)
            
            TextBox.FocusLost:Connect(function(EnterPressed)
                if EnterPressed then
                    Callback(TextBox.Text)
                end
            end)
            
            local TextBoxObject = {}
            
            function TextBoxObject:SetText(NewText)
                TextBox.Text = NewText
            end
            
            function TextBoxObject:GetText()
                return TextBox.Text
            end
            
            table.insert(Elements, TextBoxObject)
            return TextBoxObject
        end
        
        function TabItems:CreateLabel(Text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 210 * ScaleFactor, 0, 18 * ScaleFactor)
            Label.BackgroundTransparency = 1
            Label.Text = Text
            Label.TextColor3 = Theme.TextMuted
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 9 * ScaleFactor
            Label.Parent = Page
        end
        
        function TabItems:CreateDropdown(Text, Options, Callback)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(0, 210 * ScaleFactor, 0, 28 * ScaleFactor)
            DropdownFrame.BackgroundColor3 = Theme.Dropdown
            DropdownFrame.Parent = Page
            
            Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 5)
            
            local DropdownTitle = Instance.new("TextLabel")
            DropdownTitle.Size = UDim2.new(1, -30 * ScaleFactor, 1, 0)
            DropdownTitle.Position = UDim2.new(0, 8 * ScaleFactor, 0, 0)
            DropdownTitle.BackgroundTransparency = 1
            DropdownTitle.Text = Text .. ": " .. (Options[1] or "NONE")
            DropdownTitle.TextColor3 = Theme.Text
            DropdownTitle.Font = Enum.Font.GothamBold
            DropdownTitle.TextSize = 9 * ScaleFactor
            DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
            DropdownTitle.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(0, 18 * ScaleFactor, 0, 18 * ScaleFactor)
            DropdownButton.Position = UDim2.new(1, -23 * ScaleFactor, 0.5, -9 * ScaleFactor)
            DropdownButton.BackgroundColor3 = Theme.Button
            DropdownButton.Text = "▼"
            DropdownButton.TextColor3 = Theme.Text
            DropdownButton.Font = Enum.Font.GothamBold
            DropdownButton.TextSize = 9 * ScaleFactor
            DropdownButton.Parent = DropdownFrame
            
            Instance.new("UICorner", DropdownButton).CornerRadius = UDim.new(0, 4)
            
            local DropdownList = Instance.new("ScrollingFrame")
            DropdownList.Size = UDim2.new(0, 210 * ScaleFactor, 0, 0)
            DropdownList.BackgroundColor3 = Theme.Dropdown
            DropdownList.ScrollBarThickness = 0
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
            DropdownList.Visible = false
            DropdownList.ZIndex = 10
            DropdownList.Parent = ScreenGui
            
            Instance.new("UICorner", DropdownList).CornerRadius = UDim.new(0, 5)
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = DropdownList
            
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
            end)
            
            local IsOpen = false
            local Selected = Options[1]
            
            local function UpdateDropdown()
                DropdownTitle.Text = Text .. ": " .. Selected
                for _, OptionButton in pairs(DropdownList:GetChildren()) do
                    if OptionButton:IsA("TextButton") then
                        OptionButton.BackgroundColor3 = OptionButton.Text == Selected and Theme.DropdownSelected or Theme.Dropdown
                    end
                end
                Callback(Selected)
            end
            
            local function CloseAllDropdowns()
                for _, Child in pairs(ScreenGui:GetChildren()) do
                    if Child:IsA("ScrollingFrame") and Child ~= TabGridScroll then
                        TweenService:Create(Child, TweenInfo.new(0.2), {Size = UDim2.new(0, 210 * ScaleFactor, 0, 0)}):Play()
                        task.wait(0.2)
                        Child.Visible = false
                    end
                end
            end
            
            local function ToggleDropdown()
                IsOpen = not IsOpen
                
                if IsOpen then
                    CloseAllDropdowns()
                    local Position = DropdownFrame.AbsolutePosition
                    DropdownList.Position = UDim2.new(0, Position.X, 0, Position.Y + DropdownFrame.AbsoluteSize.Y + 2)
                    DropdownList.Visible = true
                    TweenService:Create(DropdownList, TweenInfo.new(0.2), {
                        Size = UDim2.new(0, 210 * ScaleFactor, 0, math.min(#Options * 22 * ScaleFactor, 110 * ScaleFactor))
                    }):Play()
                else
                    TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(0, 210 * ScaleFactor, 0, 0)}):Play()
                    task.wait(0.2)
                    DropdownList.Visible = false
                end
            end
            
            DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
            
            UserInputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and IsOpen then
                    local MousePos = Input.Position
                    local ListPos = DropdownList.AbsolutePosition
                    local ListSize = DropdownList.AbsoluteSize
                    local FramePos = DropdownFrame.AbsolutePosition
                    local FrameSize = DropdownFrame.AbsoluteSize
                    
                    if not (MousePos.X >= FramePos.X and MousePos.X <= FramePos.X + FrameSize.X and
                           MousePos.Y >= FramePos.Y and MousePos.Y <= FramePos.Y + FrameSize.Y + ListSize.Y) then
                        ToggleDropdown()
                    end
                end
            end)
            
            for _, Option in pairs(Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 22 * ScaleFactor)
                OptionButton.BackgroundColor3 = Theme.Dropdown
                OptionButton.Text = Option
                OptionButton.TextColor3 = Theme.Text
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.TextSize = 9 * ScaleFactor
                OptionButton.Parent = DropdownList
                
                Instance.new("UICorner", OptionButton).CornerRadius = UDim.new(0, 4)
                
                OptionButton.MouseButton1Click:Connect(function()
                    Selected = Option
                    UpdateDropdown()
                    ToggleDropdown()
                end)
            end
            
            UpdateDropdown()
            
            local DropdownObject = {}
            
            function DropdownObject:SetSelection(NewSelection)
                if table.find(Options, NewSelection) then
                    Selected = NewSelection
                    UpdateDropdown()
                end
            end
            
            function DropdownObject:GetSelection()
                return Selected
            end
            
            table.insert(Elements, DropdownObject)
            return DropdownObject
        end
        
        -- Black-Themed Entry System
        function TabItems:CreateBrainrotEntry(ParentFrame, AnimalData, Index, TeleportCallback)
            local Entry = Instance.new("Frame")
            Entry.Size = UDim2.new(1, -10 * ScaleFactor, 0, 70 * ScaleFactor)
            Entry.BackgroundColor3 = Theme.EntryBackground
            Entry.BackgroundTransparency = 0.1
            Entry.BorderSizePixel = 0
            Entry.LayoutOrder = Index
            Entry.Parent = ParentFrame
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6 * ScaleFactor)
            Corner.Parent = Entry
            
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Theme.EntryStroke
            Stroke.Thickness = 2 * ScaleFactor
            Stroke.Parent = Entry
            
            -- Name Label
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(0.7, -5 * ScaleFactor, 0, 20 * ScaleFactor)
            NameLabel.Position = UDim2.new(0, 5 * ScaleFactor, 0, 5 * ScaleFactor)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = AnimalData.Name or AnimalData.name or "Unknown"
            NameLabel.TextColor3 = Theme.EntryText
            NameLabel.TextSize = 13 * ScaleFactor
            NameLabel.Font = Enum.Font.GothamBold
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.TextWrapped = true
            NameLabel.Parent = Entry
            
            -- Generation Label
            local GenLabel = Instance.new("TextLabel")
            GenLabel.Size = UDim2.new(0.7, -5 * ScaleFactor, 0, 18 * ScaleFactor)
            GenLabel.Position = UDim2.new(0, 5 * ScaleFactor, 0, 25 * ScaleFactor)
            GenLabel.BackgroundTransparency = 1
            GenLabel.Text = AnimalData.GenText or AnimalData.genText or "Generation: N/A"
            GenLabel.TextColor3 = Theme.EntryTextSecondary
            GenLabel.TextSize = 12 * ScaleFactor
            GenLabel.Font = Enum.Font.GothamSemibold
            GenLabel.TextXAlignment = Enum.TextXAlignment.Left
            GenLabel.Parent = Entry
            
            -- Mutation Label
            local MutationLabel = Instance.new("TextLabel")
            MutationLabel.Size = UDim2.new(0.7, -5 * ScaleFactor, 0, 16 * ScaleFactor)
            MutationLabel.Position = UDim2.new(0, 5 * ScaleFactor, 0, 45 * ScaleFactor)
            MutationLabel.BackgroundTransparency = 1
            MutationLabel.Text = AnimalData.Mutation ~= "None" and ("Mut: " .. AnimalData.Mutation) or "No Mutation"
            
            if AnimalData.Mutation ~= "None" then
                MutationLabel.TextColor3 = Theme.EntryMutationGreen
            else
                MutationLabel.TextColor3 = Theme.EntryTextMuted
            end
            
            MutationLabel.TextSize = 11 * ScaleFactor
            MutationLabel.Font = Enum.Font.Gotham
            MutationLabel.TextXAlignment = Enum.TextXAlignment.Left
            MutationLabel.TextWrapped = true
            MutationLabel.Parent = Entry
            
            -- Teleport Button
            local TpButton = Instance.new("TextButton")
            TpButton.Size = UDim2.new(0.25, 0, 0, 40 * ScaleFactor)
            TpButton.Position = UDim2.new(0.75, -5 * ScaleFactor, 0.5, -20 * ScaleFactor)
            TpButton.BackgroundColor3 = Theme.EntryButton
            TpButton.TextColor3 = Theme.EntryText
            TpButton.Text = "TP"
            TpButton.Font = Enum.Font.GothamBold
            TpButton.TextSize = 14 * ScaleFactor
            TpButton.Parent = Entry
            
            local TpCorner = Instance.new("UICorner")
            TpCorner.CornerRadius = UDim.new(0, 6 * ScaleFactor)
            TpCorner.Parent = TpButton
            
            local TpStroke = Instance.new("UIStroke")
            TpStroke.Color = Theme.EntryButtonStroke
            TpStroke.Thickness = 2 * ScaleFactor
            TpStroke.Transparency = 0.3
            TpStroke.Parent = TpButton
            
            -- Teleport Button Interactions
            TpButton.MouseButton1Click:Connect(function()
                if TeleportCallback then
                    TeleportCallback(AnimalData)
                end
            end)
            
            TpButton.MouseEnter:Connect(function()
                TweenService:Create(TpButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.EntryButtonHover,
                    Size = UDim2.new(0.25, 2 * ScaleFactor, 0, 42 * ScaleFactor)
                }):Play()
            end)
            
            TpButton.MouseLeave:Connect(function()
                TweenService:Create(TpButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.EntryButton,
                    Size = UDim2.new(0.25, 0, 0, 40 * ScaleFactor)
                }):Play()
            end)
            
            return Entry
        end
        
        -- Scrollable Container for Entries
        function TabItems:CreateEntryContainer()
            local Container = Instance.new("ScrollingFrame")
            Container.Size = UDim2.new(1, -8 * ScaleFactor, 1, -6 * ScaleFactor)
            Container.Position = UDim2.new(0, 4 * ScaleFactor, 0, 3 * ScaleFactor)
            Container.BackgroundTransparency = 1
            Container.ScrollBarThickness = 2 * ScaleFactor
            Container.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
            Container.CanvasSize = UDim2.new(0, 0, 0, 0)
            Container.Parent = Page
            
            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.Padding = UDim.new(0, 5 * ScaleFactor)
            ContainerLayout.Parent = Container
            
            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
            end)
            
            return Container
        end
        
        return TabItems
    end
    
    function Window:CreateNotification(Title, Message, Type, Duration)
        Type = Type or "Info"
        Duration = Duration or 3
        
        local NotificationGui = Instance.new("ScreenGui")
        NotificationGui.Name = "Notification_" .. HttpService:GenerateGUID(false)
        NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        NotificationGui.Parent = CoreGui
        
        -- Check stats panels for positioning
        local statsPanel = nil
        local statsPanelPosition = nil
        local statsPanelSize = nil
        
        for _, panel in pairs(Library.StatsPanels) do
            if panel.Frame and panel.Frame.Parent and panel.Frame.Visible then
                local frameAbsPos = panel.Frame.AbsolutePosition
                if frameAbsPos.X > ScreenSize.X / 2 then
                    statsPanel = panel
                    statsPanelPosition = panel.Frame.AbsolutePosition
                    statsPanelSize = panel.Frame.AbsoluteSize
                    break
                end
            end
        end
        
        -- Calculate position
        local startY = 15 * ScaleFactor
        local notificationHeight = 45 * ScaleFactor
        local notificationWidth = 200 * ScaleFactor
        
        if statsPanel then
            local panelTop = statsPanelPosition.Y
            local panelBottom = statsPanelPosition.Y + statsPanelSize.Y
            
            local spaceAbove = panelTop - 10
            local spaceBelow = ScreenSize.Y - panelBottom - 10
            
            if spaceAbove >= notificationHeight + 20 then
                startY = 15 * ScaleFactor
            elseif spaceBelow >= notificationHeight + 20 then
                startY = panelBottom + 10
            else
                startY = 15 * ScaleFactor
            end
        end
        
        -- Create notification
        local Notification = Instance.new("Frame")
        Notification.Size = UDim2.new(0, notificationWidth, 0, notificationHeight)
        Notification.BackgroundColor3 = Theme.Notification
        Notification.Position = UDim2.new(1, -215 * ScaleFactor, 0, startY)
        Notification.Parent = NotificationGui
        
        Instance.new("UICorner", Notification).CornerRadius = UDim.new(0, 5)
        
        local NotificationStroke = Instance.new("UIStroke")
        NotificationStroke.Color = Type == "Success" and Theme.NotificationSuccess or 
                                  Type == "Error" and Theme.NotificationError or
                                  Type == "Warning" and Theme.NotificationWarning or
                                  Theme.Stroke
        NotificationStroke.Thickness = 1 * ScaleFactor
        NotificationStroke.Parent = Notification
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -10 * ScaleFactor, 0, 16 * ScaleFactor)
        TitleLabel.Position = UDim2.new(0, 6 * ScaleFactor, 0, 4 * ScaleFactor)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = Title
        TitleLabel.TextColor3 = Theme.Text
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 10 * ScaleFactor
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = Notification
        
        local MessageLabel = Instance.new("TextLabel")
        MessageLabel.Size = UDim2.new(1, -10 * ScaleFactor, 1, -20 * ScaleFactor)
        MessageLabel.Position = UDim2.new(0, 6 * ScaleFactor, 0, 20 * ScaleFactor)
        MessageLabel.BackgroundTransparency = 1
        MessageLabel.Text = Message
        MessageLabel.TextColor3 = Theme.TextMuted
        MessageLabel.Font = Enum.Font.Gotham
        MessageLabel.TextSize = 8 * ScaleFactor
        MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
        MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
        MessageLabel.TextWrapped = true
        MessageLabel.Parent = Notification
        
        Notification.Visible = false
        
        table.insert(Library.Notifications, NotificationGui)
        
        task.spawn(function()
            local notificationCount = #Library.Notifications
            local offsetY = startY + ((notificationCount - 1) * (50 * ScaleFactor))
            
            if offsetY + notificationHeight > ScreenSize.Y - 20 then
                offsetY = math.max(15 * ScaleFactor, ScreenSize.Y - notificationHeight - 20)
            end
            
            task.wait(0.1)
            Notification.Visible = true
            Notification.Position = UDim2.new(1, -10 * ScaleFactor, 0, offsetY)
            TweenService:Create(Notification, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -215 * ScaleFactor, 0, offsetY)
            }):Play()
            
            task.wait(Duration)
            
            TweenService:Create(Notification, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -10 * ScaleFactor, 0, offsetY)
            }):Play()
            
            task.wait(0.25)
            NotificationGui:Destroy()
            
            for i, Notif in pairs(Library.Notifications) do
                if Notif == NotificationGui then
                    table.remove(Library.Notifications, i)
                    break
                end
            end
        end)
    end
    
    function Window:CreateStatsPanel(Options)
        local PanelSettings = Options or {}
        local Position = PanelSettings.Position or "TopRight"
        local Size = PanelSettings.Size or UDim2.new(0, 170 * ScaleFactor, 0, 120 * ScaleFactor)
        local StatsList = PanelSettings.Stats or {}
        local RefreshRate = PanelSettings.RefreshRate or 1
        local Title = PanelSettings.Title or "Stats Panel"
        
        local Positions = {
            TopLeft = UDim2.new(0, 10, 0, 10),
            TopRight = UDim2.new(1, -Size.X.Offset - 10, 0, 10),
            MiddleLeft = UDim2.new(0, 10, 0.5, -Size.Y.Offset/2),
            MiddleRight = UDim2.new(1, -Size.X.Offset - 10, 0.5, -Size.Y.Offset/2),
            BottomLeft = UDim2.new(0, 10, 1, -Size.Y.Offset - 10),
            BottomRight = UDim2.new(1, -Size.X.Offset - 10, 1, -Size.Y.Offset - 10),
            Center = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
        }
        
        local StatsGui = Instance.new("ScreenGui")
        StatsGui.Name = "StatsPanel_" .. HttpService:GenerateGUID(false)
        StatsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        StatsGui.Parent = CoreGui
        
        local StatsFrame = Instance.new("Frame")
        StatsFrame.Size = Size
        StatsFrame.Position = Positions[Position] or Positions["TopRight"]
        StatsFrame.BackgroundColor3 = Theme.StatsPanel
        StatsFrame.BorderSizePixel = 0
        StatsFrame.ClipsDescendants = false
        StatsFrame.Parent = StatsGui
        
        local StatsCorner = Instance.new("UICorner")
        StatsCorner.CornerRadius = UDim.new(0, 8)
        StatsCorner.Parent = StatsFrame
        
        local StatsStroke = Instance.new("UIStroke")
        StatsStroke.Color = Theme.Stroke
        StatsStroke.Transparency = 0.8
        StatsStroke.Thickness = 1 * ScaleFactor
        StatsStroke.Parent = StatsFrame
        
        local StatsHeader = Instance.new("Frame")
        StatsHeader.Size = UDim2.new(1, 0, 0, 24 * ScaleFactor)
        StatsHeader.BackgroundColor3 = Theme.Tab
        StatsHeader.Parent = StatsFrame
        
        local HeaderCorner = Instance.new("UICorner")
        HeaderCorner.CornerRadius = UDim.new(0, 8, 0, 0)
        HeaderCorner.Parent = StatsHeader
        
        local StatsTitle = Instance.new("TextLabel")
        StatsTitle.Size = UDim2.new(1, -50 * ScaleFactor, 1, 0)
        StatsTitle.Position = UDim2.new(0, 8 * ScaleFactor, 0, 0)
        StatsTitle.BackgroundTransparency = 1
        StatsTitle.Text = Title
        StatsTitle.TextColor3 = Theme.Text
        StatsTitle.Font = Enum.Font.GothamBold
        StatsTitle.TextSize = 10 * ScaleFactor
        StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
        StatsTitle.Parent = StatsHeader
        
        -- Buttons
        local MinButton = Instance.new("TextButton")
        MinButton.Size = UDim2.new(0, 16 * ScaleFactor, 0, 16 * ScaleFactor)
        MinButton.Position = UDim2.new(1, -38 * ScaleFactor, 0.5, -8 * ScaleFactor)
        MinButton.BackgroundColor3 = Theme.Background
        MinButton.Text = "−"
        MinButton.TextColor3 = Theme.Text
        MinButton.Font = Enum.Font.GothamBold
        MinButton.TextSize = 11 * ScaleFactor
        MinButton.Parent = StatsHeader
        
        local MinButtonCorner = Instance.new("UICorner")
        MinButtonCorner.CornerRadius = UDim.new(1, 0)
        MinButtonCorner.Parent = MinButton
        
        local CloseButton = Instance.new("TextButton")
        CloseButton.Size = UDim2.new(0, 16 * ScaleFactor, 0, 16 * ScaleFactor)
        CloseButton.Position = UDim2.new(1, -18 * ScaleFactor, 0.5, -8 * ScaleFactor)
        CloseButton.BackgroundColor3 = Theme.Background
        CloseButton.Text = "×"
        CloseButton.TextColor3 = Color3.fromRGB(200, 50, 50)
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.TextSize = 9 * ScaleFactor
        CloseButton.Parent = StatsHeader
        
        local CloseButtonCorner = Instance.new("UICorner")
        CloseButtonCorner.CornerRadius = UDim.new(1, 0)
        CloseButtonCorner.Parent = CloseButton
        
        -- Button hover effects
        MinButton.MouseEnter:Connect(function()
            TweenService:Create(MinButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Button
            }):Play()
        end)
        
        MinButton.MouseLeave:Connect(function()
            TweenService:Create(MinButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Background
            }):Play()
        end)
        
        CloseButton.MouseEnter:Connect(function()
            TweenService:Create(CloseButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            }):Play()
        end)
        
        CloseButton.MouseLeave:Connect(function()
            TweenService:Create(CloseButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Background
            }):Play()
        end)
        
        local StatsContent = Instance.new("Frame")
        StatsContent.Name = "StatsContent"
        StatsContent.Size = UDim2.new(1, -8 * ScaleFactor, 1, -28 * ScaleFactor)
        StatsContent.Position = UDim2.new(0, 4 * ScaleFactor, 0, 28 * ScaleFactor)
        StatsContent.BackgroundTransparency = 1
        StatsContent.ClipsDescendants = false
        StatsContent.Parent = StatsFrame
        
        local StatsListLayout = Instance.new("UIListLayout")
        StatsListLayout.Name = "StatsListLayout"
        StatsListLayout.Padding = UDim.new(0, 4 * ScaleFactor)
        StatsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        StatsListLayout.Parent = StatsContent
        
        local StatLabels = {}
        local StatFunctions = {}
        local PanelMinimized = false
        local PanelOriginalSize = StatsFrame.Size
        
        local function RefreshStats()
            for StatName, Label in pairs(StatLabels) do
                if StatFunctions[StatName] then
                    local Success, Result = pcall(StatFunctions[StatName])
                    if Success then
                        Label.Text = StatName .. ": " .. Result
                        TweenService:Create(Label, TweenInfo.new(0.15), {
                            TextColor3 = Color3.fromRGB(180, 180, 180)
                        }):Play()
                        task.wait(0.15)
                        TweenService:Create(Label, TweenInfo.new(0.15), {
                            TextColor3 = Theme.Text
                        }):Play()
                    else
                        Label.Text = StatName .. ": Error"
                    end
                end
            end
        end
        
        local function UpdateStatsContentSize()
            local ContentHeight = StatsListLayout.AbsoluteContentSize.Y
            if ContentHeight > 0 then
                TweenService:Create(StatsContent, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, -8 * ScaleFactor, 0, ContentHeight)
                }):Play()
            end
        end
        
        StatsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateStatsContentSize)
        
        local LastTime = tick()
        local FrameCount = 0
        local FPS = 0
        
        local DefaultStats = {
            FPS = function()
                return FPS
            end,
            Ping = function()
                if game:GetService("Stats") then
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end
                return 0
            end,
            Memory = function()
                if game:GetService("Stats") then
                    return math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
                end
                return 0
            end,
            Players = function()
                return #Players:GetPlayers()
            end,
            ServerTime = function()
                return math.floor(game:GetService("Workspace").DistributedGameTime/60) .. "m"
            end
        }
        
        if #StatsList == 0 then
            StatsList = {"FPS", "Ping", "Memory"}
        end
        
        -- Create stats with animation
        local function CreateStatLabel(StatName)
            local StatLabel = Instance.new("TextLabel")
            StatLabel.Size = UDim2.new(1, 0, 0, 18 * ScaleFactor)
            StatLabel.BackgroundTransparency = 1
            StatLabel.Text = StatName .. ": "
            StatLabel.TextColor3 = Theme.Text
            StatLabel.Font = Enum.Font.Gotham
            StatLabel.TextSize = 9 * ScaleFactor
            StatLabel.TextXAlignment = Enum.TextXAlignment.Left
            StatLabel.Parent = StatsContent
            
            StatLabel.TextTransparency = 1
            StatLabel.Position = UDim2.new(0, -20 * ScaleFactor, 0, StatLabel.Position.Y.Offset)
            
            TweenService:Create(StatLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = 0,
                Position = UDim2.new(0, 0, 0, StatLabel.Position.Y.Offset)
            }):Play()
            
            return StatLabel
        end
        
        for _, StatName in pairs(StatsList) do
            local StatLabel = CreateStatLabel(StatName)
            StatLabels[StatName] = StatLabel
            StatFunctions[StatName] = DefaultStats[StatName]
        end
        
        RunService.RenderStepped:Connect(function()
            FrameCount = FrameCount + 1
            local CurrentTime = tick()
            if CurrentTime - LastTime >= 1 then
                FPS = math.floor(FrameCount / (CurrentTime - LastTime))
                FrameCount = 0
                LastTime = CurrentTime
            end
        end)
        
        local statsRefreshThread = task.spawn(function()
            while StatsGui and StatsGui.Parent do
                RefreshStats()
                task.wait(RefreshRate)
            end
        end)
        
        MinButton.MouseButton1Click:Connect(function()
            PanelMinimized = not PanelMinimized
            
            if PanelMinimized then
                MinButton.Text = "+"
                TweenService:Create(StatsContent, TweenInfo.new(0.3), {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 4 * ScaleFactor, 0, 0)
                }):Play()
                task.wait(0.15)
                StatsContent.Visible = false
                
                TweenService:Create(StatsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(PanelOriginalSize.X.Scale, PanelOriginalSize.X.Offset, 0, 24 * ScaleFactor)
                }):Play()
            else
                MinButton.Text = "−"
                StatsContent.Visible = true
                
                UpdateStatsContentSize()
                local ContentHeight = StatsListLayout.AbsoluteContentSize.Y
                local NewHeight = math.max(120 * ScaleFactor, ContentHeight + 32 * ScaleFactor)
                
                TweenService:Create(StatsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(PanelOriginalSize.X.Scale, PanelOriginalSize.X.Offset, 0, NewHeight)
                }):Play()
                
                StatsContent.BackgroundTransparency = 1
                StatsContent.Position = UDim2.new(0, 4 * ScaleFactor, 0, 0)
                TweenService:Create(StatsContent, TweenInfo.new(0.3), {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 4 * ScaleFactor, 0, 28 * ScaleFactor)
                }):Play()
                
                PanelOriginalSize = StatsFrame.Size
            end
        end)
        
        CloseButton.MouseButton1Click:Connect(function()
            task.cancel(statsRefreshThread)
            
            TweenService:Create(StatsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, StatsFrame.Position.X.Offset, 0.5, StatsFrame.Position.Y.Offset),
                BackgroundTransparency = 1
            }):Play()
            
            task.wait(0.2)
            StatsGui:Destroy()
            
            for i, Panel in pairs(Library.StatsPanels) do
                if Panel.Frame == StatsFrame then
                    table.remove(Library.StatsPanels, i)
                    break
                end
            end
        end)
        
        local StatsPanelObject = {
            Frame = StatsFrame,
            Position = Position
        }
        
        function StatsPanelObject:AddStat(Name, Function)
            local StatLabel = CreateStatLabel(Name)
            StatLabels[Name] = StatLabel
            StatFunctions[Name] = Function
            
            UpdateStatsContentSize()
            if not PanelMinimized then
                local ContentHeight = StatsListLayout.AbsoluteContentSize.Y
                local NewHeight = math.max(120 * ScaleFactor, ContentHeight + 32 * ScaleFactor)
                
                TweenService:Create(StatsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(PanelOriginalSize.X.Scale, PanelOriginalSize.X.Offset, 0, NewHeight)
                }):Play()
                
                PanelOriginalSize = StatsFrame.Size
            end
        end
        
        function StatsPanelObject:RemoveStat(Name)
            if StatLabels[Name] then
                local label = StatLabels[Name]
                TweenService:Create(label, TweenInfo.new(0.2), {
                    TextTransparency = 1,
                    Position = UDim2.new(0, -20 * ScaleFactor, 0, label.Position.Y.Offset)
                }):Play()
                
                task.wait(0.2)
                label:Destroy()
                StatLabels[Name] = nil
                StatFunctions[Name] = nil
                
                UpdateStatsContentSize()
                if not PanelMinimized then
                    local ContentHeight = StatsListLayout.AbsoluteContentSize.Y
                    local NewHeight = math.max(120 * ScaleFactor, ContentHeight + 32 * ScaleFactor)
                    
                    TweenService:Create(StatsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(PanelOriginalSize.X.Scale, PanelOriginalSize.X.Offset, 0, NewHeight)
                    }):Play()
                    
                    PanelOriginalSize = StatsFrame.Size
                end
            end
        end
        
        function StatsPanelObject:SetPosition(NewPosition)
            Position = NewPosition
            StatsPanelObject.Position = NewPosition
            
            TweenService:Create(StatsFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = Positions[NewPosition] or Positions["TopRight"]
            }):Play()
        end
        
        function StatsPanelObject:SetTitle(NewTitle)
            StatsTitle.Text = NewTitle
            TweenService:Create(StatsTitle, TweenInfo.new(0.2), {
                TextTransparency = 0.5
            }):Play()
            task.wait(0.1)
            TweenService:Create(StatsTitle, TweenInfo.new(0.2), {
                TextTransparency = 0
            }):Play()
        end
        
        function StatsPanelObject:Refresh()
            RefreshStats()
        end
        
        function StatsPanelObject:ToggleMinimize()
            MinButton.MouseButton1Click:Wait()
        end
        
        function StatsPanelObject:Destroy()
            task.cancel(statsRefreshThread)
            StatsGui:Destroy()
        end
        
        task.spawn(function()
            task.wait(0.2)
            UpdateStatsContentSize()
            local ContentHeight = StatsListLayout.AbsoluteContentSize.Y
            local NewHeight = math.max(120 * ScaleFactor, ContentHeight + 32 * ScaleFactor)
            
            StatsFrame.Size = UDim2.new(Size.X.Scale, Size.X.Offset, 0, 24 * ScaleFactor)
            TweenService:Create(StatsFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(Size.X.Scale, Size.X.Offset, 0, NewHeight)
            }):Play()
            
            PanelOriginalSize = StatsFrame.Size
        end)
        
        table.insert(Library.StatsPanels, StatsPanelObject)
        return StatsPanelObject
    end
    
    function Window:ToggleVisibility()
        Main.Visible = not Main.Visible
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    UpdateSize()
    table.insert(Library.Windows, Window)
    return Window
end

function Library:CreateNotification(Title, Message, Type, Duration)
    if not Library._dummyWindow then
        Library._dummyWindow = Library:CreateWindow("NotificationHandler", {
            Theme = "Dark",
            Scale = DeviceScale,
            ForcePosition = "TopLeft"
        })
        Library._dummyWindow.Main.Visible = false
    end
    
    Library._dummyWindow:CreateNotification(Title, Message, Type, Duration)
end

function Library:GetAllWindows()
    return Library.Windows
end

return Library
