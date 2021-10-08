Extension { #name : #Text }

{ #category : #'*Morphic-converting' }
Text >> asDraggableMorph [

	^ self copy
		addAttribute: (TextFontReference toFont: ((self userInterfaceTheme get: #font for: #TransferMorph) ifNil: [TextStyle defaultFont]));
		asMorph
]

{ #category : #'*Morphic-converting' }
Text >> asMorph [
	^ self asTextMorph
]

{ #category : #'*Morphic-converting' }
Text >> asStringMorph [
	^ StringMorph
		contents: self string
		font: (self fontAt: 1 withStyle: TextStyle default)
		emphasis: (self emphasisAt: 1)
]

{ #category : #'*Morphic-converting' }
Text >> asTextMorph [
	^ TextMorph new contentsAsIs: self
]

{ #category : #'*Morphic-Text Support' }
Text >> embeddedMorphs [
	"return the list of morphs embedded in me"

	| morphs |
	morphs := IdentitySet new.
	runs withStartStopAndValueDo: 
			[:start :stop :attribs | 
			attribs 
				do: [:attrib | attrib anchoredMorph ifNotNil: [morphs add: attrib anchoredMorph]]].
	^morphs select: [:m | m isMorph]
]

{ #category : #'*Morphic-Text Support' }
Text >> embeddedMorphsFrom: start to: stop [ 
	"return the list of morphs embedded in me"

	| morphs |
	morphs := IdentitySet new.
	runs 
		runsFrom: start
		to: stop
		do: 
			[:attribs | 
			attribs 
				do: [:attr | attr anchoredMorph ifNotNil: [morphs add: attr anchoredMorph]]].
	^morphs select: [:m | m isMorph]
]

{ #category : #'*Morphic-Explorer' }
Text >> explorerContents [

	^ (self class allInstVarNames asOrderedCollection withIndexCollect: [:each :index |
		ObjectExplorerWrapper
			with: (self instVarAt: index)
			name: each
			model: self])
]
