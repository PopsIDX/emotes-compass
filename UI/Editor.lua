-- Wheel editor (/ec edit): the wheel on the left, the emote list on the right.
--   list  -> wedge : assign         click a row or wedge : try the emote
--   wedge -> wedge : swap           right-click a wedge  : clear it
--   wedge -> away  : clear
-- The same emote may sit on several wedges on purpose; the list only marks the ones already on the wheel.
-- Styled like the gamepad UI: no window chrome, just the wheel and a translucent card.

local _, ns = ...

local Util, DB, Catalog, L = ns.Util, ns.DB, ns.Catalog, ns.L

local Editor = {}
ns.Editor = Editor

local WIDTH, HEIGHT = 900, 560
local HEADER_HEIGHT  = 40
local WHEEL_ZONE     = 520  -- width of the wheel area, left of the list
local WHEEL_SIZE     = 460  -- on-screen size of the wheel
local WHEEL_OFFSET_Y = -10  -- nudges the wheel down, away from the header
local CARD_TOP       = 48   -- the list card starts below the header
local CARD_BOTTOM    = 8
local LIST_TOP       = 60   -- room for the search box and the hint, from the card's padded top
local ROW_HEIGHT     = 30
local LABEL_MAX      = 220  -- widest emote name in a row, leaves room for the voice icon
local VOICE_SIZE     = 18

local COLOR_ON_WHEEL = CreateColor(0.4, 1, 0.4)

local ATLAS_HEADER    = "gamepad-radial-menu-toptext"
local ATLAS_ROW_HOVER = "options_list_active"
local ATLAS_CLOSE     = "128-redbutton-exit"
local ATLAS_VOICE     = "chatframe-button-icon-voicechat"

local frame, wheel, list, searchBox, ghost
local drag -- { token = ..., fromSlot = index or nil } while dragging
local wasDragged = false -- the current mouse press turned into a drag: its release is not a click

-- Rows and wedges call this on mouse down, before any click or drag of the new press.
local function OnPressStart()
	wasDragged = false
end

---------------------------------------------------------------------------
-- Refresh
---------------------------------------------------------------------------

local function Matches(emote, text)
	return strlower(emote.command):find(text, 1, true)
		or strlower(emote.token):find(text, 1, true)
end

local function RefreshList(keepScroll)
	local text = strlower(strtrim(searchBox:GetText()))
	local entries = {}
	for _, emote in ipairs(Catalog.GetAll()) do
		if text == "" or Matches(emote, text) then
			entries[#entries + 1] = emote
		end
	end
	list:SetDataProvider(CreateDataProvider(entries), keepScroll and ScrollBoxConstants.RetainScrollPosition)
end

local function Refresh()
	wheel:SetTokens(DB.GetSlots())
	RefreshList(true) -- updates the "already on the wheel" marks
end

local function ShowEmoteTooltip(owner, token, hint)
	local emote = Catalog.Get(token)
	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
	GameTooltip:SetText(emote.command, 1, 1, 1)
	if emote.voiced then GameTooltip:AddLine(L.voiced, 0.6, 0.8, 1) end
	GameTooltip:AddLine(hint, 0.6, 0.6, 0.6)
	GameTooltip:Show()
end

---------------------------------------------------------------------------
-- Drag and drop
---------------------------------------------------------------------------

local function DropTarget()
	return wheel:GetSlotAtCursor(true, true)
end

local function StartDrag(token, fromSlot)
	if not token then return end
	wasDragged = true
	drag = { token = token, fromSlot = fromSlot }
	local emote = Catalog.Get(token)
	ghost.icon:SetTexture(emote.icon)
	ghost.label:SetText(emote.command)
	ghost:Show()
	GameTooltip:Hide()
	Util.PlaySound("U_CHAT_SCROLL_BUTTON")
end

local function FinishDrag()
	if not drag then return end
	local target = DropTarget()

	if not drag.fromSlot then
		if target then DB.SetSlot(target, drag.token) end -- duplicates are allowed
	elseif not target then
		DB.SetSlot(drag.fromSlot, nil) -- dropped off the wheel
	elseif target ~= drag.fromSlot then
		DB.SwapSlots(target, drag.fromSlot)
	end

	drag = nil
	ghost:Hide()
	Refresh()
	Util.PlaySound("IG_ABILITY_ICON_DROP")
end

local function CreateGhost()
	ghost = CreateFrame("Frame", nil, UIParent)
	ghost:SetFrameStrata("TOOLTIP")
	ghost:SetSize(40, 40)
	ghost:Hide()

	ghost.icon = Util.CreateRoundIcon(ghost)
	ghost.icon:SetAllPoints()

	ghost.label = ghost:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ghost.label:SetPoint("LEFT", ghost, "RIGHT", 6, 0)

	ghost:SetScript("OnUpdate", function(self)
		Util.MoveToCursor(self, UIParent)
		wheel:SetHighlight(DropTarget())
	end)
	ghost:SetScript("OnHide", function() wheel:SetHighlight(nil) end)
end

---------------------------------------------------------------------------
-- Emote list rows
---------------------------------------------------------------------------

local function SetupRow(row)
	row:RegisterForDrag("LeftButton")
	row:RegisterForClicks("LeftButtonUp")

	local hover = row:CreateTexture(nil, "HIGHLIGHT")
	hover:SetAtlas(ATLAS_ROW_HOVER)
	hover:SetAllPoints()

	row.icon = Util.CreateRoundIcon(row)
	row.icon:SetSize(24, 24)
	row.icon:SetPoint("LEFT", 8, 0)

	-- Sized to its text (see InitRow) so the voice icon can sit right after it.
	row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.label:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
	row.label:SetJustifyH("LEFT")
	row.label:SetWordWrap(false)

	row.voice = row:CreateTexture(nil, "OVERLAY")
	row.voice:SetAtlas(ATLAS_VOICE)
	row.voice:SetSize(VOICE_SIZE, VOICE_SIZE)
	row.voice:SetPoint("LEFT", row.label, "RIGHT", 6, 0)

	row:SetScript("OnMouseDown", OnPressStart)
	row:SetScript("OnClick", function(self)
		if not wasDragged then Catalog.Perform(self.token) end
	end)
	row:SetScript("OnDragStart", function(self) StartDrag(self.token) end)
	row:SetScript("OnDragStop", FinishDrag)
end

local function InitRow(row, emote)
	if not row.icon then SetupRow(row) end
	row.token = emote.token
	row.icon:SetTexture(emote.icon)
	row.label:SetText(emote.command)
	Util.FitText(row.label, LABEL_MAX)
	row.voice:SetShown(emote.voiced)
	local color = DB.IsOnWheel(emote.token) and COLOR_ON_WHEEL or NORMAL_FONT_COLOR
	row.label:SetTextColor(color:GetRGB())
end

---------------------------------------------------------------------------
-- Wheel wedges
---------------------------------------------------------------------------

local function SetupWedge(slot, index)
	slot:EnableMouse(true)
	slot:RegisterForDrag("LeftButton")
	slot:SetScript("OnDragStart", function() StartDrag(DB.GetSlot(index), index) end)
	slot:SetScript("OnDragStop", FinishDrag)
	slot:SetScript("OnMouseDown", OnPressStart)
	slot:SetScript("OnMouseUp", function(_, button)
		local token = DB.GetSlot(index)
		if not token or wasDragged then return end
		if button == "RightButton" then
			DB.SetSlot(index, nil)
			GameTooltip:Hide()
			Refresh()
		else
			Catalog.Perform(token)
		end
	end)
	slot:SetScript("OnEnter", function(self)
		local token = DB.GetSlot(index)
		if token and not drag then ShowEmoteTooltip(self, token, L.slotTooltip) end
	end)
	slot:SetScript("OnLeave", GameTooltip_Hide)
end

---------------------------------------------------------------------------
-- Frame
---------------------------------------------------------------------------

-- Title on the gamepad header bar; dragging it moves the editor.
local function CreateHeader()
	local header = CreateFrame("Frame", nil, frame)
	header:SetPoint("TOPLEFT")
	header:SetPoint("TOPRIGHT")
	header:SetHeight(HEADER_HEIGHT)
	header:EnableMouse(true)
	header:RegisterForDrag("LeftButton")
	header:SetScript("OnDragStart", function() frame:StartMoving() end)
	header:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

	local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("CENTER")
	title:SetTextColor(1, 1, 1)
	title:SetText(L.editorTitle)

	local bar = header:CreateTexture(nil, "BACKGROUND")
	bar:SetAtlas(ATLAS_HEADER, true)
	bar:SetPoint("CENTER", title, "CENTER", 0, -2)

	-- Child of the header so it sits above it (the header takes the mouse across the top edge).
	local close = CreateFrame("Button", nil, header)
	close:SetSize(32, 32)
	close:SetPoint("TOPRIGHT", -4, -4)
	close:SetNormalAtlas(ATLAS_CLOSE)
	close:SetHighlightAtlas(ATLAS_CLOSE, "ADD")
	close:SetScript("OnClick", function() frame:Hide() end)
end

local function CreateWheel()
	wheel = ns.WheelView.Create(frame, { showEmpty = true })
	local scale = WHEEL_SIZE / wheel:GetWidth()
	wheel:SetScale(scale)
	wheel:SetPoint("CENTER", frame, "LEFT", (WHEEL_ZONE / 2) / scale, WHEEL_OFFSET_Y / scale)

	for index, slot in ipairs(wheel.slots) do
		SetupWedge(slot, index)
	end
end

local function CreateCardBackground(card)
	local background = card:CreateTexture(nil, "BACKGROUND")
	background:SetAllPoints()
	background:SetColorTexture(0, 0, 0, 0.6)
end

local function CreateList()
	local pad = 28
	local card = CreateFrame("Frame", nil, frame)
	card:SetPoint("TOPLEFT", WHEEL_ZONE, -CARD_TOP)
	card:SetPoint("BOTTOMRIGHT", 0, CARD_BOTTOM)
	CreateCardBackground(card)

	searchBox = CreateFrame("EditBox", nil, card, "SearchBoxTemplate")
	searchBox:SetHeight(20)
	searchBox:SetPoint("TOPLEFT", pad + 6, -pad)
	searchBox:SetPoint("TOPRIGHT", -pad, -pad)

	local hint = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -6, -6)
	hint:SetPoint("RIGHT", searchBox, "RIGHT")
	hint:SetJustifyH("LEFT")
	hint:SetText(L.listHint)

	list = CreateFrame("Frame", nil, card, "WowScrollBoxList")
	list:SetPoint("TOPLEFT", pad, -(pad + LIST_TOP))
	list:SetPoint("BOTTOMRIGHT", -(pad + 14), pad)

	local scrollBar = CreateFrame("EventFrame", nil, card, "MinimalScrollBar")
	scrollBar:SetPoint("TOPLEFT", list, "TOPRIGHT", 6, 0)
	scrollBar:SetPoint("BOTTOMLEFT", list, "BOTTOMRIGHT", 6, 0)

	local scrollView = CreateScrollBoxListLinearView()
	scrollView:SetElementExtent(ROW_HEIGHT)
	scrollView:SetElementInitializer("Button", InitRow)
	ScrollUtil.InitScrollBoxListWithScrollBar(list, scrollBar, scrollView)

	searchBox:HookScript("OnTextChanged", function() RefreshList() end)
end

local function Create()
	frame = CreateFrame("Frame", "EmoteCompassEditor", UIParent)
	frame:SetSize(WIDTH, HEIGHT)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetToplevel(true)
	frame:SetMovable(true)
	frame:Hide()

	CreateHeader()
	CreateWheel()
	CreateList()
	CreateGhost()

	frame:SetScript("OnShow", function()
		Refresh()
		Util.PlaySound("IG_CHARACTER_INFO_OPEN")
	end)
	frame:SetScript("OnHide", function()
		drag = nil
		ghost:Hide()
		Util.PlaySound("IG_CHARACTER_INFO_CLOSE")
	end)
end

function Editor.Open()
	if not frame then Create() end
	frame:Show()
end
