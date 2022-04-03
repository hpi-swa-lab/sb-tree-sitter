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
	slot := SBTSSlot new addNode: self.
	^ self bodyTemplate isTSChoice
		ifTrue: [{SBTSUnknownBlock new slot: slot}]
		ifFalse: [
			self isBlockInlined
				ifTrue: [ | blocks |
					blocks := self bodyTemplate buildEmpty.
					blocks do: [:b | b slot addNode: self].
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
		^ self bodyTemplate
			cursorPositionsDo: aClosure
			shallow: aBoolean
			blocks: aStream
			parent: aBlock].
	
	(aStream peek slot includesParent: self) ifTrue: [ | block |
		block := aStream next.
		block isTextMorph ifTrue: [
			aClosure value: (SBCursorText new
				block: block containingSandblock;
				currentCommand: (SBTextCommand new textMorph: block))].
		(aBoolean not and: [block isTSBlock]) ifTrue: [block cursorPositionsDo: aClosure shallow: aBoolean]]
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

	(self factory inputTransitionBlackList includes: self type) ifTrue: [^ #noMatch].
	
	^ aParser
		memoizationFor: self type
		ifPresent: [:results |
			" we may not actually ever want left-recursion, because these blocks will be composed of a wrapper block and a basic block, and we always want to choose the basic block and offer the user to expand the basic block to the more complicated construct. "
			(results = #recur or: [results = #noMatch])
				ifTrue: [#noMatch]
				ifFalse: [
					results do: [:r | r blocks last slot replaceLast: self].
					aParser peek = (Character value: 0)
						ifTrue: [
							" if we consumed a nested block, use the input parser and copy all relevant state
because the stored, nested parser does not have a valid stream "
							aParser blocks: aParser blocks, results first blocks.
							aParser next.
							{aParser}]
						ifFalse: [results]]]
		ifAbsentPut: [ | results currentBlocks |
			currentBlocks := aParser blocks.
			aParser blocks: OrderedCollection new.
			
			results := self bodyTemplate resultsFor: aParser.
			results = #noMatch
				ifTrue: [
					aParser blocks: currentBlocks.
					#noMatch]
				ifFalse: [
					results collect: [:result |
						self isInlined
							ifTrue: [
								result blocks do: [:b | b slot addNode: self].
								result blocks: currentBlocks copy, result blocks.
								result]
							ifFalse: [
								result blocks: (currentBlocks copy
									add: (SBTSBlock new
										slot: (SBTSSlot new addNode: self);
										addAllMorphs: (result blocks collect: [:b | b copyBlock]));
									yourself)]]]]
]

{ #category : #parsing }
SBTSNodeSymbol >> takeNodesFrom: aParser [

	(self isSuperType or: [factory promotedInlineSymbols includes: self type]) ifTrue: [ | results |
		results := self bodyTemplate takeNodesFrom: aParser.
		^ results = #noMatch ifTrue: [#noMatch] ifFalse: [
			results collect: [:parser | | res |
				res := parser copy.
				res currentSlot addNode: self.
				res]]].
	
	(aParser atEnd not and: [aParser peek isString not and: [aParser peek compatibleWithType: self type]]) ifTrue: [
		aParser next.
		^ {aParser copy addSlot: self}].
	
	^ #noMatch
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
