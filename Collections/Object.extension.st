Extension { #name : #Object }

{ #category : #'*collections' }
Object >> asLink [

	^ ValueLink value: self
]

{ #category : #'*collections' }
Object >> compareSafely: anObject [
	^ self class = anObject class
		ifTrue: [ self printString < anObject printString ]
		ifFalse: [ self class name < anObject class name ]
]
