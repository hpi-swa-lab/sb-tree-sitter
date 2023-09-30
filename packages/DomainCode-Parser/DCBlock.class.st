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
DCBlock class >> findChangeRangeFrom: original to: new [

	| start end maxSize |
	start := 1.
	[start <= (original size min: new size) and: [(original at: start) = (new at: start)]] whileTrue: [start := start + 1].
	
	end := 1.
	maxSize := original size min: new size.
	[end <= maxSize and: [maxSize - (end - 1) >= start and: [(original atLast: end) = (new atLast: end)]]] whileTrue: [end := end + 1].
	
	^ SBTSInputEdit new
		startByte: start - 1;
		oldEndByte: original size - (end - 1);
		newEndByte: new size - (end - 1);
		bytesToPointsIn: original new: new
]

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

	^ (self parseBlock: aString language: aLanguage)
		layoutInset: 4;
		hResizing: #rigid;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured;
		yourself
]

{ #category : #'as yet unclassified' }
DCBlock class >> parse: aString old: oldBlock edit: anEdit language: aLanguage [

	| api oldTree |
	api := SBTreeSitter new.
	oldTree := (oldBlock valueOfProperty: #tsTree) ifNotNil: [:tsTree |
		tsTree isNull ifTrue: [nil] ifFalse: [
			api
				treeEdit: tsTree
				edit: (self findChangeRangeFrom: (oldBlock valueOfProperty: #tsSource) to: aString).
			tsTree]].
	^ api parseAsCursor: aString language: aLanguage language oldTree: oldTree do: [:cursor :newTree | | block changedRanges |
		changedRanges := oldTree ifNotNil: [api changedRangesFrom: oldTree to: newTree] ifNil: [{}].
		block := (self
			fromCursor: (SBTSCursorRaw new library: api cursor: cursor factory: aLanguage instance grammar)
			language: aLanguage)
			setProperty: #tsTree
				toValue: newTree;
			setProperty: #tsSource
				toValue: aString;
			yourself.
		
		{block. changedRanges. self findChangeRangeFrom: (oldBlock valueOfProperty: #tsSource) to: aString}]
]

{ #category : #'as yet unclassified' }
DCBlock class >> parseBlock: aString language: aLanguage [

	| api |
	api := SBTreeSitter new.
	^ api parseAsCursor: aString language: aLanguage language do: [:cursor :tree |
		(self
			fromCursor: (SBTSCursorRaw new library: api cursor: cursor factory: aLanguage instance grammar)
			language: aLanguage)
			setProperty: #tsTree
				toValue: tree;
			setProperty: #tsSource
				toValue: aString;
			yourself]
]

{ #category : #'as yet unclassified' }
DCBlock >> absolutePositionOf: aMorph [

	| n |
	n := 0.
	self allMorphsDo: [:m |
		n := n + 1.
		m = aMorph ifTrue: [^ n]].
	^ self assert: false
]

{ #category : #'as yet unclassified' }
DCBlock >> alias [

	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> allParents [

	^ self allParentsUpTo: self rootBlock
]

{ #category : #'as yet unclassified' }
DCBlock >> allParentsUpTo: aBlock [

	self = aBlock ifTrue: [^ #()].
	
	^ Array streamContents: [:s |
		self assert: (self ownerSatisfying: [:o |
			s nextPut: o.
			o = aBlock]) notNil]
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
DCBlock >> copyRangesFrom: newTree to: oldTree [

	oldTree range: newTree range.
	newTree submorphs with: oldTree submorphs do: [:a :b | self copyRangesFrom: a to: b]
]

{ #category : #'as yet unclassified' }
DCBlock >> currentTextMorph [

	self submorphsDo: [:m | m isTextMorph ifTrue: [^ m]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> deleteAfterCursor [
	<action>

	self tryApplyChange: [:source :textMorph :cursorIndex :apply |
		self
			deleteFrom: source
			at: cursorIndex + 1
			do: [:new :edit | apply value: new value: edit value: cursorIndex]]
]

{ #category : #'as yet unclassified' }
DCBlock >> deleteBeforeCursor [
	<action>

	self tryApplyChange: [:source :textMorph :cursorIndex :apply |
		self
			deleteFrom: source
			at: cursorIndex
			do: [:new :edit | apply value: new value: edit value: cursorIndex - 1]]
]

{ #category : #'as yet unclassified' }
DCBlock >> deleteFrom: aString at: aNumber do: aBlock [

	| new |
	new := (aString first: aNumber - 1), (aString allButFirst: aNumber).
	^ aBlock value: new value: (SBTSInputEdit new
		startByte: aNumber - 1;
		oldEndByte: aNumber;
		newEndByte: aNumber - 1;
		bytesToPointsIn: aString new: new)
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
DCBlock >> findLastMatchingAncesors: aCollection oldTree: aBlock [

	| oldCurrent |
	oldCurrent := aBlock.
	aCollection allButLast reverseDo: [:newCurrent |
		oldCurrent := oldCurrent submorphs at: newCurrent submorphIndex ifAbsent: [
			self assert: oldCurrent type = newCurrent owner type.
			^ {oldCurrent. newCurrent owner}].
		oldCurrent type = newCurrent type ifFalse: [
			self assert: oldCurrent owner type = newCurrent owner type.
			^ {oldCurrent owner. newCurrent owner}]].
	
	self assert: aCollection first type = oldCurrent type.
	^ {oldCurrent. aCollection first}
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
DCBlock >> insert: aString in: aContainerString at: aNumber do: aBlock [

	| new |
	new := (aNumber > aContainerString size or: [aContainerString isEmpty])
		ifTrue: [aContainerString, aString]
		ifFalse: [(aContainerString first: aNumber - 1), aString, (aContainerString allButFirst: aNumber - 1)].
	aBlock value: new value: (SBTSInputEdit new
		startByte: aNumber - 1;
		oldEndByte: aNumber - 1;
		newEndByte: aNumber - 1 + aString size;
		bytesToPointsIn: aContainerString new: new)
]

{ #category : #'as yet unclassified' }
DCBlock >> insertStatementAboveOrBelow: anAboveBoolean [

	self isBlockBody ifTrue: [
		^ self sandblockEditor do: (SBRelInsertCommand new
			near: self activeTextMorph
			before: anAboveBoolean
			in: self
			morph: (DCUnknown new language: self language))].
	
	(self orOwnerSuchThat: [:morph | morph isTSBlock and: [morph isStatement]]) ifNotNil: [:statement | | target |
		target := ((statement morphBeforeOrAfter: anAboveBoolean) ifNotNil: #treeLabel) = self language statementTerminator
			ifTrue: [statement morphBeforeOrAfter: anAboveBoolean]
			ifFalse: [statement].
		self sandblockEditor do: (SBRelInsertCommand new near: target before: anAboveBoolean in: statement owner morph: (DCUnknown new
			language: self language;
			contents: self language statementTerminator))]
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
DCBlock >> isPart [

	^ self highlight notNil and: [self highlight endsWith: '.part']
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
		insert := [:str |
			self
				insert: str
				in: source
				at: cursorIndex + 1
				do: [:new :edit | apply value: new value: edit value: cursorIndex + 1]].
		(input first isPrintable and: [anEvent commandKeyPressed not]) ifTrue: [
			"do not place closing pair characters if they are coming up right after"
			(self pairMap keyAtValue: input ifAbsent: nil) ifNotNil: [:openChar | (source at: cursorIndex + 1 ifPresent: [:char | input first = char] ifAbsent: [false]) ifTrue: [^ self owner startInputAtSourceIndex: cursorIndex + 1]].
			
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

	^ Dictionary newFrom: {'(' -> ')'. '''' -> ''''. '"' -> '"'. '`' -> '`'. '{' -> '}'. '[' -> ']'}
]

{ #category : #'as yet unclassified' }
DCBlock >> placeCursorIn: newTree at: newIndex [

	^ newIndex isNumber ifTrue: [newTree startInputAtSourceIndex: newIndex] ifFalse: [ | target |
		target := newTree blockFor: newIndex.
		target isTextMorph
			ifTrue: [
				newTree sandblockEditor
					startInput: target containingSandblock
					at: 1
					replacingContents: false
					in: target]
			ifFalse: [newTree sandblockEditor selectNoInput: target]]
]

{ #category : #'as yet unclassified' }
DCBlock >> preferredColorIn: aColorPolicy [

	^ self slot preferredColorIn: aColorPolicy for: self highlight
]

{ #category : #'as yet unclassified' }
DCBlock >> prefersNoBorder [

	^ self isPart
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
DCBlock >> replace: oldTree with: newTree [

	^ SBToggledCode comment: '' active: 1 do: {
		[ | editor |
			editor := self sandblockEditor.
			DCMatcher new doCommandForEditsIn: newTree to: oldTree in: editor.
			editor history noMoreMerge.
			oldTree].
		[
			self sandblockEditor do: (SBReplaceCommand new
				target: oldTree replacer: newTree;
				shouldMergeWithNext: true).
			newTree
				position: oldTree position;
				width: oldTree width;
				yourself]}
]

{ #category : #'as yet unclassified' }
DCBlock >> rootBlock [

	self owner ifNil: [^ self].
	^ self ownerSatisfying: [:o | o isTSBlock and: [o type = self language rootRuleName]]
]

{ #category : #'as yet unclassified' }
DCBlock >> shallowCopyBlock [

	^ DCBlock new
		type: type;
		language: language;
		range: range;
		field: field;
		highlight: highlight
]

{ #category : #'as yet unclassified' }
DCBlock >> slot [

	^ DCMockSlot new for: self
]

{ #category : #'as yet unclassified' }
DCBlock >> smallestBlockEncompassig: aRange [

	| min |
	min := self.
	self allBlocksDo: [:block | (block encompasses: aRange) ifTrue: [min range size > block range size ifTrue: [min := block]]].
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
			self swap: pivot range with: target range in: source do: [:new :edit |
				apply value: new value: edit value: (SBToggledCode
					comment: ''
					active: 1
					do: {[SBTSRange start: startIndex size: pivot range size]. [startIndex]})]]]
]

{ #category : #'as yet unclassified' }
DCBlock >> swap: aRange with: anotherRange in: aString do: aBlock [

	| first second new |
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
	new := (aString first: first start index), (aString copyFrom: second start index + 1 to: second end index), (aString copyFrom: first end index + 1 to: second start index), (aString copyFrom: first start index + 1 to: first end index), (aString allButFirst: second end index).
	
	^ aBlock value: new value: (SBTSInputEdit new
		startByte: first start index;
		oldEndByte: second end index;
		newEndByte: second end index;
		bytesToPointsIn: aString new: new)
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
DCBlock >> treeHash [

	self hasSubmorphs ifFalse: [^ self treeHashChildren: 0].
	^ self treeHashChildren: (self submorphs inject: 0 into: [:hash :morph | hash bitXor: morph treeHash])
]

{ #category : #'as yet unclassified' }
DCBlock >> treeHashChildren: anotherNumber [

	^ ((self type hash bitXor: 'ENTER' hash) bitXor: anotherNumber) bitXor: 'LEAVE' hash
]

{ #category : #'as yet unclassified' }
DCBlock >> treeLabel [

	^ ''
]

{ #category : #'as yet unclassified' }
DCBlock >> tryApplyChange: aClosure [

	| newTree oldTree oldCursorOffset oldSource |
	oldCursorOffset := self activeTextMorph ifNotNil: #cursor.
	oldTree := self rootBlock.
	oldSource := oldTree getSourceStringAndMark.
	
	aClosure
		value: oldSource
		value: self activeTextMorph
		value: (self activeTextMorph ifNotNil: [self activeTextMorph range start index + (oldCursorOffset - 1)])
		value: [:newSource :edit :newIndex |
			newTree := DCBlock parse: newSource old: oldTree edit: edit language: self language.
			
			SBToggledCode comment: '' active: 1 do: {
				[self replace: oldTree with: newTree first].
				[
					newTree second
						ifNotEmpty: [:changedRanges | | change newContained pair |
							change := SBTSRange merging: changedRanges.
							newContained := newTree first smallestBlockEncompassig: change.
							pair := self findLastMatchingAncesors: {newContained}, newContained allParents oldTree: oldTree.
							self replace: pair first with: pair second]
						ifEmpty: [ | pair |
							"empty change means no structures were changed, only contents"
							pair := self
								findLastMatchingAncesors: {
									self sandblockEditor currentInputCommand ifNotNil: #textMorph.
									self sandblockEditor currentInputCommand ifNotNil: #block}, (self sandblockEditor currentInputCommand ifNotNil: #block) allParents
								oldTree: newTree first.
							pair second contents: pair first contents].
					self copyRangesFrom: newTree first to: oldTree]}.
			
			oldTree
				setProperty: #tsTree toValue: (newTree first valueOfProperty: #tsTree);
				setProperty: #tsSource toValue: (newTree first valueOfProperty: #tsSource).
			
			self placeCursorIn: oldTree at: newIndex]
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
