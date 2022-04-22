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
SBTSNodeAlias >> buildMorphWith: aBlock slot: aSlot [

	aSlot addNodeFirst: aBlock slot firstNode element.
	^ super buildMorphWith: aBlock slot: aSlot
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

	| results |
	results := self element resultsFor: aParser.
	results = #noMatch ifTrue: [^ results].
	^ results collect: [:result |
		result blocks do: [:b | b slot addNode: self].
		result]
]

{ #category : #parsing }
SBTSNodeAlias >> takeNodesFrom: aParser [

	^ (aParser atEnd not and: [
		aParser peek isString not and: [
			SBToggledCode comment: '' active: 1 do: {
				[(aParser peek isKindOf: self class) and: [aParser peek alias = self alias]].
				[aParser peek type = self alias or: [(aParser peek isKindOf: self class) and: [aParser peek alias = self alias]]]}]])
		ifTrue: [
			aParser next.
			{aParser copy addSlot: self}]
		ifFalse: [#noMatch]
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
