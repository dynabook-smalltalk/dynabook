Extension { #name : #Integer }

{ #category : #'*Morphic-Explorer' }
Integer >> explorerContents [

	^#(
		('hexadecimal' 16)
		('octal' 8)
		('binary' 2)) collect: [ :each |
			ObjectExplorerWrapper
				with: each first translated
				name: (self printStringBase: each second)
				model: self ]
]

{ #category : #'*Morphic-Explorer' }
Integer >> hasContentsInExplorer [
	^true
]
