Extension { #name : #BitmapFillStyle }

{ #category : #'*Morphic-Balloon' }
BitmapFillStyle >> addFillStyleMenuItems: aMenu hand: aHand from: aMorph [
	"Add the items for changing the current fill style of the receiver"
	aMenu add: 'choose new graphic' translated target: self selector: #chooseNewGraphicIn:event: argument: aMorph.
	aMenu add: 'grab new graphic' translated target: self selector: #grabNewGraphicIn:event: argument: aMorph.
	super addFillStyleMenuItems: aMenu hand: aHand from: aMorph.
]

{ #category : #'*Morphic-Balloon' }
BitmapFillStyle >> chooseNewGraphicIn: aMorph event: evt [ 
	"Used by any morph that can be represented by a graphic"
	| aGraphicalMenu |
	aGraphicalMenu := GraphicalMenu new
				initializeFor: self
				withForms: aMorph reasonableBitmapFillForms
				coexist: true.
	aGraphicalMenu selector: #newForm:forMorph:;
		 argument: aMorph.
	evt hand attachMorph: aGraphicalMenu
]

{ #category : #'*Morphic-Balloon' }
BitmapFillStyle >> grabNewGraphicIn: aMorph event: evt [ 
	"Used by any morph that can be represented by a graphic"
	| fill |
	fill := Form fromUser.
	fill boundingBox area = 0
		ifTrue: [^ self].
	self form: fill.
	self direction: fill width @ 0.
	self normal: 0 @ fill height.
	aMorph changed
]

{ #category : #'*Morphic-Balloon' }
BitmapFillStyle >> newForm: aForm forMorph: aMorph [
	self form: aForm.
	self direction: (aForm width @ 0).
	self normal: (0 @ aForm height).
	aMorph changed.
]
