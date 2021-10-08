"
This class is more appropriate remote models.

QUICK & VERY DIRTY IMPLEMENTATION

features:
- hold strong references to dependents

future features:
- handle disponibility errors in notification process
- hold strong references to event handlers (#when: family of methods)

"
Class {
	#name : #RSTModel,
	#superclass : #Model,
	#instVars : [
		'strongDependents'
	],
	#category : #'rST-Core'
}

{ #category : #dependents }
RSTModel >> addDependent: anObject [ 
	self strongDependents add: anObject.
	super addDependent: anObject
]

{ #category : #dependents }
RSTModel >> breakDependents [
	super breakDependents.
	self clearStrongDependents
]

{ #category : #private }
RSTModel >> clearStrongDependents [
	strongDependents _ nil
]

{ #category : #dependents }
RSTModel >> removeDependent: anObject [ 
	super removeDependent: anObject.
	self strongDependents
		remove: anObject
		ifAbsent: [].
	self strongDependents isEmpty
		ifTrue: [self clearStrongDependents]
]

{ #category : #private }
RSTModel >> strongDependents [
	^ strongDependents
		ifNil: [strongDependents _ IdentitySet new]
]
