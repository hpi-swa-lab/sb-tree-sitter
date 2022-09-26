Class {
	#name : #SBTSHoverMorph,
	#superclass : #ScrollPane,
	#instVars : [
		'morph',
		'container'
	],
	#category : #'Sandblocks-TreeSitter-Project'
}

{ #category : #contents }
SBTSHoverMorph >> addString: aString [

	| backgroundColor background |
	backgroundColor := Color r: 1 g: 1 b: 1.
	container submorphCount = 0
		ifTrue: [backgroundColor := Color r: 0.0 g: 0.0 b: 1]
		ifFalse: [container addMorphBack: SBDivider new].
	background := Morph new
		color: backgroundColor;
		changeTableLayout;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		layoutInset: 10 @ 4 * self scalingFactor;
		yourself.
	background addMorphBack: (SBMultilineOwnTextMorph new
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

	anObject isString ifTrue: [^ self addString: anObject].
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

	self addAlarm: #delete after: 300
]

{ #category : #'events-processing' }
SBTSHoverMorph >> handleMouseEnter: anEvent [

	super handleMouseEnter: anEvent.
	self cancelDelete
]

{ #category : #'events-processing' }
SBTSHoverMorph >> handleMouseLeave: anEvent [

	super handleMouseLeave: anEvent.
	self deleteSoon
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
