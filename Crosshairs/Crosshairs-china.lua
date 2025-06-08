--local LibNameplates = LibStub("LibNameplates-1.0")
--if not LibNameplates then return end
--此版本归功于bkader，我只是基于awesome得api使用正式服得代码改写。oliveria

local alpha = 0.75 -- Overall alpha
local speed = 0.1 -- seconds to fade textures in and out
local lineAlpha = 0.5 -- Set to 0 to hide lines but keep the circle

-- 添加锚点位置偏移变量
local offsetX = 0   -- 水平偏移量（正数向右，负数向左）
local offsetY = 15  -- 垂直偏移量（正数向上，负数向下）
-- 添加焦点框架偏移变量
local focusOffsetY = 20  -- 焦点框架垂直偏移（正数向上，负数向下）

-- 焦点目标高亮设置
local focusAlpha = 0.9 -- 焦点边框透明度
local focusBorderWidth = 80   -- 焦点边框宽度
local focusBorderHeight = 20  -- 焦点边框高度
local focusBorderTexture = [[Interface\AddOns\Crosshairs\Media\nameplate_glow]] -- 替换为您的边框材质路径

local UIFrameFadeIn = UIFrameFadeIn
local CreateFrame = CreateFrame
local tonumber = tonumber
local strmatch = strmatch or string.match
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsUnit = UnitIsUnit
local UnitSelectionColor = UnitSelectionColor
local GetScreenResolutions = GetScreenResolutions
local GetCurrentResolution = GetCurrentResolution

local function GetPhysicalScreenSize()
    local width, height = strmatch(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)x(%d+)")
    return tonumber(width), tonumber(height)
end

-- 创建主准星框架
local f = CreateFrame("frame", "Crosshairs", UIParent)
f:SetFrameLevel(0)
f:SetFrameStrata("BACKGROUND")
f:SetPoint("CENTER")

-- 创建焦点目标高亮框架
local focusFrame = CreateFrame("frame", "CrosshairsFocus", UIParent)
focusFrame:SetFrameLevel(1)
focusFrame:SetFrameStrata("BACKGROUND")
focusFrame:Hide()

local uiScale = 2
local screen_size = {GetPhysicalScreenSize()}
if screen_size and screen_size[2] then
    uiScale = 768 / screen_size[2]
end
local lineWidth = uiScale * 2
f:SetSize(64 * uiScale, 64 * uiScale)


-- 修改焦点框架大小计算
local focusWidth = 64 * uiScale + focusBorderWidth * 2
local focusHeight = 64 * uiScale + focusBorderHeight * 2
focusFrame:SetSize(focusWidth, focusHeight)

local circle = UIParent:CreateTexture(nil, "ARTWORK")
circle:SetTexture([[Interface\AddOns\Crosshairs\circle]])
circle:SetAllPoints(f)
circle:SetAlpha(alpha)

-- 创建焦点边框纹理
local focusBorder = focusFrame:CreateTexture(nil, "OVERLAY")
focusBorder:SetTexture(focusBorderTexture)
focusBorder:SetAllPoints(focusFrame)
focusBorder:SetAlpha(focusAlpha)
focusBorder:SetBlendMode("ADD")

local left = f:CreateTexture(nil, "ARTWORK")
left:SetTexture([[Interface\Buttons\WHITE8X8]])
left:SetVertexColor(1, 1, 1, alpha)
left:SetPoint("RIGHT", f, "LEFT", 8, 0)
left:SetSize(2000, lineWidth)

local right = f:CreateTexture(nil, "ARTWORK")
right:SetTexture([[Interface\Buttons\WHITE8X8]])
right:SetVertexColor(1, 1, 1, alpha)
right:SetPoint("LEFT", f, "RIGHT", -8, 0)
right:SetSize(2000, lineWidth)

local top = f:CreateTexture(nil, "ARTWORK")
top:SetTexture([[Interface\Buttons\WHITE8X8]])
top:SetVertexColor(1, 1, 1, alpha)
top:SetPoint("BOTTOM", f, "TOP", 0, -8)
top:SetSize(lineWidth, 2000)

local bottom = f:CreateTexture(nil, "ARTWORK")
bottom:SetTexture([[Interface\Buttons\WHITE8X8]])
bottom:SetVertexColor(1, 1, 1, alpha)
bottom:SetPoint("TOP", f, "BOTTOM", 0, 8)
bottom:SetSize(lineWidth, 2000)

circle:SetBlendMode("ADD")
left:SetBlendMode("ADD")
right:SetBlendMode("ADD")
top:SetBlendMode("ADD")
bottom:SetBlendMode("ADD")

local tx = UIParent:CreateTexture(nil, "ARTWORK")
tx:SetTexture([[Interface\AddOns\Crosshairs\arrows]])
tx:SetAllPoints(f)

local ag = tx:CreateAnimationGroup()
local rotation = ag:CreateAnimation("Rotation")
rotation:SetDegrees(-360)
rotation:SetDuration(5)
ag:SetLooping("REPEAT")

-- 焦点边框动画组
local focusAg = focusBorder:CreateAnimationGroup()
local focusScale = focusAg:CreateAnimation("Scale")
focusScale:SetScale(1, 1)
focusScale:SetDuration(1)
focusScale:SetSmoothing("IN_OUT")
local focusAlphaAnim = focusAg:CreateAnimation("Alpha")
focusAlphaAnim:SetFromAlpha(focusAlpha)
focusAlphaAnim:SetToAlpha(focusAlpha * 0.7)
focusAlphaAnim:SetDuration(1)
focusAg:SetLooping("BOUNCE")

local function HideEverything()
    UIFrameFadeIn(circle, speed, alpha, 0)
    UIFrameFadeIn(left, speed, lineAlpha, 0)
    UIFrameFadeIn(right, speed, lineAlpha, 0)
    UIFrameFadeIn(top, speed, lineAlpha, 0)
    UIFrameFadeIn(bottom, speed, lineAlpha, 0)
    UIFrameFadeIn(tx, speed, alpha, 0)
    ag:Stop()
    f.plate = nil
end

local function HideFocus()
    focusBorder:SetAlpha(0)
    focusFrame:Hide()
    focusAg:Stop()
end

local function ShowEverything()
    UIFrameFadeIn(circle, speed, 0, alpha)
    UIFrameFadeIn(left, speed, 0, lineAlpha)
    UIFrameFadeIn(right, speed, 0, lineAlpha)
    UIFrameFadeIn(top, speed, 0, lineAlpha)
    UIFrameFadeIn(bottom, speed, 0, lineAlpha)
    UIFrameFadeIn(tx, speed, 0, alpha)
    ag:Play()
end

f:HookScript("OnHide", HideEverything)
f:HookScript("OnShow", ShowEverything)
f:Hide()

local function SetColor(r, g, b)
    circle:SetVertexColor(r, g, b)
    left:SetVertexColor(r, g, b)
    right:SetVertexColor(r, g, b)
    top:SetVertexColor(r, g, b)
    bottom:SetVertexColor(r, g, b)
    tx:SetVertexColor(r, g, b)
end

local function SetFocusColor(r, g, b)
    focusBorder:SetVertexColor(r, g, b)
end

-- 焦点目标高亮函数
local function FocusHighlight(plate, isFocus)
    if isFocus then
        focusFrame:ClearAllPoints()
        -- 添加垂直偏移量到焦点框架
        focusFrame:SetPoint("CENTER", plate, 0, focusOffsetY)
        focusFrame:Show()
        focusBorder:SetAlpha(focusAlpha)
        focusAg:Play()
        
        local r, g, b
        if UnitIsPlayer('focus') then
            local _, class = UnitClass('focus')
            if class and RAID_CLASS_COLORS[class] then
                local colors = RAID_CLASS_COLORS[class]
                r, g, b = colors.r, colors.g, colors.b
            else
                r, g, b = 1, 0.84, 0 -- 金色焦点边框
            end
        else
            r, g, b = 0, 1, 1 -- 青色焦点边框
        end
        SetFocusColor(r, g, b)
    else
        HideFocus()
    end
end

-- 调整目标准星位置
local function FocusPlate(plate)
    f:ClearAllPoints()
    -- 应用偏移量到锚点位置
    f:SetPoint("CENTER", plate, offsetX, offsetY)
    f:Show()
    f.plate = plate
    
    local r, g, b = 1, 1, 1
    if UnitIsTapDenied('target') then
        r, g, b = 0.5, 0.5, 0.5
    elseif UnitIsPlayer('target') then
        local _, class = UnitClass('target')
        if class and RAID_CLASS_COLORS[class] then
            local colors = RAID_CLASS_COLORS[class]
            r, g, b = colors.r, colors.g, colors.b
        else
            r, g, b = 0.274, 0.705, 0.392
        end
    else
        r, g, b = UnitSelectionColor('target')
    end
    SetColor(r, g, b)
end

function f:PLAYER_TARGET_CHANGED()
    local nameplate = C_NamePlate.GetNamePlateForUnit('target')
    if nameplate then
        FocusPlate(nameplate)
    else
        self.plate = nil
        self:Hide()
    end
end
f:RegisterEvent('PLAYER_TARGET_CHANGED')

-- 焦点目标变化事件
function f:PLAYER_FOCUS_CHANGED()
    local focusPlate = C_NamePlate.GetNamePlateForUnit('focus')
    if focusPlate then
        FocusHighlight(focusPlate, true)
    else
        HideFocus()
    end
end
f:RegisterEvent('PLAYER_FOCUS_CHANGED')

function f:PLAYER_ENTERING_WORLD()
    self:PLAYER_TARGET_CHANGED()
    self:PLAYER_FOCUS_CHANGED()
end
f:RegisterEvent('PLAYER_ENTERING_WORLD')

local xFactor, yFactor = 1, 1
function ScaleCoords(xPixel, yPixel, trueScale)
    local x, y  = xPixel / xFactor, yPixel / yFactor
    x, y = x - x % 1, y - y % 1
    return trueScale and (xPixel * xFactor) or (x * xFactor), trueScale and (xPixel * xFactor) or (y * yFactor)
end

function f:NAME_PLATE_UNIT_ADDED(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate then
        if UnitIsUnit('target', unit) then
            FocusPlate(nameplate)
        end
        if UnitIsUnit('focus', unit) then
            FocusHighlight(nameplate, true)
        end
    end
end
f:RegisterEvent('NAME_PLATE_UNIT_ADDED')

function f:NAME_PLATE_UNIT_REMOVED(unit)
    if UnitIsUnit('target', unit) then
        self.plate = nil
        self:Hide()
    end
    if UnitIsUnit('focus', unit) then
        HideFocus()
    end
end
f:RegisterEvent('NAME_PLATE_UNIT_REMOVED')

f:SetScript('OnEvent', function(self, event, ...) 
    return self[event] and self[event](self, ...) 
end)