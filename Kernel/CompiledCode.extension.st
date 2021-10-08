Extension { #name : #CompiledCode }

{ #category : #'*Kernel-tool support' }
CompiledCode >> hasBreakpoint [
	^ self class environment
		at: #BreakpointManager
		ifPresent: [:bpm | bpm methodHasBreakpoint: self]
		ifAbsent: [false]
]
