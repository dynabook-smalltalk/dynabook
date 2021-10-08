"
I'm the Inspector for the Remote Objects
"
Class {
	#name : #RSTRemoteInspector,
	#superclass : #Inspector,
	#category : #'rST-Core'
}

{ #category : #'user interface' }
RSTRemoteInspector >> defaultBackgroundColor [
	"change the default color so the user realize as soon as posible that the object is a remote one"
	^ Color blue twiceLighter
]
