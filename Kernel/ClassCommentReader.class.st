Class {
	#name : #ClassCommentReader,
	#superclass : #ClassCategoryReader,
	#category : #'Kernel-Classes'
}

{ #category : #'filein/Out' }
ClassCommentReader >> scanFrom: aStream [ 
	"File in the class comment from aStream.  Not string-i-fied, just a text, exactly as it is in the browser.  Move to changes file."

	class theNonMetaClass classComment: (aStream nextChunkText) stamp: changeStamp
		"Writes it on the disk and saves a RemoteString ref"
]

{ #category : #'filein/Out' }
ClassCommentReader >> scanFrom: aStream environment: anEnvironment [
	^ self scanFrom: aStream
]

{ #category : #'filein/Out' }
ClassCommentReader >> scanFromNoCompile: aStream [ 
	"File in the class comment from aStream.  Not string-i-fied, just a text, exactly as it is in the browser.  Move to changes file."

	self scanFrom: aStream.	"for comments, the same as usual"
]
