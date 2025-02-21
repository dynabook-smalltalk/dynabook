Extension { #name : #FileStream }

{ #category : #'*System-Files' }
FileStream class >> fileIn: fullName [
	"File in the entire contents of the file specified by the name provided"

	| ff |
	fullName ifNil: [^ Beeper beep].
	ff := self readOnlyFileNamed: (GZipReadStream uncompressedFileName: fullName).
	ff fileIn.

]
