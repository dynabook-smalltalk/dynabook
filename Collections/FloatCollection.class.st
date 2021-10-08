"
FloatCollctions store 32bit IEEE floating point numbers.
"
Class {
	#name : #FloatCollection,
	#superclass : #NonPointersOrderedCollection,
	#category : #'Collections-Sequenceable'
}

{ #category : #private }
FloatCollection class >> arrayType [
	^ FloatArray
]

{ #category : #converting }
FloatCollection >> asFloatArray [
	"Optimized version"

	^array copyFrom: firstIndex to: lastIndex
]
