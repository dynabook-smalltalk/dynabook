Extension { #name : #OutOfMemory }

{ #category : #'*System-exceptionDescription' }
OutOfMemory >> defaultAction [
	Smalltalk signalLowSpace.
]
