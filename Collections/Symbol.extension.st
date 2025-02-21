Extension { #name : #Symbol }

{ #category : #'*Collections-SortFunctions-converting' }
Symbol >> asSortFunction [
	"Return a SortFunction around the receiver, where the receiver will be used as a unary message to send to both a and b during sorting, and then the result of said send will be collated in ascending order using the <=> method."
	"#('abc' 'de' 'fghi') sorted: #size ascending >>> #('de' 'abc' 'fghi')"

	^PropertySortFunction property: self
]

{ #category : #'*Collections-SortFunctions-converting' }
Symbol >> ascending [
	"Return a SortFunction around the receiver, where the receiver will be used as a unary message to send to both a and b during sorting, and then the result of said send will be collated in ascending order using the <=> method."
	"#('abc' 'de' 'fghi') sorted: #size ascending >>> #('de' 'abc' 'fghi')"

	^self asSortFunction 
]

{ #category : #'*Collections-SortFunctions-converting' }
Symbol >> collatedBy: aSortFunction [
	"Return a SortFunction around the receiver, where the receiver will be used as a unary message to send to both a and b during sorting, and then the result of said send will be collated iusing aSortFunction."
	"#('abc' 'de' 'fghi') sorted: (#size collatedWith: [:e|e bitAnd: 1]) , #size >>> #( 'de' 'fghi' 'abc')"

	^PropertySortFunction property: self collatedWith: aSortFunction asSortFunction
]

{ #category : #'*Collections-SortFunctions-converting' }
Symbol >> descending [
	"Return a SortFunction around the receiver, where the receiver will be used as a unary message to send to both a and b during sorting, and then the result of said send will be collated in descending order using the <=> method."
	"#('abc' 'de' 'fghi') sorted: #size ascending >>> #('fghi' 'abc' 'de')"

	^self asSortFunction reversed
]
