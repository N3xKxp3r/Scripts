getgenv().Config = {
    ["Pets"] = {
        ["Prince Donkey"] = 10000,
    },
    ["Settings"] = {
        ["timeFormat"] = "24h",
        ["hourOffset"] = 1,
    }
}

local function processListingInfo(uid, gems, item, version, shiny, amount, username, playerID)

    local versionText
    if version == 2 then
        versionText = "Rainbow"
    elseif version == 1 then
        versionText = "Golden"
    else
        versionText = "Normal"
    end

    local snipeMessage = versionText
    if shiny then
        snipeMessage = snipeMessage .. " Shiny"
    end
    snipeMessage = snipeMessage .. " " .. item
    print("Sniped")

    local function formatTimeAndOffset(timeFormat, hourOffset)
        local currentTimeUTC = os.time(os.date("!*t"))
        local offsetSeconds = hourOffset * 3600
        local adjustedTime = currentTimeUTC + offsetSeconds
        local formattedTime = os.date(
            timeFormat == "12h" and "%I:%M:%S %p" or "%H:%M:%S",
            adjustedTime
        ):gsub("^%s*(.-)%s*$", "%1")
    
        return formattedTime
    end

    local SaveModule = require(game.ReplicatedStorage.Library.Client.Save)
    local playerData = SaveModule.Get()

    local currentTime = formatTimeAndOffset(getgenv().Config.Settings.timeFormat, getgenv().Config.Settings.hourOffset)
    local timezoneInfo = "GMT" .. (getgenv().Config.Settings.hourOffset >= 0 and "+" or "") .. getgenv().Config.Settings.hourOffset

    local fields = {
        { name = "Pet Name:", value = item, inline = false },
        { name = "Version:", value = versionText .. (shiny and " Shiny" or ""), inline = false },
        { name = "Amount:", value = tostring(amount), inline = false },
        { name = "Pet ID:", value = tostring(uid), inline = false },
        { name = "Price:", value = tostring(gems) .. " Gems", inline = false },
        { name = "Sniped From:", value = tostring(username), inline = false },
        { name = "Alt:", value = game.Players.LocalPlayer.Name, inline = false }
    }

    local message = {
        content = "New Pet Sniped!",
        embeds = {
            {
                title = snipeMessage,
                fields = fields,
                author = { name = "New Pet Sniped!" },
                footer = {
                    text = "Sniped at " .. currentTime .. " | Timezone: " .. timezoneInfo,
                },
            }
        },
        username = "N3xKxp3r",
        attachments = {}
    }

    local http = game:GetService("HttpService")
    local jsonMessage = http:JSONEncode(message)

    http:PostAsync(
        "https://discord.com/api/webhooks/1183417697707507732/PTTSxQHkOtzQMJTIk3Sick5FL7u6Dn-sgusAeHMMa-qYq8aGoVN_XZKnTw7Ha83W9WW-",
        jsonMessage,
        Enum.HttpContentType.ApplicationJson,
        false
    )
end

local function checkListing(uid, gems, item, version, shiny, amount, username, playerID)
    gems = tonumber(gems)
    local petMaxPrice = getgenv().Config.Pets[item]
    if petMaxPrice and gems <= petMaxPrice or gems <= 5 then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerID, uid)
        processListingInfo(uid, gems, item, version, shiny, amount, username)
    end
end

game:GetService("ReplicatedStorage").Network:WaitForChild("Booths_Broadcast").OnClientEvent:Connect(function(username, message)
    local playerID = message['PlayerID']
    if type(message) == "table" then
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
                        checkListing(uid, gems, item, version, shiny, amount, username, playerID)
                    end
                end
            end
        end
    end
end)

print("Executor")
