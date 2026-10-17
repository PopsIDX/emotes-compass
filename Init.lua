-- Entry point: everything global (key binding, slash commands) and the startup sequence.

local ADDON_NAME, ns = ...

local DB, L = ns.DB, ns.L

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

local handlers = {}

function handlers.ADDON_LOADED(frame, name)
	if name ~= ADDON_NAME then return end
	DB.Init()
	frame:UnregisterEvent("ADDON_LOADED")
end

function handlers.PLAYER_LOGIN()
	ns.Options.Register()
	ns.WheelButton.Refresh()
end

local events = CreateFrame("Frame")
events:SetScript("OnEvent", function(self, event, ...)
	handlers[event](self, ...)
end)
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
