Extension { #name : #TextStyle }

{ #category : #'*Morphic-user interface' }
TextStyle class >> emphasisMenuForFont: font target: target selector: selector highlight: currentEmphasis [
	"Offer a font emphasis menu for the given style. If one is selected, pass that font to target with a call to selector. The fonts will be displayed in that font.
	Answer nil if no derivatives exist.
	"

 	| aMenu derivs |
	derivs := font derivativeFonts.
	derivs isEmpty ifTrue: [ ^nil ].
	aMenu := MenuMorph entitled: 'emphasis' translated.
	derivs := derivs asOrderedCollection.
	derivs addFirst: font.
	derivs do: [ :df | 
			aMenu 
				add: df emphasisString
				target: target 
				selector: selector
				argument: df.
                aMenu lastItem font: df.
                df emphasis == currentEmphasis ifTrue: [aMenu lastItem color: Color blue darker]].
        ^ aMenu
]

{ #category : #'*Morphic-user interface' }
TextStyle class >> fontMenuForStyle: styleName target: target selector: selector [
	^self fontMenuForStyle: styleName target: target selector: selector highlight: nil
]

{ #category : #'*Morphic-user interface' }
TextStyle class >> fontMenuForStyle: styleName target: target selector: selector highlight: currentFont [ 
	"Offer a font menu for the given style. If one is selected, pass 
	that font to target with a  
	call to selector. The fonts will be displayed in that font."
	| aMenu |
	aMenu := MenuMorph entitled: styleName.
	(TextStyle named: styleName)
		ifNotNil: [:s | s isTTCStyle
				ifTrue: [aMenu
						add: 'New Size'
						target: self
						selector: #chooseTTCFontSize:
						argument: {styleName. target. selector}]].
	(self pointSizesFor: styleName)
		do: [:pointSize | 
			| font subMenu displayFont | 
			font := (self named: styleName)
						fontOfPointSize: pointSize.
			subMenu := self
						emphasisMenuForFont: font
						target: target
						selector: selector
						highlight: (currentFont
								ifNotNil: [:cf | (cf familyName = styleName
											and: [cf pointSize = font pointSize])
										ifTrue: [currentFont emphasis]]).
			subMenu
				ifNil: [aMenu
						add: pointSize asString , ' Point'
						target: target
						selector: selector
						argument: font]
				ifNotNil: [aMenu add: pointSize asString , ' Point' subMenu: subMenu].
			displayFont := font.
			(font isSymbolFont or:[(font hasDistinctGlyphsForAll: pointSize asString , ' Point') not])
				ifTrue:[
					"don't use a symbol font to display its own name!!"
					displayFont := self default fontOfPointSize: pointSize].
			aMenu lastItem font: displayFont.
			currentFont
				ifNotNil: [:cf | (cf familyName = styleName
							and: [cf pointSize = font pointSize])
						ifTrue: [aMenu lastItem color: Color blue darker]]].
	^ aMenu
]

{ #category : #'*Morphic-user interface' }
TextStyle class >> promptForFont: aPrompt andSendTo: aTarget withSelector: aSelector [
	self promptForFont: aPrompt andSendTo: aTarget withSelector: aSelector highlight: nil
]

{ #category : #'*Morphic-user interface' }
TextStyle class >> promptForFont: aPrompt andSendTo: aTarget withSelector: aSelector highlight: currentFont [ 
	"Morphic Only! prompt for a font and if one is provided, send it to aTarget using a 
	message with selector aSelector."
	"TextStyle promptForFont: 'Choose system font:' andSendTo: Preferences withSelector: 
	#setSystemFontTo: "
	"Derived from a method written by Robin Gibson"
	| menu currentTextStyle |
	currentTextStyle := currentFont
				ifNotNil: [currentFont textStyleName].
	menu := MenuMorph entitled: aPrompt.
	self actualTextStyles keysSortedSafely
		do: [:styleName | | subMenu | 
			subMenu := self
						fontMenuForStyle: styleName
						target: aTarget
						selector: aSelector
						highlight: currentFont.
			menu add: styleName subMenu: subMenu.
			menu lastItem
				font: ((self named: styleName)
						fontOfSize: 18).
			styleName = currentTextStyle
				ifTrue: [menu lastItem color: Color blue darker]].
	menu popUpInWorld: self currentWorld
]
