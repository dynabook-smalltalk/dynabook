Extension { #name : #Color }

{ #category : #'*Morphic' }
Color >> asMorph [

	^(RectangleMorph new)
		fillStyle: self;
		borderWidth: 0;
		yourself
]

{ #category : #'*Morphic' }
Color >> iconOrThumbnailOfSize: aNumberOrPoint [ 
	"Answer an appropiate form to represent the receiver"
	| form |
	form := Form extent: aNumberOrPoint asPoint asPoint depth: 32.
	form fillColor: self.
	^ form
]
