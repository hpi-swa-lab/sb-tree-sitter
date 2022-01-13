Class {
	#name : #SBTSNodeTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeTest >> input: aString in: aNode [

	^ aNode
]

{ #category : #'as yet unclassified' }
SBTSNodeTest >> testTypeNumber [

	| expr number |
	expr := SBTSSmalltalk instance buildNodesForRule: 'expression'.
	number := self input: '1' in: expr.
	self assert: 'number' equals: number type
]
