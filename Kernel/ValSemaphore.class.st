Class {
	#name : #ValSemaphore,
	#superclass : #Semaphore,
	#instVars : [
		'vals'
	],
	#category : #'Kernel-Processes'
}

{ #category : #'as yet unclassified' }
ValSemaphore >> initialize [
super initialize.
vals := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
ValSemaphore >> signal [
^self signal: nil
]

{ #category : #'as yet unclassified' }
ValSemaphore >> signal: x [
vals add: x.
^super signal
]

{ #category : #'as yet unclassified' }
ValSemaphore >> wait [
super wait.
^vals removeFirst
]
