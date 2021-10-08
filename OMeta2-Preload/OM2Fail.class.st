Class {
	#name : #OM2Fail,
	#superclass : #Exception,
	#category : #OMeta2
}

{ #category : #'class initialization' }
OM2Fail class >> initialize [
	(Smalltalk at: #OMeta2Fail ifAbsent: []) class == self
		ifFalse: [Smalltalk at: #OMeta2Fail put: self new]
]

{ #category : #'priv handling' }
OM2Fail >> defaultAction [

	self error: 'match failed'
]
