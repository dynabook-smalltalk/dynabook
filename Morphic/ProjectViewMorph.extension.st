Extension { #name : #ProjectViewMorph }

{ #category : #'*Morphic-Sound-piano rolls' }
ProjectViewMorph >> triggerActionFromPianoRoll [

	WorldState addDeferredUIMessage: [
		project world setProperty: #letTheMusicPlay toValue: true.
		self enter.
	]
]
