-- Entry point: everything global (key binding, slash commands) and the startup sequence.

local ADDON_NAME, ns = ...

local DB, L = ns.DB, ns.L

local DEFAULT_KEY = "G"

-- Key binding (declared in Bindings.xml): it gets its own section in the game's keybinds list.
BINDING_CATEGORY_EMOTECOMPASS = L.bindingHeader
BINDING_NAME_EMOTECOMPASS_TOGGLE = L.bindingName

function EmoteCompass_OnBinding(keystate)
	if DB.GetButton().shown then return end -- the key is disabled while the wheel button is shown
	ns.Popup.OnBinding(keystate)
end

-- /ec: options · /ec edit: wheel editor · /ec show: open the wheel
SLASH_EMOTECOMPASS1 = "/emotecompass"
SLASH_EMOTECOMPASS2 = "/ec"
SlashCmdList.EMOTECOMPASS = function(msg)
	local command = strlower(strtrim(msg))
	if command == "edit" then
		ns.Editor.Open()
	elseif command == "show" then
		ns.Popup.Show()
	else
		ns.Options.Open()
	end
end

-- Bind the default key once, on the first login with the addon. It's a real binding so it shows
-- (and can be changed) in the options; after that the player's bindings are never touched again.
-- Does nothing during combat (bindings are locked); it's retried when combat ends.
local function ApplyDefaultKey()
	if DB.IsDefaultKeyApplied() then return true end
	if GetBindingKey(ns.BINDING) then
		DB.SetDefaultKeyApplied()
		return true
	end
	if InCombatLockdown() then return false end

	SetBinding(DEFAULT_KEY, ns.BINDING)
	SaveBindings(GetCurrentBindingSet())
	DB.SetDefaultKeyApplied()
	return true
end

local handlers = {}

function handlers.ADDON_LOADED(frame, name)
	if name ~= ADDON_NAME then return end
	DB.Init()
	frame:UnregisterEvent("ADDON_LOADED")
end

function handlers.PLAYER_LOGIN(frame)
	ns.Options.Register()
	ns.WheelButton.Refresh()
	ApplyDefaultKey()
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function handlers.PLAYER_REGEN_ENABLED()
	ApplyDefaultKey()
end

local events = CreateFrame("Frame")
events:SetScript("OnEvent", function(self, event, ...)
	handlers[event](self, ...)
end)
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
