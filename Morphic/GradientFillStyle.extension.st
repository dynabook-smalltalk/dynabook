Extension { #name : #GradientFillStyle }

{ #category : #'*Morphic-Balloon' }
GradientFillStyle >> addFillStyleMenuItems: aMenu hand: aHand from: aMorph [
	"Add the items for changing the current fill style of the receiver"
	self isRadialFill ifTrue:[
		aMenu add: 'linear gradient' translated target: self selector: #beLinearGradientIn: argument: aMorph.
	] ifFalse:[
		aMenu add: 'radial gradient' translated target: self selector: #beRadialGradientIn: argument: aMorph.
	].
	aMenu addLine.
	aMenu add: 'change color ramp' translated target: self selector: #changeColorRampIn:event: argument: aMorph.
	aMenu addLine.
	super addFillStyleMenuItems: aMenu hand: aHand from: aMorph.
]

{ #category : #'*Morphic-Balloon' }
GradientFillStyle >> addNewColorIn: aMorph event: evt [
	^self inform:'not yet implemented'
]

{ #category : #'*Morphic-Balloon' }
GradientFillStyle >> beLinearGradientIn: aMorph [
	self radial: false.
	aMorph changed.
]

{ #category : #'*Morphic-Balloon' }
GradientFillStyle >> beRadialGradientIn: aMorph [
	self radial: true.
	aMorph changed.
]

{ #category : #'*Morphic-Balloon' }
GradientFillStyle >> changeColorRampIn: aMorph event: evt [
	^self changeColorSelector: #colorRamp:forMorph: hand: evt hand morph: aMorph originalColor:aMorph fillStyle colorRamp
]

{ #category : #'*Morphic-Balloon' }
GradientFillStyle >> changeColorSelector: aSymbol hand: aHand morph: aMorph originalColor: originalColor [ 
	"Change either the firstColor or the lastColor (depending on aSymbol).  Put up a color picker to hande it.  We always use a modal picker so that the user can adjust both colors concurrently."

^(GradientEditor on: self selector: aSymbol forMorph: aMorph colorRamp: originalColor) openNear: aMorph fullBoundsInWorld. 


	"NewColorPickerMorph useIt
		ifTrue:
			[ (NewColorPickerMorph
				on: self
				originalColor: originalColor
				setColorSelector: aSymbol) openNear: aMorph fullBoundsInWorld ]
		ifFalse:
			[ ColorPickerMorph new
				 initializeModal: false ;
				 sourceHand: aHand ;
				 target: self ;
				 selector: aSymbol ;
				 argument: aMorph ;
				 originalColor: originalColor ;
				
				putUpFor: aMorph
				near: aMorph fullBoundsInWorld ]"
]

{ #category : #'*Morphic-Balloon' }
GradientFillStyle >> changeFirstColorIn: aMorph event: evt [
	^self changeColorSelector: #firstColor:forMorph:hand: hand: evt hand morph: aMorph originalColor: colorRamp first value
]

{ #category : #'*Morphic-Balloon' }
GradientFillStyle >> changeSecondColorIn: aMorph event: evt [
	^self changeColorSelector: #lastColor:forMorph:hand: hand: evt hand morph: aMorph originalColor: colorRamp last value
]

{ #category : #'*Morphic-Balloon' }
GradientFillStyle >> colorRamp: aColorRamp forMorph: aMorph [ 
	colorRamp :=aColorRamp.
	isTranslucent := nil.
	pixelRamp := nil. 
	aMorph changed.
]

{ #category : #'*Morphic-Balloon' }
GradientFillStyle >> firstColor: aColor forMorph: aMorph hand: aHand [
	colorRamp first value: aColor.
	isTranslucent := nil.
	pixelRamp := nil.
	aMorph changed.
]

{ #category : #'*Morphic-Balloon' }
GradientFillStyle >> lastColor: aColor forMorph: aMorph hand: aHand [
	colorRamp last value: aColor.
	isTranslucent := nil.
	pixelRamp := nil.
	aMorph changed.
]
