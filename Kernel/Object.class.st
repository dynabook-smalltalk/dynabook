"
Object is the root class for almost all of the other classes in the class hierarchy. The exceptions are ProtoObject (the superclass of Object) and its subclasses.

Class Object provides default behavior common to all normal objects, such as access, copying, comparison, error handling, message sending, and reflection. Also utility messages that all objects should respond to are defined here.

Object has no instance variables, nor should any be added. This is due to several classes of objects that inherit from Object that have special implementations (SmallInteger and UndefinedObject for example) or the VM knows about and depends on the structure and layout of certain standard classes.

Class Variables:
	DependentsFields		an IdentityDictionary
		Provides a virtual 'dependents' field so that any object may have one
		or more dependent views, synchronized by the changed:/update: protocol.
		Note that class Model has a real slot for its dependents, and overrides
		the associated protocol with more efficient implementations.
	EventsFields			an IdentityDictionary that maps each object to its dependents.
		Registers a message send (consisting of a selector and a receiver object)
		which should be performed when anEventSymbol is triggered by the receiver.
		Part of a new event notification framework which could eventually replace
		the existing changed/update mechanism.  It is intended to be compatible
		with Dolphin Smalltalk and VSE as much as possible.

Because Object is the root of the inheritance tree, methods are often defined in Object to give all objects special behaviors needed by certain subsystems or applications, or to respond to certain general test messages such as isMorph.
"
Class {
	#name : #Object,
	#superclass : #ProtoObject,
	#traits : 'UniversalMethods',
	#classTraits : 'UniversalMethods classTrait',
	#classVars : [
		'DependentsFields'
	],
	#category : #'Kernel-Objects'
}

{ #category : #'instance creation' }
Object class >> basicReadFrom: textStringOrStream [
	"Create an object based on the contents of textStringOrStream."

	| object |
	(Compiler couldEvaluate: textStringOrStream)
		ifFalse: [^ self error: 'expected String, Stream, or Text' translated].
	object := self environment beCurrentDuring: [
		Compiler evaluate: textStringOrStream environment: self environment].
	(object isKindOf: self) ifFalse: [self error: ('{1} expected' translated format: {self name})].
	^object
]

{ #category : #'instance creation' }
Object class >> categoryForUniclasses [
	"Answer the default system category into which to place unique-class instances"

	^ 'UserObjects'
]

{ #category : #'instance creation' }
Object class >> chooseUniqueClassName [
	| i className |
	i := 1.
	[className := (self name , i printString) asSymbol.
	 Smalltalk includesKey: className]
		whileTrue: [i := i + 1].
	^ className
]

{ #category : #'objects from disk' }
Object class >> createFrom: aSmartRefStream size: varsOnDisk version: instVarList [
	"Create an instance of me so objects on the disk can be read in.  Tricky part is computing the size if variable.  Inst vars will be filled in later.  "

	^ self isVariable
		ifFalse: [self basicNew]
		ifTrue: ["instVarList is names of old class's inst vars plus a version number" 
				self basicNew: (varsOnDisk - (instVarList size - 1))]

]

{ #category : #'file list services' }
Object class >> fileReaderServicesForDirectory: aFileDirectory [
	"Backstop"
	^#()
]

{ #category : #'file list services' }
Object class >> fileReaderServicesForFile: fullName suffix: suffix [
	"Backstop"
	^#()
]

{ #category : #'class initialization' }
Object class >> flushDependents [
	DependentsFields keysAndValuesDo:[:key :dep|
		key ifNotNil:[key removeDependent: nil].
	].
	DependentsFields finalizeValues.
]

{ #category : #documentation }
Object class >> howToModifyPrimitives [
	"You are allowed to write methods which specify primitives, but please use 
	caution.  If you make a subclass of a class which contains a primitive method, 
	the subclass inherits the primitive.  The message which is implemented 
	primitively may be overridden in the subclass (E.g., see at:put: in String's 
	subclass Symbol).  The primitive behavior can be invoked using super (see 
	Symbol string:). 
	 
	A class which attempts to mimic the behavior of another class without being 
	its subclass may or may not be able to use the primitives of the original class.  
	In general, if the instance variables read or written by a primitive have the 
	same meanings and are in the same fields in both classes, the primitive will 
	work.  

	For certain frequently used 'special selectors', the compiler emits a 
	send-special-selector bytecode instead of a send-message bytecode. Special 
	selectors were created because they offer two advantages.  First, code which
	sends special selectors compiles into fewer bytes than normal. Second, for
	some pairs of receiver classes and special selectors, the interpreter jumps
	directly to a primitive routine without looking up the method in the class,
	and the just-in-time (JIT) compiler (if in use) may emit code to directly execute
	the primitive.  At least in the interpeeter this is much faster than a normal
	message lookup. In both the interpreter and the JIT send-special-selector,
	conditional branch pairs are short-circuited for the comparison selectors.
	 
	A selector which is a special selector solely in order to save space has a 
	normal behavior.  Methods whose selectors are special in order to 
	gain speed contain the comment, 'No Lookup'.  When the interpreter 
	encounters a send-special-selector bytecode, it checks the class of the 
	receiver and the selector.  If the class-selector pair is a no-lookup pair, 
	then the interpreter swiftly jumps to the routine which implements the 
	corresponding primitive.  (A special selector whose receiver is not of the 
	right class to make a no-lookup pair, is looked up normally).  The pairs are 
	listed below.  No-lookup methods contain a primitive number specification, 
	<primitive: xx>, which is redundant.  Since the method is not normally looked 
	up, deleting the primitive number specification cannot prevent this 
	primitive from running.  If a no-lookup primitive fails, the method is looked 
	up normally, and the expressions in it are executed. 
	 
	No Lookup pairs of (class, selector) 

	SmallInteger and Float with any of	+ - * /
	SmallInteger with any of			\\  bitOr: bitShift: bitAnd:  // @
	SmallInteger and Float with any of	=  ~=  >  <  >=  <= 
	Any class with						== ~~ class
	Point with either of					x y				(interpreter only)
	BlockClosure with either of 			value value:	(interpreter only)
	"

	self error: 'comment only'
]

{ #category : #'instance creation' }
Object class >> initialInstance [
	"Answer the first instance of the receiver, generate an error if there is one already"
	"self instanceCount > 0 ifTrue: [self error: 'instance(s) already exist.']."
		"Debugging test that is very slow"
	^ self new
]

{ #category : #'class initialization' }
Object class >> initialize [
	"Object initialize"
	DependentsFields ifNil:[self initializeDependentsFields].
]

{ #category : #'class initialization' }
Object class >> initializeDependentsFields [
	"Object initialize"
	DependentsFields := WeakIdentityKeyDictionary new.

]

{ #category : #'instance creation' }
Object class >> initializedInstance [
	self isAbstract ifTrue: [^nil].
	^ self new
]

{ #category : #'instance creation' }
Object class >> instanceOfUniqueClass [
	"Answer an instance of a unique subclass of the receiver"

	^ self instanceOfUniqueClassWithInstVarString: '' andClassInstVarString: ''
]

{ #category : #'instance creation' }
Object class >> instanceOfUniqueClassWithInstVarString: instVarString andClassInstVarString: classInstVarString [
	"Create a unique class for the receiver, and answer an instance of it"

	^ (self newUniqueClassInstVars: instVarString 
		classInstVars: classInstVarString) initialInstance
]

{ #category : #'instance creation' }
Object class >> isUniClass [
	^ false
]

{ #category : #'instance creation' }
Object class >> newFrom: aSimilarObject [
	"Create an object that has similar contents to aSimilarObject.
	If the classes have any instance varaibles with the same names, copy them across.
	If this is bad for a class, override this method."

	^ (self isVariable
		ifTrue: [self basicNew: aSimilarObject basicSize]
		ifFalse: [self basicNew]
	  ) copySameFrom: aSimilarObject
]

{ #category : #'instance creation' }
Object class >> newUniqueClassInstVars: instVarString classInstVars: classInstVarString [
	"Create a unique class for the receiver"

	| aName aClass |
	self isSystemDefined ifFalse:
		[^ superclass newUniqueClassInstVars: instVarString classInstVars: classInstVarString].
	aName := self chooseUniqueClassName.
	aClass := self subclass: aName instanceVariableNames: instVarString 
		classVariableNames: '' poolDictionaries: '' category: self categoryForUniclasses.
	classInstVarString size > 0 ifTrue:
		[aClass class instanceVariableNames: classInstVarString].
	
	self flag: #todo. self flag: #uniclasses. "Discuss if we really want to hide uniclasses again"
	aClass environment: aClass newEnvironment.
	aClass environment organization
		classify: aClass name
		under: (self environment organization categoryOfElement: aClass name).
	self environment forgetClass: aClass logged: false.
	self removeSubclass: aClass.
		
	^ aClass
]

{ #category : #'instance creation' }
Object class >> newUserInstance [
	"Answer an instance of an appropriate class to serve as a user object in the containment hierarchy"

	^ self instanceOfUniqueClass
]

{ #category : #documentation }
Object class >> postRecompileAction [
	"This is a stub method to document the convention for reinitializing state at the end of Compiler recompileAll.
	 The issue is that after recompiling all methods, processes or blocks could remain that refer to old methods,
	 and that somehow those processes should be restarted and objects referring to blocks rebuilt.  For example,
	 PluggableDictionary integerDictionary creates a PluggableDictionary with a hashBlock that refers to the
	 PluggableDictionary class>>#integerDictionary method.  Users of PluggableDictionary integerDictionary can
	 rebuild structures containing it after recompile by implementing thsi method to do so.  Compiler will then
	 invoke any and all such methods after recompileAll."

	^self
]

{ #category : #'class initialization' }
Object class >> reInitializeDependentsFields [
	"Object reInitializeDependentsFields"
	| oldFields |
	oldFields := DependentsFields.
	DependentsFields := WeakIdentityKeyDictionary new.
	oldFields keysAndValuesDo:[:obj :deps|
		deps do:[:d| obj addDependent: d]].

]

{ #category : #'instance creation' }
Object class >> readCarefullyFrom: textStringOrStream [
	"Create an object based on the contents of textStringOrStream.  Return an error instead of putting up a SyntaxError window."

	^ [self basicReadFrom: textStringOrStream]
		on: SyntaxErrorNotification
		do: [:ex | self error: ex messageText]
]

{ #category : #'instance creation' }
Object class >> readFrom: textStringOrStream [
	"Create an object based on the contents of textStringOrStream."

	^ self basicReadFrom: textStringOrStream
]

{ #category : #private }
Object class >> releaseExternalSettings [
	"Do nothing as a default"
]

{ #category : #'file list services' }
Object class >> services [
	"Backstop"
	^#()
]

{ #category : #documentation }
Object class >> whatIsAPrimitive [
	"Some messages in the system are responded to primitively. A primitive   
	response is performed directly by the interpreter rather than by evaluating   
	expressions in a method. The methods for these messages indicate the   
	presence of a primitive response by including <primitive: xx> before the   
	first expression in the method.   
	  
	Primitives exist for several reasons. Certain basic or 'primitive' 
	operations cannot be performed in any other way. Smalltalk without 
	primitives can move values from one variable to another, but cannot add two 
	SmallIntegers together. Many methods for arithmetic and comparison 
	between numbers are primitives. Some primitives allow Smalltalk to 
	communicate with I/O devices such as the disk, the display, and the keyboard. 
	Some primitives exist only to make the system run faster; each does the same 
	thing as a certain Smalltalk method, and its implementation as a primitive is 
	optional.  
	  
	When the Smalltalk interpreter begins to execute a method which specifies a 
	primitive response, it tries to perform the primitive action and to return a 
	result. If the routine in the interpreter for this primitive is successful, 
	it will return a value and the expressions in the method will not be evaluated. 
	If the primitive routine is not successful, the primitive 'fails', and the 
	Smalltalk expressions in the method are executed instead. These 
	expressions are evaluated as though the primitive routine had not been 
	called.  
	  
	The Smalltalk code that is evaluated when a primitive fails usually 
	anticipates why that primitive might fail. If the primitive is optional, the 
	expressions in the method do exactly what the primitive would have done (See 
	Number @). If the primitive only works on certain classes of arguments, the 
	Smalltalk code tries to coerce the argument or appeals to a superclass to find 
	a more general way of doing the operation (see SmallInteger +). If the 
	primitive is never supposed to fail, the expressions signal an error (see 
	SmallInteger asFloat).  
	  
	Each method that specifies a primitive has a comment in it. If the primitive is 
	optional, the comment will say 'Optional'. An optional primitive that is not 
	implemented always fails, and the Smalltalk expressions do the work 
	instead.  
	 
	If a primitive is not optional, the comment will say, 'Essential'. Some 
	methods will have the comment, 'No Lookup'. See Object 
	howToModifyPrimitives for an explanation of special selectors which are 
	not looked up.  
	  
	For the primitives for +, -, *, and bitShift: in SmallInteger, and truncated 
	in Float, the primitive constructs and returns a 16-bit 
	LargePositiveInteger when the result warrants it. Returning 16-bit 
	LargePositiveIntegers from these primitives instead of failing is 
	optional in the same sense that the LargePositiveInteger arithmetic 
	primitives are optional. The comments in the SmallInteger primitives say, 
	'Fails if result is not a SmallInteger', even though the implementor has the 
	option to construct a LargePositiveInteger. For further information on 
	primitives, see the 'Primitive Methods' part of the chapter on the formal 
	specification of the interpreter in the Smalltalk book."

	self error: 'comment only'
]

{ #category : #associating }
Object >> -> anObject [
	"Answer an Association between self and anObject"

	^Association basicNew key: self value: anObject
]

{ #category : #comparing }
Object >> = anObject [ 
	"Answer whether the receiver and the argument represent the same 
	object. If = is redefined in any subclass, consider also redefining the 
	message hash."

	^self == anObject
]

{ #category : #'drag and drop' }
Object >> acceptDroppingMorph: transferMorph event: evt inMorph: dstListMorph [ 
	
	^false.
]

{ #category : #finalization }
Object >> actAsExecutor [
	"Prepare the receiver to act as executor for any resources associated with it"
	self breakDependents
]

{ #category : #converting }
Object >> adaptToFloat: rcvr andCompare: selector [ 
	"If I am involved in comparison with a Float.
	Default behaviour is to process comparison as any other selectors."
	^ self adaptToFloat: rcvr andSend: selector
]

{ #category : #converting }
Object >> adaptToFloat: rcvr andSend: selector [
	"If no method has been provided for adapting an object to a Float,
	then it may be adequate to simply adapt it to a number."
	^ self adaptToNumber: rcvr andSend: selector
]

{ #category : #converting }
Object >> adaptToFraction: rcvr andCompare: selector [ 
	"If I am involved in comparison with a Fraction.
	Default behaviour is to process comparison as any other selectors."
	^ self adaptToFraction: rcvr andSend: selector
]

{ #category : #converting }
Object >> adaptToFraction: rcvr andSend: selector [
	"If no method has been provided for adapting an object to a Fraction,
	then it may be adequate to simply adapt it to a number."
	^ self adaptToNumber: rcvr andSend: selector
]

{ #category : #converting }
Object >> adaptToInteger: rcvr andCompare: selector [ 
	"If I am involved in comparison with an Integer.
	Default behaviour is to process comparison as any other selectors."
	^ self adaptToInteger: rcvr andSend: selector
]

{ #category : #converting }
Object >> adaptToInteger: rcvr andSend: selector [
	"If no method has been provided for adapting an object to a Integer,
	then it may be adequate to simply adapt it to a number."
	^ self adaptToNumber: rcvr andSend: selector
]

{ #category : #converting }
Object >> adaptToScaledDecimal: rcvr andCompare: selector [ 
	"If I am involved in comparison with a ScaledDecimal.
	Default behaviour is to process comparison as any other selectors."
	^ self adaptToScaledDecimal: rcvr andSend: selector
]

{ #category : #scripting }
Object >> adaptedToWorld: aWorld [
	"If I refer to a world or a hand, return the corresponding items in the new world."
	^self
]

{ #category : #'dependents access' }
Object >> addDependent: anObject [
	"Make the given object one of the receiver's dependents."

	| dependents |
	dependents := self dependents.
	(dependents includes: anObject) ifFalse:
		[self myDependents: (dependents copyWithDependent: anObject)].
	^ anObject
]

{ #category : #accessing }
Object >> addInstanceVarNamed: aName withValue: aValue [
	"Add an instance variable named aName and give it value aValue"
	self class addInstVarName: aName asString.
	self instVarAt: self class instSize put: aValue
]

{ #category : #'user interface' }
Object >> addModelItemsToWindowMenu: aMenu [
	"aMenu is being constructed to be presented to the user in response to the user's pressing on the menu widget in the title bar of a morphic window.  Here, the model is given the opportunity to add any model-specific items to the menu, whose default target is the SystemWindow itself."
]

{ #category : #'user interface' }
Object >> addModelMenuItemsTo: aCustomMenu forMorph: aMorph hand: aHandMorph [ 
	"The receiver serves as the model for aMorph; a menu is being constructed for the morph, and here the receiver is able to add its own items"

]

{ #category : #'graph model' }
Object >> addModelYellowButtonMenuItemsTo: aCustomMenu forMorph: aMorph hand: aHandMorph [ 
	"The receiver serves as the model for aMorph; a menu is being constructed for the morph, and here the receiver is able to add its own items"
	
	aCustomMenu add: 'inspect model' translated target: self action: #inspect.
	^aCustomMenu

]

{ #category : #literals }
Object >> allLiteralsDo: aBlock [

	self flag: #discuss. "mt: Better implement this only on Symbol, Array, Number, Binding, etc. instead of Object?"
	aBlock value: self.
]

{ #category : #converting }
Object >> as: aSimilarClass [
	"Create an object of class aSimilarClass that has similar contents to the receiver."

	^ aSimilarClass newFrom: self
]

{ #category : #converting }
Object >> asDraggableMorph [
	"Converts the receiver into a Morph suitable for dragging"
	^(StringMorph contents: (
			(self respondsTo: #dragLabel) 
				ifTrue:[self dragLabel] 
				ifFalse:[self printString]))
		color: ((self userInterfaceTheme get: #textColor for: #TransferMorph) ifNil: [Color black]);
		font: ((self userInterfaceTheme get: #font for: #TransferMorph) ifNil: [TextStyle defaultFont])
		yourself
]

{ #category : #'user interface' }
Object >> asExplorerString [
	^ self printString
]

{ #category : #'system primitives' }
Object >> asOop [
	"This method is for compatibility only.
	In Smalltalk, this used to return an integer unique to each object.
	In Squeak, OOPs are internal to the VM.  Accessing an OOP would be useless anyway since it changes when the object is moved during garbage collection."

	^self identityHash
]

{ #category : #converting }
Object >> asOrderedCollection [
	"Answer an OrderedCollection with the receiver as its only element."

	^ OrderedCollection with: self
]

{ #category : #converting }
Object >> asSetElement [
	"Answer an object, which can be put into a Set as element , wrapped
	by one of SetElement instance, if necessary. 
	Default implementation is to answer self"

]

{ #category : #converting }
Object >> asString [
	"Answer a string that represents the receiver."

	^ self printString 
]

{ #category : #converting }
Object >> asStringOrText [
	"Answer a string that represents the receiver."
	^ self asString
]

{ #category : #'error handling' }
Object >> assert: aBlock [
	"Throw an assertion error if aBlock does not evaluates to true."

	aBlock value ifFalse: [AssertionFailure signal: 'Assertion failed']
]

{ #category : #'error handling' }
Object >> assert: aBlock description: aStringOrBlock [
	"Throw an assertion error if aBlock does not evaluates to true."

	aBlock value ifFalse: [ AssertionFailure signal: aStringOrBlock value ]
]

{ #category : #'error handling' }
Object >> assert: aBlock descriptionBlock: descriptionBlock [
	"Throw an assertion error if aBlock does not evaluate to true."

	aBlock value ifFalse: [AssertionFailure signal: descriptionBlock value asString ]
]

{ #category : #viewer }
Object >> assureUniClass [
	"If the receiver is not yet an instance of a uniclass, create a uniclass for it and make the receiver become an instance of that class."

	| anInstance |
	self belongsToUniClass ifTrue: [^ self].
	anInstance := self class instanceOfUniqueClass.
	self becomeForward: (self as: anInstance class).
	^ anInstance
]

{ #category : #accessing }
Object >> at: index [ 
	"Primitive. Assumes receiver is indexable. Answer the value of an 
	indexable element in the receiver. Fail if the argument index is not an 
	Integer or is out of bounds. Essential. See Object documentation 
	whatIsAPrimitive."

	<primitive: 60>
	index isInteger ifTrue:
		[self class isVariable
			ifTrue: [self errorSubscriptBounds: index]
			ifFalse: [self errorNotIndexable]].
	index isNumber
		ifTrue: [^self at: index asInteger]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
Object >> at: index modify: aBlock [
	"Replace the element of the collection with itself transformed by the block"
	^ self at: index put: (aBlock value: (self at: index))
]

{ #category : #accessing }
Object >> at: index put: value [ 
	"Primitive. Assumes receiver is indexable. Store the argument value in 
	the indexable element of the receiver indicated by index. Fail if the 
	index is not an Integer or is out of bounds. Or fail if the value is not of 
	the right type for this kind of collection. Answer the value that was 
	stored. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 61>
	index isInteger ifTrue:
		[self class isVariable
			ifTrue: [(index >= 1 and: [index <= self size])
					ifTrue: [self errorImproperStore]
					ifFalse: [self errorSubscriptBounds: index]]
			ifFalse: [self errorNotIndexable]].
	index isNumber
		ifTrue: [^self at: index asInteger put: value]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #'error handling' }
Object >> backwardCompatibilityOnly: explanationString [
	"Warn that the sending method has been deprecated. Methods that are tagt with #backwardCompatibility:
	 are kept for compatibility."

	Deprecation
		signalForContext: thisContext sender
		message: ' (but will be kept for compatibility)'
		explanation: explanationString
]

{ #category : #accessing }
Object >> basicAt: index [ 
	"Primitive. Assumes receiver is indexable. Answer the value of an 
	indexable element in the receiver. Fail if the argument index is not an 
	Integer or is out of bounds. Essential. Do not override in a subclass. See 
	Object documentation whatIsAPrimitive."

	<primitive: 60>
	index isInteger ifTrue: [self errorSubscriptBounds: index].
	index isNumber
		ifTrue: [^self basicAt: index asInteger]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
Object >> basicAt: index put: value [ 
	"Primitive. Assumes receiver is indexable. Store the second argument 
	value in the indexable element of the receiver indicated by index. Fail 
	if the index is not an Integer or is out of bounds. Or fail if the value is 
	not of the right type for this kind of collection. Answer the value that 
	was stored. Essential. Do not override in a subclass. See Object 
	documentation whatIsAPrimitive."

	<primitive: 61>
	index isInteger
		ifTrue: [(index >= 1 and: [index <= self size])
					ifTrue: [self errorImproperStore]
					ifFalse: [self errorSubscriptBounds: index]].
	index isNumber
		ifTrue: [^self basicAt: index asInteger put: value]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #'user interface' }
Object >> basicInspect [
	"Create and schedule an Inspector in which the user can examine the 
	receiver's variables. This method should not be overriden."
	ToolSet basicInspect: self
]

{ #category : #accessing }
Object >> basicSize [
	"Primitive. Answer the number of indexable variables in the receiver. 
	This value is the same as the largest legal subscript. Essential. Do not 
	override in any subclass. See Object documentation whatIsAPrimitive."

	<primitive: 62>
	"The number of indexable fields of fixed-length objects is 0"
	^0	
]

{ #category : #testing }
Object >> basicType [
	"Answer a symbol representing the inherent type of the receiver"

	^ #Object
]

{ #category : #testing }
Object >> beViewed [
	"Open up a viewer on the receiver.  The Presenter is invited to decide just how to present this viewer"

	self uniqueNameForReference.  "So the viewer will have something nice to refer to"
	self presenter viewObject: self
]

{ #category : #viewer }
Object >> belongsToUniClass [
	"Answer whether the receiver belongs to a uniclass.  For the moment (this is not entirely satisfactory) this is precisely equated with the classname ending in a digit"

	^ self class isUniClass
]

{ #category : #accessing }
Object >> bindWithTemp: aBlock [
	^ aBlock value: self value: nil
]

{ #category : #binding }
Object >> bindingOf: aString [
	^nil
]

{ #category : #'dependents access' }
Object >> breakDependents [
	"Remove all of the receiver's dependents."

	self myDependents: nil
]

{ #category : #'user interface' }
Object >> browseHierarchy [
	self systemNavigation browseHierarchy: self class
]

{ #category : #viewer }
Object >> browseOwnClassSubProtocol [
	"Open up a ProtocolBrowser on the subprotocol of the receiver"

	ProtocolBrowser openSubProtocolForClass: self class

]

{ #category : #'filter streaming' }
Object >> byteEncode:aStream [
	self flattenOnStream:aStream.

]

{ #category : #'dependents access' }
Object >> canDiscardEdits [
	"Answer true if none of the views on this model has unaccepted edits that matter."

	self dependents
		do: [:each | each canDiscardEdits ifFalse: [^ false]]
		without: self.
	^ true
]

{ #category : #undo }
Object >> capturedState [
	"May be overridden in subclasses."

	^ self shallowCopy

]

{ #category : #'error handling' }
Object >> caseError [
	"Report an error from an in-line or explicit case statement."

	self error: 'Case not found (', self printString, '), and no otherwise clause'
]

{ #category : #casing }
Object >> caseOf: aBlockAssociationCollection [
	"The elements of aBlockAssociationCollection are associations between blocks.
	 Answer the evaluated value of the first association in aBlockAssociationCollection
	 whose evaluated key equals the receiver.  If no match is found, report an error."

	^ self caseOf: aBlockAssociationCollection otherwise: [self caseError]

"| z | z := {[#a]->[1+1]. ['b' asSymbol]->[2+2]. [#c]->[3+3]}. #b caseOf: z"
"| z | z := {[#a]->[1+1]. ['d' asSymbol]->[2+2]. [#c]->[3+3]}. #b caseOf: z"
"The following are compiled in-line:"
"#b caseOf: {[#a]->[1+1]. ['b' asSymbol]->[2+2]. [#c]->[3+3]}"
"#b caseOf: {[#a]->[1+1]. ['d' asSymbol]->[2+2]. [#c]->[3+3]}"
]

{ #category : #casing }
Object >> caseOf: aBlockAssociationCollection otherwise: aBlock [
	"The elements of aBlockAssociationCollection are associations between blocks.
	 Answer the evaluated value of the first association in aBlockAssociationCollection
	 whose evaluated key equals the receiver.  If no match is found, answer the result
	 of evaluating aBlock."

	aBlockAssociationCollection associationsDo:
		[:assoc | (assoc key value = self) ifTrue: [^assoc value value]].
	^ aBlock value

"| z | z := {[#a]->[1+1]. ['b' asSymbol]->[2+2]. [#c]->[3+3]}. #b caseOf: z otherwise: [0]"
"| z | z := {[#a]->[1+1]. ['d' asSymbol]->[2+2]. [#c]->[3+3]}. #b caseOf: z otherwise: [0]"
"The following are compiled in-line:"
"#b caseOf: {[#a]->[1+1]. ['b' asSymbol]->[2+2]. [#c]->[3+3]} otherwise: [0]"
"#b caseOf: {[#a]->[1+1]. ['d' asSymbol]->[2+2]. [#c]->[3+3]} otherwise: [0]"
]

{ #category : #viewer }
Object >> categoriesForViewer: aViewer [
	"Answer a list of categories to offer in the given viewer"

	| aList instItem |
	aList := aViewer currentVocabulary categoryListForInstance: self ofClass: self class limitClass: aViewer limitClass.
	self isPlayerLike ifTrue:
		[self costume isWorldMorph ifFalse:
			[aList removeAllFoundIn: #(preferences display)].
		^ aList].
	instItem := ScriptingSystem nameForInstanceVariablesCategory.
	^ (aList includes: instItem)
		ifTrue:
			[aList]
		ifFalse:
			[ {instItem }, aList]
]

{ #category : #viewer }
Object >> categoriesForVocabulary: aVocabulary limitClass: aLimitClass [
	"Answer a list of categories of methods for the receiver when using the given vocabulary, given that one considers only methods that are implemented not further away than aLimitClass"

	^ aVocabulary categoryListForInstance: self ofClass: self class limitClass: aLimitClass
]

{ #category : #converting }
Object >> changeClassTo: aBehavior [
	"Change the class of the receiver to the argument, provided
	 that the format of the argument matches the format of the receiver's class."
	aBehavior adoptInstance: self.
	^self
]

{ #category : #updating }
Object >> changed [
	"Receiver changed in a general way; inform all the dependents by 
	sending each dependent an update: message."

	self changed: self
]

{ #category : #updating }
Object >> changed: aParameter [ 
	"Receiver changed. The change is denoted by the argument aParameter. 
	Usually the argument is a Symbol that is part of the dependent's change 
	protocol. Inform all of the dependents."

	self dependents do: [:aDependent | aDependent update: aParameter]
]

{ #category : #updating }
Object >> changed: anAspect with: anObject [
	"Receiver changed. The change is denoted by the argument anAspect. 
	Usually the argument is a Symbol that is part of the dependent's change 
	protocol. Inform all of the dependents. Also pass anObject for additional information."

	self dependents do: [:aDependent | aDependent update: anAspect with: anObject]
]

{ #category : #'debugging-haltOnce' }
Object >> checkHaltCountExpired [
	| counter |
	counter := Smalltalk at: #HaltCount ifAbsent: [0].
	^counter = 0
]

{ #category : #viewer }
Object >> chooseNewNameForReference [
	"Offer an opportunity for the receiver, presumed already to be known in the References registry, to be renamed"

	|  nameSym current newName |
	current := References keyAtValue: self ifAbsent: [^ self error: 'not found in References'].

	newName := UIManager default request: 'Please enter new name' initialAnswer: current.
	"Want to user some better way of determining the validity of the chosen identifier, and also want to give more precise diagnostic if the string the user types in is not acceptable.  Work to be done here."

	newName isEmpty ifTrue: [^ nil].
	((Scanner isLiteralSymbol: newName) and: [(newName includes: $:) not])
		ifTrue:
			[nameSym := newName capitalized asSymbol.
			(((References includesKey:  nameSym) not and:
				[(Smalltalk includesKey: nameSym) not]) and:
						[(ScriptingSystem allKnownClassVariableNames includes: nameSym) not])
					ifTrue:
						[(References associationAt: current) key: nameSym.
						References rehash.
						^ nameSym]].
	self inform: 'Sorry, that name is not available.'.
	^ nil
]

{ #category : #'class membership' }
Object >> class [
	"Primitive. Answer the object which is the receiver's class. Essential. See 
	Object documentation whatIsAPrimitive."

	<primitive: 111>
	self primitiveFailed
]

{ #category : #'system primitives' }
Object >> className [
	"Answer a string characterizing the receiver's class, for use in list views for example"

	^ self class name asString
]

{ #category : #'debugging-haltOnce' }
Object >> clearHaltOnce [
	"Turn on the halt once flag."
	Smalltalk at: #HaltOnce put: false
]

{ #category : #copying }
Object >> clone [
	"Answer a shallow copy of the receiver."

	self deprecated: 'Use #shallowCopy'.
	^self shallowCopy
]

{ #category : #comparing }
Object >> closeTo: anObject [
	"Answer whether the receiver and the argument represent the same
	object. If = is redefined in any subclass, consider also redefining the
	message hash."

	^[self = anObject] ifError: [false]
]

{ #category : #macpal }
Object >> codeStrippedOut: messageString [
	"When a method is stripped out for external release, it is replaced by a method that calls this"

	self halt: 'Code stripped out -- ', messageString, '-- do not proceed.'
]

{ #category : #'objects from disk' }
Object >> comeFullyUpOnReload: smartRefStream [
	"Normally this read-in object is exactly what we want to store. 7/26/96 tk"

	^ self
]

{ #category : #undo }
Object >> commandHistory [
	"Return the command history for the receiver"
	| w |
	(w := self currentWorld) ifNotNil: [^ w commandHistory].
	^ CommandHistory new. "won't really record anything but prevent breaking things"
]

{ #category : #converting }
Object >> complexContents [

	^self
]

{ #category : #'error handling' }
Object >> confirm: queryString [
	"Put up a yes/no menu with caption queryString. Answer true if the 
	response is yes, false if no. This is a modal question--the user must 
	respond yes or no."

	"nil confirm: 'Are you hungry?'"

	^ UIManager default confirm: queryString
]

{ #category : #'error handling' }
Object >> confirm: aString orCancel: cancelBlock [
	"Put up a yes/no/cancel menu with caption aString. Answer true if  
	the response is yes, false if no. If cancel is chosen, evaluate  
	cancelBlock. This is a modal question--the user must respond yes or no."

	^ UIManager default confirm: aString orCancel: cancelBlock
]

{ #category : #macpal }
Object >> contentsChanged [
	self changed: #contents
]

{ #category : #'objects from disk' }
Object >> convertToCurrentVersion: varDict refStream: smartRefStrm [

	"subclasses should implement if they wish to convert old instances to modern ones"
]

{ #category : #copying }
Object >> copy [
	"Answer another instance just like the receiver. Subclasses typically override postCopy; they typically do not override shallowCopy."

	^self shallowCopy postCopy
]

{ #category : #copying }
Object >> copyAddedStateFrom: anotherObject [
	"Copy over the values of instance variables added by the receiver's class from anotherObject to the receiver.  These will be remapped in mapUniClasses, if needed."

	self class superclass instSize + 1 to: self class instSize do:
		[:index | self instVarAt: index put: (anotherObject instVarAt: index)]
]

{ #category : #copying }
Object >> copyFrom: anotherObject [
	"Copy to myself all instance variables I have in common with anotherObject.  This is dangerous because it ignores an object's control over its own inst vars.  "

	| mine his |
	<primitive: 168>
	mine := self class allInstVarNames.
	his := anotherObject class allInstVarNames.
	1 to: (mine size min: his size) do: [:ind |
		(mine at: ind) = (his at: ind) ifTrue: [
			self instVarAt: ind put: (anotherObject instVarAt: ind)]].
	self class isVariable & anotherObject class isVariable ifTrue: [
		1 to: (self basicSize min: anotherObject basicSize) do: [:ind |
			self basicAt: ind put: (anotherObject basicAt: ind)]].
]

{ #category : #copying }
Object >> copySameFrom: otherObject [
	"Copy to myself all instance variables named the same in otherObject.
	This ignores otherObject's control over its own inst vars."

	| myInstVars otherInstVars |
	myInstVars := self class allInstVarNames.
	otherInstVars := otherObject class allInstVarNames.
	myInstVars doWithIndex: [:each :index |
		| match |
		(match := otherInstVars indexOf: each) > 0 ifTrue:
			[self instVarAt: index put: (otherObject instVarAt: match)]].
	1 to: (self basicSize min: otherObject basicSize) do: [:i |
		self basicAt: i put: (otherObject basicAt: i)].

]

{ #category : #copying }
Object >> copyTwoLevel [
	"one more level than a shallowCopy"

	| newObject class index |
	class := self class.
	newObject := self shallowCopy.
	newObject == self ifTrue: [^ self].
	class isVariable
		ifTrue: 
			[index := self basicSize.
			[index > 0]
				whileTrue: 
					[newObject basicAt: index put: (self basicAt: index) shallowCopy.
					index := index - 1]].
	index := class instSize.
	[index > 0]
		whileTrue: 
			[newObject instVarAt: index put: (self instVarAt: index) shallowCopy.
			index := index - 1].
	^newObject
]

{ #category : #testing }
Object >> costumes [
	"Answer a list of costumes associated with the receiver.  The appearance of this method in class Object serves only as a backstop, probably only transitionally"

	^ nil
]

{ #category : #'system primitives' }
Object >> creationStamp [
	"Answer a string which reports the creation particulars of the receiver.  Intended perhaps for list views, but this is presently a feature not easily accessible"

	^ '<no creation stamp>'
]

{ #category : #macpal }
Object >> currentEvent [
	"Answer the current Morphic event.  This method never returns nil."
	^ActiveEvent ifNil:[self currentHand lastEvent]
]

{ #category : #macpal }
Object >> currentHand [
	"Return a usable HandMorph -- the one associated with the object's current environment.  This method will always return a hand, even if it has to conjure one up as a last resort.  If a particular hand is actually handling events at the moment (such as a remote hand or a ghost hand), it will be returned."

	^ActiveHand ifNil: [ self currentWorld primaryHand ]
]

{ #category : #macpal }
Object >> currentVocabulary [
	"Answer the currently-prevailing default vocabulary."

	^ Project current currentVocabulary

]

{ #category : #macpal }
Object >> currentWorld [
	"Answer a morphic world that is the current UI focus."
	^ActiveWorld ifNil:[Project current world]
]

{ #category : #'debugging-haltOnce' }
Object >> decrementAndCheckHaltCount [
	self decrementHaltCount.
	^self checkHaltCountExpired
]

{ #category : #'debugging-haltOnce' }
Object >> decrementHaltCount [
	| counter |
	counter := Smalltalk
				at: #HaltCount
				ifAbsent: [0].
	counter > 0 ifTrue: [
		counter := counter - 1.
		self setHaltCountTo: counter]
]

{ #category : #copying }
Object >> deepCopy [
	"Answer a copy of the receiver with its own copy of each instance variable.
	WARNING: deepCopy does not preserve object identities in cycles in the object graph. Consider using #veryDeepCopy instead."

	| newObject class index |
	class := self class.
	(class == Object) ifTrue: [^self].
	class isVariable
		ifTrue: 
			[index := self basicSize.
			newObject := class basicNew: index.
			[index > 0]
				whileTrue: 
					[newObject basicAt: index put: (self basicAt: index) deepCopy.
					index := index - 1]]
		ifFalse: [newObject := class basicNew].
	index := class instSize.
	[index > 0]
		whileTrue: 
			[newObject instVarAt: index put: (self instVarAt: index) deepCopy.
			index := index - 1].
	^newObject
]

{ #category : #'user interface' }
Object >> defaultBackgroundColor [
	
	self deprecated: 'Implement #uniformWindowColor and #customWindowColor in your model.'.
	^ Color veryVeryLightGray
]

{ #category : #scripting }
Object >> defaultFloatPrecisionFor: aGetSelector [
	"Answer a number indicating the default float precision to be used in a numeric readout for which the receiver is the model."

	^ 1
]

{ #category : #'user interface' }
Object >> defaultLabelForInspector [
	"Answer the default label to be used for an Inspector window on the receiver."

	^ self class name
]

{ #category : #viewer }
Object >> defaultLimitClassForVocabulary: aVocabulary [
	"Answer the class to use, by default, as the limit class on a protocol browser or viewer opened up on the receiver, within the purview of the Vocabulary provided"

	^ (aVocabulary isKindOf: FullVocabulary)
		ifTrue:
			 [self class superclass == Object
				ifTrue:
					[self class]
				ifFalse:
					[self class superclass]]
		ifFalse:
			[ProtoObject]
]

{ #category : #viewer }
Object >> defaultNameStemForInstances [
	"Answer a basis for names of default instances of the receiver.  The default is to let the class specify, but certain instances will want to override.  (PasteUpMorphs serving as Worlds come to mind"

	^ self class defaultNameStemForInstances
]

{ #category : #'dependents access' }
Object >> dependents [
	"Answer a collection of objects that are 'dependent' on the receiver;
	 that is, all objects that should be notified if the receiver changes."

	^ self myDependents ifNil: [#()]
]

{ #category : #'error handling' }
Object >> deprecated [
	"Warn that the sending method has been deprecated."

	Deprecation
		signalForContext: thisContext sender
		message: ''
		explanation: ''
]

{ #category : #'error handling' }
Object >> deprecated: explanationString [
	"Warn that the sending method has been deprecated."

	Deprecation
		signalForContext: thisContext sender
		message: ''
		explanation: explanationString
]

{ #category : #'error handling' }
Object >> deprecated: explanationString block: aBlock [ 
	 "Warn that the sender has been deprecated.  Answer the value of aBlock on resumption.  (Note that #deprecated: is usually the preferred method.)"

	Deprecation
		signalForContext: thisContext sender
		message: ''
		explanation: explanationString.
	^ aBlock value

]

{ #category : #'parts bin' }
Object >> descriptionForPartsBin [
	"If the receiver is a member of a class that would like to be represented in a parts bin, answer the name by which it should be known, and a documentation string to be provided, for example, as balloon help.  When the 'nativitySelector' is sent to the 'globalReceiver', it is expected that some kind of Morph will result.  The parameters used in the implementation below are for documentation purposes only!"

	^ DescriptionForPartsBin
		formalName: 'PutFormalNameHere'
		categoryList: #(PutACategoryHere MaybePutAnotherCategoryHere)
		documentation: 'Put the balloon help here'
		globalReceiverSymbol: #PutAGlobalHere
		nativitySelector: #PutASelectorHere
]

{ #category : #'debugging-haltOnce' }
Object >> doExpiredHaltCount [
	self clearHaltOnce.
	self removeHaltCount.
	self halt
]

{ #category : #'debugging-haltOnce' }
Object >> doExpiredHaltCount: aString [
	self clearHaltOnce.
	self removeHaltCount.
	self halt: aString
]

{ #category : #'debugging-haltOnce' }
Object >> doExpiredInspectCount [
	self clearHaltOnce.
	self removeHaltCount.
	self inspect
]

{ #category : #'error handling' }
Object >> doesNotUnderstand: aMessage [ 
	 "Handle the fact that there was an attempt to send the given
	  message to the receiver but the receiver does not understand
	  this message (typically sent from the machine when a message
	 is sent to the receiver and no method is defined for that selector)."

	"Testing: (3 activeProcess)"

	| exception resumeValue |
	(exception := MessageNotUnderstood new)
		message: aMessage;
		receiver: self.
	resumeValue := exception signal.
	^exception reachedDefaultHandler
		ifTrue: [aMessage sentTo: self]
		ifFalse: [resumeValue]
]

{ #category : #'error handling' }
Object >> dpsTrace: reportObject [  
	Transcript myDependents isNil ifTrue: [^self].
	self dpsTrace: reportObject levels: 1 withContext: thisContext
		
" nil dpsTrace: 'sludder'. "
]

{ #category : #'error handling' }
Object >> dpsTrace: reportObject levels: anInt [
	self dpsTrace: reportObject levels: anInt withContext: thisContext

"(1 to: 3) do: [:int | nil dpsTrace: int levels: 5.]"
]

{ #category : #'error handling' }
Object >> dpsTrace: reportObject levels: anInt withContext: currentContext [
	| reportString context displayCount |
	reportString := (reportObject respondsTo: #asString) 
			ifTrue: [reportObject asString] ifFalse: [reportObject printString].
	(Smalltalk at: #Decompiler ifAbsent: [nil]) 
	ifNil: 
		[Transcript cr; show: reportString]
	ifNotNil:
		[context := currentContext.
		displayCount := anInt > 1.
		1 to: anInt do:
			[:count |
			Transcript cr.
			displayCount
				ifTrue: [Transcript show: count printString, ': '].
			
			reportString notNil
			ifTrue:
				[Transcript show: context home class name 
			, '/' , context sender selector,  ' (' , reportString , ')'.
				context := context sender.
				reportString := nil]
			ifFalse:
				[(context notNil and: [(context := context sender) notNil])
				ifTrue: [Transcript show: context receiver class name , '/' , context selector]]].
		"Transcript cr"].
]

{ #category : #'drag and drop' }
Object >> dragAnimationFor: item transferMorph: transferMorph [ 
	"Default do nothing"
	self deprecated.
]

{ #category : #'drag and drop' }
Object >> dragPassengerFor: item inMorph: dragSource [ 
	^item
]

{ #category : #'drag and drop' }
Object >> dragStartedFor: anItemMorph transferMorph: aTransferMorph [ 
	"Give the model a chance to respond to a started drag operation. Could be used to give a notification or play an animation. Do nothing by default."
]

{ #category : #'drag and drop' }
Object >> dragTransferTypeForMorph: dragSource [ 
	^nil
]

{ #category : #'filter streaming' }
Object >> drawOnCanvas:aStream [
	self flattenOnStream:aStream.

]

{ #category : #'user interface' }
Object >> eToyStreamedRepresentationNotifying: aWidget [

	| outData |
	[ outData := SmartRefStream streamedRepresentationOf: self ] 
		on: ProgressInitiationException
		do: [ :ex | 
			ex sendNotificationsTo: [ :min :max :curr |
				aWidget ifNotNil: [aWidget flashIndicator: #working].
			].
		].
	^outData

]

{ #category : #'filter streaming' }
Object >> elementSeparator [
	^nil.
]

{ #category : #viewer }
Object >> elementTypeFor: aStringOrSymbol vocabulary: aVocabulary [
	"Answer a symbol characterizing what kind of element aStringOrSymbol represents.  Realistically, at present, this always just returns #systemScript; a prototyped but not-incorporated architecture supported use of a leading colon to characterize an inst var of a system class, and for the moment we still see its remnant here."

	self flag: #deferred.  "a loose end in the non-player case"
	^ #systemScript
]

{ #category : #accessing }
Object >> enclosedSetElement [
	"The receiver is included into a set as an element. 
	Since some objects require wrappers (see SetElement) to be able to be included into a Set,
	a set sends this message to its element to make sure it getting real object,
	instead of its wrapper.
	Only SetElement instance or its subclasses allowed to answer something different than receiver itself"
	

]

{ #category : #'filter streaming' }
Object >> encodePostscriptOn:aStream [
	self byteEncode:aStream.

]

{ #category : #'error handling' }
Object >> error [
	"Throw a generic Error exception."

	^self error: 'Error!'.
]

{ #category : #'error handling' }
Object >> error: aString [ 
	"Throw a generic Error exception."

	^Error new signal: aString
]

{ #category : #private }
Object >> errorImproperStore [
	"Create an error notification that an improper store was attempted."

	self error: 'Improper store into indexable object'
]

{ #category : #private }
Object >> errorNonIntegerIndex [
	"Create an error notification that an improper object was used as an index."

	self error: 'only integers should be used as indices'
]

{ #category : #private }
Object >> errorNotIndexable [
	"Create an error notification that the receiver is not indexable."

	self error: ('Instances of {1} are not indexable' translated format: {self class name})
]

{ #category : #private }
Object >> errorSubscriptBounds: index [ 
	"Create an error notification that an improper integer was used as an index."

	self error: 'subscript is out of bounds: ' , index printString
]

{ #category : #'dependents access' }
Object >> evaluate: actionBlock wheneverChangeIn: aspectBlock [
	| viewerThenObject objectThenViewer |
	objectThenViewer := self.
	viewerThenObject := ObjectViewer on: objectThenViewer.
	objectThenViewer become: viewerThenObject.
	"--- Then ---"
	objectThenViewer xxxViewedObject: viewerThenObject
			evaluate: actionBlock
			wheneverChangeIn: aspectBlock
]

{ #category : #scripting }
Object >> evaluateUnloggedForSelf: aCodeString [

	^Compiler evaluate:
		aCodeString
		for: self
]

{ #category : #'message handling' }
Object >> executeMethod: compiledMethod [
	"Execute compiledMethod against the receiver with no args"

	<primitive: 189>
	^ self withArgs: #() executeMethod: compiledMethod
]

{ #category : #finalization }
Object >> executor [
	"Return an object which can act as executor for finalization of the receiver"
	^self shallowCopy actAsExecutor
]

{ #category : #'user interface' }
Object >> explore [
	ToolSet explore: self
]

{ #category : #viewer }
Object >> externalName [
	"Answer an external name by which the receiver is known.  Generic implementation here is a transitional backstop. probably"

	^ self nameForViewer
]

{ #category : #finalization }
Object >> finalize [
	"Finalize the resource associated with the receiver. This message should only be sent during the finalization process. There is NO garantuee that the resource associated with the receiver hasn't been free'd before so take care that you don't run into trouble - this all may happen with interrupt priority."
]

{ #category : #'objects from disk' }
Object >> fixUponLoad: aProject seg: anImageSegment [
	"change the object due to conventions that have changed on
the project level.  (sent to all objects in the incoming project).
Specific classes should reimplement this."
]

{ #category : #macpal }
Object >> flash [
	"Do nothing."

]

{ #category : #'filter streaming' }
Object >> flattenOnStream:aStream [
	self writeOnFilterStream:aStream.

]

{ #category : #'filter streaming' }
Object >> fullDrawPostscriptOn:aStream [
	^aStream fullDraw:self.

]

{ #category : #printing }
Object >> fullPrintString [
	"Answer a String whose characters are a description of the receiver."

	^ String streamContents: [:s | self printOn: s]
]

{ #category : #'user interface' }
Object >> fullScreenSize [
	"Answer the size to which a window displaying the receiver should be set"
	| adj |
	adj := (3 * Preferences scrollBarWidth) @ 0.
	^ Rectangle origin: adj extent: (DisplayScreen actualScreenSize - adj)
]

{ #category : #futures }
Object >> future [
	"See FutureMaker class comment.  In practice, this code is optimized away by the Compiler (see FutureNode)."
	^(FutureMaker new) 
		setDeltaMSecs: 0.0 target: self
]

{ #category : #futures }
Object >> future: deltaMSecs [
	"See FutureMaker class comment.  In practice, this code is optimized away by the Compiler (see FutureNode)."
	^(FutureMaker new)
		setDeltaMSecs: deltaMSecs target: self
]

{ #category : #futures }
Object >> futureDo: aSelector at: deltaMSecs args: args [
	"Send a message deltaMSecs into the future (some implementations may requires 'deltaMSecs' to be zero).  No response is expected.  See comment in class FutureNode."
	Project current future: self do: aSelector at: deltaMSecs args: args.
	^nil
]

{ #category : #futures }
Object >> futureSend: aSelector at: deltaMSecs args: args [
	"Send a message deltaSeconds into the future (some implementations may requires 'deltaMSecs' to be zero).  Answers a Promise that will be resolved at some time in the future.  See comment in class FutureNode."
	^Project current future: self send: aSelector at: deltaMSecs args: args.
]

{ #category : #viewer }
Object >> graphicForViewerTab [
	"When a Viewer is open on the receiver, its tab needs some graphic to show to the user.  Answer a form or a morph to serve that purpose.  A generic image is used for arbitrary objects, but note my reimplementors"
	
	^ ScriptingSystem formAtKey: 'Image'
]

{ #category : #'error handling' }
Object >> halt [
	"This is the typical message to use for inserting breakpoints during 
	debugging. It behaves like halt:, but does not call on halt: in order to 
	avoid putting this message on the stack. Halt is especially useful when 
	the breakpoint message is an arbitrary one."

	Halt signal
]

{ #category : #'error handling' }
Object >> halt: aString [ 
	"This is the typical message to use for inserting breakpoints during 
	debugging. It creates and schedules a Notifier with the argument, 
	aString, as the label."
	
	Halt new signal: aString
]

{ #category : #'debugging-haltOnce' }
Object >> halt: aString onCount: int [ 
	self haltOnceEnabled
		ifTrue: [self hasHaltCount
				ifTrue: [self decrementAndCheckHaltCount
						ifTrue: [self doExpiredHaltCount: aString]]
				ifFalse: [int = 1
						ifTrue: [self doExpiredHaltCount: aString]
						ifFalse: [self setHaltCountTo: int - 1]]]
]

{ #category : #debugging }
Object >> haltIf: condition [
	"This is the typical message to use for inserting breakpoints during 
	debugging.  Param can be a block or expression, halt if true.
	If the Block has one arg, the receiver is bound to that.
 	If the condition is a selector, we look up in the callchain. Halt if
      any method's selector equals selector."
	| cntxt |

	condition isSymbol ifTrue:[
		"only halt if a method with selector symbol is in callchain"
		cntxt := thisContext.
		[cntxt sender isNil] whileFalse: [
			cntxt := cntxt sender. 
			(cntxt selector = condition) ifTrue: [Halt signal].
			].
		^self.
	].
	(condition isBlock 
			ifTrue: [condition cull: self] 
			ifFalse: [condition] 
	) ifTrue: [
		Halt signal
	].
]

{ #category : #testing }
Object >> haltIfNil [
]

{ #category : #'debugging-haltOnce' }
Object >> haltOnCount: int [ 
	self haltOnceEnabled
		ifTrue: [self hasHaltCount
				ifTrue: [self decrementAndCheckHaltCount
						ifTrue: [self doExpiredHaltCount]]
				ifFalse: [int = 1
						ifTrue: [self doExpiredHaltCount]
						ifFalse: [self setHaltCountTo: int - 1]]]
]

{ #category : #'debugging-haltOnce' }
Object >> haltOnce [
	"Halt unless we have already done it once."
	self haltOnceEnabled
		ifTrue: [self clearHaltOnce.
			^ self halt]
]

{ #category : #'debugging-haltOnce' }
Object >> haltOnce: aString [ 
	"Halt unless we have already done it once."
	self haltOnceEnabled
		ifTrue: [self clearHaltOnce.
			^ self halt: aString]
]

{ #category : #'debugging-haltOnce' }
Object >> haltOnceEnabled [
	^ Smalltalk
		at: #HaltOnce
		ifAbsent: [false]
]

{ #category : #updating }
Object >> handledListVerification [
	"When a self-updating PluggableListMorph lazily checks to see the state of affairs, it first gives its model an opportunity to handle the list verification itself (this is appropriate for some models, such as VersionsBrowser); if a list's model has indeed handled things itself, it returns true here"

	^ false
]

{ #category : #'error handling' }
Object >> handles: exception [
	"This method exists in case a non exception class is the first arg in an on:do: (for instance using a exception class that is not loaded). We prefer this to raising an error during error handling itself. Also, semantically it makes sense that the exception handler is not active if its exception class is not loaded"

	^ false
]

{ #category : #'user interface' }
Object >> hasContentsInExplorer [

	^self basicSize > 0 or: [self class allInstVarNames isEmpty not]

]

{ #category : #'debugging-haltOnce' }
Object >> hasHaltCount [
	^self class environment
				includesKey: #HaltCount
]

{ #category : #literals }
Object >> hasLiteral: literal [

	^ self hasLiteralSuchThat: [:lit | lit literalEqual: literal]
]

{ #category : #literals }
Object >> hasLiteralSuchThat: testBlock [

	self allLiteralsDo: [:literal |
		(testBlock value: literal) ifTrue: [^ true]].
	
	^ false
]

{ #category : #'graph model' }
Object >> hasModelYellowButtonMenuItems [
	^ true
]

{ #category : #'dependents access' }
Object >> hasUnacceptedEdits [
	"Answer true if any of the views on this object has unaccepted edits."

	self dependents
		do: [:each | each hasUnacceptedEdits ifTrue: [^ true]]
		without: self.
	^ false
]

{ #category : #viewer }
Object >> hasUserDefinedSlots [
	"Answer whether the receiver has any user-defined slots, in the omniuser sense of the term.  This is needed to allow Viewers to look at any object, not just at Players."

	^ false
]

{ #category : #comparing }
Object >> hash [
	"Answer a SmallInteger whose value is related to the receiver's identity.
	May be overridden, and should be overridden in any classes that define = "

	^self scaledIdentityHash
]

{ #category : #comparing }
Object >> hashString [
^self hash printStringBase: 36
]

{ #category : #testing }
Object >> haveFullProtocolBrowsed [
	"Open up a Lexicon on the receiver"

	^ self haveFullProtocolBrowsedShowingSelector: nil

	"(2@3) haveFullProtocolBrowsed"

]

{ #category : #testing }
Object >> haveFullProtocolBrowsedShowingSelector: aSelector [
	"Open up a Lexicon on the receiver, having it open up showing aSelector, which may be nil"

	| aBrowser |
	aBrowser := (Smalltalk at: #InstanceBrowser ifAbsent:[^nil]) new useVocabulary: Vocabulary fullVocabulary.
	aBrowser openOnObject: self inWorld: ActiveWorld showingSelector: aSelector

	"(2@3) haveFullProtocolBrowsed"
]

{ #category : #thumbnail }
Object >> iconOrThumbnailOfSize: aNumberOrPoint [ 
	"Answer an appropiate form to represent the receiver"
	^ nil
]

{ #category : #comparing }
Object >> identityHashPrintString [
	"'fred' identityHashPrintString"

	^ '(', self identityHash printString, ')'
]

{ #category : #comparing }
Object >> identityHashString [
^self identityHash printStringBase: 36
]

{ #category : #accessing }
Object >> ifNil: nilBlock ifNotNilDo: aBlock [ 
	"Evaluate aBlock with the receiver as its argument."

	^ aBlock value: self

]

{ #category : #accessing }
Object >> ifNotNilDo: aBlock [
	"Evaluate the given block with the receiver as its argument."

	^ aBlock value: self

]

{ #category : #accessing }
Object >> ifNotNilDo: aBlock ifNil: nilBlock [
	"Evaluate aBlock with the receiver as its argument."

	^ aBlock value: self

]

{ #category : #accessing }
Object >> in: aBlock [
	"Evaluate the given block with the receiver as its argument."

	^ aBlock value: self

]

{ #category : #tracing }
Object >> inboundPointers [
"Answers a collection of all objects in the system that point to myself"

	^ self inboundPointersExcluding: #()
]

{ #category : #tracing }
Object >> inboundPointersExcluding: objectsToExclude [
	"Answer a list of all objects in the system that hold a reference to me, excluding those in the collection of objectsToExclude."

	| pointers object objectsToAlwaysExclude |
	Smalltalk garbageCollect.
	pointers := OrderedCollection new.
	self systemNavigation allObjectsOrNil ifNotNil: [ :allObjects |
		objectsToAlwaysExclude := {
			allObjects.
			thisContext.
			thisContext sender.
			thisContext sender sender.
			objectsToExclude.
		}.
		1 to: allObjects size do: [ :index |
			object := allObjects at: index.
			(object pointsTo: self) ifTrue: [
				((objectsToAlwaysExclude identityIncludes: object)
					or: [ objectsToExclude identityIncludes: object ])
					ifFalse: [ pointers add: object ] ] ].
		^pointers ].
	"SystemNavigation >> #allObjectsDo: is inlined here with a slight modification: the marker object is pointers. This gives better results, because the value of pointers, it's inner objects and transient method contexts will not be iterated over."
	object := self someObject.
	[ object == pointers ] whileFalse: [
		(object isInMemory and: [ object pointsTo: self ]) ifTrue: [
			pointers add: object ].
		object := object nextObject ].
	objectsToAlwaysExclude := {
		thisContext.
		thisContext sender.
		thisContext sender sender.
		objectsToExclude.
	}.
	^pointers removeAllSuchThat: [ :ea |
		(objectsToAlwaysExclude identityIncludes: ea)
			or: [ objectsToExclude identityIncludes: ea ] ]
]

{ #category : #viewer }
Object >> infoFor: anElement inViewer: aViewer [
	"The user made a gesture asking for info/menu relating to me.  Some of the messages dispatched here are not yet available in this image"

	| aMenu elementType |
	elementType := self elementTypeFor: anElement vocabulary: aViewer currentVocabulary.
	((elementType = #systemSlot) | (elementType == #userSlot))
		ifTrue:	[^ self slotInfoButtonHitFor: anElement inViewer: aViewer].
	self flag: #deferred.  "Use a traditional MenuMorph, and reinstate the pacify thing"
	aMenu := MenuMorph new defaultTarget: aViewer.
	#(	('implementors'			browseImplementorsOf:)
		('senders'				browseSendersOf:)
		('versions'				browseVersionsOf:)
		-
		('browse full'			browseMethodFull:)
		('inheritance'			browseMethodInheritance:)
		-
		('about this method'		aboutMethod:)) do:

			[:pair |
				pair = '-'
					ifTrue:
						[aMenu addLine]
					ifFalse:
						[aMenu add: pair first target: aViewer selector: pair second argument: anElement]].
	aMenu addLine.
	aMenu defaultTarget: self.
	#(	('destroy script'		removeScript:)
		('rename script'		renameScript:)
		('pacify script'		pacifyScript:)) do:
			[:pair |
				aMenu add: pair first target: self selector: pair second argument: anElement].

	aMenu addLine.
	aMenu  add: 'show categories....' target: aViewer selector: #showCategoriesFor: argument: anElement.
	aMenu items size = 0 ifTrue:  "won't happen at the moment a/c the above"
		[aMenu add: 'ok' action: nil].  "in case it was a slot -- weird, transitional"

	aMenu addTitle: anElement asString, ' (', elementType, ')'.

	aMenu popUpInWorld: self currentWorld.
 
]

{ #category : #'user interface' }
Object >> inform: aString [
	"Display a message for the user to read and then dismiss. 6/9/96 sw"

	aString isEmptyOrNil ifFalse: [UIManager default inform: aString]
]

{ #category : #'class membership' }
Object >> inheritsFromAnyIn: aList [
	"Answer whether the receiver inherits from any class represented by any element in the list.  The elements of the list can be classes, class name symbols, or strings representing possible class names.  This allows speculative membership tests to be made even when some of the classes may not be known to the current image, and even when their names are not interned symbols."

	aList do:
		[:elem | Symbol hasInterned: elem asString ifTrue: 
			[:elemSymbol |
			| aClass |
			(((aClass := Smalltalk at: elemSymbol ifAbsent: [nil]) isKindOf: Class)
						and: [self isKindOf: aClass])
				ifTrue:
					[^ true]]].
	^ false


"
{3.  true. 'olive'} do:
	[:token |
		 {{#Number. #Boolean}. {Number.  Boolean }.  {'Number'. 'Boolean'}} do:
			[:list |
				Transcript cr; show: token asString, ' list element provided as a ', list first class name, ' - ', (token inheritsFromAnyIn: list) asString]]
"
]

{ #category : #copying }
Object >> initialDeepCopierSize [
	"default value is 4096; other classes may override this, esp. for smaller (=faster) sizes"

	^4096
]

{ #category : #'user interface' }
Object >> initialExtent [
	"Answer the desired extent for the receiver when a view on it is first opened on the screen. 
	5/22/96 sw: in the absence of any override, obtain from RealEstateAgent"

	^ RealEstateAgent standardWindowExtent
]

{ #category : #viewer }
Object >> initialTypeForSlotNamed: aName [
	"Answer the initial type to be ascribed to the given instance variable"

	^ #Object
]

{ #category : #'translation support' }
Object >> inline: inlineFlag [
	"For translation only; noop when running in Smalltalk."
]

{ #category : #'user interface' }
Object >> inspect [
	"Create and schedule an Inspector in which the user can examine the receiver's variables."
	ToolSet inspect: self
]

{ #category : #'debugging-haltOnce' }
Object >> inspectOnCount: int [ 
	self haltOnceEnabled
		ifTrue: [self hasHaltCount
				ifTrue: [self decrementAndCheckHaltCount
						ifTrue: [self doExpiredInspectCount]]
				ifFalse: [int = 1
						ifTrue: [self doExpiredInspectCount]
						ifFalse: [self setHaltCountTo: int - 1]]]
]

{ #category : #'debugging-haltOnce' }
Object >> inspectOnce [
	"Inspect unless we have already done it once."
	self haltOnceEnabled
		ifTrue: [self clearHaltOnce.
			^ self inspect]
]

{ #category : #'debugging-haltOnce' }
Object >> inspectUntilCount: int [ 
	self haltOnceEnabled
		ifTrue: [self hasHaltCount
				ifTrue: [self decrementAndCheckHaltCount
						ifTrue: [self doExpiredInspectCount]
						ifFalse: [self inspect]]
				ifFalse: [int = 1
						ifTrue: [self doExpiredInspectCount]
						ifFalse: [self setHaltCountTo: int - 1]]]
]

{ #category : #'user interface' }
Object >> inspectWithLabel: aLabel [
	"Create and schedule an Inspector in which the user can examine the receiver's variables."
	ToolSet inspect: self label: aLabel
]

{ #category : #'system primitives' }
Object >> instVarAt: index [
	"Primitive. Answer a fixed variable in an object. The numbering of the variables
	 corresponds to the named instance variables, followed by the indexed instance
	 variables. Fail if the index is not an Integer or is not the index of a fixed or
	 indexed variable. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 173 error: ec>
	self primitiveFailed
]

{ #category : #'system primitives' }
Object >> instVarAt: index put: anObject [
	"Primitive. Store a value into a fixed variable in an object. The numbering of the
	 variables corresponds to the named instance variables, followed by the indexed
	 instance variables. Fail if the index is not an Integer or is not the index of a fixed
	 or indexed variable. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 174 error: ec>
	self primitiveFailed
]

{ #category : #'system primitives' }
Object >> instVarNamed: aString [
	"Return the value of the instance variable in me with that name.  Slow and unclean, but very useful. "

	^ self instVarAt: (self class
						instVarIndexFor: aString asString
						ifAbsent: [self error: 'no such inst var'])



]

{ #category : #'system primitives' }
Object >> instVarNamed: aString put: aValue [
	"Store into the value of the instance variable in me of that name.  Slow and unclean, but very useful. "

	^self
		instVarAt: (self class
						instVarIndexFor: aString asString
						ifAbsent: [self error: 'no such inst var'])
		put: aValue

]

{ #category : #macpal }
Object >> instanceVariableValues [
	"Answer a collection whose elements are the values of those instance variables of the receiver which were added by the receiver's class"
	| c |
	c := OrderedCollection new.
	self class superclass instSize + 1 to: self class instSize do:
		[:i | c add: (self instVarAt: i)].
	^ c
]

{ #category : #testing }
Object >> isArray [
	^false
]

{ #category : #testing }
Object >> isBehavior [
	"Return true if the receiver is a behavior.
	Note: Do not override in any class except behavior."
	^false
]

{ #category : #testing }
Object >> isBlock [

	^ false
]

{ #category : #testing }
Object >> isBoolean [
	^ false
]

{ #category : #testing }
Object >> isCharacter [

	^ false.

]

{ #category : #testing }
Object >> isClassReference [

	^ false
]

{ #category : #testing }
Object >> isClosure [
	^false
]

{ #category : #testing }
Object >> isCodeReference [

	^ self isClassReference or: [self isMethodReference]
]

{ #category : #testing }
Object >> isCollection [
	"Return true if the receiver is some sort of Collection and responds to basic collection messages such as #size and #do:"
	^false
]

{ #category : #testing }
Object >> isColor [
	"Answer true if receiver is a Color. False by default."

	^ false

]

{ #category : #testing }
Object >> isColorForm [
	^false
]

{ #category : #testing }
Object >> isCompiledCode [
	^false
]

{ #category : #testing }
Object >> isCompiledMethod [

	^ false
]

{ #category : #testing }
Object >> isComplex [
	"Answer true if receiver is a Complex number. False by default."

	^ false

]

{ #category : #testing }
Object >> isContext [
	^false
]

{ #category : #testing }
Object >> isDictionary [
	^false
]

{ #category : #testing }
Object >> isFloat [
	"Overridden to return true in Float, natch"
	^ false
]

{ #category : #testing }
Object >> isForm [
	^false
]

{ #category : #testing }
Object >> isFraction [
	"Answer true if the receiver is a Fraction."

	^ false
]

{ #category : #testing }
Object >> isHeap [

	^ false
]

{ #category : #testing }
Object >> isInteger [
	"Overridden to return true in Integer."

	^ false
]

{ #category : #testing }
Object >> isInterval [

	^ false
]

{ #category : #'class membership' }
Object >> isKindOf: aClass [ 
	"Answer whether the class, aClass, is a superclass or class of the receiver."
	^ self class == aClass or: [ self class inheritsFrom: aClass ]
]

{ #category : #'class membership' }
Object >> isKindOf: aClass orOf: anotherClass [
	"Answer whether either of the classes, aClass or anotherClass,, is a superclass or class of the receiver.  A convenience; could be somewhat optimized"
	^ (self isKindOf: aClass) or: [self isKindOf: anotherClass]
]

{ #category : #printing }
Object >> isLiteral [
	"Answer whether the receiver has a literal text form recognized by the 
	compiler."

	^false
]

{ #category : #'class membership' }
Object >> isMemberOf: aClass [ 
	"Answer whether the receiver is an instance of the class, aClass."

	^self class == aClass
]

{ #category : #testing }
Object >> isMessageSend [
	^false

]

{ #category : #testing }
Object >> isMethodContext [
	^ false
]

{ #category : #testing }
Object >> isMethodProperties [
	^false
]

{ #category : #testing }
Object >> isMethodReference [
	^false
]

{ #category : #testing }
Object >> isMorph [

	^ false
]

{ #category : #testing }
Object >> isMorphicEvent [
	^false
]

{ #category : #testing }
Object >> isMorphicModel [
	"Return true if the receiver is a morphic model"
	^false

]

{ #category : #testing }
Object >> isNumber [
	"Overridden to return true in Number, natch"
	^ false
]

{ #category : #pinning }
Object >> isPinned [
	"Answer if the receiver is pinned.  The VM's garbage collector routinely moves
	 objects as it reclaims and compacts memory.  But it can also pin an object so
	 that it will not be moved, which can make it easier to pass objects out through
	 the FFI."
	<primitive: 183 error: ec>
	^self primitiveFailed
]

{ #category : #testing }
Object >> isPlayer [
	^false
]

{ #category : #viewer }
Object >> isPlayerLike [
	"Return true if the receiver is a player-like object"
	^false
]

{ #category : #testing }
Object >> isPoint [
	"Overridden to return true in Point."

	^ false
]

{ #category : #testing }
Object >> isPrimitiveCostume [
"True for primitive costumes in Tweak. Added here because a Tweak override in DisplayScanner was merged into trunk for maintainability"
	^false
]

{ #category : #testing }
Object >> isPromise [
	^false
]

{ #category : #accessing }
Object >> isReadOnlyObject [
^false
]

{ #category : #testing }
Object >> isRectangle [
	^false
]

{ #category : #testing }
Object >> isRemote [
	"answer if the object is a remote one"
	^ false
]

{ #category : #testing }
Object >> isScriptEditorMorph [
	^false
]

{ #category : #testing }
Object >> isSketchMorph [
	^false
]

{ #category : #testing }
Object >> isStream [
	"Return true if the receiver responds to the stream protocol"
	^false

]

{ #category : #testing }
Object >> isString [
	"Overridden to return true in String, natch"
	^ false
]

{ #category : #testing }
Object >> isSymbol [
	^ false 
]

{ #category : #testing }
Object >> isSystemWindow [
"answer whatever the receiver is a SystemWindow"
	^ false
]

{ #category : #testing }
Object >> isText [
	^ false
]

{ #category : #testing }
Object >> isTextView [
	"True if the reciever is a view on a text model, such as a view on a TranscriptStream"
	^false
]

{ #category : #flagging }
Object >> isThisEverCalled [
	^ self isThisEverCalled: thisContext sender printString
]

{ #category : #flagging }
Object >> isThisEverCalled: msg [
	"Send this message, with some useful printable argument, from methods or branches of methods which you believe are never reached.  2/5/96 sw"

	self halt: 'This is indeed called: ', msg printString
]

{ #category : #testing }
Object >> isTrait [
	"Return true if the receiver is a trait.
	Note: Do not override in any class except TraitBehavior."
	^false
]

{ #category : #testing }
Object >> isTransparent [
	^ false
]

{ #category : #macpal }
Object >> isUniversalTiles [
	"Return true if I (my world) uses universal tiles.  This message can be called in places where the current World is not known, such as when writing out a project.  For more information about the project-writing subtlety addressed by this protocol, kindly contact Ted Kaehler."

	^ Preferences universalTiles
]

{ #category : #testing }
Object >> isVariableBinding [
	"Return true if I represent a literal variable binding"
	^false
	
]

{ #category : #testing }
Object >> isWebBrowser [
	"whether this object is a web browser.  See class: Scamper"
	^false
]

{ #category : #testing }
Object >> isWindowForModel: aModel [
	"Return true if the receiver acts as the window for the given model"
	^false
]

{ #category : #testing }
Object >> knownName [
	"If a formal name has been handed out for this object, answer it, else nil"
	
	^ Preferences capitalizedReferences
		ifTrue:
			[References keyAtValue: self ifAbsent: [nil]]
		ifFalse:
			[nil]
]

{ #category : #'user interface' }
Object >> launchPartVia: aSelector [
	"Obtain a morph by sending aSelector to self, and attach it to the morphic hand.  This provides a general protocol for parts bins"

	| aMorph |
	aMorph := self perform: aSelector.
	aMorph setProperty: #beFullyVisibleAfterDrop toValue: true.
	aMorph openInHand
]

{ #category : #'user interface' }
Object >> launchPartVia: aSelector label: aString [
	"Obtain a morph by sending aSelector to self, and attach it to the morphic hand.  This provides a general protocol for parts bins"

	| aMorph |
	aMorph := self perform: aSelector.
	aMorph setNameTo: (ActiveWorld unusedMorphNameLike: aString).
	aMorph setProperty: #beFullyVisibleAfterDrop toValue: true.
	aMorph openInHand
]

{ #category : #'user interface' }
Object >> launchTileToRefer [
	"Create a tile to reference the receiver, and attach it to the hand"

	self currentHand attachMorph: self tileToRefer
]

{ #category : #comparing }
Object >> literalEqual: other [

	^ self class == other class and: [self = other]
]

{ #category : #flagging }
Object >> logEntry [

	Transcript show: 'Entered ', thisContext sender printString; cr.

]

{ #category : #flagging }
Object >> logExecution [

	Transcript show: 'Executing ', thisContext sender printString; cr.

]

{ #category : #flagging }
Object >> logExit [

	Transcript show:  'Exited ', thisContext sender printString; cr.

]

{ #category : #printing }
Object >> longPrintOn: aStream [
	"Append to the argument, aStream, the names and values of all 
	of the receiver's instance variables."

	self class allInstVarNames doWithIndex:
		[:title :index |
		aStream nextPutAll: title;
		 nextPut: $:;
		 space;
		 tab;
		 print: (self instVarAt: index);
		 cr]
]

{ #category : #printing }
Object >> longPrintOn: aStream limitedTo: sizeLimit indent: indent [
	"Append to the argument, aStream, the names and values of all of the receiver's instance variables.  Limit is the length limit for each inst var."

	self class allInstVarNames doWithIndex:
		[:title :index |
		indent timesRepeat: [aStream tab].
		aStream nextPutAll: title;
		 nextPut: $:;
		 space;
		 tab;
		 nextPutAll: 
			((self instVarAt: index) printStringLimitedTo: (sizeLimit -3 -title size max: 1));
		 cr]
]

{ #category : #printing }
Object >> longPrintString [
	"Answer a String whose characters are a description of the receiver."
	
	| str |
	str := String streamContents: [:aStream | self longPrintOn: aStream].
	"Objects without inst vars should return something"
	^ str isEmpty ifTrue: [self printString, String cr] ifFalse: [str]
]

{ #category : #printing }
Object >> longPrintStringLimitedTo: aLimitValue [
	"Answer a String whose characters are a description of the receiver."
	
	| str |
	str := String streamContents: [:aStream | self longPrintOn: aStream limitedTo: aLimitValue indent: 0].
	"Objects without inst vars should return something"
	^ str isEmpty ifTrue: [self printString, String cr] ifFalse: [str]
]

{ #category : #scripting }
Object >> methodInterfacesForCategory: aCategorySymbol inVocabulary: aVocabulary limitClass: aLimitClass [
	"Return a list of methodInterfaces for the receiver in the given category, given a vocabulary.  aCategorySymbol is the inherent category symbol, not necessarily the wording as expressed in the vocabulary."

	| categorySymbol |
	categorySymbol := aCategorySymbol asSymbol.

	(categorySymbol == ScriptingSystem nameForInstanceVariablesCategory) ifTrue: [
		"user-defined instance variables"
		^ self methodInterfacesForInstanceVariablesCategoryIn: aVocabulary].
	(categorySymbol == ScriptingSystem nameForScriptsCategory) ifTrue: [
		"user-defined scripts"
		^ self methodInterfacesForScriptsCategoryIn: aVocabulary].
	"all others"
	^ self usableMethodInterfacesIn: (aVocabulary methodInterfacesInCategory: categorySymbol
		forInstance: self
		ofClass: self class
		limitClass: aLimitClass)

]

{ #category : #scripting }
Object >> methodInterfacesForInstanceVariablesCategoryIn: aVocabulary [
	"Return a collection of methodInterfaces for the instance-variables category.  The vocabulary parameter, at present anyway, is not used.  And for non-players, the method is at present vacuous in any case"

	^  OrderedCollection new
]

{ #category : #scripting }
Object >> methodInterfacesForScriptsCategoryIn: aVocabulary [
	"Answer a list of method interfaces for the category #scripts, as seen in a viewer or other tool.  The vocabulary argument is not presently used.  Also, at present, only Players really do anyting interesting here."

	^ OrderedCollection new
]

{ #category : #viewer }
Object >> methodInterfacesInPresentationOrderFrom: interfaceList forCategory: aCategory [ 
	"Answer the interface list sorted in desired presentation order, using a 
	static master-ordering list, q.v. The category parameter allows an 
	escape in case one wants to apply different order strategies in different 
	categories, but for now a single master-priority-ordering is used -- see 
	the comment in method EToyVocabulary.masterOrderingOfPhraseSymbols"

	| masterOrder ordered unordered |
	masterOrder := Vocabulary eToyVocabulary masterOrderingOfPhraseSymbols.
	ordered := OrderedCollection new. 
	unordered := OrderedCollection new.

	interfaceList do: [:interface | 
		| index |
		index := masterOrder indexOf: interface elementSymbol.
		index = 0
			ifTrue: [unordered addLast: interface]
			ifFalse: [ordered addLast: index -> interface]].

	ordered sort: [:a :b | a key < b key].
	unordered sort: [:a :b | a wording < b wording].
	
	^ Array
		streamContents: [:stream | 
			ordered do: [:assoc | stream nextPut: assoc value].
			stream nextPutAll: unordered]
]

{ #category : #'user interface' }
Object >> modelSleep [
	"A window with me as model is being exited or collapsed or closed.
	Default response is no-op" 
]

{ #category : #'user interface' }
Object >> modelWakeUp [
	"A window with me as model is being entered or expanded.  Default response is no-op" 
]

{ #category : #'user interface' }
Object >> modelWakeUpIn: aWindow [
	"A window with me as model is being entered or expanded.  Default response is no-op" 
	self modelWakeUp
]

{ #category : #'user interface' }
Object >> mouseUpBalk: evt [
	"A button I own got a mouseDown, but the user moved out before letting up.  Certain kinds of objects (so-called 'radio buttons', for example, and other structures that must always have some selection, e.g. PaintBoxMorph) wish to take special action in this case; this default does nothing."

]

{ #category : #converting }
Object >> mustBeBoolean [
	"Catches attempts to test truth of non-Booleans.  This message is sent from the VM.  The sending context is rewound to just before the jump causing this exception."

	^ self mustBeBooleanIn: thisContext sender
]

{ #category : #converting }
Object >> mustBeBooleanIn: context [
	"context is the where the non-boolean error occurred. Rewind context to before jump then raise error."

	| proceedValue |
	context skipBackBeforeJump.
	proceedValue := NonBooleanReceiver new
		object: self;
		signal: 'proceed for truth.'.
	^ proceedValue ~~ false
]

{ #category : #'dependents access' }
Object >> myDependents [
	"Private. Answer a list of all the receiver's dependents."

	^ DependentsFields at: self ifAbsent: []
]

{ #category : #'dependents access' }
Object >> myDependents: aCollectionOrNil [
	"Private. Set (or remove) the receiver's dependents list."

	aCollectionOrNil
		ifNil: [DependentsFields removeKey: self ifAbsent: []]
		ifNotNil: [DependentsFields at: self put: aCollectionOrNil]
]

{ #category : #testing }
Object >> name [
	"Answer a name for the receiver.  This is used generically in the title of certain inspectors, such as the referred-to inspector, and specificially by various subsystems.  By default, we let the object just print itself out..  "

	^ self printString
]

{ #category : #testing }
Object >> nameForViewer [
	"Answer a name to be shown in a Viewer that is viewing the receiver"

	| aName |
	(aName := self uniqueNameForReferenceOrNil) ifNotNil: [^ aName].
	(aName := self knownName) ifNotNil: [^ aName].

	^ [(self asString copyWithout: Character cr) truncateTo:  27] ifError:
		[:msg :rcvr | self class name printString]
]

{ #category : #debugging }
Object >> needsWork [
]

{ #category : #viewer }
Object >> newScriptorAround: aPhraseTileMorph [
	"Sprout a scriptor around aPhraseTileMorph, thus making a new script.  This is where generalized scriptors will be threaded in"

	^ nil
]

{ #category : #'user interface' }
Object >> newTileMorphRepresentative [
	^ TileMorph new setLiteral: self
]

{ #category : #printing }
Object >> nominallyUnsent: aSelectorSymbol [
	"From within the body of a method which is not formally sent within the system, but which you intend to have remain in the system (for potential manual invocation, or for documentation, or perhaps because it's sent by commented-out-code that you anticipate uncommenting out someday, send this message, with the selector itself as the argument.

This will serve two purposes:

	(1)  The method will not be returned by searches for unsent selectors (because it, in a manner of speaking, sends itself).
	(2)	You can locate all such methods by browsing senders of #nominallyUnsent:"

	false ifTrue: [self flag: #nominallyUnsent:]    "So that this method itself will appear to be sent"

]

{ #category : #'user interface' }
Object >> notYetImplemented [
	NotYetImplemented signal
	
]

{ #category : #updating }
Object >> noteSelectionIndex: anInteger for: aSymbol [
	"backstop"
]

{ #category : #'error handling' }
Object >> notify: aString [ 
	"Create and schedule a Notifier with the argument as the message in 
	order to request confirmation before a process can proceed."

	Warning signal: aString

	"nil notify: 'confirmation message'"
]

{ #category : #'error handling' }
Object >> notify: aString at: location [
	"Create and schedule a Notifier with the argument as the message in 
	order to request confirmation before a process can proceed. Subclasses can
	override this and insert an error message at location within aString."

	self notify: aString

	"nil notify: 'confirmation message' at: 12"
]

{ #category : #'error handling' }
Object >> notifyWithLabel: aString [ 
	"Create and schedule a Notifier with aString as the window label as well as the contents of the window, in  order to request confirmation before a process can proceed."

	self deprecated.
	self notify: aString.
	
	"nil notify: 'let us see if this works'"
]

{ #category : #'objects from disk' }
Object >> objectForDataStream: refStrm [
    "Return an object to store on an external data stream."

    ^ self
]

{ #category : #macpal }
Object >> objectRepresented [
	"most objects represent themselves; this provides a hook for aliases to grab on to"

	^ self
]

{ #category : #viewer }
Object >> offerViewerMenuFor: aViewer event: evt [
	"Offer the primary Viewer menu to the user.  Copied up from Player code, but most of the functions suggested here don't work for non-Player objects, many aren't even defined, some relate to exploratory sw work not yet reflected in the current corpus.  We are early in the life cycle of this method..."

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addStayUpItem.
	aMenu title: '**CAUTION -- UNDER CONSTRUCTION!**
Many things may not work!
', self nameForViewer.
	(aViewer affordsUniclass and: [self belongsToUniClass not]) ifTrue:
		[aMenu add: 'give me a Uniclass' action: #assureUniClass.
		aMenu addLine].
	aMenu add: 'choose vocabulary...' target: aViewer action: #chooseVocabulary.
	aMenu add: 'choose limit class...' target: aViewer action: #chooseLimitClass.
	aMenu add: 'add search pane' target: aViewer action: #addSearchPane.
	aMenu balloonTextForLastItem: 'Specify which class should be the most generic one to have its methods shown in this Viewer'.
	aMenu addLine.

	self belongsToUniClass ifTrue:
		[aMenu add: 'add a new instance variable' target: self selector: #addInstanceVariableIn: argument: aViewer.
		aMenu add: 'add a new script' target: aViewer selector: #newPermanentScriptIn: argument: aViewer.
		aMenu addLine.
		aMenu add: 'make my class be first-class' target: self selector: #makeFirstClassClassIn: argument: aViewer.
		aMenu add: 'move my changes up to my superclass' target: self action: #promoteChangesToSuperclass.
		aMenu addLine].

	aMenu add: 'tear off a tile' target: self selector: #launchTileToRefer.
	aMenu addLine.

	aMenu add: 'inspect me' target: self selector: #inspect.
	aMenu add: 'inspect my class' target: self class action: #inspect.
	aMenu addLine.

	aMenu add: 'browse vocabulary' action: #haveFullProtocolBrowsed.
	aMenu add: 'inspect this Viewer' target: aViewer action: #inspect.

	aMenu popUpEvent: evt in: aViewer currentWorld

"
	aMenu add: 'references to me' target: aViewer action: #browseReferencesToObject.
	aMenu add: 'toggle scratch pane' target: aViewer selector: #toggleScratchPane.
	aMenu add: 'make a nascent script for me' target: aViewer selector: #makeNascentScript.
	aMenu add: 'rename me' target: aViewer selector: #chooseNewNameForReference.
	aMenu add: 'browse full' action: #browseOwnClassFull.
	aMenu add: 'browse hierarchy' action: #browseOwnClassHierarchy.
	aMenu add: 'set user level...' target: aViewer action: #setUserLevel.
	aMenu add: 'browse sub-protocol' action: #browseOwnClassSubProtocol.
	aMenu addLine.

"
]

{ #category : #viewer }
Object >> offerViewerMenuForEvt: anEvent morph: aMorph [
	"Offer the viewer's primary menu to the user.  aMorph is some morph within the viewer itself, the one within which a mousedown triggered the need for this menu, and it is used only to retrieve the Viewer itself"

	self offerViewerMenuFor: (aMorph ownerThatIsA: StandardViewer) event: anEvent
]

{ #category : #updating }
Object >> okToChange [
	"Allows a controller to ask this of any model"
	^ true
]

{ #category : #updating }
Object >> okToClose [
	"Allows a controller to ask this of any model"
	^self okToChange
]

{ #category : #'system primitives' }
Object >> oopString [
	"Answer a string that represents the oop of the receiver.
	This method is for compatibility only, see comment for #asOop."

	^ self asOop printString
]

{ #category : #tracing }
Object >> outboundPointers [
"Answers a list of all objects I am causing not to be garbage-collected"

	| collection |
	collection := OrderedCollection new.
	self outboundPointersDo: [:ea | collection add: ea].
	^ collection
]

{ #category : #tracing }
Object >> outboundPointersDo: aBlock [
"do aBlock for every object I point to, exactly how the garbage collector would. Adapted from PointerFinder >> #followObject:"

	aBlock value: self class.
	1 to: self class instSize do: [:i | aBlock value: (self instVarAt: i)].
	1 to: self basicSize do: [:i | aBlock value: (self basicAt: i)].
]

{ #category : #'message handling' }
Object >> perform: aSymbol [ 
	"Send the unary selector, aSymbol, to the receiver.
	Fail if the number of arguments expected by the selector is not zero.
	Primitive. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 83>
	^ self perform: aSymbol withArguments: {}
]

{ #category : #'message handling' }
Object >> perform: selector orSendTo: otherTarget [
	"If I wish to intercept and handle selector myself, do it; else send it to otherTarget"
	^ (self respondsTo: selector) ifTrue: [self perform: selector] ifFalse: [otherTarget perform: selector]
]

{ #category : #'message handling' }
Object >> perform: aSymbol with: anObject [ 
	"Send the selector, aSymbol, to the receiver with anObject as its argument.
	Fail if the number of arguments expected by the selector is not one.
	Primitive. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 83>
	^ self perform: aSymbol withArguments: { anObject }
]

{ #category : #'message handling' }
Object >> perform: aSymbol with: firstObject with: secondObject [ 
	"Send the selector, aSymbol, to the receiver with the given arguments.
	Fail if the number of arguments expected by the selector is not two.
	Primitive. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 83>
	^ self perform: aSymbol withArguments: { firstObject. secondObject }
]

{ #category : #'message handling' }
Object >> perform: aSymbol with: firstObject with: secondObject with: thirdObject [ 
	"Send the selector, aSymbol, to the receiver with the given arguments.
	Fail if the number of arguments expected by the selector is not three.
	Primitive. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 83>
	^ self perform: aSymbol withArguments: { firstObject. secondObject. thirdObject }
]

{ #category : #'message handling' }
Object >> perform: aSymbol with: firstObject with: secondObject with: thirdObject with: fourthObject [
	"Send the selector, aSymbol, to the receiver with the given arguments.
	Fail if the number of arguments expected by the selector is not four.
	Primitive. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 83>
	^ self perform: aSymbol withArguments: { firstObject. secondObject. thirdObject. fourthObject }
]

{ #category : #'message handling' }
Object >> perform: aSymbol with: firstObject with: secondObject with: thirdObject with: fourthObject with: fifthObject [
	"Send the selector, aSymbol, to the receiver with the given arguments.
	Fail if the number of arguments expected by the selector is not five.
	Primitive. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 83>
	^ self perform: aSymbol withArguments: { firstObject. secondObject. thirdObject. fourthObject. fifthObject }
]

{ #category : #'message handling' }
Object >> perform: selector withArguments: argArray [ 
	"Send the selector, aSymbol, to the receiver with arguments in argArray.
	Fail if the number of arguments expected by the selector 
	does not match the size of argArray.
	Primitive. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 84>
	^ self perform: selector withArguments: argArray inSuperclass: self class
]

{ #category : #'message handling' }
Object >> perform: selector withArguments: argArray inSuperclass: lookupClass [
	"NOTE:  This is just like perform:withArguments:, except that
	the message lookup process begins, not with the receivers's class,
	but with the supplied superclass instead.  It will fail if lookupClass
	cannot be found among the receiver's superclasses.
	Primitive. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 100>
	(selector isSymbol)
		ifFalse: [^ self error: 'selector argument must be a Symbol'].
	(selector numArgs = argArray size)
		ifFalse: [^ self error: 'incorrect number of arguments'].
	(self class == lookupClass or: [self class inheritsFrom: lookupClass])
		ifFalse: [^ self error: 'lookupClass is not in my inheritance chain'].
	self primitiveFailed
]

{ #category : #'message handling' }
Object >> perform: selector withEnoughArguments: anArray [
	"Send selector to the receiver with arguments in anArray. Only use enough arguments for the arity of the selector; supply nils for missing ones."
	
	| numArgs args |
	(numArgs := selector numArgs) = anArray size 
		ifTrue: [ args := anArray asArray ]
		ifFalse: [
			args := Array new: numArgs.
			args 
				replaceFrom: 1
				to: (anArray size min: args size)
				with: anArray
				startingAt: 1 ].
	^self perform: selector withArguments: args
]

{ #category : #pinning }
Object >> pin [
	"The VM's garbage collector routinely moves objects as it reclaims and compacts
	 memory. But it can also pin an object so that it will not be moved, which can make
	 it easier to pass objects out through the FFI.  Objects are unpinnned when created.
	 This method ensures an object is pinned, and answers whether it was already pinned."
	^self setPinned: true
]

{ #category : #copying }
Object >> postCopy [
	"self is a shallow copy, subclasses should copy fields as necessary to complete the full copy"

	^ self
]

{ #category : #accessing }
Object >> presenter [
	"Answer the presenter object associated with the receiver.  For morphs, there is in effect a clear containment hierarchy of presenters (accessed via their association with PasteUpMorphs); for arbitrary objects the hook is simply via the current world, at least at present."

	^ self currentWorld presenter
]

{ #category : #'system primitives' }
Object >> primitiveChangeClassTo: anObject [
	"Primitive. Change the class of the receiver into the class of the argument given that the format of the receiver matches the format of the argument's class. Fail if receiver or argument are SmallIntegers, or the receiver is an instance of a compact class and the argument isn't, or when the argument's class is compact and the receiver isn't, or when the format of the receiver is different from the format of the argument's class, or when the arguments class is fixed and the receiver's size differs from the size that an instance of the argument's class should have.
	Note: The primitive will fail in most cases that you think might work. This is mostly because of a) the difference between compact and non-compact classes, and b) because of differences in the format. As an example, '(Array new: 3) primitiveChangeClassTo: Morph basicNew' would fail for three of the reasons mentioned above. Array is compact, Morph is not (failure #1). Array is variable and Morph is fixed (different format - failure #2). Morph is a fixed-field-only object and the array is too short (failure #3).
	The facility is really provided for certain, very specific applications (mostly related to classes changing shape) and not for casual use."

	<primitive: 115>
	self primitiveFailed
]

{ #category : #private }
Object >> primitiveError: aString [ 

	self flag: #discussion. "mt: Is this still required?"
	Project current primitiveError: aString.
]

{ #category : #'error handling' }
Object >> primitiveFailed [
	"Announce that a primitive has failed and there is no appropriate 
	Smalltalk code to run."

	self primitiveFailed: thisContext sender selector
]

{ #category : #'error handling' }
Object >> primitiveFailed: selector [
	"Announce that a primitive has failed and there is no appropriate 
	Smalltalk code to run."

	self error: selector asString, ' failed'
]

{ #category : #converting }
Object >> printDirectlyToDisplay [
	"For debugging: write the receiver's printString directly to the display at (0, 100); senders of this are detected by the check-for-slips mechanism."

	self asString displayAt: 0@100

"StringMorph someInstance printDirectlyToDisplay"
]

{ #category : #printing }
Object >> printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that  
	identifies the receiver."

	| title |
	title := self class name.
	aStream
		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: title
]

{ #category : #printing }
Object >> printString [
	"Answer a String whose characters are a description of the receiver. 
	If you want to print without a character limit, use fullPrintString."

	^ self printStringLimitedTo: 50000
]

{ #category : #printing }
Object >> printStringLimitedTo: limit [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString."
	| limitedString |
	limitedString := String streamContents: [:s | self printOn: s] limitedTo: limit.
	limitedString size < limit ifTrue: [^ limitedString].
	^ limitedString , '...etc...'
]

{ #category : #printing }
Object >> printWithClosureAnalysisOn: aStream [
	"Append to the argument, aStream, a sequence of characters that  
	identifies the receiver."

	| title |
	title := self class name.
	aStream
		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: title
]

{ #category : #undo }
Object >> purgeAllCommands [
	"Purge all commands for this object"
	Preferences useUndo ifFalse: [^ self]. "get out quickly"
	self commandHistory purgeAllCommandsSuchThat: [:cmd | cmd undoTarget == self].

]

{ #category : #'filter streaming' }
Object >> putOn:aStream [
	^aStream nextPut:self.

]

{ #category : #'objects from disk' }
Object >> readDataFrom: aDataStream size: varsOnDisk [
	"Fill in the fields of self based on the contents of aDataStream.  Return self.
	 Read in the instance-variables written by Object>>storeDataOn:.
	 NOTE: This method must send beginReference: before reading any objects from aDataStream that might reference it.
	 Allow aDataStream to have fewer inst vars.  See SmartRefStream."
	| cntInstVars cntIndexedVars |

	cntInstVars := self class instSize.
	self class isVariable
		ifTrue: [cntIndexedVars := varsOnDisk - cntInstVars.
				cntIndexedVars < 0 ifTrue: [
					self error: 'Class has changed too much.  Define a convertxxx method']]
		ifFalse: [cntIndexedVars := 0.
				cntInstVars := varsOnDisk]. 	"OK if fewer than now"

	aDataStream beginReference: self.
	1 to: cntInstVars do:
		[:i | self instVarAt: i put: aDataStream next].
	1 to: cntIndexedVars do:
		[:i | self basicAt: i put: aDataStream next].
	"Total number read MUST be equal to varsOnDisk!"
	^ self	"If we ever return something other than self, fix calls 
			on (super readDataFrom: aDataStream size: anInteger)"
]

{ #category : #accessing }
Object >> readFromString: aString [
	"Create an object based on the contents of aString."

	^self readFrom: (ReadStream on: aString)
]

{ #category : #undo }
Object >> redoFromCapturedState: st [ 
	"May be overridden in subclasses.  See also capturedState"

	self undoFromCapturedState: st  "Simple cases are symmetric"

]

{ #category : #undo }
Object >> refineRedoTarget: target selector: aSymbol arguments: arguments in: refineBlock [ 
	"Any object can override this method to refine its redo specification"

	^ refineBlock
		value: target
		value: aSymbol
		value: arguments
]

{ #category : #undo }
Object >> refineUndoTarget: target selector: aSymbol arguments: arguments in: refineBlock [ 
	"Any object can override this method to refine its undo specification"

	^ refineBlock
		value: target
		value: aSymbol
		value: arguments
]

{ #category : #macpal }
Object >> refusesToAcceptCode [
	"Answer whether the receiver is a code-bearing instrument which at the moment refuses to allow its contents to be submitted"

	^ false
	
]

{ #category : #'dependents access' }
Object >> release [
	"Remove references to objects that may refer to the receiver. This message 
	should be overridden by subclasses with any cycles, in which case the 
	subclass should also include the expression super release."

	self breakDependents.
	(self respondsTo: #releaseActionMap) ifTrue: [self releaseActionMap].
]

{ #category : #undo }
Object >> rememberCommand: aCommand [
	"Remember the given command for undo"
	Preferences useUndo ifFalse: [^ self]. "get out quickly"
	^ self commandHistory rememberCommand: aCommand
]

{ #category : #undo }
Object >> rememberUndoableAction: actionBlock named: caption [
	| cmd result |
	cmd := Command new cmdWording: caption.
	cmd undoTarget: self selector: #undoFromCapturedState: argument: self capturedState.
	result := actionBlock value.
	cmd redoTarget: self selector: #redoFromCapturedState: argument: self capturedState.
	self rememberCommand: cmd.
	^ result
]

{ #category : #'dependents access' }
Object >> removeDependent: anObject [
	"Remove the given object as one of the receiver's dependents."

	| dependents |
	dependents := self dependents reject: [:each | each == anObject].
	self myDependents: (dependents isEmpty ifFalse: [dependents]).
	^ anObject
]

{ #category : #'debugging-haltOnce' }
Object >> removeHaltCount [
	(self class environment includesKey: #HaltCount) ifTrue: [
		self class environment removeKey: #HaltCount]
]

{ #category : #testing }
Object >> renameInternal: newName [ 
	"Change the internal name (because of a conflict) but leave the external name unchanged.  Change Player class name, but do not change the names that appear in tiles.  Any object that might be pointed to in the References dictionary might get this message sent to it upon reload"

	^ nil	"caller will renameTo:.  new name may be different"
]

{ #category : #viewer }
Object >> renameScript: oldSelector [
	"prompt the user for a new selector and apply it.  Presently only works for players"

	self notYetImplemented
]

{ #category : #testing }
Object >> renameTo: newName [
	"If the receiver has an inherent idea about its own name, it should take action here.  Any object that might be pointed to in the References dictionary might get this message sent to it upon reload"
]

{ #category : #printing }
Object >> reportableSize [
	"Answer a string that reports the size of the receiver -- useful for showing in a list view, for example"

	^ (self basicSize + self class instSize) printString
]

{ #category : #'class membership' }
Object >> respondsTo: aSymbol [ 
	"Answer whether the method dictionary of the receiver's class contains 
	aSymbol as a message selector."

	^self class canUnderstand: aSymbol
]

{ #category : #finalization }
Object >> retryWithGC: execBlock until: testBlock [
	"Retry execBlock as long as testBlock returns false. Do an incremental GC after the first try, a full GC after the second try."
	| blockValue |
	blockValue := execBlock value.
	(testBlock value: blockValue) ifTrue:[^blockValue].
	Smalltalk garbageCollectMost.
	blockValue := execBlock value.
	(testBlock value: blockValue) ifTrue:[^blockValue].
	Smalltalk garbageCollect.
	^execBlock value.
]

{ #category : #'system primitives' }
Object >> rootStubInImageSegment: imageSegment [

	^ ImageSegmentRootStub new
		xxSuperclass: nil
		format: nil
		segment: imageSegment
]

{ #category : #'objects from disk' }
Object >> saveOnFile [
	"Ask the user for a filename and save myself on a SmartReferenceStream file.  Writes out the version and class structure.  The file is fileIn-able.  Does not file out the class of the object."

	| aFileName |
	aFileName := self class name asFileName.	"do better?"
	aFileName := UIManager default 
				saveFilenameRequest: 'File name?' translated initialAnswer: aFileName.
	aFileName ifNil: [^ Beeper beep].

	self saveOnFileNamed: aFileName
]

{ #category : #'objects from disk' }
Object >> saveOnFileNamed: filenameString [
	"Save myself on a SmartReferenceStream file.  Writes out the version and class structure.  The file is fileIn-able.  UniClasses will be filed out."
	| fileStream |
	fileStream := FileStream newFileNamed: filenameString.
	fileStream fileOutClass: nil andObject: self.	"Puts UniClass definitions out anyway, and closes the stream."
]

{ #category : #macpal }
Object >> scriptPerformer [

	^ self

]

{ #category : #accessing }
Object >> secureInfo [
"test"
^Smalltalk at: ('//SeInfo/', self identityHashString) asSymbol ifAbsentPut: [Dictionary new]

]

{ #category : #scripting }
Object >> selfWrittenAsIll [

	^self
]

{ #category : #scripting }
Object >> selfWrittenAsIm [

	^self
]

{ #category : #scripting }
Object >> selfWrittenAsMe [

	^self
]

{ #category : #scripting }
Object >> selfWrittenAsMy [

	^self
]

{ #category : #scripting }
Object >> selfWrittenAsThis [

	^self
]

{ #category : #'debugging-haltOnce' }
Object >> setHaltCountTo: int [
	Smalltalk at: #HaltCount put: int
]

{ #category : #'debugging-haltOnce' }
Object >> setHaltOnce [
	"Turn on the halt once flag."
	Smalltalk at: #HaltOnce put: true
]

{ #category : #private }
Object >> setPinned: aBoolean [
	"The VM's garbage collector routinely moves objects as it reclaims and compacts
	 memory. But it can also pin an object so that it will not be moved, which can make
	 it easier to pass objects out through the FFI.  Objects are unpinnned when created.
	 This primitive either pins or unpins an object, and answers if it was already pinned."
	<primitive: 184 error: ec>
	^self primitiveFailed
]

{ #category : #copying }
Object >> shallowCopy [
	"Answer a copy of the receiver which shares the receiver's instance variables."

	<primitive: 148 error: ec>
	| class newObject |
	ec == #'insufficient object memory' ifFalse:
		[^self primitiveFailed].
	"If the primitive fails due to insufficient memory, instantiate via basicNew: to invoke
	 the garbage collector before retrying, and use copyFrom: to copy state."
	newObject := (class := self class) isVariable
					ifTrue: 
						[class isCompiledMethodClass
							ifTrue:
								[class newMethod: self basicSize - self initialPC + 1 header: self header]
							ifFalse:
								[class basicNew: self basicSize]]
					ifFalse:
						[class basicNew].
	^newObject copyFrom: self
]

{ #category : #'error handling' }
Object >> shouldBeImplemented [
	"Announce that this message should be implemented"

	^ NotImplemented signal: ('{1} or a superclass should implement {2}' format: {self className. thisContext sender selector})
]

{ #category : #testing }
Object >> shouldBePrintedAsLiteral [

	^self isLiteral
]

{ #category : #testing }
Object >> shouldBePrintedAsLiteralVisiting: aSet [

	^self isLiteral
]

{ #category : #'error handling' }
Object >> shouldNotImplement [
	"Announce that, although the receiver inherits this message, it should 
	not implement it."

	NotImplemented signal: ('{1} is not a message appropriate for a {2}' format: {thisContext sender selector. self className}).
]

{ #category : #testing }
Object >> showDiffs [
	"Answer whether the receiver, serving as the model of a text-bearing entity, is 'showing differences' -- if it is, the editor may wish to show special feedback"

	^ false
]

{ #category : #accessing }
Object >> size [
	"Primitive. Answer the number of indexable variables in the receiver. 
	This value is the same as the largest legal subscript. Essential. See Object 
	documentation whatIsAPrimitive."

	<primitive: 62>
	self class isVariable ifFalse: [self errorNotIndexable].
	^ 0
]

{ #category : #macpal }
Object >> slotInfo [
	"Answer a list of slot-information objects.  Initally only provides useful info for players"

	^ Dictionary new
]

{ #category : #'system primitives' }
Object >> someObject [
	"Primitive. Answer the first object in the enumeration of all
	 objects."

	<primitive: 138>
	self primitiveFailed.
]

{ #category : #private }
Object >> species [
	"Answer the preferred class for reconstructing the receiver.  For example, 
	collections create new collections whenever enumeration messages such as 
	collect: or select: are invoked.  The new kind of collection is determined by 
	the species of the original collection.  Species and class are not always the 
	same.  For example, the species of Interval is Array."
	<primitive: 111>
	^self class
]

{ #category : #testing }
Object >> stepAt: millisecondClockValue in: aWindow [

	^ self stepIn: aWindow
]

{ #category : #testing }
Object >> stepIn: aWindow [

	^ self step
]

{ #category : #testing }
Object >> stepTime [
	
	^ 1000 "milliseconds -- default backstop for objects serving as models of system windows"
]

{ #category : #testing }
Object >> stepTimeIn: aSystemWindow [
	
	^ 1000 "milliseconds -- default backstop for objects serving as models of system windows"
]

{ #category : #private }
Object >> storeAt: offset inTempFrame: aContext [
	"This message had to get sent to an expression already on the stack
	as a Block argument being accessed by the debugger.
	Just re-route it to the temp frame."
	^ aContext tempAt: offset put: self
]

{ #category : #'objects from disk' }
Object >> storeDataOn: aDataStream [
	"Store myself on a DataStream.  Answer self.  This is a low-level DataStream/ReferenceStream method. See also objectToStoreOnDataStream.  NOTE: This method must send 'aDataStream beginInstance:size:' and then (nextPut:/nextPutWeak:) its subobjects.  readDataFrom:size: reads back what we write here."
	| cntInstVars cntIndexedVars |

	cntInstVars := self class instSize.
	cntIndexedVars := self basicSize.
	aDataStream
		beginInstance: self xxxClass
		size: cntInstVars + cntIndexedVars.
	1 to: cntInstVars do:
		[:i | aDataStream nextPut: (self instVarAt: i)].

	"Write fields of a variable length object.  When writing to a dummy 
		stream, don't bother to write the bytes"
	((aDataStream byteStream class == DummyStream) and: [self class isBits]) ifFalse: [
		1 to: cntIndexedVars do:
			[:i | aDataStream nextPut: (self basicAt: i)]].

]

{ #category : #printing }
Object >> storeOn: aStream [ 
	"Append to the argument aStream a sequence of characters that is an 
	expression whose evaluation creates an object similar to the receiver."

	aStream nextPut: $(.
	self class isVariable
		ifTrue: [aStream nextPutAll: '(', self class name, ' basicNew: ';
					store: self basicSize;
					nextPutAll: ') ']
		ifFalse: [aStream nextPutAll: self class name, ' basicNew'].
	1 to: self class instSize do:
		[:i |
		aStream nextPutAll: ' instVarAt: ';
			store: i;
			nextPutAll: ' put: ';
			store: (self instVarAt: i);
			nextPut: $;].
	1 to: self basicSize do:
		[:i |
		aStream nextPutAll: ' basicAt: ';
			store: i;
			nextPutAll: ' put: ';
			store: (self basicAt: i);
			nextPut: $;].
	aStream nextPutAll: ' yourself)'

]

{ #category : #printing }
Object >> storeString [
	"Answer a String representation of the receiver from which the receiver 
	can be reconstructed."

	^ String streamContents: [:s | self storeOn: s]
]

{ #category : #printing }
Object >> stringForReadout [
	^ self stringRepresentation
]

{ #category : #printing }
Object >> stringRepresentation [
	"Answer a string that represents the receiver.  For most objects this is simply its printString, but for strings themselves, it's themselves.  6/12/96 sw"

	^ self printString 
]

{ #category : #'error handling' }
Object >> subclassResponsibility [
	"This message sets up a framework for the behavior of the class' subclasses.
	Announce that the subclass should have implemented this message."
	^ SubclassResponsibility
		signal: ('My {1} subclass should have overridden {2}'
			format: {self className. thisContext sender selector}).
]

{ #category : #viewer }
Object >> tilePhrasesForCategory: aCategorySymbol inViewer: aViewer [
	"Return a collection of phrases for the category."

	| interfaces |
	interfaces := self methodInterfacesForCategory: aCategorySymbol inVocabulary: aViewer currentVocabulary limitClass: aViewer limitClass.
	interfaces := self methodInterfacesInPresentationOrderFrom: interfaces forCategory: aCategorySymbol.
	^ self tilePhrasesForMethodInterfaces: interfaces inViewer: aViewer
]

{ #category : #viewer }
Object >> tileToRefer [
	"Answer a reference tile that comprises an alias to me"

	^ TileMorph new setToReferTo: self
]

{ #category : #'debugging-haltOnce' }
Object >> toggleHaltOnce [
	self haltOnceEnabled
		ifTrue: [self clearHaltOnce]
		ifFalse: [self setHaltOnce]
]

{ #category : #'error handling' }
Object >> traitConflict [
	self error: 'A class or trait does not properly resolve a conflict between multiple traits it uses.'
]

{ #category : #undo }
Object >> undoFromCapturedState: st [ 
	"May be overridden in subclasses.  See also capturedState"

	self copyFrom: st

]

{ #category : #viewer }
Object >> uniqueInstanceVariableNameLike: aString excluding: takenNames [
	"Answer a nice instance-variable name to be added to the receiver which resembles aString, making sure it does not coincide with any element in takenNames"

	| okBase uniqueName usedNames |
	usedNames := self class allInstVarNamesEverywhere.
	usedNames removeAllFoundIn: self class instVarNames.
	usedNames addAll: takenNames.
	okBase := Scanner wellFormedInstanceVariableNameFrom: aString.

	uniqueName := Utilities keyLike: okBase satisfying: 
		[:aKey | (usedNames includes: aKey) not].

	^ uniqueName
]

{ #category : #viewer }
Object >> uniqueNameForReference [
	"Answer a nice name by which the receiver can be referred to by other objects.  At present this uses a global References dictionary to hold the database of references, but in due course this will need to acquire some locality"

	| aName stem knownClassVars |
	(aName := self uniqueNameForReferenceOrNil) ifNotNil: [^ aName].
	(stem := self knownName) ifNil:
		[stem := self defaultNameStemForInstances asString].
	stem := stem select: [:ch | ch isLetter or: [ch isDigit]].
	stem size = 0 ifTrue: [stem := 'A'].
	stem first isLetter ifFalse:
		[stem := 'A', stem].
	stem := stem capitalized.
	knownClassVars := ScriptingSystem allKnownClassVariableNames.
	aName := Utilities keyLike:  stem satisfying:
		[:jinaLake |
			| nameSym |
			nameSym := jinaLake asSymbol.
			 ((References includesKey:  nameSym) not and:
				[(Smalltalk includesKey: nameSym) not]) and:
						[(knownClassVars includes: nameSym) not]].

	References at: (aName := aName asSymbol) put: self.
	^ aName
]

{ #category : #viewer }
Object >> uniqueNameForReferenceOrNil [

	^ nil.

]

{ #category : #pinning }
Object >> unpin [
	"The VM's garbage collector routinely moves objects as it reclaims and compacts
	 memory. But it can also pin an object so that it will not be moved, which can make
	 it easier to pass objects out through the FFI.  Objects are unpinnned when created.
	 This method ensures an object is unpinned, and answers whether it was pinned."
	^self setPinned: false
]

{ #category : #updating }
Object >> update: aParameter [ 
	"Receive a change notice from an object of whom the receiver is a 
	dependent. The default behavior is to do nothing; a subclass might want 
	to change itself in some way."

	^ self
]

{ #category : #updating }
Object >> update: anAspect with: anObject [
	"Receive a change notice from an object of whom the receiver is a 
	dependent. The default behavior is to call update:,
	which by default does nothing; a subclass might want 
	to change itself in some way."

	^ self update: anAspect
]

{ #category : #updating }
Object >> updateListsAndCodeIn: aWindow [
	self canDiscardEdits ifFalse: [^ self].
	aWindow updatablePanes do: [:aPane | aPane verifyContents]
]

{ #category : #viewer }
Object >> updateThresholdForGraphicInViewerTab [
	"When a Viewer is open on the receiver, its tab needs some graphic to show to the user. Computing this graphic can take quite some time so we want to make the update frequency depending on how long it takes to compute the thumbnail. The threshold returned by this method defines that the viewer will update at most every 'threshold * timeItTakesToDraw' milliseconds. Thus, if the time for computing the receiver's thumbnail is 200 msecs and the the threshold is 10, the viewer will update at most every two seconds."
	^20 "seems to be a pretty good general choice"
]

{ #category : #viewer }
Object >> usableMethodInterfacesIn: aListOfMethodInterfaces [
	"Filter aList, returning a subset list of apt phrases"

	^ aListOfMethodInterfaces

]

{ #category : #evaluating }
Object >> value [

	^self
]

{ #category : #evaluating }
Object >> valueWithArguments: aSequenceOfArguments [

	^self
]

{ #category : #copying }
Object >> veryDeepCopy [
	"Do a complete tree copy using a dictionary. An object in the tree twice is only copied once. All references to the object in the copy of the tree will point to the new copy."

	| copier new |
	copier := DeepCopier new: self initialDeepCopierSize.
	new := self veryDeepCopyWith: copier.
	copier mapUniClasses.
	copier references associationsDo: [:assoc | 
		assoc value veryDeepFixupWith: copier].
	copier fixDependents.
	^ new
]

{ #category : #copying }
Object >> veryDeepCopySibling [
	"Do a complete tree copy using a dictionary.  Substitute a clone of oldPlayer for the root.  Normally, a Player or non systemDefined object would have a new class.  We do not want one this time.  An object in the tree twice, is only copied once.  All references to the object in the copy of the tree will point to the new copy."

	| copier new |
	copier := DeepCopier new: self initialDeepCopierSize.
	copier newUniClasses: false.
	new := self veryDeepCopyWith: copier.
	copier mapUniClasses.
	copier references associationsDo: [:assoc | 
		assoc value veryDeepFixupWith: copier].
	copier fixDependents.
	^ new
]

{ #category : #copying }
Object >> veryDeepCopyUsing: copier [
	"Do a complete tree copy using a dictionary.  An object in the tree twice is only copied once.  All references to the object in the copy of the tree will point to the new copy.
	Same as veryDeepCopy except copier (with dictionary) is supplied.
	** do not delete this method, even if it has no callers **"

	| new refs |
	new := self veryDeepCopyWith: copier.
	copier mapUniClasses.
	copier references associationsDo: [:assoc | 
		assoc value veryDeepFixupWith: copier].
	"Fix dependents"
	refs := copier references.
	DependentsFields associationsDo: [:pair |
		pair value do: [:dep | 
			| newDep newModel |
			(newDep := refs at: dep ifAbsent: [nil]) ifNotNil: [
				newModel := refs at: pair key ifAbsent: [pair key].
				newModel addDependent: newDep]]].
	^ new
]

{ #category : #copying }
Object >> veryDeepCopyWith: deepCopier [
	"Copy me and the entire tree of objects I point to.  An object in the tree twice is copied once, and both references point to him.  deepCopier holds a dictionary of objects we have seen.  Some classes refuse to be copied.  Some classes are picky about which fields get deep copied."
	| class index sub subAss new uc sup has mine |
	deepCopier references at: self ifPresent: [:newer | ^ newer]. 	"already did him"
	class := self class.
	class isMeta ifTrue: [^ self].		"a class"
	new := self shallowCopy.
	(class isSystemDefined not and: [deepCopier newUniClasses "allowed"]) ifTrue: [
		uc := deepCopier uniClasses at: class ifAbsent: [nil].
		uc ifNil: [
			deepCopier uniClasses at: class put: (uc := self copyUniClassWith: deepCopier).
			deepCopier references at: class put: uc].	"remember"
		new := uc new.
		new copyFrom: self].	"copy inst vars in case any are weak"
	deepCopier references at: self put: new.	"remember"
	(class isVariable and: [class isPointers]) ifTrue: 
		[index := self basicSize.
		[index > 0] whileTrue: 
			[sub := self basicAt: index.
			(subAss := deepCopier references associationAt: sub ifAbsent: [nil])
				ifNil: [new basicAt: index put: (sub veryDeepCopyWith: deepCopier)]
				ifNotNil: [new basicAt: index put: subAss value].
			index := index - 1]].
	"Ask each superclass if it wants to share (weak copy) any inst vars"
	new veryDeepInner: deepCopier.		"does super a lot"

	"other superclasses want all inst vars deep copied"
	sup := class.  index := class instSize.
	[has := sup compiledMethodAt: #veryDeepInner: ifAbsent: [nil].
	has := has ifNil: [class isSystemDefined not "is a uniClass"] ifNotNil: [true].
	mine := sup instVarNames.
	has ifTrue: [index := index - mine size]	"skip inst vars"
		ifFalse: [1 to: mine size do: [:xx |
				sub := self instVarAt: index.
				(subAss := deepCopier references associationAt: sub ifAbsent: [nil])
						"use association, not value, so nil is an exceptional value"
					ifNil: [new instVarAt: index put: 
								(sub veryDeepCopyWith: deepCopier)]
					ifNotNil: [new instVarAt: index put: subAss value].
				index := index - 1]].
	(sup := sup superclass) == nil] whileFalse.
	new rehash.	"force Sets and Dictionaries to rehash"
	^ new

]

{ #category : #copying }
Object >> veryDeepFixupWith: deepCopier [
	"I have no fields and no superclass.  Catch the super call."

]

{ #category : #copying }
Object >> veryDeepInner: deepCopier [
	"No special treatment for inst vars of my superclasses.  Override when some need to be weakly copied.  Object>>veryDeepCopyWith: will veryDeepCopy any inst var whose class does not actually define veryDeepInner:"

]

{ #category : #testing }
Object >> vocabularyDemanded [
	"Answer a vocabulary that the receiver insists be used when it is looked at in a Viewer.  This allows specific classes to insist on specific custom vocabularies"

	^ nil
]

{ #category : #testing }
Object >> wantsDiffFeedback [
	"Answer whether the receiver, serving as the model of a text-bearing entity, would like for 'diffs' green pane-border feedback to be shown"

	^ false
]

{ #category : #'drag and drop' }
Object >> wantsDroppedMorph: aMorph event: anEvent inMorph: destinationLM [ 
	^false
]

{ #category : #testing }
Object >> wantsSteps [
	"Overridden by morphic classes whose instances want to be stepped,
	or by model classes who want their morphic views to be stepped."

	^ false
]

{ #category : #testing }
Object >> wantsStepsIn: aSystemWindow [
	
	^ self wantsSteps
]

{ #category : #events }
Object >> when: anEventSelector
send: aMessageSelector
to: anObject [
 
    self
        when: anEventSelector
        evaluate: (WeakMessageSend
            receiver: anObject
            selector: aMessageSelector)
]

{ #category : #events }
Object >> when: anEventSelector
send: aMessageSelector
to: anObject
with: anArg [
 
    self
        when: anEventSelector
        evaluate: (WeakMessageSend
            receiver: anObject
            selector: aMessageSelector
		arguments: (Array with: anArg))
]

{ #category : #events }
Object >> when: anEventSelector
send: aMessageSelector
to: anObject
withArguments: anArgArray [
 
    self
        when: anEventSelector
        evaluate: (WeakMessageSend
            receiver: anObject
            selector: aMessageSelector
		arguments: anArgArray)
]

{ #category : #'user interface' }
Object >> windowActiveOnFirstClick [
	"Return true if my window should be active on first click."

	^ false
]

{ #category : #updating }
Object >> windowIsClosing [
	"This message is used to inform a models that its window is closing. Most models do nothing, but some, such as the Debugger, must do some cleanup. Note that this mechanism must be used with care by models that support multiple views, since one view may be closed while others left open."

]

{ #category : #'user interface' }
Object >> windowReqNewLabel: labelString [
	"My window's title has been edited.
	Return true if this is OK, and override for further behavior."

	^ true
]

{ #category : #'message handling' }
Object >> with: arg1 executeMethod: compiledMethod [
	"Execute compiledMethod against the receiver and arg1"

	<primitive: 189>
	^ self withArgs: {arg1} executeMethod: compiledMethod
]

{ #category : #'message handling' }
Object >> with: arg1 with: arg2 executeMethod: compiledMethod [
	"Execute compiledMethod against the receiver and arg1 & arg2"

	<primitive: 189>
	^ self withArgs: {arg1. arg2} executeMethod: compiledMethod
]

{ #category : #'message handling' }
Object >> with: arg1 with: arg2 with: arg3 executeMethod: compiledMethod [
	"Execute compiledMethod against the receiver and arg1, arg2, & arg3"

	<primitive: 189>
	^ self withArgs: {arg1. arg2. arg3} executeMethod: compiledMethod
]

{ #category : #'message handling' }
Object >> with: arg1 with: arg2 with: arg3 with: arg4 executeMethod: compiledMethod [
	"Execute compiledMethod against the receiver and arg1, arg2, arg3, & arg4"

	<primitive: 189>
	^ self withArgs: {arg1. arg2. arg3. arg4} executeMethod: compiledMethod
]

{ #category : #'message handling' }
Object >> withArgs: argArray executeMethod: compiledMethod [
	"Execute compiledMethod against the receiver and args in argArray"

	| selector |
	<primitive: 188>
	selector := Symbol new.
	self class addSelectorSilently: selector withMethod: compiledMethod.
	^ [self perform: selector withArguments: argArray]
		ensure: [self class basicRemoveSelector: selector]
]

{ #category : #converting }
Object >> withoutListWrapper [

	^self
]

{ #category : #'filter streaming' }
Object >> writeOnFilterStream:aStream [
	aStream writeObject:self.

]

{ #category : #'class membership' }
Object >> xxxClass [
	"For subclasses of nil, such as ObjectOut"
	^ self class
]

{ #category : #accessing }
Object >> yourself [
	"Answer self."
	^self
]

{ #category : #comparing }
Object >> ~= anObject [ 
	"Answer whether the receiver and the argument do not represent the 
	same object."

	^self = anObject == false
]
