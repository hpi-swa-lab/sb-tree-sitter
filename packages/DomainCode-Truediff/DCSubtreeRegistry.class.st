Class {
	#name : #DCSubtreeRegistry,
	#superclass : #Object,
	#instVars : [
		'subtrees'
	],
	#category : #'DomainCode-Truediff'
}

{ #category : #'as yet unclassified' }
DCSubtreeRegistry >> assignShare: aNode [

	| share |
	aNode assigned: nil.
	share := subtrees at: aNode structureHash ifAbsentPut: [DCSubtreeShare new].
	aNode share: share.
	^ share
]

{ #category : #'as yet unclassified' }
DCSubtreeRegistry >> assignShareAndRegisterTree: aNode [

	| share |
	share := self assignShare: aNode.
	share registerAvailableTree: aNode.
	^ share
]

{ #category : #'as yet unclassified' }
DCSubtreeRegistry >> initialize [

	subtrees := Dictionary new
]
