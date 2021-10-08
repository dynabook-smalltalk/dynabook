Class {
	#name : #OMeta2RuleParser,
	#superclass : #OMeta2,
	#instVars : [
		'temps'
	],
	#category : #OMeta2
}

{ #category : #rules }
OMeta2RuleParser >> application [ =

	"^" name:rule args:as				-> [{#SuperApp. rule}, as]
|	name:grm $. nsName:rule args:as	-> [{#App. #foreign. grm. ('#', rule) asSymbol}, as]
|	name:rule args:as						-> [{#App. rule}, as]
]

{ #category : #rules }
OMeta2RuleParser >> args [ =

	$( listOf(#squeakExpression. '.'):ans ")" -> [ans]
|	~$( -> [#()]
]

{ #category : #rules }
OMeta2RuleParser >> characterLiteral [ =

	spaces $$ char:c -> [{#App. #exactly. c storeString}]
]

{ #category : #rules }
OMeta2RuleParser >> characters [ =

	"``" (~($' $') char)*:xs $' $' -> [{#App. #seq. (String withAll: xs) storeString}]
]

{ #category : #rules }
OMeta2RuleParser >> expr [ =

	listOf(#expr4. '|'):xs -> [(OrderedCollection with: #Or) addAll: xs; yourself]
]

{ #category : #rules }
OMeta2RuleParser >> expr1 [ =

	(keyword('true') | keyword('false') | keyword('nil')):lit -> [{#App. #exactly. lit}]
|	application
|	semanticAction
|	semanticPredicate
|	characters
|	tokenSugar
|	stringLiteral
|	symbolLiteral
|	numberLiteral
|	characterLiteral
|	"{"  expr:e "}" -> [{#Form. e}]
|	"<"  expr:e ">" -> [{#ConsBy. e}]
|	"@<" expr:e ">" -> [{#IdxConsBy. e}]
|	"("  expr:e ")" -> [e]
]

{ #category : #rules }
OMeta2RuleParser >> expr2 [ =

	"~" expr2:x -> [{#Not. x}]
|	"&" expr2:x -> [{#Lookahead. x}]
|	expr1
]

{ #category : #rules }
OMeta2RuleParser >> expr3 [ =

	expr2:x optIter(x):x
		(	$: nsName:n [temps add: n]	-> [{#Set. n. x}]
		|	empty								-> [x]
		)
|	":" nsName:n [temps add: n]			-> [{#Set. n. {#App. #anything}}]
]

{ #category : #rules }
OMeta2RuleParser >> expr4 [ =

	expr3*:xs -> [(OrderedCollection with: #And) addAll: xs; yourself]
]

{ #category : #'rules-meta' }
OMeta2RuleParser >> keyword [ :xs =

	token(xs) ~letterOrDigit -> [xs]
]

{ #category : #rules }
OMeta2RuleParser >> name [ =

	spaces nsName
]

{ #category : #rules }
OMeta2RuleParser >> nameFirst [ =

	letter
]

{ #category : #rules }
OMeta2RuleParser >> nameRest [ =

	nameFirst | digit
]

{ #category : #rules }
OMeta2RuleParser >> nsName [ =

	firstAndRest(#nameFirst. #nameRest):xs -> [(String withAll: xs) asSymbol]
|	$_ -> [#anything]
]

{ #category : #rules }
OMeta2RuleParser >> numberLiteral [ =

	spaces ($- spaces -> [-1] | empty -> [1]):sign digit+:ds
		-> [{#App. #exactly. (sign * (String withAll: ds) asNumber) storeString}]
]

{ #category : #'rules-meta' }
OMeta2RuleParser >> optIter [ :x =

	"*"		-> [{#Many.  x}]
|	"+"		-> [{#Many1. x}]
|	"?" ~$[	-> [{#Opt. x}]
|	empty		-> [x]
]

{ #category : #rules }
OMeta2RuleParser >> rule [ =

	~(^space* nsName expr4 "=") <char*>:squeakCode -> [{#Squeak. squeakCode}]
|	&(^space* nsName):n rulePart(n):x ("," rulePart(n))*:xs spaces end
		-> [{#Rule. n. temps asSortedCollection. (OrderedCollection with: #Or with: x) addAll: xs; yourself}]
]

{ #category : #'rules-meta' }
OMeta2RuleParser >> rulePart [ :ruleName =

	name:n ?[n = ruleName] expr4:b1
		(	"=" expr:b2	-> [{#And. b1. b2}]
		|	empty			-> [b1]
		)
]

{ #category : #rules }
OMeta2RuleParser >> semanticAction [ =

	"->"? "[" squeakExpression:e $] -> [{#Act. e}]
]

{ #category : #rules }
OMeta2RuleParser >> semanticPredicate [ =

	"?[" squeakExpression:e $] -> [{#Pred. e}]
]

{ #category : #rules }
OMeta2RuleParser >> space [ =

	^space | fromTo('/*'. '*/') | fromTo('//'. String cr)
]

{ #category : #rules }
OMeta2RuleParser >> squeakExpression [ =

	O2SqueakRecognizer.squeakExpr:ans spaces -> [ans]
]

{ #category : #rules }
OMeta2RuleParser >> stringLiteral [ =

	"'" ($' $' -> [$'] | ~$' char)*:xs $' -> [{#App. #exactly. (String withAll: xs) storeString}]
]

{ #category : #rules }
OMeta2RuleParser >> symbolLiteral [ =

	// TODO: make this accept, e.g., #foo:bar:
	"#" nsName:s -> [{#App. #exactly. s storeString}]
]

{ #category : #rules }
OMeta2RuleParser >> tokenSugar [ =

	token('"') (~$" char)*:xs $" -> [{#App. #token. (String withAll: xs) storeString}]
]
