Extension { #name : #Dictionary }

{ #category : #'*Morphic-Explorer' }
Dictionary >> explorerContents [

	^self keysSortedSafely replace: [ :key |
		ObjectExplorerWrapper
			with: (self at: key)
			name: (key printString contractTo: 32)
			model: self ]

]

{ #category : #'*Morphic-Explorer' }
Dictionary >> hasContentsInExplorer [

	^self isEmpty not
]
