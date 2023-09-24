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
					[node addMorphBack: (self fromCursor: aCursor language: aLanguage)] doWhileFalse: [aCursor gotoNextSibling].
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

	self
		tryApplyChange: [:m |
			(m cursor = 1 and: [m contents notEmpty])
				ifTrue: [
					(m previousMorphThat: [:t | t isTextMorph]) ifNotNil: [:before |
						(self language spaceBetween: before and: m lastCharacterOfFirst: before contents last)
							ifTrue: [
								before contents: before contents, m contents.
								m contents: '']
							ifFalse: [before contents ifNotEmpty: [before contents: before contents allButLast]]]]
				ifFalse: [m deleteBeforeCursor]]
		input: Character backspace asString
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
		(textMorph contents notEmpty and: [complete = '''']) ifTrue: [^ textMorph insertString: input].
		
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

	self
		tryApplyChange: [:textMorph | self handleInsertEvent: anEvent in: textMorph]
		input: anEvent keyCharacter asString
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
DCBlock >> startInputCommandIn: aTextMorph [

	^ aTextMorph ifNotNil: [SBTextCommand new textMorph: aTextMorph] ifNil: [nil]
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
DCBlock >> tryApplyChange: aClosure input: aString [

	| oldContents newTree oldTree oldCursorOffset newCursorOffset |
	oldContents := self activeTextMorph contents.
	oldCursorOffset := self activeTextMorph cursor.
	oldTree := self containingFloat.
	
	aClosure value: self activeTextMorph.
	
	(aString allSatisfy: #isSeparator) ifTrue: ["if we get a separator, wait reparsing, since separators are not shown in the tree"
	"TODO: replace with match against extras"
	^ self].
	self activeTextMorph ifNil: ["FIXME cursor was moved out"
	^ self].
	
	newTree := DCBlock parse: oldTree getSourceStringAndMark language: self language.
	newCursorOffset := self activeTextMorph cursor.
	
	SBToggledCode comment: '' active: 1 do: {
		[ | cursorPosition |
			self activeTextMorph contents: oldContents.
			self activeTextMorph cursor: oldCursorOffset.
			
			cursorPosition := self activeTextMorph range start + (newCursorOffset - 1).
			self sandblockEditor do: (SBReplaceCommand new
				target: self containingFloat replacer: (newTree
					position: self containingFloat position;
					width: self containingFloat width);
				shouldMergeWithNext: true).
			
			(newTree textMorphForPosition: cursorPosition)
				ifNotNil: [:newTextMorph |
					newTree sandblockEditor
						startInput: newTextMorph containingSandblock
						at: cursorPosition - newTextMorph range start + 1
						replacingContents: false
						in: newTextMorph]
				ifNil: [newTree inputClosestTextMorphTo: cursorPosition]].
		[
			self activeTextMorph contents: oldContents.
			self diff: oldTree to: newTree].
		[
			(SBTSInputParser new optionsForTemplate: self template given: self contents) ifEmpty: [
				self activeTextMorph contents: previousContents.
				SBTSInputParser new
					optionsForTemplate: self parentSandblock template
					given: self contents
					before: {self}
					after: {}]]}
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
	aStream hasLineInfo ifTrue: [range start line: aStream currentLine character: aStream currentIndexInLine].
	parens := self parentSandblock notNil and: [self parentSandblock isTSBlock and: [self slot needsParenthesis: self]].
	(self language indentMatch: self) ifTrue: [self slot indent: 1 on: aStream].
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
	aStream hasLineInfo ifTrue: [range end line: aStream currentLine character: aStream currentIndexInLine]
]
