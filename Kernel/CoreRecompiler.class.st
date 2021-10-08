Class {
	#name : #CoreRecompiler,
	#superclass : #O2SqueakRecognizer,
	#instVars : [
		'methodId',
		'methodObject'
	],
	#category : #'Kernel-Methods'
}

{ #category : #accessing }
CoreRecompiler >> expr [ =

	var (":=" | "_") expr
|	(msgExpr:x -> ['Smalltalk trace: #o', (x hash printStringBase: 36) ,'in: #', methodId, 'as: [', x, '].'])
]

{ #category : #accessing }
CoreRecompiler >> method [ =
expr
(() -> ['Smalltalk trace: #', methodId, '.'])
		(	"|" identifier* "|"
		|	empty
		)

		(	expr ("." expr)* ("." "^" expr | empty)
		|	"^" expr
		|	empty
		)

		(	"."
		|	empty
		)
]

{ #category : #accessing }
CoreRecompiler >> methodId [

	^ methodId
]

{ #category : #accessing }
CoreRecompiler >> methodId: anObject [

	methodId := anObject.
]

{ #category : #accessing }
CoreRecompiler >> methodObject [

	^ methodObject
]

{ #category : #accessing }
CoreRecompiler >> methodObject: anObject [

	methodObject := anObject.
]

{ #category : #accessing }
CoreRecompiler >> unit [ =

	literal
|	var
|	arrayLit
|	arrayConstr
|	block
|	"(" expr ")"
]

{ #category : #accessing }
CoreRecompiler >> var [ =
identifier
]
