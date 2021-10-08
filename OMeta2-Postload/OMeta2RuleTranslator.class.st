Class {
	#name : #OMeta2RuleTranslator,
	#superclass : #OMeta2,
	#instVars : [
		'grammarClass'
	],
	#category : #OMeta2
}

{ #category : #rules }
OMeta2RuleTranslator >> act [ = string:x -> [{'('. x. ')'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> and [ = trans*:xs -> [{'(true ifTrue: ['. self delim: xs with: '. '. '])'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> app [ =

	symbol:rule
	(	anything+:args [self delim: args with: '. ']:args -> [{'(self apply: '. rule storeString. ' withArgs: {'. args. '})'}]
	|	[{'(self apply: '. rule storeString. ')'}]
	)
]

{ #category : #rules }
OMeta2RuleTranslator >> consby [ =

	trans:x -> [{'(self consumedBy: ['. x. '])'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> form [ =

	trans:x -> [{'(self form: ['. x. '])'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> idxconsby [ =

	trans:x -> [{'(self indexConsumedBy: ['. x. '])'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> lookahead [ =

	trans:x -> [{'(self lookahead: ['. x. '])'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> many [ =

	trans:x -> [{'(self many: ['. x. '])'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> many1 [ =

	trans:x -> [{'(self many1: ['. x. '])'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> not [ =

	trans:x -> [{'(self not: ['. x. '])'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> opt [ =

	trans:x -> [{'(self opt: ['. x. '])'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> or [ =

	(trans:x -> [{'['. x. ']'}])*:xs -> [{'(self ometaOr: {'. self delim: xs with: '. '. '})'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> pred [ =

	string:x -> [{'(self pred: ('. x. '))'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> rule [ =

	symbol:name
	anything:temps [temps select: [:t | (grammarClass instVarNames includes: t) not]]:temps
	trans:body
	-> [{name. ' |'. self delim: temps asSortedCollection with: ' '. ' | ^ '. body}]
]

{ #category : #rules }
OMeta2RuleTranslator >> set [ =

	symbol:n trans:v -> [{'('. n asString. ' := '. v. ')'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> squeak [ = string
]

{ #category : #rules }
OMeta2RuleTranslator >> superapp [ =

	symbol:rule anything*:args
	[self delim: args with: '. ']:args
	-> [{'(self super: '. grammarClass superclass name. ' apply: '. rule storeString. ' withArgs: {'. args. '})'}]
]

{ #category : #rules }
OMeta2RuleTranslator >> trans [ = {symbol:type apply(type asLowercase asSymbol):ans} -> [ans]
]

{ #category : #rules }
OMeta2RuleTranslator >> translate [ :grammarClass = trans
]
