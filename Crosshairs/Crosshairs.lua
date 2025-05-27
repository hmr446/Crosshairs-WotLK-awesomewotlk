--local LibNameplates = LibStub("LibNameplates-1.0")
--if not LibNameplates then return end
--此版本归功于bkader，我只是基于awesome得api使用正式服得代码改写。oliveria

local alpha = 0.75 -- Overall alpha
local speed = 0.1 -- seconds to fade textures in and out
local lineAlpha = 0.5 -- Set to 0 to hide lines but keep the circle

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

local f = CreateFrame("frame", "Crosshairs", UIParent)
f:SetFrameLevel(0)
f:SetFrameStrata("BACKGROUND")
f:SetPoint("CENTER")

local uiScale = 1
local screen_size = {GetPhysicalScreenSize()}
if screen_size and screen_size[2] then
	uiScale = 768 / screen_size[2]
end
local lineWidth = uiScale * 2
f:SetSize(64 * uiScale, 64 * uiScale)

local circle = UIParent:CreateTexture(nil, "ARTWORK")
circle:SetTexture([[Interface\AddOns\Crosshairs\circle]])
circle:SetAllPoints(f)
circle:SetAlpha(alpha)

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

-- Adjust line alpha based on combat status
local function SetLineAlpha(alpha)
	left:SetAlpha(alpha)
	right:SetAlpha(alpha)
	top:SetAlpha(alpha)
	bottom:SetAlpha(alpha)
end

-- Initial state
SetLineAlpha(lineAlpha)

-- fade in if our crosshairs weren't visible
-- fade in if our crosshairs weren't visible
local Moving = false
local function FocusPlate(plate)
	f:ClearAllPoints()
	f:SetPoint("CENTER", plate)
	f:Show()
	f.plate = plate
	
	local r, g, b = 1, 1, 1
	--if UnitIsTapped('target') and not UnitIsTappedByPlayer('target') and not UnitIsTappedByAllThreatList('target') then
	if UnitIsTapDenied('target') then
		--SetColor(0.5, 0.5, 0.5)
		r, g, b = 0.5, 0.5, 0.5
	elseif UnitIsPlayer('target') then
		local _, class = UnitClass('target')
		if class and RAID_CLASS_COLORS[class] then
			local colors = RAID_CLASS_COLORS[class]
			r, g, b = colors.r, colors.g, colors.b
		else
			r, g, b = 0.274, 0.705, 0.392 --70/255,  180/255, 100/255
		end
	--seif UnitIsOtherPlayersPet('target') then
		-- g, b = 0.6, 0.6, 0.6
	else
		r, g, b = UnitSelectionColor('target')
	end
	SetColor(r, g, b)
	
	
	--Moving = GetTime()
end

function f:PLAYER_TARGET_CHANGED()
	local nameplate = C_NamePlate.GetNamePlateForUnit('target') --f:GetPlateByGUID(targetGUID)
	if nameplate then
		FocusPlate(nameplate)
		--rgetLock:Show()
	else
	self.plate = nil
	self:Hide()
	end
end
f:RegisterEvent('PLAYER_TARGET_CHANGED')

function f:PLAYER_ENTERING_WORLD()
	-- PLAYER_TARGET_CHANGED doesn't fire when you lose your target from zoning
	self:PLAYER_TARGET_CHANGED()
end
f:RegisterEvent('PLAYER_ENTERING_WORLD')

local xFactor, yFactor = 1, 1 -- pixel perfect stuff, just try and prevent it from screwing up our lines
function ScaleCoords(xPixel, yPixel, trueScale)
	local x, y  = xPixel / xFactor, yPixel / yFactor
	x, y = x - x % 1, y - y % 1 -- floor
	return trueScale and (xPixel * xFactor) or (x * xFactor), trueScale and (xPixel * xFactor) or (y * yFactor)
end

function f:NAME_PLATE_UNIT_ADDED(unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	if nameplate and UnitIsUnit('target', unit) then
		FocusPlate(nameplate)
		--rgetLock:Show()
	end
end
f:RegisterEvent('NAME_PLATE_UNIT_ADDED')

function f:NAME_PLATE_UNIT_REMOVED(unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	if UnitIsUnit('target', unit) then
		self.plate = nil
		self:Hide()
	end
end
f:RegisterEvent('NAME_PLATE_UNIT_REMOVED')

f:SetScript('OnEvent', function(self, event, ...) return self[event] and self[event](self, ...) end)
