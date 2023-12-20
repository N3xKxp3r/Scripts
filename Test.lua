-- Made By N3xKxp3r

local SaveModule = require(game.ReplicatedStorage.Library.Client.Save)
local a = SaveModule.Get()

local function formatNumber(number)
    local suffixes = {"", "k", "m", "b", "t", "q", "qa"}
    local suffixIndex = 1

    while number >= 1000 and suffixIndex < #suffixes do
        number = number / 1000
        suffixIndex = suffixIndex + 1
    end

    return string.format("%.2f%s", number, suffixes[suffixIndex])
end

local function getDiamondsAmount()
    for _, currency in pairs(a.Inventory.Currency) do
        if currency.id == 'Diamonds' then
            return currency._am
        end
    end
    return 0
end

local diamondsAmount = getDiamondsAmount()
local formattedDiamonds = formatNumber(diamondsAmount)
print("Diamonds: " .. formattedDiamonds)
