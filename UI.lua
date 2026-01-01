local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {}

function Library:CreateWindow(title)
    local Window = {}
    local CurrentPage = nil
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StrikerUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = (game:GetService("RunService"):IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 220, 0, 250)
    Main.Position = UDim2.new(0.5, -110, 0.5, -125)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.8

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundTransparency = 1

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 12
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -25, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Size = UDim2.new(1, 0, 0, 25)
    TabHolder.Position = UDim2.new(0, 0, 0, 35)
    TabHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabHolder.BorderSizePixel = 0
    
    local TabList = Instance.new("UIListLayout", TabHolder)
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, 0, 1, -60)
    Container.Position = UDim2.new(0, 0, 0, 60)
    Container.BackgroundTransparency = 1

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", TabHolder)
        TabBtn.Size = UDim2.new(0, 70, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name:upper()
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 9

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 5)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            Page.Visible = true
            TabBtn.TextColor3 = Color3.new(1, 1, 1)
        end)

        if CurrentPage == nil then
            CurrentPage = Page
            Page.Visible = true
            TabBtn.TextColor3 = Color3.new(1, 1, 1)
        end

        local TabItems = {}

        function TabItems:CreateToggle(text, callback)
            local T = Instance.new("TextButton", Page)
            T.Size = UDim2.new(0.9, 0, 0, 30)
            T.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            T.Text = text .. ": OFF"
            T.TextColor3 = Color3.fromRGB(255, 60, 60)
            T.Font = Enum.Font.GothamBold
            T.TextSize = 10
            Instance.new("UICorner", T)
            
            local s = false
            T.MouseButton1Click:Connect(function()
                s = not s
                T.Text = text .. ": " .. (s and "ON" or "OFF")
                T.TextColor3 = s and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
                callback(s)
            end)
        end

        function TabItems:CreateButton(text, callback)
            local B = Instance.new("TextButton", Page)
            B.Size = UDim2.new(0.9, 0, 0, 30)
            B.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            B.Text = text
            B.TextColor3 = Color3.new(1, 1, 1)
            B.Font = Enum.Font.GothamBold
            B.TextSize = 10
            Instance.new("UICorner", B)
            B.MouseButton1Click:Connect(callback)
        end

        return TabItems
    end

    return Window
end

return Library
