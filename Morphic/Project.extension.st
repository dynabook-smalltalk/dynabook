Extension { #name : #Project }

{ #category : #'*Morphic-Support' }
Project class >> allMorphicProjects [

	^ self allProjects select: [:p | p isMorphic]
]
