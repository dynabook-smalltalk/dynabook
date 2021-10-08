Class {
	#name : #OMeta2Compiler,
	#superclass : #Compiler,
	#category : #OMeta2
}

{ #category : #'as yet unclassified' }
OMeta2Compiler >> compile: origCode in: cls classified: aCategory notifying: notify ifFail: failBlock [

	^ self compile: origCode in: cls notifying: notify ifFail: failBlock
]

{ #category : #'as yet unclassified' }
OMeta2Compiler >> compile: origCode in: cls notifying: notify ifFail: failBlock [

	| origCodeStream parseTree structuredCode translatedCode |
	origCodeStream := origCode asString readStream.
	[self from: origCodeStream class: cls context: nil notifying: notify] on: Error do: [^failBlock value].
	[
		parseTree := OMeta2RuleParser matchStream: origCodeStream with: #rule withArgs: #() withPlaybackDebugging: false.
		parseTree := OMeta2Optimizer match: parseTree with: #optimizeRule.
		structuredCode := OMeta2RuleTranslator match: parseTree with: #translate withArgs: {cls}.
		translatedCode := OMeta2Flattener match: structuredCode with: #flatten
	] on: OM2Fail do: [
		self notify: '<-- parse error around here -->' at: origCodeStream position.
		^ failBlock value
	].
	^ Compiler new
		compile: translatedCode readStream
		in: cls
		notifying: notify
		ifFail: failBlock
]

{ #category : #'as yet unclassified' }
OMeta2Compiler >> parse: aStream class: aClass noPattern: noPattern context: ctxt notifying: req ifFail: aBlock [

	^ [
		| parseTree structuredCode code |
		parseTree := OMeta2RuleParser matchAll: aStream contents with: #rule.
		structuredCode := OMeta2RuleTranslator match: parseTree with: #translate withArgs: {aClass}.
		code := OMeta2Flattener match: structuredCode with: #flatten.
		Parser new parse: code readStream class: aClass noPattern: noPattern context: ctxt notifying: req ifFail: aBlock
	] on: OM2Fail do: [aBlock value]
]

{ #category : #compiling }
OMeta2Compiler >> parseCue: aCompilationCue noPattern: aBoolean ifFail: aBlockClosure [ 
		^ [
		| parseTree structuredCode code |
		parseTree := OMeta2RuleParser matchAll: aCompilationCue sourceStream contents with: #rule.
		structuredCode := OMeta2RuleTranslator match: parseTree with: #translate withArgs: {aCompilationCue getClass}.
		code := OMeta2Flattener match: structuredCode with: #flatten.
		Parser new parseCue: (aCompilationCue shallowCopy sourceStream: code readStream;yourself) noPattern: aBoolean ifFail: aBlockClosure
	] on: OM2Fail do: [aBlockClosure value]
]

{ #category : #'as yet unclassified' }
OMeta2Compiler >> parser [
	^ self parserClass new
]

{ #category : #'as yet unclassified' }
OMeta2Compiler >> parserClass [

	^ self class
]
