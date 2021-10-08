Class {
	#name : #UnusedVariable,
	#superclass : #ParserNotification,
	#category : #'Compiler-Exceptions'
}

{ #category : #'as yet unclassified' }
UnusedVariable >> openMenuIn: aBlock [
	
	self resume: (UIManager default
		confirm: name asText allBold, ' appears to be unused in this method.\Remove it from the code?' withCRs
		title: 'Unused Variable').
]
