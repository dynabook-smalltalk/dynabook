"
I'm a place where you can store objetcs, when you store an object you get an unique key for this instance, sucesives call to the pool answer the same unique key.

Aditionaly you can get the object with the key.

The references to the object are strong references
"
Class {
	#name : #KeyManager,
	#superclass : #Object,
	#instVars : [
		'lastKey',
		'dictionary',
		'mutex',
		'onNewKey'
	],
	#category : #'rST-Utilities'
}

{ #category : #'instance creation' }
KeyManager class >> new [
^ super new initialize
]

{ #category : #accessing }
KeyManager >> at: keyObject [
	"anser the object that the key was asigned before"
^ self at:keyObject ifAbsent:[self error:'Object no found for key:', keyObject asString]
]

{ #category : #accessing }
KeyManager >> at: keyObject ifAbsent: absentBlock [ 
	"anser the object that the key was asigned before"
	| value |
	mutex
		critical: [self flag: #TODO.
			"TODO: be carefull when WeakDictionary will be used"
			value _ dictionary
						at: keyObject
						ifAbsent: [].
			value
				ifNil: [value _ absentBlock value]].
	^ value
]

{ #category : #accessing }
KeyManager >> at: keyObject put: anObject [
	"asign keyObject to anObject"
	^ dictionary at: keyObject put: anObject
]

{ #category : #private }
KeyManager >> depurate [
	"PRIVATE: This method is called from a critical section, be carefull to call 
	it without synchonization"
	
]

{ #category : #accessing }
KeyManager >> hasKey: anObject [ 
	"answer if anObject has a key"
	anObject isNil
		ifTrue: [^ self error: 'can store a nil'].

	mutex
		critical: [dictionary
				keyAtIdentityValue: anObject
				ifAbsent: [^ false]].
	^ true
]

{ #category : #initialization }
KeyManager >> initialize [
	lastKey _ 0.
	mutex _ Semaphore forMutualExclusion.
	self initializeDictionary.
	onNewKey _ nil
]

{ #category : #initialization }
KeyManager >> initializeDictionary [
	"hook method"
	dictionary _ Dictionary new
]

{ #category : #accessing }
KeyManager >> keyFor: anObject [ 
	"gives a key for anObject, the key will be the same in future calls"
	| key |
	anObject isNil
		ifTrue: [^ self error: 'can store a nil'].
	mutex
		critical: [key _ dictionary
						keyAtIdentityValue: anObject
						ifAbsent: [self newKeyFor: anObject]].
	^ key
]

{ #category : #private }
KeyManager >> newKeyFor: anObject [ 
	"PRIVATE: This method is called from a critical section, be carefull to call 
	it without synchronization"
	| lastKeyAsString |
	lastKey _ lastKey + 1.
	lastKeyAsString _ 'OID-'
				, (65535 atRandom hex allButFirst: 3)
				, (lastKey hex allButFirst: 3)
				, (65535 atRandom hex allButFirst: 3).
	dictionary at: lastKeyAsString put: anObject.
	onNewKey isNil ifFalse:[onNewKey value: anObject value: lastKeyAsString].
	(lastKey isDivisibleBy: 25)
		ifTrue: [self depurate].
	^ lastKeyAsString
]

{ #category : #accessing }
KeyManager >> onNewKey: aBlock [
	onNewKey _ aBlock
]

{ #category : #printing }
KeyManager >> printOn: aStream [ 
	super printOn: aStream.
	aStream nextPutAll: ' last key=';
		 nextPutAll: lastKey asString;
		 nextPutAll: ', objects count=';
		 nextPutAll: dictionary size asString
]

{ #category : #removing }
KeyManager >> removeKey: keyObject [ 
mutex
		critical: [
	^ dictionary removeKey: keyObject]
]

{ #category : #accessing }
KeyManager >> size [
	"answer an estimated size"
	^ mutex
		critical: [dictionary size]
]
