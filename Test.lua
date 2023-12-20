task.wait(15)
getgenv().config = {
	placeId = 8737899170,
	eventName = "Gingerbread",
	servers = {
		count = 100,
		sort = "Desc",
		pageDeep = math.random(2, 6)
	},
	delays = {
		beforeExecute = 0.3,
		beforeBreak = 1.5,
		afterBreak = 2.4,
		hit = 0.03,
		lootbag = 0.03,
		beforeTp = 2,
		whileError = 10
	}
}
if not getgenv().config then
	getgenv().config = {
		placeId = 8737899170,
		eventName = "Gingerbread",
		servers = {
			count = 100,
			sort = "Asc",
			pageDeep = math.random(2, 6)
		},
		delays = {
			beforeExecute = 0.3,
			beforeBreak = 1.5,
			afterBreak = 2.4,
			hit = 0.03,
			lootbag = 0.03,
			beforeTp = 2,
			whileError = 10
		}
	}
end;
repeat
	task.wait()
until game.PlaceId ~= nil;
if not game:IsLoaded() then
	game.Loaded:Wait()
end;
local a = game:GetService("ReplicatedStorage")
local b = game:GetService("HttpService")
local c = game:GetService("Players")
local d = game:GetService("TeleportService")
task.wait(config.delays.beforeExecute)
if game.PlaceId ~= config.placeId then
	print("Gingerbread hunter unloaded, unknown place.")
	return
end;
local a = require(a:WaitForChild("Library", 2000))
if not a.Loaded then
	repeat
		task.wait()
	until a.Loaded ~= false
end;
local e = a.RandomEventCmds;
local f = c.LocalPlayer;
local f = f.Character;
local g = f:WaitForChild("Humanoid", 1000)
local f = f:WaitForChild("HumanoidRootPart", 1000)
print(b:JSONEncode(config))
function tpToPos(a)
	f.CFrame = CFrame.new(a)
end;
function jumpToServer()
	local a = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true"
	local e = request({
		Url = string.format(a, config.placeId, config.servers.sort, config.servers.count)
	})
	local f = b:JSONDecode(e.Body)
	if config.servers.pageDeep > 1 then
		for c = 1, config.servers.pageDeep, 1 do
			e = request({
				Url = string.format(a .. "&cursor=" .. f.nextPageCursor, config.placeId, config.servers.sort, config.servers.count)
			})
			f = b:JSONDecode(e.Body)
			task.wait(0.1)
		end
	end;
	local a = {}
	if f and f.data then
		for b, b in next, f.data do
			if type(b) == "table" then
				table.insert(a, 1, b.id)
			end
		end
	end;
	local b = # a;
	if not b then
		b = 2
	end;
	d:TeleportToPlaceInstance(config.placeId, a[math.random(1, b)], c.LocalPlayer)
end;
a.Alert.Message("Finding Gingerbread...")
local b = e.GetActive() or e.GetActive()
local c = false;
task.wait(config.delays.beforeExecute)
for a, a in b do
	if a.name == config.eventName then
		c = true;
		tpToPos(a.origin + Vector3.new(0, 18, 0))
	end
end;
a.Things:FindFirstChild("Lootbags").ChildAdded:Connect(function(a)
	task.wait()
	if a then
		game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Lootbags_Claim"):FireServer(unpack({
			[1] = {
				[1] = a.Name
			}
		}))
	end
end)
function CollectAllLootbags()
	pcall(function()
		for a, a in pairs(a.Things:FindFirstChild("Lootbags"):GetChildren()) do
			if a and not a:GetAttribute("Collected") then
				game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Lootbags_Claim"):FireServer(unpack({
					[1] = {
						[1] = a.Name
					}
				}))
				task.wait(config.delays.lootbag)
			end
		end
	end)
end;
function findGingerbread()
	for a, a in a.Things.Breakables:GetChildren() do
		if a.ClassName == "Model" and a:GetAttribute("BreakableID") == config.eventName then
			return a
		end
	end
end;
if c then
	a.Alert.Message("Gingerbread exist!")
	task.wait(config.delays.beforeBreak)
	local b = nil;
	for a = 1, 5, 1 do
		b = findGingerbread()
		if b then
			tpToPos(b.PrimaryPart.Position + Vector3.new(0, 18, 0))
			break
		else
			task.wait(0.5)
		end
	end;
	if b then
		a.Alert.Message("Start breaking!")
		while a.Things.Breakables:FindFirstChild(b.Name) do
			local a = {
				[1] = b.Name
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Breakables_PlayerDealDamage"):FireServer(unpack(a))
			task.wait(config.delays.hit)
		end;
		a.Alert.Message("Broke!")
		b = false
	end;
	CollectAllLootbags()
	task.wait(config.delays.afterBreak)
	CollectAllLootbags()
	task.wait(config.delays.afterBreak)
else
	a.Alert.Message("Gingerbread not found :c")
end;
d.TeleportInitFailed:Connect(function(b, c, d)
	print(string.format("server: teleport %s failed, resultEnum:%s, msg:%s", b.Name, tostring(c), d))
	config.servers.pageDeep += 1;
	a.Alert.Message("Tp Retry... :" .. d)
	task.wait(config.delays.whileError)
	jumpToServer()
end)
task.wait(config.delays.beforeTp)
a.Alert.Message("Tp to another server...")
jumpToServer()
