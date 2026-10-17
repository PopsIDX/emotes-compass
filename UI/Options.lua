-- Options page in Esc > Options > AddOns, built with Blizzard's Settings API.
-- The wheel button settings are stored in the addon's saved variables (see DB.GetButton).
-- The key row, above the "show the button" checkbox, shows the bound key; its button opens the game's
-- keybinds list at the addon's section. While the checkbox is on, the key keeps its binding but is ignored
-- (see EmoteCompass_OnBinding in Init.lua).

local _, ns = ...

local DB, L = ns.DB, ns.L

local Options = {}
ns.Options = Options

-- Checkbox row template (UI/Checkbox.xml): Blizzard's checkbox row plus a small grey hint after the checkbox.
EmoteCompassCheckboxMixin = {}

function EmoteCompassCheckboxMixin:Init(initializer)
	SettingsCheckboxControlMixin.Init(self, initializer)
	self.Hint:SetText(initializer.data.hint or "")
end

local MIN_SCALE, MAX_SCALE, SCALE_STEP = 0.5, 2, 0.05

local category

local function IsButtonOn()
	return DB.GetButton().shown
end

-- Text of the key row's button: the bound key, or "Not Bound".
local function GetKeyText()
	local key = GetBindingKey(ns.BINDING)
	return key and GetBindingText(key) or NOT_BOUND
end

-- Opens Esc > Options > Keybindings, scrolled to the addon's section (named after its binding category).
local function OpenKeybindings()
	Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID, L.bindingHeader)
end

---------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------

local function GetButtonVariable(key)
	return "EmoteCompass_Button_" .. key
end

local SHOWN_VARIABLE = GetButtonVariable("shown")

-- A setting stored in the saved button table, applying the button's changes as soon as it changes.
local function RegisterButtonSetting(key, name, varType)
	local variable = GetButtonVariable(key)
	local setting = Settings.RegisterAddOnSetting(category, variable, key, DB.GetButton(), varType, name,
		DB.GetButtonDefault(key))
	Settings.SetOnValueChangedCallback(variable, ns.WheelButton.Refresh)
	return setting
end

local function FormatPercent(value)
	return ("%d%%"):format(value * 100 + 0.5)
end

-- No search tags on our button rows: AddSearchTags called from here stores addon-tainted tags that the
-- settings search reads on every search, tainting all its results.
local NO_SEARCH_TAGS = false

-- Greys out and indents a row while the button is hidden. Not SetParentInitializer: the settings search
-- reads parentInitializer outside its taint guards, so a parent set from here taints the search whenever
-- the row matches. These fields are only read when the row itself is drawn.
local function DependOnShownSetting(row)
	row:AddModifyPredicate(IsButtonOn)
	row:AddEvaluateStateCVar(SHOWN_VARIABLE) -- any setting variable works: re-evaluated when it changes
	row:Indent()
end

local function RegisterOpeningOptions(layout)
	-- Not Blizzard's binding row (CreateKeybindingEntryInitializer): built from addon code, its search
	-- functions taint the settings search and Blizzard then blocks actions on every result.
	if Settings.KEYBINDINGS_CATEGORY_ID then
		layout:AddInitializer(CreateSettingsButtonInitializer(L.bindingName, GetKeyText, OpenKeybindings, nil,
			NO_SEARCH_TAGS))
	end

	local showRow = Settings.CreateControlInitializer("EmoteCompassCheckboxTemplate",
		RegisterButtonSetting("shown", L.buttonShow, Settings.VarType.Boolean))
	showRow.data.hint = L.buttonHint
	layout:AddInitializer(showRow)

	-- Only meaningful while the button is shown: greyed out and indented under the checkbox otherwise.
	local lockRow = Settings.CreateCheckbox(category,
		RegisterButtonSetting("locked", L.buttonLock, Settings.VarType.Boolean))
	DependOnShownSetting(lockRow)

	local sliderOptions = Settings.CreateSliderOptions(MIN_SCALE, MAX_SCALE, SCALE_STEP)
	sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercent)
	local sizeRow = Settings.CreateSlider(category,
		RegisterButtonSetting("scale", L.buttonSize, Settings.VarType.Number), sliderOptions)
	DependOnShownSetting(sizeRow)
end

-- Rows keep Blizzard's default tooltip (their name). No hook on SettingsTooltip: it is shown from Blizzard's
-- code on every row of the panel, including search results, and an addon hook there taints that code.
function Options.Register()
	local layout
	category, layout = Settings.RegisterVerticalLayoutCategory(L.bindingHeader)

	RegisterOpeningOptions(layout)

	layout:AddInitializer(CreateSettingsButtonInitializer(L.editorName, L.editorButton,
		ns.Editor.Open, nil, NO_SEARCH_TAGS))

	Settings.RegisterAddOnCategory(category)
end

function Options.Open()
	Settings.OpenToCategory(category:GetID())
end
