"
My purpose is to remember some objects with some names at least for a time you tell me.  Each name has an expiration, when all names expires I'll forget the object.

NOTE: Between time and time you must send #maintenance to me
"
Class {
	#name : #RSTRememberer,
	#superclass : #Object,
	#instVars : [
		'remembered',
		'mutex'
	],
	#category : #'rST-Core'
}

{ #category : #'instance creation' }
RSTRememberer class >> new [
	^ super new initialize
]

{ #category : #accessing }
RSTRememberer >> allNamed: nameObject [ 
	"answer all object named nameObject"
	| named |
	named _ Set new.
	mutex
		critical: [""
			remembered
				keysAndValuesDo: [:object :names | ""
(names keys includes:nameObject)
ifTrue:[named add: object]
]].
	^ named
]

{ #category : #'remembering & forgetting' }
RSTRememberer >> forget: anObject named: nameObject [ 
	"forget anObject"
	mutex
		critical: [| names | 
			names _ remembered
						at: anObject
						ifAbsent: [^ anObject].
			names
				removeKey: nameObject
				ifAbsent: [].
			names isEmpty
				ifTrue: [remembered removeKey: anObject]]
]

{ #category : #'remembering & forgetting' }
RSTRememberer >> forgetAllNamed: nameObject [ 
	"forget anObject"
	| named | 
			named _ self allNamed: nameObject.
			named
				do: [:object | self forget: object named: nameObject]
]

{ #category : #initialization }
RSTRememberer >> initialize [
	remembered _ IdentityDictionary new.
	mutex _ Semaphore forMutualExclusion
]

{ #category : #maintenance }
RSTRememberer >> maintenance [
	"within time and time, check for objects to forget"
	mutex
		critical: [| current toForget | 
			current _ Time totalSeconds.
			remembered _ remembered
						select: [:eachRemembered | 
							""
							eachRemembered
								keysAndValuesRemove: [:name :expires | ""
									expires notNil
										and: [expires <= current]].
							eachRemembered notEmpty]]
]

{ #category : #'remembering & forgetting' }
RSTRememberer >> remember: anObject forSeconds: anInteger naming: nameObject [ 
	"remember anObject at least for anInteger seconds"
	mutex
		critical: [| names expires | 
			names _ remembered
						at: anObject
						ifAbsentPut: [Dictionary new].
			expires _ anInteger isNil
						ifFalse: [Time totalSeconds + anInteger].
			names at: nameObject put: expires]
]

{ #category : #'remembering & forgetting' }
RSTRememberer >> rememberForEver: anObject naming: nameObject [ 
	"remember anObject for ever"
	^ self
		remember: anObject
		forSeconds: nil
		naming: nameObject
]
