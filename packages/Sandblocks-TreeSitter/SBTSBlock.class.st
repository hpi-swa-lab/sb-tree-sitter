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
SBTSBlock class >> registerShortcuts: aProvider [

	aProvider
		registerShortcut: Character space do: #promptTransition;
		registerShortcut: Character space shift do: #promptTransition
]

{ #category : #'as yet unclassified' }
SBTSBlock >> absorbsInput: anEvent [

	(anEvent commandKeyPressed or: [anEvent optionKeyPressed or: [anEvent controlKeyPressed]]) ifTrue: [^ false].
	^ anEvent keyCharacter isPrintable and: [self currentTextMorph slot firstNode regex matches: anEvent keyCharacter asString]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> actionProviders [

	^ super actionProviders, {self grammarHandler}
]

{ #category : #'as yet unclassified' }
SBTSBlock >> adaptSlot: aConverter [
	<convert>

	aConverter
		if: [
			(aConverter objectInterface first isKindOf: SBTSObjectInterface)
				ifTrue: [self slot copy adaptSlotFor: aConverter objectInterface first slot]
				ifFalse: [false]]
		do: [ | copy |
			copy := self copyBlock.
			copy slot adaptSlotFor: aConverter objectInterface first slot.
			copy]
]

{ #category : #accessing }
SBTSBlock >> addBlock: aBlock [
	"use this when adding foreign blocks to self, it will adapt the slot accordingly, if possible"

	self
		cursorPositionsDo: [:pos |
			pos isInsert ifTrue: [ | targetSlot |
				targetSlot := SBTSSlot new addNode: pos command element.
				(aBlock slot adaptSlotFor: targetSlot) ifTrue: [^ self addMorphBack: aBlock]]]
		shallow: true.
	self error: ('no suitable insertion point for a `{1}` in a `{2}` found' format: {aBlock printString. self printString})
]

{ #category : #'inline block compat' }
SBTSBlock >> alias [
	"remove, compat to inlineblocks"

	self flag: #todo.
	^ nil
]

{ #category : #replacements }
SBTSBlock >> allReplacementCandidates [

	^ SBTSReplacementBlock allSubclasses gather: [:class | (Pragma allNamed: #lang:match: in: class), (Pragma allNamed: #lang:match:sample: in: class) select: [:pragma | pragma arguments first = self factory name]]
]

{ #category : #replacements }
SBTSBlock >> applyReplacement [

	| candidates |
	candidates := self allReplacementCandidates.
	candidates do: [:pragma | | blockClass |
		blockClass := pragma methodClass.
		(blockClass
			match: self
			against: (SBTSQuery new prepare: pragma arguments second)
			buildSelector: pragma selector) ifNotNil: [:cmd |
			^ cmd]].
	^ nil
]

{ #category : #actions }
SBTSBlock >> applyReplacements [
	<action>

	| candidates |
	candidates := self allReplacementCandidates.
	self allBlocksDo: [:block |
		(block isTSBlock and: [block isTSReplacement not]) ifTrue: [
			candidates do: [:pragma | | blockClass |
				blockClass := pragma methodClass.
				(blockClass
					match: block
					against: (SBTSQuery new prepare: pragma arguments second)
					buildSelector: pragma selector) ifNotNil: [:cmd |
					self sandblockEditor
						ifNotNil: [:e | e do: (cmd shouldMergeWithNext: true)]
						ifNil: [cmd do]]]]]
]

{ #category : #accessing }
SBTSBlock >> children [

	^ self submorphs
]

{ #category : #'inline block compat' }
SBTSBlock >> childrenForQuery [
	"remove, compat with inlineblocks"

	self flag: #todo.
	^ self children
]

{ #category : #'as yet unclassified' }
SBTSBlock >> compatibleWithType: aString [

	^ self slot compatibleWithType: aString
]

{ #category : #'as yet unclassified' }
SBTSBlock >> copyBlock [

	| copy |
	copy := self class new
		addAllMorphs: (self isUnknown ifTrue: [{}] ifFalse: [self submorphs collect: [:s | s copyBlock]]);
		slot: self slot copy.
	self
		valueOfProperty: #lastConstructed
		ifPresentDo: [:val | copy setProperty: #lastConstructed toValue: true].
	^ copy
]

{ #category : #'as yet unclassified' }
SBTSBlock >> currentTextMorph [

	self submorphsDo: [:m | (m isKindOf: SBTSTextMorph) ifTrue: [^ m]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSBlock >> cursorPositionsDo: aBlock shallow: aBoolean [

	aBlock value: (SBCursorSelect new block: self).
	self template
		cursorPositionsDo: aBlock
		shallow: aBoolean
		blocks: self children readStream
		parent: self
]

{ #category : #'as yet unclassified' }
SBTSBlock >> deleteBeforeCursor [
	<action>

	| editor textMorph |
	textMorph := self sandblockEditor currentInputCommand textMorph.
	self contents ifNotEmpty: [^ super deleteBeforeCursor].
	editor := self sandblockEditor.
	
	textMorph submorphBefore ifNil: [
		(self parentSandblock deleteCommandFor: self) ifNotNil: [:c | | pos |
			pos := self sandblockEditor cursor positionBefore: c commands first target.
			editor do: c.
			editor cursor cursorPosition: pos explicitMove: true axis: #x.
			^ self]].
	
	self reinterpretWithoutEmpty ifFalse: [
		self parentSandblock reinterpretWithoutEmpty ifFalse: [
			self parentSandblock parentSandblock reinterpretWithoutEmpty ifFalse: [
				self childSandblocks size > 0
					ifTrue: [self changeToUnknown]
					ifFalse: [editor performForSelection: #moveCursorLeft]]]]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> deleteCommandFor: aBlock [

	| groups |
	aBlock slot repeatersDo: [:repeater |
		groups := repeater groupsIn: self.
		(repeater required not or: [groups size > 1]) ifTrue: [groups do: [:group | (group includes: aBlock) ifTrue: [^ SBCombinedCommand newWith: (group collect: [:block | SBDeleteCommand new target: block])]]]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSBlock >> evaluate [

	^ self factory runtime evaluate: self sourceString
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
SBTSBlock >> get: aFieldNameString [

	| matches |
	matches := self children select: [:child | child field = aFieldNameString].
	matches ifNotEmpty: [
		^ (matches size > 1 and: [matches first slot includesRepeat])
			ifTrue: [matches]
			ifFalse: [matches first]].
	^ nil
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
	
	aBlock slot lastRepeater ifNotNil: [:repeater | ^ SBRelInsertCommand new near: aBlock before: aBoolean in: self morph: aMorph].
	
	^ nil
]

{ #category : #testing }
SBTSBlock >> isBlockBody [

	^ self slot factory isStatementContainer: self type
]

{ #category : #testing }
SBTSBlock >> isExpression [

	self slot allSuperTypesDo: [:type | (self factory expressionTypes includes: type type) ifTrue: [^ true]].
	^ false
]

{ #category : #testing }
SBTSBlock >> isTSBlock [

	^ true
]

{ #category : #testing }
SBTSBlock >> isTSMorph [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSBlock >> isTSReplacement [

	^ false
]

{ #category : #testing }
SBTSBlock >> keepDuringTransform [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSBlock >> keyStroke: anEvent [

	self tryApplyChange: [:block | super keyStroke: anEvent] input: anEvent keyCharacter asString
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
			self children overlappingPairsDo: [:a :b |
				stream nextPut: a layoutCommands.
				(self factory hardLineBreakBetween: a and: b)
					ifTrue: [stream nextPut: SBAlgebraCommand hardLine]
					ifFalse: [
						(self factory softLineBreakBetween: a and: b)
							ifTrue: [stream nextPut: SBAlgebraCommand softLineOrGap]
							ifFalse: [stream nextPut: SBAlgebraCommand gap]]].
			self children ifNotEmpty: [stream nextPut: self lastSubmorph layoutCommands]])
]

{ #category : #'as yet unclassified' }
SBTSBlock >> matchesQuery: aString [

	^ SBTSQuery new execute: aString against: self capturesDo: [:b | ]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> newEmptyChildNear: aBlock before: aBoolean [

	aBlock ifNil: [^ nil].
	aBlock isTSMorph ifFalse: [^ nil].
	aBlock slot lastRepeater ifNotNil: [:repeater |
		self flag: #todo.
		"can return multiple"
		^ repeater element buildEmpty first].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSBlock >> newNullBlock [

	^ SBTSUnknownBlock new slot: (SBTSSlot new addNode: self slot lastNode)
]

{ #category : #'as yet unclassified' }
SBTSBlock >> objectInterfaceForChild: aBlock [

	^ {SBTSObjectInterface new slot: aBlock slot}
]

{ #category : #'as yet unclassified' }
SBTSBlock >> objectInterfaceForInsert: aCommand [

	^ {SBTSObjectInterface new slot: (SBTSSlot new addNode: aCommand element)}
]

{ #category : #highlight }
SBTSBlock >> ownerWithColor [

	^ self highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithColor]]
		ifFalse: [self]
]

{ #category : #highlight }
SBTSBlock >> preferredColorIn: aColorPolicy [

	^ self slot preferredColorIn: aColorPolicy for: self highlight
]

{ #category : #'as yet unclassified' }
SBTSBlock >> prefixValid [

	^ self currentTextMorph
		ifNotNil: [:t | t slot firstNode prefixValidFor: t contents]
		ifNil: [true]
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
	self field ifNotNil: [
		aStream nextPutAll: self field.
		aStream nextPutAll: ': '].
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

{ #category : #actions }
SBTSBlock >> promptTransition [
	<action>

	SBTSDisambiguatePopup new for: self input: '' before: ActiveEvent shiftPressed
]

{ #category : #'as yet unclassified' }
SBTSBlock >> query: aString capturesDo: aBlock [

	^ SBTSQuery new execute: aString against: self capturesDo: aBlock
]

{ #category : #'as yet unclassified' }
SBTSBlock >> queryRecursiveFirstMatch: aString capturesDo: aBlock [

	self allBlocksDo: [:block |
		block isTSBlock ifTrue: [ | captures |
			captures := nil.
			(SBTSQuery new execute: aString against: block capturesDo: [:cap | captures := cap]) ifTrue: [
				aBlock value: captures.
				^ true]]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSBlock >> reinterpretWithoutEmpty [

	| remaining options editor |
	editor := self sandblockEditor.
	remaining := self children select: [:m | m sourceString notEmpty].
	remaining ifEmpty: [
		(self parentSandblock deleteCommandFor: self) ifNotNil: [:c |
			editor do: c.
			editor selection moveCursorToEnd.
			^ true].
		^ false].
	options := SBTSInputParser new optionsFor: self given: '' before: remaining after: #().
	(options size = 1 and: [options first first type ~= self type]) ifTrue: [
		editor do: (SBReplaceMultipleCommand new target: self replacers: options first).
		options first last lastDeepChild startInputAtEnd.
		^ true].
	(remaining allSatisfy: [:m | m slot firstNode isTSLabel]) ifTrue: [
		(self parentSandblock deleteCommandFor: self) ifNotNil: [:c |
			editor do: c.
			editor selection moveCursorToEnd.
			^ true]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSBlock >> repeaterGroup [

	self slot repeater ifNotNil: [:repeater | | myIndex mySubIndex seq start |
		myIndex := self submorphIndex.
		self flag: #todo.
		" does not consider nested repeats and nested seqs "
		seq := self slot parentThat: [:p | p isTSSeq and: [p hasParent: repeater]].
		seq ifNil: [^ {self}].
		
		mySubIndex := (self slot parentThat: [:p | p parent = seq]) in: [:c | c parent elements indexOf: c].
		start := myIndex - mySubIndex + 1.
		^ self owner children copyFrom: start to: start + seq elements size - 1].
	^ nil
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
SBTSBlock >> sourceStringForCompare [

	^ String streamContents: [:s | self writeSourceOn: s indent: 0 forCompare: true]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> startInputCommandIn: aTextMorph [

	^ SBTextCommand new textMorph: aTextMorph
]

{ #category : #'as yet unclassified' }
SBTSBlock >> statements [

	^ self isBlockBody ifTrue: [self childSandblocks] ifFalse: [#()]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> suggestions [

	^ self factory suggestionsFor: self
]

{ #category : #'as yet unclassified' }
SBTSBlock >> template [

	^ self slot firstNode bodyTemplate
]

{ #category : #'as yet unclassified' }
SBTSBlock >> textMorphs [

	^ self submorphs select: [:t | t isTextMorph]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> tryApplyChange: aBlock input: aString [

	| previousContents isAtStart |
	previousContents := self contents.
	isAtStart := self currentTextMorph cursor = 1.
	aBlock value: self.
	
	^ self prefixValid ifTrue: [true] ifFalse: [
		self contents: previousContents.
		SBTSDisambiguatePopup new
			for: (self isUnknown ifTrue: [self] ifFalse: [self currentTextMorph])
			input: aString
			before: isAtStart]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> type [

	^ self slot type
]

{ #category : #highlight }
SBTSBlock >> updateAllHighlights [

	self slot updateAllHighlightsFor: self
]

{ #category : #'as yet unclassified' }
SBTSBlock >> useSuggestion: anItem [

	self contents: ''.
	self tryApplyChange: [:b | b contents: anItem contents] input: anItem contents
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
SBTSBlock >> wantsInput [

	(self currentTextMorph notNil and: [self contents isEmpty]) ifTrue: [^ true].
	
	(self isBlockBody and: [self hasChildSandblocks not]) ifTrue: [^ true].
	
	^ false
]

{ #category : #actions }
SBTSBlock >> wrapWithWatch [
	<action>

	self isWatch ifTrue: [^ self sandblockEditor do: (SBReplaceCommand new target: self replacer: self expression copyBlock)].
	self parentSandblock isWatch ifTrue: [
		^ self sandblockEditor do: (SBReplaceCommand new
			target: self parentSandblock
			replacer: self parentSandblock expression copyBlock)].
	
	(self orOwnerSuchThat: [:o | o isTSBlock and: [o isExpression]]) ifNotNil: [:expr | self sandblockEditor do: (SBReplaceCommand new target: expr replacer: (SBWatch2 newEmptyFor: expr copyBlock))]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> writeSourceOn: aStream [

	self writeSourceOn: aStream indent: 0 forCompare: false
]

{ #category : #'as yet unclassified' }
SBTSBlock >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	self children ifEmpty: [^ self].
	
	(self factory indentMatch: self) ifTrue: [aStream tab: aNumber].
	self children overlappingPairsDo: [:first :second |
		first writeSourceOn: aStream indent: (self indentFor: first current: aNumber) forCompare: aBoolean.
		aStream nextPutAll: (self slot separatorBetween: first and: second indent: aNumber)].
	self lastSubmorph
		writeSourceOn: aStream
		indent: (self indentFor: self lastSubmorph current: aNumber)
		forCompare: aBoolean
]
