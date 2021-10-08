Class {
	#name : #OM2Stream,
	#superclass : #Object,
	#instVars : [
		'head',
		'tail',
		'memo'
	],
	#category : #OMeta2
}

{ #category : #accessing }
OM2Stream >> basicTail [

	^ tail
]

{ #category : #forgetting }
OM2Stream >> forgetEverything [

	memo := IdentityDictionary new
]

{ #category : #accessing }
OM2Stream >> head [

	^ head
]

{ #category : #'initialize-release' }
OM2Stream >> initHead: h tail: t [

	head := h.
	tail := t
]

{ #category : #'initialize-release' }
OM2Stream >> initialize [

	memo := IdentityDictionary new
]

{ #category : #accessing }
OM2Stream >> inputSpecies [

	^ Array
]

{ #category : #accessing }
OM2Stream >> memo [

	^ memo
]

{ #category : #accessing }
OM2Stream >> pos [

	^ -1
]

{ #category : #printing }
OM2Stream >> printOn: aStream [

	| inputIsString curr |
	inputIsString := (self inputSpecies inheritsFrom: String) and: [(self inputSpecies inheritsFrom: Symbol) not].
	curr := self.
	aStream
		nextPutAll: 'an ';
		nextPutAll: self class name;
		nextPut: $(.
	[curr notNil] whileTrue: [
		(curr isKindOf: OM2EndOfStream) ifTrue: [
			aStream nextPut: $).
			^ self
		].
		inputIsString
			ifTrue: [aStream nextPut: curr head]
			ifFalse: [
				curr head printOn: aStream.
				aStream space
			].
		curr := curr basicTail.
	].
	aStream nextPutAll: '...)'
]

{ #category : #accessing }
OM2Stream >> tail [

	^ tail
]

{ #category : #forgetting }
OM2Stream >> transitiveForgetEverything [

	| curr |
	curr := self.
	[curr notNil] whileTrue: [
		curr forgetEverything.
		curr := curr basicTail
	]
]
