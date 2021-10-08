"
FloatArrays store 32bit IEEE floating point numbers.
"
Class {
	#name : #FloatArray,
	#superclass : #ArrayedCollection,
	#type : #words,
	#category : #'Collections-Arrayed'
}

{ #category : #arithmetic }
FloatArray >> * anObject [

	^self shallowCopy *= anObject
]

{ #category : #arithmetic }
FloatArray >> *= anObject [
	^anObject isNumber
		ifTrue:[self primMulScalar: anObject asFloat]
		ifFalse:[self primMulArray: anObject]
]

{ #category : #arithmetic }
FloatArray >> + anObject [

	^self shallowCopy += anObject
]

{ #category : #arithmetic }
FloatArray >> += anObject [
	^anObject isNumber
		ifTrue:[self primAddScalar: anObject asFloat]
		ifFalse:[self primAddArray: anObject]
]

{ #category : #arithmetic }
FloatArray >> - anObject [

	^self shallowCopy -= anObject
]

{ #category : #arithmetic }
FloatArray >> -= anObject [
	^anObject isNumber
		ifTrue:[self primSubScalar: anObject asFloat]
		ifFalse:[self primSubArray: anObject]
]

{ #category : #arithmetic }
FloatArray >> / anObject [

	^self shallowCopy /= anObject
]

{ #category : #arithmetic }
FloatArray >> /= anObject [
	^anObject isNumber
		ifTrue:[self primDivScalar: anObject asFloat]
		ifFalse:[self primDivArray: anObject]
]

{ #category : #comparing }
FloatArray >> = aFloatArray [ 
	<primitive: 'primitiveEqual' module: 'FloatArrayPlugin'>
	^super = aFloatArray
]

{ #category : #arithmetic }
FloatArray >> \\= other [

	other isNumber ifTrue: [
		1 to: self size do: [:i |
			self at: i put: (self at: i) \\ other
		].
		^ self.
	].
	1 to: (self size min: other size) do: [:i |
		self at: i put: (self at: i) \\ (other at: i).
	].


]

{ #category : #arithmetic }
FloatArray >> adaptToNumber: rcvr andSend: selector [
	"If I am involved in arithmetic with a Number. If possible,
	convert it to a float and perform the (more efficient) primitive operation."
	selector == #+ ifTrue:[^self + rcvr].
	selector == #* ifTrue:[^self * rcvr].
	selector == #- ifTrue:[^self negated += rcvr].
	selector == #/ ifTrue:[
		"DO NOT USE TRIVIAL CODE
			^self reciprocal * rcvr
		BECAUSE OF GRADUAL UNDERFLOW
		self should: (1.0e-39 / (FloatArray with: 1.0e-39)) first < 2."
			^(self class new: self size withAll: rcvr) / self
		].
	^super adaptToNumber: rcvr andSend: selector
]

{ #category : #converting }
FloatArray >> asFloatArray [
	^self
]

{ #category : #accessing }
FloatArray >> at: index [
	<primitive: 'primitiveAt' module: 'FloatArrayPlugin'>
	^Float fromIEEE32Bit: (self basicAt: index)
]

{ #category : #accessing }
FloatArray >> at: index put: value [
	<primitive: 'primitiveAtPut' module: 'FloatArrayPlugin'>
	value isFloat 
		ifTrue:[self basicAt: index put: value asIEEE32BitWord]
		ifFalse:[self at: index put: value asFloat].
	^value
]

{ #category : #accessing }
FloatArray >> defaultElement [
	"Return the default element of the receiver"
	^0.0
]

{ #category : #arithmetic }
FloatArray >> dot: aFloatVector [
	"Primitive. Return the dot product of the receiver and the argument.
	Fail if the argument is not of the same size as the receiver."

	| result |
	<primitive: 'primitiveDotProduct' module: 'FloatArrayPlugin'>
	self size = aFloatVector size ifFalse:[^self error:'Must be equal size'].
	result := 0.0.
	1 to: self size do:[:i|
		result := result + ((self at: i) * (aFloatVector at: i)).
	].
	^result
]

{ #category : #comparing }
FloatArray >> hash [
	| result |
	<primitive:'primitiveHashArray' module: 'FloatArrayPlugin'>
	result := 0.
	1 to: self size do:[:i| result := result + (self basicAt: i) ].
	^result bitAnd: 16r1FFFFFFF
]

{ #category : #accessing }
FloatArray >> length [
	"Return the length of the receiver"
	^self squaredLength sqrt
]

{ #category : #arithmetic }
FloatArray >> negated [

	^self shallowCopy *= -1
]

{ #category : #arithmetic }
FloatArray >> normalize [
	"Unsafely normalize the receiver in-place (become a unit vector).
 	 Div-by-Zero raised if len 0."
	<primitive: 'primitiveNormalize' module: 'FloatArrayPlugin'>
	self /= self length.
]

{ #category : #'primitives-plugin' }
FloatArray >> primAddArray: floatArray [

	<primitive: 'primitiveAddFloatArray' module: 'FloatArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) + (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
FloatArray >> primAddScalar: scalarValue [

	<primitive: 'primitiveAddScalar' module: 'FloatArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) + scalarValue].
]

{ #category : #'primitives-plugin' }
FloatArray >> primDivArray: floatArray [

	<primitive: 'primitiveDivFloatArray' module: 'FloatArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) / (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
FloatArray >> primDivScalar: scalarValue [

	<primitive: 'primitiveDivScalar' module: 'FloatArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) / scalarValue].
]

{ #category : #'primitives-plugin' }
FloatArray >> primMulArray: floatArray [

	<primitive: 'primitiveMulFloatArray' module: 'FloatArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) * (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
FloatArray >> primMulScalar: scalarValue [

	<primitive: 'primitiveMulScalar' module: 'FloatArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) * scalarValue].
]

{ #category : #'primitives-plugin' }
FloatArray >> primSubArray: floatArray [

	<primitive: 'primitiveSubFloatArray' module: 'FloatArrayPlugin'>
	self isOfSameSizeCheck: floatArray.
	1 to: self size do:[:i| self at: i put: (self at: i) - (floatArray at: i)].
]

{ #category : #'primitives-plugin' }
FloatArray >> primSubScalar: scalarValue [

	<primitive: 'primitiveSubScalar' module: 'FloatArrayPlugin'>
	1 to: self size do:[:i| self at: i put: (self at: i) - scalarValue].
]

{ #category : #private }
FloatArray >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	super replaceFrom: start to: stop with: replacement startingAt: repStart
]

{ #category : #accessing }
FloatArray >> squaredLength [
	"Return the squared length of the receiver"
	^self dot: self
]

{ #category : #'primitives-plugin' }
FloatArray >> sum [

	<primitive: 'primitiveSum' module: 'FloatArrayPlugin'>
	^ super sum
]
