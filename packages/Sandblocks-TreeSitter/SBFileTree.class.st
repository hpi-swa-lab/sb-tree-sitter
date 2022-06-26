Class {
	#name : #SBFileTree,
	#superclass : #Morph,
	#instVars : [
		'file'
	],
	#category : #'Sandblocks-TreeSitter-Project'
}

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
SBFileTree >> on: aFile [

	self removeAllMorphs.
	file := aFile.
	self
		addMorphBack: (SBRow new
			cellPositioning: #center;
			cellGap: 8;
			addMorphBack: (aFile isDirectory
				ifTrue: [SBIcon iconAngleRight on: #click send: #toggleExpand to: self]
				ifFalse: [((SBTSFile languageForPath: aFile name) ifNil: [SBTSLanguage]) iconMorph]);
			addMorphBack: (SBStringMorph new contents: aFile basename));
		color: Color transparent;
		on: #click send: #open to: self;
		listDirection: #topToBottom;
		layoutPolicy: SBVerticalLayout new;
		cellPositioning: #left;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap
]

{ #category : #'as yet unclassified' }
SBFileTree >> open [

	file isDirectory ifTrue: [self toggleExpand].
	(self ownerSatisfying: [:o | (o ownerThatIsA: self class) isNil])
		triggerEvent: #open
		with: file
]

{ #category : #'as yet unclassified' }
SBFileTree >> toggleExpand [

	| list |
	self submorphCount > 1 ifTrue: [
		self firstSubmorph firstSubmorph changeIconName: #iconAngleRight.
		^ self lastSubmorph delete].
	self firstSubmorph firstSubmorph changeIconName: #iconAngleDown.
	self addMorphBack: (list := SBColumn new layoutInset: (SBEdgeInsets left: 16)).
	file children
		ifNotEmpty: [
			(file children sort: [:a :b | | fa fb |
				fb := b isDirectory asInteger.
				fa := a isDirectory asInteger.
				fa = fb ifTrue: [a basename caseInsensitiveLessOrEqual: b basename] ifFalse: [fa > fb]]) do: [:child | list addMorphBack: (SBFileTree new on: child)]]
		ifEmpty: [list addMorphBack: (SBStringMorph new contents: '- empty -')]
]
