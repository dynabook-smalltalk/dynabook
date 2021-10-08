"
Here's how to run these examples:

	OMeta2Examples match: 5 with: #fact.
	OMeta2Examples matchAll: '1234' with: #number.
	OMeta2Examples matchAll: 'abc123' with: #identifier.
	OMeta2Examples matchAll: #($a $b $c 1 2 3 #(4 5)) with: #structure.
	OMeta2Examples matchAll: 'howdy' with: #greeting.
"
Class {
	#name : #OMeta2Examples,
	#superclass : #OMeta2,
	#category : #OMeta2
}

{ #category : #'squeak methods' }
OMeta2Examples >> aSqueakMethod [

	self inform: 'hello world'
]

{ #category : #'squeak methods' }
OMeta2Examples >> anotherSqueakMethod [

	self inform: 'good-bye world'
]

{ #category : #rules }
OMeta2Examples >> digit [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self
										super: OMeta2
										apply: #digit
										withArgs: {}.
							t1 digitValue]]}]]}
]

{ #category : #rules }
OMeta2Examples >> fact [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [self apply: #exactly withArgs: {0}].
				self ometaOr: {[true
						ifTrue: [1]]}]]. [true
			ifTrue: [true
					ifTrue: [t3 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #fact withArgs: {t3 - 1}.
							t3 * t1]]}]]}
]

{ #category : #rules }
OMeta2Examples >> formTest [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								form: [self ometaOr: {[true
											ifTrue: [self inform: input hash printString.
												self apply: #exactly withArgs: {#foo}.
												self apply: #exactly withArgs: {#bar}]]}]]]. [true
						ifTrue: [self
								form: [self ometaOr: {[true
											ifTrue: [self inform: input hash printString.
												self apply: #exactly withArgs: {#bar}]]}]]]}]]}
]

{ #category : #rules }
OMeta2Examples >> greeting [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								consumedBy: [self ometaOr: {[true
											ifTrue: [self apply: #seq withArgs: {'howdy'}.
												self
													opt: [self apply: #seq withArgs: {'-ho'}]]]}]]]}]]}
]

{ #category : #rules }
OMeta2Examples >> identifier [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #spaces.
							self
								consumedBy: [self ometaOr: {[true
											ifTrue: [self apply: #letter.
												self
													many: [self ometaOr: {[true
																ifTrue: [self apply: #letter]]. [true
																ifTrue: [self apply: #digit]]}]]]}]]]}]]}
]

{ #category : #rules }
OMeta2Examples >> identifierIdx [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #spaces.
							self
								indexConsumedBy: [self ometaOr: {[true
											ifTrue: [self apply: #letter.
												self
													many: [self ometaOr: {[true
																ifTrue: [self apply: #letter]]. [true
																ifTrue: [self apply: #digit]]}]]]}]]]}]]}
]

{ #category : #rules }
OMeta2Examples >> identifiers [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								many: [self ometaOr: {[true
											ifTrue: [self inform: self pos printString.
												self apply: #identifier]]}]]]}]]}
]

{ #category : #rules }
OMeta2Examples >> number [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t3 := self apply: #number.
							t1 := self apply: #digit.
							t3 * 10 + t1]]. [true
						ifTrue: [self apply: #digit]]}]]}
]

{ #category : #rules }
OMeta2Examples >> structure [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #exactly withArgs: {$a}.
							self apply: #exactly withArgs: {$b}.
							self apply: #exactly withArgs: {$c}.
							self apply: #exactly withArgs: {1}.
							self apply: #exactly withArgs: {2}.
							self apply: #exactly withArgs: {3}.
							self
								form: [self ometaOr: {[true
											ifTrue: [self
													many: [self apply: #anything]]]}]]]}]]}
]
