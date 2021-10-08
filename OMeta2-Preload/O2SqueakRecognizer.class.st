Class {
	#name : #O2SqueakRecognizer,
	#superclass : #OMeta2,
	#classVars : [
		'TypeTable'
	],
	#category : #OMeta2
}

{ #category : #'as yet unclassified' }
O2SqueakRecognizer class >> initialize [

	TypeTable := #(#xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xDelimiter #xDelimiter #xBinary #xDelimiter #xDelimiter #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #doIt #xBinary #xDelimiter #xBinary #xDoubleQuote #xLitQuote #xDollar #xBinary #xBinary #xSingleQuote #leftParenthesis #rightParenthesis #xBinary #xBinary #xBinary #xBinary #period #xBinary #xDigit #xDigit #xDigit #xDigit #xDigit #xDigit #xDigit #xDigit #xDigit #xDigit #xColon #semicolon #xBinary #xBinary #xBinary #xBinary #xBinary #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #leftBracket #xBinary #rightBracket #upArrow #leftArrow #xBinary #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #leftBrace #verticalBar #rightBrace #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xLetter #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xBinary #xLetter #xBinary #xBinary #xBinary #xBinary #xLetter #xBinary #xBinary #xBinary #xBinary #xBinary #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xBinary #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xBinary #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xLetter #xBinary)
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> arrayConstr [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {'{'}.
							self apply: #expr.
							self
								many: [self ometaOr: {[true
											ifTrue: [self apply: #token withArgs: {'.'}.
												self apply: #expr]]}].
							self ometaOr: {[true
									ifTrue: [self apply: #token withArgs: {'.'}]]. [true
									ifTrue: [self apply: #empty]]}.
							self apply: #token withArgs: {'}'}]]. [true
						ifTrue: [self apply: #token withArgs: {'{'}.
							self apply: #token withArgs: {'}'}]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> arrayLit [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {'#'}.
							self apply: #token withArgs: {'('}.
							self
								many: [self ometaOr: {[true
											ifTrue: [self apply: #literal]]. [true
											ifTrue: [self apply: #arrayLit]]. [true
											ifTrue: [self apply: #spaces.
												self apply: #tsArraySymbol]]}].
							self apply: #token withArgs: {')'}]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> binary [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #spaces.
							self apply: #tsBinary]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> binaryExpr [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #binaryExpr.
							self apply: #binaryMsg]]. [true
						ifTrue: [self apply: #unaryExpr]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> binaryMsg [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #binary.
							self apply: #unaryExpr]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> block [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {'['}.
							self ometaOr: {[true
									ifTrue: [self
											many1: [self ometaOr: {[true
														ifTrue: [self apply: #token withArgs: {':'}.
															self apply: #identifier]]}].
										self apply: #token withArgs: {'|'}]]. [true
									ifTrue: [self apply: #empty]]}.
							self ometaOr: {[true
									ifTrue: [self apply: #token withArgs: {'|'}.
										self
											many: [self apply: #identifier].
										self apply: #token withArgs: {'|'}]]. [true
									ifTrue: [self apply: #empty]]}.
							self ometaOr: {[true
									ifTrue: [self apply: #expr.
										self
											many: [self ometaOr: {[true
														ifTrue: [self apply: #token withArgs: {'.'}.
															self apply: #expr]]}].
										self ometaOr: {[true
												ifTrue: [self apply: #token withArgs: {'.'}.
													self apply: #token withArgs: {'^'}.
													self apply: #expr]]. [true
												ifTrue: [self apply: #empty]]}]]. [true
									ifTrue: [self apply: #token withArgs: {'^'}.
										self apply: #expr]]. [true
									ifTrue: [self apply: #empty]]}.
							self ometaOr: {[true
									ifTrue: [self apply: #token withArgs: {'.'}]]. [true
									ifTrue: [self apply: #empty]]}.
							self apply: #token withArgs: {']'}]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> cascade [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #identifier]]. [true
						ifTrue: [self apply: #binaryMsg]]. [true
						ifTrue: [self apply: #keywordMsg]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> expr [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #identifier.
							self ometaOr: {[true
									ifTrue: [self apply: #token withArgs: {':='}]]. [true
									ifTrue: [self apply: #token withArgs: {'_'}]]}.
							self apply: #expr]]. [true
						ifTrue: [self apply: #msgExpr]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> identifier [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #spaces.
							self apply: #tsIdentifier.
							self
								not: [self apply: #exactly withArgs: {$:}]]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> keyword [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #spaces.
							self apply: #tsKeyword]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> keywordExpr [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #binaryExpr.
							self apply: #keywordMsg]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> keywordMsg [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #keywordMsg.
							self apply: #keywordMsgPart]]. [true
						ifTrue: [self apply: #keywordMsgPart]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> keywordMsgPart [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #keyword.
							self apply: #binaryExpr]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> literal [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #spaces.
							self ometaOr: {[true
									ifTrue: [self apply: #tsNumber]]. [true
									ifTrue: [self apply: #tsCharacter]]. [true
									ifTrue: [self apply: #tsString]]. [true
									ifTrue: [self apply: #tsSymbol]]}]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> method [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #expr.
							self ometaOr: {[true
									ifTrue: [self apply: #token withArgs: {'|'}.
										self
											many: [self apply: #identifier].
										self apply: #token withArgs: {'|'}]]. [true
									ifTrue: [self apply: #empty]]}.
							self ometaOr: {[true
									ifTrue: [self apply: #expr.
										self
											many: [self ometaOr: {[true
														ifTrue: [self apply: #token withArgs: {'.'}.
															self apply: #expr]]}].
										self ometaOr: {[true
												ifTrue: [self apply: #token withArgs: {'.'}.
													self apply: #token withArgs: {'^'}.
													self apply: #expr]]. [true
												ifTrue: [self apply: #empty]]}]]. [true
									ifTrue: [self apply: #token withArgs: {'^'}.
										self apply: #expr]]. [true
									ifTrue: [self apply: #empty]]}.
							self ometaOr: {[true
									ifTrue: [self apply: #token withArgs: {'.'}]]. [true
									ifTrue: [self apply: #empty]]}]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> msgExpr [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self ometaOr: {[true
									ifTrue: [self apply: #keywordExpr]]. [true
									ifTrue: [self apply: #binaryExpr]]}.
							self
								many: [self ometaOr: {[true
											ifTrue: [self apply: #token withArgs: {';'}.
												self apply: #cascade]]}]]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> squeakExpr [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								consumedBy: [self ometaOr: {[true
											ifTrue: [self apply: #expr]]}]]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> symbol [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #token withArgs: {'#'}.
							self apply: #spaces.
							self ometaOr: {[true
									ifTrue: [self apply: #tsString]]. [true
									ifTrue: [self apply: #tsKeyword.
										self ometaOr: {[true
												ifTrue: [self apply: #tsIdentifier]]. [true
												ifTrue: [self apply: #empty]]}]]}]]}]]}
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tcBinaryChar [
	| t1 |
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [t1 := self apply: #char.
							self pred: (TypeTable at: t1 asciiValue)
									== #xBinary]]}]]}
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsArraySymbol [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								many1: [self apply: #tsKeyword].
							self ometaOr: {[true
									ifTrue: [self apply: #tsIdentifier]]. [true
									ifTrue: [self apply: #empty]]}]]. [true
						ifTrue: [self apply: #tsIdentifier]]}]]}
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsBinary [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self ometaOr: {[true
									ifTrue: [self apply: #exactly withArgs: {$|}]]. [true
									ifTrue: [self apply: #tcBinaryChar]]}.
							self
								many: [self apply: #tcBinaryChar]]]}]]}
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsCharacter [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #exactly withArgs: {$$}.
							self apply: #char]]}]]}
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsIdentifier [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #letter.
							self
								many: [self ometaOr: {[true
											ifTrue: [self apply: #letter]]. [true
											ifTrue: [self apply: #digit]]}]]]}]]}
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsKeyword [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #tsIdentifier.
							self apply: #exactly withArgs: {$:}]]}]]}
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsNatural [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self
								many1: [self apply: #digit]]]}]]}
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsNumber [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self ometaOr: {[true
									ifTrue: [self apply: #exactly withArgs: {$+}]]. [true
									ifTrue: [self apply: #exactly withArgs: {$-}]]. [true
									ifTrue: [self apply: #empty]]}.
							self apply: #tsNatural]]}]]}
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsString [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #exactly withArgs: {$'}.
							self
								many: [self ometaOr: {[true
											ifTrue: [self apply: #exactly withArgs: {$'}.
												self apply: #exactly withArgs: {$'}]]. [true
											ifTrue: [self
													not: [self apply: #exactly withArgs: {$'}].
												self apply: #char]]}].
							self apply: #exactly withArgs: {$'}]]}]]}
]

{ #category : #'rules-lexing' }
O2SqueakRecognizer >> tsSymbol [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #exactly withArgs: {$#}.
							self apply: #spaces.
							self ometaOr: {[true
									ifTrue: [self apply: #tsString]]. [true
									ifTrue: [self apply: #tsArraySymbol]]}]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> unaryExpr [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #unit.
							self
								many: [self apply: #identifier]]]}]]}
]

{ #category : #'rules-parsing' }
O2SqueakRecognizer >> unit [
	^ self ometaOr: {[true
			ifTrue: [true.
				self ometaOr: {[true
						ifTrue: [self apply: #literal]]. [true
						ifTrue: [self apply: #identifier]]. [true
						ifTrue: [self apply: #arrayLit]]. [true
						ifTrue: [self apply: #arrayConstr]]. [true
						ifTrue: [self apply: #block]]. [true
						ifTrue: [self apply: #token withArgs: {'('}.
							self apply: #expr.
							self apply: #token withArgs: {')'}]]}]]}
]
