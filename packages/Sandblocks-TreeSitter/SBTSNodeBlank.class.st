Class {
	#name : #SBTSNodeBlank,
	#superclass : #SBTSNodeBase,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> allChildrenDo: aBlock [

	
]

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> elements [

	^ #()
]

{ #category : #'as yet unclassified' }
SBTSNodeBlank >> isTSBlank [

	^ true
]
