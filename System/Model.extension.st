Extension { #name : #Model }

{ #category : #'*System-preferences' }
Model >> defaultWindowColor [

	^ self uniformWindowColor
]

{ #category : #'*System-preferences' }
Model >> uniformWindowColor [

	^ self userInterfaceTheme uniformWindowColor ifNil: [Color veryVeryLightGray]
]

{ #category : #'*System-preferences' }
Model >> windowColorToUse [

	^ Color colorFrom: (self class useColorfulWindows
		ifTrue: [self userInterfaceTheme customWindowColor ifNil: [self defaultWindowColor]]
		ifFalse: [self uniformWindowColor])
]
