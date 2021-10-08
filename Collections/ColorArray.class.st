Class {
	#name : #ColorArray,
	#superclass : #ArrayedCollection,
	#type : #words,
	#category : #'Collections-Arrayed'
}

{ #category : #converting }
ColorArray >> asColorArray [
	^self
]

{ #category : #accessing }
ColorArray >> at: index [
	^(super at: index) asColorOfDepth: 32
]

{ #category : #accessing }
ColorArray >> at: index put: aColor [
	^super at: index put: (aColor pixelWordForDepth: 32).
]

{ #category : #converting }
ColorArray >> bytesPerElement [

	^4
]
