Class {
	#name : #CompiledSandbox,
	#superclass : #O2SqueakRecognizer,
	#instVars : [
		'appId'
	],
	#category : #'Kernel-Sandboxing'
}

{ #category : #accessing }
CompiledSandbox >> appId [

	^ appId
]

{ #category : #accessing }
CompiledSandbox >> appId: anObject [

	appId := anObject.
]

{ #category : #'as yet unclassified' }
CompiledSandbox >> binary [ =
^binary:x -> ['perform: #''/', appId, '/', x, ''' with:']
]

{ #category : #'as yet unclassified' }
CompiledSandbox >> binaryExpr [ =

	(binaryExpr binaryMsg):x -> ['(', x, ')']
|	unaryExpr
]

{ #category : #'as yet unclassified' }
CompiledSandbox >> cascade [ =

	identifier:x -> ['perform: #''/', appId, '/', x, '''']
|	binaryMsg
|	keywordMsg
]

{ #category : #'as yet unclassified' }
CompiledSandbox >> keywordMsg [ =
keywordMsgPart*:x [x collect: #first]:a [x collect: #second]:b -> ['perform: #''/', appId, '/', a concatenation, ''' withArguments: {', ((b collect: [:c|c, ' . ']) concatenation), '}']
]

{ #category : #'as yet unclassified' }
CompiledSandbox >> keywordMsgPart [ =

	keyword:a binaryExpr:b -> [{a. a, b}]
]

{ #category : #'as yet unclassified' }
CompiledSandbox >> unaryExpr [ =

	(unaryExpr (identifier:x -> ['perform: #''/', appId, '/', x, ''''])):y -> ['(', y , ')'] |
	unit
]
