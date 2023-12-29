-- Configuration
getgenv().Config = {
    ["Discord"] = {
        webhookUrl = "https://discord.com/api/webhooks/1187515692489121933/UX26bntG_oMrQIY5Xv4haUbPDZ53piXp3_CX3OL0xJOoe9pv8WNxIZQJ_wNiRjP78Why",
        username = "Webhook Bot",
        avatarUrl = "https://media.discordapp.net/attachments/1185962685335081000/1189319692742033558/jnSDc0gF8R4i9WbbLUVqMeWecVsyYROyaTTXqSTEfaPKWCf2uCp0vQPtlg2kcun6.png?ex=659dbb47&is=658b4647&hm=12721c6e107c415723b571a9a9b1cbc0ca197a7d3b0cf8412057a6b5feb32f7e&=&format=webp&quality=lossless&width=846&height=905",
        color = "16711680",
    }
}

-- Function to send a webhook with advanced error handling
local function sendWebhook(message, fields)
    local data = {
        username = getgenv().Config.Discord.username,
        avatar_url = getgenv().Config.Discord.avatarUrl,
        embeds = {{
            color = tonumber(getgenv().Config.Discord.color, 16),
            description = message,
            fields = fields,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local headers = {
        ["Content-Type"] = "application/json"
    }

    local success, response = pcall(function()
        return game:GetService("HttpService"):PostAsync(getgenv().Config.Discord.webhookUrl, game:GetService("HttpService"):JSONEncode(data), Enum.HttpContentType.ApplicationJson, false, headers)
    end)

    if success then
        if response and response.StatusCode == 200 then
            print("Webhook sent successfully.")
            print(response)
        else
            warn("Failed to send webhook. Unexpected response:")
            warn(response)
        end
    else
        warn("Failed to send webhook. Error message:")
        warn(response)

        local errorMessage = tostring(response)
        local lineNumber = errorMessage:match(":(%d+):")
        
        if lineNumber then
            lineNumber = tonumber(lineNumber)
            local scriptName = getfenv(2).script.Name
            warn("Error occurred in script:", scriptName)
            warn("Error line number:", lineNumber)
        end
    end
end

-- Example usage
local message = "Hello, this is a webhook message!"
local webhookFields = {
    {name = "Field 1", value = "Value 1", inline = false},
    {name = "Field 2", value = "Value 2", inline = true}
}

sendWebhook(message, webhookFields)
