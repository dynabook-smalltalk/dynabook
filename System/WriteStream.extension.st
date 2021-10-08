Extension { #name : #WriteStream }

{ #category : #'*System-Object Storage-fileIn/Out' }
WriteStream >> fileOutChangeSet: aChangeSetOrNil andObject: theObject [
	"Write a file that has both the source code for the named class and an object as bits.  Any instance-specific object will get its class written automatically."

	"An experimental version to fileout a changeSet first so that a project can contain its own classes"


	self setFileTypeToObject.
		"Type and Creator not to be text, so can attach correctly to an email msg"
	self header; timeStamp.

	aChangeSetOrNil ifNotNil: [
		aChangeSetOrNil fileOutPreambleOn: self.
		aChangeSetOrNil fileOutOn: self.
		aChangeSetOrNil fileOutPostscriptOn: self.
	].
	self trailer.	"Does nothing for normal files.  HTML streams will have trouble with object data"

	"Append the object's raw data"
	(SmartRefStream on: self)
		nextPut: theObject;  "and all subobjects"
		close.		"also closes me"

]

{ #category : #'*System-Object Storage-fileIn/Out' }
WriteStream >> fileOutChanges [
	"Append to the receiver a description of all class changes."
	Cursor write showWhile:
		[self header; timeStamp.
		ChangeSet current fileOutOn: self.
		self trailer; close]
]

{ #category : #'*System-Object Storage-fileIn/Out' }
WriteStream >> fileOutClass: extraClass andObject: theObject [
	"Write a file that has both the source code for the named class and an object as bits.  Any instance-specific object will get its class written automatically."

	| class srefStream |
	self setFileTypeToObject.
		"Type and Creator not to be text, so can attach correctly to an email msg"
	self text.
	self header; timeStamp.

	extraClass ifNotNil: [
		class := extraClass.	"A specific class the user wants written"
		class sharedPools size > 0 ifTrue:
			[class shouldFileOutPools
				ifTrue: [class fileOutSharedPoolsOn: self]].
		class fileOutOn: self moveSource: false toFile: 0].
	self trailer.	"Does nothing for normal files.  HTML streams will have trouble with object data"
	self binary.

	"Append the object's raw data"
	srefStream := SmartRefStream on: self.
	srefStream nextPut: theObject.  "and all subobjects"
	srefStream close.		"also closes me"

]

{ #category : #'*System-Object Storage-fileIn/Out' }
WriteStream >> fileOutClass: extraClass andObject: theObject blocking: anIdentDict [
	"Write a file that has both the source code for the named class and an object as bits.  Any instance-specific object will get its class written automatically.  Accept a list of objects to map to nil or some other object (blockers).  In addition to teh choices in each class's objectToStoreOnDataStream"

	| class srefStream |
	self setFileTypeToObject.
		"Type and Creator not to be text, so can attach correctly to an email msg"
	self header; timeStamp.

	extraClass ifNotNil: [
		class := extraClass.	"A specific class the user wants written"
		class sharedPools size > 0 ifTrue:
			[class shouldFileOutPools
				ifTrue: [class fileOutSharedPoolsOn: self]].
		class fileOutOn: self moveSource: false toFile: 0].
	self trailer.	"Does nothing for normal files.  HTML streams will have trouble with object data"

	"Append the object's raw data"
	srefStream := SmartRefStream on: self.
	srefStream blockers: anIdentDict.
	srefStream nextPut: theObject.  "and all subobjects"
	srefStream close.		"also closes me"

]

{ #category : #'*System-Object Storage-fileIn/Out' }
WriteStream >> padToEndWith: aChar [
	"We don't have pages, so we are at the end, and don't need to pad."
]

{ #category : #'*System-Object Storage-fileIn/Out' }
WriteStream >> setFileTypeToObject [

	"ignore"
]
