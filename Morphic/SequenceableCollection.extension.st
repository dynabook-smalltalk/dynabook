Extension { #name : #SequenceableCollection }

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> asCubic [
	"Convert this point array to a Cubic object"
	self
		assert: [self size = 4].
	self
		assert: [self
				allSatisfy: [:each | each isPoint]].
	^ Cubic withAll: self
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> assertSlopesWith: knots from: start to: end [
   "
	We trust everything has been checked. 
	The following assertions should hold at this point: "
	
	self assert: [ self size = knots size ] . 
	"Sizes must be consistent." 
	self assert: [ end > start]. 
	"There must be at least one slope to clamp." 
	self assert: [ 0 < start and: [start <= knots size] ]. 
	"The clamped slope may be the last one."
	self assert: [  end  <= knots size + start ] . 
	"We can wrap. There may be only one known slope."
	"xxx self assert: [ end = knots size + start ifTrue: [ (self at: start) notNil ] ] . xxx"
		"xxx If we overlap slope must be known. xxx"
	{ start . end } 
		do: [ :index |
			| slope |
			slope := (self at: index ).
			self assert: [ slope isNil 
				or: [ slope isNumber 
				or: [ slope isPoint ] ] ] ] . 
	"And a known and reasonalble value or nil." 
	^true 
	
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> changeInSlopes: slopes [ 
	"A message to knots of a spline. Returns an array with the 3rd cubic coeff."
	"The last nth item is correct iff this is a closed cubic.
	Presumably that is the only time we care.
	We always return the same sized array as self."
	| n slopeChanges |
	n := self size.
	n = slopes size
		ifFalse: [^ self error: 'vertices and slopes differ in number'].
	slopeChanges := Array new: n.
	(1 to: n)
		do: [:i | slopeChanges at: i put: (self atWrap: i + 1)
					- (self at: i) * 3 - ((slopes at: i)
						* 2)
					- (slopes atWrap: i + 1)].
	
	^ slopeChanges
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> changeOfChangesInSlopes: slopes [ 
	"A message to knots of a spline. Returns an array with the 4rd 
	cubic coeff."
	"The last nth item is correct iff this is a closed cubic. 
	Presumably that is the only time we care. 
	We always return the same sized array as self."
	| n changes |
	n := self size.
	n = slopes size
		ifFalse: [^ self error: 'vertices and slopes differ in number'].
	changes := Array new: n.
	1 to: n do: [ :i | 
		changes at: i put: (self at: i)
			- (self atWrap: i + 1) * 2
			+ (slopes at: i)
			+ (slopes atWrap: i + 1) ].
	^ changes
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> closedCubicSlopes [
	"Sent to knots returns the slopes of a closed cubic spline.
	From the same set of java sources as naturalCubic. This is a squeak  
	transliteration of the java code."
	"from java code NatCubicClosed extends NatCubic  
	solves for the set of equations for all knots: 
	b1+4*b2+b3=3*(a3-a1)
	where a1 is (knots atWrap: index + 1) etc.
	and the b's are the slopes .
	
	by decomposing the matrix into upper triangular and lower matrices  
	and then back sustitution. See Spath 'Spline Algorithms for Curves  
	and Surfaces' pp 19--21. The D[i] are the derivatives at the knots.  
	"
	
	| v w x y z n1  D F G H |
	n1 := self size.
	n1 < 3
		ifTrue: [self error: 'Less than 3 points makes a poor curve'].
	v := Array new: n1.
	w := Array new: n1.
	y := Array new: n1.
	
	D := Array new: n1.
	x := self.
	z := 1.0 / 4.0.
	v at: 2 put: z.
	w at: 2 put: z.
	y at: 1 put: z * 3.0 * ((x at: 2)
				- (x at: n1)).
	H := 4.0.
	F := 3 * ((x at: 1)
					- (x at: n1 - 1)).
	G := 1.
	2 to: n1 - 1
		do: [:k | 
			z := 1.0 / (4.0
							- (v at: k)).
			v at: k + 1 put: z.
			w at: k + 1 put: z negated
					* (w at: k).
			y at: k put: z * (3.0 * ((x at: k + 1)
							- (x at: k - 1))
						- (y at: k - 1)).
			H := H - (G
						* (w at: k)).
			F := F - (G
						* (y at: k - 1)).
			G := (v at: k) negated * G].
	H := H - (G + 1 * ((v at: n1)
						+ (w at: n1))).
	y at: n1 put: F - (G + 1
				* (y at: n1 - 1)).
	D at: n1 put: (y at: n1)
			/ H.
	D at: n1 - 1 put: (y at: n1 - 1)
			- ((v at: n1)
					+ (w at: n1)
					* (D at: n1)).
	n1 - 2 to: 1 by: -1 do: [ :k | 
		D at: k put: 
			(y at: k)
					- ((v at: k + 1)
							* (D at: k + 1)) - ((w at: k + 1)
						* (D at: n1))].
	^ D .
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> closedCubicSlopes: clampedSlopes [
	"Sent to knots returns a copy of clampedSlopes with the values of the undefined (nil)  slopes filled in.
	"
	" clampedSlopes must be the same size as knots)" 
	
	"/* Between known slopes we solve the equation for knots with end conditions:  
	4*b1+b2 = 3(a2 - a0) - b0 
	bN2+4*bN1 = 3*(aN-aN2) - bN
	and inbetween:
	b2+4*b3+b4=3*(a4-a2)
	where a2 is (knots atWrap: index + 1) etc.
	and the b's are the slopes .
	N is the last index (knots size)
	N1 is N-1.
	 
	by using row operations to convert the matrix to upper  
	triangular and then back substitution. 
	"
	| slopes tripleKnots list |
	(list := clampedSlopes closedFillinList) = { 0 to: self size } ifTrue: [ ^ self closedCubicSlopes ] .
	"Special case all unknown."
	
	tripleKnots := self * 3.0 . 
	" Premultiply and convert numbers or point coords to Floats "
	slopes := clampedSlopes copy. "slopes contents will be modified."
	
	list do: [ :r | slopes slopesWith: tripleKnots from: r first to: r last ] .
	
	^ slopes
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> closedFillinList [
	"Answers a list of ranges between which values are undertermined.
	Reciever is a list that combines known values and nil entries for
	undetermined values.
	Answer a list of ranges. Each range starts and ends with a known
	value. 
	The range inbetween the known values are nil. The ranges start and
	ends may overlap. 
	Each nil element in the list appears in exactly one range. 
	If the list starts or ends with nil the last range will wrap around to the
	next known value. There may be only one known value in the list but
	there must be atleast one know value.
	
	(self allsatisfy: [ :e | e isNil ] ) ifTrue: [ self error: 'list must contain at
	least one known value' ] 
	"
	| changes n |
	changes := self nilTransitions .
	changes isEmpty ifTrue: [ ^ { 0 to: self size } "Special case. All unknowns." ] .
	 
	changes = #(1) ifTrue: [ ^ #() "Special case. no unknowns." ] . 
	changes = { n :=  self size } ifTrue: [ ^ { n to: n + n } ] .
	"Special case. Only last element known."
	
	changes size even ifTrue: 
			[changes add: self size
							+ (changes at: 1)]
						ifFalse: [
		changes first = 1 ifFalse: [ changes add: self size + 1;
											add: self size + changes first ]
						
		].
	^ changes allButFirst pairsCollect: [ :s :e | ( s - 1 to: e ) ] .

	
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> cubicPointPolynomialAt: vIndex [
	"From curve information assemble a 4-array of points representing the coefficents for curve segment between to points. Beginning point is first point in array endpoint is the pointSum of the array. Meant to be sent to newcurves idea of curve coefficents." 
	
	| result |
	result := Cubic new: 4.
	1 to: 4 do: [ :i | 
		result at: i put: ((self at: i) at: vIndex) @ ((self at: 4 + i) at: vIndex) ].
	^result
]

{ #category : #'*Morphic-Explorer' }
SequenceableCollection >> explorerContents [

	^Array new: self size streamContents: [ :stream |
		1 to: self size do: [ :index |
			stream nextPut: (
				ObjectExplorerWrapper
					with: (self at: index)
					name: index printString
					model: self) ] ]
]

{ #category : #'*Morphic-fliprotate' }
SequenceableCollection >> flipRotated: flipIndex [ 
	"Answer a copy of the receiver with element order indicated by  
	flipIndex."
	"Examples:"
	"'frog' flipRotated: 1"
	"[ :c | (1 to: c size * 2) collect:  
	[ :i | c flipRotated: i ]  
	] value: 'frog'."
	"Lsb of flipIndex indicates whether list is reversed"
	"The flipIndex // 2 gives how much to rotate by after reversing"
	"A good way to think of this is a piece of pie in a pie plate being flip  
	over its leading edge successively."
	"flipIndex > 2 * n are allowed to make it possible to store an array of  
	indexes in an integer."
	| n result src twist |
	n := self size.
	flipIndex \\ (n * 2) = 0
		ifTrue: [^ self].
	"allow for doing nothing"
	result := self species new: n.
	twist := flipIndex // 2 \\ n.
	src := 0.
	(flipIndex even
		ifTrue: [1 + twist to: n + twist]
		ifFalse: [n - 1 - twist to: twist negated by: -1])
		do: [:i | result
				at: (src := src + 1)
				put: (self atWrap: i)].
	^ result
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> naturalCubicSlopes [
	"Sent to knots returns the slopes of a natural cubic curve fit.
	This is a direct  squeak  
	transliteration of the java code."
	" public class NatCubic extends ControlCurve
	
	/* We solve the equation for knots with end conditions:  
	2*b1+b2 = 3(a1 - a0) 
	bN1+2*bN = 3*(aN-aN1)
	and inbetween:
	b2+4*b3+b4=3*(a4-a2)
	where a2 is (knots atWrap: index + 1) etc.
	and the b's are the slopes .
	N is the last index (knots size)
	N1 is N-1.
	 
	by using row operations to convert the matrix to upper  
	triangular  
	and then back sustitution. The D[i] are the derivatives at the  
	knots.  
	"
	| x gamma delta D n1 |
	n1 := self size.
	n1 < 3
		ifTrue: [self error: 'Less than 3 points makes a poor curve'].
	x := self.
	gamma := Array new: n1.
	delta := Array new: n1.
	
	D := Array new: n1.
	gamma at: 1 put: 1.0 / 2.0.
	(2 to: n1 - 1)
		do: [:i | gamma at: i put: 1.0 / (4.0
						- (gamma at: i - 1))].
	gamma at: n1 put: 1.0 / (2.0
				- (gamma at: n1 - 1)).
	delta at: 1 put: 3.0 * ((x at: 2)
				- (x at: 1))
			* (gamma at: 1).
	(2 to: n1 - 1)
		do: [:i | delta at: i put: 3.0 * ((x at: i + 1)
						- (x at: i - 1))
					- (delta at: i - 1)
					* (gamma at: i)].
	delta at: n1 put: 3.0 * ((x at: n1)
				- (x at: n1 - 1))
			- (delta at: n1 - 1)
			* (gamma at: n1).
	D
		at: n1
		put: (delta at: n1).
	(1 to: n1 - 1)
		reverseDo: [:i | D at: i put: (delta at: i)
					- ((gamma at: i)
							* (D at: i + 1))].
	^ D
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> naturalCubicSlopes: clampedSlopes [
	"Sent to knots returns a copy of clampedSlopes with the values of the undefined (nil)  slopes filled in.
	"
	" clampedSlopes must be the same size as knots)" 
	
	"/* Between known slopes we solve the equation for knots with end conditions:  
	4*b1+b2 = 3(a2 - a0) - b0 
	bN2+4*bN1 = 3*(aN-aN2) - bN
	and inbetween:
	b2+4*b3+b4=3*(a4-a2)
	where a2 is (knots atWrap: index + 1) etc.
	and the b's are the slopes .
	N is the last index (knots size)
	N1 is N-1.
	 
	by using row operations to convert the matrix to upper  
	triangular and then back substitution. 
	"
	| slopes tripleKnots |
	tripleKnots := self * 3.0 . 
	" Premultiply and convert numbers or point coords to Floats "
	slopes := clampedSlopes copy. "slopes will be modified."
	clampedSlopes naturalFillinList do: [ :r | slopes slopesWith: tripleKnots from: r first to: r last ] .
	
	^ slopes
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> naturalFillinList [
	"Return a list of fillin ranges to be used to calculate natural or clamped slopes.
	Note that this list is slightly different in mission from the closedFillinList"
	"Answers a list of ranges between which value are undertermined.
	Reciever is a list that combines known values and nil entries for
	undetermined values.
	Answer a list of ranges. Each range starts and ends with a known value. 
	With the exception of the first and last slopes on the list which may be unknown.
	If no slopes are known then the only range is the whole list.
	If all slopes are known then the fillin list is empty.
	The range inbetween the known values are nil. The ranges start and
	ends may overlap if the slope at the overlap is known.
	Each nil element in the list appears in exactly one range.  
	"
	| changes  |
	changes := self nilTransitions .
	changes isEmpty ifTrue: [ ^ { 1 to: self size } "Special case all unknown." ] .
	 
	changes = #(1) ifTrue: [ ^ #() "Special case. no unknowns." ] . 
	
	changes size even 
			ifTrue: [changes add: self size ] .  "Last slope is unknown"
	changes first = 1
			ifTrue: [ ^ changes allButFirst pairsCollect: [ :s :e | (  s - 1 to: e ) ] ] .
	 
		"Otherwise first slope is unknown."
				
						
			^ { 1 to: changes first } , 
					(changes allButFirst pairsCollect: [ :s :e | ( ( s - 1) to: e ) ]) 

	
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> nilTransitions [
	"Return an OrderedCollection of transition indexes.  
	Indexes represent where the list elements transitions 
	from nil to nonNil 
		or from nonNil to nil.
	1 is an index in the list iff the first element is nonNil. "
	
	| changes nilSkip |

	changes := OrderedCollection new.
	nilSkip := true .
	
	1 to: self size
		do: [:i | (self atWrap: i) isNil == nilSkip
				ifFalse: [changes add: i.
					nilSkip := nilSkip not]].

	^ changes 
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> segmentedSlopes [
	"For a collection of floats. Returns the slopes for straight 
	segments between vertices."
	"last slope closes the polygon. Always return same size as 
	self. "
	^ self
		collectWithIndex: [:x :i | (self atWrap: i + 1)
				- x]
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> slopesWith: tripleKnots from: start to: end [ 
	"Sent to modifiable list of slopes. Fills in the slope values between start
	and end. Start and end slopes can be either clamped or nil. 
	If nil the natural slope for that value will be filled in. 
	We expect that the parameters meets the assertions in
	self assertSlopesWith: knots from: start to: end."
	"
	
	/* We solve the equation for knots with end conditions either known or unknown: 
	4*b1+b2 = 3*(a2 - a0) - b0			b0 known
	Or
	2*b0+b1 = 3*(a1 - a0) .			b0 == nil
	
	bN2+4*bN1 = 3*(aN-aN2)-bN		bN known
	Or
	bN1+2*bN = 3*(aN-aN1)			bN == nil
	 .
	b0, bN are starting and ending slopes.
	
	We now handle the special closed cubic case where a0 == aN ( i.e. N = knots size )
	and b0 == bN == nil .
	
	
	
	
	and inbetween:
	b2+4*b3+b4=3*(a4-a2)
	where a2 is (knots  atWrap: index + 1) etc.
	and the b's are the slopes .
	by using row operations to convert the matrix to upper 
	triangular and then back substitution. 
	"
	| gamma delta n range isOpenRange |
	n := self size.
	gamma := Array new: n.
	delta := Array new: n.
	isOpenRange := end < (start + self size) .
	(self at: start)
		ifNotNil: [
			gamma at: start put: 0.0.
			delta
				at: start
				put: (self at: start).
			range := ( start + 1 to: end - 1 ) .
			] " clamped initial conditions"
		ifNil: [
				isOpenRange
				ifTrue:	
			[gamma at: start put: 2.0 reciprocal.
			delta
				at: start
				put:  ((tripleKnots atWrap: start + 1)
					- tripleKnots at: start ) * (gamma at: start) .
			range := ( start  to: end - 1 ) . ]  "natural initial conditions "
				ifFalse: 
			[ gamma at: start put: 4.0 reciprocal.
			delta
				at: start
				put:  ((tripleKnots atWrap: start + 1)
					- tripleKnots atWrap: start - 1 ) * (gamma at: start) .
			range := ( start + 1  to: end - 1 ) .
				]  "closed initial conditions "
				] .
	(start + 1 to: end - 1)
		do: [:i | gamma atWrap: i put: 1.0 / (4.0
						- (gamma atWrap: i - 1))].
	(start + 1 to: end - 1)
		do: [:i | delta atWrap: i put: ((tripleKnots atWrap: i + 1)
						- (tripleKnots atWrap: i - 1))
					- (delta atWrap: i - 1)
					* (gamma atWrap: i)].
	(self atWrap: end) 
		ifNil: [ isOpenRange
			ifTrue: [
			gamma atWrap: end put: 1.0 / (2.0  
										- (gamma atWrap: end - 1 )).
			delta
				atWrap: end
				put:  ((tripleKnots atWrap: end )
							- tripleKnots atWrap: end - 1 )
					 	- (delta at: end - 1 ) * (gamma atWrap: end)] "natural end conditions"
					ifFalse: [
			gamma atWrap: end put: 1.0 / (4.0  
										- (gamma atWrap: end - 1 )).
			delta
				atWrap: end
				put:  ((tripleKnots atWrap: end + 1 )
							- tripleKnots atWrap: end - 1 ) 
						- (delta at: end - 1 ) * (gamma atWrap: end)] "closed end conditions"  
					.
			self atWrap: end put: (delta atWrap: end ) .
				] 
	ifNotNil: [ 
			gamma atWrap: end put: 0.0 .
			delta
				atWrap: end
				put: (self atWrap: end)  .
		
			] "clamped end conditions" .
		
	range
		reverseDo: [:i | self atWrap: i put: 
					(delta atWrap: i)
					- ((gamma atWrap: i)
							* (self atWrap: i + 1)) ] .
	" reciever now contains the filled in slopes."
	^ self 
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> transitions [
	"Sent to a list of boolean values. 
	Return an OrderedCollection of transition indexes.  
	Indexes represent where the list elements transitions 
	from true to false
		or from false to true.
	1 is an index in the list iff the first element is false. "
	
	| changes boolSkip |

	changes := OrderedCollection new.
	boolSkip := true .
	
	self
		withIndexDo: [:truth :i | truth  == boolSkip
				ifFalse: [changes add: i.
					boolSkip := boolSkip not]].

	^ changes 
]

{ #category : #'*Morphic-NewCurves-cubic support' }
SequenceableCollection >> transitions: aSelectBlock [
	"Sent to a list. Select block returns a boolean 
	Return an OrderedCollection of transition indexes.  
	Indexes represent where the list elements transitions 
	from true to false
		or from false to true.
	1 is an index in the list iff the first element tests false. "
	
	| changes boolSkip |

	changes := OrderedCollection new.
	boolSkip := true .
	
	self withIndexDo: 
		 [:e :i | (aSelectBlock value: e ) == boolSkip
				ifFalse: [changes add: i.
					boolSkip := boolSkip not]].

	^ changes 
]
