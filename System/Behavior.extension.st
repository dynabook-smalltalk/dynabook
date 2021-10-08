Extension { #name : #Behavior }

{ #category : #'*System-Support' }
Behavior >> allCallsOn [
	"Answer a sorted collection of all the methods that refer to me."
	
	^self systemNavigation allCallsOnClass: self
]

{ #category : #'*System-Support' }
Behavior >> allCallsOn: aSymbol [
	"Answer a sorted collection of all the methods that call on aSymbol."

	^self systemNavigation allCallsOn: aSymbol from: self.
	
]

{ #category : #'*System-Support' }
Behavior >> allLocalCallsOn: aSymbol [
	"Answer a sorted collection of all the methods that call on aSymbol, anywhere in my class hierarchy."

	^self systemNavigation allCallsOn: aSymbol from: self theNonMetaClass
]

{ #category : #'*System-Support' }
Behavior >> allUnsentMessages [
	"Answer an array of all the messages defined by the receiver that are not sent anywhere in the system."

	^self systemNavigation allUnSentMessagesIn: self selectors
]

{ #category : #'*System-Changes' }
Behavior >> changeRecordsAt: selector [
	"Return a list of ChangeRecords for all versions of the method at selector. Source code can be retrieved by sending string to any one.  Return nil if the method is absent."

	"(Pen changeRecordsAt: #go:) collect: [:cRec | cRec string]"
	^ChangeSet 
		scanVersionsOf: (self compiledMethodAt: selector ifAbsent: [^ nil])
		class: self meta: self isMeta
		category: (self whichCategoryIncludesSelector: selector)
		selector: selector.
]
