-- Optional always-visible button: click it to open the wheel, drag it to place it anywhere.

local _, ns = ...

local Util, DB, L = ns.Util, ns.DB, ns.L

local WheelButton = {}
ns.WheelButton = WheelButton

-- Same look as the minimap buttons: round icon in the gold tracking ring.
local ICON = "Interface\\Icons\\inv_misc_gear_01"
local BACKGROUND = "Interface\\Minimap\\UI-Minimap-Background"
local BORDER = "Interface\\Minimap\\MiniMap-TrackingBorder"
local HIGHLIGHT = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
local SIZE = 31
local BASE_SCALE = 1.5 -- the "100%" of the size option
local DEFAULT_OFFSET_X = 250 -- from the screen center, until the player moves it

local button
local wasDragged = false

-- Center of the button in UIParent coordinates (what DB stores and Popup.Open expects).
local function GetCenterInScreen()
	local x, y = button:GetCenter()
	local ratio = button:GetEffectiveScale() / UIParent:GetEffectiveScale()
	return x * ratio, y * ratio
end

local function Place()
	local settings = DB.GetButton()
	local scale = settings.scale * BASE_SCALE
	local point = settings.point
	button:SetScale(scale)
	button:ClearAllPoints()
	if point then
		button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", point.x / scale, point.y / scale)
	else
		button:SetPoint("CENTER", UIParent, "CENTER", DEFAULT_OFFSET_X / scale, 0)
	end
end

local function OnDragStart()
	if DB.GetButton().locked then return end
	wasDragged = true
	GameTooltip:Hide()
	button:StartMoving()
end

local function OnDragStop()
	button:StopMovingOrSizing()
	DB.SetButtonPoint(GetCenterInScreen())
	Place() -- re-anchor to the saved point so the scale option keeps the button in place
end

local function OnClick(_, mouseButton)
	if wasDragged or mouseButton ~= "LeftButton" then return end
	ns.Popup.Open(GetCenterInScreen())
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:SetText(L.bindingName)
	if not DB.GetButton().locked then
		GameTooltip:AddLine(L.buttonDragTip, 1, 1, 1)
	end
	GameTooltip:Show()
end

local function Create()
	button = CreateFrame("Button", "EmotesCompassButton", UIParent)
	button:SetSize(SIZE, SIZE)
	button:SetFrameStrata("MEDIUM")
	button:SetClampedToScreen(true)
	button:SetMovable(true)
	button:SetDontSavePosition(true) -- the position lives in EmotesCompassDB (see DB.SetButtonPoint)
	button:RegisterForClicks("LeftButtonUp")
	button:RegisterForDrag("LeftButton")

	local background = button:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(BACKGROUND)
	background:SetSize(20, 20)
	background:SetPoint("TOPLEFT", 7, -5)

	local icon = Util.CreateRoundIcon(button, "ARTWORK")
	icon:SetTexture(ICON)
	icon:SetSize(17, 17)
	icon:SetPoint("TOPLEFT", 7, -6)

	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetTexture(BORDER)
	border:SetSize(50, 50)
	border:SetPoint("TOPLEFT")

	button:SetHighlightTexture(HIGHLIGHT)

	button:SetScript("OnMouseDown", function() wasDragged = false end)
	button:SetScript("OnDragStart", OnDragStart)
	button:SetScript("OnDragStop", OnDragStop)
	button:SetScript("OnClick", OnClick)
	button:SetScript("OnEnter", OnEnter)
	button:SetScript("OnLeave", GameTooltip_Hide)
end

-- Applies the saved settings (visibility, size, position). Call after any of them changes.
function WheelButton.Refresh()
	local settings = DB.GetButton()
	if not button then
		if not settings.shown then return end
		Create()
	end
	Place()
	button:SetShown(settings.shown)
end
