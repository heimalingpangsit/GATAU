-- ================================================================
--   MARV SCRIPT RECORDER v5  +  JEPIN RECORD SYSTEM
--   Fix: save bug, no popup after stop, auto-discard old recording,
--        modern UI responsive PC+HP, merge urut checkpoint_1..N,
--        ⚡=merge, tengah=refresh, kanan=upload all
--   ADDED: JEPIN Recording Engine (60FPS, Rollback, BypassTime)
-- ================================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local hrp       = character:WaitForChild("HumanoidRootPart")

-- ================================================================
-- CONFIG
-- ================================================================
local GH_TOKEN        = "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"
local GH_USER         = "heimalingpangsit"
local GH_REPO         = "GATAU"
local GH_FOLDER_PUB   = "wiwokdetok"
local GH_FOLDER_PRIV  = "private"
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1444181677776703599/PuGIc7X3DvVDqFW9fFCTI1Yj46Tp6b8ZKZfDnVH2ycaX6EG2gPCEO11Dybn3Nqiz2UzR"
local OWNER_NAMES     = {["hasimkipui"]=true}
local ADMIN_NAMES     = {["jrkigacor420"]=true,["tes123"]=true}
local RobloxUsername  = player.Name
local SAVE_FOLDER     = "PokayRecorder"

-- ================================================================
-- JEPIN RECORD CONFIG (ditambahkan dari JEPINRecorder)
-- ================================================================
local RECORD_HZ              = 60      -- 60 FPS
local ROLLBACK_SECS          = 3       -- detik rollback per tekan
local MIN_DISTANCE_THRESHOLD = 0.008   -- threshold minimum jarak antar frame (saat recording)
local JUMP_VELOCITY_THRESHOLD = 10     -- threshold velocity Y untuk deteksi lompat

-- ================================================================
-- ROLES
-- ================================================================
local function isOwnerOrAdmin() return OWNER_NAMES[RobloxUsername] or ADMIN_NAMES[RobloxUsername] end
local function getRoleLabel()
    if OWNER_NAMES[RobloxUsername] then return "👑 Owner"
    elseif ADMIN_NAMES[RobloxUsername] then return "🛡 Admin"
    else return "👤 User" end
end

-- ================================================================
-- BASE64
-- ================================================================
local B64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function toBase64(s)
    local r,n={},#s
    for i=1,n,3 do
        local a,b,c=s:byte(i),s:byte(i+1) or 0,s:byte(i+2) or 0
        local v=a*65536+b*256+c
        r[#r+1]=B64:sub(math.floor(v/262144)%64+1,math.floor(v/262144)%64+1)
        r[#r+1]=B64:sub(math.floor(v/4096)%64+1,math.floor(v/4096)%64+1)
        r[#r+1]=(i+1<=n) and B64:sub(math.floor(v/64)%64+1,math.floor(v/64)%64+1) or "="
        r[#r+1]=(i+2<=n) and B64:sub(v%64+1,v%64+1) or "="
    end
    return table.concat(r)
end

-- ================================================================
-- FOLDERS
-- ================================================================
local function ensureFolders()
    pcall(function()
        if not isfolder("PokayRecorder") then makefolder("PokayRecorder") end
        if not isfolder(SAVE_FOLDER) then makefolder(SAVE_FOLDER) end
    end)
end
ensureFolders()

-- ================================================================
-- RECORDER STATE  (JEPIN Engine — 60FPS)
-- ================================================================
local isRecording    = false
local recordedFrames = {}
local recordConn     = nil
local recordStart    = 0
local lastFrameTime  = 0
local frameInterval  = 1 / RECORD_HZ
local bypassEnabled  = true

-- ================================================================
-- PLAYBACK STATE
-- ================================================================
local isPlaying           = false
local playbackConnection  = nil
local accumulatedTime     = 0
local lastPlaybackTime    = 0
local heightOffset        = 0
local playbackSpeed       = 1.0
local currentFlipRotation = CFrame.new()

-- ================================================================
-- TOOL TRACKING STATE  ←  uwaw System
-- ================================================================
local currentToolName = nil

-- ================================================================
-- TP END STATE  ←  uwaw System
-- Diupdate setiap kali save → Nearest pakai ini untuk TP
-- ================================================================
local lastSavedPosition = nil   -- Vector3 posisi frame terakhir saat save
local lastSavedRotation = 0     -- Yaw rotation frame terakhir saat save

-- ================================================================
-- HELPERS
-- ================================================================
local function v3t(v)  return {x=v.X,y=v.Y,z=v.Z} end
local function tv3(t)  return Vector3.new(t.x or 0,t.y or 0,t.z or 0) end
local function lerp(a,b,t) return a+(b-a)*t end
local function lerpV(a,b,t) return Vector3.new(lerp(a.X,b.X,t),lerp(a.Y,b.Y,t),lerp(a.Z,b.Z,t)) end
local function lerpA(a,b,t)
    local d=b-a
    while d>math.pi do d=d-2*math.pi end
    while d<-math.pi do d=d+2*math.pi end
    return a+d*t
end

-- getCurrentTool: ambil nama tool yang sedang diequip (nil jika tidak ada)
local function getCurrentTool()
    local c=player.Character; if not c then return nil end
    local t=c:FindFirstChildOfClass("Tool")
    return t and t.Name or nil
end

-- UpdateTool (uwaw system): equip/unequip tool dengan tracking agar tidak equip berulang
local function UpdateTool(char, toolName)
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local currentTool=char:FindFirstChildOfClass("Tool")
    if toolName then
        -- sudah equip tool yang sama, skip
        if currentTool and currentTool.Name==toolName then return end
        -- unequip dulu kalau ada tool lain
        if currentTool then hum:UnequipTools() end
        -- equip dari backpack
        local bp=player:FindFirstChildOfClass("Backpack")
        if bp then
            local newTool=bp:FindFirstChild(toolName)
            if newTool then hum:EquipTool(newTool) end
        end
    else
        -- toolName nil = unequip semua
        if currentTool then hum:UnequipTools() end
    end
end

local function getStateStr(hm)
    local m={
        [Enum.HumanoidStateType.Running]="Running",
        [Enum.HumanoidStateType.Jumping]="Jumping",
        [Enum.HumanoidStateType.Freefall]="Freefall",
        [Enum.HumanoidStateType.Landed]="Landed",
        [Enum.HumanoidStateType.Climbing]="Climbing",
        [Enum.HumanoidStateType.Swimming]="Swimming",
        [Enum.HumanoidStateType.Dead]="Dead",
    }
    return m[hm:GetState()] or "Running"
end

-- ================================================================
-- AUTO-NAME
-- ================================================================
local function getNextCPName()
    local hi=0
    pcall(function()
        for _,p in ipairs(listfiles(SAVE_FOLDER)) do
            local n=tostring(p):match("checkpoint_(%d+)%.json$")
            if n then local v=tonumber(n) or 0; if v>hi then hi=v end end
        end
    end)
    return "checkpoint_"..(hi+1)..".json"
end

-- ================================================================
-- SCAN FILES
-- ================================================================
local function scanFiles(filter)
    local r={}
    pcall(function()
        for _,p in ipairs(listfiles(SAVE_FOLDER)) do
            local name=tostring(p):match("([^/\\]+)$") or p
            if name:match("%.json$") then
                if not filter or filter=="" or name:lower():find(filter:lower(),1,true) then
                    table.insert(r,{name=name,path=p})
                end
            end
        end
    end)
    table.sort(r,function(a,b) return a.name<b.name end)
    return r
end

-- ================================================================
-- REBUILD TIMESTAMPS  ←  Pakai walkSpeed asli tiap frame
--
-- Masalah lama:
--   - applyBypass: buang frame diam tapi rebuild timestamp pakai
--     interval tetap → kalau speed tinggi (coil) jadi pelan.
--   - normalizeSpeed: hitung domSpeed dari histogram → tidak akurat
--     kalau walkSpeed berubah-ubah (coil on/off). Hasil dist/domSpeed
--     bisa bikin timestamp terlalu rapat (dash) atau terlalu lebar (pelan).
--
-- Solusi: tiap frame sudah punya frame.walkSpeed (direkam langsung dari
-- hm.WalkSpeed). Timestamp baru = dist / walkSpeed frame itu sendiri.
-- Ini 100% akurat untuk kecepatan berapa pun, coil atau tidak.
--
-- Special state (jump/freefall/climb/swim) & teleport → pakai origDt
-- karena fisikanya tidak linier dengan walkSpeed.
-- ================================================================
local function rebuildTimestamps(frames)
    if not frames or #frames < 2 then return frames end

    local DEFAULT_SPEED = 16
    local LARGE_GAP     = 100    -- >100 studs = teleport, pakai timing asli
    local MIN_DIST      = 0.05   -- gerak minimum agar timestamp diubah
    local MIN_DT        = 0.0001

    local function isSpecial(state)
        return state=="Jumping" or state=="Freefall"
            or state=="Climbing" or state=="Swimming"
    end
    local function toV3s(t)
        if typeof(t)=="Vector3" then return t end
        return Vector3.new(t.x or 0, t.y or 0, t.z or 0)
    end

    local result  = {}
    local newTime = 0

    for i, f in ipairs(frames) do
        local nf = {}
        for k,v in pairs(f) do nf[k]=v end

        if i == 1 then
            nf.time = 0
        else
            local prev   = frames[i-1]
            local posA   = toV3s(prev.position)
            local posB   = toV3s(f.position)
            local dist   = (posB - posA).Magnitude
            local origDt = math.max(f.time - prev.time, MIN_DT)
            local special = isSpecial(f.state) or isSpecial(prev.state)
            local addedTime

            if dist > LARGE_GAP then
                -- Teleport → pakai origDt supaya tidak skip
                addedTime = origDt
            elseif special then
                -- Fisika (lompat/jatuh/renang) → origDt
                addedTime = origDt
            elseif dist > MIN_DIST then
                -- Gerak normal → dist / walkSpeed frame ini
                -- walkSpeed direkam langsung dari hm.WalkSpeed saat recording
                -- → selalu akurat, coil atau tidak
                local ws = (f.walkSpeed and f.walkSpeed > 0) and f.walkSpeed
                           or (prev.walkSpeed and prev.walkSpeed > 0) and prev.walkSpeed
                           or DEFAULT_SPEED
                addedTime = dist / ws
            else
                -- Micro-movement / hampir diam → tetap kecil
                addedTime = origDt
            end

            newTime  = newTime + addedTime
            nf.time  = newTime

            -- Rebuild velocity konsisten dengan timestamp baru
            local prevNf = result[i-1]
            if prevNf and dist > MIN_DIST and dist <= LARGE_GAP then
                local dtNew = nf.time - prevNf.time
                if dtNew > MIN_DT then
                    local v = (posB - posA).Unit * (dist / dtNew)
                    nf.velocity = {x=v.X, y=v.Y, z=v.Z}
                end
            end
        end

        table.insert(result, nf)
    end

    return result
end

-- ================================================================
-- FIND SURROUNDING FRAMES
-- ================================================================
local function findFrames(data,t)
    if #data==0 then return nil,nil,0 end
    if t<=data[1].time then return 1,1,0 end
    if t>=data[#data].time then return #data,#data,0 end
    local l,r=1,#data
    while l<r-1 do
        local m=math.floor((l+r)/2)
        if data[m].time<=t then l=m else r=m end
    end
    local span=data[r].time-data[l].time
    local alpha=span>0 and math.clamp((t-data[l].time)/span,0,1) or 0
    return l,r,alpha
end

-- ================================================================
-- STOP PLAYBACK
-- ================================================================
local function stopPlayback()
    isPlaying=false; heightOffset=0
    currentFlipRotation=CFrame.new(); currentToolName=nil
    -- accumulatedTime & lastPlaybackTime tidak dipakai lagi (diganti absolute tick)
    accumulatedTime=0; lastPlaybackTime=0
    if playbackConnection then playbackConnection:Disconnect(); playbackConnection=nil end
    pcall(function()
        local c2=player.Character; if not c2 then return end
        local hm=c2:FindFirstChildOfClass("Humanoid"); if not hm then return end
        hm:Move(Vector3.new(0,0,0),false)
        if hm:GetState()~=Enum.HumanoidStateType.Running then
            hm:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

-- ================================================================
-- START PLAYBACK  ←  Capped-DT (Anti-Dash)
--
-- FIX: tick() absolut bikin karakter dash kalau ada lag spike —
--   posisi langsung loncat ke mana "seharusnya" di waktu itu.
-- SOLUSI: akumulasi dt dengan cap 0.05s per frame.
--   Lag spike → max geser 50ms per frame, tidak pernah numpuk.
-- ================================================================
local function startPlayback(data, onComplete)
    if not data or #data==0 then if onComplete then onComplete() end; return end
    if isPlaying then stopPlayback() end
    local c2=player.Character; if not c2 then return end
    local hm=c2:FindFirstChildOfClass("Humanoid")
    local hrp2=c2:FindFirstChild("HumanoidRootPart")
    if not hm or not hrp2 then return end

    local curHip=hm.HipHeight
    local recHip=data[1].hipHeight or curHip
    heightOffset=curHip-recHip

    local f1=data[1]
    local sp=tv3(f1.position)
    hrp2.CFrame=CFrame.new(sp.X,sp.Y+heightOffset,sp.Z)*CFrame.Angles(0,f1.rotation or 0,0)
    hrp2.AssemblyLinearVelocity=Vector3.new(0,0,0)
    hrp2.AssemblyAngularVelocity=Vector3.new(0,0,0)

    isPlaying=true
    currentToolName=nil

    -- ── FIX DASH: akumulasi dt dengan cap per frame ──
    -- tick() absolut bikin karakter dash kalau ada lag spike sesaat
    -- Cap 0.05s = max 50ms per frame → lag spike tidak menumpuk
    local playbackTime = 0
    local MAX_DT       = 0.05
    local totalDur     = data[#data].time
    local lastJumping  = false

    playbackConnection=RunService.Heartbeat:Connect(function(dt)
        if not isPlaying then return end
        local c3=player.Character; if not c3 then return end
        local hrp3=c3:FindFirstChild("HumanoidRootPart")
        local hm3=c3:FindFirstChildOfClass("Humanoid")
        if not hrp3 or not hm3 then return end

        playbackTime = playbackTime + math.min(dt, MAX_DT) * playbackSpeed

        if playbackTime >= totalDur then
            stopPlayback(); if onComplete then onComplete() end; return
        end

        local i0,i1,alpha=findFrames(data, playbackTime)
        local f0,f1b=data[i0],data[i1]
        if not f0 or not f1b then return end

        local pos0=tv3(f0.position)
        local pos1=tv3(f1b.position)
        local vel0=tv3(f0.velocity     or {x=0,y=0,z=0})
        local vel1=tv3(f1b.velocity    or {x=0,y=0,z=0})
        local mov0=tv3(f0.moveDirection or {x=0,y=0,z=0})
        local mov1=tv3(f1b.moveDirection or {x=0,y=0,z=0})

        local iPos=lerpV(pos0,pos1,alpha)
        local iVel=lerpV(vel0,vel1,alpha)
        local iMov=lerpV(mov0,mov1,alpha)
        local iYaw=lerpA(f0.rotation or 0, f1b.rotation or 0, alpha)

        -- Lerp CFrame: smooth tapi tidak tertinggal saat lag
        local lf=math.clamp(1-math.exp(-20*dt),0,1)
        local targetCF=CFrame.new(iPos.X,iPos.Y+heightOffset,iPos.Z)*CFrame.Angles(0,iYaw,0)
        hrp3.CFrame=hrp3.CFrame:Lerp(targetCF, lf)

        pcall(function() hrp3.AssemblyLinearVelocity=iVel end)
        pcall(function() hrp3.AssemblyAngularVelocity=Vector3.zero end)
        hm3:Move(iMov,false)

        -- Jump state
        local jumpNow=(f0.jumping or false) or (f1b.jumping or false)
        if jumpNow and not lastJumping then
            pcall(function() hm3:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
        lastJumping=jumpNow

        -- Tool system
        pcall(function()
            local c3char=player.Character; if not c3char then return end
            if f0.tool and f0.tool~=currentToolName then
                currentToolName=f0.tool
                UpdateTool(c3char, currentToolName)
            elseif not f0.tool and currentToolName then
                currentToolName=nil
                UpdateTool(c3char, nil)
            end
        end)
    end)
end

-- ================================================================
-- PLAY FILE (support sequential)
-- ================================================================
local function playFile(filePath, onDone)
    if not isfile(filePath) then if onDone then onDone() end; return end
    local ok,raw=pcall(function() return readfile(filePath) end)
    if not ok then if onDone then onDone() end; return end
    local okD,data=pcall(function() return HttpService:JSONDecode(raw) end)
    if not okD or type(data)~="table" or #data==0 then if onDone then onDone() end; return end
    local c2=player.Character; if not c2 then if onDone then onDone() end; return end
    local hrp2=c2:FindFirstChild("HumanoidRootPart")
    local hm2=c2:FindFirstChildOfClass("Humanoid")
    if not hrp2 or not hm2 then if onDone then onDone() end; return end
    local startPos=tv3(data[1].position)
    local dist=(hrp2.Position-startPos).Magnitude
    local function doPlay()
        character=player.Character or character
        if playbackConnection then playbackConnection:Disconnect(); playbackConnection=nil end
        isPlaying=false; accumulatedTime=0; lastPlaybackTime=0; heightOffset=0
        -- Teleport langsung ke posisi start sebelum play
        local c3=player.Character
        local hrp3=c3 and c3:FindFirstChild("HumanoidRootPart")
        if hrp3 then
            hrp3.CFrame=CFrame.new(startPos.X,startPos.Y,startPos.Z)*CFrame.Angles(0,data[1].rotation or 0,0)
            hrp3.AssemblyLinearVelocity=Vector3.new(0,0,0)
            hrp3.AssemblyAngularVelocity=Vector3.new(0,0,0)
        end
        startPlayback(data, function() if onDone then onDone() end end)
    end
    doPlay()
end

-- Putar semua checkpoint_N.json berurutan
local function playAllCheckpointsSeq(onAllDone)
    local cps={}
    pcall(function()
        for _,p in ipairs(listfiles(SAVE_FOLDER)) do
            local name=tostring(p):match("([^/\\]+)$") or p
            local n=name:match("^checkpoint_(%d+)%.json$")
            if n then table.insert(cps,{num=tonumber(n),path=p}) end
        end
    end)
    table.sort(cps,function(a,b) return a.num<b.num end)
    if #cps==0 then if onAllDone then onAllDone() end; return end
    local idx=0
    local function playNext()
        idx=idx+1
        if idx>#cps then
            if onAllDone then onAllDone() end; return
        end
        print(string.format("[REC] ▶ checkpoint_%d (%d/%d)",cps[idx].num,idx,#cps))
        playFile(cps[idx].path, playNext)
    end
    playNext()
end


-- ================================================================
-- ROLLBACK SYSTEM  ←  Persis dari uwaw MotionCore
--
-- Kunci uwaw: SATU variabel waktu (activeRecordTime) dipakai
-- oleh KEDUA heartbeat — rollback buffer DAN recording.
-- Buffer simpan {cframe, time=activeRecordTime}.
-- Rollback hapus frame dengan time > targetTime dari buffer.
-- Tidak ada desync karena tidak ada timer kedua.
-- ================================================================
local isRewinding         = false
local activeRecordTime    = 0      -- SATU sumber waktu, dibagi recording + buffer
local rollbackJustDone    = false
local rollbackHistoryBuffer = {}
local rollbackBufferConn  = nil
local ROLLBACK_INTERVAL   = 0.5   -- snapshot tiap 0.5 detik
local ROLLBACK_BUFFER_SIZE = 4    -- jumlah entry dibuang per rollback (uwaw: 4)
local MAX_BUFFER          = 240   -- max 240 entry

local function startRollbackBuffer()
    if rollbackBufferConn then rollbackBufferConn:Disconnect(); rollbackBufferConn=nil end
    rollbackHistoryBuffer = {}
    isRewinding = false
    -- Simpan snapshot awal
    local c2 = player.Character
    local h2 = c2 and c2:FindFirstChild("HumanoidRootPart")
    if h2 then
        table.insert(rollbackHistoryBuffer, {cframe=h2.CFrame, time=activeRecordTime})
    end
    local lastSnapshotTick = tick()
    rollbackBufferConn = RunService.Heartbeat:Connect(function()
        -- Guard: hanya jalan saat recording dan tidak sedang rewind
        if not isRecording or isRewinding then return end
        local now = tick()
        if (now - lastSnapshotTick) < ROLLBACK_INTERVAL then return end
        lastSnapshotTick = now
        local c3 = player.Character
        local h3 = c3 and c3:FindFirstChild("HumanoidRootPart")
        if not h3 then return end
        -- Simpan cframe + waktu recording SAAT INI (activeRecordTime)
        table.insert(rollbackHistoryBuffer, {cframe=h3.CFrame, time=activeRecordTime})
        if #rollbackHistoryBuffer > MAX_BUFFER then
            table.remove(rollbackHistoryBuffer, 1)
        end
    end)
end

local function stopRollbackBuffer()
    if rollbackBufferConn then rollbackBufferConn:Disconnect(); rollbackBufferConn=nil end
    rollbackHistoryBuffer = {}
    isRewinding = false
end

local function doRollback()
    if not isRecording then return 0 end
    if isRewinding then return 0 end
    if #rollbackHistoryBuffer <= ROLLBACK_BUFFER_SIZE then return 0 end

    isRewinding = true

    -- Buang ROLLBACK_BUFFER_SIZE entry terakhir (mundur ~2 detik)
    for _=1, ROLLBACK_BUFFER_SIZE do
        if #rollbackHistoryBuffer > 1 then
            table.remove(rollbackHistoryBuffer, #rollbackHistoryBuffer)
        end
    end

    local c2  = player.Character
    local hm2 = c2 and c2:FindFirstChildOfClass("Humanoid")
    local h2  = c2 and c2:FindFirstChild("HumanoidRootPart")
    if not c2 or not hm2 or not h2 then isRewinding=false; return 0 end

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {c2}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    -- Cari entry terbaru yang punya ground di bawahnya
    local foundEntry = nil
    while #rollbackHistoryBuffer > 1 and not foundEntry do
        local entry  = rollbackHistoryBuffer[#rollbackHistoryBuffer]
        local origin = entry.cframe.Position + Vector3.new(0, 2, 0)
        local hit    = workspace:Raycast(origin, Vector3.new(0, -(hm2.HipHeight + 5), 0), rayParams)
        if hit then
            foundEntry = entry
        else
            table.remove(rollbackHistoryBuffer, #rollbackHistoryBuffer)
        end
    end

    if not foundEntry then isRewinding=false; return 0 end

    local targetTime = foundEntry.time
    local _, yaw, _ = foundEntry.cframe:ToEulerAnglesYXZ()
    local hit = workspace:Raycast(
        foundEntry.cframe.Position + Vector3.new(0,2,0),
        Vector3.new(0, -(hm2.HipHeight+5), 0),
        rayParams
    )
    local landCF = CFrame.new(
        (hit and hit.Position or foundEntry.cframe.Position) + Vector3.new(0, hm2.HipHeight, 0)
    ) * CFrame.Angles(0, yaw, 0)

    -- Teleport dulu
    h2.CFrame = landCF
    h2.AssemblyLinearVelocity  = Vector3.new(0,0,0)
    h2.AssemblyAngularVelocity = Vector3.new(0,0,0)
    hm2:Move(Vector3.new(0,0,0), false)

    -- Set activeRecordTime ke targetTime SEBELUM hapus frame
    -- (uwaw: currentPlaybackTime = position322 SEBELUM hapus recordedPathData)
    activeRecordTime = targetTime

    -- Hapus semua frame SETELAH targetTime (persis seperti uwaw)
    local removed = 0
    for i=#recordedFrames, 2, -1 do
        if recordedFrames[i].time > targetTime then
            table.remove(recordedFrames, i)
            removed = removed + 1
        else
            break
        end
    end

    rollbackJustDone = true
    isRewinding = false
    return removed
end

-- ================================================================
-- RECORDING  ←  Distance-based Engine (seperti uwaw)
-- Rekam hanya saat karakter BERGERAK melebihi threshold jarak
-- ATAU state berubah (misal: mulai lompat, mulai diam, dll).
-- Hasilnya: file lebih kecil, tidak ada frame redundan saat diam,
-- dan tidak terikat FPS/lag — setiap frame yang direkam = bermakna.
-- ================================================================
local function startRecording()
    if isRecording then return end
    if isPlaying then stopPlayback() end
    character=player.Character or player.CharacterAdded:Wait()
    humanoid=character:WaitForChild("Humanoid")
    hrp=character:WaitForChild("HumanoidRootPart")

    recordedFrames={}
    recordStart=tick()
    isRecording=true
    activeRecordTime = 0
    rollbackJustDone = false

    startRollbackBuffer()

    local lastRecordedPos   = nil
    local lastRecordedState = nil
    local DIST_THRESHOLD    = 0.1

    recordConn=RunService.Heartbeat:Connect(function(dt)
        if not isRecording or isRewinding then return end
        local c2=player.Character; if not c2 then return end
        local h2=c2:FindFirstChild("HumanoidRootPart")
        local hm=c2:FindFirstChildOfClass("Humanoid")
        if not h2 or not hm then return end

        -- Update waktu — SAMA seperti uwaw: increment setiap heartbeat
        activeRecordTime = activeRecordTime + dt

        -- Setelah rollback: reset referensi posisi
        if rollbackJustDone then
            lastRecordedPos   = h2.Position
            lastRecordedState = getStateStr(hm)
            rollbackJustDone  = false
            return  -- skip frame ini, mulai fresh dari next heartbeat
        end

        local currentPos   = h2.Position
        local currentState = getStateStr(hm)

        local shouldRecord = false
        if lastRecordedPos == nil then
            shouldRecord = true
        else
            local moved       = (currentPos - lastRecordedPos).Magnitude > DIST_THRESHOLD
            local stateChange = currentState ~= lastRecordedState
            shouldRecord = moved or stateChange
        end
        if not shouldRecord then return end

        local tool  = getCurrentTool()
        local frame = {
            time          = activeRecordTime,
            position      = v3t(currentPos),
            velocity      = v3t(h2.AssemblyLinearVelocity),
            moveDirection = v3t(hm.MoveDirection),
            rotation      = select(2, h2.CFrame:ToEulerAnglesYXZ()),
            hipHeight     = hm.HipHeight,
            state         = currentState,
            walkSpeed     = hm.WalkSpeed,
            jumping       = hm:GetState()==Enum.HumanoidStateType.Jumping,
        }
        if tool then frame.tool = tool end
        table.insert(recordedFrames, frame)
        lastRecordedPos   = currentPos
        lastRecordedState = currentState
    end)
end

local function stopRecording()
    if not isRecording then return end
    isRecording=false
    if recordConn then recordConn:Disconnect(); recordConn=nil end
    stopRollbackBuffer()
end

-- ================================================================
-- TP END  ←  uwaw System
-- TP ke posisi frame terakhir yang DISAVE (bukan recordedFrames).
-- Pakai lastSavedPosition yang di-set saat saveRecording.
-- +2 Y offset seperti uwaw supaya tidak masuk lantai.
-- ================================================================
local function doTpEnd()
    if not lastSavedPosition then return false end
    local c2=player.Character; if not c2 then return false end
    local h2=c2:FindFirstChild("HumanoidRootPart"); if not h2 then return false end
    h2.CFrame = CFrame.new(lastSavedPosition + Vector3.new(0, 2, 0))
              * CFrame.Angles(0, lastSavedRotation, 0)
    h2.AssemblyLinearVelocity  = Vector3.new(0,0,0)
    h2.AssemblyAngularVelocity = Vector3.new(0,0,0)
    return true
end

-- ================================================================
-- SAVE  ←  applyBypass (JEPIN) dijalankan saat save
-- ================================================================
local function saveRecording(customName)
    if #recordedFrames==0 then return false,"Tidak ada frame!" end
    ensureFolders()
    local fname=(customName and customName~="") and customName or getNextCPName()
    if not fname:match("%.json$") then fname=fname..".json" end
    local processedFrames=rebuildTimestamps(recordedFrames)
    -- ── Track posisi akhir untuk TP END (uwaw system) ──
    local lf=processedFrames[#processedFrames]
    if lf and lf.position then
        lastSavedPosition = Vector3.new(lf.position.x, lf.position.y, lf.position.z)
        lastSavedRotation = lf.rotation or 0
    end
    local path=SAVE_FOLDER.."/"..fname
    local ok,err=pcall(function()
        writefile(path, HttpService:JSONEncode(processedFrames))
    end)
    if ok then
        return true, fname, path, #processedFrames
    else
        return false, tostring(err)
    end
end

-- ================================================================
-- MERGE: ambil semua checkpoint_1..checkpoint_N berurutan
-- ================================================================
local function mergeAllCheckpoints(outName)
    ensureFolders()
    local cps={}
    pcall(function()
        for _,p in ipairs(listfiles(SAVE_FOLDER)) do
            local name=tostring(p):match("([^/\\]+)$") or p
            local n=name:match("^checkpoint_(%d+)%.json$")
            if n then table.insert(cps,{num=tonumber(n),path=p,name=name}) end
        end
    end)
    table.sort(cps,function(a,b) return a.num<b.num end)
    if #cps<2 then return false,"Butuh min 2 checkpoint_N.json! Ditemukan: "..#cps end
    local merged={}; local offset=0; local lastT=0
    for idx,cp in ipairs(cps) do
        local ok,raw=pcall(function() return readfile(cp.path) end)
        if not ok then return false,"Gagal baca: "..cp.name end
        local okD,data=pcall(function() return HttpService:JSONDecode(raw) end)
        if not okD or type(data)~="table" then return false,"JSON invalid: "..cp.name end
        for _,f in ipairs(data) do
            if type(f)=="table" and f.time~=nil then
                local nf={}; for k,v in pairs(f) do nf[k]=v end
                nf.time=f.time+offset; table.insert(merged,nf); lastT=nf.time
            end
        end
        if idx<#cps then offset=lastT end
    end
    if #merged==0 then return false,"Tidak ada frame valid!" end
    local fname=(outName and outName~="") and outName or
        ("merged_cp1-"..cps[#cps].num..".json")
    if not fname:match("%.json$") then fname=fname..".json" end
    local path=SAVE_FOLDER.."/"..fname
    local okW,errW=pcall(function() writefile(path,HttpService:JSONEncode(merged)) end)
    if okW then
        return true,fname,path,#merged,#cps
    else
        return false,tostring(errW)
    end
end

-- ================================================================
-- UPLOAD GITHUB
-- ================================================================
local function uploadToGitHub(filePath, mapName, onDone)
    if not isfile(filePath) then if onDone then onDone(false,"File tidak ada!") end; return end
    local ok,raw=pcall(function() return readfile(filePath) end)
    if not ok then if onDone then onDone(false,"Gagal baca!") end; return end
    local pid=tostring(game.PlaceId)
    local ghFolder=isOwnerOrAdmin() and (GH_FOLDER_PUB.."/"..pid) or (GH_FOLDER_PRIV.."/"..pid)
    local filename=isOwnerOrAdmin() and (mapName..".json") or (RobloxUsername.."__"..mapName..".json")
    local apiUrl="https://api.github.com/repos/"..GH_USER.."/"..GH_REPO.."/contents/"..ghFolder.."/"..filename
    task.spawn(function()
        local sha=nil
        local okC,resC=pcall(function() return HttpService:RequestAsync({Url=apiUrl,Method="GET",
            Headers={["Authorization"]="token "..GH_TOKEN,["Accept"]="application/vnd.github.v3+json",["User-Agent"]="RobloxScript"}}) end)
        if okC and resC and resC.StatusCode==200 then
            local okP,p=pcall(function() return HttpService:JSONDecode(resC.Body) end)
            if okP and p and p.sha then sha=p.sha end
        end
        local payload={message="Upload: "..mapName.." | "..RobloxUsername,content=toBase64(raw),branch="main"}
        if sha then payload.sha=sha end
        local ok2,res2=pcall(function() return HttpService:RequestAsync({Url=apiUrl,Method="PUT",
            Headers={["Authorization"]="token "..GH_TOKEN,["Content-Type"]="application/json",
                     ["Accept"]="application/vnd.github.v3+json",["User-Agent"]="RobloxScript"},
            Body=HttpService:JSONEncode(payload)}) end)
        local success=ok2 and res2 and (res2.StatusCode==200 or res2.StatusCode==201)
        if success then
            pcall(function()
                local dt=os.date("*t")
                local tgl=string.format("%02d/%02d/%04d %02d:%02d",dt.day,dt.month,dt.year,dt.hour,dt.min)
                HttpService:RequestAsync({Url=DISCORD_WEBHOOK,Method="POST",
                    Headers={["Content-Type"]="application/json",["User-Agent"]="RobloxScript"},
                    Body=HttpService:JSONEncode({embeds={{title="📁 Map Diupload!",color=3896346,
                        fields={{name="📦 Map",value="`"..mapName.."`",inline=true},
                                {name="🎮 PlaceID",value="`"..pid.."`",inline=true},
                                {name="👤 By",value=getRoleLabel().." **"..RobloxUsername.."**",inline=false},
                                {name="📅 Waktu",value=tgl,inline=false}},
                        footer={text="POKAY RECORDER"}}}})})
            end)
        end
        if onDone then onDone(success,success and filename or ("HTTP "..tostring(res2 and res2.StatusCode or "?"))) end
    end)
end

-- ================================================================
-- BUILD UI
-- ================================================================
local function buildUI()
    pcall(function()
        local old=CoreGui:FindFirstChild("MarvRec5"); if old then old:Destroy() end
    end)

    local sg=Instance.new("ScreenGui")
    sg.Name="MarvRec5"; sg.ResetOnSpawn=false
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset=true; sg.Parent=CoreGui

    local vp=workspace.CurrentCamera.ViewportSize
    local isPhone=(vp.X<600)
    local WW = isPhone and math.min(vp.X-16, 310) or 400
    local WH = isPhone and math.min(vp.Y-50, 390) or 350
    local LW = isPhone and math.floor(WW*0.43) or 165

    local BG   = Color3.fromRGB(14,14,18)
    local PNL  = Color3.fromRGB(22,22,28)
    local ITEM = Color3.fromRGB(30,30,38)
    local HOV  = Color3.fromRGB(40,40,52)
    local RED  = Color3.fromRGB(220,45,55)
    local ORG  = Color3.fromRGB(225,138,22)
    local GRN  = Color3.fromRGB(38,175,95)
    local BLU  = Color3.fromRGB(55,118,230)
    local PUR  = Color3.fromRGB(140,65,215)
    local GRY  = Color3.fromRGB(52,52,62)
    local TXT  = Color3.fromRGB(230,230,235)
    local SUB  = Color3.fromRGB(120,120,138)
    local SEP  = Color3.fromRGB(38,38,50)

    local FS  = isPhone and 9 or 10
    local FS2 = isPhone and 10 or 11
    local BH  = isPhone and 26 or 28
    local IH  = isPhone and 22 or 24

    local function cr(inst,r)
        local c=Instance.new("UICorner",inst); c.CornerRadius=UDim.new(0,r or 8); return c
    end
    local function sk(inst,col,t)
        local s=Instance.new("UIStroke",inst); s.Color=col; s.Thickness=t or 1.5; return s
    end
    local function lpad(inst,l,r2,t2,b)
        local p=Instance.new("UIPadding",inst)
        p.PaddingLeft=UDim.new(0,l or 0); p.PaddingRight=UDim.new(0,r2 or 0)
        p.PaddingTop=UDim.new(0,t2 or 0); p.PaddingBottom=UDim.new(0,b or 0)
    end

    local win=Instance.new("Frame",sg)
    win.Name="Win"; win.Size=UDim2.new(0,WW,0,WH)
    win.Position=UDim2.new(0.5,-WW/2,0.5,-WH/2)
    win.BackgroundColor3=BG; win.BorderSizePixel=0; cr(win,12); sk(win,RED,1.5)

    local HDR_H=40
    local hdr=Instance.new("Frame",win)
    hdr.Size=UDim2.new(1,0,0,HDR_H); hdr.BackgroundColor3=RED; hdr.BorderSizePixel=0; cr(hdr,12)
    local hfix=Instance.new("Frame",hdr)
    hfix.Size=UDim2.new(1,0,0.5,0); hfix.Position=UDim2.new(0,0,0.5,0)
    hfix.BackgroundColor3=RED; hfix.BorderSizePixel=0

    local ibg=Instance.new("Frame",hdr); ibg.Size=UDim2.new(0,26,0,26)
    ibg.Position=UDim2.new(0,8,0.5,-13); ibg.BackgroundColor3=Color3.new(1,1,1)
    ibg.BorderSizePixel=0; cr(ibg,6)
    local il=Instance.new("TextLabel",ibg); il.Size=UDim2.new(1,0,1,0)
    il.BackgroundTransparency=1; il.Text="P"; il.Font=Enum.Font.GothamBold
    il.TextSize=13; il.TextColor3=RED

    local htl=Instance.new("TextLabel",hdr)
    htl.Size=UDim2.new(1,-95,1,0); htl.Position=UDim2.new(0,40,0,0)
    htl.BackgroundTransparency=1; htl.Text="Pokay Recorder"
    htl.Font=Enum.Font.GothamBold; htl.TextSize=12; htl.TextColor3=Color3.new(1,1,1)
    htl.TextXAlignment=Enum.TextXAlignment.Left

    local function hBtn(txt,xOff,bgCol)
        local b=Instance.new("TextButton",hdr); b.Size=UDim2.new(0,28,0,28)
        b.Position=UDim2.new(1,xOff,0.5,-14); b.BackgroundColor3=bgCol or Color3.fromRGB(255,255,255)
        b.BackgroundTransparency=bgCol and 0 or 0.85
        b.BorderSizePixel=0; b.Text=txt; b.Font=Enum.Font.GothamBold
        b.TextSize=13; b.TextColor3=Color3.new(1,1,1); b.AutoButtonColor=true; cr(b,6)
        return b
    end
    local btnClose=hBtn("✕",-36,RED)
    local btnMin  =hBtn("−",-70)

    local isMin=false
    btnMin.MouseButton1Click:Connect(function()
        isMin=not isMin; win.Size=isMin and UDim2.new(0,WW,0,HDR_H) or UDim2.new(0,WW,0,WH)
    end)
    btnClose.MouseButton1Click:Connect(function() sg:Destroy() end)

    local dg,ds,dp=false,nil,nil
    hdr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dg=true; ds=i.Position; dp=win.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dg=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            win.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)

    local body=Instance.new("Frame",win)
    body.Size=UDim2.new(1,0,1,-HDR_H); body.Position=UDim2.new(0,0,0,HDR_H)
    body.BackgroundTransparency=1; body.ClipsDescendants=true

    local div=Instance.new("Frame",body); div.Size=UDim2.new(0,1,1,-12)
    div.Position=UDim2.new(0,LW,0,6); div.BackgroundColor3=SEP; div.BorderSizePixel=0

    local lScr=Instance.new("ScrollingFrame",body)
    lScr.Size=UDim2.new(0,LW,1,0); lScr.BackgroundTransparency=1; lScr.BorderSizePixel=0
    lScr.ScrollBarThickness=2; lScr.ScrollBarImageColor3=RED
    lScr.CanvasSize=UDim2.new(0,0,0,0); lScr.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local lLL=Instance.new("UIListLayout",lScr); lLL.Padding=UDim.new(0,5)
    lLL.SortOrder=Enum.SortOrder.LayoutOrder; lpad(lScr,8,6,8,8)

    local rPnl=Instance.new("Frame",body)
    rPnl.Size=UDim2.new(1,-LW-2,1,0); rPnl.Position=UDim2.new(0,LW+2,0,0)
    rPnl.BackgroundTransparency=1

    -- ──────────────────────────────────────────────────────────
    -- LEFT SIDE
    -- ──────────────────────────────────────────────────────────
    local function secLbl(txt,order)
        local f=Instance.new("Frame",lScr); f.Size=UDim2.new(1,0,0,18)
        f.BackgroundTransparency=1; f.LayoutOrder=order
        local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,0,1,0)
        l.BackgroundTransparency=1; l.Text=txt; l.Font=Enum.Font.GothamBold
        l.TextSize=9; l.TextColor3=Color3.fromRGB(160,60,70)
        l.TextXAlignment=Enum.TextXAlignment.Left
        return f
    end
    local function divLine(order)
        local d=Instance.new("Frame",lScr); d.Size=UDim2.new(1,0,0,1)
        d.BackgroundColor3=SEP; d.BorderSizePixel=0; d.LayoutOrder=order; return d
    end
    local function mkBtn(txt,col,order,h)
        local b=Instance.new("TextButton",lScr); b.Size=UDim2.new(1,0,0,h or BH)
        b.BackgroundColor3=col; b.BorderSizePixel=0; b.Text=txt
        b.Font=Enum.Font.GothamBold; b.TextSize=FS2; b.TextColor3=Color3.new(1,1,1)
        b.AutoButtonColor=true; b.LayoutOrder=order; cr(b,8)
        local shine=Instance.new("Frame",b); shine.Size=UDim2.new(0.4,0,1,0)
        shine.BackgroundColor3=Color3.new(1,1,1); shine.BackgroundTransparency=0.92
        shine.BorderSizePixel=0; cr(shine,8)
        return b
    end
    local function mkInput(ph,order)
        local b=Instance.new("TextBox",lScr); b.Size=UDim2.new(1,0,0,IH)
        b.BackgroundColor3=ITEM; b.BorderSizePixel=0; b.Font=Enum.Font.Gotham
        b.TextSize=FS; b.TextColor3=TXT; b.PlaceholderText=ph; b.PlaceholderColor3=SUB
        b.Text=""; b.ClearTextOnFocus=false; b.LayoutOrder=order; cr(b,8)
        lpad(b,8,8,0,0); sk(b,SEP,1)
        return b
    end
    local function mkToggle(txt,val,order)
        local f=Instance.new("Frame",lScr); f.Size=UDim2.new(1,0,0,IH)
        f.BackgroundColor3=ITEM; f.BorderSizePixel=0; f.LayoutOrder=order; cr(f,8); sk(f,SEP,1)
        local l=Instance.new("TextLabel",f); l.Size=UDim2.new(0.7,0,1,0); l.Position=UDim2.new(0,8,0,0)
        l.BackgroundTransparency=1; l.Text=txt; l.Font=Enum.Font.Gotham
        l.TextSize=FS; l.TextColor3=TXT; l.TextXAlignment=Enum.TextXAlignment.Left
        local pill=Instance.new("Frame",f); pill.Size=UDim2.new(0,34,0,16)
        pill.Position=UDim2.new(1,-42,0.5,-8); pill.BorderSizePixel=0; cr(pill,8)
        local dot=Instance.new("Frame",pill); dot.Size=UDim2.new(0,12,0,12)
        dot.Position=UDim2.new(0,2,0.5,-6); dot.BorderSizePixel=0; cr(dot,6)
        local function rf(s)
            pill.BackgroundColor3=s and GRN or GRY
            dot.BackgroundColor3=Color3.new(1,1,1)
            dot.Position=s and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
        end
        rf(val)
        local hit=Instance.new("TextButton",f); hit.Size=UDim2.new(1,0,1,0)
        hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=5
        return f,hit,rf
    end
    local function mkRow2(order)
        local f=Instance.new("Frame",lScr); f.Size=UDim2.new(1,0,0,BH)
        f.BackgroundTransparency=1; f.LayoutOrder=order
        local lay=Instance.new("UIListLayout",f); lay.FillDirection=Enum.FillDirection.Horizontal
        lay.Padding=UDim.new(0,5); lay.VerticalAlignment=Enum.VerticalAlignment.Center
        return f
    end
    local function mkBtnInline(parent,txt,col,w)
        local b=Instance.new("TextButton",parent); b.Size=UDim2.new(0,w,1,0)
        b.BackgroundColor3=col; b.BorderSizePixel=0; b.Text=txt; b.Font=Enum.Font.GothamBold
        b.TextSize=FS; b.TextColor3=Color3.new(1,1,1); b.AutoButtonColor=true; cr(b,8)
        return b
    end

    -- STATUS BADGE
    local stBadge=Instance.new("Frame",lScr); stBadge.Size=UDim2.new(1,0,0,32)
    stBadge.BackgroundColor3=ITEM; stBadge.BorderSizePixel=0; stBadge.LayoutOrder=0; cr(stBadge,10); sk(stBadge,SEP,1)
    local statusLbl=Instance.new("TextLabel",stBadge); statusLbl.Size=UDim2.new(0.55,0,1,0); statusLbl.Position=UDim2.new(0,8,0,0)
    statusLbl.BackgroundTransparency=1; statusLbl.Text="⬤  READY"; statusLbl.Font=Enum.Font.GothamBold
    statusLbl.TextSize=FS2; statusLbl.TextColor3=GRN; statusLbl.TextXAlignment=Enum.TextXAlignment.Left
    local infoLbl=Instance.new("TextLabel",stBadge); infoLbl.Size=UDim2.new(0.45,-4,1,0); infoLbl.Position=UDim2.new(0.55,0,0,0)
    infoLbl.BackgroundTransparency=1; infoLbl.Text="0fr  0.0s"; infoLbl.Font=Enum.Font.Gotham
    infoLbl.TextSize=9; infoLbl.TextColor3=SUB; infoLbl.TextXAlignment=Enum.TextXAlignment.Right

    -- FPS + Rollback info badge (JEPIN)
    local fpsBadge=Instance.new("TextLabel",lScr); fpsBadge.Size=UDim2.new(1,0,0,14)
    fpsBadge.BackgroundTransparency=1
    fpsBadge.Text="🎬 "..RECORD_HZ.."FPS  ↩ Rollback "..ROLLBACK_SECS.."s"
    fpsBadge.Font=Enum.Font.Gotham; fpsBadge.TextSize=8; fpsBadge.TextColor3=PUR
    fpsBadge.TextXAlignment=Enum.TextXAlignment.Center; fpsBadge.LayoutOrder=1

    local toolLbl=Instance.new("TextLabel",lScr); toolLbl.Size=UDim2.new(1,0,0,14)
    toolLbl.BackgroundTransparency=1; toolLbl.Text="🔧 -"; toolLbl.Font=Enum.Font.Gotham
    toolLbl.TextSize=9; toolLbl.TextColor3=ORG; toolLbl.TextXAlignment=Enum.TextXAlignment.Center
    toolLbl.LayoutOrder=2

    divLine(3)
    secLbl("CONTROLS",4)

    local btnRecord  = mkBtn("⬤  CATATAN",  RED, 5, BH+4)
    local btnRollback= mkBtn("↩  ROLLBACK ("..ROLLBACK_SECS.."s)", ORG, 6, BH)  -- ← JEPIN

    local row1=mkRow2(7)
    local btnTpEnd   =mkBtnInline(row1,"📍 TP End",  BLU, math.floor((LW-21)/2))
    local btnNearest =mkBtnInline(row1,"🔍 Nearest", ORG, math.floor((LW-21)/2))

    divLine(8)
    secLbl("PLAYBACK",9)

    local spRow=mkRow2(10)
    local spLabel=Instance.new("TextLabel",spRow); spLabel.Size=UDim2.new(0,26,1,0)
    spLabel.BackgroundTransparency=1; spLabel.Text="Spd"; spLabel.Font=Enum.Font.Gotham
    spLabel.TextSize=9; spLabel.TextColor3=SUB
    local spBox=Instance.new("TextBox",spRow); spBox.Size=UDim2.new(0,40,0,IH-4)
    spBox.BackgroundColor3=ITEM; spBox.BorderSizePixel=0; spBox.Font=Enum.Font.Gotham
    spBox.TextSize=FS; spBox.TextColor3=TXT; spBox.Text="1.0"; spBox.ClearTextOnFocus=false; cr(spBox,7); lpad(spBox,5,0,0,0)
    sk(spBox,SEP,1)
    spBox:GetPropertyChangedSignal("Text"):Connect(function()
        local v=tonumber(spBox.Text); if v then playbackSpeed=math.clamp(v,0.1,10) end
    end)
    local loopPill=Instance.new("Frame",spRow); loopPill.Size=UDim2.new(0,50,0,IH-4)
    loopPill.BackgroundColor3=GRY; loopPill.BorderSizePixel=0; cr(loopPill,7)
    local loopTxt=Instance.new("TextLabel",loopPill); loopTxt.Size=UDim2.new(1,0,1,0)
    loopTxt.BackgroundTransparency=1; loopTxt.Text="🔁 OFF"; loopTxt.Font=Enum.Font.Gotham
    loopTxt.TextSize=9; loopTxt.TextColor3=SUB; loopTxt.TextXAlignment=Enum.TextXAlignment.Center
    local loopEnabled=false
    local loopBtn=Instance.new("TextButton",loopPill); loopBtn.Size=UDim2.new(1,0,1,0)
    loopBtn.BackgroundTransparency=1; loopBtn.Text=""; loopBtn.ZIndex=5
    loopBtn.MouseButton1Click:Connect(function()
        loopEnabled=not loopEnabled
        loopPill.BackgroundColor3=loopEnabled and GRN or GRY
        loopTxt.Text=loopEnabled and "🔁 ON" or "🔁 OFF"
        loopTxt.TextColor3=loopEnabled and Color3.new(1,1,1) or SUB
    end)

    divLine(11)
    secLbl("SIMPAN",12)
    local nameInput=mkInput("Nama (kosong = auto checkpoint_N)",13)
    local btnSave=mkBtn("💾  SIMPAN",GRN,14,BH)

    divLine(15)
    -- BYPASS TIME toggle (JEPIN)
    local _,bypassHit,bypassRf=mkToggle("✂ Bypass Time",bypassEnabled,16)
    bypassHit.MouseButton1Click:Connect(function()
        bypassEnabled=not bypassEnabled; bypassRf(bypassEnabled)
    end)

    local rollbackHint=Instance.new("TextLabel",lScr); rollbackHint.Size=UDim2.new(1,0,0,12)
    rollbackHint.BackgroundTransparency=1; rollbackHint.Text="F=Rec/Stop  R=Rollback  G=Save"
    rollbackHint.Font=Enum.Font.Gotham; rollbackHint.TextSize=8; rollbackHint.TextColor3=SUB
    rollbackHint.TextXAlignment=Enum.TextXAlignment.Center; rollbackHint.LayoutOrder=17

    -- ──────────────────────────────────────────────────────────
    -- RIGHT PANEL
    -- ──────────────────────────────────────────────────────────
    local rHdr=Instance.new("Frame",rPnl); rHdr.Size=UDim2.new(1,-4,0,36); rHdr.Position=UDim2.new(0,2,0,4)
    rHdr.BackgroundTransparency=1

    local cpTitle=Instance.new("TextLabel",rHdr); cpTitle.Size=UDim2.new(0.5,0,1,0); cpTitle.Position=UDim2.new(0,4,0,0)
    cpTitle.BackgroundTransparency=1; cpTitle.Text="CHECKPOINTS"
    cpTitle.Font=Enum.Font.GothamBold; cpTitle.TextSize=10; cpTitle.TextColor3=RED
    cpTitle.TextXAlignment=Enum.TextXAlignment.Left

    local function rIBtn(txt,col,xOff)
        local b=Instance.new("TextButton",rHdr); b.Size=UDim2.new(0,28,0,28)
        b.Position=UDim2.new(1,xOff,0.5,-14); b.BackgroundColor3=col; b.BorderSizePixel=0
        b.Text=txt; b.Font=Enum.Font.GothamBold; b.TextSize=14; b.TextColor3=Color3.new(1,1,1)
        b.AutoButtonColor=true; cr(b,7); return b
    end
    local btnMerge   = rIBtn("⚡",PUR,  -90)
    local btnRefresh = rIBtn("↻",GRY,  -56)
    local btnUpAll   = rIBtn("☁",BLU,  -22)

    local srch=Instance.new("TextBox",rPnl); srch.Size=UDim2.new(1,-8,0,IH)
    srch.Position=UDim2.new(0,4,0,42); srch.BackgroundColor3=ITEM; srch.BorderSizePixel=0
    srch.Font=Enum.Font.Gotham; srch.TextSize=FS; srch.TextColor3=TXT
    srch.PlaceholderText="🔍 Cari..."; srch.PlaceholderColor3=SUB
    srch.Text=""; srch.ClearTextOnFocus=false; cr(srch,8); sk(srch,SEP,1); lpad(srch,8,8,0,0)

    local cpScr=Instance.new("ScrollingFrame",rPnl)
    cpScr.Size=UDim2.new(1,-4,1,-74); cpScr.Position=UDim2.new(0,2,0,72)
    cpScr.BackgroundTransparency=1; cpScr.BorderSizePixel=0
    cpScr.ScrollBarThickness=2; cpScr.ScrollBarImageColor3=RED
    cpScr.CanvasSize=UDim2.new(0,0,0,0); cpScr.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local cpLL2=Instance.new("UIListLayout",cpScr); cpLL2.Padding=UDim.new(0,3)
    lpad(cpScr,0,0,2,4)

    local allRows={}
    local selNearestPath=nil
    local currentPlayBtn=nil

    local function refreshCPList(filter)
        for _,ch in ipairs(cpScr:GetChildren()) do
            if ch:IsA("Frame") or ch:IsA("TextLabel") then ch:Destroy() end
        end
        allRows={}
        local files=scanFiles(filter)
        if #files==0 then
            local el=Instance.new("TextLabel",cpScr); el.Size=UDim2.new(1,0,0,36)
            el.BackgroundTransparency=1; el.Text="Belum ada checkpoint"
            el.Font=Enum.Font.Gotham; el.TextSize=FS; el.TextColor3=SUB
            el.TextXAlignment=Enum.TextXAlignment.Center; return
        end
        for idx,f in ipairs(files) do
            local row=Instance.new("Frame",cpScr)
            row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=ITEM
            row.BorderSizePixel=0; row.LayoutOrder=idx; cr(row,8); sk(row,SEP,0.8)

            local pBtn=Instance.new("TextButton",row)
            pBtn.Size=UDim2.new(0,26,0,26); pBtn.Position=UDim2.new(0,4,0.5,-13)
            pBtn.BackgroundColor3=Color3.fromRGB(35,35,46); pBtn.BorderSizePixel=0
            pBtn.Text="▶"; pBtn.Font=Enum.Font.GothamBold; pBtn.TextSize=10
            pBtn.TextColor3=SUB; pBtn.AutoButtonColor=true; cr(pBtn,6)

            local nl=Instance.new("TextLabel",row)
            nl.Size=UDim2.new(1,-94,1,0); nl.Position=UDim2.new(0,34,0,0)
            nl.BackgroundTransparency=1; nl.Text=f.name:gsub("%.json$","")
            nl.Font=Enum.Font.Gotham; nl.TextSize=FS; nl.TextColor3=TXT
            nl.TextXAlignment=Enum.TextXAlignment.Left; nl.TextTruncate=Enum.TextTruncate.AtEnd

            local bUp=Instance.new("TextButton",row)
            bUp.Size=UDim2.new(0,26,0,24); bUp.Position=UDim2.new(1,-58,0.5,-12)
            bUp.BackgroundColor3=BLU; bUp.BorderSizePixel=0; bUp.Text="☁"
            bUp.Font=Enum.Font.GothamBold; bUp.TextSize=12; bUp.TextColor3=Color3.new(1,1,1)
            bUp.AutoButtonColor=true; cr(bUp,6)

            local bDel=Instance.new("TextButton",row)
            bDel.Size=UDim2.new(0,26,0,24); bDel.Position=UDim2.new(1,-28,0.5,-12)
            bDel.BackgroundColor3=RED; bDel.BorderSizePixel=0; bDel.Text="✕"
            bDel.Font=Enum.Font.GothamBold; bDel.TextSize=11; bDel.TextColor3=Color3.new(1,1,1)
            bDel.AutoButtonColor=true; cr(bDel,6)

            row.MouseEnter:Connect(function()
                if row.BackgroundColor3~=Color3.fromRGB(35,45,35) then row.BackgroundColor3=HOV end
            end)
            row.MouseLeave:Connect(function()
                if row.BackgroundColor3~=Color3.fromRGB(35,45,35) then row.BackgroundColor3=ITEM end
            end)

            local rowHit=Instance.new("TextButton",row)
            rowHit.Size=UDim2.new(1,-90,1,0); rowHit.Position=UDim2.new(0,34,0,0)
            rowHit.BackgroundTransparency=1; rowHit.Text=""; rowHit.ZIndex=5
            rowHit.MouseButton1Click:Connect(function()
                selNearestPath=f.path
                for _,r2 in ipairs(allRows) do
                    r2.row.BackgroundColor3=(r2.path==f.path) and Color3.fromRGB(35,40,55) or ITEM
                end
            end)

            pBtn.MouseButton1Click:Connect(function()
                if isPlaying then
                    stopPlayback()
                    pBtn.Text="▶"; pBtn.TextColor3=SUB
                    if currentPlayBtn==pBtn then currentPlayBtn=nil; return end
                end
                if currentPlayBtn then currentPlayBtn.Text="▶"; currentPlayBtn.TextColor3=SUB end
                pBtn.Text="⏹"; pBtn.TextColor3=RED; currentPlayBtn=pBtn
                local myNum=f.name:match("^checkpoint_(%d+)%.json$")
                if myNum then
                    local allCPs={}
                    pcall(function()
                        for _,p2 in ipairs(listfiles(SAVE_FOLDER)) do
                            local n2=tostring(p2):match("([^/\\]+)$") or p2
                            local num=n2:match("^checkpoint_(%d+)%.json$")
                            if num and tonumber(num)>=tonumber(myNum) then
                                table.insert(allCPs,{num=tonumber(num),path=p2})
                            end
                        end
                    end)
                    table.sort(allCPs,function(a,b) return a.num<b.num end)
                    local seqIdx=0
                    local function nextSeq()
                        seqIdx=seqIdx+1
                        if seqIdx>#allCPs then
                            pcall(function() pBtn.Text="▶"; pBtn.TextColor3=SUB end)
                            if currentPlayBtn==pBtn then currentPlayBtn=nil end; return
                        end
                        print(string.format("[REC] ▶ checkpoint_%d (%d/%d)",allCPs[seqIdx].num,seqIdx,#allCPs))
                        playFile(allCPs[seqIdx].path, nextSeq)
                    end
                    nextSeq()
                else
                    playFile(f.path, function()
                        pcall(function() pBtn.Text="▶"; pBtn.TextColor3=SUB end)
                        if currentPlayBtn==pBtn then currentPlayBtn=nil end
                    end)
                end
            end)

            bUp.MouseButton1Click:Connect(function()
                local mapN=f.name:gsub("%.json$","")
                bUp.Text="⏳"; bUp.BackgroundColor3=GRY
                uploadToGitHub(f.path,mapN,function(ok2,msg)
                    pcall(function()
                        bUp.Text= ok2 and "✓" or "✗"
                        bUp.BackgroundColor3= ok2 and GRN or RED
                        task.delay(2,function() pcall(function() bUp.Text="☁"; bUp.BackgroundColor3=BLU end) end)
                        print("[REC] Upload "..mapN..": "..(ok2 and "✅ "..msg or "❌ "..msg))
                    end)
                end)
            end)

            bDel.MouseButton1Click:Connect(function()
                pcall(function() delfile(f.path) end)
                if selNearestPath==f.path then selNearestPath=nil end
                refreshCPList(srch.Text)
            end)

            table.insert(allRows,{row=row,path=f.path})
        end
    end

    btnRefresh.MouseButton1Click:Connect(function() refreshCPList(srch.Text) end)
    srch:GetPropertyChangedSignal("Text"):Connect(function() refreshCPList(srch.Text) end)

    btnMerge.MouseButton1Click:Connect(function()
        btnMerge.Text="⏳"; btnMerge.BackgroundColor3=GRY
        local ok2,fname2,_,cnt,ncps=mergeAllCheckpoints(nameInput.Text)
        if ok2 then
            nameInput.Text=""; refreshCPList(srch.Text)
            print(string.format("✅ Merged %d CPs → %s (%d frames)",ncps,fname2,cnt))
            btnMerge.Text="✓"; btnMerge.BackgroundColor3=GRN
        else
            warn("❌ Merge gagal: "..tostring(fname2))
            btnMerge.Text="✗"; btnMerge.BackgroundColor3=RED
        end
        task.delay(2,function() pcall(function() btnMerge.Text="⚡"; btnMerge.BackgroundColor3=PUR end) end)
    end)

    btnUpAll.MouseButton1Click:Connect(function()
        local files=scanFiles()
        if #files==0 then print("[REC] Tidak ada file!"); return end
        btnUpAll.Text="⏳"; btnUpAll.BackgroundColor3=GRY
        local done,total=0,#files
        for _,f in ipairs(files) do
            local mapN=f.name:gsub("%.json$","")
            uploadToGitHub(f.path,mapN,function(ok2,msg)
                done=done+1
                print(string.format("[REC] Upload [%d/%d] %s: %s",done,total,mapN,ok2 and "✅" or "❌ "..msg))
                if done>=total then
                    pcall(function()
                        btnUpAll.Text="✓"; btnUpAll.BackgroundColor3=GRN
                        task.delay(2,function() pcall(function() btnUpAll.Text="☁"; btnUpAll.BackgroundColor3=BLU end) end)
                    end)
                end
            end)
        end
    end)

    btnTpEnd.MouseButton1Click:Connect(function()
        if not doTpEnd() then print("[REC] Tidak ada frame untuk TP End") end
    end)

    -- 🔍 Nearest = TP END sistem uwaw: TP ke posisi frame terakhir yang disave
    btnNearest.MouseButton1Click:Connect(function()
        if not lastSavedPosition then
            print("[REC] Belum ada file yang disave, Nearest tidak tersedia"); return
        end
        local c2=player.Character; if not c2 then return end
        local h2=c2:FindFirstChild("HumanoidRootPart"); if not h2 then return end
        h2.CFrame = CFrame.new(lastSavedPosition + Vector3.new(0, 2, 0))
                  * CFrame.Angles(0, lastSavedRotation, 0)
        h2.AssemblyLinearVelocity  = Vector3.new(0,0,0)
        h2.AssemblyAngularVelocity = Vector3.new(0,0,0)
        print("[REC] TP END → posisi frame terakhir yang disave")
    end)

    btnSave.MouseButton1Click:Connect(function()
        local ok,fname,_,cnt=saveRecording(nameInput.Text)
        if ok then
            nameInput.Text=""; recordedFrames={}; refreshCPList(srch.Text)
            print(string.format("✅ Saved: %s (%d frames)",fname,cnt))
            btnSave.BackgroundColor3=BLU
            task.delay(0.8,function() pcall(function() btnSave.BackgroundColor3=GRN end) end)
        else
            btnSave.BackgroundColor3=RED
            task.delay(1,function() pcall(function() btnSave.BackgroundColor3=GRN end) end)
            warn("❌ Save gagal: "..tostring(fname))
        end
    end)

    -- ══════════════════════════════════════════════════════════
    -- FLOATING RECORD PANEL  (+ ROLLBACK dari JEPIN)
    -- ══════════════════════════════════════════════════════════
    local RP_W=215; local RP_H=90
    local recPanel=Instance.new("Frame",sg)
    recPanel.Name="RecPanel"; recPanel.Size=UDim2.new(0,RP_W,0,RP_H)
    recPanel.Position=UDim2.new(0.5,-RP_W/2,0.88,-RP_H/2)
    recPanel.BackgroundColor3=BG; recPanel.BorderSizePixel=0; recPanel.Visible=false
    cr(recPanel,12); sk(recPanel,RED,1.5)

    local glow=Instance.new("ImageLabel",recPanel)
    glow.Size=UDim2.new(1,20,1,20); glow.Position=UDim2.new(0,-10,0,-10)
    glow.BackgroundTransparency=1; glow.ZIndex=0
    glow.Image="rbxassetid://6015897843"; glow.ImageColor3=RED; glow.ImageTransparency=0.7

    local rd,rds3,rdp3=false,nil,nil
    recPanel.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            rd=true; rds3=i.Position; rdp3=recPanel.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then rd=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if rd and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-rds3
            recPanel.Position=UDim2.new(rdp3.X.Scale,rdp3.X.Offset+d.X,rdp3.Y.Scale,rdp3.Y.Offset+d.Y)
        end
    end)

    local recStat=Instance.new("TextLabel",recPanel)
    recStat.Size=UDim2.new(1,0,0,20); recStat.Position=UDim2.new(0,0,0,4)
    recStat.BackgroundTransparency=1
    recStat.Text="⬤  REC  0.0s  0fr  @"..RECORD_HZ.."FPS"
    recStat.Font=Enum.Font.GothamBold; recStat.TextSize=10
    recStat.TextColor3=RED; recStat.TextXAlignment=Enum.TextXAlignment.Center

    local recBtnF=Instance.new("Frame",recPanel)
    recBtnF.Size=UDim2.new(1,-14,0,56); recBtnF.Position=UDim2.new(0,7,0,26)
    recBtnF.BackgroundTransparency=1
    local rbl=Instance.new("UIListLayout",recBtnF)
    rbl.FillDirection=Enum.FillDirection.Vertical; rbl.Padding=UDim.new(0,5)
    rbl.VerticalAlignment=Enum.VerticalAlignment.Top

    local function mkRBtn(txt,col)
        local rowF=Instance.new("Frame",recBtnF); rowF.Size=UDim2.new(1,0,0,22)
        rowF.BackgroundTransparency=1
        local b=Instance.new("TextButton",rowF); b.Size=UDim2.new(1,0,1,0)
        b.BackgroundColor3=col; b.BorderSizePixel=0; b.Text=txt; b.Font=Enum.Font.GothamBold
        b.TextSize=11; b.TextColor3=Color3.new(1,1,1); b.AutoButtonColor=true; cr(b,7)
        return b
    end
    local btnStop2     = mkRBtn("⏹  STOP",    RED)
    local btnRollback2 = mkRBtn("↩  ROLLBACK ("..ROLLBACK_SECS.."s)", ORG)  -- ← JEPIN

    local function startPulse()
        task.spawn(function()
            while isRecording do
                recStat.TextTransparency=0; task.wait(0.5)
                recStat.TextTransparency=0.4; task.wait(0.5)
            end
            recStat.TextTransparency=0
        end)
    end

    local function enterRecord()
        startRecording()
        win.Visible=false; recPanel.Visible=true
        startPulse()
    end
    local function exitRecord()
        stopRecording()
        recPanel.Visible=false; win.Visible=true
        refreshCPList(srch.Text)
    end

    btnRecord.MouseButton1Click:Connect(enterRecord)
    btnStop2.MouseButton1Click:Connect(exitRecord)

    -- ══════════════════════════════════════════════════════════
    -- FLOATING PLAYBACK PANEL  (muncul saat isPlaying)
    -- ══════════════════════════════════════════════════════════
    local PP_W=215; local PP_H=66
    local playPanel=Instance.new("Frame",sg)
    playPanel.Name="PlayPanel"; playPanel.Size=UDim2.new(0,PP_W,0,PP_H)
    playPanel.Position=UDim2.new(0.5,-PP_W/2,0.88,-PP_H/2)
    playPanel.BackgroundColor3=BG; playPanel.BorderSizePixel=0; playPanel.Visible=false
    cr(playPanel,12); sk(playPanel,BLU,1.5)

    local ppGlow=Instance.new("ImageLabel",playPanel)
    ppGlow.Size=UDim2.new(1,20,1,20); ppGlow.Position=UDim2.new(0,-10,0,-10)
    ppGlow.BackgroundTransparency=1; ppGlow.ZIndex=0
    ppGlow.Image="rbxassetid://6015897843"; ppGlow.ImageColor3=BLU; ppGlow.ImageTransparency=0.7

    local ppd,ppds,ppdp=false,nil,nil
    playPanel.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            ppd=true; ppds=i.Position; ppdp=playPanel.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then ppd=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if ppd and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ppds
            playPanel.Position=UDim2.new(ppdp.X.Scale,ppdp.X.Offset+d.X,ppdp.Y.Scale,ppdp.Y.Offset+d.Y)
        end
    end)

    local playStat=Instance.new("TextLabel",playPanel)
    playStat.Size=UDim2.new(1,0,0,20); playStat.Position=UDim2.new(0,0,0,4)
    playStat.BackgroundTransparency=1
    playStat.Text="▶  PLAYING..."
    playStat.Font=Enum.Font.GothamBold; playStat.TextSize=10
    playStat.TextColor3=BLU; playStat.TextXAlignment=Enum.TextXAlignment.Center

    local ppBtnF=Instance.new("Frame",playPanel)
    ppBtnF.Size=UDim2.new(1,-14,0,32); ppBtnF.Position=UDim2.new(0,7,0,28)
    ppBtnF.BackgroundTransparency=1

    local btnStopPlay=Instance.new("TextButton",ppBtnF)
    btnStopPlay.Size=UDim2.new(1,0,1,0)
    btnStopPlay.BackgroundColor3=BLU; btnStopPlay.BorderSizePixel=0
    btnStopPlay.Text="⏹  STOP PLAYBACK"; btnStopPlay.Font=Enum.Font.GothamBold
    btnStopPlay.TextSize=11; btnStopPlay.TextColor3=Color3.new(1,1,1); btnStopPlay.AutoButtonColor=true
    cr(btnStopPlay,7)

    btnStopPlay.MouseButton1Click:Connect(function()
        stopPlayback()
        playPanel.Visible=false; win.Visible=true
        -- Reset semua play button
        if currentPlayBtn then
            pcall(function() currentPlayBtn.Text="▶"; currentPlayBtn.TextColor3=SUB end)
            currentPlayBtn=nil
        end
        print("[REC] ⏹ Playback dihentikan manual")
    end)

    -- Pantau isPlaying untuk tampilkan/sembunyikan playPanel
    task.spawn(function()
        local wasPlaying=false
        while sg.Parent do
            pcall(function()
                if isPlaying and not wasPlaying then
                    -- Hanya tampilkan playPanel kalau tidak sedang recording
                    if not isRecording then
                        playPanel.Visible=true; win.Visible=false
                    end
                    wasPlaying=true
                    playStat.TextTransparency=0
                elseif not isPlaying and wasPlaying then
                    playPanel.Visible=false
                    if not isRecording then win.Visible=true end
                    wasPlaying=false
                end
                if isPlaying then
                    playStat.Text="▶  PLAYING..."
                end
            end)
            task.wait(0.1)
        end
    end)

    -- Rollback handler (dipakai di 2 tempat)
    local function handleRollback()
        if not isRecording then
            print("[REC] Rollback hanya aktif saat recording"); return
        end
        local n=doRollback()
        print("[REC] Rollback "..ROLLBACK_SECS.."s → hapus "..n.." frame, sisa "..#recordedFrames)
    end
    btnRollback.MouseButton1Click:Connect(handleRollback)
    btnRollback2.MouseButton1Click:Connect(handleRollback)

    -- LIVE UPDATE
    task.spawn(function()
        while sg.Parent do
            pcall(function()
                local fc=#recordedFrames
                local dur=fc>0 and recordedFrames[fc].time or 0
                infoLbl.Text=string.format("%dfr  %.1fs",fc,dur)
                local tool=getCurrentTool()
                toolLbl.Text="🔧 "..(tool or "-")
                if isRecording then
                    statusLbl.Text="⬤  REC"; statusLbl.TextColor3=RED
                    recStat.Text=string.format("⬤  REC  %.1fs  %dfr  @%dFPS",dur,fc,RECORD_HZ)
                elseif isPlaying then
                    statusLbl.Text="▶  PLAY"; statusLbl.TextColor3=BLU
                else
                    statusLbl.Text="⬤  READY"; statusLbl.TextColor3=GRN
                end
            end)
            task.wait(0.15)
        end
    end)

    -- KEYBOARD
    UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end
        local focused=UserInputService:GetFocusedTextBox()
        if focused then return end
        if inp.KeyCode==Enum.KeyCode.F then
            if isRecording then exitRecord()
            elseif isPlaying then
                stopPlayback()
                playPanel.Visible=false; win.Visible=true
                if currentPlayBtn then
                    pcall(function() currentPlayBtn.Text="▶"; currentPlayBtn.TextColor3=SUB end)
                    currentPlayBtn=nil
                end
            else enterRecord() end
        elseif inp.KeyCode==Enum.KeyCode.R then
            handleRollback()
        elseif inp.KeyCode==Enum.KeyCode.G then
            if not isRecording then
                local ok,fname2,_,cnt=saveRecording(nameInput.Text)
                if ok then
                    nameInput.Text=""; recordedFrames={}; refreshCPList(srch.Text)
                    print(string.format("✅ G Save: %s (%d frames)",fname2,cnt))
                end
            end
        end
    end)

    refreshCPList("")
end

-- ================================================================
-- INIT
-- ================================================================
player.CharacterAdded:Connect(function(newChar)
    character=newChar
    humanoid=newChar:WaitForChild("Humanoid")
    hrp=newChar:WaitForChild("HumanoidRootPart")
    if isRecording then stopRecording(); print("[REC] Respawn → rekaman dihentikan.") end
    if isPlaying then stopPlayback() end
end)

buildUI()
print("═══════════════════════════════════════════════════")
print("  POKAY RECORDER  +  Jepin Record Engine")
print("  F=Record/Stop  R=Rollback("..ROLLBACK_SECS.."s)  G=Quick Save")
print("  ⚡=Merge checkpoint_1..N  ▶=Play sequential")
print("  🎬 "..RECORD_HZ.."FPS  ✂ Bypass Time  ↩ Rollback")
print("═══════════════════════════════════════════════════")
