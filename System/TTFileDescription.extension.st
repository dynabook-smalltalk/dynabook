Extension { #name : #TTFileDescription }

{ #category : #'*System-Tools-profiling' }
TTFileDescription >> profileAll [
	"Profile reading all the glyphs"
	MessageTally spyOn:[
		1 to: numGlyphs do:[:glyphIndex| self readGlyphAt: glyphIndex-1].
	].
]
