Extension { #name : #FileDoesNotExistException }

{ #category : #'*System-Files-error handling' }
FileDoesNotExistException >> defaultAction [
	"The default action taken if the exception is signaled."

	^self readOnly
		ifTrue: [StandardFileStream readOnlyFileDoesNotExistUserHandling: self fileName
			ifDebug: [super defaultAction]]
		ifFalse: [StandardFileStream fileDoesNotExistUserHandling: self fileName
			ifDebug: [super defaultAction]]

]
