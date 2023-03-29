Class {
	#name : #SBTSSlot,
	#superclass : #Object,
	#instVars : [
		'nodes'
	],
	#category : #'Sandblocks-TreeSitter-Grammar'
}

{ #category : #'as yet unclassified' }
SBTSSlot class >> with: aNode [

	| new |
	new := self new.
	new nodes add: aNode.
	^ new
]

{ #category : #mutating }
SBTSSlot >> addNode: aNode [

	| new |
	self assert: (aNode isKindOf: SBTSNodeBase).
	SBToggledCode comment: '' active: 1 do: {
		[self assert: (nodes includes: aNode) not].
		[self assert: (nodes isEmpty or: [aNode ~= self lastNode])]}.
	new := self copy.
	new nodes add: aNode.
	^ new
]

{ #category : #mutating }
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

	aBlock slot allParentsDo: [:p |
		"if we first hit a seq where both of these are involved, do not put a delimiter"
		(p isTSSeq and: [anotherBlock slot includesParent: p]) ifTrue: [^ ''].
		(p isTSRepeat and: [(anotherBlock slot includesParent: p) and: [p delimiter notNil]]) ifTrue: [^ p delimiter]].
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
SBTSSlot >> indent: aNumber on: aStream [

	aNumber timesRepeat: [
		self language tabsToSpaces
			ifTrue: [aStream nextPutAll: '    ']
			ifFalse: [aStream tab]]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> initialize [

	nodes := OrderedCollection new: 1
]

{ #category : #'as yet unclassified' }
SBTSSlot >> isStatementIn: aContainerBlock [

	self repeatersDo: [:repeater | repeater isStatementRepeater ifTrue: [^ true]].
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

{ #category : #mutating }
SBTSSlot >> mergeWith: aSlot [

	nodes addAll: aSlot nodes
]

{ #category : #'as yet unclassified' }
SBTSSlot >> needsParenthesis: aBlock [

	| mine parent recursiveType parentSlot cmp |
	aBlock parentSandblock isTSBlock ifFalse: [^ false].
	
	"FIXME: drop this and fix it propper"
	aBlock type = #'parenthesized_expression' ifTrue: [^ false].
	
	parentSlot := aBlock parentSandblock slot.
	recursiveType := (self lastCommonAncestorWith: parentSlot) ifNil: [^ false].
	self flag: #todo.
	"should only occur if the recursive type is at a border position (e.g. not in parentheses) "
	((parentSlot firstNode bodyTemplate countType: recursiveType type) > 1 and: [(self firstNode bodyTemplate countType: recursiveType type) > 0]) ifFalse: [^ false].
	
	(parentSlot firstNode bodyTemplate hasTypeRightMost: recursiveType) ifFalse: [^ false].
	
	mine := self precedenceAround: aBlock firstSubmorph.
	parent := parentSlot precedenceAround: aBlock.
	cmp := mine compareTo: parent ifNotComparable: [0].
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
			['variable.part'] -> [aColorPolicy default].
			['variable.builtin'] -> [aColorPolicy identifier].
			['type'] -> [aColorPolicy keyword].
			['number'] -> [aColorPolicy literal].
			['string'] -> [aColorPolicy literal].
			['escape'] -> [aColorPolicy literal].
			['punctuation.bracket'] -> [aColorPolicy builtIn].
			['constant.builtin'] -> [aColorPolicy builtIn].
			['operator'] -> [aColorPolicy identifier].
			['property'] -> [aColorPolicy important].
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

{ #category : #mutating }
SBTSSlot >> replaceLast: aNode [

	| new |
	new := self copy.
	new nodes removeLast.
	new nodes add: aNode.
	^ new
]

{ #category : #'as yet unclassified' }
SBTSSlot >> separatorBetween: aBlock and: anotherBlock indent: aNumber lastCharacterOfFirst: aCharacter [

	(self delimiterBetween: aBlock and: anotherBlock) ifNotEmpty: [:delimiter | ^ delimiter].
	(self factory hardLineBreakBetween: aBlock and: anotherBlock) ifTrue: [
		^ String streamContents: [:s |
			s cr.
			self indent: aNumber on: s]].
	(self factory language
		spaceBetween: aBlock
		and: anotherBlock
		lastCharacterOfFirst: aCharacter) ifTrue: [^ String space].
	^ ''
]

{ #category : #'as yet unclassified' }
SBTSSlot >> transitionRoot [

	^ self nodes last transitionRoot
]

{ #category : #mutating }
SBTSSlot >> trimNodesTo: aNode [

	| index |
	index := nodes indexOf: aNode ifAbsent: [self error: 'missing node in slot list'].
	nodes removeLast: nodes size - index
]

{ #category : #mutating }
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

	self factory highlightQuery ifNotNil: [:query | (query executeCaptureAgainst: aBlock) do: [:pair | (pair value highlight isNil or: [pair value highlight = #'_sb_none' or: [pair value highlight size < pair key size]]) ifTrue: [pair value highlight: pair key]]]
]

{ #category : #'as yet unclassified' }
SBTSSlot >> veryDeepCopyWith: deepCopier [
	"immutable, so can be shared"

	
]
