"
A CompilationCue is a helper class holding enough context for evaluating/compiling Smalltalk code.

That is mainly the source code, and the source code editor to interact with if the Compiler is used interactively.
But that is also any additional information necessary to resolve variable names.

When compiling a method, the Compiler typically need to know the target class in which to install the method.

When evaluating an expression, the Compiler also needs a receiver (for accessing the value of its instance variables), its class (for resolving instance/class variable names), and optionnally a context of execution when debugging a method (for accessing values of temporaries and parameters).

Instance Variables
	class:			<Behavior>
	context:		<Context | nil>
	environment:	<Environment | nil>
	receiver:		<Object>
	requestor:		<TextEditor | nil>
	source:			<Stream>

class
	- the target class in which to install the compiled method;
	  this enables to resolve the instance variable names, class variable names and shared pool variable names.
	  When evaluating, this should be the receiver class

context
	- the context introspected when evaluating the code: this is typically for accessing parameters and temporary variables when debugging

environment
	- the environment in which to resolve global variable names

receiver
	- the receiver into which to evaluate the code: this is typically for accessing instance variables in an inspector

requestor
	- typically the text editor containing the source code being compiled/evaluated. This enables the Compiler to interact in case of syntax error.

source
	- a ReadStream on the source code to be compiled

"
Class {
	#name : #CompilationCue,
	#superclass : #Object,
	#instVars : [
		'source',
		'context',
		'receiver',
		'class',
		'environment',
		'requestor'
	],
	#category : #'Compiler-Kernel'
}

{ #category : #'instance creation' }
CompilationCue class >> class: aClass [
	^ self 
		source: nil
		context: nil
		receiver: nil
		class: aClass
		environment: (aClass ifNotNil: [aClass environment])
		requestor: nil
]

{ #category : #'instance creation' }
CompilationCue class >> source: aTextOrStream [
	^ self
		source: aTextOrStream
		class: nil
		requestor: nil
]

{ #category : #'instance creation' }
CompilationCue class >> source: aTextOrStream class: aClass environment: anEnvironment requestor: anObject [
	^ self
		source: aTextOrStream
		context: nil
		receiver: nil
		class: aClass
		environment: anEnvironment
		requestor: anObject
]

{ #category : #'instance creation' }
CompilationCue class >> source: aTextOrStream class: aClass requestor: anObject [
	^ self 
		source: aTextOrStream 
		context: nil 
		receiver: nil
		class: aClass 
		environment: (aClass ifNotNil: [aClass environment])
		requestor: anObject
]

{ #category : #'instance creation' }
CompilationCue class >> source: aTextOrStream context: aContext class: aClass environment: anEnvironment requestor: reqObject [
	^ self basicNew
		initializeWithSource: aTextOrStream 
		context: aContext 
		receiver: (aContext ifNotNil: [aContext receiver]) 
		class: aClass 
		environment: anEnvironment 
		requestor: reqObject
]

{ #category : #'instance creation' }
CompilationCue class >> source: aTextOrStream context: aContext class: aClass requestor: anObject [
	^ self 
		source: aTextOrStream 
		context: aContext 
		receiver: (aContext ifNotNil: [aContext receiver])
		class: aClass 
		environment: (aClass ifNotNil: [aClass environment])
		requestor: anObject
]

{ #category : #'instance creation' }
CompilationCue class >> source: aTextOrStream context: aContext receiver: recObject class: aClass environment: anEnvironment requestor: reqObject [
	^ self basicNew
		initializeWithSource: aTextOrStream 
		context: aContext 
		receiver: recObject 
		class: aClass 
		environment: anEnvironment 
		requestor: reqObject
]

{ #category : #'instance creation' }
CompilationCue class >> source: aString environment: anEnvironment [
	^ self 
		source: aString
		context: nil
		receiver: nil
		class: UndefinedObject
		environment: anEnvironment
		requestor: nil
]

{ #category : #'instance creation' }
CompilationCue class >> source: aString environment: anEnvironment requestor: aRequestor [
	^ self 
		source: aString
		context: nil
		receiver: nil
		class: UndefinedObject
		environment: anEnvironment
		requestor: aRequestor
]

{ #category : #binding }
CompilationCue >> bindingOf: aSymbol [
	^ class bindingOf: aSymbol environment: environment
]

{ #category : #accessing }
CompilationCue >> context [
	^ context
]

{ #category : #accessing }
CompilationCue >> environment [
	^ environment
]

{ #category : #accessing }
CompilationCue >> getClass [
	^ class
]

{ #category : #initialization }
CompilationCue >> initializeWithSource: aTextOrString context: aContext receiver: recObject class: aClass environment: anEnvironment requestor: reqObject [
	self initialize.
	source := (aTextOrString isKindOf: PositionableStream)
		ifTrue: [ aTextOrString ]
		ifFalse: [ ReadStream on: aTextOrString asString ].
	context := aContext.
	receiver := recObject.
	class := aClass.
	environment := anEnvironment.
	requestor := reqObject
]

{ #category : #accessing }
CompilationCue >> receiver [
	^ receiver
]

{ #category : #accessing }
CompilationCue >> requestor [
	^ requestor
]

{ #category : #accessing }
CompilationCue >> sourceStream [
	^source
]

{ #category : #accessing }
CompilationCue >> sourceStream: x [
source := x
]

{ #category : #accessing }
CompilationCue >> stringToLog [
	"Answer a string to be logged in a change log.
	Implementation note:
	If the requestor is a TextEditor, preferably take its selection.
	This convoluted code is presumably crafted to avoid broken contents
	(ReadStream on: '123456' from: 3 to: 4) contents -> '1234'
	As long as selectionAsStream is using such construct this might be required."
	| itsSelection itsSelectionString |
	^((requestor respondsTo: #selection)  
			and:[(itsSelection := requestor selection) notNil
			and:[(itsSelectionString := itsSelection asString) isEmptyOrNil not]])
				ifTrue:[itsSelectionString]
				ifFalse:[self sourceStream contents]
]
