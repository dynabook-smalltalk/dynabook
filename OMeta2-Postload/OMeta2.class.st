"
TODOS:

* implement OMeta -> Squeak translator
* implement Squeak parser
* implement OMeta/Squeak ""compiler"", make it OMeta2's compilerClass

* rewrite #char, #digit, #empty, #end, #exactly, #firstAndRest, #fromTo, #letter, #letterOrDigit, #listOf, #lower, #notLast, #number, #range, #space, #spaces, #string, #symbol, #token, and #upper in OMeta syntax
* consider implementing position-related functionality (see http://www.tinlizzie.org/ometa-js/ometa-base.js)
* consider the optimization suggestions in the comments of OMeta2Lib's methods
"
Class {
	#name : #OMeta2,
	#superclass : #OMeta2Base,
	#category : #OMeta2
}

{ #category : #rules }
OMeta2 >> char [ =

	anything:x ?[x isCharacter] -> [x]
]

{ #category : #rules }
OMeta2 >> digit [ =

	char:x ?[x isDigit] -> [x]
]

{ #category : #rules }
OMeta2 >> end [ =

	~anything
]

{ #category : #'rules-meta' }
OMeta2 >> exactly [ :wanted =

	anything:got ?[wanted = got] -> [wanted]
]

{ #category : #rules }
OMeta2 >> fromTo [ :x :y =

	seq(x) (~seq(y) char)* seq(y)
]

{ #category : #rules }
OMeta2 >> letter [ =

	char:x ?[x isLetter] -> [x]
]

{ #category : #rules }
OMeta2 >> letterOrDigit [ =

	char:x ?[x isAlphaNumeric] -> [x]
]

{ #category : #'rules-meta' }
OMeta2 >> listOf [ :rule :delim =

		apply(rule):x (token(delim) apply(rule))*:xs -> [xs addFirst: x; yourself]
	|	empty -> [#()]
]

{ #category : #rules }
OMeta2 >> lower [ =

	char:x ?[x isLowercase] -> [x]
]

{ #category : #'rules-meta' }
OMeta2 >> notLast [ :rule =

	apply(rule):ans &apply(rule) -> [ans]
]

{ #category : #rules }
OMeta2 >> number [ =

	anything:x ?[x isNumber] -> [x]
]

{ #category : #'rules-meta' }
OMeta2 >> range [ :a :b =

	anything:x ?[a <= x & x <= b] -> [x]
]

{ #category : #rules }
OMeta2 >> space [ =

	char:x ?[x asciiValue <= 32] -> [x]
]

{ #category : #rules }
OMeta2 >> spaces [ =

	space*
]

{ #category : #rules }
OMeta2 >> string [ =

	anything:x ?[x isString] -> [x]
]

{ #category : #rules }
OMeta2 >> symbol [ =

	anything:x ?[x isSymbol] -> [x]
]

{ #category : #'rules-meta' }
OMeta2 >> token [ :t =

	spaces seq(t)
]

{ #category : #rules }
OMeta2 >> upper [ =

	char:x ?[x isUppercase] -> [x]
]
