Class {
	#name : #SBTSTextMorph,
	#superclass : #SBMultilineOwnTextMorph,
	#instVars : [
		'slot'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSTextMorph >> childrenForQuery [
	"remove inline block compat"

	self flag: #todo.
	^ #()
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> copyBlock [

	^ self class new
		contents: self contents;
		slot: self slot
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> field [

	^ self slot field
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> isTSSymbol [
	"remove inline block compat"

	self flag: #todo.
	^ false
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> language [

	^ self slot factory name
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> slot [

	^ slot
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> slot: aSlot [

	self assert: (aSlot class = SBTSSlot or: [aSlot isNil]).
	slot := aSlot
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> sourceString [

	^ self contents
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> writeSourceOn: aStream indent: aNumber [

	aStream nextPutAll: self contents
]
