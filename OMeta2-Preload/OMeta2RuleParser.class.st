Class {
	#name : #OMeta2RuleParser,
	#superclass : #OMeta2,
	#instVars : [
		'temps'
	],
	#category : #OMeta2
}

{ #category : #'as yet unclassified' }
OMeta2RuleParser class >> isOMeta2Rule: aString [

	^ [(self matchAll: aString with: #rule) first ~= #Squeak] on: OM2Fail do: [false]
]

{ #category : #rules }
OMeta2RuleParser >> application [
	| t1 t3 t4 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {'^'}.
							t4 := self apply: #name.
							t1 := self apply: #args.
							{#SuperApp. t4} , t1]]. [true
						ifTrue: [t3 := self apply: #name.
							self apply: #exactly withArgs: {$.}.
							t4 := self apply: #nsName.
							t1 := self apply: #args.
							{#App. #foreign. t3. ('#' , t4) asSymbol} , t1]]. [true
						ifTrue: [t4 := self apply: #name.
							t1 := self apply: #args.
							{#App. t4} , t1]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> args [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #exactly withArgs: {$(}.
							t1 := self apply: #listOf withArgs: {#squeakExpression. '.'}.
							self apply: #token withArgs: {')'}.
							t1]]. [true
						ifTrue: [self
								not: [self apply: #exactly withArgs: {$(}].
							#()]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> characterLiteral [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #spaces.
							self apply: #exactly withArgs: {$$}.
							t1 := self apply: #char.
							{#App. #exactly. t1 storeString}]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> characters [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {'``'}.
							t1 := self
										many: [self ometaOr: {[true
													ifTrue: [self
															not: [self ometaOr: {[true
																		ifTrue: [self apply: #exactly withArgs: {$'}.
																			self apply: #exactly withArgs: {$'}]]}].
														self apply: #char]]}].
							self apply: #exactly withArgs: {$'}.
							self apply: #exactly withArgs: {$'}.
							{#App. #seq. (String withAll: t1) storeString}]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> expr [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #listOf withArgs: {#expr4. '|'}.
							(OrderedCollection with: #Or) addAll: t1;
								 yourself]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> expr1 [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t3 := self ometaOr: {[true
											ifTrue: [self apply: #keyword withArgs: {'true'}]]. [true
											ifTrue: [self apply: #keyword withArgs: {'false'}]]. [true
											ifTrue: [self apply: #keyword withArgs: {'nil'}]]}.
							{#App. #exactly. t3}]]. [true
						ifTrue: [self apply: #application]]. [true
						ifTrue: [self apply: #semanticAction]]. [true
						ifTrue: [self apply: #semanticPredicate]]. [true
						ifTrue: [self apply: #characters]]. [true
						ifTrue: [self apply: #tokenSugar]]. [true
						ifTrue: [self apply: #stringLiteral]]. [true
						ifTrue: [self apply: #symbolLiteral]]. [true
						ifTrue: [self apply: #numberLiteral]]. [true
						ifTrue: [self apply: #characterLiteral]]. [true
						ifTrue: [self apply: #token withArgs: {'{'}.
							t1 := self apply: #expr.
							self apply: #token withArgs: {'}'}.
							{#Form. t1}]]. [true
						ifTrue: [self apply: #token withArgs: {'<'}.
							t1 := self apply: #expr.
							self apply: #token withArgs: {'>'}.
							{#ConsBy. t1}]]. [true
						ifTrue: [self apply: #token withArgs: {'@<'}.
							t1 := self apply: #expr.
							self apply: #token withArgs: {'>'}.
							{#IdxConsBy. t1}]]. [true
						ifTrue: [self apply: #token withArgs: {'('}.
							t1 := self apply: #expr.
							self apply: #token withArgs: {')'}.
							t1]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> expr2 [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {'~'}.
							t1 := self apply: #expr2.
							{#Not. t1}]]. [true
						ifTrue: [self apply: #token withArgs: {'&'}.
							t1 := self apply: #expr2.
							{#Lookahead. t1}]]. [true
						ifTrue: [self apply: #expr1]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> expr3 [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t3 := self apply: #expr2.
							t3 := self apply: #optIter withArgs: {t3}.
							self ometaOr: {[true
									ifTrue: [self apply: #exactly withArgs: {$:}.
										t1 := self apply: #nsName.
										temps add: t1.
										{#Set. t1. t3}]]. [true
									ifTrue: [self apply: #empty.
										t3]]}]]. [true
						ifTrue: [self apply: #token withArgs: {':'}.
							t1 := self apply: #nsName.
							temps add: t1.
							{#Set. t1. {#App. #anything}}]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> expr4 [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self
										many: [self apply: #expr3].
							(OrderedCollection with: #And) addAll: t1;
								 yourself]]}]]}
]

{ #category : #'initialize-release' }
OMeta2RuleParser >> initialize [

	super initialize.
	temps := IdentitySet new
]

{ #category : #'rules-meta' }
OMeta2RuleParser >> keyword [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [t1 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {t1}.
							self
								not: [self apply: #letterOrDigit].
							t1]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> name [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #spaces.
							self apply: #nsName]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> nameFirst [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #letter]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> nameRest [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #nameFirst]]. [true
						ifTrue: [self apply: #digit]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> nsName [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #firstAndRest withArgs: {#nameFirst. #nameRest}.
							(String withAll: t1) asSymbol]]. [true
						ifTrue: [self apply: #exactly withArgs: {$_}.
							#anything]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> numberLiteral [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #spaces.
							t3 := self ometaOr: {[true
											ifTrue: [self apply: #exactly withArgs: {$-}.
												self apply: #spaces.
												-1]]. [true
											ifTrue: [self apply: #empty.
												1]]}.
							t1 := self
										many1: [self apply: #digit].
							{#App. #exactly. (t3 * (String withAll: t1) asNumber) storeString}]]}]]}
]

{ #category : #'rules-meta' }
OMeta2RuleParser >> optIter [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [t1 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {'*'}.
							{#Many. t1}]]. [true
						ifTrue: [self apply: #token withArgs: {'+'}.
							{#Many1. t1}]]. [true
						ifTrue: [self apply: #token withArgs: {'?'}.
							self
								not: [self apply: #exactly withArgs: {$[}].
							{#Opt. t1}]]. [true
						ifTrue: [self apply: #empty.
							t1]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> rule [
	| t1 t3 t4 t5 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								not: [self ometaOr: {[true
											ifTrue: [self
													many: [self
															super: OMeta2
															apply: #space
															withArgs: {}].
												self apply: #nsName.
												self apply: #expr4.
												self apply: #token withArgs: {'='}]]}].
							t3 := self
										consumedBy: [self ometaOr: {[true
													ifTrue: [self
															many: [self apply: #char]]]}].
							{#Squeak. t3}]]. [true
						ifTrue: [t1 := self
										lookahead: [self ometaOr: {[true
													ifTrue: [self
															many: [self
																	super: OMeta2
																	apply: #space
																	withArgs: {}].
														self apply: #nsName]]}].
							t4 := self apply: #rulePart withArgs: {t1}.
							t5 := self
										many: [self ometaOr: {[true
													ifTrue: [self apply: #token withArgs: {','}.
														self apply: #rulePart withArgs: {t1}]]}].
							self apply: #spaces.
							self apply: #end.
							{#Rule. t1. temps asSortedCollection. (OrderedCollection with: #Or with: t4) addAll: t5;
								 yourself}]]}]]}
]

{ #category : #'rules-meta' }
OMeta2RuleParser >> rulePart [
	| t1 t3 t4 t5 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [t5 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [t4 := self apply: #name.
							self pred: t4 = t5.
							t1 := self apply: #expr4.
							self ometaOr: {[true
									ifTrue: [self apply: #token withArgs: {'='}.
										t3 := self apply: #expr.
										{#And. t1. t3}]]. [true
									ifTrue: [self apply: #empty.
										t1]]}]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> semanticAction [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								opt: [self apply: #token withArgs: {'->'}].
							self apply: #token withArgs: {'['}.
							t1 := self apply: #squeakExpression.
							self apply: #exactly withArgs: {$]}.
							{#Act. t1}]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> semanticPredicate [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {'?['}.
							t1 := self apply: #squeakExpression.
							self apply: #exactly withArgs: {$]}.
							{#Pred. t1}]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> space [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								super: OMeta2
								apply: #space
								withArgs: {}]]. [true
						ifTrue: [self apply: #fromTo withArgs: {'/*'. '*/'}]]. [true
						ifTrue: [self apply: #fromTo withArgs: {'//'. String cr}]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> squeakExpression [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #foreign withArgs: {O2SqueakRecognizer. #squeakExpr}.
							self apply: #spaces.
							t1]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> stringLiteral [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {''''}.
							t1 := self
										many: [self ometaOr: {[true
													ifTrue: [self apply: #exactly withArgs: {$'}.
														self apply: #exactly withArgs: {$'}.
														$']]. [true
													ifTrue: [self
															not: [self apply: #exactly withArgs: {$'}].
														self apply: #char]]}].
							self apply: #exactly withArgs: {$'}.
							{#App. #exactly. (String withAll: t1) storeString}]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> symbolLiteral [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {'#'}.
							t1 := self apply: #nsName.
							{#App. #exactly. t1 storeString}]]}]]}
]

{ #category : #rules }
OMeta2RuleParser >> tokenSugar [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {'"'}.
							t1 := self
										many: [self ometaOr: {[true
													ifTrue: [self
															not: [self apply: #exactly withArgs: {$"}].
														self apply: #char]]}].
							self apply: #exactly withArgs: {$"}.
							{#App. #token. (String withAll: t1) storeString}]]}]]}
]
