"
NumberParser is an abstract class for parsing and building numbers from string/stream.
It offers a framework with utility methods and exception handling.

Number syntax is not defined and should be subclassResponsibility.

Instance variables:
sourceStream <Stream> the stream of characters from which the number is read
base <Integer> the radix in which to interpret digits
neg <Boolean> true in case of minus sign
integerPart <Integer> the integer part of the number
fractionPart <Integer> the fraction part of the number if any
exponent <Integer> the exponent used in scientific notation if any
scale <Integer> the scale used in case of ScaledDecimal number if any
nDigits <Integer> number of digits read to form an Integer
lasNonZero <Integer> position of last non zero digit, starting at 1 from left, 0 if all digits are zero
requestor <TextEditor | nil> can be used to insert an error message in the requestor
failBlock <BlockClosure> Block to execute whenever an error occurs.
	The fail block can have 0, 1 or 2 arguments (errorString and source position)

"
Class {
	#name : #NumberParser,
	#superclass : #Object,
	#instVars : [
		'sourceStream',
		'base',
		'neg',
		'integerPart',
		'fractionPart',
		'exponent',
		'scale',
		'nDigits',
		'lastNonZero',
		'requestor',
		'failBlock'
	],
	#category : #'Kernel-Numbers'
}

{ #category : #'instance creation' }
NumberParser class >> on: aStringOrStream [
	^self new on: aStringOrStream
]

{ #category : #'instance creation' }
NumberParser class >> parse: aStringOrStream [ 
	^(self new)
		on: aStringOrStream;
		nextNumber
]

{ #category : #'instance creation' }
NumberParser class >> parse: aStringOrStream onError: failBlock [ 
	^(self new)
		on: aStringOrStream;
		failBlock: failBlock;
		nextNumber
]

{ #category : #accessing }
NumberParser >> allowPlusSign [
	"return a boolean indicating if plus sign is allowed or not"

	^self subclassResponsibility
]

{ #category : #accessing }
NumberParser >> allowPlusSignInExponent [
	"return a boolean indicating if plus sign is allowed or not in exponent"

	^self allowPlusSign
]

{ #category : #error }
NumberParser >> error: aString [
	NumberParserError signal: aString
]

{ #category : #error }
NumberParser >> expected: aString [ 
	| errorString |
	errorString := aString , ' expected'.
	requestor isNil
		ifFalse: [requestor
				notify: errorString
				at: sourceStream position + 1
				in: sourceStream].
	failBlock ifNotNil: [^failBlock cull: errorString cull: sourceStream position + 1].
	self error: 'Reading a number failed: ' , errorString
]

{ #category : #accessing }
NumberParser >> exponentLetters [
	"answer the list of possible exponents for Numbers."

	^self subclassResponsibility
]

{ #category : #accessing }
NumberParser >> failBlock: aBlockOrNil [
	failBlock := aBlockOrNil
]

{ #category : #testing }
NumberParser >> isExponentLetter: aCharacter [

	^self exponentLetters includes: aCharacter
]

{ #category : #'parsing-private' }
NumberParser >> makeFloatFromMantissa: m exponent: k base: aRadix [ 
	"Convert infinite precision arithmetic into Floating point.
	This alogrithm rely on correct IEEE rounding mode
	being implemented in Integer>>asFloat and Fraction>>asFloat"

	k = 0 ifTrue: [ ^m asFloat ].
	k > 0 ifTrue: [ ^(m * (aRadix raisedToInteger: k)) asFloat ].
	^(Fraction numerator: m denominator: (aRadix raisedToInteger: k negated)) asFloat
]

{ #category : #'parsing-private' }
NumberParser >> makeScaledDecimalWithNumberOfNonZeroFractionDigits: numberOfNonZeroFractionDigits andNumberOfTrailingZeroInFractionPart: numberOfTrailingZeroInFractionPart [
	"at this point integerPart fractionPart and scale have been read out (in inst var).
	Form a ScaledDecimal.
	Care of eliminating trailing zeroes from the fractionPart"
	
	| decimalMultiplier decimalFraction |
	decimalMultiplier := base raisedToInteger: numberOfNonZeroFractionDigits.
	decimalFraction := integerPart * decimalMultiplier + (fractionPart // (base raisedTo: numberOfTrailingZeroInFractionPart)) / decimalMultiplier.
	^ ScaledDecimal
		newFromNumber: (neg
			ifTrue: [decimalFraction negated]
			ifFalse: [decimalFraction])
		scale: scale
]

{ #category : #'parsing-large int' }
NumberParser >> nextElementaryLargeIntegerBase: aRadix [
	"Form an unsigned integer with incoming digits from sourceStream.
	Return this integer, or zero if no digits found.
	Stop reading if end of digits or if a LargeInteger is formed.
	Count the number of digits and the position of lastNonZero digit and store them in instVar."

	| value digit char |
	value := 0.
	nDigits := 0.
	lastNonZero := 0.
	[
		value isLarge ifTrue: [ ^value ].
		char := sourceStream next ifNil: [ ^value ].
		((digit := char digitValue) < 0 or: [digit >= aRadix]) ifTrue: [
			sourceStream skip: -1.
			^value ].
		nDigits := nDigits + 1.
		digit = 0
			ifFalse: [
				lastNonZero := nDigits.
				value := value * aRadix + digit ]
			ifTrue: [ value := value * aRadix ] ] repeat
]

{ #category : #'parsing-public' }
NumberParser >> nextInteger [
	"Read an Integer from sourceStream, asnwser that Integer.
	This is a generic version dealing with an optional sign and a simple sequence of decimal digits.
	Subclass might define extended syntax."
	
	base := 10.
	^self nextIntegerBase: base ifFail: [^self expected: ('a digit between 0 and ' copyWith: (Character digitValue: base - 1))]
]

{ #category : #'parsing-public' }
NumberParser >> nextIntegerBase: aRadix [
	"Form an integer with following digits.
	Fail if no digit found"
	
	| isNeg value |
	isNeg := self peekSignIsMinus.
	value := self nextUnsignedIntegerBase: aRadix.
	^isNeg
		ifTrue: [value negated]
		ifFalse: [value]
]

{ #category : #'parsing-public' }
NumberParser >> nextIntegerBase: aRadix ifFail: aBlock [
	"Form an integer with optional sign and following digits from sourceStream."
	
	| isNeg value |
	isNeg := self peekSignIsMinus.
	value := self nextUnsignedIntegerOrNilBase: aRadix.
	value ifNil: [^aBlock value].
	^isNeg
		ifTrue: [value negated]
		ifFalse: [value]
]

{ #category : #'parsing-large int' }
NumberParser >> nextLargeIntegerBase: aRadix nPackets: nPackets [ 
	"Form a Large integer with incoming digits from sourceStream.
	Return this integer, or zero if no digits found.
	Stop reading when no more digits or when nPackets elementary LargeInteger have been encountered.
	Count the number of digits and the lastNonZero digit and store them in instVar"
	
	| high nDigitsHigh lastNonZeroHigh low nDigitsLow halfPackets |
	halfPackets := nPackets bitShift: -1.
	halfPackets = 0 ifTrue: [^self nextElementaryLargeIntegerBase: aRadix].
	high := self nextLargeIntegerBase: aRadix nPackets: halfPackets.
	high isLarge ifFalse: [^high].
	nDigitsHigh := nDigits.
	lastNonZeroHigh := lastNonZero.
	low := self nextLargeIntegerBase: aRadix nPackets: halfPackets.
	nDigitsLow := nDigits.
	nDigits := nDigitsHigh + nDigitsLow.
	lastNonZero := lastNonZero = 0
		ifTrue: [lastNonZeroHigh]
		ifFalse: [lastNonZero + nDigitsHigh].
	^high * (aRadix raisedToInteger: nDigitsLow) + low
]

{ #category : #'parsing-public' }
NumberParser >> nextNumber [
	"read next number from sourceStream contents"

	^self subclassResponsibility
]

{ #category : #'parsing-public' }
NumberParser >> nextUnsignedInteger [
	"Read an Integer from sourceStream, asnwser that Integer.
	This is a generic version dealing with a simple sequence of decimal digits.
	Subclass might define extended syntax."
	
	base := 10.
	^self nextUnsignedIntegerBase: base ifFail: [^self expected: ('a digit between 0 and ' copyWith: (Character digitValue: base - 1))]
]

{ #category : #'parsing-public' }
NumberParser >> nextUnsignedIntegerBase: aRadix [ 
	"Form an unsigned integer with incoming digits from sourceStream.
	Fail if no digit found.
	Count the number of digits and the lastNonZero digit and store int in instVar "
	
	| value |
	value := self nextUnsignedIntegerOrNilBase: aRadix.
	value ifNil: [^self expected: ('a digit between 0 and ' copyWith: (Character digitValue: aRadix - 1))].
	^value
]

{ #category : #'parsing-public' }
NumberParser >> nextUnsignedIntegerBase: aRadix ifFail: errorBlock [
	"Form an unsigned integer with incoming digits from sourceStream.
	Answer this integer, or execute errorBlock if no digit found.
	Count the number of digits and the position of lastNonZero digit and store them in instVar"
	
	| value |
	value := self nextUnsignedIntegerOrNilBase: aRadix.
	value ifNil: [^errorBlock value].
	^value
]

{ #category : #'parsing-public' }
NumberParser >> nextUnsignedIntegerOrNilBase: aRadix [
	"Form an unsigned integer with incoming digits from sourceStream.
	Answer this integer, or nil if no digit found.
	Count the number of digits and the position of lastNonZero digit and store them in instVar"
	
	| nPackets high nDigitsHigh lastNonZeroHigh low |
	"read no more digits than one elementary LargeInteger"
	high :=  self nextElementaryLargeIntegerBase: aRadix.
	nDigits = 0 ifTrue: [^nil].
	
	"Not enough digits to form a LargeInteger, stop iteration"
	high isLarge ifFalse: [^high].

	"We now have to engage arithmetic with LargeInteger
	Decompose the integer in a high and low packets of growing size:"
	nPackets := 1.
	nDigitsHigh := nDigits.
	lastNonZeroHigh := lastNonZero.
	[
	low := self nextLargeIntegerBase: aRadix nPackets: nPackets .
	high := high * (aRadix raisedToInteger: nDigits) + low.
	lastNonZero = 0 ifFalse: [lastNonZeroHigh := lastNonZero + nDigitsHigh].
	nDigitsHigh := nDigitsHigh + nDigits.
	low isLarge]
		whileTrue: [nPackets := nPackets * 2].

	nDigits := nDigitsHigh.
	lastNonZero := lastNonZeroHigh.
	^high
]

{ #category : #'initialize-release' }
NumberParser >> on: aStringOrStream [ 
	sourceStream := aStringOrStream isString 
		ifTrue: [ aStringOrStream readStream ]
		ifFalse: [ aStringOrStream ].
	base := 10.
	neg := false.
	integerPart := fractionPart := exponent := scale := 0.
	requestor := failBlock := nil
]

{ #category : #'parsing-private' }
NumberParser >> peekSignIsMinus [
	"Peek an optional sign from sourceStream.
	Answer true if it is minus sign"

	| isMinus |
	isMinus := sourceStream peekFor: $-.
	isMinus ifFalse: [self allowPlusSign ifTrue: [sourceStream peekFor: $+]].
	^isMinus
]

{ #category : #'parsing-private' }
NumberParser >> readExponent [
	"read the exponent if any (stored in instVar).
	Answer true if found, answer false if none.
	If exponent letter is not followed by a digit,
	this is not considered as an error.
	Exponent are always read in base 10."
	
	| eneg epos |
	exponent := 0.
	(self isExponentLetter: sourceStream peek) ifFalse: [^ false].
	sourceStream next.
	eneg := sourceStream peekFor: $-.
	epos := eneg not and: [self allowPlusSignInExponent and: [sourceStream peekFor: $+]].
	exponent := self nextUnsignedIntegerOrNilBase: 10.
	exponent ifNil: ["Oops, there was no digit after the exponent letter.Ungobble the letter"
		exponent := 0.
		sourceStream
						skip: ((eneg or: [epos])
								ifTrue: [-2]
								ifFalse: [-1]).
					^ false].
	eneg ifTrue: [exponent := exponent negated].
	^true
]

{ #category : #accessing }
NumberParser >> requestor: anObjectOrNil [
	requestor := anObjectOrNil
]
