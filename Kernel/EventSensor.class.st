"
An EventSensor is an interface to the user input devices.
There is at least one instance of EventSensor named Sensor in the system.

EventSensor is a replacement for the earlier InputSensor implementation based on a set of (optional) event primitives. An EventSensor updates its state when events are received so that all state based users of Sensor (e.g., Sensor keyboard, Sensor leftShiftDown, Sensor mouseButtons) will work exactly as before, by moving the current VM mechanisms into EventSensor itself. An optional input semaphore is part of the new design.

For platforms that support true asynchronous event notification, the semaphore will be signaled to indicate pending events.
On platforms that do not support asynchronous notifications about events, the UI will have to poll EventSensor periodically to read events from the VM.

Instance variables:
	mouseButtons <Integer>	- mouse button state as replacement for primMouseButtons
	mousePosition <Point>	- mouse position as replacement for primMousePt
	keyboardBuffer <SharedQueue>	- keyboard input buffer
	interruptKey <Integer>			- currently defined interrupt key
	interruptSemaphore <Semaphore>	- the semaphore signaled when the interruptKey is detected
	eventQueue <SharedQueue>	- an optional event queue for event driven applications
	inputSemaphore <Semaphore>- the semaphore signaled by the VM if asynchronous event notification is supported
	lastEventPoll <Integer>		- the last millisecondClockValue at which we called fetchMoreEvents
	hasInputSemaphore <Boolean>	- true if my inputSemaphore has actually been signaled at least once.

Class variables:
	ButtonDecodeTable <ByteArray> - maps mouse buttons as reported by the VM to ones reported in the events.
	KeyDecodeTable <Dictionary<SmallInteger->SmallInteger>> - maps some keys and their modifiers to other keys (used for instance to map Ctrl-X to Alt-X)
	InterruptSemaphore <Semaphore> - signalled by the the VM and/or the event loop upon receiving an interrupt keystroke.
	InterruptWatcherProcess <Process> - waits on the InterruptSemaphore and then responds as appropriate.
	EventPollPeriod <Integer>	- the number of milliseconds to wait between polling for more events in the userInterruptHandler.
	EventTicklerProcess <Process>	- the process that makes sure that events are polled for often enough (at least every EventPollPeriod milliseconds).

Event format:
The current event format is very simple. Each event is recorded into an 8 element array. All events must provide some SmallInteger ID (the first field in the event buffer) and a time stamp (the second field in the event buffer), so that the difference between the time stamp of an event and the current time can be reported.

Currently, the following events are defined:

Null event
=============
The Null event is returned when the ST side asks for more events but no more events are available.
Structure:
[1]		- event type 0
[2-8]	- unused

Mouse event structure
==========================
Mouse events are generated when mouse input is detected.
[1]	- event type 1
[2]	- time stamp
[3]	- mouse x position
[4]	- mouse y position
[5]	- button state; bitfield with the following entries:
		1	-	2r001	yellow (e.g., right) button
		2	-	2r010	blue (e.g., middle) button
		4	-	2r100	red (e.g., left) button
		[all other bits are currently undefined]
[6]	- modifier keys; bitfield with the following entries:
		1	-	shift key
		2	-	ctrl key
		4	-	(Mac specific) option key
		8	-	Cmd/Alt key
		[all other bits are currently undefined]
[7]	- reserved.
[8]	- host window id.

Keyboard events
====================
Keyboard events are generated when keyboard input is detected.
[1]	- event type 2
[2]	- time stamp
[3]	- character code (Ascii)
		For now the character code is in Mac Roman encoding. See #macToSqueak.
		For key press/release (see [4]), character codes are normalized.
[4]	- press state; integer with the following meaning
		0	-	character (aka. key stroke or key still pressed)
		1	-	key press (aka. key down)
		2	- 	key release (aka. key up)
[5]	- modifier keys (same as in mouse events)
		For key press/release (see [4]), modifier keys are still accessible.
[6]	- character code (Unicode UTF32)
		Manual decoding via KeyboardInputInterpreter possible.
		For key press/release (see [4]), character codes are normalized.
[7]	- reserved.
[8]	- host window id.
	
Mouse-wheel event structure
==========================
Mouse-wheel events are generated when mouse-wheel input is detected.
[1] - event type 7
[2] - time stamp
[3] - horizontal scroll delta
[4] - vertical scroll delta
[5] - button state (same as in mouse events)
[6] - modifier keys (same as in mouse events)
[7] - reserved.
[8] - host window id.

"
Class {
	#name : #EventSensor,
	#superclass : #Object,
	#instVars : [
		'mouseButtons',
		'mousePosition',
		'mouseWheelDelta',
		'keyboardBuffer',
		'interruptKey',
		'interruptSemaphore',
		'eventQueue',
		'inputSemaphore',
		'lastEventPoll',
		'hasInputSemaphore'
	],
	#classVars : [
		'ButtonDecodeTable',
		'EventPollPeriod',
		'EventTicklerProcess',
		'InterruptSemaphore',
		'InterruptWatcherProcess',
		'KeyDecodeTable'
	],
	#pools : [
		'EventSensorConstants'
	],
	#category : #'Kernel-Processes'
}

{ #category : #public }
EventSensor class >> default [
	"Answer the default system input sensor, Sensor."

	^ Sensor
]

{ #category : #'class initialization' }
EventSensor class >> defaultCrossPlatformKeys [
	"Answer a list of key letters that are used for common editing operations
	on different platforms."
	^{ $c . $x . $v . $a . $s . $f . $g . $z }

]

{ #category : #'preference change notification' }
EventSensor class >> duplicateAllControlAndAltKeysChanged [
	"The Preference for duplicateAllControlAndAltKeys has changed; reset the other two."
	"At some point the various exclusive CtrlAlt-key prefs should become a radio button set, then these methods wouldn't be needed."
	(Preferences
		valueOfFlag: #swapControlAndAltKeys
		ifAbsent: [false]) ifTrue: [
			self inform: 'Resetting swapControlAndAltKeys preference'.
			(Preferences preferenceAt: #swapControlAndAltKeys) rawValue: false.
		].
	(Preferences
		valueOfFlag: #duplicateControlAndAltKeys
		ifAbsent: [false]) ifTrue: [
			self inform: 'Resetting duplicateControlAndAltKeys preference'.
			(Preferences preferenceAt: #duplicateControlAndAltKeys) rawValue: false.
		].
	self installKeyDecodeTable.

]

{ #category : #public }
EventSensor class >> duplicateControlAndAltKeys: aBoolean [
	"EventSensor duplicateControlAndAltKeys: true"

	Preferences setPreference: #duplicateControlAndAltKeys toValue: aBoolean.
	self installKeyDecodeTable

]

{ #category : #'preference change notification' }
EventSensor class >> duplicateControlAndAltKeysChanged [
	"The Preference for duplicateControlAndAltKeys has changed; reset the other two."
	(Preferences
		valueOfFlag: #swapControlAndAltKeys
		ifAbsent: [false]) ifTrue: [
			self inform: 'Resetting swapControlAndAltKeys preference'.
			(Preferences preferenceAt: #swapControlAndAltKeys) rawValue: false.
		].
	(Preferences
		valueOfFlag: #duplicateAllControlAndAltKeys
		ifAbsent: [false]) ifTrue: [
			self inform: 'Resetting duplicateAllControlAndAltKeys preference'.
			(Preferences preferenceAt: #duplicateAllControlAndAltKeys) rawValue: false.
		].
	self installKeyDecodeTable.

]

{ #category : #'class initialization' }
EventSensor class >> eventPollPeriod [
	^EventPollPeriod ifNil: [ EventPollPeriod := 500 ].
]

{ #category : #'class initialization' }
EventSensor class >> eventPollPeriod: msec [
	"Set the number of milliseconds between checking for events to msec."

	EventPollPeriod := msec max: 10.
]

{ #category : #'class initialization' }
EventSensor class >> initialize [

	Smalltalk addToStartUpList: self before: ProcessorScheduler.
	Smalltalk addToShutDownList: self.
	
	self installKeyDecodeTable.
	self installMouseDecodeTable.
	self install.


]

{ #category : #'class initialization' }
EventSensor class >> install [	"EventSensor install"
	"Install an EventSensor in place of the current Sensor."
	| newSensor |
	Sensor shutDown.
	newSensor := self new.
	newSensor startUp.
	"Note: We must use #become: here to replace all references to the old sensor with the new one, since Sensor is referenced from all the existing controllers."
	Sensor becomeForward: newSensor. "done"
]

{ #category : #'key decode table' }
EventSensor class >> installDuplicateKeyEntryFor: aPrintableCharacter [
	"Updates the key-decode table, which maps between pairs of {character code . modifier code}.
	See the class comment for more information.
	The purpose of this change is to let ctrl+key act like cmd+key (Mac) or alt+key (linux/windows).
	It is especially usefull on windows VM where default feel is to use ctrl as shortcut (ctrl+C = copy, etc...).
	Note that the bitmask 16r9F removes the high bits, which subtracts 64 from the key code for (upper) $A to $Z and 96 for (lower) $a to $z. The VM sends non-printable control characters for [ctrl]+[A-Za-Z] in ASCII < 32, but the given character is expected to be ASCII >= 32 and thus printable. So we have to convert control characters to printable characters in this mapping table."

	| upper lower |
	upper := aPrintableCharacter asUppercase asInteger.
	lower := aPrintableCharacter asLowercase asInteger.
	
	KeyDecodeTable at: { lower bitAnd: 16r9F . 2 "ctrl" } put: { lower . 8 "cmd/alt" }.
	KeyDecodeTable at: { upper bitAnd: 16r9F . 2 bitOr: 1 "ctrl + shift" } put: { upper . 8 bitOr: 1 "cmd/alt + shift" }.
]

{ #category : #'class initialization' }
EventSensor class >> installKeyDecodeTable [
	"Create a decode table that swaps or duplicates some keys if the respective preference is set."

	KeyDecodeTable := Dictionary new.

	Preferences swapControlAndAltKeys 
		ifTrue: [ (Character allByteCharacters select: [:ea | ea isAlphaNumeric]) do:
				[ :c | self installSwappedKeyEntryFor: c ] ].
	Preferences duplicateAllControlAndAltKeys
		ifTrue: [ (Character allByteCharacters select: [:ea | ea isAlphaNumeric]) do:
				[ :c | self installDuplicateKeyEntryFor: c ] ].

	self flag: #toDeprecate. "mt: This mapping should be deprecated in the future."
	Preferences duplicateControlAndAltKeys 
		ifTrue: [ self defaultCrossPlatformKeys do:
				[ :c | self installDuplicateKeyEntryFor: c ] ].

]

{ #category : #'class initialization' }
EventSensor class >> installMouseDecodeTable [
	"Create a decode table that swaps the lowest-order 2 bits if 
	Preferences swapMouseButtons is set"
	ButtonDecodeTable := Preferences swapMouseButtons
				ifTrue: [ByteArray withAll:
							((0 to: 255) collect: [:ea |
								((ea bitAnd: 1) << 1
									bitOr: (ea bitAnd: 2) >> 1)
										bitOr: (ea bitAnd: 16rFC) ])]
				ifFalse: [ByteArray
						withAll: (0 to: 255)]
]

{ #category : #'key decode table' }
EventSensor class >> installSwappedKeyEntryFor: aPrintableCharacter [
	"Updates the key-decode table, which maps between pairs of {character code . modifier code}. See the class comment for more information.
	Note that the bitmask 16r9F removes the high bits, which subtracts 64 from the key code for (upper) $A to $Z and 96 for (lower) $a to $z. The VM sends non-printable control characters for [ctrl]+[A-Za-Z] in ASCII < 32, but the given character is expected to be ASCII >= 32 and thus printable. So we have to convert printable characters to control characters in this mapping table."

	| upper lower |
	upper := aPrintableCharacter asUppercase asInteger.
	lower := aPrintableCharacter asLowercase asInteger.
	
	KeyDecodeTable at: { lower bitAnd: 16r9F . 2 "ctrl" } put: { lower . 8 "cmd/alt" }.
	KeyDecodeTable at: { lower . 8 "cmd/alt" } put: { lower bitAnd: 16r9F . 2 "ctrl" }.
	KeyDecodeTable at: { upper bitAnd: 16r9F . 2 bitOr: 1 "ctrl+shift" } put: { upper . 8 bitOr: 1 "cmd/alt+shift" }.
	KeyDecodeTable at: { upper . 8 bitOr: 1 "cmd/alt+shift" } put: { upper bitAnd: 16r9F . 2 bitOr: 1 "ctrl+shift" }.
]

{ #category : #'key decode table' }
EventSensor class >> keyDecodeTable [
	^KeyDecodeTable ifNil: [ self installKeyDecodeTable ]
]

{ #category : #'system startup' }
EventSensor class >> shutDown [
	self default shutDown.
]

{ #category : #'system startup' }
EventSensor class >> startUp [
	
	self installMouseDecodeTable.
	self installKeyDecodeTable.
	self default startUp
]

{ #category : #public }
EventSensor class >> swapControlAndAltKeys: aBoolean [
	"EventSensor swapControlAndAltKeys: true"

	Preferences setPreference: #swapControlAndAltKeys toValue: aBoolean.
	self installKeyDecodeTable
]

{ #category : #'preference change notification' }
EventSensor class >> swapControlAndAltKeysChanged [
	"The Preference for swapControlAndAltKeys has changed; reset the other two."
	(Preferences
		valueOfFlag: #duplicateControlAndAltKeys
		ifAbsent: [false]) ifTrue: [
			self inform: 'Resetting duplicateControlAndAltKeys preference'.
			(Preferences preferenceAt: #duplicateControlAndAltKeys) rawValue: false.
		].
	(Preferences
		valueOfFlag: #duplicateAllControlAndAltKeys
		ifAbsent: [false]) ifTrue: [
			self inform: 'Resetting duplicateAllControlAndAltKeys preference'.
			(Preferences preferenceAt: #duplicateAllControlAndAltKeys) rawValue: false.
		].
	self installKeyDecodeTable.

]

{ #category : #public }
EventSensor class >> swapMouseButtons: aBoolean [
	"EventSensor swapMouseButtons: true"

	Preferences setPreference: #swapMouseButtons toValue: aBoolean.
	self installMouseDecodeTable.
]

{ #category : #'preference change notification' }
EventSensor class >> swapMouseButtonsChanged [

	self installMouseDecodeTable.
]

{ #category : #mouse }
EventSensor >> anyButtonPressed [
	"Answer whether at least one mouse button is currently being pressed."

	^ self peekButtons anyMask: 7

]

{ #category : #'modifier keys' }
EventSensor >> anyModifierKeyPressed [
	"ignore, however, the shift keys 'cause that's not REALLY a command key"

	^ self peekButtons anyMask: 16r70	"cmd | opt | ctrl"
]

{ #category : #mouse }
EventSensor >> blueButtonPressed [
	"Answer whether only the blue mouse button is being pressed. 
	This is the third mouse button or cmd+click on the Mac."

	^ (self peekButtons bitAnd: 7) = 1

]

{ #category : #keyboard }
EventSensor >> characterForKeycode: keycode [
	"Map the given keycode to a Smalltalk character object. Encoding:
		A keycode is 12 bits:   <4 modifer bits><8 bit ISO character>
		Modifier bits are:       <command><option><control><shift>"

	"NOTE: the command and option keys are specific to the Macintosh and may not have equivalents on other platforms."

	keycode = nil ifTrue: [ ^nil ].
	keycode class = Character ifTrue: [ ^keycode ].  "to smooth the transition!"
	^ Character value: (keycode bitAnd: 16rFF)
]

{ #category : #'modifier keys' }
EventSensor >> commandKeyPressed [
	"Answer whether the command key on the keyboard is being held down."

	^ self peekButtons anyMask: 64
]

{ #category : #'modifier keys' }
EventSensor >> controlKeyPressed [
	"Answer whether the control key on the keyboard is being held down."

	^ self peekButtons anyMask: 16
]

{ #category : #mouse }
EventSensor >> createMouseEvent [
	"create and return a new mouse event from the current mouse 
	position; this is useful for restarting normal event queue 
	processing after manual polling"

	| buttons modifiers pos mapped eventBuffer |
	eventBuffer := Array new: 8.
	buttons := self peekButtons.
	pos := self peekPosition.
	modifiers := buttons bitShift: -3.
	buttons := buttons bitAnd: 7.
	mapped := self mapButtons: buttons modifiers: modifiers.
	eventBuffer
		at: 1
		put: EventTypeMouse;
		 at: 2 put: Time eventMillisecondClock;
		 at: 3 put: pos x;
		 at: 4 put: pos y;
		 at: 5 put: mapped;
		 at: 6 put: modifiers.
	^ eventBuffer
]

{ #category : #cursor }
EventSensor >> cursorPoint [
	"Answer a Point indicating the cursor location."

	^ self peekPosition
]

{ #category : #cursor }
EventSensor >> cursorPoint: aPoint [ 
	"Set aPoint to be the current cursor location."

	^self primCursorLocPut: aPoint
]

{ #category : #accessing }
EventSensor >> eventQueue [
	^ eventQueue
]

{ #category : #accessing }
EventSensor >> eventQueue: aSharedQueue [
	eventQueue := aSharedQueue.
]

{ #category : #private }
EventSensor >> eventTickler [
	"Poll infrequently to make sure that the UI process is not been stuck. 
	If it has been stuck, then spin the event loop so that I can detect the 
	interrupt key."
	| delay |
	delay := Delay forMilliseconds: self class eventPollPeriod.
	self lastEventPoll.	"ensure not nil."
	[| delta | 
	[ delay wait.
	delta := Time millisecondClockValue - lastEventPoll.
	(delta < 0
			or: [delta > self class eventPollPeriod])
		ifTrue:
			["force check on rollover"
			self fetchMoreEvents]]
		on: Error do: [:ex | ]] repeat.
]

{ #category : #accessing }
EventSensor >> eventTicklerProcess [
	"Answer my event tickler process, if any"
	^EventTicklerProcess
]

{ #category : #'private-I/O' }
EventSensor >> fetchMoreEvents [
	"Fetch more events from the VM"
	| eventBuffer type |

	"Reset input semaphore so clients can wait for the next events after this one."
	inputSemaphore isSignaled
		ifTrue: [ hasInputSemaphore := true.
			inputSemaphore initSignals ].

	"Remember the last time that I checked for events."
	lastEventPoll := Time millisecondClockValue.

	eventBuffer := Array new: 8.
	[self primGetNextEvent: eventBuffer.
	type := eventBuffer at: 1.
	type = EventTypeNone]
		whileFalse: [self processEvent: eventBuffer].

]

{ #category : #accessing }
EventSensor >> flushAllButDandDEvents [
	| newQueue oldQueue  |
	
	newQueue := SharedQueue new.
	self eventQueue ifNil: [ 
		self eventQueue: newQueue.
		^ self].
	oldQueue := self eventQueue.
	[oldQueue size > 0] whileTrue: 
		[| item type | 
		item := oldQueue next.
		type := item at: 1.
		type = EventTypeDragDropFiles ifTrue: [ newQueue nextPut: item]].
	self eventQueue: newQueue.
]

{ #category : #accessing }
EventSensor >> flushEvents [
	self eventQueue ifNotNil:[:queue | queue flush].
]

{ #category : #keyboard }
EventSensor >> flushKeyboard [
	"Remove all characters from the keyboard buffer."

	[self keyboardPressed]
		whileTrue: [self keyboard]
]

{ #category : #private }
EventSensor >> flushNonKbdEvents [
	"We do NOT use 'isKeybdEvent: ' here,
	 as that would have us flush key press-release events,
	 which is not appropriate when flushing non-keyboard events."
	self eventQueue ifNotNil:
		[:queue |
		 queue flushAllSuchThat: [:buf | (self isAnyKbdEvent: buf) not]]
]

{ #category : #tablet }
EventSensor >> hasTablet [
	"Answer true if there is a pen tablet available on this computer."

	^ (self primTabletGetParameters: 1) notNil

]

{ #category : #initialize }
EventSensor >> initialize [
	"Initialize the receiver"
	mouseButtons := 0.
	mousePosition := 0 @ 0.
	mouseWheelDelta := 0 @ 0.
	keyboardBuffer := SharedQueue new.
	self setInterruptKey: (interruptKey ifNil: [$. asciiValue bitOr: 16r0800 ]). 	"cmd-."
	interruptSemaphore := (Smalltalk specialObjectsArray at: 31) ifNil: [Semaphore new].
	self flushAllButDandDEvents.
	inputSemaphore := Semaphore new.
	hasInputSemaphore := false.
]

{ #category : #private }
EventSensor >> installEventTickler [
	"Initialize the interrupt watcher process. Terminate the old process if any."
	"Sensor installEventTickler"

	EventTicklerProcess ifNotNil: [EventTicklerProcess terminate].
	EventTicklerProcess := [self eventTickler] forkAt: Processor lowIOPriority.

]

{ #category : #'user interrupts' }
EventSensor >> installInterruptWatcher [
	"Initialize the interrupt watcher process. Terminate the old process if any."
	"Sensor installInterruptWatcher"

	InterruptWatcherProcess ifNotNil: [InterruptWatcherProcess terminate].
	InterruptSemaphore := Semaphore new.
	InterruptWatcherProcess := [self userInterruptWatcher] forkAt: Processor lowIOPriority.
	self primInterruptSemaphore: InterruptSemaphore.
]

{ #category : #'user interrupts' }
EventSensor >> interruptWatcherProcess [
	"Answer my interrupt watcher process, if any"
	^InterruptWatcherProcess
]

{ #category : #private }
EventSensor >> isAnyKbdEvent: buf [
	^(buf at: 1) = EventTypeKeyboard
]

{ #category : #private }
EventSensor >> isKbdEvent: buf [
	^ (buf at: 1) = EventTypeKeyboard and: [(buf at: 4) = EventKeyChar]
]

{ #category : #joystick }
EventSensor >> joystickButtons: index [

	^ ((self primReadJoystick: index) bitShift: -22) bitAnd: 16r71F
	
]

{ #category : #joystick }
EventSensor >> joystickOn: index [

	^ (((self primReadJoystick: index) bitShift: -27) bitAnd: 1) ~= 0
	
]

{ #category : #joystick }
EventSensor >> joystickXY: index [

	| inputWord x y |
	inputWord := self primReadJoystick: index.
	x := (inputWord bitAnd: 16r7FF) - 16r400.
	y := ((inputWord bitShift: -11) bitAnd: 16r7FF) - 16r400.
	^ x@y
	
]

{ #category : #keyboard }
EventSensor >> kbdTest [    "Sensor kbdTest"
	"This test routine will print the unmodified character, its keycode,
	and the OR of all its modifier bits, until the character x is typed"
	| char evt |
	char := nil.
	[char = $x] whileFalse: 
		[[(evt := self peekKeyboardEvent) isNil] whileTrue.
		char := self characterForKeycode: evt third.
		(String streamContents: 
			[:s |
			s nextPut: char.
			(3 to: 8) with: 'cpmurw' do:
				[:i :c|
				s space; nextPut: c; nextPut: $:; print: (evt at: i); nextPutAll: '     ']])
			displayAt: 10@10]
]

{ #category : #keyboard }
EventSensor >> keyboard [
	"Answer the next character from the keyboard."

	| firstCharacter secondCharactor stream multiCharacter converter |
	firstCharacter := self characterForKeycode: self primKbdNext.
	secondCharactor := self peekKeyboard.
	secondCharactor isNil
		ifTrue: [^ firstCharacter].
	converter := TextConverter defaultSystemConverter.
	converter isNil
		ifTrue: [^ firstCharacter].
	stream := ReadStream
				on: (String with: firstCharacter with: secondCharactor).
	multiCharacter := converter nextFromStream: stream.
	multiCharacter isOctetCharacter
		ifTrue: [^ multiCharacter].
	self primKbdNext.
	^ multiCharacter

]

{ #category : #keyboard }
EventSensor >> keyboardPressed [
	"Answer true if keystrokes are available."

	^self peekKeyboard notNil
]

{ #category : #private }
EventSensor >> lastEventPoll [
	"Answer the last clock value at which fetchMoreEvents was called."
	^lastEventPoll ifNil: [ lastEventPoll := Time millisecondClockValue ]
]

{ #category : #'modifier keys' }
EventSensor >> leftShiftDown [
	"Answer whether the shift key on the keyboard is being held down. The name of this message is a throwback to the Alto, which had independent left and right shift keys."

	^ self peekButtons anyMask: 8
]

{ #category : #'private-I/O' }
EventSensor >> mapButtons: buttons modifiers: modifiers [
	"Map the buttons to yellow or blue based on the given modifiers.
	If only the red button is pressed, then map
		Ctrl-RedButton -> BlueButton.
		Cmd-RedButton -> YellowButton.
	"
	(buttons = RedButtonBit)
		ifFalse:[^buttons].
	(modifiers allMask: CtrlKeyBit) 
		ifTrue:[^BlueButtonBit].
	(modifiers allMask: CommandKeyBit) 
		ifTrue:[^YellowButtonBit].
	^buttons
]

{ #category : #mouse }
EventSensor >> mouseButtons [
	"Answer a number from 0 to 7 that encodes the state of the three mouse buttons in its lowest 3 bits."

	^ self peekButtons bitAnd: 7

]

{ #category : #accessing }
EventSensor >> nextEvent [
	"Return the next event from the receiver."

	^ self eventQueue 
		ifNil: [self nextEventSynthesized]
		ifNotNil: [self nextEventFromQueue]

]

{ #category : #private }
EventSensor >> nextEventFromQueue [
	"Return the next event from the receiver. If the queue is empty, try to fetch more events once."

	self eventQueue isEmpty
		ifTrue: [self fetchMoreEvents].

	^ self eventQueue isEmpty
		ifTrue: [nil]
		ifFalse: [self eventQueue next]
]

{ #category : #private }
EventSensor >> nextEventSynthesized [
	"Return a synthesized event. This method is called if an event driven client wants to receive events but the primary user interface is not event-driven (e.g., the receiver does not have an event queue but only updates its state). This can, for instance, happen if a Morphic World is run in an MVC window. To simplify the clients work this method will always return all available keyboard events first, and then (repeatedly) the mouse events. Since mouse events come last, the client can assume that after one mouse event has been received there are no more to come. Note that it is impossible for EventSensor to determine if a mouse event has been issued before so the client must be aware of the possible problem of getting repeatedly the same mouse events. See HandMorph>>processEvents for an example on how to deal with this."
	| kbd array buttons pos modifiers mapped |
	"First check for keyboard"
	array := Array new: 8.
	kbd := self primKbdNext.
	kbd ifNotNil:
		["simulate keyboard event"
		array at: 1 put: EventTypeKeyboard. "evt type"
		array at: 2 put: Time eventMillisecondClock. "time stamp"
		array at: 3 put: (kbd bitAnd: 255). "char code"
		array at: 4 put: EventKeyChar. "key press/release"
		array at: 5 put: (kbd bitShift: -8). "modifier keys"
		^ array].

	"Then check for mouse"
	pos := self peekPosition.
	buttons := mouseButtons.
	modifiers := buttons bitShift: -3.
	buttons := buttons bitAnd: 7.
	mapped := self mapButtons: buttons modifiers: modifiers.
	array 
		at: 1 put: EventTypeMouse;
		at: 2 put: Time eventMillisecondClock;
		at: 3 put: pos x;
		at: 4 put: pos y;
		at: 5 put: mapped;
		at: 6 put: modifiers.
	^ array


]

{ #category : #mouse }
EventSensor >> noButtonPressed [
	"Answer whether any mouse button is not being pressed."

	^self anyButtonPressed not

]

{ #category : #'primitives-fallback' }
EventSensor >> oldPrimInterruptSemaphore: aSemaphore [ 
	"Primitive. Install the argument as the semaphore to be signalled whenever the user presses the interrupt key. The semaphore will be signaled once each time the interrupt key is pressed."

	<primitive: 134>
	^self primitiveFailed
"Note: This primitive is obsolete with the new event driven architecture in which EventSensor can handle the interrupts itself. However, for supporting older images running on newer VMs the primitive must still be implemented."
]

{ #category : #'primitives-fallback' }
EventSensor >> oldPrimKbdNext [
	<primitive: 108>
	^ nil
]

{ #category : #'primitives-fallback' }
EventSensor >> oldPrimMouseButtons [
	<primitive: 107>
	^ 0
]

{ #category : #'primitives-fallback' }
EventSensor >> oldPrimMousePt [
	"Primitive. Poll the mouse to find out its position. Return a Point. Fail if
	event-driven tracking is used instead of polling. Optional. See Object
	documentation whatIsAPrimitive."

	<primitive: 90>
	^ 0@0
]

{ #category : #'primitives-fallback' }
EventSensor >> oldPrimSetInterruptKey: anInteger [
	"Primitive. Register the given keycode as the user interrupt key. The low byte of the keycode is the ISO character and its next four bits are the Smalltalk modifer bits <cmd><opt><ctrl><shift>."

	<primitive: 133>
	^self primitiveFailed
"Note: This primitive is obsolete with the new event driven architecture in which EventSensor can handle the interrupts itself. However, for supporting older images running on newer VMs the primitive must still be implemented."
]

{ #category : #accessing }
EventSensor >> peekButtons [
	self fetchMoreEvents.
	self flushNonKbdEvents.
	^ mouseButtons
]

{ #category : #accessing }
EventSensor >> peekEvent [
	"Look ahead at the next event. Try to fetch more events first."

	^ self eventQueue
		ifNil: [nil]
		ifNotNil: [:queue |
			self fetchMoreEvents.
			queue peek]
]

{ #category : #keyboard }
EventSensor >> peekKeyboard [
	"Answer the next character in the keyboard buffer without removing it, or nil if it is empty."

	| char |
	self fetchMoreEvents.
	keyboardBuffer isEmpty ifFalse: [^ self characterForKeycode: keyboardBuffer peek].
	char := nil.
	self eventQueue ifNotNil: [:queue |
		queue nextOrNilSuchThat:  "NOTE: must not return out of this block, so loop to end"
			[:buf | (self isKbdEvent: buf) ifTrue: [char ifNil: [char := buf at: 3]].
			false  "NOTE: block value must be false so Queue won't advance"]].
	^ self characterForKeycode: char
]

{ #category : #accessing }
EventSensor >> peekKeyboardEvent [
	"Return the next keyboard char event from the receiver or nil if none available"
	
	^ self eventQueue
		ifNil: [nil]
		ifNotNil: [:queue |
			self fetchMoreEvents.
			queue nextOrNilSuchThat: [:buf | 
				buf first = EventTypeKeyboard and: [(buf fourth) = EventKeyChar]]]
]

{ #category : #accessing }
EventSensor >> peekPosition [
	self fetchMoreEvents.
	"self flushNonKbdEvents. -- mt: Should not be necessary here."
	^ mousePosition
]

{ #category : #accessing }
EventSensor >> peekWheelDelta [
	self fetchMoreEvents.
	^ mouseWheelDelta
]

{ #category : #'primitives-cursor' }
EventSensor >> primCursorLocPut: aPoint [
	"If the primitive fails, try again with a rounded point."

	<primitive: 91>
	^ self primCursorLocPutAgain: aPoint rounded
]

{ #category : #'primitives-cursor' }
EventSensor >> primCursorLocPutAgain: aPoint [
	"Do nothing if primitive is not implemented."

	<primitive: 91>
	^ self
]

{ #category : #'private-I/O' }
EventSensor >> primGetNextEvent: array [
	"Store the next OS event available into the provided array.
	Essential. If the VM is not event driven the ST code will fall
	back to the old-style mechanism and use the state based
	primitives instead."
	| kbd buttons modifiers pos mapped |
	<primitive: 94>
	"Simulate the events"
	array at: 1 put: EventTypeNone. "assume no more events"

	"First check for keyboard"
	kbd := self oldPrimKbdNext.
	kbd = nil ifFalse:[
		"simulate keyboard event"
		array at: 1 put: EventTypeKeyboard. "evt type"
		array at: 2 put: Time eventMillisecondClock. "time stamp"
		array at: 3 put: (kbd bitAnd: 255). "char code"
		array at: 4 put: EventKeyChar. "key press/release"
		array at: 5 put: (kbd bitShift: -8). "modifier keys"
		^self].

	"Then check for mouse"
	buttons := self oldPrimMouseButtons.
	pos := self oldPrimMousePt.
	modifiers := buttons bitShift: -3.
	buttons := buttons bitAnd: 7.
	mapped := self mapButtons: buttons modifiers: modifiers.
	(pos = mousePosition and:[(mapped bitOr: (modifiers bitShift: 3)) = mouseButtons])
		ifTrue:[^self].
	array 
		at: 1 put: EventTypeMouse;
		at: 2 put: Time eventMillisecondClock;
		at: 3 put: pos x;
		at: 4 put: pos y;
		at: 5 put: mapped;
		at: 6 put: modifiers.

]

{ #category : #private }
EventSensor >> primInterruptSemaphore: aSemaphore [ 
	"Primitive. Install the argument as the semaphore to be signalled whenever the user presses the interrupt key. The semaphore will be signaled once each time the interrupt key is pressed."
	interruptSemaphore := aSemaphore.
	"backward compatibility: use the old primitive which is obsolete now"
	self oldPrimInterruptSemaphore: aSemaphore
]

{ #category : #private }
EventSensor >> primKbdNext [
	"Allows for use of old Sensor protocol to get at the keyboard,
	as when running kbdTest or the InterpreterSimulator in Morphic"
	| evtBuf |
	
	self flag: #refactor. "mt: Suspiciously similar to #peekKeyboardEvent"
	self fetchMoreEvents.
	keyboardBuffer isEmpty ifFalse:[^ keyboardBuffer next].
	self eventQueue ifNotNil: [:queue |
		evtBuf := queue nextOrNilSuchThat: [:buf | self isKbdEvent: buf].
		self flushNonKbdEvents].
	^ evtBuf ifNotNil: [evtBuf at: 3]

]

{ #category : #'primitives-tablet' }
EventSensor >> primReadJoystick: index [
	"Return the joystick input word for the joystick with the given index in the range [1..16]. Returns zero if the index does not correspond to a currently installed joystick."

	<primitive: 'primitiveReadJoystick' module: 'JoystickTabletPlugin'>
	^ 0

	
]

{ #category : #'private-I/O' }
EventSensor >> primSetInputSemaphore: semaIndex [
	"Set the input semaphore the VM should use for asynchronously signaling the availability of events. Primitive. Optional."
	<primitive: 93>
	^nil
]

{ #category : #private }
EventSensor >> primSetInterruptKey: anInteger [
	"Primitive. Register the given keycode as the user interrupt key. The low byte of the keycode is the ISO character and its next four bits are the Smalltalk modifer bits <cmd><opt><ctrl><shift>."
	interruptKey := anInteger.
	"backward compatibility: use the old primitive which is obsolete now"
	self oldPrimSetInterruptKey: anInteger
]

{ #category : #'primitives-tablet' }
EventSensor >> primTabletGetParameters: cursorIndex [
	"Answer the pen tablet parameters. For parameters that differ from cursor to cursor, answer those associated with the cursor having the given index. Answer nil if there is no pen tablet. The parameters are:
	1. tablet width, in tablet units
	2. tablet height, in tablet units
	3. number of tablet units per inch
	4. number of cursors (pens, pucks, etc; some tablets have more than one)
	5. this cursor index
	6. and 7. x scale and x offset for scaling tablet coordintes (e.g., to fit the screen)
	8. and 9. y scale and y offset for scaling tablet coordintes  (e.g., to fit the screen)
	10. number of pressure levels
	11. presure threshold needed close pen tip switch 
	12. number of pen tilt angles"

	<primitive: 'primitiveGetTabletParameters' module: 'JoystickTabletPlugin'>
	^ nil

]

{ #category : #'primitives-tablet' }
EventSensor >> primTabletRead: cursorIndex [
	"Answer the pen tablet data for the cursor having the given index. Answer nil if there is no pen tablet. The data is:
	1. index of the cursor to which this data applies
	2. timestamp of the last state chance for this cursor
	3., 4., and 5. x, y, and z coordinates of the cursor (z is typically 0)
	6. and 7. xTilt and yTilt of the cursor; (signed)
	8. type of cursor (0 = unknown, 1 = pen, 2 = puck, 3 = eraser)
	9. cursor buttons
	10. cursor pressure, downward
	11. cursor pressure, tangential
	12. flags"

	<primitive: 'primitiveReadTablet' module: 'JoystickTabletPlugin'>
	self primitiveFailed

]

{ #category : #'private-I/O' }
EventSensor >> processEvent: evt [ 
	"Process a single event. This method is run at high priority."
	| type buttons window |
	type := evt at: 1.

	"Only process main window events, forward others to host window proxies"
	window := evt at: 8.
	(window isNil or: [window isZero]) ifTrue: 
		[window := 1. 
		evt at: 8 put: window].
	window = 1 ifFalse: [
		^Smalltalk at: #HostWindowProxy ifPresent: [:w | w processEvent: evt]].

	"Tackle mouse events and mouse wheel events first"
	(type = EventTypeMouse or: [type = EventTypeMouseWheel])
		ifTrue: [buttons := (ButtonDecodeTable at: (evt at: 5) + 1). 
				evt at: 5 put: (Smalltalk platformName = 'Mac OS'
							ifTrue: [ buttons ]
							ifFalse: [ self mapButtons: buttons modifiers: (evt at: 6) ]).
				self queueEvent: evt.
				type = EventTypeMouse ifTrue: [self processMouseEvent: evt].
				type = EventTypeMouseWheel ifTrue: [self processMouseWheelEvent: evt].				
				^self].
	
	"Store the event in the queue if there's any"
	type = EventTypeKeyboard
		ifTrue: [ "Check if the event is a user interrupt"
			((evt at: 4) = EventKeyChar
				and: [((evt at: 3)
						bitOr: (((evt at: 5)
							bitAnd: 8)
							bitShift: 8))
							= interruptKey])
					ifTrue: ["interrupt key is meta - not reported as event"
							^ interruptSemaphore signal].
			"Decode keys for characters (i.e., duplicate or swap, ctrl <-> alt/cmd)."
			(evt at: 4) = EventKeyChar
				ifTrue: [ | unicode ascii |
					"Copy lookup key first in case of key swap."
					unicode := {evt at: 6. evt at: 5}.
					ascii := {evt at: 3. evt at: 5}.
					KeyDecodeTable "Unicode character first"
						at: unicode
						ifPresent: [:a | evt at: 6 put: a first;
								 at: 5 put: a second]. 
					KeyDecodeTable "ASCII character second"
						at: ascii
						ifPresent: [:a | evt at: 3 put: a first;
								 at: 5 put: a second]]. 
			self queueEvent: evt. 
			self processKeyboardEvent: evt . 
			^self ].
				
	"Handle all events other than Keyboard or Mouse."
	self queueEvent: evt.
	
]

{ #category : #'private-I/O' }
EventSensor >> processKeyboardEvent: evt [
	"process a keyboard event, updating EventSensor state"
	| charCode pressCode |
	"Never update keyboardBuffer if we have an eventQueue active"
	mouseButtons := (mouseButtons bitAnd: 7) bitOr: ((evt at: 5) bitShift: 3).
	self eventQueue ifNotNil:[^self]. 
	charCode := evt at: 3.
	charCode = nil ifTrue:[^self]. "extra characters not handled in MVC"
	pressCode := evt at: 4.
	pressCode = EventKeyChar ifFalse:[^self]. "key down/up not handled in MVC"
	"mix in modifiers"
	charCode := charCode bitOr: ((evt at: 5) bitShift: 8).
	keyboardBuffer nextPut: charCode.
]

{ #category : #'private-I/O' }
EventSensor >> processMouseEvent: evt [
	"process a mouse event, updating EventSensor state"
	| modifiers buttons mapped |
	mousePosition := (evt at: 3) @ (evt at: 4).
	buttons := evt at: 5.
	modifiers := evt at: 6.
	mapped := self mapButtons: buttons modifiers: modifiers.
	mouseButtons := mapped bitOr: (modifiers bitShift: 3).
]

{ #category : #'private-I/O' }
EventSensor >> processMouseWheelEvent: evt [
	"process a mouse wheel event, updating EventSensor state"
	
	| modifiers buttons mapped |
	mouseWheelDelta := (evt at: 3) @ (evt at: 4).
	buttons := evt at: 5.
	modifiers := evt at: 6.
	mapped := self mapButtons: buttons modifiers: modifiers.
	mouseButtons := mapped bitOr: (modifiers bitShift: 3).
]

{ #category : #'private-I/O' }
EventSensor >> queueEvent: evt [
	"Queue the given event in the event queue (if any).
	Note that the event buffer must be copied since it
	will be reused later on."
	
	self eventQueue ifNotNil: [:queue |
		queue nextPut: evt shallowCopy].
]

{ #category : #'modifier keys' }
EventSensor >> rawMacOptionKeyPressed [
	"Answer whether the option key on the Macintosh keyboard is being held down. Macintosh specific.  Clients are discouraged from calling this directly, since it circumvents bert's attempt to eradicate option-key checks"

	^ self peekButtons anyMask: 32
]

{ #category : #mouse }
EventSensor >> redButtonPressed [
	"Answer true if only the red mouse button is being pressed.
	This is the first mouse button, usually the left one."

	^ (self peekButtons bitAnd: 7) = 4

]

{ #category : #'user interrupts' }
EventSensor >> setInterruptKey: anInteger [
	"Register the given keycode as the user interrupt key."

	self primSetInterruptKey: anInteger.

]

{ #category : #'modifier keys' }
EventSensor >> shiftPressed [
	"Answer whether the shift key on the keyboard is being held down."

	^ self peekButtons anyMask: 8

]

{ #category : #initialize }
EventSensor >> shutDown [

	InterruptWatcherProcess ifNotNil: [
		InterruptWatcherProcess terminate.
		InterruptWatcherProcess := nil ].

	EventTicklerProcess ifNotNil: [
		EventTicklerProcess terminate.
		EventTicklerProcess := nil. ].
	
	inputSemaphore ifNotNil:[Smalltalk unregisterExternalObject: inputSemaphore].
]

{ #category : #initialize }
EventSensor >> startUp [

	self initialize.
	self primSetInputSemaphore: (Smalltalk registerExternalObject: inputSemaphore).

	self installInterruptWatcher.
	self installEventTickler.

	Smalltalk isMorphic ifTrue: [self flushAllButDandDEvents].

	"Attempt to discover whether the input semaphore is actually being signaled."
	hasInputSemaphore := false.
	inputSemaphore initSignals.
]

{ #category : #tablet }
EventSensor >> tabletExtent [
	"Answer the full tablet extent in tablet coordinates."

	| params |
	params := self primTabletGetParameters: 1.
	params ifNil: [^ self error: 'no tablet available'].
	^ (params at: 1)@(params at: 2)

]

{ #category : #tablet }
EventSensor >> tabletPoint [
	"Answer the current position of the first tablet pointing device (pen, puck, or eraser) in tablet coordinates."

	| data |
	data := self primTabletRead: 1.  "state of first/primary pen"
	^ (data at: 3) @ (data at: 4)

]

{ #category : #tablet }
EventSensor >> tabletPressure [
	"Answer the current pressure of the first tablet pointing device (pen, puck, or eraser), a number between 0.0 (no pressure) and 1.0 (max pressure)"

	| params data |
	params := self primTabletGetParameters: 1.
	params ifNil: [^ self].
	data := self primTabletRead: 1.  "state of first/primary pen"
	^ (data at: 10) asFloat / ((params at: 10) - 1)

]

{ #category : #tablet }
EventSensor >> tabletTimestamp [
	"Answer the time (in tablet clock ticks) at which the tablet's primary pen last changed state. This can be used in polling loops; if this timestamp hasn't changed, then the pen state hasn't changed either."

	| data |
	data := self primTabletRead: 1.  "state of first/primary pen"
	^ data at: 2

]

{ #category : #'user interrupts' }
EventSensor >> userInterruptWatcher [
	"Wait for user interrupts and open a notifier on the active process when one occurs."
	[ InterruptSemaphore wait.
	Display deferUpdates: false.
	SoundService stop.
	Smalltalk handleUserInterrupt ] repeat
]

{ #category : #mouse }
EventSensor >> waitButton [
	"Wait for the user to press any mouse button and then answer with the 
	current location of the cursor."

	| delay |
	delay := Delay forMilliseconds: 50.
	[self anyButtonPressed] whileFalse: [ delay wait ].
	^self cursorPoint

]

{ #category : #mouse }
EventSensor >> waitButtonOrKeyboard [
	"Wait for the user to press either any mouse button or any key. 
	Answer the current cursor location or nil if a keypress occured."

	| delay |
	delay := Delay forMilliseconds: 50.
	[self anyButtonPressed]
		whileFalse: [delay wait.
			self keyboardPressed
				ifTrue: [^ nil]].
	^ self cursorPoint

]

{ #category : #mouse }
EventSensor >> waitClickButton [
	"Wait for the user to click (press and then release) any mouse button and 
	then answer with the current location of the cursor."

	self waitButton.
	^self waitNoButton
]

{ #category : #mouse }
EventSensor >> waitNoButton [
	"Wait for the user to release any mouse button and then answer the current location of the cursor."

	| delay |
	delay := Delay forMilliseconds: 50.
	[self anyButtonPressed] whileTrue: [ delay wait].
	^self cursorPoint

]

{ #category : #mouse }
EventSensor >> yellowButtonPressed [
	"Answer whether only the yellow mouse button is being pressed. 
	This is the second mouse button or option+click on the Mac."

	^ (self peekButtons bitAnd: 7) = 2

]
