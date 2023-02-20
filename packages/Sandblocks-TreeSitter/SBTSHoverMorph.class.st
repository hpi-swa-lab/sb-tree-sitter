Class {
	#name : #SBTSHoverMorph,
	#superclass : #ScrollPane,
	#instVars : [
		'morph',
		'container'
	],
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #contents }
SBTSHoverMorph >> addString: aString [

	| backgroundColor background |
	backgroundColor := Color r: 1 g: 1 b: 1.
	container hasSubmorphs ifTrue: [container addMorphBack: SBDivider new].
	background := Morph new
		color: backgroundColor;
		changeTableLayout;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		layoutInset: (10 @ 4) sbScaled;
		yourself.
	background addMorphBack: (SBMultilineOwnTextMorph new
		maxWidth: 800;
		contents: aString;
		yourself).
	container addMorphBack: background
]

{ #category : #deleting }
SBTSHoverMorph >> cancelDelete [

	self removeAlarm: #delete
]

{ #category : #contents }
SBTSHoverMorph >> contents: anObject [

	(anObject isString or: [anObject isText]) ifTrue: [^ self addString: anObject].
	anObject isDictionary ifTrue: [^ self addString: (anObject at: 'value')].
	anObject do: [:content | self contents: content]
]

{ #category : #'submorphs - add/remove' }
SBTSHoverMorph >> delete [

	super delete.
	morph removeProperty: #hover
]

{ #category : #deleting }
SBTSHoverMorph >> deleteSoon [
	"essentially just the next tick: the user needs to be able to have moved their mouse on to the popup"

	self addAlarm: #delete after: 1
]

{ #category : #'events-processing' }
SBTSHoverMorph >> handleMouseEnter: anEvent [

	super handleMouseEnter: anEvent.
	self cancelDelete
]

{ #category : #'events-processing' }
SBTSHoverMorph >> handleMouseLeave: anEvent [

	super handleMouseLeave: anEvent.
	self delete
]

{ #category : #initialization }
SBTSHoverMorph >> initialize [

	super initialize.
	self
		hResizing: #shrinkWrap;
		disableLayout: true.
	container := Morph new
		beTransparent;
		changeTableLayout;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		cellGap: 2;
		layoutInset: 0;
		yourself.
	self scroller addMorphBack: container
]

{ #category : #accessing }
SBTSHoverMorph >> morph: aMorph [

	morph := aMorph.
	self reposition
]

{ #category : #positioning }
SBTSHoverMorph >> reposition [

	self height: (230 min: container height + 2).
	self bottomLeft: morph positionInWorld
]

{ #category : #'stepping and presenter' }
SBTSHoverMorph >> step [

	self reposition
]

{ #category : #'stepping and presenter' }
SBTSHoverMorph >> stepTime [

	^ 0
]
