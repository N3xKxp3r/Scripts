local Settings = {
    Webhook = {
        URL = "https://discord.com/api/webhooks/1187008049064444034/SviWAYuaP7KmKUIowZtM2K6XUd2RIR_tY8ZgHlF9t8xD4SJ0SfgZRDf4Q8yiGbkWNs4e",
        Colors = {
            Success = 0x00FF00,
            Alert = 0xFF0000,
            Warning = 0xFFFF00
        },
        Footer = {
            Text = "Made by N3xKxp3r",
        }
    },
    Teleport = {
        MaxRetries = 10,
        RetryDelay = 5,
        BeforeTeleportDelay = 2.5
    },
    Delays = {
        BeforeExecute = 1,
        BeforeBreak = 1,
        AfterBreak = 2,
        Hit = 0.1,
        Lootbag = 0.1,
        BeforeTp = 3,
        WhileError = 5
    },
    placeId = 8737899170,
    eventName = "Gingerbread",
    servers = {
        count = 100,
        sort = "Desc",
        pageDeep = math.random(5, 15)
    },
}

repeat
    task.wait()
until game.PlaceId ~= nil

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

task.wait(Settings.Delays.BeforeExecute)

if game.PlaceId ~= Settings.placeId then
    print("Gingerbread hunter unloaded, unknown place.")
    return
end

local Library = require(ReplicatedStorage:WaitForChild("Library", 2000))
if not Library.Loaded then
    repeat
        task.wait()
    until Library.Loaded ~= false
end

local RandomEventCmds = Library.RandomEventCmds
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:WaitForChild("Humanoid", 1000)
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 1000)

local function teleportToPosition(position)
    HumanoidRootPart.CFrame = CFrame.new(position)
end

local function sendWebhook(content, color, title, description)
    local data = {
        content = content,
        embeds = {
            {
                title = title,
                description = description,
                color = color,
                footer = {
                    text = Settings.Webhook.Footer.Text
                }
            }
        }
    }

    local encodedData = HttpService:JSONEncode(data)
    pcall(function()
        HttpService:PostAsync(Settings.Webhook.URL, encodedData, Enum.HttpContentType.ApplicationJson)
    end)
end

local function sendSuccessWebhook(title, description)
    sendWebhook("Success", Settings.Webhook.Colors.Success, title, description)
end

local function sendAlertWebhook(title, description)
    sendWebhook("Alert", Settings.Webhook.Colors.Alert, title, description)
end

local function sendWarningWebhook(title, description)
    sendWebhook("Warning", Settings.Webhook.Colors.Warning, title, description)
end

local function jumpToServer()
    local urlFormat = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true"
    local response = request({
        Url = string.format(urlFormat, Settings.placeId, Settings.servers.sort, Settings.servers.count)
    })

    local serverData = HttpService:JSONDecode(response.Body)

    if Settings.servers.pageDeep > 1 then
        for count = 1, Settings.servers.pageDeep, 1 do
            response = request({
                Url = string.format(urlFormat .. "&cursor=" .. serverData.nextPageCursor, Settings.placeId, Settings.servers.sort, Settings.servers.count)
            })
            serverData = HttpService:JSONDecode(response.Body)
            task.wait(0.1)
        end
    end

    local servers = {}
    if serverData and serverData.data then
        for _, server in next, serverData.data do
            if type(server) == "table" then
                table.insert(servers, 1, server.id)
            end
        end
    end

    local serverCount = #servers
    if not serverCount then
        serverCount = 2
    end

    TeleportService:TeleportToPlaceInstance(Settings.placeId, servers[math.random(1, serverCount)], Players.LocalPlayer)
end

Library.Alert.Message("Finding Gingerbread...")
sendWebhook("Finding Gingerbread!", Settings.Webhook.Colors.Info, "Gingerbread Hunt", "Looking for Gingerbread!")

local activeEvents = RandomEventCmds.GetActive() or RandomEventCmds.GetActive()
local gingerbreadFound = false

task.wait(Settings.Delays.BeforeExecute)

for _, event in activeEvents do
    if event.name == Settings.eventName then
        gingerbreadFound = true
        teleportToPosition(event.origin + Vector3.new(0, 18, 0))
    end
end

ReplicatedStorage.Things:FindFirstChild("Lootbags").ChildAdded:Connect(function(lootbag)
    task.wait()
    if lootbag then
        ReplicatedStorage.Network.Lootbags_Claim:FireServer(unpack({{lootbag.Name}}))
    end
end)

local function collectAllLootbags()
    pcall(function()
        for _, lootbag in pairs(ReplicatedStorage.Things:FindFirstChild("Lootbags"):GetChildren()) do
            if lootbag and not lootbag:GetAttribute("Collected") then
                ReplicatedStorage.Network.Lootbags_Claim:FireServer(unpack({{lootbag.Name}}))
                task.wait(Settings.Delays.Lootbag)
            end
        end
    end)
end

local function findGingerbread()
    for _, breakable in ReplicatedStorage.Things.Breakables:GetChildren() do
        if breakable.ClassName == "Model" and breakable:GetAttribute("BreakableID") == Settings.eventName then
            return breakable
        end
    end
end

if gingerbreadFound then
    sendSuccessWebhook("Gingerbread Found", "Gingerbread has been located!")

    task.wait(Settings.Delays.BeforeBreak)
    local gingerbreadModel = nil

    for attempt = 1, Settings.Teleport.MaxRetries, 1 do
        gingerbreadModel = findGingerbread()

        if gingerbreadModel then
            teleportToPosition(gingerbreadModel.PrimaryPart.Position + Vector3.new(0, 18, 0))
            break
        else
            task.wait(Settings.Teleport.RetryDelay)
        end
    end

    if gingerbreadModel then
        sendWebhook("Start Breaking!", Settings.Webhook.Colors.Success, "Breaking Gingerbread", "Preparing to break Gingerbread!")

        while ReplicatedStorage.Things.Breakables:FindFirstChild(gingerbreadModel.Name) do
            local damageData = {{gingerbreadModel.Name}}
            ReplicatedStorage.Network.Breakables_PlayerDealDamage:FireServer(unpack(damageData))
            task.wait(Settings.Delays.Hit)
        end

		sendAlertWebhook("Gingerbread Broken", "The Gingerbread has been successfully broken!")

        gingerbreadModel = false
    end

    collectAllLootbags()
    task.wait(Settings.Delays.AfterBreak)
    collectAllLootbags()
    task.wait(Settings.Delays.AfterBreak)
else
    sendWebhook("Gingerbread not found ", Settings.Webhook.Colors.Alert, "Gingerbread Not Found", "Unable to locate Gingerbread.")
end

TeleportService.TeleportInitFailed:Connect(function(server, resultEnum, message)
    Settings.servers.pageDeep = Settings.servers.pageDeep + 1
    sendEventUpdate("Teleport Retry", "Retrying teleport... :" .. message, Settings.Webhook.Colors.Warning)
    task.wait(Settings.Delays.WhileError)
    jumpToServer()
end)

task.wait(Settings.Delays.BeforeTp)
sendEventUpdate("Teleporting", "Teleporting to another server...", Settings.Webhook.Colors.Success)
jumpToServer()
