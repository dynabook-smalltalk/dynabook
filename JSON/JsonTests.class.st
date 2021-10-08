"
I provide a number of test cases for class Json.
"
Class {
	#name : #JsonTests,
	#superclass : #TestCase,
	#category : #JSON
}

{ #category : #'as yet unclassified' }
JsonTests >> assertIncompleteJson: aString [
	self should: [self readFrom: aString] raise: JsonIncompleteError
]

{ #category : #'as yet unclassified' }
JsonTests >> assertInvalidJson: aString [
	self should: [self readFrom: aString] raise: JsonInvalidError
]

{ #category : #'as yet unclassified' }
JsonTests >> json: aString equals: aValue [
	| readValue |
	readValue := self readFrom: aString.
	self assert: readValue = aValue.
]

{ #category : #'as yet unclassified' }
JsonTests >> readFrom: aString [
	^ (Json newWithConstructors: {JsonDummyTestObject.}) readFrom: aString readStream

]

{ #category : #'as yet unclassified' }
JsonTests >> render: anObject equals: aString [
	self assert: (Json render: anObject) = aString
]

{ #category : #'as yet unclassified' }
JsonTests >> simpleDummyObject [
	^ JsonDummyTestObject new a: 1; b: 2; c: 3; yourself
]

{ #category : #'as yet unclassified' }
JsonTests >> testArray [
	self json: '[]' equals: #().
	self json: '[[]]' equals: #(#()).
	self json: '[[], []]' equals: #(#() #()).
	self json: '["hi", "there"]' equals: #('hi' 'there').
	self json: '[["a", "b", null]]' equals: #(('a' 'b' nil)).
]

{ #category : #'as yet unclassified' }
JsonTests >> testAtomFalse [
	self json: 'false' equals: false.
	self json: '  false' equals: false.
	self json: 'false  ' equals: false.
	self json: '  false  ' equals: false.

]

{ #category : #'as yet unclassified' }
JsonTests >> testAtomNull [
	self json: 'null' equals: nil.
	self json: '  null' equals: nil.
	self json: 'null  ' equals: nil.
	self json: '  null  ' equals: nil.

]

{ #category : #'as yet unclassified' }
JsonTests >> testAtomNumber [
	self json: '1' equals: 1.
	self json: '0123' equals: 123.
	self json: '1.23e2' equals: 123.
	self json: '-1' equals: -1.
	self json: '-0' equals: 0.
	self json: '[-1.2]' equals: #(-1.2).
]

{ #category : #'as yet unclassified' }
JsonTests >> testAtomString [
	self json: '"hi"' equals: 'hi'.
	self json: '"\""' equals: '"'.
	self json: '"\\"' equals: '\'.
	self json: '""' equals: ''.
	self json: '"a\u0004b"' equals: ({$a. Character value: 4. $b} as: String).
	self json: '"a\nb"' equals: ({$a. Character lf. $b} as: String).
]

{ #category : #'as yet unclassified' }
JsonTests >> testAtomTrue [
	self json: 'true' equals: true.
	self json: '  true' equals: true.
	self json: 'true  ' equals: true.
	self json: '  true  ' equals: true.

]

{ #category : #'as yet unclassified' }
JsonTests >> testCtor [
	self json: '@JsonDummyTestObject {"a": 1, "b": 2, "c": 3}' equals: self simpleDummyObject.
	self json: (Json render: self simpleDummyObject) equals: self simpleDummyObject.
]

{ #category : #'as yet unclassified' }
JsonTests >> testDictionary [
	self json: '{}' equals: (JsonObject new).
	self json: '{"a": "a"}' equals: (JsonObject new at: 'a' put: 'a'; yourself).
	self json: '{"a": [[]]}' equals: (JsonObject new at: 'a' put: #(#()); yourself).
	self json: '{"a":"b", "b":"a"}' equals: (JsonObject new add: 'a'->'b'; add: 'b'->'a';yourself).
]

{ #category : #'as yet unclassified' }
JsonTests >> testIncomplete [
	self assertIncompleteJson: ''.
	self assertIncompleteJson: '  '.
	self assertIncompleteJson: '  tr'.
	self assertIncompleteJson: 'tru'.
	self assertIncompleteJson: '['.
	self assertIncompleteJson: '[true'.
	self assertIncompleteJson: '[true,'.
	self assertIncompleteJson: '{'.
	self assertIncompleteJson: '{"hi"'.
	self assertIncompleteJson: '{"hi":'.
	self assertIncompleteJson: '{"hi":true'.
	self assertIncompleteJson: '{"hi":true,'.
	self assertIncompleteJson: '{"hi":true,"'.
	self assertIncompleteJson: '"hello'.
	self assertIncompleteJson: '"hello '.
	self assertIncompleteJson: '"hello\'.
	self assertIncompleteJson: '"\u26'.
]

{ #category : #'as yet unclassified' }
JsonTests >> testInvalid [
	self assertInvalidJson: 'x'.
	self assertInvalidJson: '  x'.
	self assertInvalidJson: '  trx'.
	self assertInvalidJson: 'trux'.
	self assertInvalidJson: '.'.
	self assertInvalidJson: ':'.
	self assertInvalidJson: ','.
	self assertInvalidJson: ']'.
	self assertInvalidJson: '}'.
	self assertInvalidJson: '[x'.
	self assertInvalidJson: '[true t'.
	self assertInvalidJson: '[true,]'.
	self assertInvalidJson: '{]'.
	self assertInvalidJson: '{,'.
	self assertInvalidJson: '{"hi",'.
	self assertInvalidJson: '{"hi":x'.
	self assertInvalidJson: '{"hi":,'.
	self assertInvalidJson: '{"hi":true "'.
	self assertInvalidJson: '{"hi":true,}'.
	self assertInvalidJson: '\u263A'.
]

{ #category : #'as yet unclassified' }
JsonTests >> testInvalidUnicodeEscapes [
	self assertInvalidJson: '"\u26"'. "Note that naively reading four chars runs off the end here, so we might see JsonIncompleteError, which would be wrong."
	self assertInvalidJson: '"\u2Z"'.
	self assertInvalidJson: '"\u2Z44"'.
]

{ #category : #'as yet unclassified' }
JsonTests >> testMissingCtor [
	self assertInvalidJson: '@Missing[]'
]

{ #category : #'as yet unclassified' }
JsonTests >> testMissingCtorNoMap [
	self 
		should: [Json new readFrom: '@Missing[]' readStream]
		raise: JsonInvalidError
]

{ #category : #'as yet unclassified' }
JsonTests >> testStreaming [
	| j |
	j := Json new stream: 'truefalsetrue[]{}1.234 5.678"A""B"nullnull' readStream.
	self assert: j readAny equals: true.
	self assert: j readAny equals: false.
	self assert: j readAny equals: true.
	self assert: j readAny equals: #().
	self assert: j readAny equals: JsonObject new.
	self assert: j readAny equals: 1.234.
	self assert: j readAny equals: 5.678.
	self assert: j readAny equals: 'A'.
	self assert: j readAny equals: 'B'.
	self assert: j readAny equals: nil.
	self assert: j readAny equals: nil.
]

{ #category : #'as yet unclassified' }
JsonTests >> testStringWithUnicode [

	| unicodeString |
	unicodeString := (Unicode value: 16r263A) asString.
	self json: '"\u263A"' equals:unicodeString.
	self json: '"\u263a"' equals:unicodeString.
	self json: '"', unicodeString, '"' equals: unicodeString.
	self render: unicodeString equals: '"', unicodeString, '"'.
]

{ #category : #'as yet unclassified' }
JsonTests >> testWriteAssociation [
	self render: 'key' -> 'value' equals: '"key": "value"'.
	self render: 'key' -> 2 equals: '"key": 2'.
	"keys should be strings"
	self render: 42 -> 2 equals: '"42": 2'.
	"try to do _something_ for more complex keys"
	self render: #(42 43 44) -> 2 equals:  '"#(42 43 44)": 2'.
	
	
	
]

{ #category : #'as yet unclassified' }
JsonTests >> testWriteString [
	self render: '"' equals: '"\""'.
	self render: '\' equals: '"\\"'.
	self render: 'hi' equals: '"hi"'.
	self render: ({$a. Character lf. $b} as: String) equals: '"a\nb"'.
	self render: ({$a. Character value: 4. $b} as: String) equals: '"a\u0004b"'.
]
