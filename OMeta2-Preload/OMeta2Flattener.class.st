Class {
	#name : #OMeta2Flattener,
	#superclass : #OMeta2,
	#instVars : [
		'ws'
	],
	#category : #OMeta2
}

{ #category : #rules }
OMeta2Flattener >> flatten [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true
					ifTrue: [t1 := self apply: #anything].
				self ometaOr: {[true
						ifTrue: [self apply: #iFlatten withArgs: {t1}.
							ws contents]]}]]}
]

{ #category : #rules }
OMeta2Flattener >> iFlatten [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #string.
							ws nextPutAll: t1]]. [true
						ifTrue: [self
								form: [self ometaOr: {[true
											ifTrue: [self
													many: [self apply: #iFlatten]]]}]]]}]]}
]

{ #category : #'initialize-release' }
OMeta2Flattener >> initialize [

	super initialize.
	ws := (String new: 64) writeStream
]
