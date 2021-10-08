Extension { #name : #FileDirectory }

{ #category : #'*network-url' }
FileDirectory >> asUrl [
	"Convert my path into a file:// type url - a FileUrl."
	
	^FileUrl pathParts: (self pathParts copyWith: '')
]

{ #category : #'*network-uri' }
FileDirectory class >> contentStreamForURI: aURI [
	| fullPath fileDir |
	fullPath := self fullPathForURI: aURI.
	fileDir := self forFileName: fullPath.
"	^fileDir readOnlyFileNamed: (self localNameFor: fullPath)"
	^StandardFileStream readOnlyFileNamed: fullPath

]

{ #category : #'*network-uri' }
FileDirectory class >> directoryEntryForURI: aURI [
	^ self directoryEntryFor: (self fullPathForURI: aURI)
]

{ #category : #'*network-uri' }
FileDirectory class >> fullPathForURI: aURI [
	^self activeDirectoryClass privateFullPathForURI: (FileDirectory default uri resolveRelativeURI: aURI)
]

{ #category : #'*network-uri' }
FileDirectory >> pathFromURI: aString [
	| path |
	aString class == Array ifTrue:["bullet-proofing"
		^FileDirectory pathFrom: {self pathName}, aString].
	"To support paths like foo/bar/user#2.doc, use #allButScheme instead of #path"
	path := (self uri resolveRelativeURI: aString) allButScheme.
	^self uriPathToPlatformPath: path

]

{ #category : #'*network-uri' }
FileDirectory class >> privateFullPathForURI: aURI [
	^(aURI path copyReplaceAll: '/' with: self slash) unescapePercents
]

{ #category : #'*network-uri' }
FileDirectory class >> retrieveMIMEDocument: uri [
	| file |
	file  := [self contentStreamForURI: uri] 
			on: FileDoesNotExistException do:[:ex| ex return: nil].
	file ifNotNil: [^MIMEDocument contentType: (MIMEDocument guessTypeFromName: uri) content: file contents url: uri].
	^nil
]

{ #category : #'*network-uri' }
FileDirectory >> uri [
	"Convert my path into a file:// type url.  Use slash instead of the local delimiter (:), and convert odd characters to %20 notation."

	"If slash (/) is not the file system delimiter, encode slashes before converting."
	| list |
	list := self pathParts.
	^(String streamContents: [:strm |
		strm nextPutAll: 'file:'.
		list do: [:each | strm nextPut: $/; nextPutAll: each encodeForHTTP].
		strm nextPut: $/]) asURI
]

{ #category : #'*network-uri' }
FileDirectory class >> uri: aURI [
	^self on: (FileDirectory fullPathForURI: aURI)
]

{ #category : #'*network-uri' }
FileDirectory >> uriPathToPlatformPath: aString [
	"Convert a URI path (w/ forward slashes) into a platform path if necessary"
	^aString
]
