local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MF = Instance.new("Frame", ScreenGui)
MF.Size, MF.Position = UDim2.new(0, 350, 0, 420), UDim2.new(0.5, -175, 0.5, -210)
MF.BackgroundColor3, MF.Active, MF.Draggable = Color3.fromRGB(25, 20, 35), true, true
MF.ClipsDescendants = true
Instance.new("UICorner", MF)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size, OpenBtn.Position = UDim2.new(0, 80, 0, 30), UDim2.new(0, 10, 0, 10)
OpenBtn.BackgroundColor3, OpenBtn.Text, OpenBtn.Visible = Color3.fromRGB(150, 100, 255), "OPEN", false
OpenBtn.TextColor3, OpenBtn.Font = Color3.new(1,1,1), "GothamBold"
Instance.new("UICorner", OpenBtn)

local CloseBtn = Instance.new("TextButton", MF)
CloseBtn.Size, CloseBtn.Position = UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency, CloseBtn.Text, CloseBtn.TextColor3 = 1, "X", Color3.new(1,0,0)
CloseBtn.Font, CloseBtn.TextSize = "GothamBold", 18

local MiniBtn = Instance.new("TextButton", MF)
MiniBtn.Size, MiniBtn.Position = UDim2.new(0, 30, 0, 30), UDim2.new(1, -65, 0, 5)
MiniBtn.BackgroundTransparency, MiniBtn.Text, MiniBtn.TextColor3 = 1, "-", Color3.new(1,1,1)
MiniBtn.Font, MiniBtn.TextSize = "GothamBold", 22

local Title = Instance.new("TextLabel", MF)
Title.Size, Title.Position = UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 5)
Title.Text = "<font color='#D680FF'>POKAYHUB</font> | WEBHOOK"
Title.RichText, Title.BackgroundTransparency, Title.TextColor3 = true, 1, Color3.new(1,1,1)
Title.Font, Title.TextSize = "GothamBlack", 16

local function CreateBox(pos, ph, clear)
    local tb = Instance.new("TextBox", MF)
    tb.Size, tb.Position = UDim2.new(0.85, 0, 0, 35), UDim2.new(0.075, 0, pos, 0)
    tb.BackgroundColor3, tb.PlaceholderText, tb.Text, tb.TextColor3 = Color3.fromRGB(35, 30, 50), ph, "", Color3.new(1,1,1)
    tb.ClipsDescendants = true
    tb.TextTruncate = Enum.TextTruncate.AtEnd
    tb.ClearTextOnFocus = clear
    Instance.new("UICorner", tb)
    return tb
end

local WebhookURL = CreateBox(0.13, "Paste Webhook URL Here", true)
local SenderName = CreateBox(0.25, "Nama Pengirim", false)
local MessageText = CreateBox(0.37, "Isi Pesan", false)
local AmountBox  = CreateBox(0.49, "Jumlah Kirim", false)

-- ================================================================
-- SECTION: Pilihan Hapus Webhook
-- ================================================================
local OptionLabel = Instance.new("TextLabel", MF)
OptionLabel.Size, OptionLabel.Position = UDim2.new(0.85, 0, 0, 18), UDim2.new(0.075, 0, 0.635, 0)
OptionLabel.BackgroundTransparency = 1
OptionLabel.Text = "Pilihan Webhook Setelah Kirim:"
OptionLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
OptionLabel.Font = "GothamBold"
OptionLabel.TextSize = 11
OptionLabel.TextXAlignment = Enum.TextXAlignment.Left

-- State pilihan: 1 = hapus setelah kirim, 2 = jangan hapus, 3 = hapus langsung
local selectedOption = 1

local optionDefs = {
    {label = "🗑 Hapus setelah kirim",         color = Color3.fromRGB(220, 80, 80)},
    {label = "✅ Jangan hapus setelah kirim",  color = Color3.fromRGB(60, 180, 100)},
    {label = "⚡ Hapus langsung (tanpa kirim)", color = Color3.fromRGB(200, 130, 30)},
}

local optionBtns = {}
local BTN_H = 0.078
local BTN_START = 0.675

for i, def in ipairs(optionDefs) do
    local yPos = BTN_START + (i - 1) * (BTN_H + 0.01)
    local btn = Instance.new("TextButton", MF)
    btn.Size     = UDim2.new(0.85, 0, 0, 28)
    btn.Position = UDim2.new(0.075, 0, yPos, 0)
    btn.BackgroundColor3 = (i == 1) and def.color or Color3.fromRGB(45, 38, 62)
    btn.Text      = def.label
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font       = "GothamBold"
    btn.TextSize   = 11
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn)

    -- Stroke untuk highlight aktif
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = (i == 1) and 1.5 or 0
    stroke.Color = def.color

    optionBtns[i] = {btn=btn, stroke=stroke, def=def}

    btn.MouseButton1Click:Connect(function()
        selectedOption = i
        -- Update visual semua tombol
        for j, ob in ipairs(optionBtns) do
            if j == selectedOption then
                ob.btn.BackgroundColor3 = ob.def.color
                ob.stroke.Thickness = 1.5
                ob.stroke.Color = ob.def.color
            else
                ob.btn.BackgroundColor3 = Color3.fromRGB(45, 38, 62)
                ob.stroke.Thickness = 0
            end
        end
    end)
end

-- ================================================================
-- SEND BUTTON
-- ================================================================
local SendBtn = Instance.new("TextButton", MF)
SendBtn.Size, SendBtn.Position = UDim2.new(0.85, 0, 0, 36), UDim2.new(0.075, 0, 0.915, 0)
SendBtn.BackgroundColor3, SendBtn.Text, SendBtn.TextColor3 = Color3.fromRGB(150, 100, 255), "SEND TO WEBHOOK", Color3.new(1,1,1)
SendBtn.Font, SendBtn.TextSize = "GothamBlack", 14
Instance.new("UICorner", SendBtn)

-- ================================================================
-- BUTTON LOGIC
-- ================================================================
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
MiniBtn.MouseButton1Click:Connect(function() MF.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MF.Visible = true; OpenBtn.Visible = false end)

local function deleteWebhook(url)
    pcall(function()
        local req = (syn and syn.request) or http_request or request or (http and http.request)
        req({ Url = url, Method = "DELETE", Headers = {["Content-Type"] = "application/json"}, Body = "" })
    end)
end

SendBtn.MouseButton1Click:Connect(function()
    local URL  = WebhookURL.Text
    local Name = SenderName.Text
    local Msg  = MessageText.Text
    local Amt  = tonumber(AmountBox.Text) or 1

    -- ── Opsi 3: Hapus langsung tanpa kirim ──
    if selectedOption == 3 then
        if URL == "" then
            SendBtn.Text = "MASUKKAN URL DULU!"
            task.wait(1.5)
            SendBtn.Text = "SEND TO WEBHOOK"
            return
        end
        SendBtn.BackgroundColor3 = Color3.fromRGB(200, 130, 30)
        SendBtn.Text = "MENGHAPUS..."
        deleteWebhook(URL)
        WebhookURL.Text = ""
        task.wait(0.8)
        SendBtn.Text = "WEBHOOK DIHAPUS!"
        task.wait(1.5)
        SendBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
        SendBtn.Text = "SEND TO WEBHOOK"
        return
    end

    -- ── Opsi 1 & 2: Kirim pesan dulu ──
    if URL == "" or Msg == "" or Name == "" then
        SendBtn.Text = "LENGKAPI DATA!"
        task.wait(1.5)
        SendBtn.Text = "SEND TO WEBHOOK"
        return
    end

    SendBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 140)

    for i = 1, Amt do
        SendBtn.Text = "SENDING " .. i .. "/" .. Amt
        pcall(function()
            local req = (syn and syn.request) or http_request or request or (http and http.request)
            req({
                Url = URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = game:GetService("HttpService"):JSONEncode({["username"] = Name, ["content"] = Msg})
            })
        end)
        task.wait(0.3)
    end

    -- ── Opsi 1: Hapus webhook setelah selesai kirim ──
    if selectedOption == 1 then
        SendBtn.Text = "MENGHAPUS WEBHOOK..."
        SendBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
        deleteWebhook(URL)
        WebhookURL.Text = ""
        task.wait(0.8)
        SendBtn.Text = "SELESAI + WEBHOOK DIHAPUS"
    else
        -- ── Opsi 2: Jangan hapus ──
        SendBtn.Text = "FINISHED (" .. Amt .. ")"
    end

    task.wait(2)
    SendBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    SendBtn.Text = "SEND TO WEBHOOK"
end)
