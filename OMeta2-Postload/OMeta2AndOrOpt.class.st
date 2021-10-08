Class {
	#name : #OMeta2AndOrOpt,
	#superclass : #OMeta2NullOpt,
	#category : #OMeta2
}

{ #category : #rules }
OMeta2AndOrOpt >> and [ =

	trans:x end setHelped -> [x]
|	transInside(#And):xs -> [xs addFirst: #And; yourself]
]

{ #category : #rules }
OMeta2AndOrOpt >> or [ =

	trans:x end setHelped -> [x]
|	transInside(#Or):xs -> [xs addFirst: #Or; yourself]
]

{ #category : #rules }
OMeta2AndOrOpt >> transInside [ :t =

	{exactly(t) transInside(t):xs} transInside(t):ys setHelped -> [xs, ys]
|	trans:x transInside(t):xs -> [xs addFirst: x; yourself]
|	empty -> [OrderedCollection new]
]
