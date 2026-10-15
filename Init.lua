-- Entry point: everything global (key binding, slash commands) and the startup sequence.

local ADDON_NAME, ns = ...

local DB, L = ns.DB, ns.L

-- Key binding (declared in Bindings.xml): it gets its own section in the game's keybinds list.
BINDING_CATEGORY_EMOTECOMPASS = L.bindingHeader
BINDING_NAME_EMOTECOMPASS_TOGGLE = L.bindingName

function EmoteCompass_OnBinding(keystate)
	ns.Popup.OnBinding(keystate)
end

-- /ec edit: wheel editor · /ec show: open the wheel
SLASH_EMOTECOMPASS1 = "/emotecompass"
SLASH_EMOTECOMPASS2 = "/ec"
SlashCmdList.EMOTECOMPASS = function(msg)
	local command = strlower(strtrim(msg))
	if command == "edit" then
		ns.Editor.Open()
	else
		ns.Popup.Show()
	end
end

local events = CreateFrame("Frame")
events:SetScript("OnEvent", function(self, event, name)
	if name ~= ADDON_NAME then return end
	DB.Init()
	self:UnregisterEvent("ADDON_LOADED")
end)
events:RegisterEvent("ADDON_LOADED")
