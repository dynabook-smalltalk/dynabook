Class {
	#name : #OMeta2AndOrOpt,
	#superclass : #OMeta2NullOpt,
	#category : #OMeta2
}

{ #category : #rules }
OMeta2AndOrOpt >> and [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							self apply: #end.
							self apply: #setHelped.
							t1]]. [true
						ifTrue: [t3 := self apply: #transInside withArgs: {#And}.
							t3 addFirst: #And;
								 yourself]]}]]}
]

{ #category : #rules }
OMeta2AndOrOpt >> or [
	| t1 t3 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #trans.
							self apply: #end.
							self apply: #setHelped.
							t1]]. [true
						ifTrue: [t3 := self apply: #transInside withArgs: {#Or}.
							t3 addFirst: #Or;
								 yourself]]}]]}
]

{ #category : #rules }
OMeta2AndOrOpt >> transInside [
	| t1 t3 t4 t5 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [t1 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [self
								form: [self ometaOr: {[true
											ifTrue: [self apply: #exactly withArgs: {t1}.
												t4 := self apply: #transInside withArgs: {t1}]]}].
							t5 := self apply: #transInside withArgs: {t1}.
							self apply: #setHelped.
							t4 , t5]]. [true
						ifTrue: [t3 := self apply: #trans.
							t4 := self apply: #transInside withArgs: {t1}.
							t4 addFirst: t3;
								 yourself]]. [true
						ifTrue: [self apply: #empty.
							OrderedCollection new]]}]]}
]
