-- Small helpers shared by every module.

local _, ns = ...

local Util = {}
ns.Util = Util

local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"

-- Cursor position in the coordinate space of `frame` (i.e. comparable with frame:GetCenter()).
function Util.GetCursorIn(frame)
	local x, y = GetCursorPosition()
	local scale = frame:GetEffectiveScale()
	return x / scale, y / scale
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
