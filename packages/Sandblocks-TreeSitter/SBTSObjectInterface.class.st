Class {
	#name : #SBTSObjectInterface,
	#superclass : #Object,
	#instVars : [
		'slot'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSObjectInterface >> slot: aSlot [

	slot := aSlot
]

{ #category : #'as yet unclassified' }
SBTSObjectInterface >> value: anObject [

	^ anObject isSandblock and: [anObject isTSBlock and: [anObject slot lastNode = slot lastNode]]
]
