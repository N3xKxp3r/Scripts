local Save = require(game.ReplicatedStorage.Library.Client.Save).Get()

local function GetDiamonds()
    for _, v in pairs(Save.Inventory.Currency) do 
        if v.id == 'Diamonds' then 
            return v._am 
        end 
    end
end

local diamonds = GetDiamonds()
print(diamonds)
