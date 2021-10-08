"
I represent a remote exception
"
Class {
	#name : #RSTRemoteException,
	#superclass : #Error,
	#category : #'rST-Core'
}

{ #category : #'instance creation' }
RSTRemoteException class >> on: anException [
	^ self new initializeOn: anException
]

{ #category : #initialization }
RSTRemoteException >> initializeOn: anException [
	self messageText: anException asString
]
