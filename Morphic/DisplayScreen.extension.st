Extension { #name : #DisplayScreen }

{ #category : #'*Morphic-blitter defaults' }
DisplayScreen >> defaultCanvasClass [
	"Return the WarpBlt version to use when I am active"
	^FormCanvas
]
