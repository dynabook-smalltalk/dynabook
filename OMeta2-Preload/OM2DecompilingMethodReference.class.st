"
This class is a helper to OM2PreloadPackagingInfo which is used to save OMeta2 productions in their decompiled form.
"
Class {
	#name : #OM2DecompilingMethodReference,
	#superclass : #MethodReference,
	#category : #'OMeta2-Info'
}

{ #category : #queries }
OM2DecompilingMethodReference >> source [
	^self compiledMethod decompileString
]
