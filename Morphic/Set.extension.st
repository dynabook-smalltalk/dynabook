Extension { #name : #Set }

{ #category : #'*Morphic-Explorer' }
Set >> explorerContents [ 

	^Array new: self size streamContents: [ :stream |
		self do: [ :each |
			stream nextPut: (
				ObjectExplorerWrapper
					with: each
					name: (stream position + 1) printString
					model: self) ] ]
]

{ #category : #'*Morphic-Explorer' }
Set >> hasContentsInExplorer [

	^self notEmpty
]
