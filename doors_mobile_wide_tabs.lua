-- DOORS Entity Alerts
-- Full version: entity alerts + menu + X close + mobile ☰ open

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local entities = {
    RushMoving="Rush", AmbushMoving="Ambush", Eyes="Eyes", SeekMoving="Seek",
    FigureRig="Figure", Screech="Screech", Halt="Halt", Dupe="Dupe",
    Hide="Hide", Dread="Dread", Void="Void", Jack="Jack", Timothy="Timothy",
    Shadow="Shadow", Snare="Snare", A60="A-60", A90="A-90", A120="A-120",
    BackdoorRush="Blitz", BackdoorLookman="Lookman", Giggle="Giggle",
    Grumble="Grumble", QueenGrumble="Queen Grumble",
    GloombatSwarm="Gloombat Swarm", Surge="Surge", Mandrake="Mandrake",
    Bramble="Bramble", Groundskeeper="Groundskeeper",
}

local enabled = {}
for _,name in pairs(entities) do enabled[name]=true end

local old=playerGui:FindFirstChild("DOORS_EntityAlerts")
if old then old:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="DOORS_EntityAlerts"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.Parent=playerGui

local function corner(p,r)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r)
    c.Parent=p
end

local function outline(p)
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(85,85,85)
    s.Thickness=1
    s.Parent=p
end

local sound=Instance.new("Sound")
sound.Name="EntityAlertSound"
sound.SoundId="rbxassetid://9118823106"
sound.Volume=0.6
sound.Parent=SoundService

-- MENU
local menu=Instance.new("Frame")
menu.Name="Menu"
menu.Size=UDim2.new(0,430,0,500)
menu.Position=UDim2.new(0,20,0.5,-225)
menu.BackgroundColor3=Color3.fromRGB(15,15,15)
menu.BorderSizePixel=0
menu.Parent=gui
corner(menu,12)
outline(menu)

local header=Instance.new("Frame")
header.Size=UDim2.new(1,0,0,50)
header.BackgroundTransparency=1
header.Parent=menu

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-60,1,0)
title.Position=UDim2.new(0,15,0,0)
title.BackgroundTransparency=1
title.Text="DOORS ENTITY ALERTS"
title.TextColor3=Color3.new(1,1,1)
title.TextSize=17
title.Font=Enum.Font.GothamBold
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=header

-- X
local close=Instance.new("TextButton")
close.Name="Close"
close.Size=UDim2.new(0,38,0,38)
close.Position=UDim2.new(1,-44,0,6)
close.BackgroundColor3=Color3.fromRGB(90,35,35)
close.Text="X"
close.TextColor3=Color3.new(1,1,1)
close.TextSize=18
close.Font=Enum.Font.GothamBold
close.Parent=header
corner(close,9)

-- CATEGORY TABS
local entityTab=Instance.new("TextButton")
entityTab.Size=UDim2.new(0,195,0,36)
entityTab.Position=UDim2.new(0,10,0,55)
entityTab.BackgroundColor3=Color3.fromRGB(55,100,55)
entityTab.Text="👹 СУЩНОСТИ"
entityTab.TextColor3=Color3.new(1,1,1)
entityTab.TextSize=14
entityTab.Font=Enum.Font.GothamBold
entityTab.Parent=menu
corner(entityTab,8)

local floorTab=Instance.new("TextButton")
floorTab.Size=UDim2.new(0,195,0,36)
floorTab.Position=UDim2.new(0,215,0,55)
floorTab.BackgroundColor3=Color3.fromRGB(45,45,45)
floorTab.Text="🏠 ПОДЭТАЖИ"
floorTab.TextColor3=Color3.new(1,1,1)
floorTab.TextSize=14
floorTab.Font=Enum.Font.GothamBold
floorTab.Parent=menu
corner(floorTab,8)

-- ENTITY LIST
local scroll=Instance.new("ScrollingFrame")
scroll.Position=UDim2.new(0,10,0,100)
scroll.Size=UDim2.new(1,-20,1,-110)
scroll.BackgroundTransparency=1
scroll.BorderSizePixel=0
scroll.ScrollBarThickness=5
scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.Parent=menu

local list=Instance.new("UIListLayout")
list.Padding=UDim.new(0,5)
list.SortOrder=Enum.SortOrder.LayoutOrder
list.Parent=scroll

local names={}
for _,name in pairs(entities) do names[name]=true end
local sorted={}
for name in pairs(names) do table.insert(sorted,name) end
table.sort(sorted)

for _,name in ipairs(sorted) do
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-5,0,34)
    b.BackgroundColor3=Color3.fromRGB(40,100,45)
    b.Text=name.."  [ON]"
    b.TextColor3=Color3.new(1,1,1)
    b.TextSize=14
    b.Font=Enum.Font.Gotham
    b.Parent=scroll
    corner(b,7)

    b.Activated:Connect(function()
        enabled[name]=not enabled[name]
        if enabled[name] then
            b.Text=name.."  [ON]"
            b.BackgroundColor3=Color3.fromRGB(40,100,45)
        else
            b.Text=name.."  [OFF]"
            b.BackgroundColor3=Color3.fromRGB(90,35,35)
        end
    end)
end

-- MOBILE OPEN BUTTON
local open=Instance.new("TextButton")
open.Name="Open"
open.Size=UDim2.new(0,52,0,52)
open.Position=UDim2.new(0,18,0.5,-26)
open.BackgroundColor3=Color3.fromRGB(20,20,20)
open.Text="☰"
open.TextColor3=Color3.new(1,1,1)
open.TextSize=25
open.Font=Enum.Font.GothamBold
open.Visible=false
open.Parent=gui
corner(open,14)
outline(open)

local function closeMenu()
    menu.Visible=false
    open.Visible=true
end

local function openMenu()
    menu.Visible=true
    open.Visible=false
end

close.Activated:Connect(closeMenu)
open.Activated:Connect(openMenu)

-- PC: M toggles menu
UserInputService.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.M then
        if menu.Visible then closeMenu() else openMenu() end
    end
end)

-- SUBFLOOR / FLOOR LIST
local floorScroll=Instance.new("ScrollingFrame")
floorScroll.Position=UDim2.new(0,10,0,100)
floorScroll.Size=UDim2.new(1,-20,1,-110)
floorScroll.BackgroundTransparency=1
floorScroll.BorderSizePixel=0
floorScroll.ScrollBarThickness=5
floorScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
floorScroll.Visible=false
floorScroll.Parent=menu

local floorLayout=Instance.new("UIListLayout")
floorLayout.Padding=UDim.new(0,5)
floorLayout.SortOrder=Enum.SortOrder.LayoutOrder
floorLayout.Parent=floorScroll

local subfloors={
    ["Backdoor"]=true,
    ["Rooms"]=true,
    ["Mines"]=true,
    ["Hotel"]=true,
    ["Floor 2"]=true,
}

local floorEnabled={}
for name in pairs(subfloors) do floorEnabled[name]=true end

local floorNames={}
for name in pairs(subfloors) do table.insert(floorNames,name) end
table.sort(floorNames)

for _,name in ipairs(floorNames) do
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-5,0,38)
    b.BackgroundColor3=Color3.fromRGB(40,100,45)
    b.Text=name.."  [ON]"
    b.TextColor3=Color3.new(1,1,1)
    b.TextSize=15
    b.Font=Enum.Font.Gotham
    b.Parent=floorScroll
    corner(b,7)

    b.Activated:Connect(function()
        floorEnabled[name]=not floorEnabled[name]
        if floorEnabled[name] then
            b.Text=name.."  [ON]"
            b.BackgroundColor3=Color3.fromRGB(40,100,45)
        else
            b.Text=name.."  [OFF]"
            b.BackgroundColor3=Color3.fromRGB(90,35,35)
        end
    end)
end

entityTab.Activated:Connect(function()
    scroll.Visible=true
    floorScroll.Visible=false
    entityTab.BackgroundColor3=Color3.fromRGB(55,100,55)
    floorTab.BackgroundColor3=Color3.fromRGB(45,45,45)
end)

floorTab.Activated:Connect(function()
    scroll.Visible=false
    floorScroll.Visible=true
    entityTab.BackgroundColor3=Color3.fromRGB(45,45,45)
    floorTab.BackgroundColor3=Color3.fromRGB(55,100,55)
end)

-- NOTIFICATIONS
local active={}
local counter=0

local function reposition()
    for i,frame in ipairs(active) do
        if frame and frame.Parent then
            TweenService:Create(frame,TweenInfo.new(0.2),
                {Position=UDim2.new(1,-380,0,70+(i-1)*98)}):Play()
        end
    end
end

local function removeNotification(frame)
    for i,v in ipairs(active) do
        if v==frame then table.remove(active,i) break end
    end
    if frame and frame.Parent then
        local out=TweenService:Create(frame,
            TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
            {Position=UDim2.new(1,20,0,frame.Position.Y.Offset)})
        out:Play()
        out.Completed:Wait()
        frame:Destroy()
    end
    reposition()
end

local function notify(entity)
    if not enabled[entity] then return end

    counter+=1
    local frame=Instance.new("Frame")
    frame.Name="Notification_"..counter
    frame.Size=UDim2.new(0,360,0,88)
    frame.Position=UDim2.new(1,20,0,70)
    frame.BackgroundColor3=Color3.fromRGB(18,18,18)
    frame.BorderSizePixel=0
    frame.Parent=gui
    corner(frame,10)
    outline(frame)

    table.insert(active,frame)
    local slot=#active

    local icon=Instance.new("TextLabel")
    icon.Size=UDim2.new(0,58,0,58)
    icon.Position=UDim2.new(0,12,0,15)
    icon.BackgroundColor3=Color3.fromRGB(35,35,35)
    icon.Text="!"
    icon.TextColor3=Color3.fromRGB(255,210,80)
    icon.TextSize=32
    icon.Font=Enum.Font.GothamBold
    icon.Parent=frame
    corner(icon,8)

    local head=Instance.new("TextLabel")
    head.Size=UDim2.new(1,-90,0,22)
    head.Position=UDim2.new(0,84,0,9)
    head.BackgroundTransparency=1
    head.Text="ENTITY DETECTED"
    head.TextColor3=Color3.new(1,1,1)
    head.TextSize=13
    head.Font=Enum.Font.GothamBold
    head.TextXAlignment=Enum.TextXAlignment.Left
    head.Parent=frame

    local msg=Instance.new("TextLabel")
    msg.Size=UDim2.new(1,-90,0,38)
    msg.Position=UDim2.new(0,84,0,31)
    msg.BackgroundTransparency=1
    msg.Text=entity.." has spawned!"
    msg.TextColor3=Color3.fromRGB(220,220,220)
    msg.TextSize=18
    msg.Font=Enum.Font.Gotham
    msg.TextXAlignment=Enum.TextXAlignment.Left
    msg.Parent=frame

    pcall(function() sound:Play() end)

    TweenService:Create(frame,
        TweenInfo.new(0.4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
        {Position=UDim2.new(1,-380,0,70+(slot-1)*98)}):Play()

    task.delay(4,function() removeNotification(frame) end)
end

-- DETECTION
local lastDetected={}

local function detect(obj)
    local entity=entities[obj.Name]
    if not entity or not enabled[entity] then return end
    if lastDetected[obj] then return end

    lastDetected[obj]=true
    task.spawn(function() notify(entity) end)

    task.delay(10,function()
        lastDetected[obj]=nil
    end)
end

workspace.DescendantAdded:Connect(detect)

for _,obj in ipairs(workspace:GetDescendants()) do
    detect(obj)
end
