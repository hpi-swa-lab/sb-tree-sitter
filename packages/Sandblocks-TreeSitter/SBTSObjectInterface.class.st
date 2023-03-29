Class {
	#name : #SBTSObjectInterface,
	#superclass : #Object,
	#instVars : [
		'slot',
		'at'
	],
	#category : #'Sandblocks-TreeSitter-Utils'
}

{ #category : #'as yet unclassified' }
SBTSObjectInterface >> at [

	^ at
]

{ #category : #'as yet unclassified' }
SBTSObjectInterface >> at: aCursor [

	at := aCursor
]

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
	((anObject slot includesParent: slot lastNode transitionRoot) and: [SBTSInputParser new canInsert: anObject for: slot transitionRoot]) ifTrue: [^ true].
	^ false
]
