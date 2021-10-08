Class {
	#name : #OMeta2Base,
	#superclass : #Object,
	#instVars : [
		'input',
		'om2streams',
		'haltingPoint'
	],
	#category : #OMeta2
}

{ #category : #'as yet unclassified' }
OMeta2Base class >> compilerClass [

        ^ OMeta2Compiler
]

{ #category : #'as yet unclassified' }
OMeta2Base class >> debugMatch: anObject with: aRule [

	^ self debugMatch: anObject with: aRule withArgs: #()
]

{ #category : #'as yet unclassified' }
OMeta2Base class >> debugMatch: anObject with: aRule withArgs: args [

	^ self debugMatchAll: {anObject} readStream with: aRule withArgs: args
]

{ #category : #'as yet unclassified' }
OMeta2Base class >> debugMatchAll: aSequenceableCollection with: aRule [

	^ self debugMatchAll: aSequenceableCollection with: aRule withArgs: #()
]

{ #category : #'as yet unclassified' }
OMeta2Base class >> debugMatchAll: aSequenceableCollection with: aRule withArgs: args [

	^ self matchStream: aSequenceableCollection readStream with: aRule withArgs: args withPlaybackDebugging: true
]

{ #category : #'as yet unclassified' }
OMeta2Base class >> match: anObject with: aRule [

	^ self match: anObject with: aRule withArgs: #()
]

{ #category : #'as yet unclassified' }
OMeta2Base class >> match: anObject with: aRule withArgs: args [

	^ self matchAll: {anObject} readStream with: aRule withArgs: args
]

{ #category : #'as yet unclassified' }
OMeta2Base class >> matchAll: aSequenceableCollection with: aRule [

	^ self matchAll: aSequenceableCollection with: aRule withArgs: #()
]

{ #category : #'as yet unclassified' }
OMeta2Base class >> matchAll: aSequenceableCollection with: aRule withArgs: args [

	^ self matchStream: aSequenceableCollection readStream with: aRule withArgs: args withPlaybackDebugging: false
]

{ #category : #'as yet unclassified' }
OMeta2Base class >> matchStream: aReadStream with: aRule withArgs: args withPlaybackDebugging: debugging [

	| input matcher ans|
	input := OM2LazyStream for: aReadStream withPos: 1.
	matcher := self new initInput: input.
	[
		matcher apply: #empty withArgs: args.
		ans := matcher apply: aRule.
		matcher apply: #end.
		^ ans
	] on: OM2Fail do: [:e |
		| curr prev prevPrev |
		debugging ifFalse: [e signal].
		curr := input.
		prev := nil.
		prevPrev := nil.
		[curr notNil] whileTrue: [
			prevPrev := prev.
			prev := curr.
			curr := curr basicTail
		].
		curr := prevPrev ifNotNil: [prevPrev] ifNil: [prev].
		self inform: 'will halt each time matcher reaches ', curr printString.
		matcher
			initInput: input;
			forgetEverything.
		curr ifNil: [self error: 'you''ve found a bug -- please tell Alex'].
		curr become: (OM2StreamDebugger for: curr copy).
		matcher haltingPoint: curr.
		matcher apply: #empty withArgs: args.
		ans := matcher apply: aRule.
		matcher apply: #end.
		^ ans
	]
]

{ #category : #'as yet unclassified' }
OMeta2Base class >> matcherOn: aReadStream [

	| input matcher |
	input := OM2LazyStream for: aReadStream withPos: 1.
	matcher := self new initInput: input.
	^ matcher
]

{ #category : #'rules-basic' }
OMeta2Base >> anything [

	| ans |
	ans := input head.
	input := input tail.
	^ ans
]

{ #category : #'rules-basic' }
OMeta2Base >> apply [

	| aRule |
	aRule := self apply: #anything.
	^ self apply: aRule
]

{ #category : #'rule application' }
OMeta2Base >> apply: aRule [

	" A memoRec is an association whose key is the answer,
	  and whose value is the next input. Failers pretend to
     be memoRecs, but throw a fail in response to #value "
	| memo memoRec |
	input == haltingPoint ifTrue: [self halt].
	memo := input memo.
	memoRec := memo at: aRule ifAbsent: [nil].
	memoRec ifNil: [
		| origInput failer ans |
		origInput := input.
		failer := OM2Failer new.
		memo at: aRule put: failer.
		ans := self perform: aRule.
		memoRec := ans -> input.
		memo at: aRule put: memoRec.
		failer used ifTrue: [
			" left recursion detected "
			| sentinel keepGoing |
			sentinel := input.
			keepGoing := true.
			[keepGoing] whileTrue: [
				[
					input := origInput.
					ans := self perform: aRule.
					input == sentinel ifTrue: [OMeta2Fail signal].
					memoRec key: ans value: input.
				] on: OM2Fail do: [keepGoing := false]
			]
		]		
	].
	input := memoRec value.
	^ memoRec key
]

{ #category : #'rule application' }
OMeta2Base >> apply: aRule withArgs: args [

	args reverseDo: [:a | input := OM2Stream new initHead: a tail: input].
	^ self perform: aRule
]

{ #category : #private }
OMeta2Base >> consumedBy: aBlock [

	| origInput i ws |
	origInput := input.
	aBlock value.
	ws := WriteStream on: origInput inputSpecies new.
	i := origInput.
	[i == input] whileFalse: [
		ws nextPut: i head.
		i := i tail
	].
	^ ws contents
]

{ #category : #'rules-basic' }
OMeta2Base >> empty [

	^ true
]

{ #category : #'rules-basic' }
OMeta2Base >> firstAndRest [

	| first rest |
	first := self apply: #anything.
	rest := self apply: #anything.
	^ self genericMany: [self apply: rest] into: (OrderedCollection with: (self apply: first))
]

{ #category : #'rules-basic' }
OMeta2Base >> foreign [

	| aGrammar aRule g ans |
	aGrammar := self apply: #anything.
	aRule := self apply: #anything.
	g := aGrammar new initInput: (OM2StreamProxy for: input).
	ans := g apply: aRule.
	input := g input target.
	^ ans
]

{ #category : #forgetting }
OMeta2Base >> forgetEverything [

	input transitiveForgetEverything.
	om2streams valuesDo: [:s | s transitiveForgetEverything]
]

{ #category : #'rules-basic' }
OMeta2Base >> form: aBlock [

	| v origInput |
	v := self apply: #anything.
	self pred: (v isCollection and: [v isSequenceable and: [v isSymbol not]]).
	origInput := input.
	input := om2streams at: v ifAbsentPut: [OM2LazyStream for: v readStream withPos: 1].
	aBlock value.
	self apply: #end.
	input := origInput.
	^ v
]

{ #category : #private }
OMeta2Base >> genericMany: aBlock into: anOrderedCollection [

	[
		| origInput |
		origInput := input.
		[anOrderedCollection addLast: aBlock value] on: OM2Fail do: [
			input := origInput.
			^ anOrderedCollection
		].
		true
	] whileTrue
]

{ #category : #'initialize-release' }
OMeta2Base >> haltingPoint: anOM2Stream [

	haltingPoint := anOM2Stream
]

{ #category : #private }
OMeta2Base >> indexConsumedBy: aBlock [

	| from to |
	from := self pos.
	aBlock value.
	to := self pos.
	^ from -> to
]

{ #category : #'initialize-release' }
OMeta2Base >> initInput: i [

	input := i
]

{ #category : #'initialize-release' }
OMeta2Base >> initialize [

	super initialize.
	om2streams := IdentityDictionary new
]

{ #category : #'rules-basic' }
OMeta2Base >> input [

	^ input
]

{ #category : #private }
OMeta2Base >> lookahead: aBlock [

	| origInput ans |
	origInput := input.
	ans := aBlock value.
	input := origInput.
	^ ans
]

{ #category : #private }
OMeta2Base >> many1: aBlock [

	^ self genericMany: aBlock into: (OrderedCollection with: aBlock value)
]

{ #category : #private }
OMeta2Base >> many: aBlock [

	^ self genericMany: aBlock into: OrderedCollection new
]

{ #category : #private }
OMeta2Base >> not: aBlock [

	| origInput |
	origInput := input.
	[aBlock value] on: OM2Fail do: [
		input := origInput.
		^ true
	].
	OMeta2Fail signal
]

{ #category : #private }
OMeta2Base >> ometaOr: choices [

	| origInput |
	origInput := input.
	choices do: [:choice |
		input := origInput.
		[^ choice value] on: OM2Fail do: []
	].
	OMeta2Fail signal
]

{ #category : #private }
OMeta2Base >> opt: aBlock [

	^ self ometaOr: {
		[aBlock value].
		[nil]
	}
]

{ #category : #'rules-basic' }
OMeta2Base >> pos [

	^ input pos
]

{ #category : #private }
OMeta2Base >> pred: aBooleanValue [

	" may want to have the compiler inline this automatically, for performance "
	aBooleanValue ifTrue: [^ true].
	OMeta2Fail signal
]

{ #category : #'rules-basic' }
OMeta2Base >> seq [

	| xs |
	xs := self apply: #anything.
	xs do: [:x |
		" may want to inline #apply:withArgs: below as an
		  optimization, since this rule gets used a lot "
		self apply: #exactly withArgs: {x}
	].
	^ xs
	
]

{ #category : #'rule application' }
OMeta2Base >> super: superclass apply: aRule withArgs: args [

	args reverseDo: [:a | input := OM2Stream new initHead: a tail: input].
	^ self perform: aRule withArguments: #() inSuperclass: superclass
]
