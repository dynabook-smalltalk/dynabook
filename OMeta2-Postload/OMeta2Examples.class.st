"
Here's how to run these examples:

	OMeta2Examples match: 5 with: #fact.
	OMeta2Examples matchAll: '1234' with: #number.
	OMeta2Examples matchAll: 'abc123' with: #identifier.
	OMeta2Examples matchAll: #($a $b $c 1 2 3 #(4 5)) with: #structure.
	OMeta2Examples matchAll: 'howdy' with: #greeting.
"
Class {
	#name : #OMeta2Examples,
	#superclass : #OMeta2,
	#category : #OMeta2
}

{ #category : #rules }
OMeta2Examples >> digit [ =

	// this example shows the new syntax for super rule applications
	// think of the ^ as an arrow that's pointing up to the parent grammar

	^digit:d -> [d digitValue]
]

{ #category : #rules }
OMeta2Examples >> fact [ 0 = [1],
fact _:n = fact(n - 1):m -> [n * m]

// this example shows that rules can have multiple definitions (they are tried in order)

]

{ #category : #rules }
OMeta2Examples >> formTest [ =

	{[self inform: input hash printString] #foo #bar}
|	{[self inform: input hash printString] #bar}
]

{ #category : #rules }
OMeta2Examples >> greeting [ = <``howdy'' ``-ho''?>
]

{ #category : #rules }
OMeta2Examples >> identifier [ =

	// this is an example of the new <> operator

	spaces <letter (letter | digit)*>
]

{ #category : #rules }
OMeta2Examples >> identifierIdx [ =

	// this is an example of the new @<> operator

	spaces @<letter (letter | digit)*>
]

{ #category : #rules }
OMeta2Examples >> identifiers [ =

	([self inform: self pos printString] identifier)*
]

{ #category : #rules }
OMeta2Examples >> number [ =

	// this is an example of left recursion support

	number:n digit:d -> [n * 10 + d]
|	digit
]

{ #category : #rules }
OMeta2Examples >> structure [ =

	// this example shows how the {}s are used for matching sequenceable collections

	$a $b $c 1 2 3 {anything*}
]
