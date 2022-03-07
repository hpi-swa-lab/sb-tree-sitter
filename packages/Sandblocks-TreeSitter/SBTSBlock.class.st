Class {
	#name : #SBTSBlock,
	#superclass : #SBBlock,
	#instVars : [
		'slot'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSBlock >> copyBlock [

	^ self class new
		addAllMorphs: (self submorphs collect: [:s | s copyBlock]);
		slot: self slot
]

{ #category : #'as yet unclassified' }
SBTSBlock >> currentTextMorph [

	self submorphsDo: [:m | (m isKindOf: SBOwnTextMorph) ifTrue: [^ m]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSBlock >> cursorPositionsDo: aBlock shallow: aBoolean [

	aBlock value: (SBCursorSelect new block: self).
	self template cursorPositionsDo: aBlock shallow: aBoolean blocks: self submorphs parent: self
]

{ #category : #'as yet unclassified' }
SBTSBlock >> deleteCommandFor: aBlock [

	self flag: #todo.
	"if we have a sequence of blocks we need to make sure to delete all of them and not just the selection. The naive approach below, however, always deletes all elements in the repeat."
	^ SBToggledCode comment: '' active: 1 do: {
		[
			aBlock slot includesRepeat
				ifTrue: [SBDeleteCommand new target: aBlock]
				ifFalse: [nil]].
		[ | repeatElement |
			repeatElement := aBlock slot parentThat: [:p | p parent ifNotNil: #isTSRepeat ifNil: [false]].
			repeatElement ifNotNil: [SBCombinedCommand newWith: ((self submorphs select: [:s | s slot includesParent: repeatElement]) collect: [:m | SBDeleteCommand new target: m])]]}
]

{ #category : #'as yet unclassified' }
SBTSBlock >> factory [

	^ self slot factory
]

{ #category : #'as yet unclassified' }
SBTSBlock >> fixedNumberOfChildren [

	self cursorPositionsDo: [:c | (c isKindOf: SBCursorInsert) ifTrue: [^ false]] shallow: true.
	^ true
]

{ #category : #'as yet unclassified' }
SBTSBlock >> initialize [

	super initialize.
	
	self
		layoutPolicy: SBAlgebraLayout new;
		layoutInset: 8;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap
]

{ #category : #testing }
SBTSBlock >> isBlockBody [

	^ self factory isStatementContainer: self type
]

{ #category : #testing }
SBTSBlock >> isTSBlock [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSBlock >> keyStroke: anEvent [

	super keyStroke: anEvent.
	
	self valid ifFalse: [
		self flag: #todo.
		"pass the entire newly invalid string"
		self tryTransitionAfterInput: anEvent keyCharacter asString]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (Array streamContents: [:stream |
			self submorphs overlappingPairsDo: [:a :b |
				stream nextPut: a layoutCommands.
				(self factory hardLineBreakBetween: a and: b)
					ifTrue: [stream nextPut: SBAlgebraCommand hardLine]
					ifFalse: [(self factory softLineBreakBetween: a and: b) ifTrue: [stream nextPut: SBAlgebraCommand softLine]]].
			self hasSubmorphs ifTrue: [stream nextPut: self lastSubmorph layoutCommands]])
]

{ #category : #'as yet unclassified' }
SBTSBlock >> printOn: aStream [

	self slot ifNotNil: [slot firstNode printOn: aStream]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> slot [

	^ slot
]

{ #category : #'as yet unclassified' }
SBTSBlock >> slot: aSlot [

	self assert: (aSlot isKindOf: SBTSSlot).
	slot := aSlot
]

{ #category : #'as yet unclassified' }
SBTSBlock >> template [

	^ self factory bodyNodeForRule: self type
]

{ #category : #'as yet unclassified' }
SBTSBlock >> tryTransitionAfterInput: aString [

	SBTSInputParser new optionsFor: self given: aString before: false
]

{ #category : #'as yet unclassified' }
SBTSBlock >> type [

	^ self slot type
]

{ #category : #'as yet unclassified' }
SBTSBlock >> valid [

	self flag: #todo.
	" cache valid "
	^ self currentTextMorph
		ifNotNil: [:t | t slot firstNode validFor: t contents]
		ifNil: [true]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> writeSourceOn: aStream [

	self flag: #todo.
	aStream
]
