"
I define a frame for positioning some morph in a proportional layout.

Instance variables:
	leftFraction 
	topFraction 
	rightFraction 
	bottomFraction 	<Float>		The fractional distance (between 0 and 1) to place the morph in its owner's bounds
	leftOffset 
	topOffset 
	rightOffset 
	bottomOffset 	<Integer>	Fixed pixel offset to apply after fractional positioning (e.g., ""10 pixel right of the center of the owner"")
"
Class {
	#name : #LayoutFrame,
	#superclass : #Object,
	#instVars : [
		'leftFraction',
		'leftOffset',
		'topFraction',
		'topOffset',
		'rightFraction',
		'rightOffset',
		'bottomFraction',
		'bottomOffset'
	],
	#category : #'Graphics-Primitives'
}

{ #category : #accessing }
LayoutFrame class >> classVersion [
	^1 "changed treatment of bottomOffset and rightOffset"

]

{ #category : #'instance creation' }
LayoutFrame class >> fractions: fractionsOrNil [
	^self fractions: fractionsOrNil offsets: nil
]

{ #category : #'instance creation' }
LayoutFrame class >> fractions: fractionsOrNil offsets: offsetsOrNil [

	| fractions offsets |

	fractions := fractionsOrNil ifNil: [0@0 extent: 0@0].
	offsets := offsetsOrNil ifNil: [0@0 extent: 0@0].
	^self new
		topFraction: fractions top offset: offsets top;
		leftFraction: fractions left offset: offsets left;
		bottomFraction: fractions bottom offset: offsets bottom;
		rightFraction: fractions right offset: offsets right

]

{ #category : #'instance creation' }
LayoutFrame class >> offsets: offsetsOrNil [
	^self fractions: nil offsets: offsetsOrNil
]

{ #category : #accessing }
LayoutFrame >> bottomFraction [
	^bottomFraction
]

{ #category : #accessing }
LayoutFrame >> bottomFraction: aNumber [
	bottomFraction := aNumber
]

{ #category : #accessing }
LayoutFrame >> bottomFraction: aNumber offset: anInteger [

	bottomFraction := aNumber.
	bottomOffset := anInteger
]

{ #category : #accessing }
LayoutFrame >> bottomOffset [
	^bottomOffset
]

{ #category : #accessing }
LayoutFrame >> bottomOffset: anInteger [
	bottomOffset := anInteger
]

{ #category : #'objects from disk' }
LayoutFrame >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	| className oldClassVersion |

	"JW 2/1/2001"
	"Since class version isn't passed in varDict, look it up through smartRefSrm."
	className := varDict at: #ClassName.
	oldClassVersion := (smartRefStrm structures at: className) first.
	(oldClassVersion = 0) ifTrue: [ self negateBottomRightOffsets ].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.

]

{ #category : #testing }
LayoutFrame >> hasFixedHeight [

	^ self topFraction = self bottomFraction
]

{ #category : #testing }
LayoutFrame >> hasFixedWidth [

	^ self leftFraction = self rightFraction
]

{ #category : #layout }
LayoutFrame >> layout: oldBounds in: newBounds [
	"Return the proportional rectangle insetting the given bounds"
	| left right top bottom |
	leftFraction ifNotNil:[
		left := newBounds left + (newBounds width * leftFraction).
		leftOffset ifNotNil:[left := left + leftOffset]].
	rightFraction ifNotNil:[
		right := newBounds right - (newBounds width * (1.0 - rightFraction)).
		rightOffset ifNotNil:[right := right + rightOffset]].
	topFraction ifNotNil:[
		top := newBounds top + (newBounds height * topFraction).
		topOffset ifNotNil:[top := top + topOffset]].
	bottomFraction ifNotNil:[
		bottom := newBounds bottom - (newBounds height * (1.0 - bottomFraction)).
		bottomOffset ifNotNil:[bottom := bottom + bottomOffset]].
	left ifNil:[ right 
			ifNil:[left := oldBounds left. right := oldBounds right]
			ifNotNil:[left := right - oldBounds width]].
	right ifNil:[right := left + oldBounds width].
	top ifNil:[ bottom 
			ifNil:[top := oldBounds top. bottom := oldBounds bottom]
			ifNotNil:[top := bottom - oldBounds height]].
	bottom ifNil:[bottom := top + oldBounds height].
	^(left rounded @ top rounded) corner: (right rounded @ bottom rounded)
]

{ #category : #accessing }
LayoutFrame >> leftFraction [
	^leftFraction
]

{ #category : #accessing }
LayoutFrame >> leftFraction: aNumber [
	leftFraction := aNumber
]

{ #category : #accessing }
LayoutFrame >> leftFraction: aNumber offset: anInteger [

	leftFraction := aNumber.
	leftOffset := anInteger
]

{ #category : #accessing }
LayoutFrame >> leftOffset [
	^leftOffset
]

{ #category : #accessing }
LayoutFrame >> leftOffset: anInteger [
	leftOffset := anInteger
]

{ #category : #layout }
LayoutFrame >> minExtentFrom: minExtent [
	"Return the minimal extent the given bounds can be represented in"
	^ (self minWidthFrom: minExtent x) @ (self minHeightFrom: minExtent y)
]

{ #category : #layout }
LayoutFrame >> minHeightFrom: minHeight [
	"Return the minimal extent the given bounds can be represented in"
	| height top bottom |
	top := topFraction ifNil: [0.0].
	bottom := bottomFraction ifNil: [1.0].
	height := bottom = top
		ifTrue: [0]
		ifFalse: [minHeight / (bottom - top)].
	topOffset ifNotNil:[height := height + topOffset].
	bottomOffset ifNotNil:[height := height + bottomOffset].
	^ height truncated
]

{ #category : #layout }
LayoutFrame >> minWidthFrom: minWidth [
	"Return the minimal extent the given bounds can be represented in"
	| width left right |
	left := leftFraction ifNil: [0.0].
	right := rightFraction ifNil: [1.0].
	width := left = right
		ifTrue: [0]
		ifFalse: [minWidth / (right - left)].
	leftOffset ifNotNil:[width := width + leftOffset].
	rightOffset ifNotNil:[width := width + rightOffset].
	^width truncated
]

{ #category : #'objects from disk' }
LayoutFrame >> negateBottomRightOffsets [

	bottomOffset ifNotNil: [ bottomOffset := bottomOffset negated ].
	rightOffset ifNotNil: [ rightOffset := rightOffset negated ].


]

{ #category : #printing }
LayoutFrame >> printOn: aStream [

	super printOn: aStream.
	
	aStream nextPutAll: '( '.
	
	{ {'l'. self leftFraction. self leftOffset}. {'t'. self topFraction. self topOffset}. {'r'. self rightFraction. self rightOffset}. {'b'. self bottomFraction. self bottomOffset} } do: [:spec |
		aStream nextPutAll: spec first; space.
		
		(spec second ifNil: [0]) printOn: aStream maxDecimalPlaces: 2.
		
		aStream nextPutAll: ((spec third ifNil: [0]) >= 0 ifTrue: ['+'] ifFalse: ['-']).
		(spec third ifNil: [0]) abs printOn: aStream maxDecimalPlaces: 0]
			separatedBy: [aStream space].
			
	aStream nextPutAll: ' )'.
]

{ #category : #accessing }
LayoutFrame >> rightFraction [
	^rightFraction
]

{ #category : #accessing }
LayoutFrame >> rightFraction: aNumber [
	rightFraction := aNumber
]

{ #category : #accessing }
LayoutFrame >> rightFraction: aNumber offset: anInteger [

	rightFraction := aNumber.
	rightOffset := anInteger
]

{ #category : #accessing }
LayoutFrame >> rightOffset [
	^rightOffset
]

{ #category : #accessing }
LayoutFrame >> rightOffset: anInteger [
	rightOffset := anInteger
]

{ #category : #accessing }
LayoutFrame >> topFraction [
	^topFraction
]

{ #category : #accessing }
LayoutFrame >> topFraction: aNumber [
	topFraction := aNumber
]

{ #category : #accessing }
LayoutFrame >> topFraction: aNumber offset: anInteger [

	topFraction := aNumber.
	topOffset := anInteger
]

{ #category : #accessing }
LayoutFrame >> topOffset [
	^topOffset
]

{ #category : #accessing }
LayoutFrame >> topOffset: anInteger [
	topOffset := anInteger
]
