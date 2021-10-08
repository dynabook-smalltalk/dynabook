Extension { #name : #Number }

{ #category : #'*rST' }
Number >> remoteType [
	"answer the prefered way to go to other squeak (#reference or #copy)"
	^ #copy
]
