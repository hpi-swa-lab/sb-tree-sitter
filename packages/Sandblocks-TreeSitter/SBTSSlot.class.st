Class {
	#name : #SBTSSlot,
	#superclass : #Object,
	#instVars : [
		'nodes'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSSlot class >> with: aNode [

	| new |
	new := self new.
	new nodes add: aNode.
	^ new
]

{ #category : #'as yet unclassified' }
SBTSSlot >> addNode: aNode [

	| new |
	self assert: (aNode isKindOf: SBTSNodeBase).
	self assert: (nodes isEmpty or: [aNode ~= self lastNode]).
	new := self copy.
	new nodes add: aNode.
	^ new
]

{ #category : #'as yet unclassified' }
SBTSSlot >> addNodeFirst: aNode [

	| new |
	new := self copy.
	new nodes addFirst: aNode.
	^ new
]

{ #category : #'as yet unclassified' }
SBTSSlot >> alias [

	^ self firstNode alias
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

	self allParentsDo: [:node | (node type = aTypeString or: [node isTSAlias and: [node alias = aTypeString]]) ifTrue: [^ true]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSSlot >> delimiterBetween: aBlock and: anotherBlock [

	aBlock slot repeatersDo: [:r | (r delimiter notNil and: [anotherBlock slot includesParent: r]) ifTrue: [^ r delimiter]].
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
SBTSSlot >> isStatementIn: aContainerBlock [

	self repeatersDo: [:repeater | (self language isStatementContainer: repeater in: aContainerBlock) ifTrue: [^ true]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSSlot >> language [

	^ self factory language
]

{ #category : #'as yet unclassified' }
SBTSSlot >> lastCommonAncestorWith: aSlot [

	| candidate |
	candidate := nil.
	self allSuperTypesDo: [:type | aSlot includesParentThat: [:p | p type = type type ifTrue: [candidate := p. true] ifFalse: [false]]].
	^ candidate
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
SBTSSlot >> needsParenthesis: aBlock [

	| mine parent recursiveType parentSlot cmp |
	aBlock parentSandblock isTSBlock ifFalse: [^ false].
	parentSlot := aBlock parentSandblock slot.
	recursiveType := (self lastCommonAncestorWith: parentSlot) ifNil: [^ false].
	self flag: #todo.
	"should only occur if the recursive type is at a border position (e.g. not in parentheses) "
	((parentSlot firstNode bodyTemplate countType: recursiveType type) > 1 and: [(self firstNode bodyTemplate countType: recursiveType type) > 0]) ifFalse: [^ false].
	
	mine := self precedenceAround: aBlock firstSubmorph.
	parent := parentSlot precedenceAround: aBlock.
	cmp := mine compareTo: parent.
	cmp = 0 ifTrue: [
		(parent associativity = #left and: [aBlock isFirstChild]) ifTrue: [^ false].
		(parent associativity = #right and: [aBlock isFirstChild not]) ifTrue: [^ false]].
	^ cmp <= 0
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

	super postCopy.
	nodes := nodes copy
]

{ #category : #'as yet unclassified' }
SBTSSlot >> precedenceAround: aBlock [

	SBToggledCode comment: '' active: 2 do: {
		[
			self firstNode bodyTemplate isTSPrecedence ifTrue: [^ self firstNode bodyTemplate].
			^ SBTSNodePrecedence new
				precedence: 'PREC';
				value: 0].
		[
			aBlock slot allParentsDo: [:p | p isTSPrecedence ifTrue: [^ p]].
			^ SBTSNodePrecedence new
				factory: self factory;
				precedence: 'PREC';
				value: 0]}
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
			['variable.builtin'] -> [aColorPolicy identifier].
			['type'] -> [aColorPolicy keyword].
			['number'] -> [aColorPolicy literal].
			['string'] -> [aColorPolicy literal].
			['escape'] -> [aColorPolicy literal].
			['punctuation.bracket'] -> [aColorPolicy builtIn].
			['constant.builtin'] -> [aColorPolicy builtIn].
			['operator'] -> [aColorPolicy identifier].
			['property'] -> [aColorPolicy identifier].
			['important'] -> [aColorPolicy important].
			['major_declaration'] -> [aColorPolicy default]}
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
SBTSSlot >> repeaterThat: aBlock [

	self repeatersDo: [:r | (aBlock value: r) ifTrue: [^ r]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSSlot >> repeatersDo: aBlock [

	self allParentsDo: [:p | p isTSRepeat ifTrue: [aBlock value: p]]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> replaceLast: aNode [

	| new |
	new := self copy.
	new nodes removeLast.
	new nodes add: aNode.
	^ new
]

{ #category : #'as yet unclassified' }
SBTSSlot >> separatorBetween: aBlock and: anotherBlock indent: aNumber [

	(self delimiterBetween: aBlock and: anotherBlock) ifNotEmpty: [:delimiter | ^ delimiter].
	(self factory hardLineBreakBetween: aBlock and: anotherBlock) ifTrue: [
		^ String streamContents: [:s |
			s cr.
			aNumber timesRepeat: [s tab]]].
	(self factory language spaceBetween: aBlock and: anotherBlock) ifTrue: [^ String space].
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
SBTSSlot >> trimNodesToTypeOf: aNode [

	| index new |
	new := self copy.
	index := nodes findFirst: [:node | aNode type = node type].
	new nodes removeLast: nodes size - (index - 1).
	new nodes addLast: aNode.
	^ new
]

{ #category : #'as yet unclassified' }
SBTSSlot >> type [

	^ self firstNode type
]

{ #category : #highlight }
SBTSSlot >> updateAllHighlightsFor: aBlock [

	self factory hasHighlight ifFalse: [^ #'_sb_none'].
	aBlock allMorphsDo: [:m |
		m isTSMorph ifTrue: [
			m highlight: #'_sb_none'.
			m slot updateHighlightFor: m]].
	^ aBlock highlight
]

{ #category : #highlight }
SBTSSlot >> updateHighlightFor: aBlock [

	self factory highlightQuery
		executeAgainst: aBlock
		capturesDo: [:captures | captures keysAndValuesDo: [:id :block | (block highlight isNil or: [block highlight = #'_sb_none' or: [block highlight size < id size]]) ifTrue: [block highlight: id]]]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> veryDeepCopyWith: deepCopier [

	
]

{ #category : #'as yet unclassified' }
SBTSSlot >> writeSourceOn: aStream with: aCollection [

	nodes last
]
