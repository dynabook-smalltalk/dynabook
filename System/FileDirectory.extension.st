Extension { #name : #FileDirectory }

{ #category : #'*System-Files' }
FileDirectory class >> openChanges: changesName forImage: imageName [
"find the changes file by looking in
a) the directory derived from the image name
b) the DefaultDirectory (which will normally be the directory derived from the image name or the SecurityManager's choice)
If an old file is not found in either place, check for a read-only file in the same places. If that fails, return nil"
	| changes fd |
	"look for the changes file or an alias to it in the image directory"
	fd := FileDirectory on: (FileDirectory dirPathFor: imageName).
	(fd fileExists: changesName)
		ifTrue: [changes := fd oldFileNamed: changesName].
	changes ifNotNil:[^changes].

	"look for the changes in the default directory"
	fd := DefaultDirectory.
	(fd fileExists: changesName)
		ifTrue: [changes := fd oldFileNamed: changesName].
	changes ifNotNil:[^changes].

	"look for read-only changes in the image directory"
	fd := FileDirectory on: (FileDirectory dirPathFor: imageName).
	(fd fileExists: changesName)
		ifTrue: [changes := fd readOnlyFileNamed: changesName].
	changes ifNotNil:[^changes].

	"look for read-only changes in the default directory"
	fd := DefaultDirectory.
	(fd fileExists: changesName)
		ifTrue: [changes := fd readOnlyFileNamed: changesName].
	"this may be nil if the last try above failed to open a file"
	^changes

]

{ #category : #'*System-Files' }
FileDirectory class >> openSources: sourcesName andChanges: changesName forImage: imageName [ 
	"Open the changes and sources files and install them in SourceFiles. Inform the user of problems regarding write permissions or CR/CRLF mixups."
	"Note: SourcesName and imageName are full paths; changesName is a  
	local name."
	| sources changes msg wmsg |
	msg := 'Squeak cannot locate &fileRef.

Please check that the file is named properly and is in the
same directory as this image.'.
	wmsg := 'Squeak cannot write to &fileRef.

Please check that you have write permission for this file.

You won''t be able to save this image correctly until you fix this.'.

	sources := self openSources: sourcesName forImage: imageName.
	changes := self openChanges: changesName forImage: imageName.

	((sources == nil or: [sources atEnd])
			and: [Preferences valueOfFlag: #warnIfNoSourcesFile])
		ifTrue: [Smalltalk platformName = 'Mac OS'
				ifTrue: [msg := msg , '
Make sure the sources file is not an Alias.'].
self inform: (msg copyReplaceAll: '&fileRef' with: 'the sources file named ' , sourcesName)].

	(changes == nil
			and: [Preferences valueOfFlag: #warnIfNoChangesFile])
		ifTrue: [self inform: (msg copyReplaceAll: '&fileRef' with: 'the changes file named ' , changesName)].

	((Preferences valueOfFlag: #warnIfNoChangesFile) and: [changes notNil])
		ifTrue: [changes isReadOnly
				ifTrue: [self inform: (wmsg copyReplaceAll: '&fileRef' with: 'the changes file named ' , changesName)].

			((changes next: 200)
					includesSubstring: String crlf)
				ifTrue: [self inform: 'The changes file named ' , changesName , '
has been injured by an unpacking utility.  Crs were changed to CrLfs.
Please set the preferences in your decompressing program to 
"do not convert text files" and unpack the system again.']].

	SourceFiles := Array with: sources with: changes
]

{ #category : #'*System-Files' }
FileDirectory class >> openSources: fullSourcesName forImage: imageName [ 
"We first do a check to see if a compressed version ofthe sources file is present.
Open the .sources file read-only after searching in:
a) the directory where the VM lives
b) the directory where the image came from
c) the DefaultDirectory (which is likely the same as b unless the SecurityManager has changed it).
"

	| sources fd sourcesName |
	(fullSourcesName endsWith: 'sources') ifTrue:
		["Look first for a sources file in compressed format."
		sources := self openSources: (fullSourcesName allButLast: 7) , 'stc'
						forImage: imageName.
		sources ifNotNil: [^ CompressedSourceStream on: sources]].

	sourcesName := FileDirectory localNameFor: fullSourcesName.
	"look for the sources file or an alias to it in the VM's directory"
	fd := FileDirectory on: Smalltalk vmPath.
	(fd fileExists: sourcesName)
		ifTrue: [sources := fd readOnlyFileNamed: sourcesName].
	sources ifNotNil: [^ sources].
	"look for the sources file or an alias to it in the image directory"
	fd := FileDirectory on: (FileDirectory dirPathFor: imageName).
	(fd fileExists: sourcesName)
		ifTrue: [sources := fd readOnlyFileNamed: sourcesName].
	sources ifNotNil: [^ sources].
	"look for the sources in the current directory"
	fd := DefaultDirectory.
	(fd fileExists: sourcesName)
		ifTrue: [sources := fd readOnlyFileNamed: sourcesName].
	"sources may still be nil here"
	^sources

]

{ #category : #'*System-Files' }
FileDirectory class >> setDefaultDirectory: directoryName [
	"Initialize the default directory to the directory supplied. This method is called when the image starts up."
	| dirName |
	DirectoryClass := self activeDirectoryClass.
	"There doesn't seem to be any really good reason to use the FilePath conversion stuff here; after all, this method gets sent after having read the image path and explicitly converting it"
	dirName := (FilePath pathName: directoryName) asSqueakPathName.
	[dirName endsWith: self slash] whileTrue:[
		dirName := dirName copyFrom: 1 to: dirName size - self slash size.
	].
	DefaultDirectory := self on: dirName.
]
