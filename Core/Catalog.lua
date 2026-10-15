-- The emotes the wheel can hold, built from the game's own data:
-- EMOTE<n>_TOKEN / EMOTE<n>_CMD1 (the globals the chat uses to resolve /commands), limited to
-- the chat menu's Emote (EmoteList) and Speech (TextEmoteSpeechList) submenus, i.e. the emotes
-- that animate the character. Labels come from the game's translated slash command, icons from
-- Data/EmoteData.lua.
--
-- Entry: { token, command, label, icon, voiced }

local _, ns = ...

local Catalog = {}
ns.Catalog = Catalog

local GENERIC_ICON = 3750314 -- Blizzard's emote icon in the gamepad radial

local entries, byToken -- built lazily: needs the player (faction, race) and the chat globals

local function ResolveIcon(icon)
	if type(icon) == "function" then icon = icon() end
	local path = icon and "Interface\\Icons\\" .. icon
	if path and GetFileIDFromPath(path) then
		return path
	end
	return GENERIC_ICON
end

-- "/sit" -> "Sit": the game translates the command, so the label follows the client language.
local function LabelFromCommand(command)
	return (command:gsub("^/", ""):gsub("^%l", string.upper))
end

local function CreateEntry(token, command, voiced)
	local data = ns.EmoteData[token] or {}
	return {
		token = token,
		command = command,
		label = LabelFromCommand(command),
		icon = ResolveIcon(data.icon),
		voiced = voiced,
	}
end

local function Build()
	entries, byToken = {}, {}

	local wanted, voiced = {}, {}
	for _, token in ipairs(EmoteList) do wanted[token] = true end
	for _, token in ipairs(TextEmoteSpeechList) do wanted[token], voiced[token] = true, true end

	for i = 1, MAXEMOTEINDEX do
		local token, command = _G["EMOTE" .. i .. "_TOKEN"], _G["EMOTE" .. i .. "_CMD1"]
		if token and command and wanted[token] and not byToken[token] then
			local entry = CreateEntry(token, command, voiced[token] or false)
			entries[#entries + 1] = entry
			byToken[token] = entry
		end
	end

	-- Voiced emotes first, then the others; each group by name.
	table.sort(entries, function(a, b)
		if a.voiced ~= b.voiced then return a.voiced end
		return strcmputf8i(a.label, b.label) < 0
	end)
end

function Catalog.GetAll()
	if not entries then Build() end
	return entries
end

function Catalog.Get(token)
	if not entries then Build() end
	-- A saved token may be outside the catalog (older version): keep it usable.
	byToken[token] = byToken[token] or CreateEntry(token, "/" .. token:lower(), false)
	return byToken[token]
end

function Catalog.Perform(token)
	C_ChatInfo.PerformEmote(token)
end
