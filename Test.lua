local function FormatNumber(number)
    local suffixes = {"", "K", "M", "B"}
    local formattedNumber = number
    local suffixIndex = 1
    
    while formattedNumber >= 1000 and suffixIndex < #suffixes do
        formattedNumber = formattedNumber / 1000
        suffixIndex = suffixIndex + 1
    end
    
    return string.format("%.2f%s", formattedNumber, suffixes[suffixIndex])
end

local Plaza = getsenv(game.Players.LocalPlayer.PlayerScripts:WaitForChild("Scripts"):WaitForChild("GUIs"):WaitForChild("Currency"))
local Save = require(game.ReplicatedStorage.Library.Client.Save).Get()

local function GetDiamonds()
    for _, v in pairs(Save.Inventory.Currency) do 
        if v.id == 'Diamonds' then 
            return v._am 
        end 
    end
end

local function CloneDiamonds()
    local diamonds = game:GetService("Players").LocalPlayer.PlayerGui.MainLeft.Left.Currency.Diamonds
    local diamonds2 = diamonds:Clone()
    diamonds2.Name = "Diamonds2"
    diamonds2.Parent = diamonds.Parent
    diamonds2.Position = UDim2.new(0, 0, 0, 100)  -- Adjust the position as needed

    return diamonds2
end

local diamonds2 = CloneDiamonds()
game:GetService("Players").LocalPlayer.PlayerGui.MainLeft.Left.Currency.Diamonds2.Diamonds.Amount.Text = "0"

local function GetCurrentTime()
    return os.time()
end

local function CalculateDifference(initialBalance)
    local currentTime = GetCurrentTime()
    
    while GetCurrentTime() - currentTime < 60 do
        task.wait(1)
    end
    
    local newBalance = GetDiamonds()
    local difference = newBalance - initialBalance
    
    return difference
end

local initialBalance = GetDiamonds()
print("Initial Diamonds balance:", initialBalance)

spawn(function()
    local megatable = {}
    local imaginaryi = 1
    local ptime = 0
    local last = tick()
    local now = last
    local TICK_TIME = 0.5
    
    while true do
        if ptime >= TICK_TIME then
            while ptime >= TICK_TIME do ptime = ptime - TICK_TIME end
            local currentbal = GetDiamonds()
            megatable[imaginaryi] = currentbal
            local diffy = currentbal - (megatable[imaginaryi - 120] or megatable[1])
            imaginaryi = imaginaryi + 1
            
            local formattedDiffy = FormatNumber(diffy)
            game:GetService("Players").LocalPlayer.PlayerGui.MainLeft.Left.Currency.Diamonds2.Diamonds.Amount.Text = tostring(formattedDiffy .. " in 60s")
        end
        
        task.wait()
        now = tick()
        ptime = ptime + (now - last)
        last = now
    end
end)
