Extension { #name : #Transcripter }

{ #category : #'*Morphic' }
Transcripter >> morphicDisplayText [
	para compose: self contents asText
		style: TextStyle default
		from: 1
		in: frame.
	Display
		fill: (frame insetBy: -2) fillColor: self black;
		fill: frame fillColor: self white.
	Display getCanvas
		paragraph: para
		bounds: (4@4 + frame topLeft extent: Display extent)
		color: Color black
]

{ #category : #'*Morphic' }
Transcripter >> morphicInitializeParagraph: classParagraph [
	para := classParagraph new.
	para compose: self contents asText
		style: TextStyle default
		from: 1
		in: frame

]
