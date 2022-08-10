Class {
	#name : #SBTSNodeSymbol,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'type',
		'hidden'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #hierarchy }
SBTSNodeSymbol >> allChildrenDo: aBlock visited: aSet [

	aBlock value: self.
	(self isInlined and: [(aSet includes: self) not]) ifTrue: [
		aSet add: self.
		self bodyTemplate allChildrenDo: aBlock visited: aSet]
]

{ #category : #hierarchy }
SBTSNodeSymbol >> allElementsDo: aBlock [

	aBlock value: self
]

{ #category : #hierarchy }
SBTSNodeSymbol >> allSubTypesDo: aBlock parents: aCollection [

	| parents |
	parents := aCollection, {self}.
	aBlock value: self value: parents.
	self isInlined ifTrue: [self bodyTemplate allSubTypesDo: aBlock parents: parents]
]

{ #category : #hierarchy }
SBTSNodeSymbol >> allSuperTypesDo: aBlock [

	aBlock value: self.
	super allSuperTypesDo: aBlock
]

{ #category : #accessing }
SBTSNodeSymbol >> bodyTemplate [

	^ self factory bodyNodeForRule: self type
]

{ #category : #parsing }
SBTSNodeSymbol >> buildEmpty [

	| slot |
	slot := SBTSSlot with: self.
	^ self bodyTemplate isTSChoice
		ifTrue: [{SBTSUnknownBlock new slot: slot}]
		ifFalse: [
			self isBlockInlined
				ifTrue: [ | blocks |
					blocks := self bodyTemplate buildEmpty.
					blocks do: [:b | b slot: (b slot addNode: self)].
					blocks]
				ifFalse: [
					{
						SBTSBlock new
							slot: slot;
							addAllMorphs: self bodyTemplate buildEmpty}]]
]

{ #category : #accessing }
SBTSNodeSymbol >> buildEmptyNodes [

	^ self bodyTemplate isTSChoice
		ifTrue: [{SBTSParseNode kind: #unknown slot: (SBTSSlot with: self) contents: nil}]
		ifFalse: [
			self isBlockInlined
				ifTrue: [ | nodes |
					nodes := self bodyTemplate buildEmptyNodes.
					nodes do: [:b | b slot: (b slot addNode: self)].
					nodes]
				ifFalse: [
					{
						SBTSParseNode
							kind: #block
							slot: (SBTSSlot with: self)
							contents: self bodyTemplate buildEmptyNodes}]]
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> createsNewBlock [

	^ self isInlined not
]

{ #category : #hierarchy }
SBTSNodeSymbol >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock [

	self isBlockInlined ifTrue: [
		^ (aStream peek isTSBlock and: [aStream peek isUnknown and: [aStream peek slot firstNode = self]])
			ifTrue: [ | block |
				block := aStream next.
				aClosure value: (SBCursorSelect new block: block).
				aBoolean ifFalse: [block cursorPositionsDo: aClosure shallow: aBoolean]]
			ifFalse: [
				self bodyTemplate
					cursorPositionsDo: aClosure
					shallow: aBoolean
					blocks: aStream
					parent: aBlock]].
	
	(aStream peek slot includesParent: self) ifTrue: [ | block |
		block := aStream next.
		block isTextMorph
			ifTrue: [
				aClosure value: (SBCursorText new
					block: block containingSandblock;
					currentCommand: (SBTextCommand new textMorph: block))]
			ifFalse: [aBoolean ifTrue: [aClosure value: (SBCursorSelect new block: block)]].
		(aBoolean not and: [block isTSBlock]) ifTrue: [block cursorPositionsDo: aClosure shallow: aBoolean]]
]

{ #category : #printing }
SBTSNodeSymbol >> delimiterBetween: aBlock and: anotherBlock [

	self factory delimitedRules
		at: self type
		ifPresent: [:delimiter | self bodyTemplate allChildrenDo: [:node | (node isTSRepeat and: [(aBlock slot lastNode hasParent: node element) and: [anotherBlock slot lastNode hasParent: node element]]) ifTrue: [^ delimiter first]]].
	^ ''
]

{ #category : #hierarchy }
SBTSNodeSymbol >> effectiveNode [

	^ self isBlockInlinedInParent ifTrue: [self bodyTemplate] ifFalse: [self]
]

{ #category : #accessing }
SBTSNodeSymbol >> elements [

	^ #()
]

{ #category : #testing }
SBTSNodeSymbol >> hasEqualStructure: aNode [

	^ (super hasEqualStructure: aNode) and: [self type = aNode type]
]

{ #category : #accessing }
SBTSNodeSymbol >> hidden [

	^ hidden ifNil: [false]
]

{ #category : #accessing }
SBTSNodeSymbol >> hidden: aBoolean [

	hidden := aBoolean
]

{ #category : #testing }
SBTSNodeSymbol >> isBlockInlinedInParent [

	^ self factory isBlockInlinedInParent: self type
]

{ #category : #testing }
SBTSNodeSymbol >> isSubTypeOf: aSymbol stack: aCollection [

	| first |
	first := aCollection indexOf: self.
	(aCollection viewFrom: first) do: [:node |
		node andParentsDo: [:p |
			p type = aSymbol type ifTrue: [^ true].
			(p isTSChoice not and: [p isTSSymbol not]) ifTrue: [^ false]]].
	^ false
]

{ #category : #testing }
SBTSNodeSymbol >> isTSSymbol [

	^ true
]

{ #category : #printing }
SBTSNodeSymbol >> labelPrintOn: aStream [

	aStream nextPutAll: ((self type copyReplaceAll: '_' with: ' ') withBlanksTrimmed asText addAttribute: TextEmphasis italic)
]

{ #category : #testing }
SBTSNodeSymbol >> noRepeatOrSeq [

	self bodyTemplate allChildrenDo: [:child | ((child isTSRepeat and: [child element isTSText not]) or: [child isTSSeq]) ifTrue: [^ false]].
	^ true
]

{ #category : #printing }
SBTSNodeSymbol >> printOn: aStream [

	aStream nextPutAll: type
]

{ #category : #parsing }
SBTSNodeSymbol >> resultsFor: aParser [

	| storedBlocks newBlocks |
	(self language inputTransitionBlackList includes: self type) ifTrue: [^ {}].
	
	aParser peek = (Character value: 1) ifTrue: [
		aParser next.
		^ {aParser basicAddBlocks: self buildEmptyNodes}].
	
	storedBlocks := (aParser peek isMorph and: [aParser peek slot type = self type])
		ifTrue: [ | block result |
			result := aParser copy.
			block := result next.
			(((block childSandblocks ifNotEmpty: [:c | c first slot] ifEmpty: [self]) parentThat: [:node | node isTSPrecedence])
				ifNotNil: [:precedence | precedence canExpandInStack: aParser symbolStack, (block childSandblocks ifNotEmpty: [{self}] ifEmpty: [{}])]
				ifNil: [true])
				ifTrue: [
					result basicAddBlocks: {SBTSParseNode kind: #blockEmbed slot: (block slot trimNodesToTypeOf: self) contents: block}.
					{result}]
				ifFalse: [{}]]
		ifFalse: [{}].
	newBlocks := (SBToggledCode comment: '' active: 2 do: {
		[true].
		["see memoizationFor:ifAbsentPut:, same hack"
		storedBlocks noneSatisfy: [:r | r atEnd]]})
		ifTrue: [
			aParser memoizationFor: self ifAbsentPut: [ | currentBlocks results |
				currentBlocks := aParser blocks.
				aParser blocks: OrderedCollection new.
				results := (self bodyTemplate resultsFor: aParser) collect: [:result |
					SBTSMemoizedBlocks new
						position: result position;
						wasIncomplete: result wasIncomplete;
						blocks: (self isInlined
							ifTrue: [
								self isBlockInlinedInParent ifTrue: [result blocks] ifFalse: [
									result blocks
										do: [:b | b slot: (b slot addNode: self)];
										yourself]]
							ifFalse: [{SBTSParseNode kind: #block slot: (SBTSSlot with: self) contents: result blocks}]);
						yourself].
				aParser blocks: currentBlocks.
				results]]
		ifFalse: [{}].
	
	^ storedBlocks, newBlocks
]

{ #category : #parsing }
SBTSNodeSymbol >> resultsForBlocks: aParser [

	^ aParser memoizedAt: aParser position for: self ifNone: [ | ret |
		ret := nil.
		(self isSuperType or: [aParser justEnteredAlias]) ifTrue: [ | currentBlocks |
			currentBlocks := aParser blocks.
			aParser justEnteredAlias: false.
			aParser blocks: OrderedCollection new.
			((self bodyTemplate resultsForBlocks: aParser) collect: [:res |
				res blocks do: [:b | b slot: (b slot addNode: self)].
				res blocks: currentBlocks, res blocks.
				res]) ifNotEmpty: [:results | "haven't found a good way yet to distinguish between just-entered-alias applying or not. e.g., in named_imports it should not apply to identifier.
so, as a workaround, we just fall-through if we did not match and try to take the symbol"
			ret := results]].
		
		(ret isNil and: [aParser atEnd not and: [aParser peekForType: self type]]) ifTrue: [ | currentBlocks results range |
			currentBlocks := aParser blocks.
			aParser blocks: OrderedCollection new.
			range := aParser currentRange.
			aParser descend.
			results := (self bodyTemplate resultsForBlocks: aParser) select: [:option |
				option ascend
					ifTrue: [
						option nextSibling.
						true]
					ifFalse: [false]].
			results size > 1 ifTrue: [
				SBToggledCode comment: '' active: 1 do: {
					[results := {results detectMax: [:r | (r blocks collect: [:b | b recursiveSubmorphCount]) sum]}].
					[self error: 'should deduplicate here?']}].
			SBToggledCode
				comment: ''
				active: 0
				do: {[self assert: results size > 0 description: 'could not construct ', type]}.
			ret := results ifEmpty: [{}] ifNotEmpty: [ | result newBlocks |
				result := results anyOne.
				newBlocks := self isBlockInlined
					ifTrue: [result blocks do: [:b | (self isBlockInlinedInParent not or: [b slot includesRepeat not]) ifTrue: [b slot: (b slot addNode: self)]]]
					ifFalse: [
						{
							SBTSBlock new
								range: range;
								addAllMorphs: result blocks;
								slot: (SBTSSlot with: self)}].
				{
					result
						blocks: currentBlocks, newBlocks;
						yourself}]].
		
		ret ifNil: [{}]]
]

{ #category : #parsing }
SBTSNodeSymbol >> takeNodesFrom: aParser [

	(self isSuperType or: [factory promotedInlineSymbols includes: self type]) ifTrue: [
		^ (self bodyTemplate takeNodesFrom: aParser) collect: [:parser | | res |
			res := parser copy.
			(res currentSlot lastNode hasParent: self bodyTemplate) ifTrue: [res replaceCurrentSlot: (res currentSlot addNode: self)].
			res]].
	
	(aParser atEnd not and: [aParser peek isString not and: [aParser peek compatibleWithType: self type]]) ifTrue: [
		aParser next.
		^ {aParser copy addSlot: self}].
	
	^ {}
]

{ #category : #hierarchy }
SBTSNodeSymbol >> traverseBlocks: aStream do: aBlock [

	self isBlockInlined ifTrue: [^ self bodyTemplate traverseBlocks: aStream do: aBlock].
	^ (aStream peek isTSBlock and: [aStream peek slot includesParent: self]) ifTrue: [ | block |
		block := aStream next.
		aBlock value: block]
]

{ #category : #accessing }
SBTSNodeSymbol >> type [

	^ type
]

{ #category : #accessing }
SBTSNodeSymbol >> type: aString factory: aFactory [

	self assert: (aFactory isKindOf: SBTSGrammar).
	type := aString asSymbol.
	factory := aFactory
]
