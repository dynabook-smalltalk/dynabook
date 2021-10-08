Extension { #name : #Text }

{ #category : #'*System-Support-instance creation' }
Text class >> fromUser [
	"Answer an instance of me obtained by requesting the user to type a string."
	"Text fromUser"

	^ self fromString:
		(UIManager default request: 'Enter text followed by carriage return')

]
