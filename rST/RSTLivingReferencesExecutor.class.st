"
I notity to a remote broker wich objects must keep alive
"
Class {
	#name : #RSTLivingReferencesExecutor,
	#superclass : #Object,
	#instVars : [
		'from',
		'objectIDs'
	],
	#category : #'rST-Core'
}

{ #category : #'instance creation' }
RSTLivingReferencesExecutor class >> from: brokerIDString objectIDs: aCollection [ 
	^ self new initializeFrom: brokerIDString objectIDs: aCollection
]

{ #category : #executing }
RSTLivingReferencesExecutor >> executeIn: aBroker [ 
	"execute in a Broker context"
	aBroker remoteBroker: from references: objectIDs.
	^ aBroker transporterFor: nil
]

{ #category : #initialization }
RSTLivingReferencesExecutor >> initializeFrom: brokerIDString objectIDs: aCollection [ 
	from _ brokerIDString.
	objectIDs _ aCollection
]

{ #category : #printing }
RSTLivingReferencesExecutor >> printOn: aStream [ 
	super printOn: aStream.
	aStream nextPutAll: ' from:';
		 nextPutAll: from;
		 nextPutAll: ' objectsIDs:';
		 print: objectIDs
]
