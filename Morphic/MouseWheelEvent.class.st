Class {
	#name : #MouseWheelEvent,
	#superclass : #MouseEvent,
	#instVars : [
		'delta',
		'direction'
	],
	#category : #'Morphic-Events'
}

{ #category : #initialization }
MouseWheelEvent >> initialize [

	super initialize.
	direction := 2r0000.
	delta := 0@0.
]

{ #category : #testing }
MouseWheelEvent >> isMouseWheel [
	^ true
]

{ #category : #testing }
MouseWheelEvent >> isWheelDown [
	^ direction anyMask: 2r0100
]

{ #category : #testing }
MouseWheelEvent >> isWheelLeft [
	^ direction anyMask: 2r0010
]

{ #category : #testing }
MouseWheelEvent >> isWheelRight [
	^ direction anyMask: 2r0001
]

{ #category : #testing }
MouseWheelEvent >> isWheelUp [
	^ direction anyMask: 2r1000
]

{ #category : #printing }
MouseWheelEvent >> printOn: aStream [

	aStream nextPut: $[.
	aStream nextPutAll: self cursorPoint printString; space.
	aStream nextPutAll: type; space.
	aStream nextPutAll: self wheelString.
	aStream nextPutAll: self wheelDelta printString; space.
	aStream nextPutAll: self modifierString.
	aStream nextPutAll: self buttonString.
	aStream nextPutAll: timeStamp printString; space.
	aStream nextPut: $].
]

{ #category : #dispatching }
MouseWheelEvent >> sentTo: anObject [
	"Dispatch the receiver into anObject"
	type == #mouseWheel ifTrue: [^ anObject handleMouseWheel: self].
	^ super sentTo: anObject
]

{ #category : #private }
MouseWheelEvent >> setType: evtType position: evtPos delta: evtDelta direction: dirFlags buttons: evtButtons hand: evtHand stamp: stamp [
	type := evtType.
	position := evtPos.
	buttons := evtButtons.
	source := evtHand.
	wasHandled := false.
	direction := dirFlags.
	delta := evtDelta.
	timeStamp := stamp.
]

{ #category : #initialization }
MouseWheelEvent >> setWheelDown [

	direction := direction bitOr: 2r0100.
]

{ #category : #initialization }
MouseWheelEvent >> setWheelLeft [

	direction := direction bitOr: 2r0010.
]

{ #category : #initialization }
MouseWheelEvent >> setWheelRight [

	direction := direction bitOr: 2r0001.
]

{ #category : #initialization }
MouseWheelEvent >> setWheelUp [

	direction := direction bitOr: 2r1000.
]

{ #category : #printing }
MouseWheelEvent >> storeOn: aStream [
	"Note: We generate the same array as provided by the VM. BUT we are a subclass of MouseEvent now even if we cannot store the position right now. This is awkward. But we still store the position and the wheel delta. *sign*"
	
	super storeOn: aStream.
	aStream space.
	delta x storeOn: aStream.
	aStream space.
	delta y storeOn: aStream.
	aStream space.
	direction storeOn: aStream.

]

{ #category : #initialization }
MouseWheelEvent >> type: eventType readFrom: aStream [

	| deltaX deltaY |
	super type: eventType readFrom: aStream.
	aStream skip: 1.
	deltaX := Integer readFrom: aStream.
	aStream skip: 1.
	deltaY := Integer readFrom: aStream.
	aStream skip: 1.
	direction := Integer readFrom: aStream.
	delta := deltaX @ deltaY.

]

{ #category : #accessing }
MouseWheelEvent >> wheelDelta [

	^ delta
]

{ #category : #printing }
MouseWheelEvent >> wheelString [
	"Return a string identifying the wheel state"
	
	^ String streamContents: [:stream |
		self isWheelUp ifTrue: [stream nextPutAll: 'up '].
		self isWheelDown ifTrue: [stream nextPutAll: 'down '].
		self isWheelLeft ifTrue: [stream nextPutAll: 'left '].
		self isWheelRight ifTrue: [stream nextPutAll: 'right ']]
]
