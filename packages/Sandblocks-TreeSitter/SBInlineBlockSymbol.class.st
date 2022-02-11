Class {
	#name : #SBInlineBlockSymbol,
	#superclass : #SBInlineBlock,
	#instVars : [
		'type',
		'hint'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> buildCopy [

	^ self buildEmpty addMorphBack: self firstSubmorph buildCopy
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> buildDefaultIn: anExplore [

	super buildDefaultIn: anExplore.
	self addMorphBack: ((factory shouldBlockInline: self type)
		ifTrue: [factory instantiateTemplate: self type]
		ifFalse: [
			SBTSUnknown new
				template: [factory getTemplate: self type];
				type: self type factory: factory])
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> buildEmpty [

	^ self class new
		type: self type factory: factory;
		field: self basicField;
		alias: self basicAlias;
		hint: self hint
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> buildWithFields: aStream alternatives: aDictionary [

	(self isRootSymbol or: [factory promotedInlineSymbols includes: self type]) ifTrue: [^ true].
	self isSuperType ifTrue: [^ true].
	(aStream atEnd or: [aStream peek second isMorph not]) ifTrue: [^ false].
	
	^ ((aStream peek second isKindOf: SBInlineBlockSymbol) and: [self type = aStream peek second type])
		ifTrue: [ | block |
			self assert: self hasSubmorphs not.
			block := aStream next second.
			self addMorphBack: (block type = self type
				ifTrue: [block firstSubmorph buildCopy]
				ifFalse: [self template buildEmpty addMorphBack: block buildCopy]).
			true]
		ifFalse: [false]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> canLikelyContainType: aString [

	^ self compatibleWithType: aString
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> candidatesForWrappingOn: aStream [

	(factory isSuperType: self type) ifTrue: [aStream nextPut: self].
	super candidatesForWrappingOn: aStream
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> childrenForQueryDo: aBlock [

	(factory isSuperType: self type)
		ifTrue: [self firstSubmorph childrenForQueryDo: aBlock]
		ifFalse: [aBlock value: self]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> childrenIn: anExplore [

	((anExplore expandSymbol: self) not and: [self isSuperType not]) ifTrue: [^ #()].
	^ (anExplore notNil and: [anExplore canVisitSymbol: self type])
		ifTrue: [{self template}]
		ifFalse: [{SBInlineBlockNever new}]
]

{ #category : #hierarchy }
SBInlineBlockSymbol >> containingSymbol [

	^ self
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> contents [

	^ (self factory ifNotNil: [:f | f containsPromotedInlineSymbol: self type] ifNil: [false])
		ifTrue: [String streamContents: [:stream | self childSandblocks do: [:child | child contents ifNotNil: [:content | stream nextPutAll: content]]]]
		ifFalse: [super contents]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> elementsDo: aBlock [

	
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> factory: aFactory [

	factory := aFactory
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> firstDifferingBlocksWith: aMorph do: aBlock [

	self class = aMorph class ifFalse: [^ aBlock value: self value: aMorph].
	self type = aMorph type ifFalse: [^ aBlock value: self value: aMorph].
	^ self firstSubmorph firstDifferingBlocksWith: aMorph firstSubmorph do: aBlock
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> get: aFieldString [

	^ self childSandblocks
		detect: [:block | (block orOwnerUpTo: self satisfying: [:b | b field = aFieldString]) notNil]
		ifNone: [nil]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> hasSameContentsAs: aBlock [

	^ (super hasSameStructureAs: aBlock) and: [self type = aBlock type and: [self firstSubmorph hasSameContentsAs: aBlock firstSubmorph]]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> hasSameStructureAs: aBlock [

	^ ((super hasSameStructureAs: aBlock) and: [self type = aBlock type]) or: [self template hasSameStructureAs: aBlock]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> hint [

	^ hint
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> hint: aString [

	hint := aString
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> includesNestedSameStructure: aBlock [

	(super includesNestedSameStructure: aBlock) ifTrue: [^ true].
	
	self type = 'binary_operator' ifTrue: [self halt].
	((aBlock isKindOf: SBInlineBlockSymbol) and: [self type = aBlock type]) ifTrue: [^ true].
	
	^ (factory getTemplate: self type) includesNestedSameStructure: aBlock
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> inline [

	^ factory isNil or: [(factory shouldBlockInline: self type) and: [self inlineIfPossible]]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> insertCommandRequest: aMorph near: aBlock before: aBoolean [

	| reference |
	reference := aBlock owner.
	[reference repeaterChild isNil and: [reference ~= self]] whileTrue: [reference := reference owner].
	^ reference repeaterChild ifNotNil: [:c | c insertCommandRequest: aMorph near: aBlock before: aBoolean]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> instantiate [

	^ (factory isSuperType: self type)
		ifTrue: [factory instantiateTemplate: self type]
		ifFalse: [self buildEmpty addMorphBack: (factory instantiateTemplate: self type)]
]

{ #category : #testing }
SBInlineBlockSymbol >> isAlias [

	^ self factory aliases anySatisfy: [:a | a name = self type and: [(self factory grammar rules includesKey: self type) not]]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> isArtefact [

	^ (self owner isNil or: [self owner isInlineBlock not and: [(self owner isKindOf: SBTSFile) not]]) and: [self type = self factory rootRuleName]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> isHidden [

	^ self type first = $_ or: [factory isSuperType: self type]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> isRootSymbol [
	" used by ParseExplore: the exploration either receives a symbol block (general case), which
first has to be unwrapped. Or it receives an arbitrary block that was aliased. In either case,
the elements that we have will start only one level deeper. But, for aliased blocks, we cannot
simply unpack the first elements as there may be choices in between.

Simple case: (identifier), stream: (identifier)
Complex case: (property_identifier, aliased as: (identifier)|(reserved)), stream: 'abc'
Complex case: ((identifier), ('as' (identifier)?), stream: (identifier)
Complex case: (x, aliased as: (a | b | c)), stream: a
Complex case: (''', string_fragment, '''), stream: (''', string_fragment, ''')"

	^ self owner isNil or: [ | owners |
		owners := self allOwners.
		(owners allSatisfy: [:owner | (owner isKindOf: SBInlineBlockSymbol) not]) and: [" if we have a sequence, we can still be the root symbol, if we're in an alias (see cases 3 vs. 4).
			Importantly, if we're not directly being aliased, we won't be the root symbol (size<2) "
		owners last alias notNil and: [owners size < 2 and: [owners allSatisfy: [:owner | (owner isKindOf: SBInlineBlockSequence) not]]]]]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> isStatementContainer [

	^ factory isStatementContainer: self type
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> isSuperType [

	^ factory isSuperType: self type
]

{ #category : #testing }
SBInlineBlockSymbol >> isTSSymbol [

	^ true
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> isTemplate [

	^ self hasSubmorphs not
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> labelDifferenceOf: aMorph do: aBlock [

	self type = aMorph type ifFalse: [
		aBlock value: self value: aMorph.
		^ false].
	(self firstSubmorph labelDifferenceOf: aMorph firstSubmorph do: aBlock) ifFalse: [
		aBlock value: self value: aMorph.
		^ false].
	^ true
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: {self firstSubmorph layoutCommands}
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> newEmptyChildNear: aBlock before: aBoolean [

	^ self repeaterChild ifNotNil: [:r | r newEmptyChildNear: aBlock before: aBoolean]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> newNullBlock [

	| parent unknown |
	parent := self lastInlineChoiceOwner ifNil: [^ self buildCopy].
	unknown := parent buildCopy
		removeAllMorphs;
		buildDefault.
	^ unknown
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> ownerWithColor [

	^ self highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithColor]]
		ifFalse: [self]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> printSExprOn: aStream depth: aNumber short: aBoolean [

	| any |
	(aBoolean and: [self inline]) ifTrue: [^ super printSExprOn: aStream depth: aNumber short: aBoolean].
	
	(self field notNil and: [self inline not]) ifTrue: [
		aStream
			nextPutAll: self field;
			nextPutAll: ': '].
	aStream nextPutAll: '('.
	self inline ifTrue: [aStream nextPutAll: '['].
	aStream nextPutAll: self type.
	self inline ifTrue: [aStream nextPutAll: ']'].
	any := false.
	self
		childSymbolsDo: [:morph |
			any ifFalse: [any := true].
			aStream crtab: aNumber + 1.
			morph printSExprOn: aStream depth: aNumber + 1 short: aBoolean]
		includeInlined: aBoolean not.
	any ifTrue: [aStream crtab: aNumber].
	aStream nextPutAll: ')'
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> printTitleOn: aStream [

	SBToggledCode comment: '' active: 0 do: {
		[((factory shouldBlockInline: self type) and: [self hasSubmorphs and: [self firstSubmorph isUnknown not]]) ifTrue: [^ self firstSubmorph printTitleOn: aStream]]}.
	aStream nextPutAll: self type
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> suggestions [

	self currentTextMorph ifNil: [^ self].
	
	^ (self factory suggestionsFor: self) ifEmpty: [
		(self
			sortedSuggestions: (Array streamContents: [:stream | self toplevel allBlocksDo: [:block | (block isInlineBlock and: [block type = self type and: [block ~= self]]) ifTrue: [block contents ifNotNil: [:c | stream nextPut: c]]]])
			for: self contents) collect: [:text | SBSuggestionItem selector: text label: self type]]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> takeParsedFrom: aCursor [

	^ (factory type: aCursor type compatibleWith: self type)
		ifTrue: [ | descend didDescend |
			" if types were only compatible not matching this is a hidden symbol "
			descend := aCursor type = self type.
			didDescend := false.
			
			descend ifTrue: [didDescend := aCursor gotoFirstChild].
			(self template takeParsedFrom: aCursor)
				ifNotNil: [:m |
					didDescend ifTrue: [
						" if there was more we did a mistake and shouldn't go back up "
						aCursor gotoNextSibling ifTrue: [^ nil].
						
						aCursor gotoParent.
						aCursor gotoNextSibling].
					self buildEmpty addMorphBack: m]
				ifNil: [nil]]
		ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> takeStreamFrom: anObject [

	^ true
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> template [

	^ factory getTemplate: self type
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> type [

	^ type
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> type: aSymbol factory: aFactory [

	type := aSymbol.
	factory := aFactory
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> type: aSymbol factory: aFactory block: aMorph [

	type := aSymbol.
	factory := aFactory.
	self addMorphBack: aMorph
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> type: aSymbol factory: aFactory visitedSymbols: aSet [

	aSet add: aSymbol.
	self type: aSymbol factory: aFactory
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> unwrapSuperType [

	^ self isSuperType ifTrue: [self firstSubmorph unwrapSuperType] ifFalse: [self]
]

{ #category : #'as yet unclassified' }
SBInlineBlockSymbol >> writeSourceOn: aStream indent: aNumber [

	self firstSubmorph writeSourceOn: aStream indent: aNumber
]
