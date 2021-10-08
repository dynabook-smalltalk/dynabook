Extension { #name : #String }

{ #category : #'*rST' }
String >> asRemoteObjectID [
	"creates a remote object id from this string"
	^ RSTRemoteObjectID fromString: self
]

{ #category : #'*rST' }
String >> remoteType [
	"answer the prefered way to go to other squeak (#reference or #copy)"
	"
	if the string is used in a mutable way, you must change to #reference
	"
	^ #copy
]
