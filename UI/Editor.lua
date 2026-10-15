-- Wheel editor (/ec edit): the wheel on the left, the emote list on the right.
--   list  -> wedge : assign
--   wedge -> wedge : swap
--   wedge -> away  : clear
-- The same emote may sit on several wedges on purpose.
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
local CARD_PAD       = 28
local LIST_TOP       = 28   -- room for the hint, from the card's padded top
local ROW_HEIGHT     = 30
local LABEL_MAX      = 220  -- widest emote name in a row

local ATLAS_HEADER    = "gamepad-radial-menu-toptext"
local ATLAS_ROW_HOVER = "options_list_active"
local ATLAS_CLOSE     = "128-redbutton-exit"

local frame, wheel, list, ghost
local drag -- { token = ..., fromSlot = index or nil } while dragging

local function Refresh()
	wheel:SetTokens(DB.GetSlots())
end

---------------------------------------------------------------------------
-- Drag and drop
---------------------------------------------------------------------------

local function DropTarget()
	return wheel:GetSlotAtCursor(true, true)
end

local function StartDrag(token, fromSlot)
	if not token then return end
	drag = { token = token, fromSlot = fromSlot }
	local emote = Catalog.Get(token)
	ghost.icon:SetTexture(emote.icon)
	ghost.label:SetText(emote.command)
	ghost:Show()
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

	local hover = row:CreateTexture(nil, "HIGHLIGHT")
	hover:SetAtlas(ATLAS_ROW_HOVER)
	hover:SetAllPoints()

	row.icon = Util.CreateRoundIcon(row)
	row.icon:SetSize(24, 24)
	row.icon:SetPoint("LEFT", 8, 0)

	row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.label:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
	row.label:SetJustifyH("LEFT")
	row.label:SetWordWrap(false)

	row:SetScript("OnDragStart", function(self) StartDrag(self.token) end)
	row:SetScript("OnDragStop", FinishDrag)
end

local function InitRow(row, emote)
	if not row.icon then SetupRow(row) end
	row.token = emote.token
	row.icon:SetTexture(emote.icon)
	row.label:SetText(emote.command)
	Util.FitText(row.label, LABEL_MAX)
end

---------------------------------------------------------------------------
-- Wheel wedges
---------------------------------------------------------------------------

local function SetupWedge(slot, index)
	slot:EnableMouse(true)
	slot:RegisterForDrag("LeftButton")
	slot:SetScript("OnDragStart", function() StartDrag(DB.GetSlot(index), index) end)
	slot:SetScript("OnDragStop", FinishDrag)
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

local function CreateList()
	local card = CreateFrame("Frame", nil, frame)
	card:SetPoint("TOPLEFT", WHEEL_ZONE, -CARD_TOP)
	card:SetPoint("BOTTOMRIGHT", 0, CARD_BOTTOM)

	local background = card:CreateTexture(nil, "BACKGROUND")
	background:SetAllPoints()
	background:SetColorTexture(0, 0, 0, 0.6)

	local hint = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("TOPLEFT", CARD_PAD, -CARD_PAD)
	hint:SetPoint("TOPRIGHT", -CARD_PAD, -CARD_PAD)
	hint:SetJustifyH("LEFT")
	hint:SetText(L.listHint)

	list = CreateFrame("Frame", nil, card, "WowScrollBoxList")
	list:SetPoint("TOPLEFT", CARD_PAD, -(CARD_PAD + LIST_TOP))
	list:SetPoint("BOTTOMRIGHT", -(CARD_PAD + 14), CARD_PAD)

	local scrollBar = CreateFrame("EventFrame", nil, card, "MinimalScrollBar")
	scrollBar:SetPoint("TOPLEFT", list, "TOPRIGHT", 6, 0)
	scrollBar:SetPoint("BOTTOMLEFT", list, "BOTTOMRIGHT", 6, 0)

	local scrollView = CreateScrollBoxListLinearView()
	scrollView:SetElementExtent(ROW_HEIGHT)
	scrollView:SetElementInitializer("Button", InitRow)
	ScrollUtil.InitScrollBoxListWithScrollBar(list, scrollBar, scrollView)

	list:SetDataProvider(CreateDataProvider(Catalog.GetAll()))
end

local function Create()
	frame = CreateFrame("Frame", "EmoteCompassEditor", UIParent)
	frame:SetSize(WIDTH, HEIGHT)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
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
