Class {
	#name : #OMeta2Optimizer,
	#superclass : #OMeta2,
	#category : #OMeta2
}

{ #category : #rules }
OMeta2Optimizer >> optimizeRule [ = _:ans (OMeta2AndOrOpt.optimize(ans):ans)* -> [ans]
]
