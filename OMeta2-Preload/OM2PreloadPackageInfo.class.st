"
This class makes it possible to store OMeta2 using decompiled production rules, so that it can be loaded without being present first.
It uses OM2DecompilingMethodReference to decompile OMeta2 rules on the fly while creating a source file.
"
Class {
	#name : #OM2PreloadPackageInfo,
	#superclass : #PackageInfo,
	#category : #'OMeta2-Info'
}

{ #category : #'class initialization' }
OM2PreloadPackageInfo class >> initialize [
	self new register
]

{ #category : #naming }
OM2PreloadPackageInfo >> packageName [
	^super packageName, '-Preload'
]

{ #category : #listing }
OM2PreloadPackageInfo >> referenceForMethod: aSymbol ofClass: aClass [
	MCMethodDefinition shutDown.	"flush cache so pre- and postload don't interfere"
	^((OMeta2RuleParser isOMeta2Rule: (aClass sourceCodeAt: aSymbol))
		ifTrue: [OM2DecompilingMethodReference]
		ifFalse: [MethodReference]) new setStandardClass: aClass methodSymbol: aSymbol
]

{ #category : #naming }
OM2PreloadPackageInfo >> systemCategoryPrefix [
	^super packageName
]
