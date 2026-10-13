-- Entry point: everything global (key binding, slash commands) and the startup sequence.

local ADDON_NAME, ns = ...

local L = ns.L

-- Key binding (declared in Bindings.xml): it gets its own section in the game's keybinds list.
BINDING_CATEGORY_EMOTECOMPASS = L.bindingHeader
BINDING_NAME_EMOTECOMPASS_TOGGLE = L.bindingName

function EmoteCompass_OnBinding(keystate)
	ns.Popup.OnBinding(keystate)
end

-- /ec list: print every emote of the catalog (temporary, to check the data)
-- /ec show: open the wheel
SLASH_EMOTECOMPASS1 = "/emotecompass"
SLASH_EMOTECOMPASS2 = "/ec"
SlashCmdList.EMOTECOMPASS = function(msg)
	local command = strlower(strtrim(msg))
	if command == "list" then
		for _, emote in ipairs(ns.Catalog.GetAll()) do
			print(emote.token, emote.command, emote.icon)
		end
	else
		ns.Popup.Open()
	end
end
