local imgui = require("mimgui")

local window = imgui.new.bool(true)
local ffi = require "ffi"
local gta = ffi.load "GTASA"

local vector3d = require("vector3d")

local SAMemory= require("SAMemory")

local tiroContador = 0
local miraAtual = 3

local currentWeaponID = 0
local shotCount = 0

local opcoes_menu = {
  "Player", 
  "Esp", 
  "Teleport", 
  "Farm",
  "Aimbot", 
  "Armas",
  "Sobre"
}
local current_lab = 1
local state = true



ffi.cdef[[
  typedef struct RwV3d {
    float x, y, z;
  } RwV3d;
  // void CPed::GetBonePosition(CPed *this, RwV3d *posn, uint32 bone, bool calledFromCam) - Mangled name
  void _ZN4CPed15GetBonePositionER5RwV3djb(void* thiz, RwV3d* posn, uint32_t bone, bool calledFromCam);
]]

function getBonePosition(ped, bone)
  local pedptr = ffi.cast('void*', getCharPointer(ped))
  local posn = ffi.new('RwV3d[1]')
  gta._ZN4CPed15GetBonePositionER5RwV3djb(pedptr, posn, bone, false)
  return posn[0].x, posn[0].y, posn[0].z
end

ffi.cdef[[
    void _Z12AND_OpenLinkPKc(const char* link);
]]

abrirlink = function(link)
    gta._Z12AND_OpenLinkPKc(link)
end

local switches = {}

local switchAnim = {}

local id_arma = imgui.new.int(0)

local player = {
  vida = imgui.new.bool(false),
  colete = imgui.new.bool(false),
  god = imgui.new.bool(false),
  atravessar_player = imgui.new.bool(false),
  nao_cansar = imgui.new.bool(false),
  correr_rapido = imgui.new.bool(false),
  fastreload = imgui.new.bool(false)
}

local cbugs = {
  cbug = imgui.new.bool(false)
  
}

local tps = {
  one = imgui.new.bool(false),
  two = imgui.new.bool(false),
  tree = imgui.new.bool(false),
  four = imgui.new.bool(false)
,
  byppas = imgui.new.bool(false)
}

local armas = {
   arma1 = imgui.new.bool(false),
   arma2 = imgui.new.bool(false),
   arma3 = imgui.new.bool(false),
   arma4 = imgui.new.bool(false),
   arma5 = imgui.new.bool(false),
   arma6 = imgui.new.bool(false),
   arma7 = imgui.new.bool(false)
}

function lifefootmob()
    if cbugs.cbug[0] and isCharShooting(PLAYER_PED) then
        shotCount = shotCount + 1
        if shotCount % 2 == 0 then
            currentWeaponID = getCurrentCharWeapon(PLAYER_PED) 
            setCurrentCharWeapon(PLAYER_PED, 0) 
            wait(300)
            setCurrentCharWeapon(PLAYER_PED, currentWeaponID)
        end
    end
end

function dar_arma()
  if armas.arma1[0] then
    giveWeaponToChar(PLAYER_PED, 24, 100) -- desert
  end
  if armas.arma2[0] then
    giveWeaponToChar(PLAYER_PED, 29, 100) -- mp5
  end
  if armas.arma3[0] then
    giveWeaponToChar(PLAYER_PED, 31, 100) -- m4
  end
  if armas.arma4[0] then
    giveWeaponToChar(PLAYER_PED, 34, 100) -- sniper
  end
  if armas.arma5[0] then
    giveWeaponToChar(PLAYER_PED, 30, 100) -- ak47
  end
  if armas.arma6[0] then
    giveWeaponToChar(PLAYER_PED, 35, 100) -- rpg
  end
  if armas.arma7[0] then 
    giveWeaponToChar(PLAYER_PED, 27, 100) -- combat shotgun
  end
    
end

function teleport(px, py, pz)
    lua_thread.create(function()
      setCharInterior(PLAYER_PED, 1)
      if tps.byppas[0] then
        sampSendSpawn()
      end
      wait(350)
      freezeCharPosition(PLAYER_PED, true)
      setCharCoordinates(PLAYER_PED, px + 0.0, py + 0.0, pz + 0.5)
      wait(50)
      freezeCharPosition(PLAYER_PED, false)
      setCharInterior(PLAYER_PED, 0)
    end)
end


local farm = {
  roubar = imgui.new.bool(false)
  
}
function roubar()
    if farm.roubar[0] then
        setCharCoordinates(PLAYER_PED, -1435.3540039063, 1480.2552490234, 1.8671875)
        sampSendChat("/roubar")
        farm.roubar[0] =  false
    end
end

function add_vida()
  if player.vida[0] then
    setCharHealth(PLAYER_PED, 100)
  end
end

function add_colete()
  if player.colete[0] then
    addArmourToChar(PLAYER_PED, 100)
  end
end

function atravessar_players()
  if player.atravessar_player[0] then
    for id = 0, sampGetMaxPlayerId(false) do
      if sampIsPlayerConnected(id) then
        local res, ped = sampGetCharHandleBySampPlayerId(id)
        if res and doesCharExist(ped) then
          local x,y,z = getCharCoordinates(PLAYER_PED)
          local xx,yy,zz = getCharCoordinates(ped)
          if getDistanceBetweenCoords3d(xx,yy,zz,x,y,z) < 1 then
            setCharCollision(ped, false)
          end
        end
      end
    end
  end
end


function rgbRainbowHex(speed, alpha)
    alpha = alpha or 1
    local t = os.clock() * speed
    local r = math.floor((math.sin(t + 0) * 127 + 128))
    local g = math.floor((math.sin(t + 2) * 127 + 128))
    local b = math.floor((math.sin(t + 4) * 127 + 128))
    local a = math.floor(alpha * 255)
    return string.format("0x%02X%02X%02X%02X", a, r, g, b)
end


function correrRapido()
    local correr_anims = {
    "run_1armed",
    "run_csaw",
    "run_rocket",
    "run_wuzi",
    "sprint_civi",
    "sprint_panic",
    "sprint_wuzi",
    "woman_run",
    "woman_runbusy",
    "woman_runpanic",
    "woman_runsexy",
    "woman_runfatold"
    }
    if player.correr_rapido[0] then
        local speed = 2.5 
        for _, animName in ipairs(correr_anims) do
            setCharAnimSpeed(PLAYER_PED, animName, speed)
        end
    end
end

function god()
  if player.god[0] then
    setCharProofs(playerPed, true, true, true, true, true)
  end
end

function recarregar_rapido()
  if player.fastreload[0] then
    setPlayerFastReload(playerHandle, true)
    setCharAnimSpeed(PLAYER_PED, "TEC_RELOAD", 20)
    setCharAnimSpeed(PLAYER_PED, "buddy_reload", 20)
    setCharAnimSpeed(PLAYER_PED, "buddy_crouchreload", 20)
    setCharAnimSpeed(PLAYER_PED, "colt45_reload", 20)
    setCharAnimSpeed(PLAYER_PED, "colt45_crouchreload", 20)
    setCharAnimSpeed(PLAYER_PED, "sawnoff_reload", 20)
    setCharAnimSpeed(PLAYER_PED, "python_reload", 20)
    setCharAnimSpeed(PLAYER_PED, "python_crouchreload", 20)
    setCharAnimSpeed(PLAYER_PED, "RIFLE_load", 20)
    setCharAnimSpeed(PLAYER_PED, "RIFLE_crouchload", 20)
    setCharAnimSpeed(PLAYER_PED, "Silence_reload", 20)
    setCharAnimSpeed(PLAYER_PED, "CrouchReload", 20)
    setCharAnimSpeed(PLAYER_PED, "UZI_reload", 20)
    setCharAnimSpeed(PLAYER_PED, "UZI_crouchreload", 20)
  else
		  setPlayerFastReload(playerHandle, false)
		end
end

  


function imgui.Switch(id, state, w, h, onToggle)
    w = w or 60
    h = h or 20
    if switchAnim[id] == nil then
        switchAnim[id] = state and 1 or 0
    end
    local anim = switchAnim[id]
    local target = state and 1 or 0
    anim = anim + (target - anim) * 0.15
    switchAnim[id] = anim
  
    -- cores
    local off = imgui.ImVec4(0.25, 0.25, 0.30, 1)
    local on  = imgui.ImVec4(0.10, 0.45, 1.00, 1)

    local bg = imgui.ImVec4(
        off.x + (on.x - off.x) * anim,
        off.y + (on.y - off.y) * anim,
        off.z + (on.z - off.z) * anim,
        1
    )

    local draw = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    local x, y = pos.x, pos.y
    local clicked = imgui.InvisibleButton(id, imgui.ImVec2(w, h))
  
    draw:AddRectFilled(
        imgui.ImVec2(x, y),
        imgui.ImVec2(x + w, y + h),
        imgui.ColorConvertFloat4ToU32(bg),
        h / 2
    )
    local knob = h - 6
    local knobX = x + 3 + (w - knob - 6) * anim

    draw:AddCircleFilled(
        imgui.ImVec2(knobX + knob/2, y + h/2),
        knob/2,
        0xFFFFFFFF
    )
  
    if clicked then
        local newState = not state
        if onToggle then onToggle(newState) end
        return newState
    end
  
    imgui.Dummy(imgui.ImVec2(0, h * 0.5))
    return state
end

local ackles = {
  esp_ativo = imgui.new.bool(false),
  esp_name = imgui.new.bool(false),
  esp_linhas = imgui.new.bool(false),
  dist = imgui.new.bool(false),
  esp_id = imgui.new.bool(false),
  esp_e = imgui.new.bool(false),
  esp_carro = imgui.new.bool(false),
  esp_box = imgui.new.bool(false),
  esp_hp = imgui.new.bool(false),
  esp_adm = imgui.new.bool(false)
}



function RGB(speed)
  local t = os.clock() * speed
  local r = math.floor(math.sin(t + 0) * 127 + 128)
  local g = math.floor(math.sin(t + 2) * 127 + 128)
  local b = math.floor(math.sin(t + 4) * 127 + 128)
  return r/255, g/255, b/255
end

local camera = SAMemory.camera
local screenWidth, screenHeight = getScreenResolution()
local configFilePath = getWorkingDirectory() .. "/config/EASY.json"
local circuloFOVAIM = false

local slide = {
    fovColor = imgui.new.float[4](1.0, 1.0, 1.0, 1.0),
    fovX = imgui.new.float(832.0),
    fovY = imgui.new.float(313.0),
    FoVVHG = imgui.new.float(150.0),
    distancia = imgui.new.int(1000),
    fovvaimbotcirculo = imgui.new.float(400),
    DistanciaAIM = imgui.new.float(1000.0),
    aimSmoothhhh = imgui.new.float(1.000),
    fovCorAimmm = imgui.new.float[4](1.0, 1.0, 1.0, 1.0),
    fovCorsilent = imgui.new.float[4](1.0, 1.0, 1.0, 1.0),
    espcores = imgui.new.float[4](1.0, 1.0, 1.0, 1.0),
    posiX = imgui.new.float(0.520),
    posiY = imgui.new.float(0.439),
    circulooPosX = imgui.new.float(832.0),
    circuloooPosY = imgui.new.float(313.0),
    circuloFOV = true,
    aimCtdr = imgui.new.int(1),
    qtdraios = imgui.new.int(5),
    raiosseguidos = imgui.new.int(10),
    larguraraios = imgui.new.int(40),
    HGPROAIM = imgui.new.int(1),
    minFov = 1,
}

local sulist = {
    cabecaAIM = imgui.new.bool(false),
    peitoAIM = imgui.new.bool(false),
    bracoAIM = imgui.new.bool(false),
    virilhaAIM = imgui.new.bool(false),
    lockAIM = imgui.new.bool(false),
    braco2AIM = imgui.new.bool(false),
    pernaAIM = imgui.new.bool(false),
    perna2AIM = imgui.new.bool(false),
    PROAIM2 = imgui.new.bool(false),
    aimbotparede = imgui.new.bool(false),
}




local buttonPressedTime = 0
local buttonRepeatInterval = 0.0
local bones = { 3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2 }
local sw, sh = getScreenResolution()
local font = renderCreateFont("Arial", 12, 1 + 4) -- P.S. in MonetLoader only Arial Bold is available (every font is defaulted to it)

function esp_esqueleto()
    for _, char in ipairs(getAllChars()) do
      local result, id = sampGetPlayerIdByCharHandle(char)
      if result and isCharOnScreen(char) then
        local opaque_color = bit.bor(bit.band(sampGetPlayerColor(id), 0xFFFFFF), 0xFF000000)
        for _, bone in ipairs(bones) do
          local x1, y1, z1 = getBonePosition(char, bone)
          local x2, y2, z2 = getBonePosition(char, bone + 1)
          local r1, sx1, sy1 = convert3DCoordsToScreenEx(x1, y1, z1)
          local r2, sx2, sy2 = convert3DCoordsToScreenEx(x2, y2, z2)
          if r1 and r2 and ackles.esp_e[0] then
            renderDrawLine(sx1, sy1, sx2, sy2, 3, 0xFFFFFFFF)
          end
        end

        local x1, y1, z1 = getBonePosition(char, 2)
        local r1, sx1, sy1 = convert3DCoordsToScreenEx(x1, y1, z1)
        if r1 then
          local x2, y2, z2 = getBonePosition(char, 41)
          local r2, sx2, sy2 = convert3DCoordsToScreenEx(x2, y2, z2)
          if r2 and ackles.esp_e[0] then
            renderDrawLine(sx1, sy1, sx2, sy2, 3, 0xFFFFFFFF)
          end
        end
        if r1 then
          local x2, y2, z2 = getBonePosition(char, 51)
          local r2, sx2, sy2 = convert3DCoordsToScreenEx(x2, y2, z2)
          if r2 and ackles.esp_e[0] then
            renderDrawLine(sx1, sy1, sx2, sy2, 3, 0xFFFFFFFF)
          end
        end
      end
    end
end

function Aimbot()
    function getCameraRotation()
        local horizontalAngle = camera.aCams[0].fHorizontalAngle
        local verticalAngle = camera.aCams[0].fVerticalAngle
        return horizontalAngle, verticalAngle
    end

    function setCameraRotation(EASYaimbotHorizontal, EASYaimbotVertical)
        camera.aCams[0].fHorizontalAngle = EASYaimbotHorizontal
        camera.aCams[0].fVerticalAngle = EASYaimbotVertical
    end

    function convertCartesianCoordinatesToSpherical(EASYaimbot)
        local coordsDifference = EASYaimbot - vector3d(getActiveCameraCoordinates())
        local length = coordsDifference:length()
        local angleX = math.atan2(coordsDifference.y, coordsDifference.x)
        local angleY = math.acos(coordsDifference.z / length)

        if angleX > 0 then
            angleX = angleX - math.pi
        else
            angleX = angleX + math.pi
        end

        local angleZ = math.pi / 2 - angleY
        return angleX, angleZ
    end

    function getCrosshairPositionOnScreen()
        local screenWidth, screenHeight = getScreenResolution()
        local crosshairX = screenWidth * slide.posiX[0]
        local crosshairY = screenHeight * slide.posiY[0]
        return crosshairX, crosshairY
    end

    function getCrosshairRotation(EASYaimbot)
        EASYaimbot = EASYaimbot or 5
        local crosshairX, crosshairY = getCrosshairPositionOnScreen()
        local worldCoords = vector3d(convertScreenCoordsToWorld3D(crosshairX, crosshairY, EASYaimbot))
        return convertCartesianCoordinatesToSpherical(worldCoords)
    end

    function aimAtPointWithM16(EASYaimbot)
        local sphericalX, sphericalY = convertCartesianCoordinatesToSpherical(EASYaimbot)
        local cameraRotationX, cameraRotationY = getCameraRotation()
        local crosshairRotationX, crosshairRotationY = getCrosshairRotation()
        local newRotationX = cameraRotationX + (sphericalX - crosshairRotationX) * slide.aimSmoothhhh[0]
        local newRotationY = cameraRotationY + (sphericalY - crosshairRotationY) * slide.aimSmoothhhh[0]
        setCameraRotation(newRotationX, newRotationY)
    end

    function aimAtPointWithSniperScope(EASYaimbot)
        local sphericalX, sphericalY = convertCartesianCoordinatesToSpherical(EASYaimbot)
        setCameraRotation(sphericalX, sphericalY)
    end

    function getNearCharToCenter(EASYaimbot)
        local nearChars = {}
        local screenWidth, screenHeight = getScreenResolution()

        for _, char in ipairs(getAllChars()) do
            if isCharOnScreen(char) and char ~= PLAYER_PED and not isCharDead(char) then
                local charX, charY, charZ = getCharCoordinates(char)
                local screenX, screenY = convert3DCoordsToScreen(charX, charY, charZ)
                local distance = getDistanceBetweenCoords2d(screenWidth / 1.923 + slide.posiX[0], screenHeight / 2.306 + slide.posiY[0], screenX, screenY)

                if isCurrentCharWeapon(PLAYER_PED, 34) then
                    distance = getDistanceBetweenCoords2d(screenWidth / 2, screenHeight / 2, screenX, screenY)
                end

                if distance <= tonumber(EASYaimbot and EASYaimbot or screenHeight) then
                    table.insert(nearChars, {
                        distance,
                        char
                    })
                end
            end
        end

        if #nearChars > 0 then
            table.sort(nearChars, function(a, b)
                return a[1] < b[1]
            end)
            return nearChars[1][2]
        end

        return nil
    end

    local distancia = slide.DistanciaAIM[0]
    local nMode = camera.aCams[0].nMode
    local nearChar = getNearCharToCenter(slide.fovvaimbotcirculo[0] + 1.923)
    
    if nearChar then
            local boneX, boneY, boneZ = getBonePosition(nearChar, 5)
        if boneX and boneY and boneZ then
            local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)
            local distanceToBone = getDistanceBetweenCoords3d(playerX, playerY, playerZ, boneX, boneY, boneZ)
    
            if not sulist.aimbotparede[0] then
                local targetX, targetY, targetZ = boneX, boneY, boneZ
                local hit, colX, colY, colZ, entityHit = processLineOfSight(playerX, playerY, playerZ, targetX, targetY, targetZ, true, true, false, true, false, false, false, false)
                if hit and entityHit ~= nearChar then
                    return
                end
            else
                local targetX, targetY, targetZ = boneX, boneY, boneZ
            end
    
            if distanceToBone < distancia then
                local point
    
                if sulist.cabecaAIM[0] then
                    local headX, headY, headZ = getBonePosition(nearChar, 5)
                    point = vector3d(headX, headY, headZ)
                end
    
                if sulist.peitoAIM[0] then
                    local chestX, chestY, chestZ = getBonePosition(nearChar, 3)
                    point = vector3d(chestX, chestY, chestZ)
                end
                
                if sulist.virilhaAIM[0] then
                    local chestX, chestY, chestZ = getBonePosition(nearChar, 1)
                    point = vector3d(chestX, chestY, chestZ)
                end
                
                if sulist.lockAIM[0] then
                    local partX, partY, partZ = getBonePosition(nearChar, miraAtual)
                    point = vector3d(partX, partY, partZ)

                    local parts = {}

                    if sulist.cabecaAIM[0] then
                        table.insert(parts, 5)
                    end
                    if sulist.peitoAIM[0] then
                        table.insert(parts, 3)
                    end
                    if sulist.virilhaAIM[0] then
                        table.insert(parts, 1)
                    end
                    if sulist.bracoAIM[0] then
                        table.insert(parts, 33)
                    end
                    if sulist.braco2AIM[0] then
                        table.insert(parts, 23)
                    end
                    if sulist.pernaAIM[0] then
                        table.insert(parts, 52)
                    end
                    if sulist.perna2AIM[0] then
                        table.insert(parts, 42)
                    end

                    if not miraAtualIndex then
                        miraAtualIndex = 1
                    end

                    if #parts > 0 then
                        if isCharShooting(PLAYER_PED) then
                            tiroContador = tiroContador + 1

                            if tiroContador >= slide.aimCtdr[0] then
                                tiroContador = 0
                                miraAtualIndex = (miraAtualIndex % #parts) + 1
                                miraAtual = parts[miraAtualIndex]
                            end
                        end

                        local partX, partY, partZ = getBonePosition(nearChar, miraAtual)
                        point = vector3d(partX, partY, partZ)
                    end
                end
                
                if sulist.bracoAIM[0] then
                    local chestX, chestY, chestZ = getBonePosition(nearChar, 33)
                    point = vector3d(chestX, chestY, chestZ)
                end
                
                if sulist.braco2AIM[0] then
                    local chestX, chestY, chestZ = getBonePosition(nearChar, 23)
                    point = vector3d(chestX, chestY, chestZ)
                end
                
                if sulist.pernaAIM[0] then
                    local chestX, chestY, chestZ = getBonePosition(nearChar, 52)
                    point = vector3d(chestX, chestY, chestZ)
                end
                
                if sulist.perna2AIM[0] then
                    local chestX, chestY, chestZ = getBonePosition(nearChar, 42)
                    point = vector3d(chestX, chestY, chestZ)
                end
    
                if point then
                    if nMode == 7 then
                        aimAtPointWithSniperScope(point)
                    elseif nMode == 53 then
                        aimAtPointWithM16(point)
                    end
                end
            end
        end
    end
end


local rain = {}
local rainCount = 43  

for i = 1, rainCount do
    rain[i] = {
        x = math.random(0, 300), 
        y = math.random(0, 500), 
        len = math.random(20, 60), 
        speed = math.random(40, 120) / 21
    }
end

local function drawRainBackground()
    local draw = imgui.GetWindowDrawList()
    local winPos = imgui.GetWindowPos()
    local winSize = imgui.GetWindowSize()

    for i = 1, rainCount do
        local drop = rain[i]
        drop.y = drop.y + drop.speed
      
        if drop.y > winSize.y then
            drop.y = -drop.len
            drop.x = math.random(0, winSize.x)
        end
        draw:AddLine(
            imgui.ImVec2(winPos.x + drop.x, winPos.y + drop.y),
            imgui.ImVec2(winPos.x + drop.x, winPos.y + drop.y + drop.len),
            0x55FFFFFF,   
            2.5      
        )
    end
end


function imgui.Theme()
  -- configs
  imgui.SwitchContext()
  imgui.GetStyle().FramePadding = imgui.ImVec2(3.5,3.5)
  imgui.GetStyle().FrameRounding = 0
  imgui.GetStyle().WindowRounding = 21
  imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5,0.5)
  imgui.GetStyle().WindowPadding = imgui.ImVec2(4.0,4.0)
   -- cores
  imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0,0,0,1)
  imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.5, 0.5, 0.5, 1)
  -- imagens
  fundo = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/416999.jpg")
  close = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/sair.jpeg")
    
  if not close then close = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/com.sampmobilerp.game/monetloader/lib/sair.jpeg") end
  
  discord = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/discord.png")
  
  if not discord then discord = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/com.sampmobilerp.game/monetloader/lib/discord.png") end
    
  instagram = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/insta.jpg")
    
  if not instagram then instagram = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/com.sampmobilerp.game/monetloader/lib/insta.jpg") end
  
  youtube = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/youtube.jpg")
  if not youtube then youtube = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/com.sampmobilerp.game/monetloader/lib/youtube.jpg")
 end
  
  -- fonte
  
  local io = imgui.GetIO()
  fonte = io.Fonts:AddFontFromFileTTF("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/a.ttf", 28)
  if not fonte then fonte = io.Fonts:AddFontFromFileTTF("/storage/emulated/0/Android/media/com.sampmobilerp.game/monetloader/lib/a.ttf", 28) end
  
  
end



imgui.OnInitialize(function() imgui.Theme() end)
  
local function drawAnimatedBackground(texture)
    local draw = imgui.GetWindowDrawList()
    local winPos = imgui.GetWindowPos()
    local winSize = imgui.GetWindowSize()

    local imgW, imgH = 1000, 563
    local pulse = math.sin(os.clock() * 2) * 10
    local scale = 1.0 + (math.sin(os.clock() * 1.5) * 0.05)

    local finalW = imgW * scale
    local finalH = imgH * scale

    -- POSIÇÃO NA DIREITA
    local posX = winPos.x + winSize.x - finalW - 20  

    -- POSIÇÃO EMBAIXO
    local posY = winPos.y + winSize.y - finalH - 20  

    draw:AddImage(
        texture,
        imgui.ImVec2(posX, posY + pulse),
        imgui.ImVec2(posX + finalW, posY + finalH + pulse),
        imgui.ImVec2(0, 0),
        imgui.ImVec2(1, 1),
        0xFFFFFFFF
    )
end

local direction = 1
local textPos = 0

function movingText(text)
    local r,g,b = RGB(2.0)
    local winW = imgui.GetWindowWidth()
    local textW = imgui.CalcTextSize(text).x
    local speed = 150 * imgui.GetIO().DeltaTime
    local rightWall = winW - 300    
    textPos = textPos + direction * speed
    if textPos + textW >= rightWall then
        textPos = rightWall - textW
        direction = -1
    end
    if textPos <= 0 then
        textPos = 0
        direction = 1
    end
    imgui.SetCursorPosX(textPos)
    imgui.SetCursorPosY(13)    
    imgui.Text(text)
end

imgui.OnFrame(function() return window[0]  end,
    function(menu)
      imgui.SetNextWindowSize(imgui.ImVec2(900,850))
      if imgui.Begin("##Menu", window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar) then
        local r,g,b = RGB(2.0)
        drawRainBackground()
        
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.5, 0.5, 0.5, 1))
        
        Aimbot()  
        imgui.SetWindowFontScale(1.8)
        imgui.PushFont(fonte)
        local text = "Ackles Menu"
        movingText(text)
        imgui.SetWindowFontScale(1.0)
        drawAnimatedBackground(fundo)
        local w = imgui.GetWindowWidth()
        imgui.SameLine()
        imgui.SetCursorPosX(w - 82)
        imgui.SetCursorPosY(13)
          
        if imgui.ImageButton(close, imgui.ImVec2(55,55)) then
          window[0] = false
        end
          
        imgui.SameLine()
        imgui.SetCursorPosX(w - 153)
        imgui.SetCursorPosY(13)
          -- imagem discord 
        
        if imgui.ImageButton(discord, imgui.ImVec2(55,55)) then
          abrirlink("https://discord.gg/9Jvwa3brt")
        end
          
        imgui.SameLine()
        imgui.SetCursorPosX(w - 220)
        imgui.SetCursorPosY(13)
          -- imagem instagram 
        
        if imgui.ImageButton(instagram, imgui.ImVec2(55,55)) then
          abrirlink("https://instagram.com/ackles.lua")
        end
        
        imgui.SameLine()
        imgui.SetCursorPosX(w - 290)
        imgui.SetCursorPosY(13)
        
        if imgui.ImageButton(youtube, imgui.ImVec2(55,55)) then
          abrirlink("https://youtube.com/@acklessamp?si=V7OErVxd2ubJuLle")
        end
        -- MENU
        imgui.Columns(2, "##Menu", false)
        imgui.SetColumnWidth(0, 190)
        for i, name in ipairs(opcoes_menu) do
            if imgui.Button(name, imgui.ImVec2(170,100)) then
                current_lab = i
            end
            imgui.Spacing()
        end
          imgui.NextColumn()
      end
      imgui.BeginChild("##RightPanel", imgui.ImVec2(0,0), false, 0)
        if current_lab == 2 then
          r,g,b = RGB(2.0)
          imgui.SetWindowFontScale(1.5)
          
ackles.esp_ativo[0] = true
            imgui.TextColored(imgui.ImVec4(r,g,b,1),"ESPS:")
          imgui.Spacing()
          
          imgui.SetWindowFontScale(1.3)
          
          imgui.Text("ESP NAME")
          imgui.SameLine()
          imgui.Switch("esp_name",
                ackles.esp_name[0]
                ,80, 35,
                function(newState)
                  ackles.esp_name[0] = newState
                end)
          
          imgui.Text("ESP ID ")
          imgui.SameLine()
          imgui.Switch("esp_id",
                ackles.esp_id[0]
                ,80, 35,
                function(newState)
                  ackles.esp_id[0] = newState
                end)
          
          imgui.Text("ESP ESQUELETO ")
          imgui.SameLine()
          imgui.Switch("espE",
                ackles.esp_e[0]
                ,80, 35,
                function(newState)
                  ackles.esp_e[0] = newState
                end)
          
          imgui.Text("ESP LINHAS ")
          imgui.SameLine()
          imgui.Switch("espL",
                ackles.esp_linhas[0]
                ,80, 35,
                function(newState)
                  ackles.esp_linhas[0] = newState
                end)
          
          imgui.Text("ESP DISTANCIA ")
          imgui.SameLine()
          imgui.Switch("espD",
                ackles.dist[0]
                ,80, 35,
                function(newState)
                  ackles.dist[0] = newState
                end)
          
          imgui.Text("ESP CAIXAS ")
          imgui.SameLine()
          imgui.Switch("EspCaix",
                ackles.esp_box[0]
                ,80, 35,
                function(newState)
                  ackles.esp_box[0] = newState
                end)
          
          
          imgui.Text("ESP CARROS")
          imgui.SameLine()
          imgui.Switch("espCarK",
                ackles.esp_carro[0]
                ,80, 35,
                function(newState)
                  ackles.esp_carro[0] = newState
                end)
          
          
          imgui.Text("ESP ADMIN Line")
          imgui.SameLine()
          imgui.Switch("espAdmLine",
                ackles.esp_adm[0]
                ,80, 35,
                function(newState)
                  ackles.esp_adm[0] = newState
                end)
          
          
          imgui.SetWindowFontScale(1.0)
        end
        if current_lab == 3 then
          imgui.SetWindowFontScale(1.5)
          local r,g,b = RGB(2.0)
          imgui.TextColored(imgui.ImVec4(r,g,b,1), "TELEPORTS: ")
          
          imgui.Text("BYPPAS?")
          imgui.SameLine()
          imgui.Switch("byppasjj",
          tps.byppas[0]
          ,80, 35,
          function(newState)
            tps.byppas[0] = newState
          end)
          
          imgui.SetWindowFontScale(1.3)
          imgui.Text("PREFEITURA")
          imgui.SameLine()
          imgui.Switch("pr",
          tps.one[0]
          ,80, 35,
          function(newState)
            tps.one[0] = newState
          end)  
              
          imgui.Text("MERCADO NEGRO")
          imgui.SameLine()
          imgui.Switch("mc",
          tps.two[0]
          ,80, 35,
          function(newState)
            tps.two[0] = newState
          end)  
            
          imgui.Text(" LAVAGEM")
          imgui.SameLine()
          imgui.Switch("teste",
          tps.tree[0]
          ,80, 35,
          function(newState)
            tps.tree[0] = newState
          end)  
              
          imgui.Text("HOTEL BPS")
          imgui.SameLine()
          imgui.Switch("ht",
          tps.four[0]
          ,80, 35,
          function(newState)
            tps.four[0] = newState
          end)
          
          imgui.SetWindowFontScale(1.0)
          
          if tps.one[0] then
            local x,y,z = 1480.4487304688, -1769.2985839844,  18.7890625
            teleport(x,y,z)
          end
          if tps.two[0] then
            local x,y,z = 2219.3759765625, -2665.8171386719, 13.551446914673
            teleport(x,y,z)
          end
          if tps.tree[0] then
            local x,y,z = 663.26171875, 1716.458984375, 7.1875
            teleport(x,y,z)
          end
          if tps.four[0] then
            local x,y,z = 2231.2377929688, -1160.7766113281, 25.826442718506
            teleport(x,y,z)
          end
          
        end
        if current_lab == 6 then
          dar_arma()
          recarregar_rapido()
          imgui.SetWindowFontScale(1.5)
          local r,g,b = RGB(2.0)
          imgui.TextColored(imgui.ImVec4(r,g,b,1), "ARMAS:")
          imgui.SetWindowFontScale(1.4)
          
          imgui.Text("RECARREGAR RAPIDO ")
          imgui.SameLine()
          imgui.Switch("Rwcarr",
                player.fastreload[0]
                ,80, 35,
                function(newState)
                  player.fastreload[0] = newState
                end)
          
          imgui.Text("PUXAR DESERT")
          imgui.SameLine()
          imgui.Switch("desert",
          armas.arma1[0]
          ,80, 35,
          function(newState)
            armas.arma1[0] = newState
          end)
          
          imgui.Text("PUXAR M4A1")
          imgui.SameLine()
          imgui.Switch("m4a1",
          armas.arma3[0]
          ,80, 35,
          function(newState)
            armas.arma3[0] = newState
          end)
          imgui.Text("PUXAR RPG")
          imgui.SameLine()
          imgui.Switch("puxrpg",
          armas.arma6[0]
          ,80, 35,
          function(newState)
            armas.arma6[0] = newState
          end)
          imgui.Text("PUXAR AK47")
          imgui.SameLine()
          imgui.Switch("puxak47",
          armas.arma5[0]
          ,80, 35,
          function(newState)
            armas.arma5[0] = newState
          end)
          imgui.Text("PUXAR DOZE")
          imgui.SameLine()
          imgui.Switch("dozij",
          armas.arma7[0]
          ,80, 35,
          function(newState)
            armas.arma7[0] = newState
          end)
          
          imgui.Text("PUXAR MP5")
          imgui.SameLine()
          imgui.Switch("Mp5",
          armas.arma2[0]
          ,80, 35,
          function(newState)
            armas.arma2[0] = newState
          end)
          imgui.Text("PUXAR Sniper")
          imgui.SameLine()
          imgui.Switch("sniper",
          armas.arma4[0]
          ,80, 35,
          function(newState)
            armas.arma4[0] = newState
          end)
          imgui.InputInt(" ", id_arma)
          local id_armaP = id_arma[0]
          imgui.Dummy(imgui.ImVec2(0,10))
          if imgui.Button("PUXAR ARMA POR ID") then
            giveWeaponToChar(PLAYER_PED, id_armaP, 100)
          end
          imgui.SetWindowFontScale(1.0)
        end
          
        if current_lab == 4 then
          roubar()
          imgui.SetWindowFontScale(1.5)
          local r,g,b = RGB(2.0)
          imgui.TextColored(imgui.ImVec4(r,g,b,1), "FARMS:")
          imgui.SetWindowFontScale(1.3)
          imgui.Text("FARM NAVIO")
          imgui.SameLine()
          imgui.Switch("FarmNavio",
                farm.roubar[0]
                ,80, 35,
                function(newState)
                  farm.roubar[0] = newState
                end)
          imgui.SetWindowFontScale(1.0)
        end
        if current_lab == 7 then
          imgui.Dummy(imgui.ImVec2(0,70))
          imgui.Text("EM BREVE! ")
        end
        if current_lab == 1 then
          add_vida()
          add_colete()
          local r,g,b = RGB(2.0)
          imgui.SetWindowFontScale(1.5)
          imgui.TextColored(imgui.ImVec4(r,g,b,1), "BEM VINDO!")
          imgui.SetWindowFontScale(1.3)
          
          imgui.Text("SETAR VIDA ")
          imgui.SameLine()
          imgui.Switch("vida",
                player.vida[0]
                ,80, 35,
                function(newState)
                  player.vida[0] = newState
                end)
          
          imgui.Text("PUXAR COLETE")
          imgui.SameLine()
          imgui.Switch("PusxColete",
                player.colete[0]
                ,80, 35,
                function(newState)
                  player.colete[0] = newState
                end)
          
          imgui.Text("GOD MODE")
          imgui.SameLine()
          imgui.Switch("godmodejk",
                player.god[0]
                ,80, 35,
                function(newState)
                  player.god[0] = newState
                end)
          
          
          imgui.Text("ATRAVESSAR PLAYERS")
          imgui.SameLine()
          imgui.Switch("atra",
                player.atravessar_player[0]
                ,80, 35,
                function(newState)
                  player.atravessar_player[0] = newState
                end)
          
          imgui.Text("CORRER RAPIDO")
          imgui.SameLine()
          imgui.Switch("correr",
                player.correr_rapido[0]
                ,80, 35,
                function(newState)
                  player.correr_rapido[0] = newState
                end)
          
          imgui.Text("CORRER SEM CANSAR")
          imgui.SameLine()
          imgui.Switch("correrSemCansar",
                player.nao_cansar[0]
                ,80, 35,
                function(newState)
                  player.nao_cansar[0] = newState
                end)
          
          
          imgui.Text("AUTO CGUG MOBILE")
          imgui.SameLine()
          imgui.Switch("autocibs",
                cbugs.cbug[0]
                ,80, 35,
                function(newState)
                  cbugs.cbug[0] = newState
                end)
          
          imgui.SetWindowFontScale(1.0)
        end
        if current_lab == 5 then
          local r,g,b = RGB(2.0)
          imgui.SetWindowFontScale(1.5)
            imgui.TextColored(imgui.ImVec4(r,g,b,1), "AIMBOTS")
          imgui.Spacing()
          imgui.SetWindowFontScale(1.0)
            imgui.SetWindowFontScale(1.3)
            imgui.Text("Aimbot Cabeca")
            imgui.SameLine()
            imgui.Switch("aimbot",
                sulist.cabecaAIM[0]
                ,80, 35,
                function(newState)
                  sulist.cabecaAIM[0] = newState
                end)
          
          imgui.Text("Aimbot Peito")
          imgui.SameLine()
          imgui.Switch("aimbotP",
                sulist.peitoAIM[0]
                ,80, 35,
                function(newState)
                  sulist.peitoAIM[0] = newState
                end)
          imgui.Text("Aimbot braco")
          imgui.SameLine()
          imgui.Switch("aimbotB",
                sulist.bracoAIM[0]
                ,80, 35,
                function(newState)
                  sulist.bracoAIM[0] = newState
                end)
          
          imgui.Text("puxar player")
          imgui.SameLine()
          imgui.Switch("puxKkk",
                sulist.PROAIM2[0]
                ,80, 35,
                function(newState)
                  sulist.PROAIM2[0] = newState
                end)
          
            imgui.SetWindowFontScale(1.0)  
        end
      imgui.EndChild()
      imgui.End()
      
    end)
function main()
  while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand("menu", function() window[0] = true end)
  while true do
    wait(0)
    lua_thread.create(Aimbot)
    lua_thread.create(esp_esqueleto)
    lua_thread.create(recarregar_rapido)
    lua_thread.create(correrRapido)
    lua_thread.create(god)
    lua_thread.create(lifefootmob)
    lua_thread.create(atravessar_players)
    
    
    if ackles.esp_ativo[0] then
      local myx,myy,myz = getCharCoordinates(PLAYER_PED)
      local mx,my = convert3DCoordsToScreen(myx,myy,myz)
      local font = renderCreateFont("Arial", 11, 0)
      for id = 0, 400 do
        local result, ped = sampGetCharHandleBySampPlayerId(id)
        if result and doesCharExist(ped) then
          local name = sampGetPlayerNickname(id)
          local text = string.format("%s", name)
          local x,y,z = getCharCoordinates(ped)
          local sx,sy = convert3DCoordsToScreen(x,y,z+ 0.6)
          local dist = getDistanceBetweenCoords3d(x,y,z,myx,myy,myz)
          
          if isPointOnScreen(x,y,z,1) then
            if ackles.esp_name[0] then
              renderFontDrawText(font, text, sx,sy, 0xFFFFFFFF)
            end
            if ackles.esp_box[0] then
              local footX, footY = convert3DCoordsToScreen(x, y, z - 1.0)
              
              local headX, headY = convert3DCoordsToScreen(x, y, z + 1.0)
              if isPointOnScreen(x, y, z, 1) then
                local height = math.abs(headY - footY)
                local width = height / 3
                local left   = footX - width
                local right  = footX + width
                local top    = headY
                local bottom = footY
                
                renderDrawLine(left,  top,    right, top,    1.7, 0xFFFFFFFF)
                renderDrawLine(left,  bottom, right, bottom, 1.7, 0xFFFFFFFF)
                renderDrawLine(left,  top,    left,  bottom, 1.7, 0xFFFFFFFF)
                renderDrawLine(right, top,    right, bottom, 1.7, 0xFFFFFFFF)
              end
            end
            if ackles.esp_linhas[0] then
              local x,y = getScreenResolution()
              renderDrawLine(x/2,y-10,sx,sy,1.5, 0xFFFFFFFF)
            end
            if ackles.dist[0] then
              local d = getDistanceBetweenCoords3d(x,y,z,myx,myy,myz)
              local font = renderCreateFont("Arial", 11, 0)
              local text = string.format("DIST: %d", tostring(d))
              renderFontDrawText(font, text, sx+20,sy+30, 0xFFFFFFFF)
            end
          end
          if ackles.esp_carro[0] then
            local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)
            local x, y = convert3DCoordsToScreen(playerX, playerY, playerZ)
            for k, i in ipairs(getAllVehicles()) do
              if isCarOnScreen(i) then
                local carX, carY, carZ = getCarCoordinates(i)
                local px, py = convert3DCoordsToScreen(carX, carY, carZ)
                local thickness = 2
                renderDrawLine(x, y, px, py, thickness, 0xFFFFFFFF)
              end
            end
          end
          if ackles.esp_adm[0] then
            local cor = rgbRainbowHex(2.0,1)
            local nick = sampGetPlayerNickname(id)
            local tx,ty = getScreenResolution()
              if isPointOnScreen(x,y,z,1) then
                if nick == string.find(nick, "Staff") or string.find(nick, "Staff") or string.find(nick, "Helper") or string.find(nick, "Admin") or string.find(nick, "admin") or string.find(nick, "helper") then
                  renderDrawLine(tx/2, ty - 10, sx,sy, 1.6, cor )
                end
              end
          end
          if ackles.esp_id[0] then
            local font = renderCreateFont("Arial", 11,0)
            if result then
              local result, id = sampGetPlayerIdByCharHandle(ped)
              local x,y,z = getCharCoordinates(ped)
              local text = string.format("%s", id)
              if isPointOnScreen(x,y,z,1) then
                renderFontDrawText(font, text, sx+15,sy, 0xFFFFFFFF)
              end
            end
          end
        end
      end
    end
  end
end