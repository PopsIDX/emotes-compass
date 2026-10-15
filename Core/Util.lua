-- Small helpers shared by every module.

local _, ns = ...

local Util = {}
ns.Util = Util

local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"

function Util.PlaySound(soundKitName)
	local id = SOUNDKIT[soundKitName]
	if id then PlaySound(id) end
end

-- Cursor position in the coordinate space of `frame` (i.e. comparable with frame:GetCenter()).
function Util.GetCursorIn(frame)
	local x, y = GetCursorPosition()
	local scale = frame:GetEffectiveScale()
	return x / scale, y / scale
end

-- Anchor `frame` by its center under the cursor, relative to `parent`'s bottom-left corner.
function Util.MoveToCursor(frame, parent)
	local x, y = Util.GetCursorIn(parent)
	local scale = frame:GetScale() -- anchor offsets are in the frame's own (scaled) units
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", parent, "BOTTOMLEFT", x / scale, y / scale)
end

local function AddCircleMask(owner, texture)
	local mask = owner:CreateMaskTexture()
	mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	mask:SetAllPoints(texture)
	texture:AddMaskTexture(mask)
end

-- Round, slightly zoomed-in icon (spell/item icons have a baked-in border).
function Util.CreateRoundIcon(owner, layer)
	local icon = owner:CreateTexture(nil, layer or "ARTWORK")
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	AddCircleMask(owner, icon)
	return icon
end

-- Size `fontString` to its text, truncating anything wider than `maxWidth`.
function Util.FitText(fontString, maxWidth)
	fontString:SetWidth(0)
	if fontString:GetStringWidth() > maxWidth then
		fontString:SetWidth(maxWidth)
	end
end

-- Frame-rate independent ease towards `target`.
function Util.Approach(current, target, elapsed, speed)
	return current + (target - current) * math.min(1, elapsed * speed)
end
