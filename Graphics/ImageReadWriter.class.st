"
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.

I am an abstract class to provide for encoding and/or decoding an image on a stream.

Instance Variables:
	stream		<ReadStream | WriteStream>	stream for image storages

Class Variables:
	ImageNotStoredSignal		<Signal>	image not stored error signal
	MagicNumberErrorSignal		<Signal>	magic number error signal

Subclasses must implement the following messages:
	accessing
		nextImage
		nextPutImage:
	testing
		canUnderstand         (added tao 10/26/97)
"
Class {
	#name : #ImageReadWriter,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#classVars : [
		'ImageNotStoredSignal',
		'MagicNumberErrorSignal'
	],
	#category : #'Graphics-Files'
}

{ #category : #'image reading/writing' }
ImageReadWriter class >> allTypicalFileExtensions [
	"Answer a collection of file extensions (lowercase) which files that my subclasses can read might commonly have"
	"ImageReadWriter allTypicalFileExtensions"
	| extensions |
	extensions := Set new.
	self allSubclassesDo: [ :cls | extensions addAll: cls typicalFileExtensions ].
	^extensions
]

{ #category : #'image reading/writing' }
ImageReadWriter class >> formFromFileNamed: fileName [
	"Answer a ColorForm stored on the file with the given name."
	| stream |
	stream := FileStream readOnlyFileNamed: fileName.
	^self formFromStream: stream
]

{ #category : #'image reading/writing' }
ImageReadWriter class >> formFromStream: aBinaryStream [
	"Answer a ColorForm stored on the given stream.  closes the stream"
	| reader readerClass form  |

	readerClass := self withAllSubclasses
		detect: [:subclass |
			aBinaryStream reset.
			subclass understandsImageFormat: aBinaryStream]
		ifNone: [
			aBinaryStream close.
			^self error: 'image format not recognized'].
	aBinaryStream reset.
	reader := readerClass new on: aBinaryStream.
	Cursor read showWhile: [
		form := reader nextImage.
		reader close].
	^ form

]

{ #category : #'instance creation' }
ImageReadWriter class >> on: aStream [
	"Answer an instance of the receiver for encoding and/or decoding images on the given."

	^ self new on: aStream

]

{ #category : #'image reading/writing' }
ImageReadWriter class >> putForm: aForm onFileNamed: fileName [
	"Store the given form on a file of the given name."

	| writer theFile |
	theFile := FileStream newFileNamed: fileName.
	writer := self on: theFile binary.
	Cursor write showWhile: [writer nextPutImage: aForm].
	writer close.
	theFile directory setMacFileNamed: theFile localName type: '    ' creator: '    '.
]

{ #category : #'image reading/writing' }
ImageReadWriter class >> putForm: aForm onStream: aWriteStream [
	"Store the given form on a file of the given name."

	| writer |
	writer := self on: aWriteStream.
	Cursor write showWhile: [writer nextPutImage: aForm].
	writer close.

]

{ #category : #'image reading/writing' }
ImageReadWriter class >> typicalFileExtensions [
	"Answer a collection of file extensions (lowercase) which files that I can read might commonly have"
	^#()
]

{ #category : #'image reading/writing' }
ImageReadWriter class >> understandsImageFormat: aStream [ 
	^[(self new on: aStream) understandsImageFormat] on: Error do:[:ex| ex return: false]
]

{ #category : #'stream access' }
ImageReadWriter >> atEnd [

	^stream atEnd
]

{ #category : #private }
ImageReadWriter >> changePadOfBits: bits width: width height: height depth: depth from: oldPad
to: newPad [
	"Change padding size of bits."

	| srcRowByteSize dstRowByteSize newBits srcRowBase rowEndOffset |
	(#(8 16 32) includes: oldPad)
		ifFalse: [^self error: 'Invalid pad: ', oldPad printString].
	(#(8 16 32) includes: newPad)
		ifFalse: [^self error: 'Invalid pad: ', newPad printString].
	srcRowByteSize := width * depth + oldPad - 1 // oldPad * (oldPad / 8).
	srcRowByteSize * height = bits size
		ifFalse: [^self error: 'Incorrect bitmap array size.'].
	dstRowByteSize := width * depth + newPad - 1 // newPad * (newPad / 8).
	newBits := ByteArray new: dstRowByteSize * height.
	srcRowBase := 1.
	rowEndOffset := dstRowByteSize - 1.
	1 to: newBits size by: dstRowByteSize do:
		[:dstRowBase |
		newBits replaceFrom: dstRowBase
			to: dstRowBase + rowEndOffset
			with: bits
			startingAt: srcRowBase.
		srcRowBase := srcRowBase + srcRowByteSize].
	^newBits
]

{ #category : #'stream access' }
ImageReadWriter >> close [
	
	stream close
]

{ #category : #'stream access' }
ImageReadWriter >> contents [

	^stream contents
]

{ #category : #'stream access' }
ImageReadWriter >> cr [

	^stream nextPut: Character cr asInteger
]

{ #category : #private }
ImageReadWriter >> hasMagicNumber: aByteArray [
	| position |
	position := stream position.
	((stream size - position) >= aByteArray size and:
	[(stream next: aByteArray size)  = aByteArray])
		ifTrue: [^true].
	stream position: position.
	^false
]

{ #category : #'stream access' }
ImageReadWriter >> lf [
	"PPM and PBM are used LF as CR."

	^stream nextPut: Character lf asInteger
]

{ #category : #'stream access' }
ImageReadWriter >> next [

	^stream next
]

{ #category : #'stream access' }
ImageReadWriter >> next: size [

	^stream next: size
]

{ #category : #accessing }
ImageReadWriter >> nextImage [
	"Dencoding an image on stream and answer the image."

	^self subclassResponsibility
]

{ #category : #'stream access' }
ImageReadWriter >> nextLong [
	"Read a 32-bit quantity from the input stream."

	^(stream next bitShift: 24) + (stream next bitShift: 16) +
		(stream next bitShift: 8) + stream next
]

{ #category : #'stream access' }
ImageReadWriter >> nextLongPut: a32BitW [
	"Write out a 32-bit integer as 32 bits."

	stream nextPut: ((a32BitW bitShift: -24) bitAnd: 16rFF).
	stream nextPut: ((a32BitW bitShift: -16) bitAnd: 16rFF).
	stream nextPut: ((a32BitW bitShift: -8) bitAnd: 16rFF).
	stream nextPut: (a32BitW bitAnd: 16rFF).
	^a32BitW
]

{ #category : #'stream access' }
ImageReadWriter >> nextPut: aByte [

	^stream nextPut: aByte
]

{ #category : #'stream access' }
ImageReadWriter >> nextPutAll: aByteArray [

	^stream nextPutAll: aByteArray
]

{ #category : #accessing }
ImageReadWriter >> nextPutImage: anImage [
	"Encoding anImage on stream."

	^self subclassResponsibility
]

{ #category : #'stream access' }
ImageReadWriter >> nextWord [
	"Read a 16-bit quantity from the input stream."

	^(stream next bitShift: 8) + stream next
]

{ #category : #'stream access' }
ImageReadWriter >> nextWordPut: a16BitW [
	"Write out a 16-bit integer as 16 bits."

	stream nextPut: ((a16BitW bitShift: -8) bitAnd: 16rFF).
	stream nextPut: (a16BitW bitAnd: 16rFF).
	^a16BitW
]

{ #category : #private }
ImageReadWriter >> on: aStream [
	stream := aStream.
	stream binary.
]

{ #category : #'stream access' }
ImageReadWriter >> peekFor: aValue [

	^stream peekFor: aValue
]

{ #category : #'stream access' }
ImageReadWriter >> position [

	^stream position
]

{ #category : #'stream access' }
ImageReadWriter >> position: anInteger [

	^stream position: anInteger
]

{ #category : #'stream access' }
ImageReadWriter >> size [

	^stream size
]

{ #category : #'stream access' }
ImageReadWriter >> skip: anInteger [

	^stream skip: anInteger
]

{ #category : #'stream access' }
ImageReadWriter >> space [

	^stream nextPut: Character space asInteger
]

{ #category : #'stream access' }
ImageReadWriter >> tab [

	^stream nextPut: Character tab asInteger
]

{ #category : #testing }
ImageReadWriter >> understandsImageFormat [
	"Test to see if the image stream format is understood by this decoder.
	This should be implemented in each subclass of ImageReadWriter so that
	a proper decoder can be selected without ImageReadWriter having to know
	about all possible image file types."

	^ false
]

{ #category : #private }
ImageReadWriter >> unpackBits: bits depthTo8From: depth with: width height: height pad: pad [
	"Unpack bits of depth 1, 2, or 4 image to it of depth 8 image."

	| bitMask pixelInByte bitsWidth upBitsWidth stopWidth
	 trailingSize upBits bitIndex upBitIndex val |
	(#(1 2 4) includes: depth)
		ifFalse: [^self error: 'depth must be 1, 2, or 4'].
	(#(8 16 32) includes: pad)
		ifFalse: [^self error: 'pad must be 8, 16, or 32'].
	bitMask := (1 bitShift: depth) - 1.
	pixelInByte := 8 / depth.
	bitsWidth := width * depth + pad - 1 // pad * (pad / 8).
	upBitsWidth := width * 8 + pad - 1 // pad * (pad / 8).
	stopWidth := width * depth + 7 // 8.
	trailingSize := width - (stopWidth - 1 * pixelInByte).
	upBits := ByteArray new: upBitsWidth * height.
	1 to: height do: [:i |
		bitIndex := i - 1 * bitsWidth.
		upBitIndex := i - 1 * upBitsWidth.
		1 to: stopWidth - 1 do: [:j |
			val := bits at: (bitIndex := bitIndex + 1).
			upBitIndex := upBitIndex + pixelInByte.
			1 to: pixelInByte do: [:k |
				upBits at: (upBitIndex - k + 1) put: (val bitAnd: bitMask).
				val := val bitShift: depth negated]].
		val := (bits at: (bitIndex := bitIndex + 1))
				bitShift: depth negated * (pixelInByte - trailingSize).
		upBitIndex := upBitIndex + trailingSize.
		1 to: trailingSize do: [:k |
			upBits at: (upBitIndex - k + 1) put: (val bitAnd: bitMask).
			val := val bitShift: depth negated]].
	^ upBits

]
