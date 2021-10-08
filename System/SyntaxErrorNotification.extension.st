Extension { #name : #SyntaxErrorNotification }

{ #category : #'*System-exceptionDescription' }
SyntaxErrorNotification >> defaultAction [
	^ToolSet handleSyntaxError: self
]
