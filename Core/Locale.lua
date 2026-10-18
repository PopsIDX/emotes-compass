-- All player-facing text. T{ en = ..., fr = ..., ... } picks the client's language, English by default.
-- Emote names are not here: they come from the game's own slash commands (see Core/Catalog.lua).

local _, ns = ...

local LANGUAGES = {
	frFR = "fr", deDE = "de", esES = "es", esMX = "es", itIT = "it", ptBR = "pt",
	ruRU = "ru", koKR = "ko", zhCN = "zhCN", zhTW = "zhTW",
}
local LANGUAGE = LANGUAGES[GetLocale()] or "en"

local function T(strings)
	return strings[LANGUAGE] or strings.en
end

ns.L = {
	-- Wheel
	cancel = T{
		en = "Cancel", fr = "Annuler", de = "Abbrechen", es = "Cancelar", it = "Annulla",
		pt = "Cancelar", ru = "Отмена", ko = "취소", zhCN = "取消", zhTW = "取消",
	},
	empty = T{
		en = "Empty", fr = "Vide", de = "Leer", es = "Vacío", it = "Vuoto",
		pt = "Vazio", ru = "Пусто", ko = "비어 있음", zhCN = "空", zhTW = "空",
	},

	-- Key binding
	bindingHeader = "Emotes Compass",
	bindingName = T{
		en = "Open emote wheel",
		fr = "Ouvrir la roue d'émotes",
		de = "Emote-Rad öffnen",
		es = "Abrir la rueda de emotes",
		it = "Apri la ruota delle emote",
		pt = "Abrir a roda de emotes",
		ru = "Открыть круг эмоций",
		ko = "감정 표현 휠 열기",
		zhCN = "打开表情轮盘",
		zhTW = "開啟表情輪盤",
	},

	-- Editor
	editorTitle = T{
		en = "Customize the emote wheel",
		fr = "Personnaliser la roue d'émotes",
		de = "Emote-Rad anpassen",
		es = "Personalizar la rueda de emotes",
		it = "Personalizza la ruota delle emote",
		pt = "Personalizar a roda de emotes",
		ru = "Настройка круга эмоций",
		ko = "감정 표현 휠 설정",
		zhCN = "自定义表情轮盘",
		zhTW = "自訂表情輪盤",
	},
	voiced = T{
		en = "Voiced", fr = "Voix", de = "Mit Stimme", es = "Con voz", it = "Con voce",
		pt = "Com voz", ru = "Озвучено", ko = "음성", zhCN = "语音", zhTW = "語音",
	},
	listHint = T{
		en = "Drag and drop emotes onto the wheel\nClick an emote to try it",
		fr = "Glisser et déposer les émotes dans la roue\nCliquer sur une émote pour l'essayer",
		de = "Emotes per Drag & Drop auf das Rad ziehen\nAuf ein Emote klicken, um es auszuprobieren",
		es = "Arrastra y suelta emotes en la rueda\nHaz clic en un emote para probarlo",
		it = "Trascina le emote sulla ruota\nClicca su un'emote per provarla",
		pt = "Arraste e solte emotes na roda\nClique em um emote para testá-lo",
		ru = "Перетаскивайте эмоции на круг\nНажмите на эмоцию, чтобы попробовать её",
		ko = "감정 표현을 휠로 끌어다 놓으세요\n감정 표현을 클릭하면 미리 실행해 볼 수 있습니다",
		zhCN = "将表情拖放到轮盘上\n点击表情可试用",
		zhTW = "將表情拖放到輪盤上\n點擊表情可試用",
	},
	slotTooltip = T{
		en = "Click: try it · Drag to move · Right-click to clear",
		fr = "Clic : essayer · Glisser pour déplacer · Clic droit pour vider",
		de = "Klick: ausprobieren · Ziehen: verschieben · Rechtsklick: leeren",
		es = "Clic: probar · Arrastrar para mover · Clic derecho para vaciar",
		it = "Clic: prova · Trascina per spostare · Clic destro per svuotare",
		pt = "Clique: testar · Arraste para mover · Clique direito para limpar",
		ru = "Щелчок: попробовать · Перетащить: переместить · ПКМ: очистить",
		ko = "클릭: 실행 · 끌어서 이동 · 우클릭: 비우기",
		zhCN = "点击：试用 · 拖动：移动 · 右键：清空",
		zhTW = "點擊：試用 · 拖曳：移動 · 右鍵：清空",
	},

	-- Options
	buttonShow = T{
		en = "Show the wheel button", fr = "Afficher le bouton de la roue", de = "Radschaltfläche anzeigen",
		es = "Mostrar el botón de la rueda", it = "Mostra il pulsante della ruota", pt = "Mostrar o botão da roda",
		ru = "Показывать кнопку круга", ko = "휠 버튼 표시", zhCN = "显示轮盘按钮", zhTW = "顯示輪盤按鈕",
	},
	buttonHint = T{
		en = "(disables the shortcut)",
		fr = "(désactive le raccourci)",
		de = "(deaktiviert die Tastenbelegung)",
		es = "(desactiva el atajo)",
		it = "(disattiva la scorciatoia)",
		pt = "(desativa o atalho)",
		ru = "(отключает клавишу)",
		ko = "(단축키 비활성화)",
		zhCN = "(禁用快捷键)",
		zhTW = "(停用快捷鍵)",
	},
	buttonLock = T{
		en = "Lock the button's position", fr = "Verrouiller la position du bouton", de = "Position der Schaltfläche sperren",
		es = "Bloquear la posición del botón", it = "Blocca la posizione del pulsante", pt = "Travar a posição do botão",
		ru = "Закрепить положение кнопки", ko = "버튼 위치 잠금", zhCN = "锁定按钮位置", zhTW = "鎖定按鈕位置",
	},
	buttonSize = T{
		en = "Button size", fr = "Taille du bouton", de = "Größe der Schaltfläche", es = "Tamaño del botón", it = "Dimensione del pulsante",
		pt = "Tamanho do botão", ru = "Размер кнопки", ko = "버튼 크기", zhCN = "按钮大小", zhTW = "按鈕大小",
	},
	buttonDragTip = T{
		en = "Drag: move", fr = "Glisser : déplacer", de = "Ziehen: verschieben", es = "Arrastrar: mover",
		it = "Trascina: sposta", pt = "Arraste: mover", ru = "Перетащить: переместить", ko = "끌기: 이동",
		zhCN = "拖动：移动", zhTW = "拖曳：移動",
	},
	editorName = T{
		en = "Wheel emotes", fr = "Émotes de la roue", de = "Emotes im Rad", es = "Emotes de la rueda", it = "Emote della ruota",
		pt = "Emotes da roda", ru = "Эмоции круга", ko = "휠 감정 표현", zhCN = "轮盘表情", zhTW = "輪盤表情",
	},
	editorButton = T{
		en = "Customize", fr = "Personnaliser", de = "Anpassen", es = "Personalizar", it = "Personalizza",
		pt = "Personalizar", ru = "Настроить", ko = "설정", zhCN = "自定义", zhTW = "自訂",
	},
}
