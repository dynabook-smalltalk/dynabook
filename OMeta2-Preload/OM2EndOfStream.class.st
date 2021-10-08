Class {
	#name : #OM2EndOfStream,
	#superclass : #OM2Stream,
	#instVars : [
		'stream',
		'pos'
	],
	#category : #OMeta2
}

{ #category : #accessing }
OM2EndOfStream >> head [

	OMeta2Fail signal
]

{ #category : #'initialize-release' }
OM2EndOfStream >> initStream: s pos: p [

	stream := s.
	pos := p
]

{ #category : #accessing }
OM2EndOfStream >> inputSpecies [

	^ stream originalContents species
]

{ #category : #accessing }
OM2EndOfStream >> pos [

	^ pos
]

{ #category : #accessing }
OM2EndOfStream >> tail [

	OMeta2Fail signal
]
