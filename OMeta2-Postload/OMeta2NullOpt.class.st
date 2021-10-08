Class {
	#name : #OMeta2NullOpt,
	#superclass : #OMeta2,
	#instVars : [
		'didSomething'
	],
	#category : #OMeta2
}

{ #category : #rules }
OMeta2NullOpt >> and [ = trans*:xs -> [xs addFirst: #And; yourself]
]

{ #category : #rules }
OMeta2NullOpt >> consby [ = trans:x -> [{#ConsBy. x}]
]

{ #category : #rules }
OMeta2NullOpt >> form [ = trans:x -> [{#Form. x}]
]

{ #category : #rules }
OMeta2NullOpt >> helped [ = ?[didSomething]
]

{ #category : #rules }
OMeta2NullOpt >> idxconsby [ = trans:x -> [{#IdxConsBy. x}]
]

{ #category : #rules }
OMeta2NullOpt >> lookahead [ = trans:x -> [{#Lookahead. x}]
]

{ #category : #rules }
OMeta2NullOpt >> many [ = trans:x -> [{#Many. x}]
]

{ #category : #rules }
OMeta2NullOpt >> many1 [ = trans:x -> [{#Many1. x}]
]

{ #category : #rules }
OMeta2NullOpt >> not [ = trans:x -> [{#Not. x}]
]

{ #category : #rules }
OMeta2NullOpt >> opt [ = trans:x -> [{#Opt. x}]
]

{ #category : #rules }
OMeta2NullOpt >> optimize [ = trans:x helped -> [x]
]

{ #category : #rules }
OMeta2NullOpt >> or [ = trans*:xs -> [xs addFirst: #Or; yourself]
]

{ #category : #rules }
OMeta2NullOpt >> rule [ = _:name _:temps trans:body -> [{#Rule. name. temps. body}]
]

{ #category : #rules }
OMeta2NullOpt >> set [ = _:name trans:val -> [{#Set. name. val}]
]

{ #category : #rules }
OMeta2NullOpt >> setHelped [ = [didSomething := true]
]

{ #category : #rules }
OMeta2NullOpt >> trans [ =

	{:t [t asLowercase asSymbol]:t ?[self class canUnderstand: t] apply(t):ans} -> [ans]
|	_
]
