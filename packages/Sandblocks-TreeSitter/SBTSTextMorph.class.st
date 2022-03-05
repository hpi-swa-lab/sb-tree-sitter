Class {
	#name : #SBTSTextMorph,
	#superclass : #SBMultilineOwnTextMorph,
	#instVars : [
		'slot'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSTextMorph >> slot [

	^ slot
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> slot: aSlot [

	self assert: aSlot class = SBTSSlot.
	slot := aSlot
]
