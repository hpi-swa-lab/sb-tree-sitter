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
			self isBlockInlined ifTrue: [self bodyTemplate buildEmpty] ifFalse: [
				{
					SBTSBlock new
						slot: slot;
						addAllMorphs: self bodyTemplate buildEmpty}]]
]

{ #category : #hierarchy }
SBTSNodeSymbol >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock [

	self isBlockInlined ifTrue: [^ self bodyTemplate cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock].
	
	aCollection
		detect: [:block | block isTSBlock and: [block slot includesParent: self]]
		ifFound: [:b |
			aClosure value: (SBCursorSelect new block: b).
			aBoolean ifFalse: [b cursorPositionsDo: aClosure shallow: aBoolean]]
		ifNone: []
]

{ #category : #testing }
SBTSNodeSymbol >> isTSSymbol [

	^ true
]

{ #category : #testing }
SBTSNodeSymbol >> noRepeatOrSeq [

	self bodyTemplate allChildrenDo: [:child | (child isTSChoice or: [child isTSSymbol or: [child isTSAlias or: [child isTSLabel]]]) ifFalse: [^ false]].
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
								result blocks: currentBlocks copy, result blocks.
								result blocks last slot addNode: self.
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

{ #category : #accessing }
SBTSNodeSymbol >> type [

	^ type
]

{ #category : #accessing }
SBTSNodeSymbol >> type: aString factory: aFactory [

	type := aString asSymbol.
	factory := aFactory
]
