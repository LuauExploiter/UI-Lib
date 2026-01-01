--[[ 
    UI LIBRARY
    A sleek, modular UI library for Roblox.
    Author: nilo8
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Library = {}

function Library:CreateWindow(title)
    local Window = {}
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerUI_" .. title
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = (RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 230, 0, 40) -- Initial size
    MainFrame.Position = UDim2.new(0.5, -115, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Styling
    local Corner = Instance.new("UICorner", MainFrame)
    Corner.CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.85
    Stroke.Thickness = 2
    
    local Gradient = Instance.new("UIGradient", MainFrame)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
    }
    Gradient.Rotation = 45
    
    -- Title Bar
    local TitleLabel = Instance.new("TextLabel", MainFrame)
    TitleLabel.Size = UDim2.new(1, -20, 0, 40)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Content Container
    local Content = Instance.new("Frame", MainFrame)
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -40)
    Content.Position = UDim2.new(0, 0, 0, 40)
    Content.BackgroundTransparency = 1
    
    local ListLayout = Instance.new("UIListLayout", Content)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local Padding = Instance.new("UIPadding", Content)
    Padding.PaddingTop = UDim.new(0, 5)
    
    -- Dragging Logic
    local Dragging, DragInput, DragStart, StartPos
    local function UpdateDrag(input)
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then UpdateDrag(input) end
    end)

    -- Auto-Resizing
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local NewHeight = ListLayout.AbsoluteContentSize.Y + 50
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 230, 0, NewHeight)}):Play()
    end)

    -- ELEMENTS
    
    function Window:CreateButton(Text, Callback)
        local Btn = Instance.new("TextButton", Content)
        Btn.Size = UDim2.new(0.9, 0, 0, 32)
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Btn.Text = Text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamSemibold
        Btn.TextSize = 12
        Btn.AutoButtonColor = true
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        
        Btn.MouseButton1Click:Connect(Callback)
    end

    function Window:CreateToggle(Text, Callback)
        local Enabled = false
        local TglBtn = Instance.new("TextButton", Content)
        TglBtn.Size = UDim2.new(0.9, 0, 0, 32)
        TglBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TglBtn.Text = Text .. ": OFF"
        TglBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        TglBtn.Font = Enum.Font.GothamSemibold
        TglBtn.TextSize = 12
        Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(0, 6)
        
        TglBtn.MouseButton1Click:Connect(function()
            Enabled = not Enabled
            TglBtn.Text = Text .. ": " .. (Enabled and "ON" or "OFF")
            TglBtn.TextColor3 = Enabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
            Callback(Enabled)
        end)
    end
    
    function Window:CreateSlider(Text, Min, Max, Default, Callback)
        local SliderFrame = Instance.new("Frame", Content)
        SliderFrame.Size = UDim2.new(0.9, 0, 0, 45)
        SliderFrame.BackgroundTransparency = 1
        
        local Label = Instance.new("TextLabel", SliderFrame)
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Text = Text .. ": " .. Default
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 11
        
        local Bar = Instance.new("Frame", SliderFrame)
        Bar.Size = UDim2.new(1, 0, 0, 6)
        Bar.Position = UDim2.new(0, 0, 0, 25)
        Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Instance.new("UICorner", Bar)
        
        local Fill = Instance.new("Frame", Bar)
        Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
        Instance.new("UICorner", Fill)
        
        local function Update(Input)
            local P = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local Val = math.floor(Min + (Max - Min) * P)
            Fill.Size = UDim2.new(P, 0, 1, 0)
            Label.Text = Text .. ": " .. Val
            Callback(Val)
        end
        
        local DraggingSlider = false
        Bar.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                DraggingSlider = true
                Update(Input)
            end
        end)
        UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingSlider = false end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if DraggingSlider and Input.UserInputType == Enum.UserInputType.MouseMovement then Update(Input) end
        end)
    end

    function Window:CreateKeybind(Text, DefaultKey, Callback)
        local KeyBtn = Instance.new("TextButton", Content)
        KeyBtn.Size = UDim2.new(0.9, 0, 0, 32)
        KeyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        KeyBtn.Text = Text .. ": " .. DefaultKey.Name
        KeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        KeyBtn.Font = Enum.Font.GothamSemibold
        KeyBtn.TextSize = 12
        Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)
        
        local CurrentKey = DefaultKey
        local Binding = false
        
        KeyBtn.MouseButton1Click:Connect(function()
            Binding = true
            KeyBtn.Text = Text .. ": ..."
            KeyBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
        end)
        
        UserInputService.InputBegan:Connect(function(Input, Processed)
            if Binding and Input.UserInputType == Enum.UserInputType.Keyboard then
                CurrentKey = Input.KeyCode
                Binding = false
                KeyBtn.Text = Text .. ": " .. CurrentKey.Name
                KeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            elseif not Binding and not Processed and Input.KeyCode == CurrentKey then
                Callback()
            end
        end)
    end
    
    return Window
end

return Library
