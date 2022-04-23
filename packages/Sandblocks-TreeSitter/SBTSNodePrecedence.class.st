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
SBTSNodePrecedence >> allSubTypesDo: aBlock parents: aCollection [

	self element allSubTypesDo: aBlock parents: aCollection
]

{ #category : #'as yet unclassified' }
SBTSNodePrecedence >> buildEmpty [

	^ self element buildEmpty
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
SBTSNodePrecedence >> value: aNumber [

	value := aNumber
]
