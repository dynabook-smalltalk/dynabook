Class {
	#name : #OMeta2NullOpt,
	#superclass : #OMeta2,
	#instVars : [
		'didSomething'
	],
	#category : #OMeta2
}

{ #category : #rules }
OMeta2NullOpt >> and [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self
										many: [self apply: #trans].
							t1 addFirst: #And;
								 yourself]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> consby [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{#ConsBy. t1}]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> form [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{#Form. t1}]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> helped [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self pred: didSomething]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> idxconsby [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{#IdxConsBy. t1}]]}]]}
]

{ #category : #'initialize-release' }
OMeta2NullOpt >> initialize [

	super initialize.
	didSomething := false
]

{ #category : #rules }
OMeta2NullOpt >> lookahead [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{#Lookahead. t1}]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> many [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{#Many. t1}]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> many1 [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{#Many1. t1}]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> not [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{#Not. t1}]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> opt [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							{#Opt. t1}]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> optimize [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							self apply: #helped.
							t1]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> or [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self
										many: [self apply: #trans].
							t1 addFirst: #Or;
								 yourself]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> rule [
	| t1 t3 t4 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t3 := self apply: #anything.
							t4 := self apply: #anything.
							t1 := self apply: #trans.
							{#Rule. t3. t4. t1}]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> set [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #anything.
							t3 := self apply: #trans.
							{#Set. t1. t3}]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> setHelped [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [didSomething := true]]}]]}
]

{ #category : #rules }
OMeta2NullOpt >> trans [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								form: [self ometaOr: {[true
											ifTrue: [t3 := self apply: #anything.
												t3 := t3 asLowercase asSymbol.
												self
													pred: (self class canUnderstand: t3).
												t1 := self apply: #apply withArgs: {t3}]]}].
							t1]]. [true
						ifTrue: [self apply: #anything]]}]]}
]
