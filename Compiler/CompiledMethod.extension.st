Extension { #name : #CompiledMethod }

{ #category : #'*Compiler-support' }
CompiledMethod >> blockExtentsInto: aDictionary from: initialPC to: endPC method: method numberer: numbererBlock [
	"Support routine for startpcsToBlockExtents"
	| pcs extentStart locator scanner blockSizeOrMethodOrLocator |
	self flag: 'belongs in DebuggerMethodMap'.
	extentStart := numbererBlock value.
	locator := BlockStartLocator new.
	scanner := InstructionStream new method: method pc: initialPC.
	pcs := OrderedCollection new.
	[pcs addLast: scanner pc.
	 scanner pc <= endPC] whileTrue:
		[blockSizeOrMethodOrLocator := scanner interpretNextInstructionFor: locator.
		 blockSizeOrMethodOrLocator ~~ locator ifTrue:
			 [blockSizeOrMethodOrLocator isInteger
				ifTrue:
					[self
						blockExtentsInto: aDictionary
						from: scanner pc
						to: scanner pc + blockSizeOrMethodOrLocator - 1
						method: method
						numberer: numbererBlock.
					 scanner pc: scanner pc + blockSizeOrMethodOrLocator]
				ifFalse:
					[self assert: blockSizeOrMethodOrLocator isCompiledBlock.
					 self
						blockExtentsInto: aDictionary
						from: blockSizeOrMethodOrLocator initialPC
						to: blockSizeOrMethodOrLocator endPC
						method: blockSizeOrMethodOrLocator
						numberer: numbererBlock]]].
	aDictionary
		at: (method isCompiledBlock
				ifTrue: [method]
				ifFalse: [initialPC])
		put: (extentStart to: numbererBlock value).
	^aDictionary
]

{ #category : #'*Compiler-support' }
CompiledMethod >> mapFromBlockKeys: keys toSchematicTemps: schematicTempNamesString [
	"Decode a schematicTempNamesString that encodes the layout of temp names
	 in a method and any closures/blocks within it, matching keys in keys to
	 vectors of temp names."
	| map tempNames |
	map := self newBlockStartMap.
	tempNames := schematicTempNamesString readStream.
	keys do:
		[:key| | tempSequence tempIndex |
		tempSequence := OrderedCollection new.
		tempIndex := 0.
		[(tempNames skipSeparators; peek) ifNil: [true] ifNotNil: [:ch| '[]' includes: ch]] whileFalse:
			[tempNames peek = $(
				ifTrue: [tempSequence addAllLast: ((self tempsSubSequenceFrom: (tempNames next; yourself)) withIndexCollect:
														[:temp :index|
														{ temp. { tempIndex + 1. index } }]).
						tempNames peek ~= $) ifTrue: [self error: 'parse error'].
						tempIndex := tempIndex + 1.
						tempNames next]
				ifFalse: [tempSequence addAllLast: ((self tempsSubSequenceFrom: tempNames) withIndexCollect:
														[:temp :index|
														{ temp. tempIndex := tempIndex + 1 }])]].
		map at: key put: tempSequence asArray.
		[tempNames peek = $]] whileTrue: [tempNames next].
		tempNames peek = $[ ifTrue:
			[tempNames next]].
	^map
]

{ #category : #'*Compiler-private' }
CompiledMethod >> newBlockStartMap [
	"If blocks are embedded then keys in the map are simple integer pcs and a Dictionary can be used.
	 If blocks are full (separate method objects) then keys in the map are CompiledBlocks and
	 IdentityDictionary must be used to avoid confusing blocks with identical code."
	^(self encoderClass supportsFullBlocks
		ifTrue: [IdentityDictionary]
		ifFalse: [Dictionary]) new
]

{ #category : #'*Compiler-support' }
CompiledMethod >> startKeysToBlockExtents [
	"Answer a Dictionary of start key to Interval of blockExtent, using the
	 identical numbering scheme described in and orchestrated by
	 BlockNode>>analyseArguments:temporaries:rootNode:.  A start key
	 identifies a block within a method and is either the startpc for an
	 embedded block or the block method itself for a full block. This is
	 used in part to find the temp names for any block in a method, as
	 needed by the debugger.  The other half is to recompile the method,
	 obtaining the temp names for each block extent.  By indirecting through
	 the blockExtent instead of using the startpc directly we decouple the
	 debugger's access to temp names from the exact bytecode; insulating
	 debugging from minor changes in the compiler (e.g. changes in literal
	 pooling, adding prefix bytecodes, adding inst vars to CompiledMethod
	 in literals towards the end of the literal frame, etc).  If the recompilation
	 doesn't produce exactly the same bytecode at exactly the same offset
	 no matter; the blockExtents will be the same."
	| index |
	self flag: 'belongs in DebuggerMethodMap'.
	index := 0.
	^self
		blockExtentsInto: self newBlockStartMap
		from: self initialPC
		to: self endPC
		method: self
		numberer: [| value | value := index. index := index + 2. value]
]
