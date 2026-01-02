local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.Windows = {}

function Library:CreateWindow(Title)
    local Window = {}
    local IsMinimized = false
    local CurrentPage = nil
    local Elements = {}
    local Mode = "TALL"
    local OriginalHeight = 350
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerUI_" .. HttpService:GenerateGUID(false)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 9)
    UICorner.Parent = Main
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.8
    Stroke.Thickness = 1.5
    Stroke.Parent = Main
    
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Parent = Main
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -70, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 22, 0, 22)
    CloseButton.Position = UDim2.new(1, -28, 0, 9)
    CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 11
    CloseButton.Parent = Header
    
    local CloseButtonUICorner = Instance.new("UICorner")
    CloseButtonUICorner.CornerRadius = UDim.new(0, 5)
    CloseButtonUICorner.Parent = CloseButton
    
    local MinButton = Instance.new("TextButton")
    MinButton.Size = UDim2.new(0, 22, 0, 22)
    MinButton.Position = UDim2.new(1, -55, 0, 9)
    MinButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinButton.Text = "-"
    MinButton.TextColor3 = Color3.new(1, 1, 1)
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextSize = 14
    MinButton.Parent = Header
    
    local MinButtonUICorner = Instance.new("UICorner")
    MinButtonUICorner.CornerRadius = UDim.new(0, 5)
    MinButtonUICorner.Parent = MinButton
    
    local Container = Instance.new("Frame")
    Container.BackgroundTransparency = 1
    Container.Parent = Main
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 0
    TabList.Parent = Container
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabList
    
    local Content = Instance.new("Frame")
    Content.BackgroundTransparency = 1
    Content.Parent = Container
    
    local function UpdateSize()
        if Mode == "TALL" then
            local contentHeight = CurrentPage and (CurrentPage.CanvasSize.Y.Offset + 20) or 200
            local newHeight = 75 + contentHeight
            OriginalHeight = newHeight
            
            Main.Size = UDim2.new(0, 230, 0, newHeight)
            Container.Size = UDim2.new(1, 0, 1, -40)
            Container.Position = UDim2.new(0, 0, 0, 40)
            
            TabList.Size = UDim2.new(1, -20, 0, 28)
            TabList.Position = UDim2.new(0, 10, 0, 0)
            TabListLayout.FillDirection = Enum.FillDirection.Horizontal
            
            Content.Size = UDim2.new(1, 0, 1, -33)
            Content.Position = UDim2.new(0, 0, 0, 33)
        else
            Main.Size = UDim2.new(0, 400, 0, 350)
            OriginalHeight = 350
            Container.Size = UDim2.new(1, 0, 1, -40)
            Container.Position = UDim2.new(0, 0, 0, 40)
            
            TabList.Size = UDim2.new(0, 100, 1, 0)
            TabList.Position = UDim2.new(0, 10, 0, 0)
            TabListLayout.FillDirection = Enum.FillDirection.Vertical
            
            Content.Size = UDim2.new(1, -120, 1, 0)
            Content.Position = UDim2.new(0, 110, 0, 0)
        end
        
        if TabList then
            local totalHeight = 0
            for _, child in pairs(TabList:GetChildren()) do
                if child:IsA("TextButton") then
                    totalHeight = totalHeight + child.AbsoluteSize.Y + 5
                end
            end
            TabList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end
    end
    
    Main.Position = UDim2.new(0.5, -115, 0.5, -175)
    
    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(Main, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        TweenService:Create(Main, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        task.wait(0.2)
        ScreenGui:Destroy()
    end)
    
    MinButton.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        
        if IsMinimized then
            Container.Visible = false
            TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, Main.Size.X.Offset, 0, 40)}):Play()
        else
            Container.Visible = true
            UpdateSize()
            TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, Main.Size.X.Offset, 0, OriginalHeight)}):Play()
        end
    end)
    
    local Keybind = Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(Input, Processed)
        if not Processed and Input.KeyCode == Keybind then
            Main.Visible = not Main.Visible
        end
    end)
    
    function Window:SetKeybind(NewKeybind)
        Keybind = NewKeybind
    end
    
    function Window:SetMode(NewMode)
        local oldMode = Mode
        Mode = NewMode:upper()
        
        if oldMode ~= Mode then
            UpdateSize()
            Main.Position = UDim2.new(0.5, -Main.Size.X.Offset/2, 0.5, -Main.Size.Y.Offset/2)
        end
    end
    
    function Window:CreateTab(Name)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = Mode == "TALL" and UDim2.new(0, 70, 0, 28) or UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        TabButton.Text = Name
        TabButton.TextColor3 = Color3.fromRGB(130, 130, 130)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 9
        TabButton.Parent = TabList
        
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 5)
        
        local Page = Instance.new("ScrollingFrame")
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Parent = Content
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 8)
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
                    TweenService:Create(Child, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(130, 130, 130), BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
                end
            end
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1), BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
            CurrentPage = Page
            UpdateSize()
        end)
        
        if CurrentPage == nil then
            CurrentPage = Page
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1), BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
            UpdateSize()
        end
        
        Page.Size = UDim2.new(1, -20, 1, -10)
        Page.Position = UDim2.new(0, 10, 0, 5)
        
        local TabItems = {}
        
        function TabItems:CreateToggle(Text, Callback)
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, Mode == "TALL" and 200 or 250, 0, 32)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            ToggleButton.Text = Text .. ": OFF"
            ToggleButton.TextColor3 = Color3.fromRGB(255, 65, 65)
            ToggleButton.Font = Enum.Font.GothamBold
            ToggleButton.TextSize = 10
            ToggleButton.Parent = Page
            
            Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)
            
            local State = false
            
            ToggleButton.MouseButton1Click:Connect(function()
                State = not State
                ToggleButton.Text = Text .. ": " .. (State and "ON" or "OFF")
                local TargetColor = State and Color3.fromRGB(65, 255, 65) or Color3.fromRGB(255, 65, 65)
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = TargetColor}):Play()
                Callback(State)
            end)
            
            local ToggleObject = {
                SetState = function(self, NewState)
                    State = NewState
                    ToggleButton.Text = Text .. ": " .. (State and "ON" or "OFF")
                    local TargetColor = State and Color3.fromRGB(65, 255, 65) or Color3.fromRGB(255, 65, 65)
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = TargetColor}):Play()
                    Callback(State)
                end,
                GetState = function(self)
                    return State
                end
            }
            
            table.insert(Elements, ToggleObject)
            return ToggleObject
        end
        
        function TabItems:CreateButton(Text, Callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, Mode == "TALL" and 200 or 250, 0, 32)
            Button.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
            Button.Text = Text
            Button.TextColor3 = Color3.new(1, 1, 1)
            Button.Font = Enum.Font.GothamBold
            Button.TextSize = 10
            Button.Parent = Page
            
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
            
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
            end)
            
            Button.MouseButton1Click:Connect(function()
                local OriginalColor = Button.BackgroundColor3
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                task.wait(0.1)
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = OriginalColor}):Play()
                Callback()
            end)
        end
        
        function TabItems:CreateTextBox(Text, Placeholder, Callback)
            local TextBoxFrame = Instance.new("Frame")
            TextBoxFrame.Size = UDim2.new(0, Mode == "TALL" and 200 or 250, 0, 40)
            TextBoxFrame.BackgroundTransparency = 1
            TextBoxFrame.Parent = Page
            
            local TextBoxTitle = Instance.new("TextLabel")
            TextBoxTitle.Size = UDim2.new(1, 0, 0, 15)
            TextBoxTitle.BackgroundTransparency = 1
            TextBoxTitle.Text = Text
            TextBoxTitle.TextColor3 = Color3.new(1, 1, 1)
            TextBoxTitle.Font = Enum.Font.GothamBold
            TextBoxTitle.TextSize = 9
            TextBoxTitle.TextXAlignment = Enum.TextXAlignment.Left
            TextBoxTitle.Parent = TextBoxFrame
            
            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, 0, 0, 20)
            TextBox.Position = UDim2.new(0, 0, 0, 20)
            TextBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            TextBox.TextColor3 = Color3.new(1, 1, 1)
            TextBox.PlaceholderText = Placeholder
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 10
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = TextBoxFrame
            
            Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)
            
            TextBox.FocusLost:Connect(function(EnterPressed)
                if EnterPressed then
                    Callback(TextBox.Text)
                end
            end)
            
            local TextBoxObject = {
                SetText = function(self, NewText)
                    TextBox.Text = NewText
                end,
                GetText = function(self)
                    return TextBox.Text
                end
            }
            
            table.insert(Elements, TextBoxObject)
            return TextBoxObject
        end
        
        function TabItems:CreateLabel(Text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, Mode == "TALL" and 200 or 250, 0, 20)
            Label.BackgroundTransparency = 1
            Label.Text = Text
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 10
            Label.Parent = Page
        end
        
        function TabItems:CreateDropdown(Text, Options, Callback)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(0, Mode == "TALL" and 200 or 250, 0, 32)
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            DropdownFrame.Parent = Page
            
            Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)
            
            local DropdownTitle = Instance.new("TextLabel")
            DropdownTitle.Size = UDim2.new(1, -30, 1, 0)
            DropdownTitle.Position = UDim2.new(0, 8, 0, 0)
            DropdownTitle.BackgroundTransparency = 1
            DropdownTitle.Text = Text .. ": " .. (Options[1] or "NONE")
            DropdownTitle.TextColor3 = Color3.new(1, 1, 1)
            DropdownTitle.Font = Enum.Font.GothamBold
            DropdownTitle.TextSize = 10
            DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
            DropdownTitle.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(0, 20, 0, 20)
            DropdownButton.Position = UDim2.new(1, -25, 0.5, -10)
            DropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            DropdownButton.Text = "▼"
            DropdownButton.TextColor3 = Color3.new(1, 1, 1)
            DropdownButton.Font = Enum.Font.GothamBold
            DropdownButton.TextSize = 10
            DropdownButton.Parent = DropdownFrame
            
            Instance.new("UICorner", DropdownButton).CornerRadius = UDim.new(0, 4)
            
            local DropdownList = Instance.new("ScrollingFrame")
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            DropdownList.Position = UDim2.new(0, 0, 1, 2)
            DropdownList.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            DropdownList.ScrollBarThickness = 0
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
            DropdownList.Visible = false
            DropdownList.Parent = DropdownFrame
            
            Instance.new("UICorner", DropdownList).CornerRadius = UDim.new(0, 6)
            
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
                        OptionButton.BackgroundColor3 = OptionButton.Text == Selected and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(22, 22, 22)
                    end
                end
                Callback(Selected)
            end
            
            local function ToggleDropdown()
                IsOpen = not IsOpen
                DropdownList.Visible = IsOpen
                local TargetSize = IsOpen and math.min(#Options * 22, 110) or 0
                TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, TargetSize)}):Play()
            end
            
            DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
            
            for _, Option in pairs(Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 22)
                OptionButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                OptionButton.Text = Option
                OptionButton.TextColor3 = Color3.new(1, 1, 1)
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.TextSize = 10
                OptionButton.Parent = DropdownList
                
                Instance.new("UICorner", OptionButton).CornerRadius = UDim.new(0, 4)
                
                OptionButton.MouseButton1Click:Connect(function()
                    Selected = Option
                    UpdateDropdown()
                    ToggleDropdown()
                end)
            end
            
            UpdateDropdown()
            
            local DropdownObject = {
                SetSelection = function(self, NewSelection)
                    if table.find(Options, NewSelection) then
                        Selected = NewSelection
                        UpdateDropdown()
                    end
                end,
                GetSelection = function(self)
                    return Selected
                end
            }
            
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
    end
    
    UpdateSize()
    table.insert(Library.Windows, Window)
    return Window
end

function Library:GetAllWindows()
    return Library.Windows
end

return Library
