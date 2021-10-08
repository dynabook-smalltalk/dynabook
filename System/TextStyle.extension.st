Extension { #name : #TextStyle }

{ #category : #'*System-Fonts' }
TextStyle >> addNewFontSize: pointSize [
	"Add a font in specified size to the array of fonts."
	| f d newArray t isSet |
	fontArray first emphasis ~= 0 ifTrue: [
		t := TextConstants at: self fontArray first familyName asSymbol.
		t fonts first emphasis = 0 ifTrue: [
			^ t addNewFontSize: pointSize.
		].
	].

	pointSize <= 0 ifTrue: [^ nil].
	fontArray do: [:s |
		s pointSize = pointSize ifTrue: [^ s].
	].

	(isSet := fontArray first isKindOf: TTCFontSet) 
	ifTrue:[
		| fonts |
		fonts := fontArray first fontArray collect: [ :font |
			| newFont |
			(font isNil)
			ifTrue: [newFont := nil]
			ifFalse: [
				newFont := (font ttcDescription size > 256)
					ifTrue: [MultiTTCFont new initialize]
					ifFalse: [TTCFont new initialize].
				newFont ttcDescription: font ttcDescription.
				newFont pixelSize: pointSize * 96 // 72.
				font derivativeFonts notEmpty ifTrue: [font derivativeFonts do: [ :proto |
					proto ifNotNil: [
						d := proto class new initialize.
						d ttcDescription: proto ttcDescription.
						d pixelSize: newFont pixelSize.
						newFont derivativeFont: d]]].
				].
			newFont].
		f := TTCFontSet newFontArray: fonts]
	ifFalse: [
		f := fontArray first class new initialize: fontArray first.
		f pointSize: pointSize.
		fontArray first derivativeFonts do: [:proto |
			proto ifNotNil: [
				d := TTCFont new initialize: proto.
				d pointSize: f pointSize.
				f derivativeFont: d.
			].
		].
	].
	newArray := (fontArray copyWith: f) asArray sort: [:a :b | a pointSize <= b pointSize].
	self newFontArray: newArray.
	isSet ifTrue: [
		TTCFontSet register: newArray at: newArray first familyName asSymbol.
	].
	^ self fontOfPointSize: pointSize

]

{ #category : #'*System-Fonts' }
TextStyle >> addNewFontSizeDialog: args [
	"This is called from a modal menu and call back the menu with entered argument."
	| f n r |
	f := UIManager default request: 'Enter the point size' initialAnswer: '12'.
	n := f asNumber.
	r := self addNewFontSize: n.
	r ifNotNil: [
		args second ifNotNil: [args second modalSelection: {args first. n}].
	].

]

{ #category : #'*System-Fonts' }
TextStyle class >> chooseTTCFontSize: args [
	"Prompt for a point size and, if one is given, add a new font size to the font named by the first member of args. If args' length is three, send a message with the selector equal to the third of args, and the receiver equal to the second of args, passing the selected style as an argument."

	| f n style |
	f := UIManager default request: 'New Point Size' initialAnswer: '0'.
	n := f asNumber.
	style := (TextConstants at: args first) addNewFontSize: n.
	style ifNotNil: [
		args second ifNotNil: [args second perform: args third with: style].
	].

]

{ #category : #'*System-Fonts' }
TextStyle >> discardOtherSizes [
	"This method trys to discard the fonts in non-standard size.  If the size is still in use, there will be a problem."
	| newArray |
	self isTTCStyle ifFalse: [^ self].
	newArray := fontArray select: [:s | TTCFont pointSizes includes: s pointSize].
	self newFontArray: newArray.

"(TextConstants at: #ComicSansMS) discardOtherSizes"
]

{ #category : #'*System-Changes-mime file in/out' }
TextStyle class >> writeSF2FamilyNamed: familyName inDirectory: directoryName toChangeSet: csName [ 
	"
	TextStyle writeSF2FamilyNamed: 'Accuny' inDirectory: 'AccunyCorrectedFeb252004Beta Folder' toChangeSet: 'AccunyInstall'.
	"

	|  family |
	family := OrderedCollection new.
	family addAll: (StrikeFont readStrikeFont2Family: familyName fromDirectory: (FileDirectory default fullNameFor: directoryName)) .
	family do: [:f | f reset].
	self 
		writeStyle: (TextStyle fontArray: family asArray)
		named: familyName
		toChangeSet: csName
]

{ #category : #'*System-Changes-mime file in/out' }
TextStyle class >> writeStyle: aTextStyle named: familyName toChangeSet: csName [
	"Write the text style to a change set, with a postscript that will re-load it.
	NOTE: to do TTCFonts, you have to have a working ShortPointArray endianness conversion."
	"
	TTCFont recreateCache.
	TextStyle writeStyle: (TextStyle named: #Arial) named: 'Arial' toChangeSet: 'ArialInstall'.
	
	TextStyle writeStyle: (TextStyle named: #Accuny) named: 'Accuny' toChangeSet: 'AccunyInstall2'.
	"

	| cs mime |

	cs := ChangeSet basicNewNamed: csName.
	cs adoptSelector: #collectionFromCompressedMIMEString: forClass: self class.
	cs adoptSelector: #replaceStyle:with: forClass: self class.
	cs adoptSelector: #replaceFontsIn:with: forClass: self class.
	cs adoptSelector: #looseFontsFromFamily: forClass: self class.
	((aTextStyle fontArray copyWithout: nil) collect: [ :f | f class ]) asSet do: [ :cls  | 
		cs adoptSelector: #derivativeFonts forClass: cls.
		cs adoptSelector: #releaseCachedState forClass: cls ].

	cs preambleString: (String streamContents: [ :s |
		s nextPutAll: '"Change Set:		'; nextPutAll: csName; cr;
		nextPutAll: 'Date:		'; print: Date today; cr;
		nextPutAll: 'Author:		'; nextPutAll: Utilities authorName; cr; cr;
		nextPutAll: 'Installs the text style '''; nextPutAll: familyName; nextPutAll: ''''; cr;
		nextPutAll: 'from a compressed MIME encoding in the postscript."'; cr. ]).

	mime := aTextStyle compressedMIMEEncoded.

	cs postscriptString: (String streamContents: [ :s | s
		nextPutAll: '"Postscript:'; cr;
		nextPutAll: 'Install the text style from the compressed MIME encoding, and replace the old one.';
		nextPut: $"; cr;
		nextPutAll: 'TextConstants at: #';
		nextPutAll: familyName;
		nextPutAll: ' ifPresent: [ :oldStyle | TextConstants at: #';
		nextPutAll: familyName;
		nextPutAll: 'OLD put: oldStyle. TextConstants removeKey: #';
		nextPutAll: familyName;
		nextPutAll: ' ].';
		cr;
		nextPutAll: 'TextStyle collectionFromCompressedMIMEString: ';
		cr;
		print: mime;
		nextPut: $.; cr; cr;
		nextPutAll: 'TextConstants at: #';
		nextPutAll: familyName;
		nextPutAll: 'OLD ifPresent: [ :oldStyle | TextStyle replaceStyle: oldStyle with: (TextStyle named: ''';
		nextPutAll: familyName;
		nextPutAll: ''') ].';
		cr;
		nextPutAll: 'TextStyle replaceFontsIn: (TextStyle looseFontsFromFamily: ''';
		nextPutAll: familyName;
		nextPutAll: ''') with: (TextStyle named: ''';
		nextPutAll: familyName;
		nextPutAll: ''').';		
		cr ]).

	cs fileOut.


]
