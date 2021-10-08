Extension { #name : #SolidFillStyle }

{ #category : #'*Morphic-Balloon' }
SolidFillStyle >> addFillStyleMenuItems: aMenu hand: aHand from: aMorph [
	^ self asColor addFillStyleMenuItems: aMenu hand: aHand from: aMorph
]
