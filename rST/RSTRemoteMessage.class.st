"
I'm a Remote Message
"
Class {
	#name : #RSTRemoteMessage,
	#superclass : #Message,
	#instVars : [
		'to'
	],
	#category : #'rST-Core'
}

{ #category : #'instance creation' }
RSTRemoteMessage class >> message: aMessage to: aRemoteObjectId using: aBroker [ 
	"creates an remote message but first wrap all parameters in transporters"
	| transportableArguments |
	transportableArguments _ aMessage arguments
				collect: [:each | aBroker transporterFor: each].
	^ (self selector: aMessage selector arguments: transportableArguments)
		initializeTo: aRemoteObjectId
]

{ #category : #executing }
RSTRemoteMessage >> executeIn: aBroker [ 
	"execute in a Broker context"
	^ aBroker processRemoteMessage: self
]

{ #category : #initialization }
RSTRemoteMessage >> initializeTo: aRemoteObjectId [
	to _ aRemoteObjectId.
]

{ #category : #printing }
RSTRemoteMessage >> printOn: aStream [ 
	super printOn: aStream.
	aStream nextPutAll: ' to: ';
		 nextPutAll: to asString
]

{ #category : #accessing }
RSTRemoteMessage >> to [
	^to
]
