-- The wheel's visuals, shared by the popup and the editor.
-- Art and geometry come from Blizzard's gamepad radial menu (Blizzard_Gamepad/UI/Radials).
--
-- view = WheelView.Create(parent, { showEmpty = bool, showCancel = bool })
--   showEmpty:  draw a placeholder in empty wedges (editor)
--   showCancel: show "Cancel" in the hub while nothing is highlighted (popup)

local _, ns = ...

local Util, Catalog, L = ns.Util, ns.Catalog, ns.L

local WheelView = {}
ns.WheelView = WheelView

local ATLAS_WHEEL    = "gamepad-radial-menu-wheelbg"
local ATLAS_SELECTED = "gamepad-radial-menu-selected"
local ATLAS_CANCEL   = "Radial_Wheel_Icon_Close"
local EMPTY_TEXTURE  = "Interface\\PaperDoll\\UI-Backpack-EmptySlot"

local WEDGE_CENTER = 150 -- distance from the hub to the middle of a wedge (Blizzard's HIGHLIGHT_DISTANCE)
local HIGHLIGHT_ROTATION_CORRECTION = 270
local ICON_SIZE   = 44
local LABEL_GAP   = 6    -- icon + label form one group centered on the wedge
local LABEL_MAX   = 100  -- longer labels get truncated
local VERTICAL_LABEL_THRESHOLD = 0.3 -- sine of the wedge angle beyond which the label goes above/below
local HUB_RADIUS  = 70   -- no wedge is selected inside the hub
local HUB_WIDTH, HUB_HEIGHT = 90, 70
local HUB_ICON_SIZE = 32
local EMPTY_ALPHA = 0.6
local HOVER_SCALE = 1.15
local HOVER_SPEED = 18
local HOVER_SETTLE = 0.001 -- close enough to the target scale to snap to it and stop animating

local LABEL_COLOR_EMPTY = CreateColor(0.5, 0.5, 0.5)
local LABEL_COLOR_HIGHLIGHT = CreateColor(1, 1, 1)

local ViewMixin = {}

---------------------------------------------------------------------------
-- Construction
---------------------------------------------------------------------------

-- The label sits on the outer side: above for the top row, beside for left/right, below for the bottom row.
-- slot.labelX/labelY record that direction (a unit vector) for Layout.
local function AnchorLabel(slot, c, s)
	if s > VERTICAL_LABEL_THRESHOLD then
		slot.labelX, slot.labelY = 0, 1
		slot.label:SetPoint("BOTTOM", slot, "TOP", 0, LABEL_GAP)
	elseif s < -VERTICAL_LABEL_THRESHOLD then
		slot.labelX, slot.labelY = 0, -1
		slot.label:SetPoint("TOP", slot, "BOTTOM", 0, -LABEL_GAP)
	elseif c > 0 then
		slot.labelX, slot.labelY = 1, 0
		slot.label:SetPoint("LEFT", slot, "RIGHT", LABEL_GAP, 0)
	else
		slot.labelX, slot.labelY = -1, 0
		slot.label:SetPoint("RIGHT", slot, "LEFT", -LABEL_GAP, 0)
	end
end

local function CreateSlot(view, index)
	local degrees = 90 - (index - 1) * 360 / ns.SLOT_COUNT -- clockwise from the top
	local c, s = math.cos(math.rad(degrees)), math.sin(math.rad(degrees))

	local slot = CreateFrame("Frame", nil, view)
	slot:SetSize(ICON_SIZE, ICON_SIZE)
	slot.centerX, slot.centerY = c * WEDGE_CENTER, s * WEDGE_CENTER
	slot.x, slot.y = slot.centerX, slot.centerY
	slot.scale = 1
	slot.highlightRotation = math.rad(degrees - HIGHLIGHT_ROTATION_CORRECTION)

	slot.icon = Util.CreateRoundIcon(slot)
	slot.icon:SetAllPoints()

	slot.label = slot:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	slot.label:SetWordWrap(false)
	AnchorLabel(slot, c, s)

	return slot
end

local function CreateHub(view)
	local hub = CreateFrame("Frame", nil, view)
	hub:SetSize(HUB_WIDTH, HUB_HEIGHT)
	hub:SetPoint("CENTER")
	hub:Hide()

	local icon = hub:CreateTexture(nil, "OVERLAY")
	icon:SetAtlas(ATLAS_CANCEL)
	icon:SetSize(HUB_ICON_SIZE, HUB_ICON_SIZE)
	icon:SetPoint("TOP", 0, -8)

	local label = hub:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	label:SetPoint("TOP", icon, "BOTTOM", 0, -4)
	label:SetText(L.cancel)

	return hub
end

function WheelView.Create(parent, options)
	local view = Mixin(CreateFrame("Frame", nil, parent), ViewMixin)
	view.options = options or {}
	view.tokens = {}

	local background = view:CreateTexture(nil, "OVERLAY", nil, -3)
	background:SetAtlas(ATLAS_WHEEL, true)
	background:SetPoint("CENTER")
	view:SetSize(background:GetSize())

	view.highlight = view:CreateTexture(nil, "OVERLAY", nil, -2)
	view.highlight:SetAtlas(ATLAS_SELECTED, true)
	view.highlight:Hide()

	view.hub = CreateHub(view)

	view.slots = {}
	for i = 1, ns.SLOT_COUNT do
		view.slots[i] = CreateSlot(view, i)
	end
	return view
end

---------------------------------------------------------------------------
-- Content
---------------------------------------------------------------------------

function ViewMixin:SetTokens(tokens)
	self.tokens = tokens
	for i, slot in ipairs(self.slots) do
		local token = tokens[i]
		if token then
			local emote = Catalog.Get(token)
			slot.icon:SetTexture(emote.icon)
			slot.icon:SetAlpha(1)
			slot.label:SetText(emote.label)
		else
			slot.icon:SetTexture(EMPTY_TEXTURE)
			slot.icon:SetAlpha(EMPTY_ALPHA)
			slot.label:SetText(L.empty)
		end
		slot:SetShown(token ~= nil or self.options.showEmpty)
		Util.FitText(slot.label, LABEL_MAX)
	end
	self:Layout()
	self:SetHighlight(nil, true)
end

-- Shift each icon so that icon + label together sit centered on the wedge.
function ViewMixin:Layout()
	for _, slot in ipairs(self.slots) do
		local width = math.min(slot.label:GetStringWidth(), LABEL_MAX)
		local height = slot.label:GetStringHeight()
		-- Move the icon away from its label by half of (gap + label extent along that axis).
		local labelExtent = math.abs(slot.labelX) * width + math.abs(slot.labelY) * height
		local shift = (LABEL_GAP + labelExtent) / 2
		slot.x = slot.centerX - slot.labelX * shift
		slot.y = slot.centerY - slot.labelY * shift
		self:PlaceSlot(slot)
	end
end

-- Anchor offsets are in the slot's own (scaled) units: compensate to keep it in place.
function ViewMixin:PlaceSlot(slot)
	slot:SetScale(slot.scale)
	slot:ClearAllPoints()
	slot:SetPoint("CENTER", self, "CENTER", slot.x / slot.scale, slot.y / slot.scale)
end

---------------------------------------------------------------------------
-- Highlight and hit-testing
---------------------------------------------------------------------------

-- Returns true when the highlighted wedge changed.
function ViewMixin:SetHighlight(index, force)
	if index == self.highlighted and not force then return false end
	self.highlighted = index

	for i, slot in ipairs(self.slots) do
		local color = NORMAL_FONT_COLOR
		if not self.tokens[i] then
			color = LABEL_COLOR_EMPTY
		elseif i == index then
			color = LABEL_COLOR_HIGHLIGHT
		end
		slot.label:SetTextColor(color:GetRGB())
	end

	local slot = index and self.slots[index]
	if slot then
		self.highlight:ClearAllPoints()
		self.highlight:SetPoint("CENTER", self, "CENTER", slot.centerX, slot.centerY)
		self.highlight:SetRotation(slot.highlightRotation)
	end
	self.highlight:SetShown(slot ~= nil)
	self.hub:SetShown(self.options.showCancel and not index)
	return true
end

-- Wedge under the cursor; nil in the hub, beyond the rim (if limitToRim), or on an
-- empty wedge (unless includeEmpty).
function ViewMixin:GetSlotAtCursor(includeEmpty, limitToRim)
	local cx, cy = self:GetCenter()
	local x, y = Util.GetCursorIn(self)
	local dx, dy = x - cx, y - cy
	local distance = math.sqrt(dx * dx + dy * dy)
	if distance < HUB_RADIUS then return nil end
	if limitToRim and distance > self:GetWidth() / 2 then return nil end

	local step = 2 * math.pi / ns.SLOT_COUNT
	local fromTop = (math.pi / 2 - math.atan2(dy, dx)) % (2 * math.pi)
	local index = math.floor(fromTop / step + 0.5) % ns.SLOT_COUNT + 1
	if not includeEmpty and not self.tokens[index] then return nil end
	return index
end

---------------------------------------------------------------------------
-- Hover animation
---------------------------------------------------------------------------

-- Only slots still growing or shrinking are touched.
function ViewMixin:UpdateHover(elapsed)
	for i, slot in ipairs(self.slots) do
		local target = i == self.highlighted and HOVER_SCALE or 1
		if slot.scale ~= target then
			slot.scale = Util.Approach(slot.scale, target, elapsed, HOVER_SPEED)
			if math.abs(target - slot.scale) < HOVER_SETTLE then
				slot.scale = target
			end
			self:PlaceSlot(slot)
		end
	end
end

function ViewMixin:ResetHover()
	for _, slot in ipairs(self.slots) do
		slot.scale = 1
		self:PlaceSlot(slot)
	end
end
