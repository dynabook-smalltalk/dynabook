Extension { #name : #ClassDescription }

{ #category : #'*system-support' }
ClassDescription >> allUnreferencedClassVariables [
	"Answer a list of the names of all the receiver's unreferenced class vars, including those defined in superclasses"

	^ self systemNavigation allUnreferencedClassVariablesOf: self
]

{ #category : #'*System-Tools' }
ClassDescription >> asCodeReference [

	^ self classReference
]

{ #category : #'*System-Tools' }
ClassDescription >> classReference [

	^ ClassReference class: self
]

{ #category : #'*System' }
ClassDescription >> methodReferencesInCategory: aCategoryName [
	^(self organization listAtCategoryNamed: aCategoryName)
		collect: [:ea | MethodReference new
						setClassSymbol: self theNonMetaClass name
						classIsMeta: self isMeta
						methodSymbol: ea
						stringVersion: '']

]
