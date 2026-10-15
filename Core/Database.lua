-- SavedVariables (EmoteCompassDB, account-wide). The only module that touches it.
--   slots   [1..SLOT_COUNT] = emote token, nil for an empty wedge (clockwise from the top)

local _, ns = ...

local DB = {}
ns.DB = DB

-- Starting set on first use; players customize it from there.
local DEFAULT_SLOTS = { "WAVE", "CHEER", "DANCE", "LAUGH", "BOW", "APPLAUD", "KISS", "SALUTE" }
assert(#DEFAULT_SLOTS == ns.SLOT_COUNT, "EmoteCompass: DEFAULT_SLOTS must fill every wedge")

local data

function DB.Init()
	EmoteCompassDB = EmoteCompassDB or {}
	data = EmoteCompassDB
	data.slots = data.slots or CopyTable(DEFAULT_SLOTS)
end

-- The saved table itself, not a copy: treat it as read-only and write through SetSlot/SwapSlots.
function DB.GetSlots()
	return data.slots
end

function DB.GetSlot(index)
	return data.slots[index]
end

function DB.SetSlot(index, token)
	data.slots[index] = token
end

function DB.SwapSlots(a, b)
	data.slots[a], data.slots[b] = data.slots[b], data.slots[a]
end

function DB.IsOnWheel(token)
	for i = 1, ns.SLOT_COUNT do
		if data.slots[i] == token then return true end
	end
	return false
end
