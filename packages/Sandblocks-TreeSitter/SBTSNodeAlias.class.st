Class {
	#name : #SBTSNodeAlias,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'alias',
		'named',
		'element'
	],
	#category : #'Sandblocks-TreeSitter-Grammar'
}

{ #category : #accessing }
SBTSNodeAlias >> alias [

	^ alias
]

{ #category : #accessing }
SBTSNodeAlias >> alias: aString [

	alias := aString asSymbol
]

{ #category : #blocks }
SBTSNodeAlias >> allChildrenDo: aBlock visited: aSet [

	aBlock value: self.
	self unwrapsNestedBlock ifFalse: [self element allChildrenDo: aBlock visited: aSet]
]

{ #category : #blocks }
SBTSNodeAlias >> allElementsDo: aBlock [

	aBlock value: self.
	self element allElementsDo: aBlock
]

{ #category : #blocks }
SBTSNodeAlias >> allSubTypesDo: aBlock parents: aCollection [

	aBlock value: self value: aCollection.
	self element allSubTypesDo: aBlock parents: aCollection
]

{ #category : #accessing }
SBTSNodeAlias >> bodyTemplate [

	^ self element bodyTemplate
]

{ #category : #blocks }
SBTSNodeAlias >> buildEmpty [

	^ {
		SBTSBlock new
			slot: (SBTSSlot with: self);
			addAllMorphs: self bodyTemplate buildEmpty}
]

{ #category : #'as yet unclassified' }
SBTSNodeAlias >> buildEmptyNodes [

	^ self element buildEmptyNodes
]

{ #category : #blocks }
SBTSNodeAlias >> buildMorphWith: aBlock slot: aSlot [

	^ super buildMorphWith: aBlock slot: (aSlot addNodeFirst: aBlock slot firstNode element)
]

{ #category : #'as yet unclassified' }
SBTSNodeAlias >> createsNewBlock [

	^ self unwrapsNestedBlock not
]

{ #category : #parsing }
SBTSNodeAlias >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock [

	(aStream peek isTSBlock and: [aStream peek slot includesParent: self])
		ifTrue: [ | block |
			block := aStream next.
			aClosure value: (SBCursorSelect new block: block).
			aBoolean ifFalse: [block cursorPositionsDo: aClosure shallow: aBoolean]]
		ifFalse: [self element cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock]
]

{ #category : #accessing }
SBTSNodeAlias >> element [

	^ element
]

{ #category : #accessing }
SBTSNodeAlias >> element: anElement [

	element := anElement.
	anElement parent: self
]

{ #category : #testing }
SBTSNodeAlias >> hasEqualStructure: aNode [

	^ (super hasEqualStructure: aNode) and: [aNode alias = self alias]
]

{ #category : #testing }
SBTSNodeAlias >> isTSAlias [

	^ true
]

{ #category : #printing }
SBTSNodeAlias >> labelPrintOn: aStream [

	aStream nextPutAll: ((self alias copyReplaceAll: '_' with: ' ') asText addAttribute: TextEmphasis italic)
]

{ #category : #'as yet unclassified' }
SBTSNodeAlias >> named [

	^ named
]

{ #category : #'as yet unclassified' }
SBTSNodeAlias >> named: aBoolean [

	named := aBoolean
]

{ #category : #printing }
SBTSNodeAlias >> printOn: aStream [

	aStream nextPut: $(.
	aStream nextPutAll: self alias.
	aStream nextPut: $=.
	self element printOn: aStream.
	aStream nextPut: $)
]

{ #category : #parsing }
SBTSNodeAlias >> resultsFor: aParser [

	| currentBlocks |
	(aParser peek isMorph and: [aParser peek slot lastNode isTSAlias and: [aParser peek slot lastNode alias = self alias]]) ifTrue: [ | block result |
		result := aParser copy.
		block := result next.
		result basicAddBlocks: {SBTSParseNode kind: #blockEmbed slot: (block slot trimNodesToTypeOf: self) contents: block}.
		^ {result}].
	
	currentBlocks := aParser blocks.
	aParser blocks: OrderedCollection new.
	^ (self element resultsFor: aParser) collect: [:result | | blocks |
		blocks := true
			ifTrue: [{SBTSParseNode kind: #block slot: (SBTSSlot with: self) contents: result blocks}]
			ifFalse: [
				result blocks do: [:b |
					(b slot lastNode isTSText or: [b slot lastNode isTSLabel])
						ifTrue: [b slot: (b slot addNode: self)]
						ifFalse: [b slot: (b slot replaceLast: self)]]].
		result blocks: currentBlocks, blocks.
		result]
]

{ #category : #parsing }
SBTSNodeAlias >> resultsForBlocks: aParser [

	(aParser atEnd not and: [
		named
			ifTrue: [(aParser peekForType: self alias) or: [aParser justEnteredAlias]]
			ifFalse: [aParser peekForLabel: self alias]]) ifTrue: [ | currentBlocks results range aliasedResults |
		currentBlocks := aParser blocks.
		aParser blocks: OrderedCollection new.
		aParser descend.
		aParser justEnteredAlias: self element isTSSymbol not.
		range := aParser currentRange.
		results := self bodyTemplate resultsForBlocks: aParser.
		aParser justEnteredAlias: false.
		
		aliasedResults := results groupBy: [:result | | node |
			"nested alias, we can't ascend again because we just did. However, 
we need to add all aliases to the slot"
			node := result blocks anyOne slot lastNode.
			node ~= self and: [node isTSAlias]].
		
		^ (((aliasedResults at: false ifAbsent: {}) select: [:result |
			result ascend
				ifTrue: [
					result nextSibling.
					true]
				ifFalse: [false]]) collect: [:result | | blocks |
			blocks := {(SBTSFileParseNode kind: #block slot: (SBTSSlot with: self) contents: result blocks) range: range}.
			result
				blocks: currentBlocks, blocks;
				yourself]), ((aliasedResults at: true ifAbsent: {}) collect: [:result |
			result blocks anyOne slot addNode: self.
			result])].
	^ {}
]

{ #category : #parsing }
SBTSNodeAlias >> takeNodesFrom: aParser [

	self element isTSText ifTrue: [
		^ (aParser atEnd not and: [aParser peek isString])
			ifTrue: [
				"need to add extra level to slot?"
				self flag: #todo.
				self element takeNodesFrom: aParser]
			ifFalse: [{}]].
	^ (aParser atEnd not and: [
		aParser peek isString not and: [
			SBToggledCode comment: '' active: 1 do: {
				[(aParser peek isKindOf: self class) and: [aParser peek alias = self alias]].
				[aParser peek type = self alias or: [(aParser peek isKindOf: self class) and: [aParser peek alias = self alias]]]}]])
		ifTrue: [
			aParser next.
			{aParser copy addSlot: self}]
		ifFalse: [{}]
]

{ #category : #'as yet unclassified' }
SBTSNodeAlias >> traverseBlocks: aStream do: aBlock [

	(aStream peek isTSBlock and: [aStream peek slot includesParent: self])
		ifTrue: [ | block |
			block := aStream next.
			aBlock value: block]
		ifFalse: [self element traverseBlocks: aStream do: aBlock]
]

{ #category : #accessing }
SBTSNodeAlias >> unpackAlias [

	^ self element isTSSymbol
		ifTrue: [self element bodyTemplate]
		ifFalse: [self element]
]

{ #category : #parsing }
SBTSNodeAlias >> unwrapsNestedBlock [

	self allElementsDo: [:e | (e isTSRepeat or: [e isTSSeq]) ifTrue: [^ false]].
	^ true
]
