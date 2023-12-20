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

    local function formatNumberWithSuffix(number)
        local suffixes = {"", "k", "m", "b", "t", "q", "qa"}
        local suffixIndex = 1
        while number >= 1000 and suffixIndex < #suffixes do
            number = number / 1000
            suffixIndex = suffixIndex + 1
        end
        return string.format("%.2f%s", number, suffixes[suffixIndex])
    end
    
    local function getCurrencyAmount(currencyId)
        for _, currency in pairs(playerData.Inventory.Currency) do
            if currency.id == currencyId then
                return currency._am
            end
        end
        return 0
    end

    local function formatTimeAndOffset(timeFormat, hourOffset)
        return os.date(
            timeFormat == "12h" and "%I:%M:%S %p" or "%H:%M:%S",
            os.time() + (hourOffset and hourOffset * 3600 or 0)
        ):gsub("^%s*(.-)%s*$", "%1")
    end

    local SaveModule = require(game.ReplicatedStorage.Library.Client.Save)
    local playerData = SaveModule.Get()
    local diamondsAmount = getCurrencyAmount('Diamonds')

    local currentTime = formatTimeAndOffset(getgenv().Config.Settings.timeFormat, getgenv().Config.Settings.hourOffset)
    local timezoneInfo = "GMT" .. (getgenv().Config.Settings.hourOffset >= 0 and "+" or "") .. getgenv().Config.Settings.hourOffset

    local fields = {
        { name = "Pet Name:", value = item, inline = false },
        { name = "Version:", value = versionText .. (shiny and " Shiny" or ""), inline = false },
        { name = "Amount:", value = tostring(amount), inline = false },
        { name = "Pet ID:", value = tostring(uid), inline = false },
        { name = "Price:", value = tostring(gems) .. " Gems", inline = false },
        { name = "Remaining Gems:", value = tostring(formatNumberWithSuffix(diamondsAmount)) .. " Gems", inline = false },
        { name = "Sniped From:", value = string.format("%s (%s)", username, playerID), inline = false },
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
