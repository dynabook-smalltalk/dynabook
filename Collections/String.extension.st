Extension { #name : #String }

{ #category : #'*collections' }
String >> compareSafely: aString [ 
	^ aString isString
		ifTrue: [ self < aString ]
		ifFalse: [ super compareSafely: aString ]
]
