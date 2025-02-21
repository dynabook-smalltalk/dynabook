Extension { #name : #AcornFileDirectory }

{ #category : #'*network-uri' }
AcornFileDirectory class >> privateFullPathForURI: aURI [
	"derive the full filepath from aURI"
	| path |
	path := String streamContents: [ :s |
		aURI pathComponents
			do: [ :p |	s nextPutAll: p ]
			separatedBy: [ s nextPut: self pathNameDelimiter ].
	].
	^path unescapePercents

]
