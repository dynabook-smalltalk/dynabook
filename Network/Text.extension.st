Extension { #name : #Text }

{ #category : #'*network-url' }
Text >> asUrl [
	^self asString asUrl
]

{ #category : #'*network-url' }
Text >> asUrlRelativeTo: aUrl [
	^self asString asUrlRelativeTo: aUrl
]
