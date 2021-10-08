Extension { #name : #String }

{ #category : #'*Morphic' }
String >> asMorph [ 
	"Answer the receiver as a StringMorph"

	^ StringMorph contents: self

"'bugs black blood' asMorph openInHand"
]

{ #category : #'*Morphic' }
String >> asStringMorph [ 
	"Answer the receiver as a StringMorph"

	^ StringMorph contents: self

"'bugs black blood' asStringMorph openInHand"
]

{ #category : #'*Morphic-Explorer' }
String >> hasContentsInExplorer [

	^false
]

{ #category : #'*Morphic-converting' }
String >> openAsMorph [
	"Open the receiver as a morph"

	^ self asMorph openInHand 
]
