-- Hand-picked icon for each emote of the catalog (pure data, see Core/Catalog.lua).
-- `icon` is an Interface\Icons file name, or a function returning one for player-dependent icons.
-- To change an icon: edit the name here (an unknown name falls back to the generic emote icon).
-- Names are not stored here: they come from the game's own slash commands, so they follow the client language.

local _, ns = ...

local function FactionBanner()
	return UnitFactionGroup("player") == "Horde" and "inv_bannerpvp_01" or "inv_bannerpvp_02"
end

local function RacePortrait()
	local _, raceFile = UnitRace("player")
	local race = raceFile == "Scourge" and "undead" or strlower(raceFile)
	local sex = UnitSex("player") == 3 and "female" or "male"
	return ("achievement_character_%s_%s"):format(race, sex)
end

ns.EmoteData = {
	-- Chat menu > Emote (animations)
	WAVE    = { icon = "ability_paladin_handoflight" },
	BOW     = { icon = "achievement_guildperk_honorablemention" },
	DANCE   = { icon = "inv_misc_drum_02" },
	APPLAUD = { icon = "inv_misc_trophy_argent" },
	BEG     = { icon = "inv_misc_bowl_01" },
	CHICKEN = { icon = "spell_magic_polymorphchicken" },
	CRY     = { icon = "spell_misc_emotionsad" },
	EAT     = { icon = "inv_misc_food_meat_cooked_01" },
	FLEX    = { icon = "spell_nature_strength" },
	KISS    = { icon = "spell_shadow_soothingkiss" },
	LAUGH   = { icon = "spell_misc_emotionhappy" },
	POINT   = { icon = "ability_hunter_markedfordeath" },
	ROAR    = { icon = "ability_druid_demoralizingroar" },
	RUDE    = { icon = "spell_misc_emotionangry" },
	SALUTE  = { icon = FactionBanner },
	SHY     = { icon = "spell_misc_emotionafraid" },
	TALK    = { icon = "ui_chat" },
	STAND   = { icon = RacePortrait },
	SIT     = { icon = "inv_fishingchair" },
	SLEEP   = { icon = "spell_nature_sleep" },
	KNEEL   = { icon = "spell_holy_sealofsalvation" },
	LEAN    = { icon = "ability_warrior_shieldwall" },

	-- Chat menu > Speech (voiced, also animated)
	HELPME         = { icon = "inv_misc_horn_01" },
	INCOMING       = { icon = "inv_misc_spyglass_02" },
	CHARGE         = { icon = "ability_warrior_charge" },
	FLEE           = { icon = "ability_rogue_sprint" },
	ATTACKMYTARGET = { icon = "ability_dualwield" },
	OOM            = { icon = "inv_potion_71" },
	FOLLOW         = { icon = "ability_tracking" },
	WAIT           = { icon = "inv_misc_pocketwatch_01" },
	HEALME         = { icon = "spell_holy_heal" },
	CHEER          = { icon = "inv_misc_missilesmall_red" },
	OPENFIRE       = { icon = "ability_vehicle_siegeenginecannon" },
	RASP           = { icon = "inv_misc_head_gnome_01" },
	HELLO          = { icon = "achievement_reputation_01" },
	BYE            = { icon = "inv_misc_rune_01" },
	NOD            = { icon = "ui_greenflag" },
	NO             = { icon = "spell_shadow_sacrificialshield" },
	THANK          = { icon = "inv_misc_gift_01" },
	WELCOME        = { icon = "inv_camelot_camping_welcomingcampfire" },
	CONGRATULATE   = { icon = "inv_helm_misc_fireworkpartyhat" },
	FLIRT          = { icon = "inv_rosebouquet01" },
	JOKE           = { icon = "inv_armor_darkmoonjester_d_01_helm" },
	TRAIN          = { icon = "inv_misc_toy_10" },
	FORTHEALLIANCE = { icon = "achievement_pvp_a_a" },
	FORTHEHORDE    = { icon = "achievement_pvp_h_h" },
}
