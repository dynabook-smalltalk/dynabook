Extension { #name : #ParserNotification }

{ #category : #'*System-default handlers' }
ParserNotification >> defaultAction [
	
	self openMenuIn: 
		[:labels :lines :caption | 
		UIManager default chooseFrom: labels lines: lines title: caption]
]
