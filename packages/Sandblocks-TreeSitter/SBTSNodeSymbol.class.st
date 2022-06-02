Class {
	#name : #SBTSNodeSymbol,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'type'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #hierarchy }
SBTSNodeSymbol >> allChildrenDo: aBlock [

	aBlock value: self.
	self isInlined ifTrue: [self bodyTemplate allChildrenDo: aBlock]
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

{ #category : #testing }
SBTSNodeSymbol >> isBlockInlinedInParent [

	^ self factory isBlockInlinedInParent: self type
]

{ #category : #testing }
SBTSNodeSymbol >> isTSSymbol [

	^ true
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
	(self factory inputTransitionBlackList includes: self type) ifTrue: [^ {}].
	
	aParser peek = (Character value: 1) ifTrue: [
		aParser next.
		^ {aParser basicAddBlocks: self buildEmpty}].
	
	storedBlocks := (aParser peek isMorph and: [aParser peek slot includesParentThat: [:p | p type = self type]])
		ifTrue: [ | block result |
			result := aParser copy.
			block := result next copyBlock.
			block slot trimNodesToTypeOf: self.
			result addBlock: block.
			{result}]
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
							ifFalse: [
								{
									SBTSBlock new
										slot: (SBTSSlot with: self);
										addAllMorphs: result blocks;
										yourself}]);
						yourself].
				aParser blocks: currentBlocks.
				results]]
		ifFalse: [{}].
	
	^ storedBlocks, newBlocks
]

{ #category : #parsing }
SBTSNodeSymbol >> resultsNonMemoizedFor: aParser [

	| currentBlocks |
	currentBlocks := aParser blocks.
	aParser blocks: OrderedCollection new.
	^ (self bodyTemplate resultsFor: aParser)
		ifEmpty: [
			aParser blocks: currentBlocks.
			{}]
		ifNotEmpty: [:results |
			results do: [:result |
				self isInlined
					ifTrue: [
						result blocks do: [:b | b slot: (b slot addNode: self)].
						result blocks: currentBlocks, result blocks]
					ifFalse: [
						result blocks: currentBlocks, {
							SBTSBlock new
								slot: (SBTSSlot with: self);
								addAllMorphs: result blocks}]].
			results]
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

	type := aString asSymbol.
	factory := aFactory
]
