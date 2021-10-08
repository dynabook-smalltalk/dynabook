Class {
	#name : #O2SqueakRecognizer,
	#superclass : #OMeta2,
	#classVars : [
		'TypeTable'
	],
	#category : #OMeta2
}

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> arrayConstr [ =

	"{" expr ("." expr)* ("." | empty) "}"
|	"{" "}"
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> arrayLit [ =

	"#" "(" (literal | arrayLit | spaces tsArraySymbol)* ")"
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> binary [ =

	spaces tsBinary
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> binaryExpr [ =

	binaryExpr binaryMsg
|	unaryExpr
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> binaryMsg [ =

	binary unaryExpr
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> block [ =

	"["
		(	(":" identifier)+ "|"
		|	empty
		)

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

	"]"
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> cascade [ =

	identifier
|	binaryMsg
|	keywordMsg
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> expr [ =

	identifier (":=" | "_") expr
|	msgExpr
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> identifier [ =

	spaces tsIdentifier ~$:
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> keyword [ =

	spaces tsKeyword
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> keywordExpr [ =

	binaryExpr keywordMsg
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> keywordMsg [ =

	keywordMsg keywordMsgPart
|	keywordMsgPart
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> keywordMsgPart [ =

	keyword binaryExpr
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> literal [ =

	spaces
		(	tsNumber
		|	tsCharacter
		|	tsString
		|	tsSymbol
		)

]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> method [ =
expr

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

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> msgExpr [ =

	(keywordExpr | binaryExpr) (";" cascade)*
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> squeakExpr [ =

	<expr>
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> symbol [ =

	"#" spaces
		(	tsString
		|	tsKeyword (tsIdentifier | empty)
		)
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tcBinaryChar [ =

	char:x ?[(TypeTable at: x asciiValue) == #xBinary]
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsArraySymbol [ =

	tsKeyword+ (tsIdentifier | empty)
|	tsIdentifier
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsBinary [ =

	($| | tcBinaryChar) tcBinaryChar*
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsCharacter [ =

	$$ char
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsIdentifier [ =

	letter (letter | digit)*
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsKeyword [ =

	tsIdentifier $:
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsNatural [ =

	digit+
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsNumber [ =

	($+ | $- | empty) tsNatural
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsString [ =

	$' ($' $' | ~$' char)* $'
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsSymbol [ =

	$# spaces (tsString | tsArraySymbol)
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> unaryExpr [ =

	unit identifier*
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> unit [ =

	literal
|	identifier
|	arrayLit
|	arrayConstr
|	block
|	"(" expr ")"

]
