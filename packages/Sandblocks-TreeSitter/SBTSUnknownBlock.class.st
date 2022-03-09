Class {
	#name : #SBTSUnknownBlock,
	#superclass : #SBTSBlock,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> cursorPositionsDo: aBlock shallow: aBoolean [

	aBlock value: (SBCursorSelect new block: self).
	self startInputCommand ifNotNil: [:command |
		aBlock value: (SBCursorText new
			block: self;
			currentCommand: command)]
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> initialize [

	super initialize.
	self addMorphBack: SBTSTextMorph new
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> isUnknown [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> printOn: aStream [

	aStream nextPutAll: 'unknown '.
	super printOn: aStream
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> slot: aSlot [

	super slot: aSlot.
	self firstSubmorph slot: aSlot
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> tryTransitionAfterInput: aString before: aBoolean [

	^ SBTSInputParser new optionsForTemplate: self slot lastNode given: aString
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> valid [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> wantsInput [

	^ true
]
