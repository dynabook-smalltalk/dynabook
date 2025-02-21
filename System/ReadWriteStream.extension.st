Extension { #name : #ReadWriteStream }

{ #category : #'*System-Object Storage-fileIn/Out' }
ReadWriteStream >> fileInObjectAndCode [
	"This file may contain:
1) a fileIn of code  
2) just an object in SmartReferenceStream format 
3) both code and an object.
	File it in and return the object.  Note that self must be a FileStream or RWBinaryOrTextStream.  Maybe ReadWriteStream incorporate RWBinaryOrTextStream?"
	| refStream object |
	self text.
	self peek asciiValue = 4
		ifTrue: [  "pure object file"
			refStream := SmartRefStream on: self.
			object := refStream nextAndClose]
		ifFalse: [  "objects mixed with a fileIn"
			self fileIn.  "reads code and objects, then closes the file"
			object := SmartRefStream scannedObject].	"set by side effect of one of the chunks"
	SmartRefStream scannedObject: nil.  "clear scannedObject"
	^ object
]

{ #category : #'*System-Object Storage-fileIn/Out' }
ReadWriteStream >> fileNameEndsWith: aString [
	"See comment in FileStream fileNameEndsWith:"

	^false
]
