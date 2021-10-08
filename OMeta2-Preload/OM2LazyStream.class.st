Class {
	#name : #OM2LazyStream,
	#superclass : #OM2Stream,
	#instVars : [
		'stream',
		'pos'
	],
	#category : #OMeta2
}

{ #category : #'as yet unclassified' }
OM2LazyStream class >> for: aReadStream withPos: pos [

	^ aReadStream atEnd
		ifTrue: [OM2EndOfStream new initStream: aReadStream pos: pos]
		ifFalse: [self new initHead: aReadStream next stream: aReadStream pos: pos]
]

{ #category : #'initialize-release' }
OM2LazyStream >> initHead: h stream: s pos: p [

	head := h.
	stream := s.
	pos := p
]

{ #category : #accessing }
OM2LazyStream >> inputSpecies [

	^ stream originalContents species
]

{ #category : #accessing }
OM2LazyStream >> pos [

	^ pos
]

{ #category : #accessing }
OM2LazyStream >> tail [

	tail ifNil: [tail := OM2LazyStream for: stream withPos: pos + 1].
	^ tail
]
