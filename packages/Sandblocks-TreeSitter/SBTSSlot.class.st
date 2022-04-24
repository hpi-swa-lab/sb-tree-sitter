Class {
	#name : #SBTSSlot,
	#superclass : #Object,
	#instVars : [
		'nodes'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSSlot >> adaptSlotFor: anotherSlot [

	| index |
	(self nodes hasEqualElements: anotherSlot nodes) ifTrue: [^ true].
	
	index := anotherSlot nodes findFirst: [:node | node type = self lastNode type].
	index > 0
		ifTrue: [
			nodes removeLast.
			anotherSlot nodes
				from: index
				to: anotherSlot nodes size
				do: [:node | self addNode: node].
			^ true]
		ifFalse: [
			anotherSlot firstNode
				allSubTypesDo: [:child :parents |
					child type = self lastNode type ifTrue: [
						nodes removeLast.
						parents reverseDo: [:p | self addNode: p].
						^ true]]
				parents: {}].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSSlot >> addNode: aNode [

	self assert: (aNode isKindOf: SBTSNodeBase).
	nodes add: aNode
]

{ #category : #'as yet unclassified' }
SBTSSlot >> addNodeFirst: aNode [

	self assert: (aNode isKindOf: SBTSNodeBase).
	nodes addFirst: aNode
]

{ #category : #'as yet unclassified' }
SBTSSlot >> allChildrenDo: aBlock [

	nodes reverseDo: [:node | node root allChildrenDo: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> allParentsDo: aBlock [

	nodes do: [:node | node andParentsDo: [:parent | aBlock value: parent]]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> allSuperTypesDo: aBlock [

	nodes do: [:node | node allSuperTypesDo: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> buildMorphWith: anObject [

	| morph |
	morph := nodes last buildMorphWith: anObject slot: self.
	^ morph
]

{ #category : #'as yet unclassified' }
SBTSSlot >> compatibleWithType: aTypeString [

	self allSuperTypesDo: [:type | type type = aTypeString ifTrue: [^ true]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSSlot >> delimiterBetween: aBlock and: anotherBlock [

	(self firstNode delimiterBetween: aBlock and: anotherBlock) ifNotEmpty: [:d | ^ d].
	self firstNode bodyTemplate allChildrenDo: [:node | node isBlockInlinedInParent ifTrue: [(node delimiterBetween: aBlock and: anotherBlock) ifNotEmpty: [:d | ^ d]]].
	
	^ ''
]

{ #category : #'as yet unclassified' }
SBTSSlot >> delimiterIn: aBlock [

	(self factory delimitedRules at: aBlock type) ifNotNil: [:delimiter | aBlock slot firstNode bodyTemplate allChildrenDo: [:node | (node isTSRepeat and: [self lastNode hasParent: node element]) ifTrue: [^ delimiter first]]].
	^ ''
]

{ #category : #'as yet unclassified' }
SBTSSlot >> factory [

	^ self lastNode factory
]

{ #category : #'as yet unclassified' }
SBTSSlot >> field [

	self allParentsDo: [:type | type field ifNotNil: [:field | ^ field]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSSlot >> firstNode [

	^ nodes first
]

{ #category : #'as yet unclassified' }
SBTSSlot >> includesParent: aNode [

	^ self includesParentThat: [:p | p = aNode]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> includesParentThat: aBlock [

	nodes do: [:node | node andParentsDo: [:parent | (aBlock value: parent) ifTrue: [^ true]]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSSlot >> includesRepeat [

	^ self includesParentThat: [:p | p isTSRepeat]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> initialize [

	nodes := OrderedCollection new: 1
]

{ #category : #'as yet unclassified' }
SBTSSlot >> lastNode [

	^ nodes last
]

{ #category : #'as yet unclassified' }
SBTSSlot >> lastRepeater [

	| repeater |
	repeater := nil.
	self allParentsDo: [:p | p isTSRepeat ifTrue: [repeater := p]].
	^ repeater
]

{ #category : #'as yet unclassified' }
SBTSSlot >> mergeWith: aSlot [

	nodes addAll: aSlot nodes
]

{ #category : #'as yet unclassified' }
SBTSSlot >> nodes [

	^ nodes
]

{ #category : #'as yet unclassified' }
SBTSSlot >> parentThat: aBlock [

	nodes do: [:node | node andParentsDo: [:parent | (aBlock value: parent) ifTrue: [^ parent]]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSSlot >> postCopy [

	nodes := nodes copy
]

{ #category : #highlight }
SBTSSlot >> preferredColorIn: aColorPolicy for: aHighlightString [

	^ aHighlightString
		caseOf: {
			['keyword'] -> [aColorPolicy keyword].
			['function'] -> [aColorPolicy identifier].
			['comment'] -> [aColorPolicy defaultLight].
			['variable'] -> [aColorPolicy identifier].
			['variable.part'] -> [aColorPolicy identifier].
			['type'] -> [aColorPolicy keyword].
			['number'] -> [aColorPolicy literal].
			['string'] -> [aColorPolicy literal].
			['escape'] -> [aColorPolicy literal].
			['punctuation.bracket'] -> [aColorPolicy builtIn].
			['constant.builtin'] -> [aColorPolicy builtIn].
			['operator'] -> [aColorPolicy identifier].
			['property'] -> [aColorPolicy identifier].
			['important'] -> [aColorPolicy important]}
		otherwise: [aColorPolicy default]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> printOn: aStream [

	aStream nextPutAll: self className.
	aStream nextPut: $(.
	nodes do: [:node | node printOn: aStream] separatedBy: [aStream nextPut: $,].
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
SBTSSlot >> repeater [

	^ self parentThat: [:p | p isTSRepeat]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> repeatersDo: aBlock [

	self allParentsDo: [:p | p isTSRepeat ifTrue: [aBlock value: p]]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> replaceLast: aNode [

	nodes removeLast.
	nodes add: aNode
]

{ #category : #'as yet unclassified' }
SBTSSlot >> separatorBetween: aBlock and: anotherBlock indent: aNumber [

	(self delimiterBetween: aBlock and: anotherBlock) ifNotEmpty: [:delimiter | ^ delimiter].
	(self factory hardLineBreakBetween: aBlock and: anotherBlock) ifTrue: [
		^ String streamContents: [:s |
			s cr.
			aNumber timesRepeat: [s tab]]].
	(self factory spaceBetween: aBlock and: anotherBlock) ifTrue: [^ String space].
	^ ''
]

{ #category : #'as yet unclassified' }
SBTSSlot >> transitionRoot [

	^ self nodes last transitionRoot
]

{ #category : #'as yet unclassified' }
SBTSSlot >> trimNodesTo: aNode [

	| index |
	index := nodes indexOf: aNode ifAbsent: [self error: 'missing node in slot list'].
	nodes removeLast: nodes size - index
]

{ #category : #'as yet unclassified' }
SBTSSlot >> type [

	^ self firstNode type
]

{ #category : #highlight }
SBTSSlot >> updateAllHighlightsFor: aBlock [

	self factory hasHighlight ifFalse: [^ self].
	aBlock allMorphsDo: [:m |
		m isTSMorph ifTrue: [
			m highlight: #'_sb_none'.
			m slot updateHighlightFor: m]]
]

{ #category : #highlight }
SBTSSlot >> updateHighlightFor: aBlock [

	self factory highlightQuery
		executeAgainst: aBlock
		capturesDo: [:captures | captures keysAndValuesDo: [:id :block | (block highlight isNil or: [block highlight = #'_sb_none']) ifTrue: [block highlight: id]]]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> writeSourceOn: aStream with: aCollection [

	nodes last
]
