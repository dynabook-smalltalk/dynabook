Class {
	#name : #OM2StreamProxy,
	#superclass : #OM2Stream,
	#instVars : [
		'target'
	],
	#category : #OMeta2
}

{ #category : #'as yet unclassified' }
OM2StreamProxy class >> for: anOM2Stream [

	^ self new initTarget: anOM2Stream
]

{ #category : #accessing }
OM2StreamProxy >> basicTail [

	^ target basicTail
]

{ #category : #accessing }
OM2StreamProxy >> head [

	head ifNil: [head := target head].
	^ head

]

{ #category : #'initialize-release' }
OM2StreamProxy >> initTarget: anOM2Stream [

	target := anOM2Stream
]

{ #category : #accessing }
OM2StreamProxy >> inputSpecies [

	^ target inputSpecies
]

{ #category : #accessing }
OM2StreamProxy >> pos [

	^ target pos
]

{ #category : #accessing }
OM2StreamProxy >> tail [

	tail ifNil: [tail := OM2StreamProxy for: target tail].
	^ tail
]

{ #category : #accessing }
OM2StreamProxy >> target [

	^ target
]
