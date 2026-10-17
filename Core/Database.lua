-- SavedVariables (EmoteCompassDB, account-wide). The only module that touches it.
--   slots             [1..SLOT_COUNT] = emote token, nil for an empty wedge (clockwise from the top);
--                     the same token may appear on several wedges
--   defaultKeyApplied true once the default key has been bound on the first login
--   button            the always-visible button: shown, locked, scale, and point = { x, y } (its center,
--                     in UIParent units from the bottom-left corner; nil until the player moves it)

local _, ns = ...

local DB = {}
ns.DB = DB

-- Starting set on first use; players customize it from there.
local DEFAULT_SLOTS = { "WAVE", "CHEER", "DANCE", "LAUGH", "BOW", "APPLAUD", "KISS", "SALUTE" }
assert(#DEFAULT_SLOTS == ns.SLOT_COUNT, "EmoteCompass: DEFAULT_SLOTS must fill every wedge")

local DEFAULT_BUTTON = { shown = false, locked = false, scale = 1 }

local data

function DB.Init()
	EmoteCompassDB = EmoteCompassDB or {}
	data = EmoteCompassDB
	data.slots = data.slots or CopyTable(DEFAULT_SLOTS)
	data.button = data.button or {}
	for key, value in pairs(DEFAULT_BUTTON) do
		if data.button[key] == nil then data.button[key] = value end
	end
end

-- The saved button settings table itself (also the backing store of the options widgets).
function DB.GetButton()
	return data.button
end

function DB.GetButtonDefault(key)
	return DEFAULT_BUTTON[key]
end

function DB.SetButtonPoint(x, y)
	data.button.point = { x = x, y = y }
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

function DB.IsDefaultKeyApplied()
	return data.defaultKeyApplied == true
end

function DB.SetDefaultKeyApplied()
	data.defaultKeyApplied = true
end
