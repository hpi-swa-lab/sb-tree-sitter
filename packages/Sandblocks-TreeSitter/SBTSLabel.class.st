Class {
	#name : #SBTSLabel,
	#superclass : #SBStringMorph,
	#instVars : [
		'slot'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSLabel >> allConnectionsDo: aBlock [

	
]

{ #category : #'as yet unclassified' }
SBTSLabel >> childrenForQuery [
	"remove inline block compat"

	self flag: #todo.
	^ #()
]

{ #category : #'as yet unclassified' }
SBTSLabel >> copyBlock [

	| copy |
	copy := self class new
		contents: self contents;
		slot: self slot.
	self
		valueOfProperty: #lastConstructed
		ifPresentDo: [:val | copy setProperty: #lastConstructed toValue: true].
	^ copy
]

{ #category : #'as yet unclassified' }
SBTSLabel >> field [

	^ self slot field
]

{ #category : #'as yet unclassified' }
SBTSLabel >> isTSSymbol [
	"remove inline block compat"

	self flag: #todo.
	^ false
]

{ #category : #'as yet unclassified' }
SBTSLabel >> keepDuringTransform [

	^ false
]

{ #category : #'as yet unclassified' }
SBTSLabel >> language [

	^ self slot factory name
]

{ #category : #'as yet unclassified' }
SBTSLabel >> repeaterGroup [

	^ {self}
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

{ #category : #'as yet unclassified' }
SBTSLabel >> sourceString [

	^ self contents
]

{ #category : #'as yet unclassified' }
SBTSLabel >> sourceStringForCompare [

	^ String streamContents: [:s | self writeSourceOn: s indent: 0 forCompare: true]
]

{ #category : #'as yet unclassified' }
SBTSLabel >> wrapOffscreen: anEditor [

	
]

{ #category : #'as yet unclassified' }
SBTSLabel >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	aStream nextPutAll: self contents
]
