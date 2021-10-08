Extension { #name : #Dictionary }

{ #category : #'*Compiler' }
Dictionary >> bindingOf: varName [

	^self associationAt: varName ifAbsent: nil
]

{ #category : #'*Compiler' }
Dictionary >> bindingOf: varName ifAbsent: aBlock [

	^self associationAt: varName ifAbsent: aBlock
]

{ #category : #'*Compiler' }
Dictionary >> bindingsDo: aBlock [
	^self associationsDo: aBlock
]
