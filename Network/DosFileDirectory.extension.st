Extension { #name : #DosFileDirectory }

{ #category : #'*network-uri' }
DosFileDirectory class >> privateFullPathForURI: aURI [
	| path |
	path := aURI path unescapePercents.

	"Check for drive notation (a: etc)"
	path size > 1
		ifTrue: [
			((path at: 3) = $:)
				ifTrue: [path := path copyFrom: 2 to: path size]
				ifFalse: [
					"All other cases should be network path names (\\xxx\sdsd etc)"
					path := '/' , path]].

	^(path copyReplaceAll: '/' with: self slash) unescapePercents
]

{ #category : #'*network-uri' }
DosFileDirectory >> uriPathToPlatformPath: aString [
	"Convert a URI path (w/ forward slashes) into a platform path if necessary.
	Also make sure we deal properly with shares vs. drives"
	| parts path |
	path := aString unescapePercents.
	parts := path findTokens: '/'.
	(parts first endsWith: ':') ifTrue:[
		"it's a drive - compose c:\foo\bar"
		^path allButFirst copyReplaceAll: '/' with: '\'
	] ifFalse:[
		"it's a share - compose \\share\foo\bar"
		^'\', (path copyReplaceAll: '/' with: '\')
	].
]
