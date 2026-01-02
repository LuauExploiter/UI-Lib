local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.Windows = {}

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
        TextMuted = Color3.fromRGB(130, 130, 130)
    }
}

function Library:CreateWindow(Title, Options)
    local WindowSettings = Options or {}
    local ThemeName = WindowSettings.Theme or "Dark"
    local Keybind = WindowSettings.Keybind or Enum.KeyCode.RightShift
    local UseKeySystem = WindowSettings.UseKeySystem or false
    local RequiredKey = WindowSettings.RequiredKey or ""
    local StartMode = WindowSettings.Mode or "Tall"
    local Theme = Themes[ThemeName] or Themes.Dark
    local ScaleFactor = WindowSettings.Scale or 1
    
    if UserInputService.TouchEnabled then
        ScaleFactor = 0.8
    end
    
    local Window = {}
    local IsMinimized = false
    local CurrentPage = nil
    local Elements = {}
    local Mode = StartMode
    local OriginalHeight = 350
    local DeviceScale = ScaleFactor
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerUI_" .. HttpService:GenerateGUID(false)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 9)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Stroke
    MainStroke.Transparency = 0.8
    MainStroke.Thickness = 1.5 * DeviceScale
    MainStroke.Parent = Main
    
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40 * DeviceScale)
    Header.BackgroundTransparency = 1
    Header.Parent = Main
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -70 * DeviceScale, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12 * DeviceScale, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13 * DeviceScale
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 22 * DeviceScale, 0, 22 * DeviceScale)
    CloseButton.Position = UDim2.new(1, -28 * DeviceScale, 0, 9 * DeviceScale)
    CloseButton.BackgroundColor3 = Theme.Button
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Theme.Text
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 11 * DeviceScale
    CloseButton.Parent = Header
    
    local CloseButtonCorner = Instance.new("UICorner")
    CloseButtonCorner.CornerRadius = UDim.new(0, 5)
    CloseButtonCorner.Parent = CloseButton
    
    local MinButton = Instance.new("TextButton")
    MinButton.Size = UDim2.new(0, 22 * DeviceScale, 0, 22 * DeviceScale)
    MinButton.Position = UDim2.new(1, -55 * DeviceScale, 0, 9 * DeviceScale)
    MinButton.BackgroundColor3 = Theme.Button
    MinButton.Text = "-"
    MinButton.TextColor3 = Theme.Text
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextSize = 14 * DeviceScale
    MinButton.Parent = Header
    
    local MinButtonCorner = Instance.new("UICorner")
    MinButtonCorner.CornerRadius = UDim.new(0, 5)
    MinButtonCorner.Parent = MinButton
    
    local Container = Instance.new("Frame")
    Container.BackgroundTransparency = 1
    Container.Parent = Main
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 0
    TabList.Parent = Container
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5 * DeviceScale)
    TabListLayout.Parent = TabList
    
    local Content = Instance.new("Frame")
    Content.BackgroundTransparency = 1
    Content.Parent = Container
    
    local function UpdateSize()
        if Mode == "Tall" then
            local ContentHeight = CurrentPage and (CurrentPage.CanvasSize.Y.Offset + 20) or 200
            local NewHeight = math.max(350, 75 + ContentHeight)
            OriginalHeight = NewHeight
            
            Main.Size = UDim2.new(0, 230 * DeviceScale, 0, NewHeight * DeviceScale)
            Container.Size = UDim2.new(1, 0, 1, -40 * DeviceScale)
            Container.Position = UDim2.new(0, 0, 0, 40 * DeviceScale)
            
            TabList.Size = UDim2.new(1, -20 * DeviceScale, 0, 28 * DeviceScale)
            TabList.Position = UDim2.new(0, 10 * DeviceScale, 0, 0)
            TabListLayout.FillDirection = Enum.FillDirection.Horizontal
            
            Content.Size = UDim2.new(1, 0, 1, -33 * DeviceScale)
            Content.Position = UDim2.new(0, 0, 0, 33 * DeviceScale)
        else
            Main.Size = UDim2.new(0, 400 * DeviceScale, 0, 350 * DeviceScale)
            OriginalHeight = 350 * DeviceScale
            Container.Size = UDim2.new(1, 0, 1, -40 * DeviceScale)
            Container.Position = UDim2.new(0, 0, 0, 40 * DeviceScale)
            
            TabList.Size = UDim2.new(0, 100 * DeviceScale, 1, 0)
            TabList.Position = UDim2.new(0, 10 * DeviceScale, 0, 0)
            TabListLayout.FillDirection = Enum.FillDirection.Vertical
            
            Content.Size = UDim2.new(1, -120 * DeviceScale, 1, 0)
            Content.Position = UDim2.new(0, 110 * DeviceScale, 0, 0)
        end
        
        if TabList then
            local TotalHeight = 0
            for _, Child in pairs(TabList:GetChildren()) do
                if Child:IsA("TextButton") then
                    TotalHeight = TotalHeight + Child.AbsoluteSize.Y + (5 * DeviceScale)
                end
            end
            TabList.CanvasSize = UDim2.new(0, 0, 0, TotalHeight)
        end
    end
    
    Main.Position = UDim2.new(0.5, -115 * DeviceScale, 0.5, -175 * DeviceScale)
    
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
            TweenService:Create(Container, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.1)
            Container.Visible = false
            
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, Main.Size.X.Offset, 0, 40 * DeviceScale)
            }):Play()
        else
            Container.Visible = true
            TweenService:Create(Container, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
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
    
    function Window:SetMode(NewMode)
        local OldMode = Mode
        Mode = NewMode
        
        if OldMode ~= Mode then
            UpdateSize()
            Main.Position = UDim2.new(0.5, -Main.Size.X.Offset/2, 0.5, -Main.Size.Y.Offset/2)
        end
    end
    
    function Window:CreateTab(Name)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = Mode == "Tall" and UDim2.new(0, 70 * DeviceScale, 0, 28 * DeviceScale) or UDim2.new(1, 0, 0, 30 * DeviceScale)
        TabButton.BackgroundColor3 = Theme.Tab
        TabButton.Text = Name
        TabButton.TextColor3 = Theme.TextMuted
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 9 * DeviceScale
        TabButton.Parent = TabList
        
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 5)
        
        local Page = Instance.new("ScrollingFrame")
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Parent = Content
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 8 * DeviceScale)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageList.Parent = Page
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
            CurrentPage = Page
            UpdateSize()
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, Child in pairs(Content:GetChildren()) do
                if Child:IsA("ScrollingFrame") then
                    Child.Visible = false
                end
            end
            for _, Child in pairs(TabList:GetChildren()) do
                if Child:IsA("TextButton") then
                    Child.TextColor3 = Theme.TextMuted
                    Child.BackgroundColor3 = Theme.Tab
                end
            end
            Page.Visible = true
            TabButton.TextColor3 = Theme.Text
            TabButton.BackgroundColor3 = Theme.TabSelected
            CurrentPage = Page
            UpdateSize()
        end)
        
        if CurrentPage == nil then
            CurrentPage = Page
            Page.Visible = true
            TabButton.TextColor3 = Theme.Text
            TabButton.BackgroundColor3 = Theme.TabSelected
            UpdateSize()
        end
        
        Page.Size = UDim2.new(1, -20 * DeviceScale, 1, -10 * DeviceScale)
        Page.Position = UDim2.new(0, 10 * DeviceScale, 0, 5 * DeviceScale)
        
        local TabItems = {}
        
        function TabItems:CreateToggle(Text, Callback)
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, (Mode == "Tall" and 200 or 250) * DeviceScale, 0, 32 * DeviceScale)
            ToggleButton.BackgroundColor3 = Theme.Toggle
            ToggleButton.Text = Text .. ": OFF"
            ToggleButton.TextColor3 = Theme.ToggleOff
            ToggleButton.Font = Enum.Font.GothamBold
            ToggleButton.TextSize = 10 * DeviceScale
            ToggleButton.Parent = Page
            
            Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)
            
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
            Button.Size = UDim2.new(0, (Mode == "Tall" and 200 or 250) * DeviceScale, 0, 32 * DeviceScale)
            Button.BackgroundColor3 = Theme.Button
            Button.Text = Text
            Button.TextColor3 = Theme.Text
            Button.Font = Enum.Font.GothamBold
            Button.TextSize = 10 * DeviceScale
            Button.Parent = Page
            
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
            
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
            TextBoxFrame.Size = UDim2.new(0, (Mode == "Tall" and 200 or 250) * DeviceScale, 0, 40 * DeviceScale)
            TextBoxFrame.BackgroundTransparency = 1
            TextBoxFrame.Parent = Page
            
            local TextBoxTitle = Instance.new("TextLabel")
            TextBoxTitle.Size = UDim2.new(1, 0, 0, 15 * DeviceScale)
            TextBoxTitle.BackgroundTransparency = 1
            TextBoxTitle.Text = Text
            TextBoxTitle.TextColor3 = Theme.Text
            TextBoxTitle.Font = Enum.Font.GothamBold
            TextBoxTitle.TextSize = 9 * DeviceScale
            TextBoxTitle.TextXAlignment = Enum.TextXAlignment.Left
            TextBoxTitle.Parent = TextBoxFrame
            
            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, 0, 0, 20 * DeviceScale)
            TextBox.Position = UDim2.new(0, 0, 0, 20 * DeviceScale)
            TextBox.BackgroundColor3 = Theme.TextBox
            TextBox.TextColor3 = Theme.Text
            TextBox.PlaceholderText = Placeholder
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 10 * DeviceScale
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
            Label.Size = UDim2.new(0, (Mode == "Tall" and 200 or 250) * DeviceScale, 0, 20 * DeviceScale)
            Label.BackgroundTransparency = 1
            Label.Text = Text
            Label.TextColor3 = Theme.TextMuted
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 10 * DeviceScale
            Label.Parent = Page
        end
        
        function TabItems:CreateDropdown(Text, Options, Callback)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(0, (Mode == "Tall" and 200 or 250) * DeviceScale, 0, 32 * DeviceScale)
            DropdownFrame.BackgroundColor3 = Theme.Dropdown
            DropdownFrame.Parent = Page
            
            Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)
            
            local DropdownTitle = Instance.new("TextLabel")
            DropdownTitle.Size = UDim2.new(1, -30 * DeviceScale, 1, 0)
            DropdownTitle.Position = UDim2.new(0, 8 * DeviceScale, 0, 0)
            DropdownTitle.BackgroundTransparency = 1
            DropdownTitle.Text = Text .. ": " .. (Options[1] or "NONE")
            DropdownTitle.TextColor3 = Theme.Text
            DropdownTitle.Font = Enum.Font.GothamBold
            DropdownTitle.TextSize = 10 * DeviceScale
            DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
            DropdownTitle.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(0, 20 * DeviceScale, 0, 20 * DeviceScale)
            DropdownButton.Position = UDim2.new(1, -25 * DeviceScale, 0.5, -10 * DeviceScale)
            DropdownButton.BackgroundColor3 = Theme.Button
            DropdownButton.Text = "▼"
            DropdownButton.TextColor3 = Theme.Text
            DropdownButton.Font = Enum.Font.GothamBold
            DropdownButton.TextSize = 10 * DeviceScale
            DropdownButton.Parent = DropdownFrame
            
            Instance.new("UICorner", DropdownButton).CornerRadius = UDim.new(0, 4)
            
            local DropdownList = Instance.new("Frame")
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            DropdownList.Position = UDim2.new(0, 0, 1, 5 * DeviceScale)
            DropdownList.BackgroundColor3 = Theme.Dropdown
            DropdownList.Visible = false
            DropdownList.ZIndex = 10
            DropdownList.Parent = DropdownFrame
            
            Instance.new("UICorner", DropdownList).CornerRadius = UDim.new(0, 6)
            
            local DropdownStroke = Instance.new("UIStroke")
            DropdownStroke.Color = Theme.Stroke
            DropdownStroke.Transparency = 0.5
            DropdownStroke.Thickness = 1
            DropdownStroke.Parent = DropdownList
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = DropdownList
            
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownList.Size = UDim2.new(1, 0, 0, math.min(ListLayout.AbsoluteContentSize.Y, 110 * DeviceScale))
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
                for _, Frame in pairs(ScreenGui:GetDescendants()) do
                    if Frame:IsA("Frame") and Frame.Name == "DropdownList" then
                        TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        task.wait(0.2)
                        Frame.Visible = false
                    end
                end
            end
            
            local function ToggleDropdown()
                IsOpen = not IsOpen
                
                if IsOpen then
                    CloseAllDropdowns()
                    DropdownList.Visible = true
                    TweenService:Create(DropdownList, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, math.min(#Options * 25 * DeviceScale, 110 * DeviceScale))
                    }):Play()
                else
                    TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    task.wait(0.2)
                    DropdownList.Visible = false
                end
            end
            
            DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
            
            UserInputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and IsOpen then
                    local MousePos = Input.Position
                    local DropdownPos = DropdownFrame.AbsolutePosition
                    local DropdownSize = DropdownFrame.AbsoluteSize
                    local ListPos = DropdownList.AbsolutePosition
                    local ListSize = DropdownList.AbsoluteSize
                    
                    if not (MousePos.X >= DropdownPos.X and MousePos.X <= DropdownPos.X + DropdownSize.X and
                           MousePos.Y >= DropdownPos.Y and MousePos.Y <= DropdownPos.Y + DropdownSize.Y + ListSize.Y) then
                        ToggleDropdown()
                    end
                end
            end)
            
            for _, Option in pairs(Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 25 * DeviceScale)
                OptionButton.BackgroundColor3 = Theme.Dropdown
                OptionButton.Text = Option
                OptionButton.TextColor3 = Theme.Text
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.TextSize = 10 * DeviceScale
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
        
        return TabItems
    end
    
    function Window:ToggleVisibility()
        Main.Visible = not Main.Visible
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    function Window:SetPosition(Position)
        Main.Position = Position
    end
    
    function Window:SetSize(Size)
        Main.Size = Size
        UpdateSize()
    end
    
    UpdateSize()
    table.insert(Library.Windows, Window)
    return Window
end

function Library:GetAllWindows()
    return Library.Windows
end

return Library
