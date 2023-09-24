Class {
	#name : #DCBlock,
	#superclass : #SBBlock,
	#instVars : [
		'type',
		'language',
		'range',
		'highlight',
		'field'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCBlock class >> fromCursor: aCursor language: aLanguage [

	^ aCursor isNamed
		ifTrue: [ | node |
			node := DCBlock new
				type: aCursor type;
				field: aCursor fieldName;
				language: aLanguage;
				range: aCursor range.
			
			aCursor gotoFirstChild
				ifTrue: [
					[
						aCursor numberOfNewLinesToNext - 1 timesRepeat: [node addMorphBack: (DCUnknown new language: aLanguage)].
						node addMorphBack: (self fromCursor: aCursor language: aLanguage)] doWhileFalse: [aCursor gotoNextSibling].
					aCursor gotoParent]
				ifFalse: [
					aCursor text ifNotEmpty: [:text |
						node addMorphBack: (DCText new
							contents: text;
							field: aCursor fieldName;
							range: aCursor range)]].
			
			node]
		ifFalse: [
			DCText new
				contents: aCursor text;
				field: aCursor fieldName;
				range: aCursor range]
]

{ #category : #'as yet unclassified' }
DCBlock class >> parse: aString language: aLanguage [

	| api |
	api := SBTreeSitter new.
	^ (api parseAsCursor: aString language: aLanguage language do: [:cursor |
		self
			fromCursor: (SBTSCursorRaw new library: api cursor: cursor factory: aLanguage instance grammar)
			language: aLanguage])
		layoutInset: 4;
		hResizing: #rigid;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured;
		yourself
]

{ #category : #'as yet unclassified' }
DCBlock >> alias [

	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> allTextMorphsDo: aBlock [

	self allMorphsDo: [:m | m isTextMorph ifTrue: [aBlock value: m]]
]

{ #category : #'as yet unclassified' }
DCBlock >> blockFor: aRange [

	self allMorphsDo: [:block | (block isTSMorph and: [block range = aRange]) ifTrue: [^ block]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> compatibleWithType: aSymbol [

	^ self type = aSymbol
]

{ #category : #'as yet unclassified' }
DCBlock >> contentsToDisplay [

	^ self contents
]

{ #category : #'as yet unclassified' }
DCBlock >> currentTextMorph [

	self submorphsDo: [:m | m isTextMorph ifTrue: [^ m]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> deleteBeforeCursor [
	<action>

	self tryApplyChange: [:source :textMorph :cursorIndex :apply | apply value: (self deleteFrom: source at: cursorIndex) value: cursorIndex - 1].
	SBToggledCode comment: '' active: 0 do: {
		[
			self tryApplyChange: [:m |
				(m cursor = 1 and: [m contents notEmpty])
					ifTrue: [
						(m previousMorphThat: [:t | t isTextMorph]) ifNotNil: [:before |
							(self language spaceBetween: before and: m lastCharacterOfFirst: before contents last)
								ifTrue: [
									before contents: before contents, m contents.
									m contents: '']
								ifFalse: [before contents ifNotEmpty: [before contents: before contents allButLast]]]]
					ifFalse: [m contents ifEmpty: [self deleteBlock] ifNotEmpty: [m deleteBeforeCursor]]]]}
]

{ #category : #'as yet unclassified' }
DCBlock >> deleteFrom: aString at: aNumber [

	^ (aString first: aNumber - 1), (aString allButFirst: aNumber)
]

{ #category : #'as yet unclassified' }
DCBlock >> diff: oldTree to: newTree [

	
]

{ #category : #'as yet unclassified' }
DCBlock >> drawnColor [

	^ self prefersNoBorder
		ifTrue: [super drawnColor alpha: 0]
		ifFalse: [super drawnColor]
]

{ #category : #'as yet unclassified' }
DCBlock >> encompasses: aRange [

	^ self range encompasses: aRange
]

{ #category : #'as yet unclassified' }
DCBlock >> field [

	^ field
]

{ #category : #'as yet unclassified' }
DCBlock >> field: aString [

	field := aString
]

{ #category : #'as yet unclassified' }
DCBlock >> firstSourceCharacter [

	self writeSourceOn: (SBImmediateStream with: [:c | ^ c]) indent: 0 forCompare: false.
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> fixedNumberOfChildren [

	^ false
]

{ #category : #'as yet unclassified' }
DCBlock >> getSourceStringAndMark [

	| stream |
	stream := SBLineInfoStream on: ''.
	self writeSourceOn: stream indent: 0 forCompare: false.
	^ stream contents
]

{ #category : #'as yet unclassified' }
DCBlock >> handleInsertEvent: anEvent in: textMorph [

	| pairMap input |
	pairMap := self pairMap.
	input := anEvent keyCharacter asString.
	pairMap at: input ifPresent: [:complete |
		"do not autocomplete quotes in words"
		((textMorph characterBeforeCursor
			ifNotNil: #isAlphaNumeric
			ifNil: [false]) and: [complete = '''']) ifTrue: [^ textMorph insertString: input].
		
		"do not autocomplete after backslash"
		textMorph characterBeforeCursor = $\ ifTrue: [^ textMorph insertString: input].
		
		^ textMorph
			insertString: input, complete;
			moveCursor: -1].
	
	SBToggledCode comment: '' active: 0 do: {
		[
			(pairMap keyAtValue: input ifAbsent: [nil]) ifNotNil: [:key |
				"jump to a matching closing bracket just after us"
				(textMorph nextMorphThat: #isTextMorph) ifNotNil: [:m |
					m contents = input ifTrue: [
						^ self sandblockEditor
							startInput: m containingSandblock
							at: 900000000
							replacingContents: false
							in: m]].
				
				"skip inserting closing parens that already exist"
				(textMorph contents notEmpty and: [textMorph contents includesSubstring: input]) ifTrue: [^ self]]]}.
	
	^ super keyStroke: anEvent
]

{ #category : #'as yet unclassified' }
DCBlock >> highlight [

	^ highlight ifNil: [self updateAllHighlights]
]

{ #category : #'as yet unclassified' }
DCBlock >> highlight: aString [

	highlight := aString
]

{ #category : #'as yet unclassified' }
DCBlock >> indentFor: aBlock current: aNumber [

	^ (self language indentMatch: aBlock)
		ifTrue: [aNumber + 1]
		ifFalse: [aNumber]
]

{ #category : #'as yet unclassified' }
DCBlock >> initialize [

	super initialize.
	
	range := SBTSRange null.
	
	self
		layoutPolicy: SBAlgebraLayout new;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap
]

{ #category : #'as yet unclassified' }
DCBlock >> inputClosestTextMorphTo: cursorPosition [

	| best bestDistance atStart |
	best := nil.
	bestDistance := Float infinity.
	atStart := false.
	
	"match on same line"
	self allMorphsDo: [:t |
		t isTextMorph ifTrue: [
			t range start line = cursorPosition line ifTrue: [ | distance |
				distance := (t range start character - cursorPosition character) abs.
				distance < bestDistance ifTrue: [
					bestDistance := distance.
					atStart := true.
					best := t]].
			t range end line = cursorPosition line ifTrue: [ | distance |
				distance := (t range end character - cursorPosition character) abs.
				distance < bestDistance ifTrue: [
					bestDistance := distance.
					atStart := false.
					best := t]]]].
	
	"match on different line"
	best ifNil: [
		self allMorphsDo: [:t |
			t isTextMorph ifTrue: [ | distance |
				distance := (t range start line - cursorPosition line) abs min: (t range end line - cursorPosition line) abs.
				distance < bestDistance ifTrue: [
					bestDistance := distance.
					atStart := false.
					best := t]]]].
	
	best ifNotNil: [
		self sandblockEditor
			startInput: best containingSandblock
			at: (atStart ifTrue: [1] ifFalse: [900000000])
			replacingContents: false
			in: best]
]

{ #category : #'as yet unclassified' }
DCBlock >> insert: aString in: aContainerString at: aNumber [

	^ (aNumber > aContainerString size or: [aContainerString isEmpty])
		ifTrue: [aContainerString, aString]
		ifFalse: [(aContainerString first: aNumber - 1), aString, (aContainerString allButFirst: aNumber - 1)]
]

{ #category : #'as yet unclassified' }
DCBlock >> insertStatementAboveOrBelow: anAboveBoolean [

	self isBlockBody ifTrue: [
		^ self sandblockEditor do: (SBRelInsertCommand new
			near: self activeTextMorph
			before: anAboveBoolean
			in: self
			morph: (DCUnknown new language: self language))].
	
	(self orOwnerSuchThat: [:morph | morph isTSBlock and: [morph isStatement]]) ifNotNil: [:adjacent |
		self sandblockEditor do: (SBRelInsertCommand new
			near: adjacent
			before: anAboveBoolean
			in: adjacent owner
			morph: (DCUnknown new language: self language))]
]

{ #category : #'as yet unclassified' }
DCBlock >> insertStatementHasCandidate [

	^ true
]

{ #category : #'as yet unclassified' }
DCBlock >> isBlockBody [

	^ self language blockBodyTypes includes: self type
]

{ #category : #'as yet unclassified' }
DCBlock >> isTSBlock [

	^ true
]

{ #category : #'as yet unclassified' }
DCBlock >> isTSMorph [

	^ true
]

{ #category : #'as yet unclassified' }
DCBlock >> keyStroke: anEvent [

	self tryApplyChange: [:source :textMorph :cursorIndex :apply | | input insert |
		input := anEvent keyCharacter asString.
		insert := [:str | apply value: (self insert: str in: source at: cursorIndex + 1) value: cursorIndex + 1].
		(input first isPrintable and: [anEvent commandKeyPressed not]) ifTrue: [
			self pairMap at: input ifPresent: [:complete |
				"do not autocomplete quotes in words"
				(complete = '''' and: [source at: cursorIndex ifPresent: #isAlphaNumeric ifAbsent: [false]]) ifTrue: [^ insert value: input].
				
				"do not autocomplete after backslash"
				textMorph characterBeforeCursor = $\ ifTrue: [^ insert value: input].
				
				^ insert value: input, complete].
			
			"for separators, don't re-parse immediately, as those get discarded during parse"
			^ input first isSeparator
				ifTrue: [textMorph keyStroke: anEvent]
				ifFalse: [insert value: input]]]
]

{ #category : #'as yet unclassified' }
DCBlock >> language [

	^ language
]

{ #category : #'as yet unclassified' }
DCBlock >> language: aLanguage [

	language := aLanguage
]

{ #category : #'as yet unclassified' }
DCBlock >> layoutCommands [

	self hasSubmorphs ifFalse: [^ SBAlgebraCommand morph data: self].
	^ SBAlgebraCommand container
		morph: self;
		data: (Array streamContents: [:stream |
			self submorphs overlappingPairsDo: [:a :b |
				stream nextPut: a layoutCommands.
				(self language addIndent: a) ifTrue: [stream nextPut: SBAlgebraCommand addIndent].
				(self language removeIndent: b) ifTrue: [stream nextPut: SBAlgebraCommand removeIndent].
				(self language hardLineBreakBetween: a and: b)
					ifTrue: [stream nextPut: (SBAlgebraCommand hardLine withGap: true)]
					ifFalse: [
						(self language softLineBreakBetween: a and: b)
							ifTrue: [
								stream nextPut: (((self language gapBetween: a and: b)
									ifTrue: [SBAlgebraCommand softLineOrGap]
									ifFalse: [SBAlgebraCommand softLine]) withGap: true)]
							ifFalse: [(self language gapBetween: a and: b) ifTrue: [stream nextPut: SBAlgebraCommand gap]]]].
			self submorphs ifNotEmpty: [stream nextPut: self lastSubmorph layoutCommands]])
]

{ #category : #'as yet unclassified' }
DCBlock >> layoutInset [

	^ (self type = 'ERROR' and: [self childSandblocks notEmpty])
		ifTrue: [0]
		ifFalse: [super layoutInset]
]

{ #category : #'as yet unclassified' }
DCBlock >> ownerWithForegroundColor [

	^ self highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithForegroundColor]]
		ifFalse: [self]
]

{ #category : #'as yet unclassified' }
DCBlock >> pairMap [

	^ Dictionary newFrom: {'(' -> ')'. '''' -> ''''. '"' -> '"'. '`' -> '`'. '{' -> '}'. '<' -> '>'. '[' -> ']'}
]

{ #category : #'as yet unclassified' }
DCBlock >> preferredColorIn: aColorPolicy [

	^ self slot preferredColorIn: aColorPolicy for: self highlight
]

{ #category : #'as yet unclassified' }
DCBlock >> printOn: aStream [

	aStream nextPutAll: self type
]

{ #category : #'as yet unclassified' }
DCBlock >> range [

	^ range
]

{ #category : #'as yet unclassified' }
DCBlock >> range: aRange [

	range := aRange
]

{ #category : #'as yet unclassified' }
DCBlock >> slot [

	^ DCMockSlot new for: self
]

{ #category : #'as yet unclassified' }
DCBlock >> smallestBlockEncompassig: aRange [

	| min |
	min := self.
	self allBlocksDo: [:block | (block encompasses: aRange) ifTrue: [min recursiveSubmorphCount > block recursiveSubmorphCount ifTrue: [min := block]]].
	^ min
]

{ #category : #'as yet unclassified' }
DCBlock >> startInputAtSourceIndex: aNumber [

	self allTextMorphsDo: [:m |
		m range end index >= aNumber ifTrue: [
			^ aNumber <= m range end index
				ifTrue: [
					"we're now inside!"
					self sandblockEditor
						startInput: m containingSandblock
						at: aNumber - m range start index + 1
						replacingContents: false
						in: m]
				ifFalse: [
					"we just went past"
					self sandblockEditor
						startInput: m containingSandblock
						at: 1
						replacingContents: false
						in: m]]]
]

{ #category : #'as yet unclassified' }
DCBlock >> startInputCommandIn: aTextMorph [

	^ aTextMorph ifNotNil: [SBTextCommand new textMorph: aTextMorph] ifNil: [nil]
]

{ #category : #'as yet unclassified' }
DCBlock >> statements [

	^ self childSandblocks
]

{ #category : #'as yet unclassified' }
DCBlock >> swap: aNumber [

	self tryApplyChange: [:source :textMorph :cursorIndex :apply | | pivot outerPivot |
		pivot := (self sandblockEditor mode = #input
			ifTrue: [textMorph]
			ifFalse: [self]) orOwnerSuchThat: [:morph | morph owner submorphCount > 1].
		outerPivot := pivot orOwnerSuchThat: [:morph |
			(aNumber > 0
				ifTrue: [morph morphAfterThat: #isSandblock]
				ifFalse: [morph morphBeforeThat: #isSandblock]) notNil].
		outerPivot ifNotNil: [ | target startIndex |
			target := aNumber > 0
				ifTrue: [outerPivot morphAfterThat: #isSandblock]
				ifFalse: [outerPivot morphBeforeThat: #isSandblock].
			startIndex := target range start index + (aNumber > 0 ifTrue: [target range size - pivot range size] ifFalse: [0]).
			apply value: (self swap: pivot range with: target range in: source) value: (SBToggledCode
				comment: ''
				active: 1
				do: {[SBTSRange start: startIndex size: pivot range size]. [startIndex]})]]
]

{ #category : #'as yet unclassified' }
DCBlock >> swap: aRange with: anotherRange in: aString [

	| first second |
	self
		example: [DCBlock new]
		args: [
			{
				SBTSRange
					start: (SBTSPosition line: 0 character: 8 index: 8)
					end: (SBTSPosition line: 0 character: 9 index: 9).
				SBTSRange
					start: (SBTSPosition line: 0 character: 2 index: 2)
					end: (SBTSPosition line: 0 character: 5 index: 5).
				'1234567890'}]
		label: 'example'.
	first := aRange start index < anotherRange start index
		ifTrue: [aRange]
		ifFalse: [anotherRange].
	second := aRange start index < anotherRange start index
		ifTrue: [anotherRange]
		ifFalse: [aRange].
	
	^ (SBExampleWatch
		report: (aString first: first start index)
		for: 540329478
		modifying: [:result | result]), (SBExampleWatch
		report: (aString copyFrom: second start index + 1 to: second end index)
		for: 153401999
		modifying: [:result | result]), (SBExampleWatch
		report: (aString copyFrom: first end index + 1 to: second start index)
		for: 554040495
		modifying: [:result | result]), (SBExampleWatch
		report: (aString copyFrom: first start index + 1 to: first end index)
		for: 568840718
		modifying: [:result | result]), (SBExampleWatch
		report: (aString allButFirst: second end index)
		for: 481875392
		modifying: [:result | result])
]

{ #category : #'as yet unclassified' }
DCBlock >> template [

	^ self language rule: self type
]

{ #category : #'as yet unclassified' }
DCBlock >> textMorphForPosition: aPosition [

	self allMorphsDo: [:t | (t isTextMorph and: [t range contains: aPosition]) ifTrue: [^ t]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> textMorphs [

	^ self submorphs select: [:t | t isTextMorph]
]

{ #category : #'as yet unclassified' }
DCBlock >> tryApplyChange: aClosure [

	| newTree oldTree oldCursorOffset oldSource |
	oldCursorOffset := self activeTextMorph ifNotNil: #cursor.
	oldTree := self containingFloat.
	oldSource := oldTree getSourceStringAndMark.
	
	aClosure
		value: oldSource
		value: self activeTextMorph
		value: (self activeTextMorph ifNotNil: [self activeTextMorph range start index + (oldCursorOffset - 1)])
		value: [:newSource :newIndex |
			newTree := (DCBlock parse: newSource language: self language)
				position: self containingFloat position;
				width: self containingFloat width.
			self sandblockEditor do: (SBReplaceCommand new
				target: oldTree replacer: newTree;
				shouldMergeWithNext: true).
			newIndex isNumber ifTrue: [newTree startInputAtSourceIndex: newIndex] ifFalse: [ | target |
				target := newTree blockFor: newIndex.
				target isTextMorph
					ifTrue: [
						newTree sandblockEditor
							startInput: target containingSandblock
							at: 1
							replacingContents: false
							in: target]
					ifFalse: [newTree sandblockEditor selectNoInput: target]]]
]

{ #category : #'as yet unclassified' }
DCBlock >> type [

	^ type
]

{ #category : #'as yet unclassified' }
DCBlock >> type: aSymbol [

	type := aSymbol
]

{ #category : #'as yet unclassified' }
DCBlock >> updateAllHighlights [

	^ self slot updateAllHighlightsFor: self
]

{ #category : #'as yet unclassified' }
DCBlock >> valid [

	^ self type ~= 'ERROR'
]

{ #category : #'as yet unclassified' }
DCBlock >> writeSourceOn: aStream [

	self writeSourceOn: aStream indent: 0 forCompare: false
]

{ #category : #'as yet unclassified' }
DCBlock >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	| parens |
	self submorphs ifEmpty: [^ self].
	parens := self parentSandblock notNil and: [self parentSandblock isTSBlock and: [self slot needsParenthesis: self]].
	(self language indentMatch: self) ifTrue: [self slot indent: 1 on: aStream].
	aStream hasLineInfo ifTrue: [
		range start
			line: aStream currentLine
			character: aStream currentIndexInLine
			index: aStream position].
	parens ifTrue: [aStream nextPut: $(].
	self submorphs overlappingPairsDo: [:first :second |
		first writeSourceOn: aStream indent: (self indentFor: first current: aNumber) forCompare: aBoolean.
		aStream nextPutAll: (self slot
			separatorBetween: first
			and: second
			indent: aNumber
			lastCharacterOfFirst: (aStream position > 0 ifFalse: [$ ] ifTrue: [aStream last]))].
	self lastSubmorph
		writeSourceOn: aStream
		indent: (self indentFor: self lastSubmorph current: aNumber)
		forCompare: aBoolean.
	SBToggledCode comment: '' active: 0 do: {
		[self slot nodes do: [:node | node bodyTemplate andParentsDo: [:type | type hasStatementTerminator ifTrue: [aStream nextPutAll: self language statementTerminator]]]]}.
	parens ifTrue: [aStream nextPut: $)].
	aStream hasLineInfo ifTrue: [range end line: aStream currentLine character: aStream currentIndexInLine index: aStream position]
]
