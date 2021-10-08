Class {
	#name : #OM2Failer,
	#superclass : #Object,
	#instVars : [
		'used'
	],
	#category : #OMeta2
}

{ #category : #'initialize-release' }
OM2Failer >> initialize [

	used := false
]

{ #category : #testing }
OM2Failer >> used [

	^ used
]

{ #category : #evaluating }
OM2Failer >> value [

	used := true.
	OMeta2Fail signal
]
