-- The in-game wheel: lives only while the key is held; releasing it performs the hovered emote.

local _, ns = ...

local Util, DB, Catalog = ns.Util, ns.DB, ns.Catalog

local Popup = {}
ns.Popup = Popup

local SCALE = 0.8
local OPEN_DURATION = 0.15
local OPEN_START_SCALE = 0.9 -- fraction of SCALE the wheel grows from while it fades in

local root, view
local openProgress = 0
local anchorX, anchorY = 0, 0 -- where the wheel opened, in root coordinates

local function PlaceView(scale)
	view:SetScale(scale)
	view:ClearAllPoints()
	view:SetPoint("CENTER", root, "BOTTOMLEFT", anchorX / scale, anchorY / scale)
end

-- Closes the wheel, performing the hovered emote if any.
local function Release()
	local index = view:GetSlotAtCursor()
	local token = index and view.tokens[index]
	root:Hide()
	if token then Catalog.Perform(token) end
end

local function AnimateOpening(elapsed)
	openProgress = math.min(1, openProgress + elapsed / OPEN_DURATION)
	local eased = 1 - (1 - openProgress) ^ 3
	view:SetAlpha(eased)
	PlaceView(SCALE * (OPEN_START_SCALE + (1 - OPEN_START_SCALE) * eased))
end

local function OnUpdate(_, elapsed)
	if openProgress < 1 then AnimateOpening(elapsed) end

	local index = view:GetSlotAtCursor()
	if view:SetHighlight(index) and index then
		Util.PlaySound("U_CHAT_SCROLL_BUTTON")
	end
	view:UpdateHover(elapsed)
end

local function Create()
	-- Invisible full-screen catcher: takes the clicks while the wheel is open.
	root = CreateFrame("Frame", "EmoteCompassFrame", UIParent)
	root:SetAllPoints(UIParent)
	root:SetFrameStrata("FULLSCREEN_DIALOG")
	root:EnableMouse(true)
	root:Hide()
	tinsert(UISpecialFrames, "EmoteCompassFrame") -- Escape closes it

	view = ns.WheelView.Create(root, { showCancel = true })
	view:SetClampedToScreen(true)

	root:SetScript("OnUpdate", OnUpdate)
	root:SetScript("OnMouseDown", function(_, button)
		if button == "LeftButton" then Release() else root:Hide() end
	end)
end

-- Opens the wheel centered on (x, y) in UIParent coordinates, or under the cursor when omitted.
-- With the key held it closes on release; otherwise it stays open until the player picks an emote,
-- right-clicks or presses Escape.
function Popup.Open(x, y)
	if not root then Create() end
	if root:IsShown() then return end

	if x then
		anchorX, anchorY = x, y
	else
		anchorX, anchorY = Util.GetCursorIn(root)
	end
	openProgress = 0
	PlaceView(SCALE)
	view:ResetHover()
	view:SetTokens(DB.GetSlots())

	root:Show()
	Util.PlaySound("IG_MAINMENU_OPEN")
end

-- Opens the wheel under the cursor, or at the screen center when the cursor is hidden (mouse-look).
-- Used by /ec show: it stays open until the player picks an emote, right-clicks or presses Escape.
function Popup.Show()
	if IsMouselooking() then
		Popup.Open(UIParent:GetWidth() / 2, UIParent:GetHeight() / 2)
	else
		Popup.Open()
	end
end

-- Key binding handler (see Bindings.xml / Init.lua): called on key down and key up.
function Popup.OnBinding(keystate)
	if keystate == "down" then
		Popup.Open()
	elseif root and root:IsShown() then
		Release()
	end
end
