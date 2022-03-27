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

	^ anObject isSandblock and: [
		anObject isTSBlock and: [
			SBToggledCode comment: '' active: 1 do: {
				[slot lastNode type = anObject slot lastNode type].
				[slot compatibleWithType: anObject slot lastNode type]}]]
]
