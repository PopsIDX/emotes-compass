-- The in-game wheel: lives only while the key is held; releasing it performs the hovered emote.

local _, ns = ...

local Util, Catalog = ns.Util, ns.Catalog

local Popup = {}
ns.Popup = Popup

local SCALE = 0.8

-- Fixed layout until the player's own is saved.
local SLOTS = { "WAVE", "DANCE", "LAUGH", "BOW", "APPLAUD", "KISS", "SALUTE", "CRY" }

local root, view
local anchorX, anchorY = 0, 0 -- where the wheel opened, in root coordinates

local function PlaceView()
	view:ClearAllPoints()
	view:SetPoint("CENTER", root, "BOTTOMLEFT", anchorX / SCALE, anchorY / SCALE)
end

-- Closes the wheel, performing the hovered emote if any.
local function Release()
	local index = view:GetSlotAtCursor()
	local token = index and view.tokens[index]
	root:Hide()
	if token then Catalog.Perform(token) end
end

local function OnUpdate()
	view:SetHighlight(view:GetSlotAtCursor())
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
	view:SetScale(SCALE)
	view:SetClampedToScreen(true)

	root:SetScript("OnUpdate", OnUpdate)
	root:SetScript("OnMouseDown", function(_, button)
		if button == "LeftButton" then Release() else root:Hide() end
	end)
end

-- Opens the wheel under the cursor.
function Popup.Open()
	if not root then Create() end
	if root:IsShown() then return end

	anchorX, anchorY = Util.GetCursorIn(root)
	PlaceView()
	view:SetTokens(SLOTS)
	root:Show()
end

-- Key binding handler (see Bindings.xml / Init.lua): called on key down and key up.
function Popup.OnBinding(keystate)
	if keystate == "down" then
		Popup.Open()
	elseif root and root:IsShown() then
		Release()
	end
end
