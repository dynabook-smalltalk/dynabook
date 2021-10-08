Extension { #name : #FileStream }

{ #category : #'*network-url' }
FileStream >> asUrl [
	"Convert my path into a file:// type url - a FileUrl."
	
	^FileUrl pathParts: (self directory pathParts copyWith: self localName)
]

{ #category : #'*network-uri' }
FileStream >> uri [
	^self directory uri resolveRelativeURI: self localName
]
