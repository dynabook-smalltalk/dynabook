"
TODOS:

* implement OMeta -> Squeak translator
* implement Squeak parser
* implement OMeta/Squeak ""compiler"", make it OMeta2's compilerClass

* rewrite #char, #digit, #empty, #end, #exactly, #firstAndRest, #fromTo, #letter, #letterOrDigit, #listOf, #lower, #notLast, #number, #range, #space, #spaces, #string, #symbol, #token, and #upper in OMeta syntax
* consider implementing position-related functionality (see http://www.tinlizzie.org/ometa-js/ometa-base.js)
* consider the optimization suggestions in the comments of OMeta2Lib's methods
"
Class {
	#name : #OMeta2,
	#superclass : #OMeta2Base,
	#category : #OMeta2
}

{ #category : #rules }
OMeta2 >> char [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #anything.
							self pred: t1 isCharacter.
							t1]]}]]}
]

{ #category : #rules }
OMeta2 >> digit [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #char.
							self pred: t1 isDigit.
							t1]]}]]}
]

{ #category : #rules }
OMeta2 >> end [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								not: [self apply: #anything]]]}]]}
]

{ #category : #'rules-meta' }
OMeta2 >> exactly [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [t3 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #anything.
							self pred: t3 = t1.
							t3]]}]]}
]

{ #category : #rules }
OMeta2 >> fromTo [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [t1 := self apply: #anything.
						t3 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [self apply: #seq withArgs: {t1}.
							self
								many: [self ometaOr: {[true
											ifTrue: [self
													not: [self apply: #seq withArgs: {t3}].
												self apply: #char]]}].
							self apply: #seq withArgs: {t3}]]}]]}
]

{ #category : #rules }
OMeta2 >> letter [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #char.
							self pred: t1 isLetter.
							t1]]}]]}
]

{ #category : #rules }
OMeta2 >> letterOrDigit [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #char.
							self pred: t1 isAlphaNumeric.
							t1]]}]]}
]

{ #category : #'rules-meta' }
OMeta2 >> listOf [
	| t1 t3 t4 t5 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [t3 := self apply: #anything.
						t1 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [t4 := self apply: #apply withArgs: {t3}.
							t5 := self
										many: [self ometaOr: {[true
													ifTrue: [self apply: #token withArgs: {t1}.
														self apply: #apply withArgs: {t3}]]}].
							t5 addFirst: t4;
								 yourself]]. [true
						ifTrue: [self apply: #empty.
							#()]]}]]}
]

{ #category : #rules }
OMeta2 >> lower [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #char.
							self pred: t1 isLowercase.
							t1]]}]]}
]

{ #category : #'rules-meta' }
OMeta2 >> notLast [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [t3 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #apply withArgs: {t3}.
							self
								lookahead: [self apply: #apply withArgs: {t3}].
							t1]]}]]}
]

{ #category : #rules }
OMeta2 >> number [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #anything.
							self pred: t1 isNumber.
							t1]]}]]}
]

{ #category : #'rules-meta' }
OMeta2 >> range [
	| t1 t3 t4 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [t1 := self apply: #anything.
						t3 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [t4 := self apply: #anything.
							self pred: t1 <= t4 & t4 <= t3.
							t4]]}]]}
]

{ #category : #rules }
OMeta2 >> space [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #char.
							self pred: t1 asciiValue <= 32.
							t1]]}]]}
]

{ #category : #rules }
OMeta2 >> spaces [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								many: [self apply: #space]]]}]]}
]

{ #category : #rules }
OMeta2 >> string [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #anything.
							self pred: t1 isString.
							t1]]}]]}
]

{ #category : #rules }
OMeta2 >> symbol [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #anything.
							self pred: t1 isSymbol.
							t1]]}]]}
]

{ #category : #'rules-meta' }
OMeta2 >> token [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [t1 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [self apply: #spaces.
							self apply: #seq withArgs: {t1}]]}]]}
]

{ #category : #rules }
OMeta2 >> upper [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #char.
							self pred: t1 isUppercase.
							t1]]}]]}
]
