Class {
	#name : #SBGDPaletteContainer,
	#superclass : #Morph,
	#instVars : [
		'item'
	],
	#category : #'Sandblocks-GDScript'
}

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> buildBlock [

	self isGDClass ifTrue: [^ self shouldBeImplemented].
	
	^ (SBGDScript parseWithPlaceholders: item name, '(', ((item arguments collect: [:arg | '_', arg name]) joinSeparatedBy: ', '), ')') applyReplacement
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> childNamed: aString [

	^ self submorphs second submorphs detect: [:entry | entry name = aString]
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> directory [

	^ file
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> example [

	SBMorphExample
		setUp: [
			self class new
				on: FileSystem disk / 'home';
				toggleExpand]
		cases: {SBMorphExampleCase name: 'example 1' caseBlock: [:m | m]}
		extent: 300 @ 300
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> file [

	^ file
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> handlesMouseOver: evt [

	^ SBWatch report: true for: 619305281
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> isExpanded [

	^ self submorphCount > 1
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> isGDClass [

	^ item includesKey: 'base_class'
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> mouseEnter: evt [

	super mouseEnter: evt.
	
	self toggleActions: true
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> mouseLeave: evt [

	super mouseLeave: evt.
	
	self toggleActions: false
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> name [

	^ item name
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> on: anItem [

	self removeAllMorphs.
	item := anItem.
	self
		addMorphBack: (SBRow new
			hResizing: #spaceFill;
			cellPositioning: #center;
			cellGap: 8;
			addMorphBack: (self isGDClass
				ifTrue: [SBIcon iconAngleRight on: #click send: #toggleExpand to: self]
				ifFalse: [((SBTSFile languageForPath: anItem name) ifNil: [SBTSLanguage]) iconMorph]);
			addMorphBack: (SBStringMorph new contents: self name));
		color: Color transparent;
		on: #click send: #open to: self;
		listDirection: #topToBottom;
		layoutPolicy: TableLayout new;
		cellPositioning: #left;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> open [

	self isGDClass ifTrue: [self toggleExpand]
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> pickUp: anEvent [

	| editor |
	editor := self sandblockEditor.
	
	anEvent hand grabMorph: (SBDragContainer new
		homeArtefact: nil;
		methodClass: nil;
		colorPolicy: editor sandblockEditor colorPolicy;
		color: (self containingSandblock sandblockBlockColorIfAbsent: [Color r: 1 g: 1 b: 1]);
		addMorphBack: self buildBlock;
		yourself)
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> reload [

	self toggleExpand.
	self toggleExpand
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> startDrag: evt [

	self pickUp: evt
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> toggleActions: aBoolean [

	self isGDClass ifFalse: [^ self].
	
	(aBoolean and: [(self valueOfProperty: #actions ifAbsent: nil) isNil]) ifTrue: [
		^ self firstSubmorph addMorphBack: (self setProperty: #actions toValue: (SBRow new
			hResizing: #spaceFill;
			listCentering: #bottomRight))].
	aBoolean not ifTrue: [
		self valueOfProperty: #actions ifPresentDo: [:a | a delete].
		self removeProperty: #actions]
]

{ #category : #'as yet unclassified' }
SBGDPaletteContainer >> toggleExpand [

	| list |
	self isExpanded ifTrue: [
		self firstSubmorph firstSubmorph changeIconName: #iconAngleRight.
		^ self lastSubmorph delete].
	self firstSubmorph firstSubmorph changeIconName: #iconAngleDown.
	self addMorphBack: (list := SBColumn new
		layoutInset: (SBEdgeInsets left: 16);
		hResizing: #spaceFill).
	(GDData select: [:class | class base_class = self name]), item methods
		ifNotEmpty: [:children | children do: [:child | list addMorphBack: (self class new on: child)]]
		ifEmpty: [list addMorphBack: (SBStringMorph new contents: '- no methods -')]
]
