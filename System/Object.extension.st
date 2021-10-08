Extension { #name : #Object }

{ #category : #'*System-Object Events-accessing' }
Object >> actionForEvent: anEventSelector [
    "Answer the action to be evaluated when <anEventSelector> has been triggered."

	^self actionMap
		at: anEventSelector asSymbol
		ifAbsent: [nil]
]

{ #category : #'*System-Object Events-accessing' }
Object >> actionForEvent: anEventSelector
ifAbsent: anExceptionBlock [
    "Answer the action to be evaluated when <anEventSelector> has been triggered."

	| actions |
	actions := self actionMap
		at: anEventSelector asSymbol
		ifAbsent: [nil].
	^actions ifNil: [anExceptionBlock value]
]

{ #category : #'*System-Object Events-accessing' }
Object >> actionMap [

	^EventManager actionMapFor: self
]

{ #category : #'*System-Object Events-accessing' }
Object >> actionSequenceForEvent: anEventSelector [

    ^(self actionMap
        at: anEventSelector asSymbol
        ifAbsent: [^WeakActionSequence new])
            asActionSequence
]

{ #category : #'*System-Object Events-accessing' }
Object >> actionsDo: aBlock [

	self actionMap do: aBlock
]

{ #category : #'*System-Change Notification-events' }
Object >> actionsWithReceiver: anObject forEvent: anEventSelector [

	^(self actionSequenceForEvent: anEventSelector)
                select: [:anAction | anAction receiver == anObject ]
]

{ #category : #'*System-Preferences' }
Object >> applyUserInterfaceTheme [
	"A new UserInterfaceTheme has been asked to #apply itself onto the current desktop.  The receiver should do what is necessary to change its colors on the screen, update its fonts, form images, etc., if the current UserInterfaceTheme specifies overrides for those values.
	
	Only subclasses which implement new #themeProperties on the class-side should implement this method.
	Implementors of this method should not call 'super applyUserInterfaceTheme'.

	The default implementation does nothing."
]

{ #category : #'*System-Change Notification-converting' }
Object >> asActionSequence [

	^WeakActionSequence with: self
]

{ #category : #'*System-Change Notification-converting' }
Object >> asActionSequenceTrappingErrors [

	^WeakActionSequenceTrappingErrors with: self
]

{ #category : #'*System-Tools-breakpoint' }
Object >> break [
	"This is a simple message to use for inserting breakpoints during debugging.
	The debugger is opened by sending a signal. This gives a chance to restore
	invariants related to multiple processes."

	BreakPoint signal.

	"nil break."
]

{ #category : #'*System-Preferences' }
Object >> canApplyUserInterfaceTheme [
	"Use this hook to control whether you want to get notified if a new theme gets applied."

	^ true
]

{ #category : #'*System-Object Events-accessing' }
Object >> createActionMap [

	^IdentityDictionary new
]

{ #category : #'*System-Finalization' }
Object >> finalizationRegistry [
	"Answer the finalization registry associated with the receiver."
	^WeakRegistry default
]

{ #category : #'*System-Object Events-class initialization' }
Object class >> flushEvents [
	"Object flushEvents"

	EventManager flushEvents. 
]

{ #category : #'*System-Object Events-accessing' }
Object >> hasActionForEvent: anEventSelector [
    "Answer true if there is an action associated with anEventSelector"

    ^(self actionForEvent: anEventSelector) notNil
]

{ #category : #'*System-Finalization' }
Object >> hasMultipleExecutors [
	"All objects, except ObjectFinalizerCollection instances should answer false to this message"
	^ false
]

{ #category : #'*system-support' }
Object >> isPrimitiveError [
	"Answer if the receiver is an error object returned by a primitive."
	^false
]

{ #category : #'*System-Localization-locales' }
Object >> localeChanged [
	"Can react to changed locales"
]

{ #category : #'*System-Localization-locales' }
Object >> localeChangedGently [
	self localeChanged.
]

{ #category : #'*System-Object Events-accessing-removing' }
Object >> releaseActionMap [

	EventManager releaseActionMapFor: self
]

{ #category : #'*System-Object Events-accessing-removing' }
Object >> removeAction: anAction
forEvent: anEventSelector [

    self
        removeActionsSatisfying: [:action | action = anAction]
        forEvent: anEventSelector
]

{ #category : #'*System-Object Events-accessing-removing' }
Object >> removeActionsForEvent: anEventSelector [

    | map |
    map := self actionMap.
    map removeKey: anEventSelector asSymbol ifAbsent: [].
    map isEmpty
        ifTrue: [self releaseActionMap]
]

{ #category : #'*System-Object Events-accessing-removing' }
Object >> removeActionsSatisfying: aBlock [

	self actionMap keys do:
		[:eachEventSelector |
			self
   				removeActionsSatisfying: aBlock
				forEvent: eachEventSelector
		]
]

{ #category : #'*System-Object Events-accessing-removing' }
Object >> removeActionsSatisfying: aOneArgBlock 
forEvent: anEventSelector [

    self
        setActionSequence:
            ((self actionSequenceForEvent: anEventSelector)
                reject: aOneArgBlock)
        forEvent: anEventSelector
]

{ #category : #'*System-Object Events-accessing-removing' }
Object >> removeActionsWithReceiver: anObject [

	self actionMap copy keysDo:
		[:eachEventSelector |
			self
   				removeActionsSatisfying: [:anAction | anAction receiver == anObject]
				forEvent: eachEventSelector
		]
]

{ #category : #'*System-Object Events-accessing-removing' }
Object >> removeActionsWithReceiver: anObject
forEvent: anEventSelector [

    self
        removeActionsSatisfying:
            [:anAction |
            anAction receiver == anObject]
        forEvent: anEventSelector
]

{ #category : #'*System-Change Notification-events' }
Object >> renameActionsWithReceiver: anObject forEvent: anEventSelector toEvent: newEvent [

	| oldActions newActions |
	oldActions := Set new.
	newActions := Set new.
	(self actionSequenceForEvent: anEventSelector) do: [ :action |
		action receiver == anObject
			ifTrue: [ oldActions add: anObject ]
			ifFalse: [ newActions add: anObject ]].
	self setActionSequence: (ActionSequence withAll: newActions) forEvent: anEventSelector.
	oldActions do: [ :act | self when: newEvent evaluate: act ].
]

{ #category : #'*System-Object Events-accessing' }
Object >> setActionSequence: actionSequence
forEvent: anEventSelector [

	| action |
	"This is a good time to compact the action sequence of old, garbage collected stuff."
	action := actionSequence asMinimalRepresentation.
	action
		ifNil: [ self removeActionsForEvent: anEventSelector]
		ifNotNil: [
			self updateableActionMap
				at: anEventSelector asSymbol
				put: action]
]

{ #category : #'*system-support' }
Object >> systemNavigation [

	^ SystemNavigation for: self environment
]

{ #category : #'*System-Preferences' }
Object class >> themeProperties [
	"Return a list of triples that describe configurable properties in a theme."
	^ {}
]

{ #category : #'*System-Finalization' }
Object >> toFinalizeSend: aSelector to: aFinalizer with: aResourceHandle [
	"When I am finalized (e.g., garbage collected) close the associated resource handle by sending aSelector to the appropriate finalizer (the guy who knows how to get rid of the resource).
	WARNING: Neither the finalizer nor the resource handle are allowed to reference me. If they do, then I will NEVER be garbage collected. Since this cannot be validated here, it is up to the client to make sure this invariant is not broken."
	self == aFinalizer ifTrue:[self error: 'I cannot finalize myself'].
	self == aResourceHandle ifTrue:[self error: 'I cannot finalize myself'].
	^self finalizationRegistry add: self executor:
		(ObjectFinalizer
			receiver: aFinalizer
			selector: aSelector
			argument: aResourceHandle)
]

{ #category : #'*System-Localization-locales' }
Object >> translatedNoop [
	"This is correspondence gettext_noop() in gettext."
	^ self

]

{ #category : #'*System-Object Events-accessing-triggering' }
Object >> triggerEvent: anEventSelector [
	"Evaluate all actions registered for <anEventSelector>. Return the value of the last registered action."

    ^(self actionForEvent: anEventSelector) value
]

{ #category : #'*System-Object Events-accessing-triggering' }
Object >> triggerEvent: anEventSelector
ifNotHandled: anExceptionBlock [
	"Evaluate all actions registered for <anEventSelector>. Return the value of the last registered action."

    ^(self 
		actionForEvent: anEventSelector
		ifAbsent: [^anExceptionBlock value]) value

]

{ #category : #'*System-Object Events-accessing-triggering' }
Object >> triggerEvent: anEventSelector
with: anObject [

    ^self 
		triggerEvent: anEventSelector
		withArguments: (Array with: anObject)
]

{ #category : #'*System-Object Events-accessing-triggering' }
Object >> triggerEvent: anEventSelector
with: anObject
ifNotHandled: anExceptionBlock [

    ^self 
		triggerEvent: anEventSelector
		withArguments: (Array with: anObject)
		ifNotHandled: anExceptionBlock
]

{ #category : #'*System-Object Events-accessing-triggering' }
Object >> triggerEvent: anEventSelector
withArguments: anArgumentList [

    ^(self actionForEvent: anEventSelector)
        valueWithArguments: anArgumentList
]

{ #category : #'*System-Object Events-accessing-triggering' }
Object >> triggerEvent: anEventSelector
withArguments: anArgumentList
ifNotHandled: anExceptionBlock [

    ^(self 
		actionForEvent: anEventSelector
		ifAbsent: [^anExceptionBlock value])
        valueWithArguments: anArgumentList
]

{ #category : #'*System-Object Events-accessing' }
Object >> updateableActionMap [

	^EventManager updateableActionMapFor: self
]

{ #category : #'*System-Preferences' }
Object >> userInterfaceTheme [
	"Call this to conveniently access properties from the current user interface theme."

	^ UserInterfaceThemeRequest new
		target: self;
		theme: UserInterfaceTheme current;
		yourself
]

{ #category : #'*System-Object Events-accessing-registering' }
Object >> when: anEventSelector evaluate: anAction [ 

	| actions |
	actions := self actionSequenceForEvent: anEventSelector.
	(actions includes: anAction)
		ifTrue: [^ self].
	self 
		setActionSequence: (actions copyWith: anAction)
		forEvent: anEventSelector
]
