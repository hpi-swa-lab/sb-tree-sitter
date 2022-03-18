Class {
	#name : #SBTSBlock,
	#superclass : #SBBlock,
	#instVars : [
		'slot',
		'highlight'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSBlock >> actionProviders [

	^ {self grammarHandler}, super actionProviders
]

{ #category : #'inline block compat' }
SBTSBlock >> alias [
	"remove, compat to inlineblocks"

	self flag: #todo.
	^ nil
]

{ #category : #'inline block compat' }
SBTSBlock >> childrenForQuery [
	"remove, compat with inlineblocks"

	self flag: #todo.
	^ self submorphs
]

{ #category : #'as yet unclassified' }
SBTSBlock >> compatibleWithType: aString [

	^ self slot compatibleWithType: aString
]

{ #category : #'as yet unclassified' }
SBTSBlock >> copyBlock [

	^ self class new
		addAllMorphs: (self submorphs collect: [:s | s copyBlock]);
		slot: self slot copy
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
SBTSBlock >> field [

	^ self slot field
]

{ #category : #'as yet unclassified' }
SBTSBlock >> fixedNumberOfChildren [

	self cursorPositionsDo: [:c | (c isKindOf: SBCursorInsert) ifTrue: [^ false]] shallow: true.
	^ true
]

{ #category : #'as yet unclassified' }
SBTSBlock >> grammarHandler [

	^ SBGrammarHandler new
]

{ #category : #highlight }
SBTSBlock >> highlight [

	^ highlight ifNil: [self updateAllHighlights]
]

{ #category : #highlight }
SBTSBlock >> highlight: aString [

	highlight := aString
]

{ #category : #'as yet unclassified' }
SBTSBlock >> indentFor: aBlock current: aNumber [

	^ (self factory indentMatch: aBlock)
		ifTrue: [aNumber + 1]
		ifFalse: [aNumber]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> initialize [

	super initialize.
	
	self
		layoutPolicy: SBAlgebraLayout new;
		layoutInset: 0;
		cellGap: 2;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap
]

{ #category : #'as yet unclassified' }
SBTSBlock >> insertCommandRequest: aMorph near: aBlock before: aBoolean [

	aBlock ifNil: [^ nil].
	
	aBlock slot repeater ifNotNil: [:repeater | ^ SBRelInsertCommand new near: aBlock before: aBoolean in: self morph: aMorph].
	
	^ nil
]

{ #category : #testing }
SBTSBlock >> isBlockBody [

	^ self slot factory isStatementContainer: self type
]

{ #category : #testing }
SBTSBlock >> isTSBlock [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSBlock >> keyStroke: anEvent [

	| previousContents isAtStart |
	previousContents := self contents.
	isAtStart := self currentTextMorph cursor = 1.
	super keyStroke: anEvent.
	
	self valid ifFalse: [
		self contents: previousContents.
		SBTSDisambiguatePopup new
			for: self
			input: anEvent keyCharacter asString
			before: isAtStart]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> language [

	^ self slot factory name
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
					ifFalse: [
						(self factory softLineBreakBetween: a and: b)
							ifTrue: [stream nextPut: SBAlgebraCommand softLine]
							ifFalse: [stream nextPut: SBAlgebraCommand gap]]].
			self hasSubmorphs ifTrue: [stream nextPut: self lastSubmorph layoutCommands]])
]

{ #category : #'as yet unclassified' }
SBTSBlock >> matchesQuery: aString [

	^ SBTSQuery new execute: aString against: self capturesDo: [:b | ]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> newEmptyChildNear: aBlock before: aBoolean [

	aBlock ifNil: [^ nil].
	aBlock slot repeater ifNotNil: [:repeater |
		self flag: #todo.
		"can return multiple"
		^ repeater element buildEmpty first].
	^ nil
]

{ #category : #highlight }
SBTSBlock >> ownerWithColor [

	^ self highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithColor]]
		ifFalse: [self]
]

{ #category : #highlight }
SBTSBlock >> preferredColorIn: aColorPolicy [

	^ self highlight
		caseOf: {
			['keyword'] -> [aColorPolicy keyword].
			['function'] -> [aColorPolicy identifier].
			['comment'] -> [aColorPolicy defaultLight].
			['variable'] -> [aColorPolicy identifier].
			['type'] -> [aColorPolicy keyword].
			['number'] -> [aColorPolicy literal].
			['string'] -> [aColorPolicy literal].
			['escape'] -> [aColorPolicy literal].
			['punctuation.bracket'] -> [aColorPolicy builtIn].
			['constant.builtin'] -> [aColorPolicy builtIn].
			['operator'] -> [aColorPolicy identifier].
			['property'] -> [aColorPolicy identifier].
			['important'] -> [aColorPolicy important]}
		otherwise: [aColorPolicy default]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> printOn: aStream [

	self slot ifNotNil: [slot firstNode printOn: aStream]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> printTree [

	^ String streamContents: [:stream | self printTreeOn: stream indent: 0]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> printTreeOn: aStream indent: aNumber [

	| any |
	aStream nextPut: $(.
	self printOn: aStream.
	any := false.
	self submorphsDo: [:m |
		m isTSBlock ifTrue: [
			any := true.
			aStream crtab: aNumber + 1.
			m printTreeOn: aStream indent: aNumber + 1]].
	any ifTrue: [aStream crtab: aNumber].
	aStream nextPut: $)
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
SBTSBlock >> statements [

	^ self isBlockBody ifTrue: [self childSandblocks] ifFalse: [#()]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> template [

	^ self factory bodyNodeForRule: self type
]

{ #category : #'as yet unclassified' }
SBTSBlock >> tryTransitionAfterInput: aString before: aBoolean [

	^ SBTSInputParser new optionsFor: self given: aString before: aBoolean
]

{ #category : #'as yet unclassified' }
SBTSBlock >> type [

	^ self slot type
]

{ #category : #highlight }
SBTSBlock >> updateAllHighlights [

	self factory hasHighlight ifFalse: [^ self].
	self allMorphsDo: [:m |
		m isTSBlock ifTrue: [
			m highlight: #'_sb_none'.
			m updateHighlight]]
]

{ #category : #highlight }
SBTSBlock >> updateHighlight [

	self factory highlightQuery
		executeAgainst: self
		capturesDo: [:captures | captures keysAndValuesDo: [:id :block | (block highlight isNil or: [block highlight = #'_sb_none']) ifTrue: [block highlight: id]]]
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

	self writeSourceOn: aStream indent: 0
]

{ #category : #'as yet unclassified' }
SBTSBlock >> writeSourceOn: aStream indent: aNumber [

	self hasSubmorphs ifFalse: [^ self].
	
	(self factory indentMatch: self) ifTrue: [aStream tab: aNumber].
	self submorphs overlappingPairsDo: [:first :second |
		first writeSourceOn: aStream indent: (self indentFor: first current: aNumber).
		aStream nextPutAll: (self slot separatorBetween: first and: second indent: aNumber)].
	self lastSubmorph
		writeSourceOn: aStream
		indent: (self indentFor: self lastSubmorph current: aNumber)
]
