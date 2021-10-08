Class {
	#name : #OMeta2Flattener,
	#superclass : #OMeta2,
	#instVars : [
		'ws'
	],
	#category : #OMeta2
}

{ #category : #rules }
OMeta2Flattener >> flatten [ :tree =

	iFlatten(tree) -> [ws contents]
]

{ #category : #rules }
OMeta2Flattener >> iFlatten [ =

	string:s 	[ws nextPutAll: s]
|	{iFlatten*}
]
