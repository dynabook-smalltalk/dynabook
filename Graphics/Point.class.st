"
I represent an x-y pair of numbers usually designating a location on the screen.
"
Class {
	#name : #Point,
	#superclass : #Object,
	#instVars : [
		'x',
		'y'
	],
	#category : #'Graphics-Primitives'
}

{ #category : #'instance creation' }
Point class >> fromUser [
	Sensor waitNoButton.
	Cursor crossHair show.
	Sensor waitButton.
	Cursor normal show.
	^ Sensor cursorPoint

"Point fromUser"
]

{ #category : #'instance creation' }
Point class >> fromUserWithCursor: aCursor [
	Sensor waitNoButton.
	aCursor showWhile:[Sensor waitButton].
	^ Sensor cursorPoint

"Point fromUserWithCursor: Cursor target"
]

{ #category : #'instance creation' }
Point class >> r: rho degrees: degrees [
	"Answer an instance of me with polar coordinates rho and theta."

	^self basicNew setR: rho degrees: degrees
]

{ #category : #'instance creation' }
Point class >> u: xInteger v: yInteger [ 
	"Answer an instance of me with coordinates xInteger and yInteger."

	^self new setX: xInteger setY: yInteger
]

{ #category : #'instance creation' }
Point class >> x: xInteger y: yInteger [ 
	"Answer an instance of me with coordinates xInteger and yInteger."

	^self basicNew setX: xInteger setY: yInteger
]

{ #category : #arithmetic }
Point >> * arg [ 
	"Answer a Point that is the product of the receiver and arg."

	arg isPoint ifTrue: [^ (x * arg x) @ (y * arg y)].
	^ arg adaptToPoint: self andSend: #*
]

{ #category : #arithmetic }
Point >> + arg [ 
	"Answer a Point that is the sum of the receiver and arg."

	arg isPoint ifTrue: [^ (x + arg x) @ (y + arg y)].
	^ arg adaptToPoint: self andSend: #+
]

{ #category : #arithmetic }
Point >> - arg [ 
	"Answer a Point that is the difference of the receiver and arg."

	arg isPoint ifTrue: [^ (x - arg x) @ (y - arg y)].
	^ arg adaptToPoint: self andSend: #-
]

{ #category : #arithmetic }
Point >> / arg [ 
	"Answer a Point that is the quotient of the receiver and arg."

	arg isPoint ifTrue: [^ (x / arg x) @ (y / arg y)].
	^ arg adaptToPoint: self andSend: #/
]

{ #category : #arithmetic }
Point >> // arg [ 
	"Answer a Point that is the quotient of the receiver and arg."

	arg isPoint ifTrue: [^ (x // arg x) @ (y // arg y)].
	^ arg adaptToPoint: self andSend: #//
]

{ #category : #comparing }
Point >> < aPoint [ 
	"Answer whether the receiver is above and to the left of aPoint."

	^x < aPoint x and: [y < aPoint y]
]

{ #category : #comparing }
Point >> <= aPoint [ 
	"Answer whether the receiver is neither below nor to the right of aPoint."

	^x <= aPoint x and: [y <= aPoint y]
]

{ #category : #comparing }
Point >> = aPoint [

	self species = aPoint species
		ifTrue: [^x = aPoint 
	"Refer to the comment in Object|=." x and: [y = aPoint y]]
		ifFalse: [^false]
]

{ #category : #comparing }
Point >> > aPoint [ 
	"Answer whether the receiver is below and to the right of aPoint."

	^x > aPoint x and: [y > aPoint y]
]

{ #category : #comparing }
Point >> >= aPoint [ 
	"Answer whether the receiver is neither above nor to the left of aPoint."

	^x >= aPoint x and: [y >= aPoint y]
]

{ #category : #arithmetic }
Point >> \\ arg [ 
	"Answer a Point that is the mod of the receiver and arg."

	arg isPoint ifTrue: [^ (x \\ arg x) @ (y \\ arg y)].
	^ arg adaptToPoint: self andSend: #\\
]

{ #category : #arithmetic }
Point >> abs [
	"Answer a Point whose x and y are the absolute values of the receiver's x 
	and y."

	^ x abs @ y abs
]

{ #category : #converting }
Point >> adaptToCollection: rcvr andSend: selector [
	"If I am involved in arithmetic with a Collection, return a Collection of
	the results of each element combined with me in that expression."

	^ rcvr collect: [:element | element perform: selector with: self]
]

{ #category : #converting }
Point >> adaptToNumber: rcvr andSend: selector [
	"If I am involved in arithmetic with an Integer, convert it to a Point."
	^ rcvr@rcvr perform: selector with: self
]

{ #category : #converting }
Point >> adaptToString: rcvr andSend: selector [
	"If I am involved in arithmetic with a String, convert it to a Number."
	^ rcvr asNumber perform: selector with: self
]

{ #category : #transforming }
Point >> adhereTo: aRectangle [
	"If the receiver lies outside aRectangle, return the nearest point on the boundary of the rectangle, otherwise return self."

	(aRectangle containsPoint: self) ifTrue: [^ self].
	^ ((x max: aRectangle left) min: aRectangle right)
		@ ((y max: aRectangle top) min: aRectangle bottom)
]

{ #category : #'point functions' }
Point >> area [
	^ x * y
]

{ #category : #converting }
Point >> asFloatPoint [
	^ x asFloat @ y asFloat
]

{ #category : #converting }
Point >> asIntegerPoint [
	^ x asInteger @ y asInteger
]

{ #category : #converting }
Point >> asNonFractionalPoint [
(x isFraction or: [y isFraction])
	ifTrue:[^ x asFloat @ y asFloat]
]

{ #category : #converting }
Point >> asPoint [
	"Answer the receiver itself."

	^self
]

{ #category : #'point functions' }
Point >> bearingToPoint: anotherPoint [
    "Return the bearing, in degrees, from the receiver to anotherPoint.
     Adapted from Playground, where the ultimate provenance of the algorithm was a wild earlier method of Jay Fenton's which I never checked carefully, but the thing has always seemed to work"

    | deltaX deltaY  |
    deltaX := anotherPoint x -  x.
    deltaY := anotherPoint y - y.

    deltaX abs < 0.001
        ifTrue:
            [^ deltaY > 0 ifTrue: [180] ifFalse: [0]].

    ^ ((deltaX >= 0 ifTrue: [90] ifFalse: [270])
            - ((deltaY / deltaX) arcTan negated radiansToDegrees)) rounded

]

{ #category : #private }
Point >> bitShiftPoint: bits [
	x := x bitShift: bits.
	y := y bitShift: bits.
]

{ #category : #'truncation and round off' }
Point >> ceiling [
	"Answer a Point that is the receiver's x and y ceiling. Answer the receiver if its coordinates are already integral."

	(x isInteger and: [y isInteger]) ifTrue: [^ self].
	^ x ceiling @ y ceiling

]

{ #category : #'converting to rectangle' }
Point >> center: aPoint [ 
	"Answer a Rectangle whose extent is the receiver and whose center is 
	aPoint. This is one of the infix ways of expressing the creation of a 
	rectangle."

	^Rectangle center: aPoint extent: self
]

{ #category : #comparing }
Point >> closeTo: aPoint [
	^(x closeTo: aPoint x) and: [y closeTo: aPoint y]
]

{ #category : #'converting to rectangle' }
Point >> corner: aPoint [ 
	"Answer a Rectangle whose origin is the receiver and whose corner is 
	aPoint. This is one of the infix ways of expressing the creation of a 
	rectangle."

	^Rectangle origin: self corner: aPoint
]

{ #category : #'point functions' }
Point >> crossProduct: aPoint [ 
	"Answer a number that is the cross product of the receiver and the 
	argument, aPoint."

	^ (x * aPoint y) - (y * aPoint x)
]

{ #category : #copying }
Point >> deepCopy [
	"Implemented here for better performance."

	^x deepCopy @ y deepCopy
]

{ #category : #'polar coordinates' }
Point >> degrees [
	"Answer the angle the receiver makes with origin in degrees. right is 0; down is 90."
	| tan theta |
	x = 0
		ifTrue: [y >= 0
				ifTrue: [^ 90.0]
				ifFalse: [^ 270.0]]
		ifFalse: 
			[tan := y asFloat / x asFloat.
			theta := tan arcTan.
			x >= 0
				ifTrue: [y >= 0
						ifTrue: [^ theta radiansToDegrees]
						ifFalse: [^ 360.0 + theta radiansToDegrees]]
				ifFalse: [^ 180.0 + theta radiansToDegrees]]
]

{ #category : #'point functions' }
Point >> dist: aPoint [ 
	"Answer the distance between aPoint and the receiver."

	| dx dy |

	dx := aPoint x - x.
	dy := aPoint y - y.

	^ ((dx * dx) + (dy * dy)) sqrt
]

{ #category : #'point functions' }
Point >> dotProduct: aPoint [ 
	"Answer a number that is the dot product of the receiver and the 
	argument, aPoint. That is, the two points are multipled and the 
	coordinates of the result summed."

	^ (x * aPoint x) + (y * aPoint y)
]

{ #category : #'point functions' }
Point >> eightNeighbors [
	^ (Array with: self + (1 @ 0)
		with: self + (1 @ 1)
		with: self + (0 @ 1)
		with: self + (-1 @ 1)) ,
	(Array with: self + (-1 @ 0)
		with: self + (-1 @ -1)
		with: self + (0 @ -1)
		with: self + (1 @ -1))

]

{ #category : #'converting to rectangle' }
Point >> extent: aPoint [ 
	"Answer a Rectangle whose origin is the receiver and whose extent is 
	aPoint. This is one of the infix ways of expressing the creation of a 
	rectangle."

	^Rectangle origin: self extent: aPoint
]

{ #category : #'point functions' }
Point >> flipBy: direction centerAt: c [
	"Answer a Point which is flipped according to the direction about the point c.
	Direction must be #vertical or #horizontal."
	direction == #vertical ifTrue: [^ x @ (c y * 2 - y)].
	direction == #horizontal ifTrue: [^ (c x * 2 - x) @ y].
	self error: 'unrecognizable direction'
]

{ #category : #'truncation and round off' }
Point >> floor [
	"Answer a Point that is the receiver's x and y floor. Answer the receiver if its coordinates are already integral."

	(x isInteger and: [y isInteger]) ifTrue: [^ self].
	^ x floor @ y floor

]

{ #category : #'point functions' }
Point >> fourDirections [
	"Return vertices for a square centered at 0 asPoint with the receiver as first corner.
	Returns the four rotation of the reciever in counter clockwise order with the reciever 	appearing last. "
	^ Array with: self leftRotated
			with: self negated
			with: self rightRotated
			with: self 
		

]

{ #category : #'point functions' }
Point >> fourNeighbors [
	^ Array with: self + (1 @ 0)
		with: self + (0 @ 1)
		with: self + (-1 @ 0)
		with: self + (0 @ -1)

]

{ #category : #'point functions' }
Point >> grid: aPoint [ 
	"Answer a Point to the nearest rounded grid modules specified by aPoint."

	| newX newY |
	newX := x + (aPoint x // 2) truncateTo: aPoint x.
	newY := y + (aPoint y // 2) truncateTo: aPoint y.
	^newX @ newY
]

{ #category : #'extent functions' }
Point >> guarded [
	"Return a positive nonzero extent."
	^ self max: 1@1
]

{ #category : #comparing }
Point >> hash [
	"Hash is reimplemented because = is implemented."

	^(x hash hashMultiply + y hash) hashMultiply
]

{ #category : #'point functions' }
Point >> insideTriangle: p1 with: p2 with: p3 [
	"Return true if the receiver is within the triangle defined by the three coordinates.
	Note: This method computes the barycentric coordinates for the receiver and tests those coordinates."
	| p0 b0 b1 b2 b3 |
	p0 := self.
	b0 := ((p2 x - p1 x) * (p3 y - p1 y)) - ((p3 x - p1 x) * (p2 y - p1 y)).
	b0 isZero ifTrue:[^false]. "degenerate"
	b0 := 1.0 / b0.
	b1 := (((p2 x - p0 x) * (p3 y - p0 y)) - ((p3 x - p0 x) * (p2 y - p0 y))) * b0.
	b2 := (((p3 x - p0 x) * (p1 y - p0 y)) - ((p1 x - p0 x) * (p3 y - p0 y))) * b0.
	b3 := (((p1 x - p0 x) * (p2 y - p0 y)) - ((p2 x - p0 x) * (p1 y - p0 y))) * b0.
	b1 < 0.0 ifTrue:[^false].
	b2 < 0.0 ifTrue:[^false].
	b3 < 0.0 ifTrue:[^false].
	^true


]

{ #category : #interpolating }
Point >> interpolateTo: end at: amountDone [
	"Interpolate between the instance and end after the specified amount has been done (0 - 1)."

	^ self + ((end - self) * amountDone).
]

{ #category : #geometry }
Point >> isInsideCircle: a with: b with: c [ 
	"Returns TRUE if self is inside the circle defined by the     
	points a, b, c. See Guibas and Stolfi (1985) p.107"
	^ (a dotProduct: a)
		* (b triangleArea: c with: self) - ((b dotProduct: b)
			* (a triangleArea: c with: self)) + ((c dotProduct: c)
			* (a triangleArea: b with: self)) - ((self dotProduct: self)
			* (a triangleArea: b with: c)) > 0.0
]

{ #category : #'truncation and round off' }
Point >> isIntegerPoint [
^ x isInteger and: [ y isInteger ] 
]

{ #category : #converting }
Point >> isPoint [
	^ true
]

{ #category : #testing }
Point >> isZero [
	^x isZero and:[y isZero]
]

{ #category : #'point functions' }
Point >> leftRotated [
"Return the reciever rotated 90 degrees.
i.e. self rotateBy: #left centerAt: 0 asPoint .
Compare to transposed and normal. "
	^y  @x negated
]

{ #category : #comparing }
Point >> max: aPoint [ 
	"Answer the lower right corner of the rectangle uniquely defined by the 
	receiver and the argument, aPoint."

	^ (x max: aPoint x) @ (y max: aPoint y)
]

{ #category : #comparing }
Point >> min: aPoint [ 
	"Answer the upper left corner of the rectangle uniquely defined by the 
	receiver and the argument, aPoint."

	^ (x min: aPoint x) @ (y min: aPoint y)
]

{ #category : #comparing }
Point >> min: aMin max: aMax [ 

	^ (self min: aMin) max: aMax
]

{ #category : #'point functions' }
Point >> nearestPointAlongLineFrom: p1 to: p2 [
	"Note this will give points beyond the endpoints.
	Streamlined by Gerardo Richarte 11/3/97"
	| x21 y21 t x1 y1 |
	p1 x = p2 x ifTrue: [^ p1 x @ y].
	p1 y = p2 y ifTrue: [^ x @ p1 y].
	x1 := p1 x asFloat.
	y1 := p1 y asFloat.
	x21 := p2 x asFloat - x1.
	y21 := p2 y asFloat - y1.
	t := ((y asFloat - y1 / x21) + (x asFloat - x1 / y21))
			/ ((x21 / y21) + (y21 / x21)).
	^ (x1 + (t * x21)) @ (y1 + (t * y21))
"
	| old new |
	Pen new place: 200@100; goto: (old := 500@300).
	Display reverse: (old extent: 10@10).
	[Sensor anyButtonPressed] whileFalse:
		[(new := (Sensor cursorPoint nearestPointAlongLineFrom: 200@100 to: 500@300) )
			= old ifFalse:
				[Display reverse: (old extent: 10@10).
				Display reverse: ((old := new) extent: 10@10)]]
"

]

{ #category : #'point functions' }
Point >> nearestPointOnLineFrom: p1 to: p2 [
	"This will not give points beyond the endpoints"
	^ (self nearestPointAlongLineFrom: p1 to: p2)
		adhereTo: (p1 rect: p2)
]

{ #category : #transforming }
Point >> negated [
	"Answer a point whose x and y coordinates are the negatives of those of the receiver.  6/6/96 sw"
	"Optimized for speed -- ar 8/26/2001"
	^ (0 - x) @ (0 - y)
]

{ #category : #'point functions' }
Point >> normal [
	"Answer a Point representing the unit vector rotated 90 deg clockwise.
	For the zero point return a normal of  -1@0   ."

	| n d |
	
	n := y negated @ x.
	(d := (n x * n x + (n y * n y))) = 0 ifTrue: [ ^  -1 @0  ] .
	^n / d sqrt
]

{ #category : #'point functions' }
Point >> normalized [
	"Optimized for speed -- ar 8/26/2001"
	| r |
	r := ((x*x) + (y * y)) sqrt.
	^(x / r) @ (y / r)
]

{ #category : #'point functions' }
Point >> octantOf: otherPoint [ 
	"Return 1..8 indicating relative direction to otherPoint.  
	1=ESE, 2=SSE, ... etc. clockwise to 8=ENE"
	"[Sensor anyButtonPressed] whileFalse: [(Display boundingBox center 
	octantOf: Sensor cursorPoint) printString displayAt: 0@0]"
	| quad moreHoriz |
	(x = otherPoint x and: [y > otherPoint y])
		ifTrue: [^ 6].
	"special case"
	(y = otherPoint y and: [x < otherPoint x])
		ifTrue: [^ 8].
	quad := self quadrantOf: otherPoint.
	moreHoriz := (x - otherPoint x) abs >= (y - otherPoint y) abs.
	(quad even eqv: moreHoriz)
		ifTrue: [^ quad * 2]
		ifFalse: [^ quad * 2 - 1]
]

{ #category : #'point functions' }
Point >> onLineFrom: p1 to: p2 [
	^ self onLineFrom: p1 to: p2 within: 2
]

{ #category : #'point functions' }
Point >> onLineFrom: p1 to: p2 within: epsilon [
	"Answer true if the receiver lies on the given line segment between p1 and p2 within a small epsilon."

	"is this point within the box spanning p1 and p2 expanded by epsilon? (optimized)"
	p1 x < p2 x
		ifTrue: [
			((x < (p1 x - epsilon)) or: [x > (p2 x + epsilon)]) ifTrue: [^ false]]
		ifFalse: [
			((x < (p2 x - epsilon)) or: [x > (p1 x + epsilon)]) ifTrue: [^ false]].
	p1 y < p2 y
		ifTrue: [
			((y < (p1 y - epsilon)) or: [y > (p2 y + epsilon)]) ifTrue: [^ false]]
		ifFalse: [
			((y < (p2 y - epsilon)) or: [y > (p1 y + epsilon)]) ifTrue: [^ false]].

	"it's in the box; is it on the line?"
	^ (self dist: (self nearestPointAlongLineFrom: p1 to: p2)) <= epsilon
]

{ #category : #'converting to rectangle' }
Point >> origin: aPoint [ 
	"Answer a Rectangle whose extent is the receiver and whose origin is 
	aPoint. This is one of the infix ways of expressing the creation of a 
	rectangle."

	^Rectangle origin: aPoint extent: self
]

{ #category : #printing }
Point >> printOn: aStream [ 
	"The receiver prints on aStream in terms of infix notation."

	x printOn: aStream.
	aStream nextPut: $@.
	(y isNumber and: [y negative]) ifTrue:
		"Avoid ambiguous @- construct"
		[aStream space].
	y printOn: aStream
]

{ #category : #'point functions' }
Point >> quadrantOf: otherPoint [
	"Return 1..4 indicating relative direction to otherPoint.
	1 is downRight, 2=downLeft, 3=upLeft, 4=upRight"
	^ x <= otherPoint x
		ifTrue: [y < otherPoint y ifTrue: [1] ifFalse: [4]]
		ifFalse: [y <= otherPoint y ifTrue: [2] ifFalse: [3]]
"
[Sensor anyButtonPressed] whileFalse:
	[(Display boundingBox center quadrantOf: Sensor cursorPoint) printString displayAt: 0@0]
"
]

{ #category : #'polar coordinates' }
Point >> r [
	"Answer the receiver's radius in polar coordinate system."

	^(self dotProduct: self) sqrt
]

{ #category : #arithmetic }
Point >> reciprocal [
    " Answer a Point with coordinates that are the reciprocals of mine. "
    " Method was missing from release. "
    " 20040301 20:50:35 TRee(Squeak3.6-5429-tree07.38) "

    ^ x reciprocal @ y reciprocal.

]

{ #category : #'converting to rectangle' }
Point >> rect: aPoint [ 
	"Answer a Rectangle that encompasses the receiver and aPoint.
	This is the most general infix way to create a rectangle."

	^ Rectangle 
		origin: (self min: aPoint)
		corner: (self max: aPoint)
]

{ #category : #'point functions' }
Point >> rightRotated [
"Return the reciever rotated 90 degrees.
i.e. self rotateBy: #right centerAt: 0 asPoint .
Compare to transposed and normal. "
	^y negated @x
]

{ #category : #transforming }
Point >> rotateBy: angle about: center [
	"Even though Point.theta is measured CW, this rotates with the more conventional CCW interpretateion of angle."

	| p r theta |
	p := self - center.
	r := p r.
	theta := angle asFloat - p theta.
	^ (center x asFloat + (r * theta cos)) @
	  (center y asFloat - (r * theta sin))
]

{ #category : #'point functions' }
Point >> rotateBy: direction centerAt: c [
	"Answer a Point which is rotated according to direction, about the point c.
	Direction must be one of #right (CW), #left (CCW) or #pi (180 degrees)."
	| offset |
	offset := self - c.
	direction == #right ifTrue: [^ (offset y negated @ offset x) + c].
	direction == #left ifTrue: [^ (offset y @ offset x negated) + c].
	direction == #pi ifTrue: [^ c - offset].
	self error: 'unrecognizable direction'
]

{ #category : #'truncation and round off' }
Point >> roundDownTo: grid [
	"Answer a Point that is the receiver's x and y rounded to grid x and 
	grid y by lower value (toward negative infinity)."
	
	| gridPoint |
	gridPoint := grid asPoint.
	^(x roundDownTo: gridPoint x) @ (y roundDownTo: gridPoint y)
]

{ #category : #'truncation and round off' }
Point >> roundTo: grid [
	"Answer a Point that is the receiver's x and y rounded to grid x and 
	grid y."
	
	| gridPoint |
	gridPoint := grid asPoint.
	^(x roundTo: gridPoint x) @ (y roundTo: gridPoint y)
]

{ #category : #'truncation and round off' }
Point >> roundUpTo: grid [
	"Answer a Point that is the receiver's x and y rounded to grid x and 
	grid y by upper value (toward infinity)."
	
	| gridPoint |
	gridPoint := grid asPoint.
	^(x roundUpTo: gridPoint x) @ (y roundUpTo: gridPoint y)
]

{ #category : #'truncation and round off' }
Point >> rounded [
	"Answer a Point that is the receiver's x and y rounded. Answer the receiver if its coordinates are already integral."

	(x isInteger and: [y isInteger]) ifTrue: [^ self].
	^ x rounded @ y rounded

]

{ #category : #transforming }
Point >> scaleBy: factor [ 
	"Answer a Point scaled by factor (an instance of Point)."

	^(factor x * x) @ (factor y * y)
]

{ #category : #transforming }
Point >> scaleFrom: rect1 to: rect2 [
	"Produce a point stretched according to the stretch from rect1 to rect2"
	^ rect2 topLeft + (((x-rect1 left) * rect2 width // rect1 width)
					@ ((y-rect1 top) * rect2 height // rect1 height))
]

{ #category : #'extent functions' }
Point >> scaleTo: anExtent [
	"Return a Point scalefactor for shrinking a thumbnail of the receiver's extent to fit within anExtent. self and anExtent are expected to have positive nonZero x and y."

	|  factor  sX sY | 
	factor :=  3.0  reciprocal .
	sX := anExtent x / self  x asFloat  .
	sY :=  anExtent y / self  y asFloat  .
	sX = sY ifTrue: [ ^ sX @ sY ] . "Same aspect ratio"
	^ sX < sY ifTrue: [   sX @ (sX max: sY * factor) ] 
		ifFalse: [  (sY max: sX * factor ) @ sY  ] 
]

{ #category : #private }
Point >> setR: rho degrees: degrees [ 

	| radians |
	radians := degrees asFloat degreesToRadians.
	x := rho asFloat * radians cos.
	y := rho asFloat * radians sin.
]

{ #category : #private }
Point >> setX: xValue setY: yValue [

	x := xValue.
	y := yValue
]

{ #category : #geometry }
Point >> sideOf: otherPoint [ 
	"Returns #left, #right or #center if the otherPoint lies to the left, right 
	or on the line given by the vector from 0@0 to self"
	| side |
	side := (self crossProduct: otherPoint) sign.
	^ {#right. #center. #left} at: side + 2

]

{ #category : #'point functions' }
Point >> sign [


^ (x sign @ y sign) .
]

{ #category : #'point functions' }
Point >> sortsBefore: otherPoint [
	"Return true if the receiver sorts before the other point"
	^y = otherPoint y
		ifTrue:[x <= otherPoint x]
		ifFalse:[y <= otherPoint y]
]

{ #category : #'point functions' }
Point >> squaredDistanceTo: aPoint [
	"Answer the distance between aPoint and the receiver."
	| delta |
	delta := aPoint - self.
	^delta dotProduct: delta
]

{ #category : #printing }
Point >> storeOn: aStream [ 
	"x@y printed form is good for storing too"
	aStream nextPut: $(.
	self printOn: aStream.
	aStream nextPut: $).

]

{ #category : #'polar coordinates' }
Point >> theta [
	"Answer the angle the receiver makes with origin in radians. right is 0; 
	down is 90. 
	Corrected the constants from single precision to 64 Bit precision 
	and changed the sends in case of overflow to constants HK 2005-07-23"

	| tan theta |
	x = 0
		ifTrue: [y >= 0
				ifTrue: [^ 1.5707963267948966 "90.0 degreesToRadians"]
				ifFalse: [^ 4.71238898038469 "270.0 degreesToRadians"]]
		ifFalse: 
			[tan := y asFloat / x asFloat.
			theta := tan arcTan.
			x >= 0
				ifTrue: [y >= 0
						ifTrue: [^theta]
						ifFalse: [^"360.0 degreesToRadians" 6.283185307179586 + theta]]
				ifFalse: [^"180.0 degreesToRadians" 3.141592653589793 + theta]]
]

{ #category : #geometry }
Point >> to: end1 intersects: start2 to: end2 [ 
	"Returns true if the linesegment from start1 (=self) to end1 intersects      
	    with the segment from start2 to end2, otherwise false."
	| start1 sideStart sideEnd |
	start1 := self.
	(((start1 = start2 or: [end1 = end2])
		or: [start1 = end2])
		or: [start2 = end1])
		ifTrue: [^ true].
	sideStart := start1 to: end1 sideOf: start2.
	sideEnd := start1 to: end1 sideOf: end2.
	sideStart = sideEnd ifTrue: [^ false].
	sideStart := start2 to: end2 sideOf: start1.
	sideEnd := start2 to: end2 sideOf: end1.
	sideStart = sideEnd ifTrue: [^ false].
	^ true
]

{ #category : #geometry }
Point >> to: end sideOf: otherPoint [ 
	"Returns #left, #right, #center if the otherPoint lies to the left, right or on the line given by the vector from self to end"
	^ end - self sideOf: otherPoint - self
]

{ #category : #transforming }
Point >> transformedBy: aTransform [
	"Point transform double dispatch"
	^aTransform transformPoint: self
]

{ #category : #transforming }
Point >> translateBy: delta [ 
	"Answer a Point translated by delta (an instance of Point)."

	^(delta x + x) @ (delta y + y)
]

{ #category : #'point functions' }
Point >> transposed [
	^y@x
]

{ #category : #geometry }
Point >> triangleArea: b with: c [
	"Returns twice the area of the oriented triangle (a, b, c), i.e., the   
	area is positive if the triangle is oriented counterclockwise"
	^ b x - self x * (c y - self y) - (b y - self y * (c x - self x))
]

{ #category : #'truncation and round off' }
Point >> truncateTo: grid [
	"Answer a Point that is the receiver's x and y truncated to grid x and 
	grid y."
	| gridPoint |
	gridPoint := grid asPoint.
	^(x truncateTo: gridPoint x) @ (y truncateTo: gridPoint y)
]

{ #category : #'truncation and round off' }
Point >> truncated [
	"Answer a Point whose x and y coordinates are integers. Answer the receiver if its coordinates are already integral."

	(x isInteger and: [y isInteger]) ifTrue: [^ self].
	^ x truncated @ y truncated

]

{ #category : #accessing }
Point >> u [
	^x
]

{ #category : #accessing }
Point >> v [
	^y
]

{ #category : #copying }
Point >> veryDeepCopyWith: deepCopier [
	"Return self.  I am immutable in the Morphic world.  Do not record me."
]

{ #category : #accessing }
Point >> x [
	"Answer the x coordinate."

	^x
]

{ #category : #accessing }
Point >> y [
	"Answer the y coordinate."

	^y
]
