Extension { #name : #StandardFileStream }

{ #category : #'*System-Files-error handling' }
StandardFileStream class >> fileDoesNotExistUserHandling: fullFileName ifDebug: debugBlock [

	| selection newName |
	selection := UIManager default chooseFrom: {
		'create a new file' translated.
		'choose another name' translated.
		'debug' translated.
		'cancel' translated
	} title: (FileDirectory localNameFor: fullFileName) , '
does not exist.'.
	selection = 1 ifTrue:
		[^ self new open: fullFileName forWrite: true].
	selection = 2 ifTrue:
		[ newName := UIManager default request: 'Enter a new file name'
						initialAnswer:  fullFileName.
		^ self oldFileNamed:
			(self fullName: newName)].
	selection = 3 ifTrue: [^ debugBlock value].
	self halt
]

{ #category : #'*System-Files-error handling' }
StandardFileStream class >> fileExistsUserHandling: fullFileName ifDebug: debugBlock [
	| dir localName choice newName newFullFileName |
	dir := FileDirectory forFileName: fullFileName.
	localName := FileDirectory localNameFor: fullFileName.
	choice := (UIManager default 
		chooseFrom: #('overwrite that file' 'append (risky!!)' 'choose another name' 'debug' 'cancel')
		title: localName, ' already exists.').

	choice = 1 ifTrue: [
		dir deleteFileNamed: localName
			ifAbsent: [self error: 'Could not delete the old version of that file'].
		^ self new open: fullFileName forWrite: true].

	choice = 2 ifTrue: [
		^ (self new open: fullFileName forWrite: true) setToEnd].

	choice = 3 ifTrue: [
		newName := UIManager default request: 'Enter a new file name' initialAnswer: fullFileName.
		newFullFileName := self fullName: newName.
		^ self newFileNamed: newFullFileName].

	choice = 4 ifTrue: [^ debugBlock value].

	self error: 'Please close this to abort file opening'
]

{ #category : #'*System-Files-error handling' }
StandardFileStream class >> readOnlyFileDoesNotExistUserHandling: fullFileName ifDebug: debugBlock [

	| dir files choices selection newName fileName |
	dir := FileDirectory forFileName: fullFileName.
	files := dir fileNames.
	fileName := FileDirectory localNameFor: fullFileName.
	choices := fileName correctAgainst: files.
	choices add: 'Choose another name'.
	choices add: 'Debug'.
	choices add: 'Cancel'.
	selection := UIManager default chooseFrom: choices lines: (Array with: 5)
		title: (FileDirectory localNameFor: fullFileName), '
does not exist.'.
	selection = choices size ifTrue:["cancel" ^ nil "should we raise another exception here?"].
	selection < (choices size - 1) ifTrue: [
		newName := (dir pathName , FileDirectory slash , (choices at: selection))].
	selection = (choices size - 2) ifTrue: [
		newName := UIManager default 
							request: 'Enter a new file name' 
							initialAnswer: fileName].
	selection = (choices size - 1) ifTrue: [^ debugBlock value].
	newName = '' ifFalse: [^ self readOnlyFileNamed: (self fullName: newName)].
	^ self error: 'Could not open a file'
]
