"
I describe the behavior of my sole instance, nil. nil represents a prior value for variables that have not been initialized, or for results which are meaningless.
"
Class {
	#name : #UndefinedObject,
	#superclass : #Object,
	#category : #'Kernel-Objects'
}

{ #category : #accessing }
UndefinedObject class >> allInstancesDo: aBlock [
	"It is well known there is a single instance"
	
	aBlock value: nil
]

{ #category : #'instance creation' }
UndefinedObject class >> initializedInstance [
	^ nil
]

{ #category : #'instance creation' }
UndefinedObject class >> new [
	self error: 'You may not create any more undefined objects--use nil'
]

{ #category : #'dependents access' }
UndefinedObject >> addDependent: ignored [ 
	"Refer to the comment in Object|dependents."

	self error: 'Nil should not have dependents'
]

{ #category : #'class hierarchy' }
UndefinedObject >> addSubclass: aClass [
	"Ignored -- necessary to support disjoint class hierarchies"
]

{ #category : #'sets support' }
UndefinedObject >> asSetElement [
	"Since nil is a singleton, we need only a single wrapper instance to represent it in set,
	created in advance"
	^ SetElement withNil
]

{ #category : #'bottom context' }
UndefinedObject >> canHandleSignal: exception [
	"When no more handler (on:do:) context left in sender chain this gets called"

	^ false
]

{ #category : #copying }
UndefinedObject >> deepCopy [
	"Only one instance of UndefinedObject should ever be made, so answer 
	with self."
]

{ #category : #'class hierarchy' }
UndefinedObject >> environment [
	"Necessary to support disjoint class hierarchies."

	^self class environment
]

{ #category : #'3ds parser support' }
UndefinedObject >> from3DS: aDictionary [
	^aDictionary
]

{ #category : #testing }
UndefinedObject >> haltIfNil [
	self halt
]

{ #category : #'bottom context' }
UndefinedObject >> handleSignal: exception [
	"When no more handler (on:do:) context left in sender chain this gets called.  Return from signal with default action."

	^ exception resumeUnchecked: exception defaultAction
]

{ #category : #testing }
UndefinedObject >> ifNil: aBlock [
	"A convenient test, in conjunction with Object ifNil:"

	^ aBlock value
]

{ #category : #testing }
UndefinedObject >> ifNil: nilBlock ifNotNil: ifNotNilBlock [
	"Evaluate the block for nil because I'm == nil"

	^ nilBlock value
]

{ #category : #testing }
UndefinedObject >> ifNil: nilBlock ifNotNilDo: ifNotNilBlock [
	"Evaluate the block for nil because I'm == nil"

	^ nilBlock value
]

{ #category : #testing }
UndefinedObject >> ifNotNil: aBlock [
	"A convenient test, in conjunction with Object ifNotNil:"

	^ self
]

{ #category : #testing }
UndefinedObject >> ifNotNil: ifNotNilBlock ifNil: nilBlock [ 
	"If I got here, I am nil, so evaluate the block nilBlock"

	^ nilBlock value
]

{ #category : #testing }
UndefinedObject >> ifNotNilDo: aBlock [
	"Override to do nothing."

	^ self

]

{ #category : #testing }
UndefinedObject >> ifNotNilDo: ifNotNilBlock ifNil: nilBlock [ 
	"If I got here, I am nil, so evaluate the block nilBlock"

	^ nilBlock value
]

{ #category : #testing }
UndefinedObject >> isEmptyOrNil [
	"Answer whether the receiver contains any elements, or is nil.  Useful in numerous situations where one wishes the same reaction to an empty collection or to nil"
	^ true
]

{ #category : #testing }
UndefinedObject >> isLiteral [
	^ true
]

{ #category : #testing }
UndefinedObject >> isNil [ 
	"Refer to the comment in Object|isNil."

	^true
]

{ #category : #'class hierarchy' }
UndefinedObject >> literalScannedAs: scannedLiteral environment: anEnvironment notifying: requestor [ 
	^ scannedLiteral
]

{ #category : #testing }
UndefinedObject >> notNil [ 
	"Refer to the comment in Object|notNil."

	^false
]

{ #category : #compiling }
UndefinedObject >> parserClass [

	^ Compiler parserClass
]

{ #category : #printing }
UndefinedObject >> printAsLiteralOn: aStream [
	^self printOn: aStream
]

{ #category : #printing }
UndefinedObject >> printOn: aStream [ 
	"Refer to the comment in Object|printOn:." 

	aStream nextPutAll: 'nil'
]

{ #category : #'dependents access' }
UndefinedObject >> release [
	"Nil release is a no-op"
]

{ #category : #'class hierarchy' }
UndefinedObject >> removeObsoleteSubclass: aClass [
	"Ignored -- necessary to support disjoint class hierarchies"
]

{ #category : #'class hierarchy' }
UndefinedObject >> removeSubclass: aClass [
	"Ignored -- necessary to support disjoint class hierarchies"
]

{ #category : #copying }
UndefinedObject >> shallowCopy [
	"Only one instance of UndefinedObject should ever be made, so answer 
	with self."
]

{ #category : #printing }
UndefinedObject >> storeOn: aStream [ 
	"Refer to the comment in Object|storeOn:." 

	aStream nextPutAll: 'nil'
]

{ #category : #'class hierarchy' }
UndefinedObject >> subclass: nameOfClass  
	instanceVariableNames: instVarNames
	classVariableNames: classVarNames
	poolDictionaries: poolDictnames
	category: category [
	"Calling this method is now considered an accident.  If you really want to create a class with a nil superclass, then create the class and then set the superclass using #superclass:"
	Transcript show: ('Attempt to create ', nameOfClass, ' as a subclass of nil.  Possibly a class is being loaded before its superclass.'); cr.
	^ProtoObject
		subclass: nameOfClass
		instanceVariableNames: instVarNames
		classVariableNames: classVarNames
		poolDictionaries: poolDictnames
		category: category

]

{ #category : #'class hierarchy' }
UndefinedObject >> subclassDefinerClass [
	"For disjunct class hierarchies -- how should subclasses of nil be evaluated"
	^Compiler
]

{ #category : #'class hierarchy' }
UndefinedObject >> subclasses [
	"Return all the subclasses of nil"
	| classList |
	classList := WriteStream on: Array new.
	self subclassesDo:[:class| classList nextPut: class].
	^classList contents
]

{ #category : #'class hierarchy' }
UndefinedObject >> subclassesDo: aBlock [
	"Evaluate aBlock with all subclasses of nil."
	^Class subclassesDo:[:cl| 
		cl isMeta ifTrue:[aBlock value: cl soleInstance]].
]

{ #category : #'class hierarchy' }
UndefinedObject >> subclassesDoGently: aBlock [
	"Evaluate aBlock with all subclasses of nil.  Others are not direct subclasses of Class."

	^ Class subclassesDoGently: [:cl | 
			cl isMeta ifTrue: [aBlock value: cl soleInstance]].
]

{ #category : #'class hierarchy' }
UndefinedObject >> typeOfClass [
	"Necessary to support disjoint class hierarchies."
	^#normal
]

{ #category : #copying }
UndefinedObject >> veryDeepCopyWith: deepCopier [
	"Return self.  I can't be copied.  Do not record me."
]