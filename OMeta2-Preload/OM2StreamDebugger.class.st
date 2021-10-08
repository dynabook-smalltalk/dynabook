Class {
	#name : #OM2StreamDebugger,
	#superclass : #OM2Stream,
	#instVars : [
		'om2stream'
	],
	#category : #OMeta2
}

{ #category : #'as yet unclassified' }
OM2StreamDebugger class >> for: anOM2Stream [

	^ self new initOm2stream: anOM2Stream
]

{ #category : #forgetting }
OM2StreamDebugger >> forgetEverything [

	om2stream forgetEverything
]

{ #category : #accessing }
OM2StreamDebugger >> head [

	^ om2stream head
]

{ #category : #'initialize-release' }
OM2StreamDebugger >> initOm2stream: anOM2Stream [

	om2stream := anOM2Stream
]

{ #category : #accessing }
OM2StreamDebugger >> memo [

	^ om2stream memo
]

{ #category : #printing }
OM2StreamDebugger >> printOn: aStream [

	aStream nextPutAll: 'an OM2StreamDebugger('.
	om2stream printOn: aStream.
	aStream nextPut: $)
]

{ #category : #accessing }
OM2StreamDebugger >> tail [

	^ om2stream tail
]

{ #category : #forgetting }
OM2StreamDebugger >> transitiveForgetEverything [

	om2stream transitiveForgetEverything
]
