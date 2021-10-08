Extension { #name : #FileExistsException }

{ #category : #'*System-Files-error handling' }
FileExistsException >> defaultAction [
	"The default action taken if the exception is signaled."

	^ self fileClass fileExistsUserHandling: self fileName ifDebug: [super defaultAction]

]
