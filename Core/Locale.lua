-- All player-facing text.
-- Emote names are not here: they come from the game's own slash commands (see Core/Catalog.lua).

local _, ns = ...

ns.L = {
	-- Wheel
	cancel = "Cancel",
	empty = "Empty",

	-- Key binding
	bindingHeader = "Emote Compass",
	bindingName = "Open emote wheel",

	-- Editor
	editorTitle = "Customize the emote wheel",
	voiced = "Voiced",
	listHint = "Drag and drop emotes onto the wheel\nClick an emote to try it",
	slotTooltip = "Click: try it · Drag to move · Right-click to clear",

	-- Options
	buttonShow = "Show the wheel button",
	buttonHint = "(disables the shortcut)",
	buttonLock = "Lock the button's position",
	buttonSize = "Button size",
	buttonDragTip = "Drag: move",
	editorName = "Wheel emotes",
	editorButton = "Customize",
}
