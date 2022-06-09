Class {
	#name : #SBTSObjectInterface,
	#superclass : #Object,
	#instVars : [
		'slot'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSObjectInterface >> slot [

	^ slot
]

{ #category : #'as yet unclassified' }
SBTSObjectInterface >> slot: aSlot [

	slot := aSlot
]

{ #category : #'as yet unclassified' }
SBTSObjectInterface >> value: anObject [

	(anObject isSandblock and: [anObject isTSBlock]) ifFalse: [^ false].
	(anObject slot includesParent: slot lastNode transitionRoot) ifTrue: [^ true].
	^ false
]
