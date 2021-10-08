Extension { #name : #MIDIFileReader }

{ #category : #'*Morphic-Sounds' }
MIDIFileReader class >> playFileNamed: fileName [

	ScorePlayerMorph
		openOn: (self scoreFromFileNamed: fileName)
		title: (FileDirectory localNameFor: fileName).

]

{ #category : #'*Morphic-Sounds' }
MIDIFileReader class >> playStream: binaryStream [

	ScorePlayerMorph
		openOn: (self scoreFromStream: binaryStream)
		title: 'a MIDI stream'

]

{ #category : #'*Morphic-Sounds' }
MIDIFileReader class >> playURLNamed: urlString [

	| titleString |
	titleString := urlString
		copyFrom: (urlString findLast: [:c | c=$/]) + 1
		to: urlString size.
	ScorePlayerMorph
		openOn: (self scoreFromURL: urlString)
		title: titleString.

]
