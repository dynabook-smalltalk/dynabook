Extension { #name : #Form }

{ #category : #'*Morphic' }
Form >> asMorph [
	^ImageMorph new image: self
]

{ #category : #'*Morphic-examples' }
Form class >> exampleColorSees [
	"Form exampleColorSees"
	"First column as above shows the sneaky red/yellow pirate sneaking up on the blue/peach galleon.
	Second column shows the 1bpp made from the red/yellow/transparent - white -> ignore this, black -> test this
	Third shows the hit area - where red touches blue - superimposed on the original scene.
	Fourth column is the tally of hits via the old algorithm
	Last column shows the tally of hits via the new prim"	
		
	|formA formB maskA  offset tally map intersection left top dCanvas sensitiveColor soughtColor index|
	formA := formB := maskA := offset := tally := map := intersection :=  nil. "just to shut up the compiler when testing"
	ActiveWorld restoreMorphicDisplay; doOneCycle.

	sensitiveColor := Color red.
	soughtColor := Color blue.

	top := 50.
	dCanvas := FormCanvas on: Display.
	-50 to: 80 by: 10 do:[:p|
		offset:= p@0. "vary this to check different states"
		left := 10.

		formA := (Form extent: 100@50 depth: 32) asFormOfDepth: 16 "so we can try original forms of other depths".
		formB := Form extent: 100@50 depth: 32.

		"make a red square in the middle of the form"
		(FormCanvas on: formA) fillRectangle: (25@25 extent: 50@5) fillStyle: sensitiveColor.
		(FormCanvas on: formA) fillRectangle: (25@30 extent: 50@5) fillStyle: Color transparent.
		(FormCanvas on: formA) fillRectangle: (25@35 extent: 50@50) fillStyle: Color yellow.
		"formA displayOn: Display at: left@top rule: Form paint.
		dCanvas frameRectangle: (left@top extent: formA extent) width:2 color: Color green.
		left := left + 150."

		"make a blue block on the right half of the form"
		(FormCanvas on: formB) fillRectangle: (50@0 extent: 50@100) fillStyle: soughtColor.
		(FormCanvas on: formB) fillRectangle: (60@0 extent: 10@100) fillStyle: Color palePeach.
		"formB displayOn: Display at: left@top rule: Form paint.
		dCanvas frameRectangle: (left@top extent: formA extent) width:2 color: Color green.
		left := left + 150."

		intersection := (formA boundingBox translateBy: offset) intersect: (formB boundingBox).

		formB displayOn: Display at: left@top rule: Form paint.
		formA displayOn: Display at: (left@top) + offset rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.
		left := left + 150.
	
		maskA := Form extent: intersection extent depth: 1.

		map := Bitmap new: (1 bitShift: (formA depth min: 15)).
		map at: (index := sensitiveColor indexInMap: map) put: 1.

		maskA copyBits: (intersection translateBy:  offset negated) from: formA at: 0@0 colorMap: map.
		formB displayOn: Display at: left@top rule: Form paint.
		formA displayOn: Display at: (left@top) + offset rule: Form paint.
		maskA displayOn: Display at: (left@top) + intersection origin rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.	left := left + 150.

		"intersect world pixels of the color we're looking for with sensitive pixels mask"
		map at: index put: 0.  "clear map and reuse it"
		map at: (soughtColor indexInMap: map) put: 1.

		maskA
	 		copyBits: intersection
			from: formB at: 0@0 clippingBox: formB boundingBox
			rule: Form and
			fillColor: nil
			map: map.

		formB displayOn: Display at: left@top rule: Form paint.
		formA displayOn: Display at: (left@top) + offset rule: Form paint.
		maskA displayOn: Display at: (left@top) + intersection origin rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.
		left := left + 170.
		
		(maskA tallyPixelValues at: 2) asString asDisplayText displayOn: Display at: left@(top +20).
		left := left + 70.
		
		"now try using the new primitive"
		tally := (BitBlt
			destForm: formB
			sourceForm: formA
			fillColor: nil
			combinationRule: 3 "really ought to work with nil but prim code checks"
			destOrigin: intersection origin
			sourceOrigin: (offset negated max: 0@0)
			extent: intersection extent 
			clipRect: intersection)
				primCompareColor: ((sensitiveColor pixelValueForDepth: formA depth) ) to: ((soughtColor pixelValueForDepth: formB depth) ) test: (Form compareMatchColor bitOr: Form compareTallyFlag).
		tally  asString asDisplayText displayOn: Display at: left@(top +20).
		top:= top + 60]


]

{ #category : #'*Morphic-examples' }
Form class >> exampleTouchTest [
	"Form exampleTouchTest"
	"Demonstrate the algorithm used in Scratch code to determine if a sprite's non-transparent pixels touch a 
	non-transparent pixel of the background upon which it is displayed.
	First column shows a form with a red block in the midst of transparent area sneaking up on a form with a transparent LHS and blue RHS. 	The green frame shows the intersection area.
	Second column shows in grey the part of the red that is within the intersection.
	Third column shows in black the blue that is within the intersection.
	Fourth column shows just the A touching B area.
	Fifth column is the tally of hits via the old algorithm
	Last column shows the tally of hits via the new prim"
	|formA formB maskA maskB offset tally map intersection left top dCanvas|
	formA := formB := maskA := maskB := offset := tally := map := intersection :=  nil. "just to shut up the compiler when testing"

	ActiveWorld restoreMorphicDisplay; doOneCycle.

	top := 50.
	dCanvas := FormCanvas on: Display.
	-50 to: 80 by: 10 do:[:p|
		offset:= p@0. "vary this to check different states"
		left := 10.

		formA := Form extent: 100@50 depth: 32.
		formB := Form extent: 100@50 depth: 16.

		"make a red square in the middle of the form"
		(FormCanvas on: formA) fillRectangle: (25@25 extent: 50@5) fillStyle: Color yellow.
		(FormCanvas on: formA) fillRectangle: (25@30 extent: 50@5) fillStyle: Color transparent.
		(FormCanvas on: formA) fillRectangle: (25@35 extent: 50@50) fillStyle: Color red.
		"formA displayOn: Display at: left@top rule: Form paint.
		dCanvas frameRectangle: (left@top extent: formA extent) width:2 color: Color green.
		left := left + 150."

		"make a blue block on the right half of the form"
		(FormCanvas on: formB) fillRectangle: (50@0 extent: 50@100) fillStyle: Color blue.
		(FormCanvas on: formB) fillRectangle: (60@0 extent: 10@100) fillStyle: Color palePeach.
		"formB displayOn: Display at: left@top rule: Form paint.
		dCanvas frameRectangle: (left@top extent: formA extent) width:2 color: Color green.
		left := left + 150."

		intersection := (formA boundingBox translateBy: offset) intersect: (formB boundingBox).

		formB displayOn: Display at: left@top rule: Form paint.
		formA displayOn: Display at: (left@top) + offset rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.
		left := left + 150.

		maskA := Form extent: intersection extent depth: 2.
		formA displayOn: maskA at: offset  - intersection origin rule: Form paint.
		formB displayOn: Display at: left@top rule: Form paint.
		formA displayOn: Display at: (left@top) + offset rule: Form paint.
		maskA displayOn: Display at: (left@top) + intersection origin rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.
		left := left + 150.

		maskB := Form extent: intersection extent depth: 2.
		formB displayOn: maskB at: intersection origin negated rule: Form paint.
		formB displayOn: Display at: left@top rule: Form paint.
		formA displayOn: Display at: (left@top) + offset rule: Form paint.
		maskB displayOn: Display at: (left@top) + intersection origin rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.
		left := left + 150.

		map := Bitmap new: 4 withAll: 1.
		map at: 1 put: 0.  "transparent"

		maskA copyBits: maskA boundingBox from: maskA at: 0@0 colorMap: map.
		"maskA displayOn: Display at: (left@top) + intersection origin rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.
		left := left + 150."

		maskB copyBits: maskB boundingBox from: maskB at: 0@0 colorMap: map.
		"maskB displayOn: Display at: (left@top) + intersection origin rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.
		left := left + 150."

		maskB displayOn: maskA at: 0@0 rule: Form and.
		maskA displayOn: Display at: (left@top) + intersection origin rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.
		left := left + 170.
		
		(maskA boundingBox area -( maskA tallyPixelValues at: 1)) asString asDisplayText displayOn: Display at: left@(top +20).
		left := left + 70.
		
		"now try using the new primitive"
		tally := (BitBlt
			destForm: formB
			sourceForm: formA
			fillColor: nil
			combinationRule: 3 "really ought to work with nil but prim code checks"
			destOrigin: intersection origin
			sourceOrigin: (offset negated max: 0@0)
			extent: intersection extent 
			clipRect: intersection)
				primCompareColor: ((Color transparent pixelValueForDepth: formA depth) bitAnd: 16rFFFFFF) to: ((Color transparent pixelValueForDepth: formB depth) bitAnd: 16rFFFFFF) test: (Form compareNotColorANotColorB bitOr: Form compareTallyFlag).
		tally  asString asDisplayText displayOn: Display at: left@(top +20).
		top:= top + 60]



]

{ #category : #'*Morphic-examples' }
Form class >> exampleTouchingColor [
	"Form exampleTouchingColor"
	"Demonstrate the algorithm used in Scratch code to determine if a sprite's non-transparent pixels touch a
	particular color pixel of the background upon which it is displayed.
	First column as above shows the sneaky red/yellow pirate sneaking up on the blue/peach galleon.
	Second column shows the 1bpp made from the red/yellow/transparent - white -> ignore this, black -> test this
	Third shows the hit area (black) superimposed on the original scene
	Fourth column is the tally of hits via the old algorithm
	Last column shows the tally of hits via the new prim"	
	|formA formB maskA  offset tally map intersection left top dCanvas ignoreColor soughtColor|
	formA := formB := maskA := offset := tally := map := intersection :=  nil. "just to shut up the compiler when testing"
	ActiveWorld restoreMorphicDisplay; doOneCycle.

	ignoreColor := Color transparent.
	soughtColor := Color blue.

	top := 50.
	dCanvas := FormCanvas on: Display.
	-50 to: 80 by: 10 do:[:p|
		offset:= p@0. "vary this to check different states"
		left := 10.

		formA := (Form extent: 100@50 depth: 32) asFormOfDepth: 16 "so we can try original forms of other depths".
		formB := Form extent: 100@50 depth: 32.

		"make a red square in the middle of the form"
		(FormCanvas on: formA) fillRectangle: (25@25 extent: 50@5) fillStyle: Color red.
		(FormCanvas on: formA) fillRectangle: (25@30 extent: 50@5) fillStyle: Color transparent.
		(FormCanvas on: formA) fillRectangle: (25@35 extent: 50@50) fillStyle: Color yellow.
		"formA displayOn: Display at: left@top rule: Form paint.
		dCanvas frameRectangle: (left@top extent: formA extent) width:2 color: Color green.
		left := left + 150."

		"make a blue block on the right half of the form"
		(FormCanvas on: formB) fillRectangle: (50@0 extent: 50@100) fillStyle: soughtColor.
		(FormCanvas on: formB) fillRectangle: (60@0 extent: 10@100) fillStyle: Color palePeach.
		"formB displayOn: Display at: left@top rule: Form paint.
		dCanvas frameRectangle: (left@top extent: formA extent) width:2 color: Color green.
		left := left + 150."

		intersection := (formA boundingBox translateBy: offset) intersect: (formB boundingBox).

		formB displayOn: Display at: left@top rule: Form paint.
		formA displayOn: Display at: (left@top) + offset rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.
		left := left + 150.
	
		maskA := Form extent: intersection extent depth: 1.

		map := Bitmap new: (1 bitShift: (formA depth min: 15)).
		map atAllPut: 1.
		map at: ( ignoreColor indexInMap: map) put: 0.

		maskA copyBits: (intersection translateBy:  offset negated) from: formA at: 0@0 colorMap: map.
		formB displayOn: Display at: left@top rule: Form paint.
		formA displayOn: Display at: (left@top) + offset rule: Form paint.
		maskA displayOn: Display at: (left@top) + intersection origin rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.	left := left + 150.

		"intersect world pixels of the color we're looking for with sensitive pixels mask"
		map atAllPut: 0.  "clear map and reuse it"
		map at: (soughtColor indexInMap: map) put: 1.

		maskA
	 		copyBits: intersection
			from: formB at: 0@0 clippingBox: formB boundingBox
			rule: Form and
			fillColor: nil
			map: map.

		formB displayOn: Display at: left@top rule: Form paint.
		formA displayOn: Display at: (left@top) + offset rule: Form paint.
		maskA displayOn: Display at: (left@top) + intersection origin rule: Form paint.
		dCanvas frameRectangle: (intersection translateBy: left@top) width:2 color: Color green.
		left := left + 170.
		
		(maskA tallyPixelValues at: 2) asString asDisplayText displayOn: Display at: left@(top +20).
		left := left + 70.
		
		"now try using the new primitive"
		tally := (BitBlt
			destForm: formB
			sourceForm: formA
			fillColor: nil
			combinationRule: 3 "really ought to work with nil but prim code checks"
			destOrigin: intersection origin
			sourceOrigin: (offset negated max: 0@0)
			extent: intersection extent 
			clipRect: intersection)
				primCompareColor: ((ignoreColor pixelValueForDepth: formA depth) bitAnd: 16rFFFFFF) to: ((soughtColor pixelValueForDepth: formB depth) bitAnd: 16rFFFFFF) test: (Form compareNotColorAMatchColorB bitOr: Form compareTallyFlag).
		tally  asString asDisplayText displayOn: Display at: left@(top +20).
		top:= top + 60]

]

{ #category : #'*Morphic' }
Form >> iconOrThumbnailOfSize: aNumberOrPoint [ 
	"Answer an appropiate form to represent the receiver"
	^ self scaledIntoFormOfSize: aNumberOrPoint
]

{ #category : #'*Morphic' }
Form >> scaledIntoFormOfSize: aNumberOrPoint [ 
	
	^ self scaledIntoFormOfSize: aNumberOrPoint smoothing: 8
]

{ #category : #'*Morphic' }
Form >> scaledIntoFormOfSize: aNumberOrPoint smoothing: factor [
	"Scale and center the receiver into a form of a given size"

	| extent scaledForm result |

	extent := aNumberOrPoint asPoint.
	extent = self extent ifTrue: [^ self copy].

	scaledForm := self scaledToSize: extent smoothing: factor.

	result := self species extent: extent depth: self depth.
	result getCanvas
		translucentImage: scaledForm
		at: extent - scaledForm extent // 2.

	^ result

]

{ #category : #'*Morphic-Support-image manipulation' }
Form >> stencil [
	"return a 1-bit deep, black-and-white stencil of myself"

	| canvas |
	canvas := FormCanvas extent: self extent depth: 1.
	canvas fillColor: (Color white).

	canvas stencil: self at: 0@0  
				sourceRect: (Rectangle origin: 0@0 corner: self extent) color: Color black.

	^ canvas form

]

{ #category : #'*Morphic-Text Support' }
Form >> textAnchorProperties [

	^ TextAnchorProperties new
]
