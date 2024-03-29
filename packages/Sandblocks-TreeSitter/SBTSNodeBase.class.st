Class {
	#name : #SBTSNodeBase,
	#superclass : #Object,
	#instVars : [
		'field',
		'factory',
		'parent'
	],
	#category : #'Sandblocks-TreeSitter-Grammar'
}

{ #category : #accessing }
SBTSNodeBase >> alias [

	^ nil
]

{ #category : #hierarchy }
SBTSNodeBase >> allChildrenDetect: aBlock ifFound: aSuccessBlock ifNone: aFailBlock [

	self allChildrenDo: [:block | (aBlock value: block) ifTrue: [^ aSuccessBlock value: block]].
	^ aFailBlock value
]

{ #category : #blocks }
SBTSNodeBase >> allChildrenDo: aBlock [

	self allChildrenDo: aBlock visited: IdentitySet new
]

{ #category : #blocks }
SBTSNodeBase >> allChildrenDo: aBlock visited: aSet [

	self subclassResponsibility
]

{ #category : #blocks }
SBTSNodeBase >> allElementsDo: aBlock [

	self subclassResponsibility
]

{ #category : #hierarchy }
SBTSNodeBase >> allSubTypes [

	self isSuperType ifTrue: [
		^ Array streamContents: [:stream | | sub |
			sub := self bodyTemplate allSubTypes.
			stream nextPutAll: sub.
			sub do: [:type | stream nextPutAll: type allSubTypes]]].
	^ {}
]

{ #category : #hierarchy }
SBTSNodeBase >> allSubTypesDo: aBlock parents: aCollection [

	
]

{ #category : #hierarchy }
SBTSNodeBase >> allSubTypesRecursive [

	| found pending |
	found := OrderedCollection new.
	pending := OrderedCollection with: self.
	[pending notEmpty] whileTrue: [
		pending removeFirst allSubTypes do: [:type |
			found add: type.
			pending add: type]].
	^ found
]

{ #category : #hierarchy }
SBTSNodeBase >> allSuperTypesDo: aBlock [

	self parent ifNotNil: [:o | o allSuperTypesDo: aBlock]
]

{ #category : #hierarchy }
SBTSNodeBase >> andParentsDo: aBlock [

	| current |
	current := self.
	[aBlock value: current] doWhileTrue: [(current := current parent) notNil]
]

{ #category : #accessing }
SBTSNodeBase >> bodyTemplate [

	^ self
]

{ #category : #blocks }
SBTSNodeBase >> buildEmpty [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> buildEmptyNodes [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSNodeBase >> buildMorphWith: aBlock slot: aSlot [

	(self factory promotedInlineSymbols includes: self type) ifTrue: [
		self assert: aBlock isString.
		^ SBTSBlock new
			slot: (SBTSSlot with: aSlot lastNode);
			addMorph: (SBTSTextMorph new
				contents: aBlock;
				slot: aSlot)].
	
	aBlock slot firstNode isBlockInlined ifTrue: [
		aBlock submorphs do: [:m | (aBlock slot firstNode isBlockInlinedInParent not or: [m slot includesRepeat not]) ifTrue: [aSlot nodes do: [:n | m slot: (m slot addNode: n)]]].
		^ aBlock submorphs].
	
	^ aBlock slot: aSlot
]

{ #category : #testing }
SBTSNodeBase >> compatibleWithType: aSymbol [

	^ self type = aSymbol
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> countType: aSymbol [

	| count |
	count := 0.
	self allChildrenDo: [:c | c type = aSymbol ifTrue: [count := count + 1]].
	^ count
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> createsNewBlock [

	^ false
]

{ #category : #blocks }
SBTSNodeBase >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock [

	^ self subclassResponsibility
]

{ #category : #hierarchy }
SBTSNodeBase >> delete [

	self parent elements: (self parent elements reject: [:el | el = self]).
	self parent: nil
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> delimiterBetween: aBlock and: anotherBlock [

	^ ''
]

{ #category : #hierarchy }
SBTSNodeBase >> effectiveNode [

	^ self
]

{ #category : #accessing }
SBTSNodeBase >> elements [

	^ {self element}
]

{ #category : #accessing }
SBTSNodeBase >> elements: aCollection [

	self assert: aCollection size = 1.
	self element: aCollection anyOne
]

{ #category : #accessing }
SBTSNodeBase >> factory [

	^ factory
]

{ #category : #accessing }
SBTSNodeBase >> factory: aFactory [

	self assert: (aFactory isKindOf: SBTSGrammar).
	factory := aFactory
]

{ #category : #accessing }
SBTSNodeBase >> field [

	^ field
]

{ #category : #accessing }
SBTSNodeBase >> field: aString [

	field := aString
]

{ #category : #testing }
SBTSNodeBase >> hasEqualStructure: aNode [

	aNode class = self class ifFalse: [^ false].
	aNode elements size = self elements size ifFalse: [^ false].
	aNode elements
		with: self elements
		do: [:a :b | (a hasEqualStructure: b) ifFalse: [^ false]].
	^ true
]

{ #category : #hierarchy }
SBTSNodeBase >> hasParent: aNode [

	self andParentsDo: [:p | p = aNode ifTrue: [^ true]].
	^ false
]

{ #category : #hierarchy }
SBTSNodeBase >> hasParentThat: aBlock [

	self andParentsDo: [:p | (aBlock value: p) ifTrue: [^ true]].
	^ false
]

{ #category : #testing }
SBTSNodeBase >> hasStatementTerminator [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> hasTypeRightMost: aSymbol [

	self elements ifEmpty: [^ false].
	self elements last type = aSymbol ifTrue: [^ true].
	^ self elements last hasTypeRightMost: aSymbol
]

{ #category : #accessing }
SBTSNodeBase >> hidden [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> includesChild: aBlock [

	self allChildrenDo: [:c | (aBlock value: c) ifTrue: [^ true]].
	^ false
]

{ #category : #testing }
SBTSNodeBase >> isBlockInlined [

	^ factory isBlockInlined: self type
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> isBlockInlinedInParent [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isInlined [

	^ self isSuperType or: [self isBlockInlined or: [self hasParentThat: [:parent | parent isTSAlias and: [parent unwrapsNestedBlock]]]]
]

{ #category : #hierarchy }
SBTSNodeBase >> isSubTypeOf: aSymbol stack: aCollection [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isSuperType [

	^ factory isSuperType: self type
]

{ #category : #testing }
SBTSNodeBase >> isTSAlias [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSBlank [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSChoice [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSLabel [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSNode [

	^ true
]

{ #category : #testing }
SBTSNodeBase >> isTSOptional [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSPrecedence [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSRepeat [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSSeq [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSSymbol [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSText [

	^ false
]

{ #category : #printing }
SBTSNodeBase >> labelPrintOn: aStream [

	self subclassResponsibility
]

{ #category : #accessing }
SBTSNodeBase >> language [

	^ factory language
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> nodeBefore [

	| index |
	self parent ifNil: [^ nil].
	index := (self parent elements indexOf: self) - 1.
	index = 0 ifTrue: [^ nil].
	^ self parent elements at: index
]

{ #category : #accessing }
SBTSNodeBase >> parent [

	^ parent
]

{ #category : #accessing }
SBTSNodeBase >> parent: aNode [

	parent := aNode
]

{ #category : #hierarchy }
SBTSNodeBase >> parentPrecedence: aCollection do: aBlock ifNone: anotherBlock [

	| isLeftMost isRightMost |
	isLeftMost := true.
	isRightMost := true.
	aCollection reverseDo: [:root |
		root andParentsDo: [:node |
			(node parent notNil and: [node parent isTSSeq]) ifTrue: [
				isLeftMost := isLeftMost and: [node parent elements first = node].
				isRightMost := isRightMost and: [node parent elements last = node]].
			node isTSPrecedence ifTrue: [^ aBlock value: node value: isLeftMost value: isRightMost]]].
	
	^ anotherBlock value
]

{ #category : #hierarchy }
SBTSNodeBase >> parentThat: aBlock [

	self andParentsDo: [:p | (aBlock value: p) ifTrue: [^ p]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> precedence [

	^ self parentThat: [:p | p isTSPrecedence]
]

{ #category : #testing }
SBTSNodeBase >> prefixValidFor: aString in: aSiblingsCollection [

	^ false
]

{ #category : #hierarchy }
SBTSNodeBase >> replaceBy: aNode [

	self replaceBy: aNode toplevelDo: [:n | self error: 'attempted to replace a top-level child']
]

{ #category : #hierarchy }
SBTSNodeBase >> replaceBy: aNode toplevelDo: aBlock [

	aNode field ifNil: [aNode field: self field].
	
	self parent ifNil: [^ aBlock value: aNode].
	self parent elements: (self parent elements
		at: (self parent elements indexOf: self) put: aNode;
		yourself).
	aNode parent: self parent.
	self parent: nil
]

{ #category : #parsing }
SBTSNodeBase >> resultsFor: aParser [

	^ self subclassResponsibility
]

{ #category : #parsing }
SBTSNodeBase >> resultsForBlocks: aParser [

	^ self subclassResponsibility
]

{ #category : #hierarchy }
SBTSNodeBase >> root [

	^ self parent ifNil: [self] ifNotNil: [:p | p root]
]

{ #category : #parsing }
SBTSNodeBase >> takeNodesFrom: aParser [

	^ self subclassResponsibility
]

{ #category : #hierarchy }
SBTSNodeBase >> transitionRoot [

	| current |
	current := self.
	[current parent notNil and: [current parent isTSChoice or: [current parent isTSSeq and: [current parent elements size = 1]]]] whileTrue: [current := current parent].
	^ current
]

{ #category : #hierarchy }
SBTSNodeBase >> traverseBlocks: aStream do: aBlock [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSNodeBase >> type [

	^ nil
]

{ #category : #testing }
SBTSNodeBase >> validFor: aString in: aSiblingsCollection [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> veryDeepInner: deepCopier [

	super veryDeepInner: deepCopier.
	parent := parent veryDeepCopyWith: deepCopier.
	field := field veryDeepCopyWith: deepCopier
]
