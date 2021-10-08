Extension { #name : #CompiledCode }

{ #category : #'*System-converting' }
CompiledCode >> asCodeReference [

	^ self methodReference ifNil: [MethodReference invalid]
]

{ #category : #'*System-Support' }
CompiledCode >> methodReference [

	| class selector |
	class := self methodClass ifNil: [^nil].
	selector := self selector ifNil: [^nil].
	^ MethodReference class: class selector: selector
]
