Extension { #name : #TTFontDescription }

{ #category : #'*Morphic-TrueType' }
TTFontDescription >> asMorph [
	^TTSampleFontMorph font: self
]
