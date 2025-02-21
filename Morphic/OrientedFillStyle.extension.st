Extension { #name : #OrientedFillStyle }

{ #category : #'*Morphic-Balloon' }
OrientedFillStyle >> addFillStyleMenuItems: aMenu hand: aHand from: aMorph [
	"Add the items for changing the current fill style of the receiver"
	aMenu add: 'change origin' translated target: self selector: #changeOriginIn:event: argument: aMorph.
	aMenu add: 'change orientation' translated target: self selector: #changeOrientationIn:event: argument: aMorph.
]

{ #category : #'*Morphic-Balloon' }
OrientedFillStyle >> changeOrientationIn: aMorph event: evt [
	"Interactively change the origin of the receiver"
	| handle |
	handle := HandleMorph new forEachPointDo:[:pt|
		self direction: pt - self origin.
		self normal: nil.
		aMorph changed].
	evt hand attachMorph: handle.
	handle startStepping.
]

{ #category : #'*Morphic-Balloon' }
OrientedFillStyle >> changeOriginIn: aMorph event: evt [
	"Interactively change the origin of the receiver"
	| handle |
	handle := HandleMorph new forEachPointDo:[:pt|
		self origin: pt.
		aMorph changed].
	evt hand attachMorph: handle.
	handle startStepping.
]
