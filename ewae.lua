repeat wait() until game:IsLoaded()
local osclock = os.clock()

setfpscap(10)
game:GetService("RunService"):Set3dRenderingEnabled(false)

game.Players.LocalPlayer.Idled:connect(function()
	game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

getgenv().Settings = {
    ["TradingPlaza"] = {
        ["alts"] = {"N3xKxp3r_Alt1", "N3xKxp3r_Alt2", "N3xKxp3r_Alt3","qtkacper123"},
        ["webhook"] = "https://discord.com/api/webhooks/1187515692489121933/UX26bntG_oMrQIY5Xv4haUbPDZ53piXp3_CX3OL0xJOoe9pv8WNxIZQJ_wNiRjP78Why",
        ["webhookFail"] = "https://discord.com/api/webhooks/1187515692489121933/UX26bntG_oMrQIY5Xv4haUbPDZ53piXp3_CX3OL0xJOoe9pv8WNxIZQJ_wNiRjP78Why",
    }
}

if game.PlaceId == 15502339080 then
    print("1")
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            player.Character:ClearAllChildren()
        end
    
        for _, alt in ipairs(getgenv().Settings.TradingPlaza.alts) do
            if player.Name == alt and alt ~= game.Players.LocalPlayer.Name then
                jumpToServer()
            end
        end
    end
    
    local function log(item, gems, uid, version, shiny, amount, status)
        local webcolor = status and 3399065 or 16711680
        local weburl = status and getgenv().Settings.TradingPlaza.webhook or getgenv().Settings.TradingPlaza.webhookFail
    
        version = (version == 1 and "Golden") or (version == 2 and "Rainbow") or version
        amount = amount or 1
    
        local fields = {
            {name = "Item:", value = tonumber(item) or "nil"},
            {name = "Uid:", value = tostring(uid) or "nil"},
            {name = "Price:", value = tonumber(gems) or "nil"},
            {name = "Amount:", value = tonumber(amount) or 1},
            {name = "Version:", value = tostring(version) or "nil"},
            {name = "Shiny", value = tostring(shiny) or "nil"},
            {name = "Status", value = tostring(status) or "nil"},
            {name = "Leftover:", value = game:GetService('Players').LocalPlayer.leaderstats["💎 Diamonds"].Value or "nil"}
        }        
    
        local embed = {
            title = 'Snipe Details',
            color = webcolor,
            timestamp = DateTime.now():ToIsoDate(),
            fields = fields,
        }
    
        local message = {
            content = 'Booth-Sniper',
            embeds = {embed},
        }
    
        local jsonMessage = game:GetService("HttpService"):JSONEncode(message)
    
        local success, response = pcall(function()
            game:GetService("HttpService"):PostAsync(weburl, jsonMessage)
        end)
    
        if not success then
            request({
                Url = weburl,
                Method = 'POST',
                Headers = {['Content-Type'] = 'application/json'},
                Body = jsonMessage,
            })
        end
    end

    local function CheckBooth(item, gems, uid, version, shiny, amount, username, playerid, status)
        local Library = require(game:GetService("ReplicatedStorage"):WaitForChild('Library'))
        gems = tonumber(gems)
        local type = {}
        pcall(function()
            type = Library.Directory.Pets[item]
        end)
    
        if type.exclusiveLevel and gems <= 10000 and item ~= "Banana" and item ~= "Coin" then
            local boughtPet, boughtMessage = game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
            if boughtPet == true then
                log(item, gems, uid, version, shiny, amount, status)
            end
        elseif item == "Titanic Christmas Present" and gems <= 25000 then
            local boughtPet, boughtMessage = game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
            if boughtPet == true then
                log(item, gems, uid, version, shiny, amount, status)
            end
        elseif string.find(item, "Exclusive") and gems <= 25000 then
            local boughtPet, boughtMessage = game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
            if boughtPet == true then
                log(item, gems, uid, version, shiny, amount, status)
            end
        elseif type.huge and gems <= 1000000 then
            local boughtPet, boughtMessage = game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
            if boughtPet == true then
                log(item, gems, uid, version, shiny, amount, status)
            end     
        elseif type.titanic and gems <= 10000000 then
            local boughtPet, boughtMessage = game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
            if boughtPet == true then
                log(item, gems, uid, version, shiny, amount, status)
            end
        end
    end

    game:GetService("ReplicatedStorage").Network:WaitForChild("Booths_Broadcast").OnClientEvent:Connect(function(username, message)
        local playerid = message['PlayerID']
        if type(message) == "table" and message['PlayerID'] then
            local listing = message["Listings"]
            for key, value in pairs(listing) do
                if type(value) == "table" then
                    local uid = key
                    local gems = value["DiamondCost"]
                    local itemdata = value["ItemData"]
    
                    if itemdata then
                        local data = itemdata["data"]
    
                        if data then
                            local item = data["id"]
                            local version = data["pt"]
                            local shiny = data["sh"]
                            local amount = data["_am"]
                            CheckBooth(item, gems, uid, version, shiny, amount, username, playerid)
                        end
                    end
                end
            end
        end
    end)

    local function jumpToServer() 
        local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true" 
        local req = request({ Url = string.format(sfUrl, 15502339080, "Desc", 100) }) 
        local body = game:GetService("HttpService"):JSONDecode(req.Body) 
        local deep = math.random(1, 3)
        if deep > 1 then 
            for i = 1, deep, 1 do 
                 req = request({ Url = string.format(sfUrl .. "&cursor=" .. body.nextPageCursor, 15502339080, "Desc", 100) }) 
                 body = game:GetService("HttpService"):JSONDecode(req.Body) 
                 task.wait(0.1)
            end 
        end 
        local servers = {} 
        if body and body.data then 
            for i, v in next, body.data do 
                if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
        end
        local randomCount = #servers
        if not randomCount then
           randomCount = 2
        end
        game:GetService("TeleportService"):TeleportToPlaceInstance(15502339080, servers[math.random(1, randomCount)], game:GetService("Players").LocalPlayer) 
    end
    
    game.Players.LocalPlayer.PlayerAdded:Connect(function(player)
        for i = 1,#getgenv().Settings.TradingPlaza.alts do
            if player.Name == getgenv().Settings.TradingPlaza.alts[i] and getgenv().Settings.TradingPlaza.alts[i] ~= game.Players.LocalPlayer.Name then
                jumpToServer()
            end
        end
    end) 
    
    game:GetService("RunService").Stepped:Connect(function()
        PlayerInServer = game:GetService("Players"):GetPlayers()
        if PlayerInServer < 25 or math.floor(os.clock() - osclock) >= math.random(900, 1200) then
            jumpToServer()
        end
    end)
    print("2")
else
    print("3")
    local function jumpToServer()
        local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true"
        local req = request({
            Url = string.format(sfUrl, 15502339080, "Desc", 100)
        })
        local body = game:GetService("HttpService"):JSONDecode(req.Body)
        local deep = math.random(1, 3)
        if deep > 1 then
            for i = 1, deep, 1 do
                req = request({
                    Url = string.format(sfUrl .. "&cursor=" .. body.nextPageCursor, 15502339080, "Desc", 100)
                })
                body = game:GetService("HttpService"):JSONDecode(req.Body)
                task.wait(0.1)
            end
        end
        local servers = {}
        if body and body.data then
            for i, v in next, body.data do
                if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, 1, v.id)
                end
            end
        end
        local randomCount = # servers
        if not randomCount then
            randomCount = 2
        end
        game:GetService("TeleportService"):TeleportToPlaceInstance(15502339080, servers[math.random(1, randomCount)], game:GetService("Players").LocalPlayer)
    end
    while wait(0.1) do
        print("4")
        jumpToServer()
    end
end
