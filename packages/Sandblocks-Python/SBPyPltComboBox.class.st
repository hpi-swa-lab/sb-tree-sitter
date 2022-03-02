"
Combo box based on SBRows as items.
"
Class {
	#name : #SBPyPltComboBox,
	#superclass : #SBRow,
	#instVars : [
		'values',
		'tooltips',
		'object',
		'icons'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #defaults }
SBPyPltComboBox class >> find: aString inItemDefinitions: aCollection fallback: aBlock [
	^ aCollection detect: [:i | i submorphs first contents = aString]
		ifFound: [:i | i]
		ifNone: [ aBlock value: aCollection ].
]

{ #category : #defaults }
SBPyPltComboBox class >> itemDefinitionsToMorphs: aCollection [
"returns a collection of morphs given aCollection like {{label. image. tooltip}...}"
	^ aCollection collect: [:triplet | SBRow new cellGap: 8;
				addMorphBack: (SBStringMorph new contents: triplet first);
				addMorphBack: triplet second].
]

{ #category : #private }
SBPyPltComboBox >> chooseMorphs: aCollection [

	| dialog |
	dialog := DialogWindow new
		title: 'Please Choose';
		message: '';
		filterEnabled: true;
		autoCancel: true;
		yourself.
	aCollection withIndexDo: [:ea :index | dialog createButton: ea value: index].
	(tooltips ifNil: [aCollection collect: #balloonText])
		with: dialog buttons
		do: [:tooltip :button | button balloonText: tooltip].
	dialog selectedButtonIndex: 1.
	^ dialog getUserResponseAtHand
]

{ #category : #'event handling' }
SBPyPltComboBox >> click: anEvent [

	self containingSandblock select
]

{ #category : #accessing }
SBPyPltComboBox >> contents [
	(self object class ~= SBRow) ifTrue: [^ self object].
	^ self object firstSubmorph contents
]

{ #category : #accessing }
SBPyPltComboBox >> display [
"returns morph to display"

	(object class ~= SBRow) ifTrue: [^object].
	 (self hasObjectSmallImage) ifTrue: [^ object submorphs second form scaledIntoFormOfSize: 30@30].
	
	^ object submorphs first contents
]

{ #category : #'event handling' }
SBPyPltComboBox >> doubleClick: evt [

	| choice |
	choice := (self chooseMorphs: values) ifNotNil: [:index | values at: index].
	choice ifNotNil: [
		self sandblockEditor do: (SBMutatePropertyCommand new
			target: self;
			selector: #object;
			value: choice)]
]

{ #category : #testing }
SBPyPltComboBox >> handlesMouseDown: evt [

	^ true
]

{ #category : #testing }
SBPyPltComboBox >> hasObjectSmallImage [
"determines whether to show string or image in selection"

	| isImage isSmallImage |
	
	(object class ~= SBRow) ifTrue: [^ false].
	
	isImage := object submorphs second class = ImageMorph.
	isSmallImage := isImage and: [object submorphs second form extent y < 35].
	^ isSmallImage
]

{ #category : #'initialize-release' }
SBPyPltComboBox >> icons: aCollection [

	icons := aCollection
]

{ #category : #'initialize-release' }
SBPyPltComboBox >> initialize [

	super initialize.
	
	self addMorphBack: (SBStringMorph new opacity: 0.7).
	self addMorphBack: (SBStringMorph new).
]

{ #category : #'event handling' }
SBPyPltComboBox >> mouseDown: evt [

	evt hand waitForClicksOrDrag: self event: evt
]

{ #category : #accessing }
SBPyPltComboBox >> object [

	^ object
]

{ #category : #'initialize-release' }
SBPyPltComboBox >> object: anObject [

	object := anObject.
	
	self removeMorph: self lastSubmorph.
	
	(self hasObjectSmallImage) 
		ifTrue: [self addMorphBack: (ImageMorph new image: self display)] 
		ifFalse: [self addMorphBack: (SBTextBubble new contents: self display)].
	
	icons ifNotNil: [ | index icon |
		index := values indexOf: object.
		self submorphCount > 2 ifTrue: [self submorphs third delete].
		icon := icons at: index.
		icon image: (icon image scaledIntoFormOfSize: TextStyle defaultFont height asPoint).
		self addMorphBack: icon]
]

{ #category : #'initialize-release' }
SBPyPltComboBox >> prefix: aString [

	self firstSubmorph contents: aString
]

{ #category : #'initialize-release' }
SBPyPltComboBox >> tooltips: aCollection [

	tooltips := aCollection
]

{ #category : #'initialize-release' }
SBPyPltComboBox >> values: aCollection [

	values := aCollection
]
