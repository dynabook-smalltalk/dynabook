Class {
	#name : #HySMTransform,
	#superclass : #Object,
	#category : #'Kernel-HySM'
}

{ #category : #'as yet unclassified' }
HySMTransform class >> transform: dat level: l [
| j k s |
j := Json readFrom: dat.
k := j at: #smap.
k := k base64Decoded.
s := ''.
((j at: #stage) at: l) do: [:x|s := s , (k at: x)].
^s
]
