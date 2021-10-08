Extension { #name : #Boolean }

{ #category : #'*rST' }
Boolean >> remoteType [
	"answer the prefered way to go to other squeak (#reference or #copy)"
	^ #copy
]
