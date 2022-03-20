Class {
	#name : #SBTSUnknownBlock,
	#superclass : #SBTSBlock,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> absorbsInput: anEvent [

	^ false
]

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
SBTSUnknownBlock >> prefixValid [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> printOn: aStream [

	aStream nextPutAll: 'unknown '.
	super printOn: aStream
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> slot: aSlot [

	| label |
	super slot: aSlot.
	self firstSubmorph slot: aSlot.
	
	label := self slot firstNode printString.
	self firstSubmorph placeholderText: (label size < 15 ifTrue: [label] ifFalse: [(label first: 12), '...'])
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> suggestAlways [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> suggestions [

	^ (self slot firstNode isTSChoice and: [self slot firstNode alternatives allSatisfy: #isTSLabel])
		ifTrue: [self slot firstNode alternatives collect: [:alt | SBTSBlockSuggestion new blocks: alt buildEmpty in: self sandblockEditor]]
		ifFalse: [#()]
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

{ #category : #'as yet unclassified' }
SBTSUnknownBlock >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	aBoolean ifTrue: [aStream nextPut: (Character value: 0)]
]
