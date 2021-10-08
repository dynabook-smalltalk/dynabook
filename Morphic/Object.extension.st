Extension { #name : #Object }

{ #category : #'*morphic' }
Object >> asMorph [
	"Open a morph, as best one can, on the receiver"

	^ self asStringMorph

	"
234 asMorph
(ScriptingSystem formAtKey: #TinyMenu) asMorph
'fred' asMorph
"


]

{ #category : #'*morphic' }
Object >> asStringMorph [
	"Open a StringMorph, as best one can, on the receiver"

	^ self asStringOrText asStringMorph

]

{ #category : #'*morphic' }
Object >> asTextMorph [
	"Open a TextMorph, as best one can, on the receiver"

	^ TextMorph new contentsAsIs: self asStringOrText

]

{ #category : #'*Morphic-Explorer' }
Object >> explorerContents [
	"Override that method to define which properties of the object should be shown in the
	object explorer. See for example the implementation in Integer>>#explorerContents."

	^ (self class allInstVarNames asOrderedCollection withIndexCollect: [:each :index |
		ObjectExplorerWrapper
			with: (self instVarAt: index)
			name: each
			model: self]) ,
		((1 to: self basicSize) collect: [:index |
			ObjectExplorerWrapper
				with: (self  basicAt: index)
				name: index printString
				model: self ])
]

{ #category : #'*Morphic-Events-Filtering' }
Object >> filterEvent: anEvent for: aMorphOrNil [
	"Get the chance to intercept the event. Note that global event filters might not be provided with the actual target. Returns the event that should be processed any further. If you want to ignore them, call #ignore on them."
	
	^ anEvent "no change"
]

{ #category : #'*morphic' }
Object >> isPluggableListMorph [
	^ false
]

{ #category : #'*morphic' }
Object >> openAsMorph [
	"Open a morph, as best one can, on the receiver"

	^ self asMorph openInHand

"
234 openAsMorph
(ScriptingSystem formAtKey: #TinyMenu) openAsMorph
'fred' openAsMorph
"
]
