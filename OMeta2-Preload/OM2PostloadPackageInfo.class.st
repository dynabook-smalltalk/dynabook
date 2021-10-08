"
This class stores all OMeta2 production rules in their original format.
"
Class {
	#name : #OM2PostloadPackageInfo,
	#superclass : #PackageInfo,
	#category : #'OMeta2-Info'
}

{ #category : #'class initialization' }
OM2PostloadPackageInfo class >> initialize [
	self new register
]

{ #category : #listing }
OM2PostloadPackageInfo >> classes [
	^super classes select: [:each | each inheritsFrom: OMeta2Base]
]

{ #category : #testing }
OM2PostloadPackageInfo >> coreMethodsForClass: aClass [
	MCMethodDefinition shutDown.	"flush cache so pre- and postload don't interfere"
	^(super coreMethodsForClass: aClass) select: [:each | OMeta2RuleParser isOMeta2Rule: each source]
]

{ #category : #testing }
OM2PostloadPackageInfo >> extensionMethodsForClass: aClass [
	^#()
]

{ #category : #naming }
OM2PostloadPackageInfo >> packageName [
	^super packageName, '-Postload'
]

{ #category : #naming }
OM2PostloadPackageInfo >> systemCategoryPrefix [
	^super packageName
]
