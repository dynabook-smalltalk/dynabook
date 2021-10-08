Class {
	#name : #OMeta2RuleTranslator,
	#superclass : #OMeta2,
	#instVars : [
		'grammarClass'
	],
	#category : #OMeta2
}

{ #category : #rules }
OMeta2RuleTranslator >> act [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #string.
							{'('. t1. ')'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> and [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self
										many: [self apply: #trans].
							{'(true ifTrue: ['. self delim: t1 with: '. '. '])'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> app [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t3 := self apply: #symbol.
							self ometaOr: {[true
									ifTrue: [t1 := self
													many1: [self apply: #anything].
										t1 := self delim: t1 with: '. '.
										{'(self apply: '. t3 storeString. ' withArgs: {'. t1. '})'}]]. [true
									ifTrue: [{'(self apply: '. t3 storeString. ')'}]]}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> consby [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{'(self consumedBy: ['. t1. '])'}]]}]]}
]

{ #category : #helpers }
OMeta2RuleTranslator >> delim: aSequenceableCollection  with: anObject [

	| first ans |
	first := true.
	ans := OrderedCollection new.
	aSequenceableCollection do: [:x |
		first ifTrue: [first := false] ifFalse: [ans add: anObject].
		ans add: x
	].
	^ ans
]

{ #category : #rules }
OMeta2RuleTranslator >> form [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{'(self form: ['. t1. '])'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> idxconsby [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{'(self indexConsumedBy: ['. t1. '])'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> lookahead [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{'(self lookahead: ['. t1. '])'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> many [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{'(self many: ['. t1. '])'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> many1 [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{'(self many1: ['. t1. '])'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> not [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{'(self not: ['. t1. '])'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> opt [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{'(self opt: ['. t1. '])'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> or [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t3 := self
										many: [self ometaOr: {[true
													ifTrue: [t1 := self apply: #trans.
														{'['. t1. ']'}]]}].
							{'(self ometaOr: {'. self delim: t3 with: '. '. '})'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> pred [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #string.
							{'(self pred: ('. t1. '))'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> rule [
	| t1 t3 t4 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t3 := self apply: #symbol.
							t4 := self apply: #anything.
							t4 := t4
										select: [:t5 | (grammarClass instVarNames includes: t5) not].
							t1 := self apply: #trans.
							{t3. ' |'. self delim: t4 asSortedCollection with: ' '. ' | ^ '. t1}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> set [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #symbol.
							t3 := self apply: #trans.
							{'('. t1 asString. ' := '. t3. ')'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> squeak [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #string]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> superapp [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t3 := self apply: #symbol.
							t1 := self
										many: [self apply: #anything].
							t1 := self delim: t1 with: '. '.
							{'(self super: '. grammarClass superclass name. ' apply: '. t3 storeString. ' withArgs: {'. t1. '})'}]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> trans [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								form: [self ometaOr: {[true
											ifTrue: [t3 := self apply: #symbol.
												t1 := self apply: #apply withArgs: {t3 asLowercase asSymbol}]]}].
							t1]]}]]}
]

{ #category : #rules }
OMeta2RuleTranslator >> translate [
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [grammarClass := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [self apply: #trans]]}]]}
]
