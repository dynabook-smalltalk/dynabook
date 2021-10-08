Extension { #name : #Symbol }

{ #category : #'*System-Support' }
Symbol >> asSimpleGetter [

	self precedence
		caseOf: {
			[ 1 ] -> [ self numArgs = 0 ifTrue: [ ^ self ] ].
			[ 3 ] -> [ self numArgs = 1 ifTrue: [ ^ self allButLast asSymbol ] ] }
		otherwise: [].
	
	self error: 'Only simple setters and getters can be converted to simple getters!'.
]

{ #category : #'*System-Support' }
Symbol >> asSimpleSetter [

	self precedence
		caseOf: {
			[ 1 ] -> [ self numArgs = 0 ifTrue: [ ^ (self copyWith: $:) asSymbol ] ].
			[ 3 ] -> [ self numArgs = 1 ifTrue: [ ^ self ] ] }
		otherwise: [].
	
	self error: 'Only simple setters and getters can be converted to simple setters!'.
]

{ #category : #'*System-Support' }
Symbol >> isSimpleGetter [

	^ self precedence = 1
]

{ #category : #'*System-Support' }
Symbol >> isSimpleSetter [

	^ self isKeyword and: [self numArgs = 1]
]
