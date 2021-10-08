Extension { #name : #PositionableStream }

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> backChunk [
	"Answer the contents of the receiver back to the previous terminator character.  Doubled terminators indicate an embedded terminator character."

	| output character |
	output := WriteStream on: (String new: 1000).
	self back. "oldBack compatibility"
	[ (character := self back) == nil ] whileFalse: [
		character == $! ifTrue: [
			self back == $! ifFalse: [ 
				self skip: 2. "oldBack compatibility"
				^output contents reversed ] ].
		output nextPut: character].
	self skip: 1. "oldBack compatibility"
	^output contents reversed
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> basicNextChunk [
	"Answer the contents of the receiver, up to the next terminator character. Doubled terminators indicate an embedded terminator character."
	| terminator out ch |
	terminator := $!.
	out := WriteStream on: (String new: 1000).
	self skipSeparators.
	[(ch := self next) == nil] whileFalse: [
		(ch == terminator) ifTrue: [
			self peek == terminator ifTrue: [
				self next.  "skip doubled terminator"
			] ifFalse: [
				^ out contents  "terminator is not doubled; we're done!"
			].
		].
		out nextPut: ch.
	].
	^ out contents
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> checkForPreamble: chunk [
	((chunk beginsWith: '"Change Set:') and: [ChangeSet current preambleString == nil])
		ifTrue: [ChangeSet current preambleString: chunk].
	((chunk beginsWith: '"Postscript:') and: [ChangeSet current postscriptString == nil])
		ifTrue: [ChangeSet current postscriptString: chunk].
							

]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> command: aString [
	"Overridden by HtmlFileStream to append commands directly without translation.  4/5/96 tk"
	"We ignore any HTML commands.  Do nothing"
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> copyMethodChunkFrom: aStream [
	"Copy the next chunk from aStream (must be different from the receiver)."
	| chunk |
	chunk := aStream nextChunkText.
	chunk runs values size = 1 "Optimize for unembellished text"
		ifTrue: [self nextChunkPut: chunk asString]
		ifFalse: [self nextChunkPutWithStyle: chunk]
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> copyMethodChunkFrom: aStream at: pos [
	"Copy the next chunk from aStream (must be different from the receiver)."
	| chunk |
	aStream position: pos.
	chunk := aStream nextChunkText.
	chunk runs values size = 1 "Optimize for unembellished text"
		ifTrue: [self nextChunkPut: chunk asString]
		ifFalse: [self nextChunkPutWithStyle: chunk]
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> copyPreamble: preamble from: aStream at: pos [ 
	"Look for a changeStamp for this method by peeking backward.
	Write a method preamble, with that stamp if found."
	| terminator last50 stamp i |
	terminator := $!.

	"Look back to find stamp in old preamble, such as...
	Polygon methodsFor: 'private' stamp: 'di 6/25/97 21:42' prior: 34957598! "
	aStream position: pos.
	aStream backChunk.	"to beginning of method"
	last50 := aStream backChunk.	"to get preamble"
	aStream position: pos.
	stamp := String new.
	(i := last50 
		findLastOccurrenceOfString: 'stamp:'
		startingAt: 1) > 0 ifTrue: 
		[ stamp := (last50 
			copyFrom: i + 8
			to: last50 size) copyUpTo: $' ].

	"Write the new preamble, with old stamp if any."
	self
		cr;
		nextPut: terminator.
	self nextChunkPut: (String streamContents: 
			[ :strm | 
			strm nextPutAll: preamble.
			stamp size > 0 ifTrue: 
				[ strm
					nextPutAll: ' stamp: ';
					print: stamp ] ]).
	self cr
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> decodeString: string andRuns: runsRaw [

	| strm runLength runValues newString index |
	strm := runsRaw readStream.
	(strm peekFor: $( ) ifFalse: [^ nil].
	runLength := OrderedCollection new.
	[strm skipSeparators.
	 strm peekFor: $)] whileFalse: 
		[runLength add: (Number readFrom: strm)].

	runValues := OrderedCollection new.
	[strm atEnd not] whileTrue: 
		[runValues add: (Number readFrom: strm).
		strm next.].

	newString := WideString new: string size.
	index := 1.
	runLength with: runValues do: [:length :leadingChar |
		index to: index + length - 1 do: [:pos |
			newString at: pos put: (Character leadingChar: leadingChar code: (string at: pos) charCode).
		].
		index := index + length.
	].

	^ newString.

]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> decodeStyle: runsObjData version: styleVersion [
	"Decode the runs array from the ReferenceStream it is stored in."
	"Verify that the class mentioned have the same inst vars as we have now"

	| structureInfo |
	styleVersion = RemoteString currentTextAttVersion ifTrue: [
		"Matches our classes, no need for checking"
		^ (ReferenceStream on: runsObjData) next].
	structureInfo := RemoteString structureAt: styleVersion.	"or nil"
		"See SmartRefStream instVarInfo: for dfn"
	^ SmartRefStream read: runsObjData withClasses: structureInfo
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> fileIn [
	"This is special for reading expressions from text that has been formatted 
	with exclamation delimitors. The expressions are read and passed to the 
	Compiler. Answer the result of compilation."

	^ self fileInAnnouncing: 'Reading ' , self name
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> fileInAnnouncing: announcement [ 
	"This is special for reading expressions from text that has been formatted 
	with exclamation delimitors. The expressions are read and passed to the 
	Compiler. Answer the result of compilation.  Put up a progress report with
     the given announcement as the title."

	| val |
	announcement 
		displayProgressFrom: 0
		to: self size
		during: 
			[:bar | 
			[self atEnd] whileFalse: 
					[bar value: self position.
					self skipSeparators.
					
					[ | chunk |
					val := (self peekFor: $!) 
								ifTrue: [(Compiler evaluate: self nextChunk logged: true) scanFrom: self]
								ifFalse: 
									[chunk := self nextChunk.
									self checkForPreamble: chunk.
									Compiler evaluate: chunk logged: true]] 
							on: InMidstOfFileinNotification
							do: [:ex | ex resume: true].
					self skipStyleChunk].
			self close].
	"Note:  The main purpose of this banner is to flush the changes file."
	Smalltalk logChange: '----End fileIn of ' , self name , '----'.
	self flag: #ThisMethodShouldNotBeThere.	"sd"
	^val
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> fileInFor: client announcing: announcement [
	"This is special for reading expressions from text that has been formatted 
	with exclamation delimitors. The expressions are read and passed to the 
	Compiler. Answer the result of compilation.  Put up a progress report with
     the given announcement as the title.
	Does NOT handle preambles or postscripts specially."
	| val |
	announcement
		displayProgressFrom: 0
		to: self size
		during:
		[:bar |
		[self atEnd]
			whileFalse: 
				[bar value: self position.
				self skipSeparators.
				[ | chunk |
				val := (self peekFor: $!) ifTrue: [
						(Compiler evaluate: self nextChunk for: client logged: false) scanFrom: self
					] ifFalse: [
						chunk := self nextChunk.
						self checkForPreamble: chunk.
						Compiler evaluate: chunk for: client logged: true ].
				] on: InMidstOfFileinNotification
				  do: [ :ex | ex resume: true].
				self atEnd ifFalse: [ self skipStyleChunk ]].
		self close].
	"Note:  The main purpose of this banner is to flush the changes file."
	Smalltalk logChange: '----End fileIn of ' , self name , '----'.
	^ val
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> fileInSilentlyAnnouncing: announcement [ 
	"This is special for reading expressions from text that has been formatted 
	with exclamation delimitors. The expressions are read and passed to the 
	Compiler. Answer the result of compilation.  Put up a progress report with
     the given announcement as the title."

	| val chunk |
	[self atEnd] whileFalse: 
			[self skipSeparators.
			
			[val := (self peekFor: $!) 
						ifTrue: [(Compiler evaluate: self nextChunk logged: false) scanFrom: self]
						ifFalse: 
							[chunk := self nextChunk.
							self checkForPreamble: chunk.
							Compiler evaluate: chunk logged: true]] 
					on: InMidstOfFileinNotification
					do: [:ex | ex resume: true].
			self skipStyleChunk].
	self close.
	"Note:  The main purpose of this banner is to flush the changes file."
	Smalltalk  logChange: '----End fileIn of ' , self name , '----'.
	self flag: #ThisMethodShouldNotBeThere.	"sd"
	SystemNavigation new allBehaviorsDo: 
			[:cl | 
			cl
				removeSelectorSimply: #DoIt;
				removeSelectorSimply: #DoItIn:].
	^val
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> header [
	"If the stream requires a standard header, override this message.  See HtmlFileStream"
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> nextChunk [
	"Answer the contents of the receiver, up to the next terminator character. Doubled terminators indicate an embedded terminator character."
	| terminator out ch |
	terminator := $!.
	out := WriteStream on: (String new: 1000).
	self skipSeparators.
	[(ch := self next) == nil] whileFalse: [
		(ch == terminator) ifTrue: [
			self peek == terminator ifTrue: [
				self next.  "skip doubled terminator"
			] ifFalse: [
				^ self parseLangTagFor: out contents  "terminator is not doubled; we're done!"
			].
		].
		out nextPut: ch.
	].
	^ self parseLangTagFor: out contents.

]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> nextChunkText [
	"Deliver the next chunk as a Text.  Decode the following ]style[ chunk if present.  Position at start of next real chunk."
	| string runs peek pos |
	"Read the plain text"
	string := self nextChunk.
	
	"Test for ]style[ tag"
	pos := self position.
	peek := self skipSeparatorsAndPeekNext.
	peek = $] ifFalse: [self position: pos. ^ string asText].  "no tag"
	(self upTo: $[) = ']style' ifFalse: [self position: pos. ^ string asText].  "different tag"

	"Read and decode the style chunk"
	runs := RunArray scanFrom: self basicNextChunk readStream.

	^ Text basicNew setString: string setRunsChecking: runs.

]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> parseLangTagFor: aString [

	| string peek runsRaw pos |
	string := aString.
	"Test for ]lang[ tag"
	pos := self position.
	peek := self skipSeparatorsAndPeekNext.
	peek = $] ifFalse: [self position: pos. ^ string].  "no tag"
	(self upTo: $[) = ']lang' ifTrue: [
		runsRaw := self basicNextChunk.
		string := self decodeString: aString andRuns: runsRaw
	] ifFalse: [
		self position: pos
	].
	^ string.

]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> skipSeparatorsAndPeekNext [
	"A special function to make nextChunk fast"
	| peek |
	[self atEnd]
		whileFalse:
		[(peek := self next) isSeparator
			ifFalse: [self position: self position-1. ^ peek]]
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> skipStyleChunk [
	"Get to the start of the next chunk that is not a style for the previous chunk"

	| pos |
	pos := self position.
	self skipSeparators.
	self peek == $] 
		ifTrue: [(self upTo: $[) = ']text' 	"old -- no longer needed"
				"now positioned past the open bracket"
			ifFalse: [self nextChunk]]	"absorb ]style[ and its whole chunk"
				
		ifFalse: [self position: pos]	"leave untouched"

]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> trailer [
	"If the stream requires a standard trailer, override this message.  See HtmlFileStream"
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> unCommand [
	"If this read stream is at a <, then skip up to just after the next >.  For removing html commands."
	| char |
	[self peek = $<] whileTrue: ["begin a block"
		[self atEnd == false and: [self next ~= $>]] whileTrue.
		"absorb characters"
		].
 
]

{ #category : #'*System-Changes-fileIn/Out' }
PositionableStream >> verbatim: aString [
	"Do not attempt to translate the characters.  Use to override nextPutAll:"
	^ self nextPutAll: aString
]
