Class {
	#name : #SBTSLabel,
	#superclass : #SBStringMorph,
	#instVars : [
		'slot'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSLabel >> copyBlock [

	^ self class new
		contents: self contents;
		slot: self slot
]

{ #category : #'as yet unclassified' }
SBTSLabel >> slot [

	^ slot
]

{ #category : #'as yet unclassified' }
SBTSLabel >> slot: aSlot [

	self assert: aSlot class = SBTSSlot.
	slot := aSlot
]
