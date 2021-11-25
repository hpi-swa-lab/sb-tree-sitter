Class {
	#name : #SBInlineBlock,
	#superclass : #SBBlock,
	#instVars : [
		'name',
		'built',
		'highlight',
		'factory',
		'alias',
		'field'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBInlineBlock >> access [

	^ SBTSFieldAccessor new element: self
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> actionProviders [

	^ {self grammarHandler}, super actionProviders
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> advanceParseFrom: aCursor index: aNumber [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBInlineBlock >> alias [

	^ self basicAlias ifNil: [
		(self owner notNil and: [self owner isInlineBlock])
			ifTrue: [self owner inline ifTrue: [self owner alias] ifFalse: [nil]]
			ifFalse: [nil]]
]

{ #category : #accessing }
SBInlineBlock >> alias: aString [

	alias := aString
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> allElementsDo: aBlock [

	^ self subclassResponsibility
]

{ #category : #actions }
SBInlineBlock >> applyReplacements [
	<action>

	| replacements commands |
	replacements := SBInlineBlockReplace allSubclasses gather: [:class | (Pragma allNamed: #lang:match: in: class class), (Pragma allNamed: #lang:match:sample: in: class class) select: [:pragma | pragma arguments first = self factory name]].
	commands := Array streamContents: [:stream |
		self allBlocksDo: [:block |
			replacements do: [:pragma |
				SBTSQuery new execute: pragma arguments second against: block capturesDo: [:captures :success |
					success ifTrue: [
						(pragma methodClass theNonMetaClass
							perform: pragma selector
							withArguments: {
								captures.
								[:target :replacer |
									SBReplaceCommand new
										target: target
										replacer: (replacer type: target type factory: target factory)]}) ifNotNil: [:cmd |
							self assert: (cmd isKindOf: SBCommand).
							stream nextPut: cmd]]]]]].
	commands ifNotEmpty: [
		self sandblockEditor
			ifNotNil: [:e | e do: (SBCombinedCommand newWith: commands)]
			ifNil: [commands do: #do]]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> artefactChanged: aMethodBlock [

	aMethodBlock = self ifTrue: [self updateAllHighlights]
]

{ #category : #accessing }
SBInlineBlock >> basicAlias [

	^ alias
]

{ #category : #accessing }
SBInlineBlock >> basicField [

	^ field
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> buildCopy [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> buildDefault [

	^ self buildDefaultIn: nil
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> buildDefaultIn: anExplore [

	built := true
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> buildEmpty [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> buildWithFields: aStream alternatives: aDictionary [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> candidatesForWrappingOn: aStream [

	(self hasSubmorphs and: [self firstSubmorph isInlineBlock]) ifTrue: [self firstSubmorph candidatesForWrappingOn: aStream]
]

{ #category : #actions }
SBInlineBlock >> changeToUnknown [
	<action>

	self lastInlineChoiceOwner ifNotNil: [:owner | | new |
		new := owner buildCopy
			removeAllMorphs;
			buildDefault.
		self sandblockEditor do: (SBReplaceCommand new
			target: owner;
			replacer: new).
		new startInputAtEnd]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> childSymbolsDo: aBlock [

	self submorphsDo: [:morph |
		morph isInlineBlock ifTrue: [
			(morph isKindOf: SBInlineBlockSymbol)
				ifTrue: [aBlock value: morph]
				ifFalse: [morph childSymbolsDo: aBlock]]]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> childrenForQuery [

	^ Array streamContents: [:s | self submorphsDo: [:m | m isInlineBlock ifTrue: [m childrenForQueryDo: [:child | s nextPut: child]]]]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> childrenForQueryDo: aBlock [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> childrenIn: anExplore [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> choicesForInput: aString before: aBoolean [

	| recursionDepth |
	" to find a transition, we first go up all nested alternatives until we reach our top-level symbol
 if no matches were found, we do the same but allow one level of recursion

why: many grammars encode a deep subtype tree in the owner hierarchy, so we should always
first query the entire hierarchy as each element should have equal importance, before allowing
recursion, which tends to produce more complex, combined blocks"
	recursionDepth := 0.
	2 timesRepeat: [
		(Array streamContents: [:stream | | current |
			current := self currentTextMorph ifNil: [self] ifNotNil: [:t | t owner].
			[current notNil and: [current isInlineBlock]] whileTrue: [
				(current isKindOf: SBInlineBlockChoice) ifTrue: [
					(SBTSRuleExplore new
						maxRecursionDepth: recursionDepth;
						explore: current
							withNested: current firstBlock
							nestedBefore: aBoolean
							for: aString
							startSymbol: nil) ifNotEmpty: [:choices |
						choices do: [:block | block first setProperty: #rootBlock toValue: current].
						stream nextPutAll: choices]].
				current := current owner.
				(current notNil and: [current isInlineBlock and: [current inline not and: [current ~= self and: [current owner isInlineBlock]]]]) ifTrue: [current := nil]]]) ifNotEmpty: [:results | ^ SBTSRuleExplore deduplicateResults: results]].
	^ #()
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> clearCache [

	self allMorphsDo: [:morph | morph layoutChanged].
	self allMorphsDo: [:morph | (morph isSandblock or: [morph isInlineBlock]) ifTrue: [morph clearCacheSelf]]
]

{ #category : #actions }
SBInlineBlock >> clearInput [
	<action>

	self changeToUnknown
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> click: anEvent [

	self inline ifFalse: [super click: anEvent]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> containingSandblock [

	^ self inline ifTrue: [self owner ifNotNil: #containingSandblock] ifFalse: [self]
]

{ #category : #hierarchy }
SBInlineBlock >> containingSymbol [

	^ self owner isInlineBlock ifTrue: [self owner containingSymbol] ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> containsEqual: aBlock [

	self allMorphsDo: [:morph | (morph isInlineBlock and: [morph hasSameContentsAs: aBlock]) ifTrue: [^ true]].
	^ false
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> convertedFor: anInterfaceCollection do: aBlock [

	anInterfaceCollection first = #isInlineBlock ifTrue: [
		SBToggledCode comment: '' active: 0 do: {[self halt]}.
		^ (SBTSRuleExplore new
			explore: anInterfaceCollection last
				withNested: self
				nestedBefore: false
				for: ''
				startSymbol: nil;
			deduplicate)
			ifNotEmpty: [:choices | aBlock value: choices first]
			ifEmpty: [nil]].
	
	^ super convertedFor: anInterfaceCollection do: aBlock
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> currentTextMorph [

	self submorphsDo: [:m | (m isInlineBlock and: [m inline]) ifTrue: [m currentTextMorph ifNotNil: [:t | ^ t]]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> cursorPositionsDo: aBlock [

	self inline not ifTrue: [aBlock value: (SBCursorSelect new block: self)].
	self submorphsDo: [:m | m cursorPositionsDo: aBlock]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> deleteCommandFor: aBlock [

	^ (aBlock owner deleteTargetFor: aBlock)
		ifNotNil: [:target | SBDeleteCommand new target: target]
		ifNil: [
			aBlock newNullBlock ifNotNil: [:nullBlock |
				SBReplaceCommand new
					target: aBlock;
					replacer: nullBlock]]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> deleteTargetFor: aBlock [

	^ nil
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> differenceTo: aMorph labelsDo: aBlock [

	| ret |
	ret := nil.
	self labelDifferenceOf: aMorph do: [:a :b |
		ret ifNil: [
			ret := aBlock
				value: (String streamContents: [:stream |
					(a ownerChain select: [:morph | morph isKindOf: SBInlineBlockSymbol]) reversed
						do: [:morph | stream nextPutAll: morph type]
						separatedBy: [stream nextPutAll: ' >> ']])
				value: (String streamContents: [:stream |
					(b ownerChain select: [:morph | morph isKindOf: SBInlineBlockSymbol]) reversed
						do: [:morph | stream nextPutAll: morph type]
						separatedBy: [stream nextPutAll: ' >> ']])]].
	^ ret
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> drawOn: aCanvas [

	self inline ifFalse: [super drawOn: aCanvas]
]

{ #category : #geometry }
SBInlineBlock >> extent: aPoint [

	SBToggledCode
		comment: ''
		active: 1
		do: {[super extent: aPoint]. [super extent: (aPoint max: 0 @ self minimumHeight)]}
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> factory [

	^ factory
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> factory: aFactory [

	factory := aFactory
]

{ #category : #accessing }
SBInlineBlock >> field [

	^ self basicField ifNil: [self owner inline ifTrue: [self owner field]]
]

{ #category : #accessing }
SBInlineBlock >> field: aString [

	field := aString
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> fields [

	^ self childrenForQuery select: [:child | child field notNil] thenCollect: #field
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> firstDifferingBlocksWith: aMorph do: aBlock [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> firstDifferingBlocksWith: aMorph do: aBlock ifNone: anotherBlock [

	(self hasSameStructureAs: aMorph) ifFalse: [^ aBlock value: self value: aMorph].
	self submorphCount = aMorph submorphCount ifTrue: [
		self submorphs with: aMorph submorphs do: [:a :b |
			(a isKindOf: SBInlineBlock) ifTrue: [
				a firstDifferingBlocksWith: b do: aBlock ifNone: anotherBlock]]].
	^ anotherBlock value
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> firstDifferingUpBlocksWith: aMorph do: aBlock ifNone: anotherBlock [

	(self hasSameStructureAs: aMorph) ifFalse: [^ aBlock value: self value: aMorph].
	(self owner notNil and: [self owner isInlineBlock]) ifTrue: [^ self owner firstDifferingUpBlocksWith: aMorph owner do: aBlock ifNone: anotherBlock].
	^ anotherBlock value
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> fixedNumberOfChildren [

	^ self repeaterChild isNil
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> grammarHandler [

	^ SBMetaGrammarHandler new
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> handlesMouseDown: anEvent [

	^ self inline not
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> handlesMouseOver: anEvent [

	^ self inline not
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> hasSameContentsAs: aBlock [

	^ aBlock class = self class
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> hasSameStructureAs: aBlock [

	^ aBlock isKindOf: self class
]

{ #category : #accessing }
SBInlineBlock >> highlight [

	^ highlight
]

{ #category : #accessing }
SBInlineBlock >> highlight: aString [

	highlight := aString
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> includesNestedSameStructure: aBlock [

	(self hasSameStructureAs: aBlock) ifTrue: [^ true].
	(self childrenIn: nil) do: [:morph | (morph includesNestedSameStructure: aBlock) ifTrue: [^ true]].
	^ false
]

{ #category : #'initialize-release' }
SBInlineBlock >> initialize [

	super initialize.
	
	built := false.
	
	self
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		layoutPolicy: SBAlgebraLayout new;
		listDirection: #leftToRight;
		color: Color transparent;
		cellGap: 2;
		layoutInset: 0;
		cellPositioning: #center;
		extent: 0 @ 0
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> inline [

	^ false
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> inlineIfPossible [

	^ self owner notNil and: [self owner isInlineBlock and: [self owner nonInlinedChildren not]]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> inlineRoot [

	^ (self owner isInlineBlock and: [self owner inline not])
		ifTrue: [self]
		ifFalse: [self owner inlineRoot]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> insertCommandRequest: aMorph near: aBlock before: aBoolean [

	^ self owner inline
		ifTrue: [self owner insertCommandRequest: aMorph near: aBlock before: aBoolean]
		ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> instantiate [

	| instance |
	instance := self buildEmpty buildDefault.
	^ instance
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> isArtefact [

	^ false
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> isBlockBody [

	^ self isStatementContainer
]

{ #category : #testing }
SBInlineBlock >> isBuilt [

	^ built
]

{ #category : #accessing }
SBInlineBlock >> isBuilt: aBoolean [

	built := aBoolean
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> isInlineBlock [

	^ true
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> isSandblock [

	^ self inline not
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> isStatement [

	^ self parentSandblock isInlineBlock and: [self parentSandblock isStatementContainer]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> isStatementContainer [

	^ false
]

{ #category : #testing }
SBInlineBlock >> isTemplate [

	^ true
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> keyStroke: anEvent [

	super keyStroke: anEvent.
	
	(self currentTextMorph notNil and: [self currentTextMorph owner valid not]) ifTrue: [
		self deleteBeforeCursor.
		
		self
			tryInterpretInput: (anEvent keyCharacter = Character space
				ifTrue: [(UIManager default request: 'type operator') ifEmpty: [^ self]]
				ifFalse: [anEvent keyCharacter asString])
			before: (anEvent keyCharacter = Character space and: [anEvent shiftPressed]) not]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> labelDifferenceOf: aMorph do: aBlock [

	self submorphs size = aMorph submorphs size ifFalse: [^ false].
	
	self submorphs
		with: aMorph submorphs
		do: [:a :b | (a labelDifferenceOf: b do: aBlock) ifFalse: [^ false]].
	^ true
]

{ #category : #accessing }
SBInlineBlock >> language [

	^ self factory name
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> lastInlineChoiceOwner [

	| last matchesCount hasOtherBlockSiblings |
	last := nil.
	matchesCount := 0.
	self allBlocksDo: [:block | matchesCount := matchesCount + 1].
	
	hasOtherBlockSiblings := [:block | | myCount |
		myCount := 0.
		block allBlocksDo: [:b | myCount := myCount + 1].
		myCount ~= matchesCount].
	
	^ self allOwnersDo: [:choice |
		(choice isKindOf: SBInlineBlockChoice) ifTrue: [last := choice].
		(choice owner isInlineBlock not or: [hasOtherBlockSiblings value: choice]) ifTrue: [^ last]]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> layoutCommands [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> layoutInset [

	^ self inline ifTrue: [0] ifFalse: [super layoutInset]
]

{ #category : #accessing }
SBInlineBlock >> leftMostChain [

	^ (self hasSubmorphs not or: [self firstSubmorph isInlineBlock not])
		ifTrue: [{self}]
		ifFalse: [{self}, self firstSubmorph leftMostChain]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> leftMostRule [

	(self hasSubmorphs and: [self firstSubmorph isInlineBlock]) ifTrue: [^ self firstSubmorph leftMostRule]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> lengthOfLeftMostPath [

	^ self submorphCount > 0
		ifTrue: [1 + self firstSubmorph lengthOfLeftMostPath]
		ifFalse: [1]
]

{ #category : #accessing }
SBInlineBlock >> matchesQuery: aString [

	^ SBTSQuery new execute: aString against: self capturesDo: [:b | ]
]

{ #category : #geometry }
SBInlineBlock >> minimumHeight [

	^ TextStyle defaultFont height
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> name: aString [

	name := aString
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> newEmptyChildNear: aBlock before: aBoolean [

	self flag: #todo.
	" if we have multiple repeating elements, get the one near aBlock "
	^ self repeaterChild ifNotNil: [:c | c element instantiate]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> nonInlinedChildren [

	^ false
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> numAlternativesIn: anExplore [

	^ 1
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> objectInterfaceNear: aBlock at: aSymbol [
	" we are abusing the protocol here: our overwritten convertedFor:do: recognizes
 this and does special handling. other handlers will get blocked by the false"

	^ {#isInlineBlock. [:o | false]. aSymbol = #replace ifTrue: [self] ifFalse: [self repeaterChild element]}
]

{ #category : #hierarchy }
SBInlineBlock >> orOwnerUpTo: aBlock satisfying: aCondBlock [

	| p |
	p := self.
	[p notNil and: [p ~= aBlock]] whileTrue: [
		(aCondBlock value: p) ifTrue: [^ p].
		p := p owner].
	^ nil
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> preferredColorIn: aColorPolicy [

	^ highlight
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
			['operator'] -> [aColorPolicy identifier].
			['property'] -> [aColorPolicy identifier]}
		otherwise: [aColorPolicy default]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> prefersNoBorder [

	^ self inline
]

{ #category : #printing }
SBInlineBlock >> printElementsSeparated: aCollection on: aStream [

	| first delimiter |
	first := true.
	
	delimiter := (self containingSymbol ifNotNil: #type)
		ifNotNil: [:parentType |
			self factory delimitedRules
				at: parentType
				ifPresent: [:delim | delim first]
				ifAbsent: ['']]
		ifNil: [''].
	
	aCollection do: [:element | | string |
		string := String streamContents: [:stream | element writeSourceOn: stream].
		(self isKindOf: SBInlineBlockRepeat)
			ifTrue: [
				first ifFalse: [aStream nextPutAll: delimiter].
				((self factory hardLineBreakMatcher value: self) or: [self containingSandblock isStatementContainer]) ifTrue: [aStream cr]]
			ifFalse: [(factory wordRule notNil and: [(string notEmpty and: [factory wordRule matches: string first asString]) and: [aStream size > 0 and: [factory wordRule matches: aStream last asString]]]) ifTrue: [delimiter ifEmpty: [aStream space] ifNotEmpty: [aStream nextPutAll: delimiter]]].
		aStream nextPutAll: string.
		first := false]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> printOn: aStream [

	SBToggledCode comment: '' active: 0 do: {[aStream nextPutAll: self className]}.
	aStream nextPut: $(.
	self printTitleOn: aStream.
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> printSExpr [

	^ String streamContents: [:s | self printSExprOn: s depth: 0]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> printSExprOn: aStream depth: aNumber [

	self childSymbolsDo: [:m |
		m printSExprOn: aStream depth: aNumber.
		aStream crtab: aNumber]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> printTitleOn: aStream [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBInlineBlock >> query: aString capturesDo: aBlock [

	^ SBTSQuery new execute: aString against: self capturesDo: aBlock
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> removedMorph: aMorph [

	super removedMorph: aMorph.
	self extent: 0 @ 0
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> repeaterChild [

	self submorphsDo: [:m | (m isSandblock not and: [m isInlineBlock]) ifTrue: [m repeaterChild ifNotNil: [:c | ^ c]]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	Clipboard clipboardText: self sourceString.
	^ true
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> statements [

	^ self isStatementContainer ifTrue: [self childSandblocks] ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> takeParseFrom: aCursor [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> takeParsedFrom: aCursor [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> takeStreamFrom: aMorph [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> title [

	^ String streamContents: [:stream | self printTitleOn: stream]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> tryInterpretInput: aString before: aBoolean [

	| selected |
	selected := SBTSBlockChooseDialog new
		do: [:query | self choicesForInput: query before: aBoolean]
		query: aString.
	selected ifNil: [^ self].
	
	self sandblockEditor do: (SBReplaceCommand new
		target: (selected valueOfProperty: #rootBlock);
		replacer: selected).
	selected removeProperty: #rootBlock.
	SBToggledCode comment: '' active: 1 do: {
		[
			selected firstBlock
				select;
				inputContainedUnknown].
		[selected inputContainedUnknown]}
]

{ #category : #accessing }
SBInlineBlock >> type [

	^ nil
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> unbuiltChildrenIn: anExplore [

	^ built ifTrue: [#()] ifFalse: [self childrenIn: anExplore]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> unwrapSuperType [

	^ self
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> updateAllHighlights [

	factory hasHighlight ifFalse: [^ self].
	
	self allMorphsDo: [:m |
		m isInlineBlock ifTrue: [
			m highlight: nil.
			m updateHighlight]]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> updateHighlight [

	self factory highlightQuery
		executeAgainst: self
		capturesDo: [:captures | captures keysAndValuesDo: [:id :block | block highlight ifNil: [block highlight: id]]]
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> veryDeepCopyWith: deepCopier [

	| f copy |
	f := factory.
	factory := nil.
	copy := super veryDeepCopyWith: deepCopier.
	factory := f.
	copy factory: f.
	^ copy
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> wantsExtraSpace [

	^ self inline not
]

{ #category : #'as yet unclassified' }
SBInlineBlock >> writeSourceOn: aStream [

	self subclassResponsibility
]
