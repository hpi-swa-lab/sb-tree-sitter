Class {
	#name : #SBFileTree,
	#superclass : #Morph,
	#instVars : [
		'file'
	],
	#category : #'Sandblocks-TreeSitter-Files'
}

{ #category : #'as yet unclassified' }
SBFileTree >> childNamed: aString [

	^ self submorphs second submorphs detect: [:entry | entry name = aString]
]

{ #category : #'as yet unclassified' }
SBFileTree >> createFile [

	| name |
	name := UIManager default request: 'File name?'.
	(self directory / name) ensureFile.
	self isExpanded ifFalse: [self toggleExpand] ifTrue: [self reload].
	(self childNamed: name) open
]

{ #category : #'as yet unclassified' }
SBFileTree >> createFolder [

	| name |
	name := UIManager default request: 'Folder name?'.
	(self directory / name) ensureDirectory.
	self reload.
	
	(self childNamed: name) toggleExpand
]

{ #category : #'as yet unclassified' }
SBFileTree >> directory [

	^ file
]

{ #category : #'as yet unclassified' }
SBFileTree >> example [

	SBMorphExample
		setUp: [
			self class new
				on: FileSystem disk / 'home';
				toggleExpand]
		cases: {SBMorphExampleCase name: 'example 1' caseBlock: [:m | m]}
		extent: 300 @ 300
]

{ #category : #'as yet unclassified' }
SBFileTree >> file [

	^ file
]

{ #category : #'as yet unclassified' }
SBFileTree >> handlesMouseOver: evt [

	^ false
]

{ #category : #'as yet unclassified' }
SBFileTree >> hovered [

	^ (self valueOfProperty: #actions ifAbsent: nil) notNil
]

{ #category : #'as yet unclassified' }
SBFileTree >> isDirectory [

	^ file isDirectory
]

{ #category : #'as yet unclassified' }
SBFileTree >> isExpanded [

	^ self submorphCount > 1
]

{ #category : #'as yet unclassified' }
SBFileTree >> mouseEnter: evt [

	super mouseEnter: evt.
	
	self firstSubmorph color: (Color gray: 0.9).
	self toggleActions: true
]

{ #category : #'as yet unclassified' }
SBFileTree >> mouseLeave: evt [

	super mouseLeave: evt.
	
	self toggleActions: false.
	self firstSubmorph color: (Color gray alpha: 0)
]

{ #category : #'as yet unclassified' }
SBFileTree >> name [

	^ file basename
]

{ #category : #'as yet unclassified' }
SBFileTree >> on: aFile [

	self removeAllMorphs.
	file := aFile.
	self
		addMorphBack: (SBRow new
			hResizing: #spaceFill;
			cellPositioning: #center;
			cellGap: 4;
			on: #mouseEnter send: #mouseEnter: to: self;
			on: #mouseLeave send: #mouseLeave: to: self;
			addMorphBack: (aFile isDirectory
				ifTrue: [SBIcon iconAngleRight on: #click send: #toggleExpand to: self]
				ifFalse: [((SBTSFile languageForPath: aFile name) ifNil: [SBTSLanguage]) iconMorph]);
			addMorphBack: (SBStringMorph new contents: aFile basename));
		color: Color transparent;
		on: #click send: #open to: self;
		listDirection: #topToBottom;
		layoutPolicy: TableLayout new;
		cellPositioning: #left;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap
]

{ #category : #'as yet unclassified' }
SBFileTree >> open [

	self isDirectory ifTrue: [self toggleExpand].
	self rootDirectory triggerEvent: #open with: file
]

{ #category : #'as yet unclassified' }
SBFileTree >> reload [

	self toggleExpand.
	self toggleExpand
]

{ #category : #'as yet unclassified' }
SBFileTree >> rootDirectory [

	^ self ownerSatisfying: [:o | (o ownerThatIsA: self class) isNil]
]

{ #category : #'as yet unclassified' }
SBFileTree >> toggleActions: aBoolean [

	self isDirectory ifFalse: [^ self].
	
	(aBoolean and: [(self valueOfProperty: #actions ifAbsent: nil) isNil]) ifTrue: [
		^ self firstSubmorph addMorphBack: (self setProperty: #actions toValue: (SBRow new
			hResizing: #spaceFill;
			listCentering: #bottomRight;
			addMorphBack: (SBIcon iconFile on: #click send: #createFile to: self);
			addMorphBack: (SBIcon iconFolder on: #click send: #createFolder to: self)))].
	aBoolean not ifTrue: [
		self valueOfProperty: #actions ifPresentDo: [:a | a delete].
		self removeProperty: #actions]
]

{ #category : #'as yet unclassified' }
SBFileTree >> toggleExpand [

	| list |
	self isExpanded ifTrue: [
		self firstSubmorph firstSubmorph changeIconName: #iconAngleRight.
		^ self lastSubmorph delete].
	self firstSubmorph firstSubmorph changeIconName: #iconAngleDown.
	self addMorphBack: (list := SBColumn new
		layoutInset: (SBEdgeInsets left: 16);
		cellGap: 1;
		hResizing: #spaceFill).
	file children
		ifNotEmpty: [
			(file children sort: [:a :b | | fa fb |
				fb := b isDirectory asInteger.
				fa := a isDirectory asInteger.
				fa = fb ifTrue: [a basename caseInsensitiveLessOrEqual: b basename] ifFalse: [fa > fb]]) do: [:child | list addMorphBack: (SBFileTree new on: child)]]
		ifEmpty: [list addMorphBack: (SBStringMorph new contents: '- empty -')]
]
