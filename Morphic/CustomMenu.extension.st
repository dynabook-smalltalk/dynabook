Extension { #name : #CustomMenu }

{ #category : #'*Morphic-invocation' }
CustomMenu >> startUp: initialSelection withCaption: caption at: aPoint [ 
	"Build and invoke this menu with the given initial selection and caption. 
	Answer the selection associated with the menu item chosen by the user 
	or nil if none is chosen."
	self build.
	initialSelection notNil
		ifTrue: [self preSelect: initialSelection].
	^ super startUpWithCaption: caption at: aPoint
]

{ #category : #'*Morphic-invocation' }
CustomMenu >> startUpWithCaption: caption at: aPoint [ 
	"Build and invoke this menu with no initial selection. Answer the  
	selection associated with the menu item chosen by the user or nil if  
	none is chosen; use the provided caption"
	^ self startUp: nil withCaption: caption at: aPoint
]
