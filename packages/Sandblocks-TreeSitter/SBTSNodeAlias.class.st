Class {
	#name : #SBTSNodeAlias,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'alias',
		'element'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
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
SBTSNodeAlias >> allChildrenDo: aBlock [

	aBlock value: self.
	self element allChildrenDo: aBlock
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

	^ self element buildEmpty
]

{ #category : #'as yet unclassified' }
SBTSNodeAlias >> buildEmptyNodes [

	^ self element buildEmptyNodes
]

{ #category : #blocks }
SBTSNodeAlias >> buildMorphWith: aBlock slot: aSlot [

	^ super buildMorphWith: aBlock slot: (aSlot addNodeFirst: aBlock slot firstNode element)
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
	currentBlocks := aParser blocks.
	aParser blocks: OrderedCollection new.
	^ (self element resultsFor: aParser) collect: [:result |
		result blocks do: [:b | b slot: (b slot addNode: self)].
		result blocks: currentBlocks, result blocks.
		result]
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
