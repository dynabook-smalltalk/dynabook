Extension { #name : #Process }

{ #category : #'*System-debugging support' }
Process >> clearErrorRecursionFlag [

	self environmentAt: #errorRecursionFlag put: false.
]

{ #category : #'*System-debugging' }
Process >> debug [

	^ self debugWithTitle: 'Debug'
]

{ #category : #'*System-debugging' }
Process >> debug: context [

	^ self debug: context title: 'Debug'
]

{ #category : #'*System-debugging' }
Process >> debug: context title: title [
	"Open debugger on self with context shown on top"

	^ self debug: context title: title full: false

]

{ #category : #'*System-debugging' }
Process >> debug: context title: title full: bool [

	^ self
		debug: context
		title: title
		full: bool
		contents: nil
]

{ #category : #'*System-debugging' }
Process >> debug: context title: title full: bool contents: contents [
	"Open debugger on self with context shown on top"

	| topCtxt |
	topCtxt := self isActiveProcess ifTrue: [thisContext] ifFalse: [self suspendedContext].
	(topCtxt hasContext: context) ifFalse: [^ self error: 'context not in process'].
	^ ToolSet debugProcess: self context: context label: title contents: contents fullView: bool
]

{ #category : #'*System-debugging' }
Process >> debugWithTitle: title [

	^ self debugWithTitle: title full: true
]

{ #category : #'*System-debugging' }
Process >> debugWithTitle: title full: aBoolean [

	^ self debugWithTitle: title full: aBoolean contents: nil
]

{ #category : #'*System-debugging' }
Process >> debugWithTitle: title full: bool contents: contents [
	"Automatically choose the top context."

	^ self
		debug: (self isActiveProcess ifTrue: [thisContext] ifFalse: [self suspendedContext])
		title: title
		full: bool
		contents: contents
]

{ #category : #'*System-debugging' }
Process class >> forBlock: aBlock [
	"Create a process and step into the block's method."
	
	^ self
		forBlock: aBlock
		runUntil: [:context | context method == aBlock method]
]

{ #category : #'*System-debugging' }
Process class >> forBlock: aBlock runUntil: aConditionBlock [
	"Create a process for the given block. Simulate code execution until the provided condition is fulfilled."

	^ aBlock newProcess
		runUntil: aConditionBlock;
		yourself
]

{ #category : #'*System-debugging' }
Process class >> forMethod: aCompiledMethod receiver: anObject [
	"Create a process and step into the method."
	
	^ self
		forBlock: [aCompiledMethod valueWithReceiver: anObject arguments: {}]
		runUntil: [:context | context method == aCompiledMethod]
]

{ #category : #'*System-debugging' }
Process class >> forMethod: aCompiledMethod receiver: anObject arguments: someArguments [
	"Create a process and step into the method."
	
	^ self
		forBlock: [aCompiledMethod valueWithReceiver: anObject arguments: someArguments]
		runUntil: [:context | context method == aCompiledMethod]
]

{ #category : #'*System-debugging' }
Process class >> forMethod: aCompiledMethod receiver: anObject arguments: someArguments runUntil: aConditionBlock [

	^ self
		forBlock: [aCompiledMethod valueWithReceiver: anObject arguments: someArguments]
		runUntil: aConditionBlock
]

{ #category : #'*System-debugging support' }
Process >> hasRecursiveError [

	^ self environmentAt: #errorRecursionFlag ifAbsent: [false]
]

{ #category : #'*System-debugging support' }
Process >> runUntil: aConditionBlock [
	"Simulate code execution until the provided condition is fulfilled."
	
	[(aConditionBlock isNil
		or: [self isTerminated])
		or: [aConditionBlock value: self suspendedContext]
	] whileFalse: [self step].

	"If we are already at a send, this next call should do nothing."
	self stepToSendOrReturn.
]

{ #category : #'*System-debugging support' }
Process >> setErrorRecursionFlag [

	self environmentAt: #errorRecursionFlag put: true.
]

{ #category : #'*System-debugging support' }
Process >> shouldResumeFromDebugger [
	"Tools can construct processes that might interfere with existing ones. For example, one process can be copied for inspecting the state through that copy later on. Resuming both - original and copy - at some point might result in unexpected interference. To prevent or help In such situations, the copy can be flagged to not be resumable from the debugger. Note that you can always resume a process with #resume even if a tool tells you otherwise."
	 
	^ self environmentAt: #shouldResumeFromDebugger ifAbsent: [true]
]

{ #category : #'*System-debugging support' }
Process >> shouldResumeFromDebugger: aBoolean [
	 
	self environmentAt: #shouldResumeFromDebugger put: aBoolean.
]
