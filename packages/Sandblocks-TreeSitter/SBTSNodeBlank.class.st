Class {
	#name : #SBTSNodeBlank,
	#superclass : #SBTSNodeBase,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> allChildrenDo: aBlock [

	aBlock value: self
]

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> allElementsDo: aBlock [

	aBlock value: self
]

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> elements [

	^ #()
]

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> isTSBlank [

	^ true
]
