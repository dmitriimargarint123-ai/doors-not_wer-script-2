-- DOORS ACHIEVEMENTS - STANDALONE
-- Original Pastebin loader removed.
-- Void/Shadow removed. Dupe checks current room only.

task.spawn(function()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UIS = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local LP = Players.LocalPlayer

    local function getGuiParent()
        local ok2, hui = pcall(function()
            if gethui then return gethui() end
        end)
        if ok2 and hui then return hui end
        return CoreGui
    end

    local ROOT = getGuiParent()

    -- IMPORTANT:
    -- Void and Shadow are intentionally NOT present here.
    -- Dupe is handled separately and only fires for the player's current room.
    local FLOORS = {
        Hotel = {
            "Rush", "Ambush", "Eyes", "Seek", "Figure", "Screech",
            "Halt", "Dupe", "Hide", "Jack", "Timothy", "Snare",
            "Dread", "Jeff the Killer", "Sally"
        },
        Mines = {
            "Rush", "Ambush", "Eyes", "Seek", "Screech", "Halt",
            "Giggle", "Gloombat Swarm", "Grumble", "Queen Grumble",
            "Bramble", "Groundskeeper", "Monument", "Jeff the Killer"
        },
        Backdoor = {
            "Blitz", "Lookman", "Haste"
        },
        Rooms = {
            "A-60", "A-90", "A-120"
        },
        Archives = {
            "Creak", "Noise", "Drones Stampede", "Teller",
            "Scribbles", "Bash", "Balls"
        },
        Outdoors = {
            "Bramble", "Groundskeeper", "Mandrake", "Monument",
            "Surge", "Jeff the Killer"
        }
    }

    -- Internal Roblox names -> display name.
    local NAME_MAP = {
        RushMoving = "Rush",
        AmbushMoving = "Ambush",
        Eyes = "Eyes",
        Lookman = "Eyes",
        SeekMoving = "Seek",
        FigureRig = "Figure",
        FigureRagdoll = "Figure",
        Figure = "Figure",
        Screech = "Screech",
        Halt = "Halt",
        DoorFake = "Dupe",
        FakeDoor = "Dupe",
        Hide = "Hide",
        Jack = "Jack",
        Timothy = "Timothy",
        Snare = "Snare",
        Dread = "Dread",
        JeffTheKiller = "Jeff the Killer",
        SallyMoving = "Sally",
        BackdoorRush = "Blitz",
        BackdoorLookman = "Lookman",
        A60 = "A-60",
        A90 = "A-90",
        A120 = "A-120",
        GloombatSwarm = "Gloombat Swarm",
        GiggleCeiling = "Giggle",
        GrumbleRig = "Grumble",
        QueenGrumble = "Queen Grumble",
        LiveEntityBramble = "Bramble",
        Groundskeeper = "Groundskeeper",
        MonumentEntity = "Monument",
        Creak = "Creak",
        NoiseModel = "Noise",
        DronesStampede = "Drones Stampede",
        TellerRig = "Teller",
        Scribbles = "Scribbles",
        BashMoving = "Bash",
        StemsEntity = "Balls",
        Mandrake = "Mandrake",
        Surge = "Surge"
    }

    local enabled = {}
    for _, list in pairs(FLOORS) do
        for _, name in ipairs(list) do
            enabled[name] = true
        end
    end

    -- Prevent duplicate alerts for the same spawned instance.
    local seen = setmetatable({}, {__mode = "k"})

    local function getFloor()
        local gd = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
        local f = gd and gd:FindFirstChild("Floor")
        if f and f.Value then
            return tostring(f.Value)
        end
        return "Hotel"
    end

    local function normalizeFloor(f)
        f = tostring(f or "")
        if f == "OldHotel" or f == "Hotel" or f == "Fools" then return "Hotel" end
        if f == "Mines" then return "Mines" end
        if f == "Backdoor" then return "Backdoor" end
        if f == "Rooms" then return "Rooms" end
        if f == "Archives" or f == "ArchivesFloor" then return "Archives" end
        if f == "Outdoors" or f == "Outdoor" then return "Outdoors" end
        return f
    end

    local function getCurrentRoom()
        local v = LP:GetAttribute("CurrentRoom")
        if tonumber(v) then return tonumber(v) end

        local gd = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
        local latest = gd and gd:FindFirstChild("LatestRoom")
        if latest and tonumber(latest.Value) then
            return tonumber(latest.Value)
        end

        local rooms = workspace:FindFirstChild("CurrentRooms")
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if rooms and root then
            local best, dist = nil, math.huge
            for _, room in ipairs(rooms:GetChildren()) do
                local n = tonumber(room.Name)
                if n then
                    local cf = room:GetPivot()
                    local d = (cf.Position - root.Position).Magnitude
                    if d < dist then
                        dist, best = d, n
                    end
                end
            end
            return best
        end
    end

    local function findRoomAncestor(obj)
        local rooms = workspace:FindFirstChild("CurrentRooms")
        if not rooms then return nil end

        local p = obj
        while p and p ~= workspace do
            if p.Parent == rooms and tonumber(p.Name) then
                return p
            end
            p = p.Parent
        end
        return nil
    end

    -- Achievement UI.
    local gui = Instance.new("ScreenGui")
    gui.Name = "DOORS_AchievementAlerts"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.Parent = ROOT

    local holder = Instance.new("Frame")
    holder.Name = "Achievements"
    holder.AnchorPoint = Vector2.new(1, 0)
    holder.Position = UDim2.new(1, -18, 0, 55)
    holder.Size = UDim2.new(0, 390, 0, 0)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.BackgroundTransparency = 1
    holder.Parent = gui

    local layout = Instance.new("UIListLayout")
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 7)
    layout.Parent = holder

    local function getAchievementTemplate()
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        local global = pg and (pg:FindFirstChild("GlobalUI") or pg:FindFirstChild("MainUI"))
        local ah = global and global:FindFirstChild("AchievementsHolder")
        local template = ah and ah:FindFirstChild("Achievement")
        return template
    end

    local function showAchievement(entityName, floorName)
        local template = getAchievementTemplate()

        if template then
            local ok3 = pcall(function()
                local a = template:Clone()
                a.Name = "CustomAchievement"
                a.Visible = true
                a.Size = UDim2.new(0, 0, 0, 0)
                a.Parent = template.Parent

                local frame = a:FindFirstChild("Frame")
                if frame then
                    local text = frame:FindFirstChild("TextLabel")
                    local details = frame:FindFirstChild("Details")
                    local image = frame:FindFirstChild("ImageLabel")

                    if text then text.Text = "ENTITY DETECTED" end
                    if details then
                        local title = details:FindFirstChild("Title")
                        local desc = details:FindFirstChild("Desc")
                        local reason = details:FindFirstChild("Reason")
                        if title then title.Text = entityName end
                        if desc then desc.Text = "Spawned on " .. floorName end
                        if reason then reason.Text = "" end
                    end
                    if image then image.Image = "rbxassetid://6023426923" end
                end

                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://10469938989"
                sound.Volume = 1
                sound.Parent = a
                sound:Play()

                a:TweenSize(UDim2.new(1, 0, 0.2, 0), "In", "Quad", 0.6, true)
                task.wait(0.6)
                if a.Parent then
                    task.wait(3.5)
                    a:TweenSize(UDim2.new(1, 0, -0.1, 0), "InOut", "Quad", 0.5, true)
                    task.wait(0.5)
                    a:Destroy()
                end
            end)
            if ok3 then return end
        end

        -- Fallback achievement card if the game's template is unavailable.
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 370, 0, 74)
        card.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        card.BackgroundTransparency = 0.08
        card.BorderSizePixel = 0
        card.Parent = holder

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = card

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0, 15, 0, 8)
        title.Size = UDim2.new(1, -30, 0, 18)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Text = "ENTITY DETECTED"
        title.TextColor3 = Color3.fromRGB(255, 220, 80)
        title.Parent = card

        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Position = UDim2.new(0, 15, 0, 29)
        name.Size = UDim2.new(1, -30, 0, 20)
        name.Font = Enum.Font.GothamBold
        name.TextSize = 16
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Text = entityName
        name.TextColor3 = Color3.new(1, 1, 1)
        name.Parent = card

        local floor = Instance.new("TextLabel")
        floor.BackgroundTransparency = 1
        floor.Position = UDim2.new(0, 15, 0, 51)
        floor.Size = UDim2.new(1, -30, 0, 16)
        floor.Font = Enum.Font.Gotham
        floor.TextSize = 11
        floor.TextXAlignment = Enum.TextXAlignment.Left
        floor.Text = "Spawned on " .. floorName
        floor.TextColor3 = Color3.fromRGB(180, 180, 180)
        floor.Parent = card

        task.delay(4.5, function()
            if card.Parent then
                card:Destroy()
            end
        end)
    end

    -- Menu.
    local menu = Instance.new("Frame")
    menu.Name = "EntityMenu"
    menu.Size = UDim2.new(0, 420, 0, 470)
    menu.Position = UDim2.new(0.5, -210, 0, 8)
    menu.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    menu.BorderSizePixel = 0
    menu.Visible = true
    menu.Parent = gui

    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 10)
    mc.Parent = menu

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 8)
    title.Size = UDim2.new(1, -65, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "🏆 DOORS ACHIEVEMENTS"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.ZIndex = 90
    title.Parent = menu

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 44, 0, 38)
    close.Position = UDim2.new(1, -50, 0, 6)
    close.Text = "✕"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 22
    close.TextColor3 = Color3.new(1, 1, 1)
    close.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
    close.BorderSizePixel = 0
    close.ZIndex = 100
    close.Parent = menu
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

    local open = Instance.new("TextButton")
    open.Size = UDim2.new(0, 45, 0, 45)
    open.Position = UDim2.new(0, 12, 0.5, -22)
    open.Text = "☰"
    open.Font = Enum.Font.GothamBold
    open.TextSize = 22
    open.TextColor3 = Color3.new(1, 1, 1)
    open.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    open.BorderSizePixel = 0
    open.Visible = false
    open.ZIndex = 100
    open.Parent = gui
    Instance.new("UICorner", open).CornerRadius = UDim.new(0, 9)

    close.Activated:Connect(function()
        menu.Visible = false
        open.Visible = true
    end)

    open.Activated:Connect(function()
        menu.Visible = true
        open.Visible = false
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.M then
            menu.Visible = not menu.Visible
            open.Visible = not menu.Visible
        end
    end)

    local tabs = Instance.new("Frame")
    tabs.BackgroundTransparency = 1
    tabs.Position = UDim2.new(0, 10, 0, 48)
    tabs.Size = UDim2.new(1, -20, 0, 38)
    tabs.Parent = menu

    local content = Instance.new("ScrollingFrame")
    content.Position = UDim2.new(0, 10, 0, 92)
    content.Size = UDim2.new(1, -20, 1, -102)
    content.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 5
    content.CanvasSize = UDim2.new()
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = menu
    Instance.new("UICorner", content).CornerRadius = UDim.new(0, 7)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 7)
    padding.PaddingLeft = UDim.new(0, 7)
    padding.PaddingRight = UDim.new(0, 7)
    padding.PaddingBottom = UDim.new(0, 7)
    padding.Parent = content

    local cl = Instance.new("UIListLayout")
    cl.Padding = UDim.new(0, 5)
    cl.Parent = content

    local tabButtons = {}

    local function rebuild(floorName)
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end

        for _, entityName in ipairs(FLOORS[floorName] or {}) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 34)
            row.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
            row.BorderSizePixel = 0
            row.Parent = content
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Size = UDim2.new(1, -95, 1, 0)
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = entityName
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Parent = row

            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(0, 70, 0, 25)
            toggle.Position = UDim2.new(1, -78, 0.5, -12)
            toggle.Font = Enum.Font.GothamBold
            toggle.TextSize = 11
            toggle.BorderSizePixel = 0
            toggle.Parent = row
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 5)

            local function refresh()
                if enabled[entityName] then
                    toggle.Text = "ON"
                    toggle.BackgroundColor3 = Color3.fromRGB(45, 145, 75)
                else
                    toggle.Text = "OFF"
                    toggle.BackgroundColor3 = Color3.fromRGB(145, 50, 50)
                end
            end

            toggle.Activated:Connect(function()
                enabled[entityName] = not enabled[entityName]
                refresh()
            end)

            refresh()
        end
    end

    local firstFloor = "Hotel"
    local x = 0
    for floorName in pairs(FLOORS) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 62, 1, 0)
        b.Position = UDim2.new(0, x, 0, 0)
        b.Text = floorName
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.TextColor3 = Color3.new(1, 1, 1)
        b.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
        b.BorderSizePixel = 0
        b.Parent = tabs
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        tabButtons[floorName] = b

        b.Activated:Connect(function()
            rebuild(floorName)
            for name, btn in pairs(tabButtons) do
                btn.BackgroundColor3 = (name == floorName)
                    and Color3.fromRGB(70, 100, 170)
                    or Color3.fromRGB(45, 45, 52)
            end
        end)
        x += 66
    end

    rebuild(firstFloor)
    if tabButtons[firstFloor] then
        tabButtons[firstFloor].BackgroundColor3 = Color3.fromRGB(70, 100, 170)
    end

    local function allowedOnCurrentFloor(displayName)
        local floorName = normalizeFloor(getFloor())
        local list = FLOORS[floorName]
        if not list then
            -- Unknown floor: do not create false positives.
            return false, floorName
        end
        for _, n in ipairs(list) do
            if n == displayName then
                return enabled[displayName] ~= false, floorName
            end
        end
        return false, floorName
    end

    local function isDupeInCurrentRoom(obj)
        local room = findRoomAncestor(obj)
        if not room then return false end

        local roomNumber = tonumber(room.Name)
        local current = getCurrentRoom()
        if not roomNumber or not current then return false end

        -- Critical fix: next-room Dupe is ignored.
        return roomNumber == current
    end

    local function notifyForObject(obj)
        if not obj or not obj.Parent or seen[obj] then return end

        local internal = obj.Name
        local displayName = NAME_MAP[internal]
        if not displayName then return end

        -- Dupe is special: only current room, never the next room.
        if displayName == "Dupe" then
            if not isDupeInCurrentRoom(obj) then return end
        end

        local allowed, floorName = allowedOnCurrentFloor(displayName)
        if not allowed then return end

        seen[obj] = true
        showAchievement(displayName, floorName)
    end

    local function scanObject(obj)
        if NAME_MAP[obj.Name] then
            notifyForObject(obj)
        end
    end

    -- Initial scan, but don't spam old entities: only scan Dupe in current room.
    local rooms = workspace:FindFirstChild("CurrentRooms")
    if rooms then
        local current = getCurrentRoom()
        local room = current and rooms:FindFirstChild(tostring(current))
        if room then
            for _, obj in ipairs(room:GetDescendants()) do
                if obj.Name == "DoorFake" or obj.Name == "FakeDoor" then
                    notifyForObject(obj)
                end
            end
        end
    end

    -- New entities.
    workspace.DescendantAdded:Connect(function(obj)
        if NAME_MAP[obj.Name] then
            task.defer(function()
                notifyForObject(obj)
            end)
        end
    end)

    -- When the player enters a new room, check ONLY that room for Dupe.
    task.spawn(function()
        local lastRoom = getCurrentRoom()
        while task.wait(0.25) do
            local now = getCurrentRoom()
            if now and now ~= lastRoom then
                lastRoom = now

                local currentRooms = workspace:FindFirstChild("CurrentRooms")
                local room = currentRooms and currentRooms:FindFirstChild(tostring(now))
                if room then
                    task.wait(0.05)
                    for _, obj in ipairs(room:GetDescendants()) do
                        if obj.Name == "DoorFake" or obj.Name == "FakeDoor" then
                            notifyForObject(obj)
                        end
                    end
                end
            end
        end
    end)

    print("[DOORS Achievements] Loaded. Void/Shadow removed. Dupe current-room fix enabled.")
end)
