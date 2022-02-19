"
Changes parent such that the selection is based on a row, not a string. This enables the use of complex morphs in the dialog.
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> click: anEvent [

	self containingSandblock select
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> contents [
	^ self object firstSubmorph contents
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> display: anObject [
"shows image of row iff image is small enough, else shows string"

	 (self isSmallImage: anObject) ifTrue: [^ anObject submorphs second form scaledIntoFormOfSize: 30@30].
	
	^ anObject submorphs first contents
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> doubleClick: evt [

	| choice |
	choice := (self chooseMorphs: values) ifNotNil: [:index | values at: index].
	choice ifNotNil: [
		self sandblockEditor do: (SBMutatePropertyCommand new
			target: self;
			selector: #object;
			value: choice)]
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> handlesMouseDown: evt [

	^ true
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> icons: aCollection [

	icons := aCollection
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> initialize [

	super initialize.
	
	self addMorphBack: (SBStringMorph new opacity: 0.7).
	self addMorphBack: (SBStringMorph new).
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> isSmallImage: anObject [
"determines whether to show string or image in selection"

	| isImage isSmallImage |
	
	isImage := anObject submorphs second class = ImageMorph.
	isSmallImage := isImage and: anObject submorphs second form extent y < 35.
	^ isSmallImage
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> mouseDown: evt [

	evt hand waitForClicksOrDrag: self event: evt
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> object [

	^ object
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> object: anObject [

	object := anObject.
	
	self removeMorph: self lastSubmorph.
	
	(self isSmallImage: object) 
		ifTrue: [self addMorphBack: (ImageMorph new image: (self display: anObject))] 
		ifFalse: [self addMorphBack: (SBStringMorph new contents: (self display: anObject))].
	
	icons ifNotNil: [ | index icon |
		index := values indexOf: object.
		self submorphCount > 2 ifTrue: [self submorphs third delete].
		icon := icons at: index.
		icon image: (icon image scaledIntoFormOfSize: TextStyle defaultFont height asPoint).
		self addMorphBack: icon]
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> prefix: aString [

	self firstSubmorph contents: aString
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> tooltips: aCollection [

	tooltips := aCollection
]

{ #category : #'as yet unclassified' }
SBPyPltComboBox >> values: aCollection [

	values := aCollection
]
