Extension { #name : #SmartRefStream }

{ #category : #'*Morphic-conversion' }
SmartRefStream >> bookPageMorphbosfcepcbbfgcc0 [
	"BookPageMorph->PasteUpMorph. For reading in old BookMorphs."

	^ PasteUpMorph

]

{ #category : #'*Morphic-conversion' }
SmartRefStream >> clippingMorphbosfcep0 [
	^ PasteUpMorph
]

{ #category : #'*Morphic-conversion' }
SmartRefStream >> clippingMorphbosfcepc0 [
	"ClippingMorph->PasteUpMorph. For reading in old BookMorphs."

	^ PasteUpMorph
]

{ #category : #'*Morphic-conversion' }
SmartRefStream >> dropShadowMorphbosfces0 [

	^ Morph 
]

{ #category : #'*Morphic-conversion' }
SmartRefStream >> layoutMorphbosfcepbbochvimol0 [
	^ AlignmentMorph
]

{ #category : #'*Morphic-conversion' }
SmartRefStream >> layoutMorphbosfcepcbbochvimol0 [
	^ AlignmentMorph
]

{ #category : #'*Morphic-conversion' }
SmartRefStream >> morphicEventtcbks0 [
	^ MorphicEvent
]

{ #category : #'*Morphic-conversion' }
SmartRefStream >> morphicSoundEventtcbkss0 [
	^ MorphicUnknownEvent
]

{ #category : #'*Morphic-conversion' }
SmartRefStream >> multiNewParagraphttfclpomsswfpp0 [
	"Selector composed in SmartRefStream>>mapClass:"
	^ NewParagraph
]

{ #category : #'*Morphic-conversion' }
SmartRefStream >> myMorphbosfce0 [

	reshaped at: #MyMorph put: #convertbosfce0:bosfce0:.
		"Be sure to define that conversion method in class Morph"
	^ Morph
]

{ #category : #'*Morphic-conversion' }
SmartRefStream >> newMorphicEventts0 [

	^ MorphicEvent
]
