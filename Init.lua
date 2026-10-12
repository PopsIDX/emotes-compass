-- Entry point: everything global (slash commands) and the startup sequence.

local ADDON_NAME, ns = ...

-- /ec list: print every emote of the catalog (temporary, to check the data)
SLASH_EMOTECOMPASS1 = "/emotecompass"
SLASH_EMOTECOMPASS2 = "/ec"
SlashCmdList.EMOTECOMPASS = function(msg)
	for _, emote in ipairs(ns.Catalog.GetAll()) do
		print(emote.token, emote.command, emote.icon)
	end
end
