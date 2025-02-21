"
WordArrays store 32-bit unsigned Integer values.

"
Class {
	#name : #WordArray,
	#superclass : #ArrayedCollection,
	#type : #words,
	#category : #'Collections-Arrayed'
}

{ #category : #'as yet unclassified' }
WordArray class >> bobsTest [
	| wa answer |
"
WordArray bobsTest
"
	answer := OrderedCollection new.
	wa := WordArray with: 16r01020304 with: 16r05060708.
	{false. true} do: [ :pad | | rawData s1 s2 wa2 |
		0 to: 3 do: [ :skip |
			s1 := RWBinaryOrTextStream on: ByteArray new.

			s1 next: skip put: 0.		"start at varying positions"
			wa writeOn: s1.
			pad ifTrue: [s1 next: 4-skip put: 0].	"force length to be multiple of 4"

			rawData := s1 contents.
			s2 := RWBinaryOrTextStream with: rawData.
			s2 reset.
			s2 skip: skip.			"get to beginning of object"
			wa2 := WordArray newFromStream: s2.
			answer add: {
				rawData size. 
				skip. 
				wa2 = wa. 
				wa2 asArray collect: [ :each | each radix: 16]
			}
		].
	].
	^answer explore
]

{ #category : #converting }
WordArray >> asWordArray [
	^self
]

{ #category : #accessing }
WordArray >> atAllPut: value [
	"Fill the receiver with the given value"

	<primitive: 145>
	super atAllPut: value
]

{ #category : #accessing }
WordArray >> byteSize [
	^self size * 4
]

{ #category : #accessing }
WordArray >> bytesPerElement [
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 4
]

{ #category : #accessing }
WordArray >> defaultElement [
	"Return the default element of the receiver"
	^0
]

{ #category : #private }
WordArray >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	<primitive: 105>
	^super replaceFrom: start to: stop with: replacement startingAt: repStart 
]
