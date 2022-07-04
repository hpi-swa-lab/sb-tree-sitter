Class {
	#name : #SBTSNodeBlank,
	#superclass : #SBTSNodeBase,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> allChildrenDo: aBlock visited: aSet [

	aBlock value: self
]

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> allElementsDo: aBlock [

	aBlock value: self
]

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> buildMorphWith: aBlock slot: aSlot [

	^ {}
]

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> elements [

	^ #()
]

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> isTSBlank [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> labelPrintOn: aStream [

	aStream nextPut: (Character value: 0)
]
