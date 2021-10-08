Class {
	#name : #RSTPersonViewController,
	#superclass : #Object,
	#instVars : [
		'person',
		'model',
		'lastName',
		'lastEMail'
	],
	#category : #'rST-Samples'
}

{ #category : #'instance creation' }
RSTPersonViewController class >> on: aPerson [ 
	^ self new initializeOn: aPerson 

]

{ #category : #initialization }
RSTPersonViewController >> initializeOn: aPerson [ 
	person _ aPerson.

]

{ #category : #accessing }
RSTPersonViewController >> model [
	^ model
]

{ #category : #accessing }
RSTPersonViewController >> model: anObject [ 
	"Set my model and make me me a dependent of the given object."
	model
		ifNotNil: [model removeDependent: self].
	anObject
		ifNotNil: [anObject addDependent: self].
	model _ anObject
]

{ #category : #testing }
RSTPersonViewController >> test [
	| testName testEMail ok |
	ok _ true.
	self model: person.
	""
	testName _ 'Diego Gomez Deck'.
	person name: testName.
	lastName = testName
		ifFalse: [""
			Transcript show: '*** INVALID LAST NAME ***';
				 cr.
			ok _ false].
	""
	testEMail _ 'DiegoGomezDeck@ConsultAr.com'.
	person eMail: testEMail.
	lastEMail = testEMail
		ifFalse: [""
			Transcript show: '*** INVALID LAST EMAIL ***';
				 cr.
			ok _ false].
	""
	self model: nil.
	^ ok
]

{ #category : #updating }
RSTPersonViewController >> update: anEvent [ 
	anEvent = #name
		ifTrue: [lastName _ self model name].
	anEvent = #eMail
		ifTrue: [lastEMail _ self model eMail]
]
