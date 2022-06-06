Class {
	#name : #SBTSNodePrecedence,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'element',
		'precedence',
		'value'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> allChildrenDo: aBlock [

	aBlock value: self.
	self element allChildrenDo: aBlock
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
SBTSNodePrecedence >> compareTo: aPrecedence [

	(self value isInteger and: [aPrecedence value isInteger]) ifTrue: [^ (self value - aPrecedence value) sign].
	
	self factory grammar precedences do: [:precedences | | sawLeft sawRight |
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
SBTSNodePrecedence >> isTSPrecedence [

	^ true
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
	aStream nextPutAll: ': '.
	self element printOn: aStream.
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> resultsFor: aParser [

	^ self element resultsFor: aParser
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> takeNodesFrom: aParser [

	^ element takeNodesFrom: aParser
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> value [

	^ value
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> value: aNumber [

	value := aNumber
]
