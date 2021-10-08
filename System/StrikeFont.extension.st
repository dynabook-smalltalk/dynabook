Extension { #name : #StrikeFont }

{ #category : #'*System-Fonts' }
StrikeFont class >> fromUser [
	"StrikeFont fromUser"
	^self fromUser: TextStyle defaultFont
]

{ #category : #'*System-Fonts' }
StrikeFont class >> fromUser: priorFont [
	^self fromUser: priorFont allowKeyboard: true
]

{ #category : #'*System-Fonts' }
StrikeFont class >> fromUser: priorFont allowKeyboard: aBoolean [	"StrikeFont fromUser"
	"Present a menu of available fonts, and if one is chosen, return it.
	Otherwise return nil. Using ToolBuilder for added abstraction."
	| fontList fontMenu font builder resultBlock widget style result item |
	builder := ToolBuilder default.
	fontList := StrikeFont actualFamilyNames.
	fontMenu := builder pluggableMenuSpec new.
	resultBlock := [:value| result := value].
	fontList do: [:fontName | | active ptMenu |
		style := TextStyle named: fontName.
		active := priorFont familyName sameAs: fontName.
		ptMenu := builder pluggableMenuSpec new.
		style pointSizes do: [:pt | | label |
			label := pt printString, ' pt'.
			item := ptMenu add: label 
				target: resultBlock
				selector: #value:
				argumentList: {{fontName. pt}}.
			item checked: (active and:[pt = priorFont pointSize]).
		].
		style isTTCStyle ifTrue: [
			ptMenu add: 'new size'
				target: style 
				selector: #addNewFontSizeDialog: 
				argumentList: {{fontName. fontMenu}}.
		].
		item := fontMenu add: fontName action: nil.
		item subMenu: ptMenu.
		item checked: active.
	].
	TTFileDescription offerNonPortableFonts ifTrue:[
		fontMenu addSeparator.
		item := fontMenu add: 'More (non-portable) Fonts...' 
			target: resultBlock 
			selector: #value:
			argumentList: #(TTFileDescription).
	].
	widget := builder open: fontMenu.
	builder runModal: widget.
	result ifNil:[^nil].
	"Pick a non-portable font if requested"
	result == #TTFileDescription ifTrue:[
		^Smalltalk at: #TTFileDescription ifPresent:[:ttf| 
			ttf fontFromUser: priorFont allowKeyboard: aBoolean]].
	style := TextStyle named: result first.
	style ifNil: [^ self].
	font := style fonts detect: [:any | any pointSize = result last] ifNone: [nil].
	^ font
]

{ #category : #'*System-Fonts' }
StrikeFont class >> setupDefaultFallbackFont [
"
	StrikeFont setupDefaultFallbackFont
"

	(#(#Accuat #Accujen #Accula #Accumon #Accusf #Accushi #Accuve #Atlanta) collect: [:e | TextStyle named: e]) do: [:style |
		style fontArray do: [:e |
			e reset.
			e setupDefaultFallbackFont.
		].
	].
	TTCFont allSubInstances
		do: [:font | font reset.
			font setupDefaultFallbackFont]


]
