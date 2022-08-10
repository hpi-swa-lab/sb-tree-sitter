Class {
	#name : #SBTSBlock,
	#superclass : #SBBlock,
	#instVars : [
		'slot',
		'highlight',
		'range'
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
	
	(anEvent keyCharacter = Character tab and: [anEvent shiftPressed]) ifTrue: [^ false].
	
	^ anEvent keyCharacter isPrintable and: [ | text oldContents oldPosition |
		text := self activeTextMorph.
		oldContents := text contents.
		
		anEvent keyCharacter = Character cr ifTrue: [^ (oldContents lineCount <= 1 and: [anEvent commandKeyPressed not]) not].
		
		oldPosition := text cursor.
		[
			text keyStroke: anEvent.
			text slot firstNode regex matches: text contents] ensure: [
			text
				contents: oldContents;
				basicCursor: oldPosition]]
]

{ #category : #actions }
SBTSBlock >> actionProviders [

	^ {self language}, super actionProviders
]

{ #category : #'as yet unclassified' }
SBTSBlock >> adaptSlot: aConverter [
	<convert>

	aConverter
		if: [
			(aConverter objectInterface first isKindOf: SBTSObjectInterface)
				ifTrue: [(self adaptSlotFor: aConverter objectInterface first slot ifFailed: [false]) ~~ false]
				ifFalse: [false]]
		do: [
			self copyBlock
				adaptSlotFor: aConverter objectInterface first slot
				ifFailed: [self assert: false]]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> adaptSlotFor: anotherSlot [

	^ self adaptSlotFor: anotherSlot ifFailed: [self error: 'blocks not compatible']
]

{ #category : #'inline block compat' }
SBTSBlock >> adaptSlotFor: anotherSlot ifFailed: aBlock [

	| results |
	" examples:
	* self=stmt,expr,id		anotherSlot=expr|num
	* self=stmt,expr,id		anotherSlot=stmt,expr,id
	* self=expr,id 			anotherSlot=stmt
	"
	results := SBTSInputParser new
		allowIncomplete: false;
		optionsForTemplate: anotherSlot transitionRoot givenBlocks: {self}.
	results ifEmpty: [^ aBlock value].
	self assert: results size = 1.
	self assert: results first size = 1.
	^ results first first
]

{ #category : #accessing }
SBTSBlock >> addBlock: aBlock [
	"use this when adding foreign blocks to self, it will adapt the slot accordingly, if possible"

	self
		cursorPositionsDo: [:pos |
			pos isInsert ifTrue: [ | targetSlot |
				targetSlot := SBTSSlot new addNode: pos command element.
				(aBlock adaptSlotFor: targetSlot ifFailed: [nil]) ifNotNil: [:newBlock | ^ self addMorphBack: newBlock]]]
		shallow: true.
	self error: ('no suitable insertion point for a `{1}` in a `{2}` found' format: {aBlock printString. self printString})
]

{ #category : #'inline block compat' }
SBTSBlock >> alias [

	^ self slot alias
]

{ #category : #replacements }
SBTSBlock >> allReplacementCandidates [

	^ SBTSReplacementBlock allSubclasses gather: [:class | (Pragma allNamed: #lang:match: in: class), (Pragma allNamed: #lang:match:sample: in: class)]
]

{ #category : #replacements }
SBTSBlock >> applyReplacement [

	^ self applyReplacementCommand do
]

{ #category : #replacements }
SBTSBlock >> applyReplacementCommand [

	| candidates |
	candidates := self allReplacementCandidates.
	candidates do: [:pragma | | blockClass |
		blockClass := pragma methodClass.
		(blockClass
			match: self
			against: (SBTSQuery new prepare: pragma arguments second)
			buildSelector: pragma selector) ifNotNil: [:cmd | ^ cmd]].
	^ nil
]

{ #category : #actions }
SBTSBlock >> applyReplacements [
	<action>

	| candidates |
	candidates := self allReplacementCandidates.
	self allBlocksDo: [:block |
		(block isTSBlock and: [block isTSReplacement not]) ifTrue: [
			self
				tryApplyReplacements: (candidates select: [:pragma | pragma arguments first = block language language])
				to: block]]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> asSlider: converter [
	<convert>

	converter
		if: [(self language respondsTo: #sourceForSlider:) and: [self type = #float or: [self type = #integer or: [self type = #number or: [self type = #'num_lit']]]]]
		do: [self language sourceForSlider: self]
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
SBTSBlock >> childrenToKeepDuringDelete [

	| current keep found |
	"up until our current cursor position we use the more strict keepDuringTransform, everything after our cursor position we use the looser keepDuringDelete"
	current := self sandblockEditor cursor cursorPosition.
	keep := OrderedCollection new.
	found := false.
	self cursorPositionsDo: [:c |
		(c morph owner = self and: [(keep includes: c morph) not and: [found ifTrue: [c morph keepDuringDelete] ifFalse: [c morph keepDuringTransform]]]) ifTrue: [keep add: c morph].
		c = current ifTrue: [found := true]].
	
	SBToggledCode comment: '' active: 0 do: {
		[(current morph keepDuringDelete not and: [keep notEmpty and: [current morph = keep last]]) ifTrue: [keep remove: current morph ifAbsent: []]]}.
	
	^ keep
]

{ #category : #actions }
SBTSBlock >> collapseBlock [
	<action>

	| collapsed command |
	collapsed := SBTSCollapsed new.
	command := SBWrapCommand new
		selectAfter: collapsed;
		outer: collapsed;
		inner: self;
		wrap: [:collapse :block | collapse block: block];
		selectAfter: collapsed.
	self sandblockEditor ifNotNil: [:e | e do: command] ifNil: [command do].
	^ collapsed
]

{ #category : #accessing }
SBTSBlock >> collapsedContent [

	^ self type
]

{ #category : #'as yet unclassified' }
SBTSBlock >> colorPolicy [

	^ super colorPolicy copy enlarge: self language alwaysEnlargeInsets
]

{ #category : #'as yet unclassified' }
SBTSBlock >> compatibleWithType: aString [

	^ self slot compatibleWithType: aString
]

{ #category : #accessing }
SBTSBlock >> contentsToDisplay [

	^ self contents
]

{ #category : #'as yet unclassified' }
SBTSBlock >> copyBlock [

	| copy |
	copy := self class new
		addAllMorphs: (self isUnknown ifTrue: [{}] ifFalse: [self submorphs collect: [:s | s copyBlock]]);
		range: range key copy -> range value copy;
		slot: self slot.
	#(#lastConstructed #copyPlaceholder) do: [:prop | self valueOfProperty: prop ifPresentDo: [:val | copy setProperty: prop toValue: val]].
	^ copy
]

{ #category : #'as yet unclassified' }
SBTSBlock >> currentTextMorph [

	self submorphsDo: [:m | (m isTextMorph and: [m symmetricSibling isNil]) ifTrue: [^ m]].
	self submorphsDo: [:m | m isTextMorph ifTrue: [^ m]].
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

	| editor textMorph target |
	editor := self sandblockEditor.
	
	textMorph := self sandblockEditor currentInputCommand ifNotNil: #textMorph.
	(textMorph ifNotNil: #contents ifNil: ['']) ifNotEmpty: [
		super deleteBeforeCursor.
		(self valid not and: [textMorph contents notEmpty]) ifTrue: [ | currentCursor evalOption |
			currentCursor := textMorph cursor.
			evalOption := [:options |
				editor do: options first.
				editor currentInputCommand ifNotNil: [:c | c textMorph moveCursorTo: currentCursor]].
			(SBTSInputReconcile new
				tryReinterpretFrom: textMorph
				in: self
				given: ''
				at: SBTSInputReconcile endIndex
				fullToken: true)
				ifNotEmpty: evalOption
				ifEmpty: [
					(SBTSInputReconcile new
						tryReinterpretFrom: textMorph
						in: self owner
						given: ''
						at: SBTSInputReconcile endIndex
						fullToken: true) ifNotEmpty: evalOption]].
		^ self].
	
	target := self.
	3 timesRepeat: [
		target reinterpretWithoutEmpty ifTrue: [^ self].
		target := target parentSandblock.
		target isTSBlock ifFalse: [^ editor performForSelection: #moveCursorLeft]].
	^ editor performForSelection: #moveCursorLeft
]

{ #category : #'as yet unclassified' }
SBTSBlock >> deleteBeforeCursorOld [
	<action>

	| editor textMorph target |
	editor := self sandblockEditor.
	
	editor mode = #insert ifTrue: [ | newPos |
		newPos := editor cursor cursorPosition moveHorizontal: -1 wordWise: false.
		newPos ifNil: [^ self].
		
		^ (newPos block = self or: [newPos block hasOwner: self])
			ifTrue: [self sandblockEditor performForSelection: #moveCursorLeft]
			ifFalse: [
				(self parentSandblock deleteCommandFor: self) ifNotNil: [:c | | pos |
					pos := editor cursor positionBefore: c commands first target.
					editor do: c.
					editor cursor cursorPosition: pos explicitMove: true axis: #x.
					^ self]]].
	
	textMorph := self sandblockEditor currentInputCommand textMorph.
	self contents ifNotEmpty: [
		super deleteBeforeCursor.
		(self valid not and: [self contents notEmpty]) ifTrue: [
			(SBTSInputReconcile new
				tryReinterpretFrom: self currentTextMorph
				in: self owner
				given: ''
				at: SBTSInputReconcile endIndex) ifNotEmpty: [:options | editor do: options first]].
		^ self].
	
	textMorph submorphBefore ifNil: [
		(self parentSandblock deleteCommandFor: self) ifNotNil: [:c | | pos |
			pos := editor cursor positionBefore: c commands first target.
			editor do: c.
			editor cursor cursorPosition: pos explicitMove: true axis: #x.
			^ self]].
	
	target := self.
	3 timesRepeat: [
		target reinterpretWithoutEmpty ifTrue: [^ self].
		target := target parentSandblock.
		target isTSBlock ifFalse: [
			self childSandblocks size > 0
				ifTrue: [self changeToUnknown]
				ifFalse: [editor performForSelection: #moveCursorLeft].
			^ self]].
	self childSandblocks size > 0
		ifTrue: [self changeToUnknown]
		ifFalse: [editor performForSelection: #moveCursorLeft]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> deleteCommandFor: aBlock [

	| target |
	target := aBlock.
	" walk up the chain of nodes, looking for either a repeater that we can delete from or any nodes that would have created other blocks, thus changing our deletion target "
	aBlock slot allParentsDo: [:p |
		(p createsNewBlock and: [p ~= aBlock slot firstNode]) ifTrue: [target := target parentSandblock].
		p isTSRepeat ifTrue: [ | groups |
			groups := p groupsIn: target owner.
			(p required not or: [groups size > 1]) ifTrue: [groups do: [:group | (group includes: target) ifTrue: [^ SBCombinedCommand newWith: (group collect: [:block | SBDeleteCommand new target: block])]]]]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSBlock >> drawnColor [

	^ self prefersNoBorder
		ifTrue: [super drawnColor alpha: 0]
		ifFalse: [super drawnColor]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> emphasis [

	self highlight ifNotNil: [:h |
		h = 'major_declaration' ifTrue: [^ TextEmphasis bold].
		self type = #comment ifTrue: [^ TextEmphasis italic]].
	^ TextEmphasis normal
]

{ #category : #'as yet unclassified' }
SBTSBlock >> encompasses: aRange [

	range key line > aRange key line ifTrue: [^ false].
	range value line < aRange value line ifTrue: [^ false].
	(range key line = aRange key line and: [range key column > aRange key column]) ifTrue: [^ false].
	(range value line = aRange value line and: [range value column < aRange value column]) ifTrue: [^ false].
	^ true
]

{ #category : #'as yet unclassified' }
SBTSBlock >> evaluate [

	self containingArtefact ifNotNil: [:a | (a respondsTo: #evaluate:) ifTrue: [^ a evaluate: self]].
	^ self language runtime evaluate: self sourceString
]

{ #category : #actions }
SBTSBlock >> evaluateExpression [
	<action>
	<actionValidIf: #isExpression>

	| result |
	result := self evaluate.
	^ result explore
]

{ #category : #'as yet unclassified' }
SBTSBlock >> exportStructure [

	| previous |
	previous := nil.
	^ {
		#children -> (Array streamContents: [:stream |
			self
				cursorPositionsDo: [:pos |
					pos isInsert ifTrue: [stream nextPut: ({#class -> #insert. #horizontal -> pos hasHorizontalLayout. #type -> pos command element type} as: Dictionary)].
					pos isText ifTrue: [stream nextPut: pos block currentTextMorph exportStructure].
					(pos isSelect and: [pos block ~= self]) ifTrue: [
						previous ifNotNil: [(pos block factory hardLineBreakBetween: previous and: pos block) ifTrue: [stream nextPut: ({#class -> #hardLineBreak} as: Dictionary)]].
						stream nextPut: pos block exportStructure.
						previous := pos block]]
				shallow: true]).
		#class -> #block.
		#bounds -> (self bounds in: [:r | {r left. r top. r width. r height}]).
		#type -> self type} as: Dictionary
]

{ #category : #accessing }
SBTSBlock >> factory [

	^ self slot factory
]

{ #category : #'as yet unclassified' }
SBTSBlock >> field [

	^ self slot field
]

{ #category : #'as yet unclassified' }
SBTSBlock >> firstSourceCharacter [

	self writeSourceOn: (SBImmediateStream with: [:c | ^ c]) indent: 0 forCompare: false.
	^ nil
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
SBTSBlock >> getSourceStringAndMark [

	| stream |
	stream := SBLineInfoStream on: ''.
	self writeSourceOn: stream indent: 0 forCompare: false.
	^ stream contents
]

{ #category : #'as yet unclassified' }
SBTSBlock >> grammarHandler [

	^ SBTSGrammarHandler new
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

	^ (self language indentMatch: aBlock)
		ifTrue: [aNumber + 1]
		ifFalse: [aNumber]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> initialize [

	super initialize.
	
	range := (SBTSPosition line: 0 character: 0) -> (SBTSPosition line: 0 character: 0).
	
	self
		layoutPolicy: SBAlgebraLayout new;
		layoutInset: 0;
		cellGap: 2 sbScaled;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap
]

{ #category : #'as yet unclassified' }
SBTSBlock >> insertCommandRequest: aMorph near: aBlock before: aBoolean [

	aBlock ifNil: [^ nil].
	
	aBlock slot lastRepeater ifNotNil: [:repeater | ^ SBRelInsertCommand new near: aBlock before: aBoolean in: self morph: aMorph].
	
	^ nil
]

{ #category : #actions }
SBTSBlock >> insertStatementAbove [
	<action>

	self insertStatementAboveOrBelow: true
]

{ #category : #actions }
SBTSBlock >> insertStatementAboveOrBelow: anAboveBoolean [

	(self sandblockEditor cursor mode = #insert and: [self sandblockEditor cursor cursorPosition command element parent isStatementRepeater]) ifTrue: [^ self sandblockEditor do: self sandblockEditor cursor cursorPosition command].
	
	self andAllParentSandblocksDo: [:block |
		block isTSBlock ifTrue: [
			"look in my template --> insert as child of me"
			(block slot repeaterThat: [:p | p isStatementRepeater]) ifNotNil: [:repeater |
				^ block sandblockEditor do: (SBTSNodeInsertCommand new
					element: (repeater element alternatives detect: [:t | t type = #empty])
					container: block parentSandblock
					index: block submorphIndex + (anAboveBoolean ifTrue: [0] ifFalse: [1]))].
			"look above me --> insert adjacent to me"
			block
				cursorPositionsDo: [:cursor | (cursor isInsert and: [cursor command element parent isStatementRepeater]) ifTrue: [^ block sandblockEditor do: cursor command]]
				shallow: true]]
]

{ #category : #actions }
SBTSBlock >> insertStatementBelow [
	<action>
	<actionValidIf: #insertStatementHasCandidate>

	self insertStatementAboveOrBelow: false
]

{ #category : #'as yet unclassified' }
SBTSBlock >> insertStatementHasCandidate [

	self andAllParentSandblocksDo: [:block |
		block isTSBlock ifTrue: [
			"look in my template --> insert as child of me"
			(block slot repeaterThat: [:p | p isStatementRepeater]) ifNotNil: [:repeater | ^ true].
			"look above me --> insert adjacent to me"
			block
				cursorPositionsDo: [:cursor | (cursor isInsert and: [cursor command element parent isStatementRepeater]) ifTrue: [^ true]]
				shallow: true]].
	^ false
]

{ #category : #testing }
SBTSBlock >> isBlockBody [

	self slot firstNode bodyTemplate allChildrenDo: [:node | (node isTSRepeat and: [node isStatementRepeater]) ifTrue: [^ true]].
	^ false
]

{ #category : #testing }
SBTSBlock >> isEditor [

	^ true
]

{ #category : #testing }
SBTSBlock >> isExpression [

	self slot allSuperTypesDo: [:type | (self language isExpression: type) ifTrue: [^ true]].
	^ false
]

{ #category : #testing }
SBTSBlock >> isMyActiveKeyword: aString [

	^ self activeTextMorph
		ifNotNil: [:t | t slot firstNode isTSLabel and: [t slot firstNode label = aString]]
		ifNil: [false]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> isPart [

	^ self highlight notNil and: [self highlight endsWith: '.part']
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
SBTSBlock >> keepDuringDelete [

	^ self submorphs anySatisfy: [:s | s keepDuringDelete]
]

{ #category : #testing }
SBTSBlock >> keepDuringTransform [

	^ self submorphs anySatisfy: [:s | s keepDuringTransform]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> keyStroke: anEvent [

	self tryApplyChange: [:textMorph | super keyStroke: anEvent] input: anEvent keyCharacter asString
]

{ #category : #accessing }
SBTSBlock >> language [

	^ self factory language
]

{ #category : #accessing }
SBTSBlock >> lastConstructedChild [

	self allMorphsDo: [:m | m valueOfProperty: #lastConstructed ifPresentDo: [:prop | ^ m]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSBlock >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (Array streamContents: [:stream |
			self children overlappingPairsDo: [:a :b |
				stream nextPut: a layoutCommands.
				(self factory addIndent: a) ifTrue: [stream nextPut: SBAlgebraCommand addIndent].
				(self factory removeIndent: b) ifTrue: [stream nextPut: SBAlgebraCommand removeIndent].
				(self factory hardLineBreakBetween: a and: b)
					ifTrue: [stream nextPut: (SBAlgebraCommand hardLine withGap: true)]
					ifFalse: [
						(self factory softLineBreakBetween: a and: b)
							ifTrue: [stream nextPut: (SBAlgebraCommand softLineOrGap withGap: true)]
							ifFalse: [stream nextPut: SBAlgebraCommand gap]]].
			self children ifNotEmpty: [stream nextPut: self lastSubmorph layoutCommands]])
]

{ #category : #query }
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

	^ SBTSUnknownBlock new slot: (SBTSSlot with: self slot lastNode)
]

{ #category : #'as yet unclassified' }
SBTSBlock >> objectInterface [

	^ self parentSandblock
		ifNotNil: [:p | p objectInterfaceForChild: self]
		ifNil: [SBInterfaces block]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> objectInterfaceForChild: aBlock [

	^ aBlock isTSBlock ifTrue: [{SBTSObjectInterface new slot: aBlock slot}] ifFalse: [SBInterfaces never]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> objectInterfaceForInsert: aCommand [

	(aCommand isKindOf: SBTSNodeInsertCommand) ifFalse: [^ SBInterfaces never].
	
	^ {SBTSObjectInterface new slot: (SBTSSlot with: aCommand element)}
]

{ #category : #highlight }
SBTSBlock >> ownerWithForegroundColor [

	^ self highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithForegroundColor]]
		ifFalse: [self]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> pickUp: anEvent [

	self isPart ifTrue: [self owner pickUp: anEvent] ifFalse: [super pickUp: anEvent]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> placeCursorCloseAfterDo: aBlock [

	| index container found |
	container := self owner.
	index := 0.
	found := false.
	container cursorPositionsDo: [:c |
		(found not and: [
			SBToggledCode
				comment: ''
				active: 1
				do: {[self activeTextMorph ~= c morph]. [c block ~= self or: [c isSelect]]}])
			ifTrue: [c isSelect ifFalse: [index := index + 1]]
			ifFalse: [found := true]].
	
	"if we are in a repeater for multiple elements and we delete ourselves, then cursor positions actually disappear"
	
	aBlock value.
	
	SBToggledCode comment: '' active: 0 do: {
		[ | count |container sandblockEditor selection recursiveSubmorphCount < count ifTrue: [index := index - 1]].
		[(self slot repeaterThat: #multiple) ifNotNil: [index := index - 1]]}.
	
	found ifTrue: [
		container cursorPositionsDo: [:c |
			c isSelect ifFalse: [
				index > 1 ifTrue: [index := index - 1] ifFalse: [
					"if we were to be put inside our container and not in the child, don't move"
					nil.
					(SBToggledCode comment: '' active: 1 do: {[true]. [c block ~= container]}) ifTrue: [
						^ container sandblockEditor cursor
							cursorPosition: (c placeAtEnd: true)
							explicitMove: true
							axis: #none]]]]].
	container sandblockEditor selection moveCursorToEnd
]

{ #category : #'as yet unclassified' }
SBTSBlock >> preferInsertCursor [

	^ self type = self language rootRuleName
]

{ #category : #highlight }
SBTSBlock >> preferredColorIn: aColorPolicy [

	^ self slot preferredColorIn: aColorPolicy for: self highlight
]

{ #category : #'as yet unclassified' }
SBTSBlock >> prefersNoBorder [

	^ self isPart
]

{ #category : #testing }
SBTSBlock >> prefixValidFor: aTextMorph in: aSiblingsCollection [

	^ aTextMorph slot firstNode
		prefixValidFor: aTextMorph contents
		in: aSiblingsCollection
]

{ #category : #accessing }
SBTSBlock >> prettySourceString [

	self allBlocksDo: [:b | b valid ifFalse: [^ self sourceString]].
	^ self language runtime
		ifNotNil: [:r | r prettyPrint: self sourceString]
		ifNil: [self sourceString]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> printLabelOn: aStream [

	self printOn: aStream
]

{ #category : #'as yet unclassified' }
SBTSBlock >> printOn: aStream [

	self slot ifNotNil: [slot firstNode labelPrintOn: aStream]
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

	SBTSInputReconcile new
		explicitAppend: true;
		for: (self activeTextMorph ifNil: [self])
		input: ''
		at: (ActiveEvent shiftPressed ifTrue: [1] ifFalse: [SBTSInputReconcile endIndex])
]

{ #category : #query }
SBTSBlock >> query: aString capturesDo: aBlock [

	^ SBTSQuery new execute: aString against: self capturesDo: aBlock
]

{ #category : #query }
SBTSBlock >> queryNode: aString [

	| element |
	(self
		queryRecursiveFirstMatch: aString
		capturesDo: [:captures :block | element := captures ifEmpty: [block] ifNotEmpty: [captures anyOne]]) ifFalse: [^ self error: 'query did not match'].
	^ element
]

{ #category : #query }
SBTSBlock >> queryRecursiveFirstMatch: aString capturesDo: aBlock [

	self allMorphsDo: [:block |
		block isTSMorph ifTrue: [ | captures |
			captures := nil.
			(SBTSQuery new execute: aString against: block capturesDo: [:cap | captures := cap]) ifTrue: [
				aBlock cull: captures cull: block.
				^ true]]].
	^ false
]

{ #category : #accessing }
SBTSBlock >> range [

	^ range
]

{ #category : #accessing }
SBTSBlock >> range: anAssociation [

	range := anAssociation
]

{ #category : #'as yet unclassified' }
SBTSBlock >> reinterpretWithoutEmpty [

	| remaining options editor |
	editor := self sandblockEditor.
	remaining := self childrenToKeepDuringDelete.
	remaining ifEmpty: [
		(self parentSandblock deleteCommandFor: self) ifNotNil: [:c |
			self placeCursorCloseAfterDo: [editor do: c].
			^ true].
		^ false].
	options := SBTSInputParser new optionsFor: self given: '' before: remaining after: #().
	(remaining hasEqualElements: self submorphs) ifTrue: [^ false].
	
	(options size = 1 and: [options first first sourceStringForCompare ~= self copyBlock sourceStringForCompare]) ifTrue: [
		self placeCursorCloseAfterDo: [editor do: (SBReplaceMultipleCommand new target: self replacers: options first)].
		^ true].
	SBToggledCode comment: '' active: 0 do: {
		[
			(remaining allSatisfy: [:m | m slot firstNode isTSLabel]) ifTrue: [
				(self parentSandblock deleteCommandFor: self) ifNotNil: [:c |
					editor do: c.
					editor selection moveCursorToEnd.
					^ true]]]}.
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

{ #category : #accessing }
SBTSBlock >> replaceBlock: aBlock [

	| new |
	new := aBlock adaptSlotFor: self slot ifFailed: [self error: 'block not compatible'].
	self replaceBy: new.
	^ new
]

{ #category : #accessing }
SBTSBlock >> semantics [

	^ (self containingArtefact ifNotNil: [:a | a semantics]) ifNil: [self language]
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
SBTSBlock >> smallestBlockEncompassig: aRange [

	| min |
	min := self.
	self allBlocksDo: [:block | (block encompasses: aRange) ifTrue: [min recursiveSubmorphCount > block recursiveSubmorphCount ifTrue: [min := block]]].
	^ min
]

{ #category : #'as yet unclassified' }
SBTSBlock >> sourceStringForCompare [

	^ String streamContents: [:s | self writeSourceOn: s indent: 0 forCompare: true]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> startInputCommandIn: aTextMorph [

	^ aTextMorph ifNotNil: [SBTextCommand new textMorph: aTextMorph] ifNil: [nil]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> statements [

	^ self isBlockBody ifTrue: [self childSandblocks] ifFalse: [#()]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> suggestAlways [

	^ self language suggestAlwaysFor: self
]

{ #category : #'as yet unclassified' }
SBTSBlock >> suggestions [

	^ self language suggestionsFor: self
]

{ #category : #'action helpers' }
SBTSBlock >> swap: aNumber [

	self activeTextMorph ifNotNil: [:text |
		(#('(' ')' '[' ']' '{' '}') includes: text contents) ifTrue: [ | options list |
			list := self submorphs asOrderedCollection.
			list addAllFirst: (self owner submorphs first: self submorphIndex - 1).
			list addAllLast: (self owner submorphs allButFirst: self submorphIndex).
			list remove: text.
			list add: text beforeIndex: self submorphIndex + text submorphIndex + aNumber - 1.
			options := SBTSInputParser new
				copyEmbeds: false;
				optionsForTemplate: self owner slot transitionRoot givenBlocks: list.
			self sandblockEditor do: (SBReplaceMultipleCommand new target: self owner replacers: options first).
			text owner sandblockEditor
				startInput: text owner
				at: 1
				replacingContents: false
				in: text.
			^ self]].
	
	^ super swap: aNumber
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
SBTSBlock >> toplevel [

	^ (self type = self language rootRuleName and: [self owner isTSBlock not])
		ifTrue: [self]
		ifFalse: [self owner toplevel]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> tryApplyChange: aBlock input: aString [

	| previousContents insertIndex textMorph |
	textMorph := self activeTextMorph.
	previousContents := textMorph contents.
	insertIndex := textMorph contents
		ifNotEmpty: [textMorph cursor]
		ifEmpty: [SBTSInputReconcile endIndex].
	aBlock value: textMorph.
	
	(self prefixValidFor: textMorph in: self submorphs)
		ifTrue: [
			((self factory keywords includes: textMorph contents) and: [(self isMyActiveKeyword: textMorph contents) not]) ifTrue: [
				textMorph contents: previousContents.
				SBTSInputReconcile new for: textMorph input: aString at: insertIndex]]
		ifFalse: [
			textMorph contents: previousContents.
			SBTSInputReconcile new for: textMorph input: aString at: insertIndex]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> tryApplyReplacements: aCollection to: aBlock [

	^ aCollection do: [:pragma | | blockClass |
		blockClass := pragma methodClass.
		(blockClass
			match: aBlock
			against: (SBTSQuery new prepare: pragma arguments second)
			buildSelector: pragma selector) ifNotNil: [:cmd |
			^ self sandblockEditor
				ifNotNil: [:e | e do: (cmd shouldMergeWithNext: true)]
				ifNil: [cmd do]]]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> type [

	^ self slot type
]

{ #category : #actions }
SBTSBlock >> typeNewLine [
	"workaround, as we want cmd+cr to put a new line, which will otherwise get blocked in keyStroke: because it contains a cmd"
	<inputAction>

	self sandblockEditor cursor cursorPosition textMorph insertString: String cr
]

{ #category : #highlight }
SBTSBlock >> updateAllHighlights [

	^ self slot updateAllHighlightsFor: self
]

{ #category : #'as yet unclassified' }
SBTSBlock >> updateMyHighlight [

	| current |
	self factory hasHighlight ifFalse: [^ self highlight: #_sb_none].
	
	highlight := nil.
	current := self.
	[highlight isNil and: [current notNil and: [current isTSBlock]]] whileTrue: [
		self slot updateHighlightFor: current.
		current := current parentSandblock].
	self clearCacheSelf
]

{ #category : #'as yet unclassified' }
SBTSBlock >> useSuggestion: anItem [

	| editor |
	editor := self sandblockEditor.
	self activeTextMorph contents: ''.
	self tryApplyChange: [:t | t contents: anItem contents] input: anItem contents.
	" we may autocomplete multiple unknowns, where we all always select the last one. typically, in the autocompletion we actually want the first one though "
	editor selection parentSandblock
		allBlocksDetect: [:b | b isUnknown]
		ifFound: [:b | b startInput]
		ifNone: []
]

{ #category : #'as yet unclassified' }
SBTSBlock >> valid [

	self flag: #todo.
	" cache valid "
	^ self textMorphs allSatisfy: [:t | t ifNotNil: [t slot firstNode validFor: t contents in: self submorphs] ifNil: [true]]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> wantsExtraSpace [

	^ SBToggledCode comment: '' active: 1 do: {[false]. [self slot needsParenthesis: self]}
]

{ #category : #'as yet unclassified' }
SBTSBlock >> wantsInput [

	(self currentTextMorph notNil and: [self contents isEmpty]) ifTrue: [^ true].
	
	(self isBlockBody and: [self hasChildSandblocks not]) ifTrue: [^ true].
	
	^ false
]

{ #category : #events }
SBTSBlock >> wasDeselected [

	super wasDeselected.
	SBTSListener allSubclassesDo: [:listener | (listener matches: self) ifTrue: [listener wasDeselected: self]].
	self updateMyHighlight
]

{ #category : #events }
SBTSBlock >> wasSelected [

	super wasSelected.
	SBTSListener allSubclassesDo: [:listener | (listener matches: self) ifTrue: [listener wasSelected: self]]
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

	| parens |
	self children ifEmpty: [^ self].
	
	aStream hasLineInfo ifTrue: [range key line: aStream currentLine character: aStream currentIndexInLine].
	
	parens := self parentSandblock notNil and: [self parentSandblock isTSBlock and: [self slot needsParenthesis: self]].
	(self language indentMatch: self) ifTrue: [aStream tab].
	parens ifTrue: [aStream nextPut: $(].
	self children overlappingPairsDo: [:first :second |
		first writeSourceOn: aStream indent: (self indentFor: first current: aNumber) forCompare: aBoolean.
		aStream nextPutAll: (self slot separatorBetween: first and: second indent: aNumber lastCharacterOfFirst: (aStream position > 0 ifFalse: [$ ] ifTrue: [aStream last]))].
	self lastSubmorph
		writeSourceOn: aStream
		indent: (self indentFor: self lastSubmorph current: aNumber)
		forCompare: aBoolean.
	self slot nodes do: [:node | node bodyTemplate andParentsDo: [:type | type hasStatementTerminator ifTrue: [aStream nextPutAll: self language statementTerminator]]].
	parens ifTrue: [aStream nextPut: $)].
	
	aStream hasLineInfo ifTrue: [range value line: aStream currentLine character: aStream currentIndexInLine]
]
