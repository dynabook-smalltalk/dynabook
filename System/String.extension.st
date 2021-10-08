Extension { #name : #String }

{ #category : #'*System-Support' }
String >> asSimpleGetter [
	"Return a getter message from a setter message. For example, #name: asSimpleGetter returns #name"

	self size > 0 ifTrue: [
		self last = $:
			ifTrue: [ self numArgs = 1 ifTrue: [ ^ self allButLast asSymbol ] ]
			ifFalse: [ self numArgs = 0 ifTrue: [ ^ self asSymbol ] ] ].
	
	self error: 'Only simple setters and getters can be converted to simple getters!'.
]

{ #category : #'*System-Support' }
String >> asSimpleSetter [
	"Return a setter message from a getter message. For example, #name asSimpleSetter returns #name:"
	
	self size > 0 ifTrue: [
		self last = $:
			ifTrue: [ self numArgs = 1 ifTrue: [ ^ self asSymbol ] ]
			ifFalse: [ self numArgs = 0 ifTrue: [ ^ (self copyWith: $:) asSymbol ] ] ].
		
	self error: 'Only simple setters and getters can be converted to simple setters!'.
]

{ #category : #'*System-Support' }
String >> isSimpleGetter [
	"Only symbols can be simple getters."
	
	^ false
]

{ #category : #'*System-Support' }
String >> isSimpleSetter [
	"Only symbols can be simple setters."

	^ false
]

{ #category : #'*System-Localization' }
String >> literalStringsDo: aBlock [ 
	"Assuming the receiver receiver is a literal, evaluate aBlock with all Strings (but not Symbols) within it."
	aBlock value: self
]

{ #category : #'*system' }
String >> suggestedTypeNames [
	
	^ Array streamContents: [:stream |
		self findFeatureIndicesDo: [:start :end |
			(self at: start) isUppercase ifTrue: [
				stream nextPut: (self copyFrom: start to: end).
				end ~= self size ifTrue: [
					stream nextPut: (self copyFrom: start to: self size) withBlanksTrimmed].
				"Often, argument names that refer to Collections end in the letter s, which can cause the suggested type-name to not be found. Account for this."
				(self at: end) = $s ifTrue: [
					stream nextPut: (self copyFrom: start to: end -1)]]]].
]

{ #category : #'*System-Localization' }
String >> translated [
	"answer the receiver translated to the default language"
	| translation |
	translation := self
		translatedTo: LocaleID current
		inDomain: (TextDomainManager domainOfMethod: thisContext sender method).
	self == translation ifTrue: [^self translatedInAllDomains].
	^translation
]

{ #category : #'*System-Localization' }
String >> translatedIfCorresponds [
	"answer the receiver translated to the default language only if 
	the receiver begins and ends with an underscore (_)"
	^ ('_*_' match: self)
		ifTrue: [(self copyFrom: 2 to: self size - 1) translated]
		ifFalse: [self]
]

{ #category : #'*System-Localization' }
String >> translatedInAllDomains [
	| translation |
	"Transcript show: self printString, ' translatedInAllDomains'; cr."
	TextDomainManager allKnownDomains do: [:domain |
		translation := self translatedTo: LocaleID current inDomain: domain.
		self = translation ifFalse: [^translation]
	].
	^self
]

{ #category : #'*System-Localization' }
String >> translatedInAnyDomain [
	| translation |
	Transcript show: self printString, ' translatedInAnyDomain'; cr.
	TextDomainManager allKnownDomains do: [:domain |
		translation := self translatedInDomain: domain.
		self = translation ifFalse: [^translation]].
	^self
]

{ #category : #'*System-Localization' }
String >> translatedInDomain: aDomainName [
	| translation |
	translation := self translatedTo: LocaleID current inDomain: aDomainName.
	self == translation ifTrue: [^self translatedInAllDomains].
	^translation

]

{ #category : #'*System-Localization' }
String >> translatedInDomain: aDomainName or: anotherDomainName [
	| translation |
	translation := self translatedTo: LocaleID current inDomain: aDomainName.
	self == translation ifTrue: [^self translatedInDomain: anotherDomainName].
	^translation

]

{ #category : #'*System-Localization' }
String >> translatedNoop [
	"This is correspondence gettext_noop() in gettext."
	^ self
]

{ #category : #'*System-Localization' }
String >> translatedTo: localeID [ 
	"answer the receiver translated to the given locale id"
	^ self translatedTo: localeID inDomain: (TextDomainManager domainOfMethod: thisContext sender method).
]

{ #category : #'*System-Localization' }
String >> translatedTo: localeID inDomain: aDomainName [
	"answer the receiver translated to the given locale id in the textdomain"

	^ NaturalLanguageTranslator translate: self 
								toLocaleID: localeID 
								inDomain:  aDomainName
]
