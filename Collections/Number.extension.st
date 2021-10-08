Extension { #name : #Number }

{ #category : #'*collections' }
Number >> compareSafely: aNumber [ 
	^ aNumber isNumber
		ifTrue: [ self < aNumber ]
		ifFalse: [ super compareSafely: aNumber ]
]
