Class {
	#name : #OMeta2Optimizer,
	#superclass : #OMeta2,
	#category : #OMeta2
}

{ #category : #rules }
OMeta2Optimizer >> optimizeRule [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #anything.
							self
								many: [self ometaOr: {[true
											ifTrue: [t1 := self apply: #foreign withArgs: {OMeta2AndOrOpt. #optimize. t1}]]}].
							t1]]}]]}
]
