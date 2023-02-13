Class {
	#name : #SBTSNodePrecedence,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'element',
		'precedence',
		'value'
	],
	#category : #'Sandblocks-TreeSitter-Grammar'
}

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> allChildrenDo: aBlock visited: aSet [

	aBlock value: self.
	self element allChildrenDo: aBlock visited: aSet
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> allElementsDo: aBlock [

	aBlock value: self.
	self element allElementsDo: aBlock
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> allSubTypesDo: aBlock parents: aCollection [

	self element allSubTypesDo: aBlock parents: aCollection
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> associativity [

	^ precedence caseOf: {
		['PREC_LEFT'] -> [#left].
		['PREC_RIGHT'] -> [#right].
		['PREC_DYNAMIC'] -> [#none].
		['PREC'] -> [#none]}
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> buildEmpty [

	^ self element buildEmpty
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> buildEmptyNodes [

	^ self element buildEmptyNodes
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> canExpandInStack: aCollection [

	SBToggledCode comment: '' active: 0 do: {
		[((aCollection anySatisfy: [:c | c hasParentThat: [:x | x isTSPrecedence and: [x value = 'member']]]) and: [value = 'call']) ifTrue: [self halt]]}.
	
	^ self
		parentPrecedence: aCollection
		do: [:parentPrec :isLeftMost :isRightMost | | comp hasActiveRecursion |
			comp := parentPrec compareTo: self ifNotComparable: [-1].
			
			hasActiveRecursion := SBToggledCode comment: '' active: 3 do: {
				[true].
				[aCollection anySatisfy: [:node | node hasParentThat: [:p | p = self parent]]].
				["FIXME: we should probably check if these are involved in this precise precedence contest"
				(aCollection collect: #type) withoutDuplicates size < aCollection size]}.
			
			hasActiveRecursion not or: [comp < 0 or: [comp = 0 and: [(self isLeftAssociative and: [isLeftMost]) or: [parentPrec isRightAssociative and: [isRightMost]]]]]]
		ifNone: [true]
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> compareTo: aPrecedence ifNotComparable: aBlock [

	(self value isInteger and: [aPrecedence value isInteger]) ifTrue: [^ (self value - aPrecedence value) sign].
	
	self value isInteger = aPrecedence value isInteger ifFalse: [^ aBlock value].
	
	self factory precedences do: [:precedences | | sawLeft sawRight |
		sawLeft := false.
		sawRight := false.
		precedences do: [:entry | | matchesLeft matchesRight |
			matchesLeft := self value = (entry at: #value).
			matchesRight := aPrecedence value = (entry at: #value).
			matchesLeft
				ifTrue: [
					sawLeft := true.
					sawRight ifTrue: [^ -1]]
				ifFalse: [
					matchesRight ifTrue: [
						sawRight := true.
						sawLeft ifTrue: [^ 1]]]]].
	^ 0
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock [

	self element cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> element [

	^ element
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> element: aNode [

	element := aNode.
	aNode parent: self
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> hasEqualStructure: aNode [

	^ (super hasEqualStructure: aNode) and: [aNode precedence = self precedence and: [aNode value = self value]]
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> isLeftAssociative [

	^ precedence = 'PREC_LEFT'
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> isRightAssociative [

	^ precedence = 'PREC_RIGHT'
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> isTSPrecedence [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> labelPrintOn: aStream [

	self element labelPrintOn: aStream
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> parentPrecedence: aCollection do: aBlock ifNone: anotherBlock [

	| isLeftMost potentialConflict isRightMost |
	isLeftMost := true.
	isRightMost := true.
	potentialConflict := false.
	
	aCollection reverseDo: [:root |
		root andParentsDo: [:node |
			(node parent notNil and: [node parent isTSSeq]) ifTrue: [
				isLeftMost := isLeftMost and: [node parent elements first = node].
				isRightMost := isRightMost and: [node parent elements last = node].
				
				SBToggledCode comment: '' active: 1 do: {
					[
						potentialConflict ifFalse: [
							potentialConflict := self element elements notEmpty and: [
								((isRightMost and: [node type = self element elements first type]) or: [isLeftMost and: [node type = self element elements last type]]) and: [
									(aCollection last isSubTypeOf: node stack: aCollection reversed) and: [
										(aCollection before: root ifAbsent: [aCollection last])
											isSubTypeOf: node
											stack: aCollection reversed]]]]]}].
			SBToggledCode comment: '' active: 0 do: {
				[
					(node isTSSeq and: [potentialConflict not]) ifTrue: [
						node elements first type ifNotNil: [
							potentialConflict := self element elements notEmpty and: [
								node elements first type = self element elements last type and: [
									(aCollection last isSubTypeOf: node elements first stack: aCollection reversed) and: [
										(aCollection before: root ifAbsent: [aCollection last])
											isSubTypeOf: node elements first
											stack: aCollection reversed]]]].
						node elements last type ifNotNil: [
							potentialConflict := self element elements notEmpty and: [
								node elements last type = self element elements first type and: [
									(aCollection last isSubTypeOf: node elements last stack: aCollection reversed) and: [
										(aCollection before: root ifAbsent: [aCollection last])
											isSubTypeOf: node elements last
											stack: aCollection reversed]]]]]]}.
			node isTSPrecedence ifTrue: [
				potentialConflict
					ifTrue: [^ aBlock value: node value: isLeftMost value: isRightMost]
					ifFalse: [
						"this one wasn't a conflict, let's check the next one"
						isLeftMost := true.
						isRightMost := true]]]].
	
	^ anotherBlock value
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> precedence [

	^ precedence
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> precedence: aString [

	precedence := aString
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> printOn: aStream [

	aStream nextPut: $(.
	aStream nextPutAll: precedence.
	aStream nextPut: $[.
	aStream print: value.
	aStream nextPutAll: ']: '.
	self element printOn: aStream.
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> resultsFor: aParser [

	^ (self precedence = 'PREC_DYNAMIC' or: [ | recursing |
		recursing := (aParser symbolStack collect: #type) withoutDuplicates size < aParser symbolStack size.
		self canExpandInStack: aParser symbolStack])
		ifTrue: [self element resultsFor: aParser]
		ifFalse: [{}]
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> resultsForBlocks: aParser [

	^ element resultsForBlocks: aParser
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> takeNodesFrom: aParser [

	^ element takeNodesFrom: aParser
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> traverseBlocks: aStream do: aBlock [

	self element traverseBlocks: aStream do: aBlock
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> value [

	^ value
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> value: aNumber [

	value := aNumber
]
