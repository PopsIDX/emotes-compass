-- SavedVariables (EmoteCompassDB, account-wide). The only module that touches it.
--   slots   [1..SLOT_COUNT] = emote token, nil for an empty wedge (clockwise from the top)

local _, ns = ...

local DB = {}
ns.DB = DB

-- Starting set on first use.
local DEFAULT_SLOTS = { "WAVE", "DANCE", "LAUGH", "BOW", "APPLAUD", "KISS", "SALUTE", "CRY" }
assert(#DEFAULT_SLOTS == ns.SLOT_COUNT, "EmoteCompass: DEFAULT_SLOTS must fill every wedge")

local data

function DB.Init()
	EmoteCompassDB = EmoteCompassDB or {}
	data = EmoteCompassDB
	data.slots = data.slots or CopyTable(DEFAULT_SLOTS)
end

-- The saved table itself, not a copy: treat it as read-only.
function DB.GetSlots()
	return data.slots
end
