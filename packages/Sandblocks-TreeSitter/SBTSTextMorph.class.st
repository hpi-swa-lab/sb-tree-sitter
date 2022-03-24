Class {
	#name : #SBTSTextMorph,
	#superclass : #SBMultilineOwnTextMorph,
	#instVars : [
		'slot'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSTextMorph >> canBeEmpty [

	^ self regex matches: ''
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> childrenForQuery [
	"remove inline block compat"

	self flag: #todo.
	^ #()
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> contents: aString [

	super contents: aString.
	self owner ifNotNil: #clearCache
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> copyBlock [

	^ self class new
		contents: self contents;
		slot: self slot
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> factory [

	^ (self slot ifNil: [self parentSandblock slot]) factory
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
SBTSTextMorph >> keepDuringTransform [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> language [

	^ self factory name
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> regex [

	^ self slot firstNode regex
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> repeaterGroup [
	"copied from SBTSBlock, not sure about the right semantics yet"

	self flag: #todo.
	
	self slot repeater ifNotNil: [:repeater | | myIndex mySubIndex seq start |
		myIndex := self submorphIndex.
		self flag: #todo.
		" does not consider nested repeats and nested seqs "
		seq := self slot parentThat: [:p | p isTSSeq and: [p hasParent: repeater]].
		seq ifNil: [^ {self}].
		mySubIndex := (self slot parentThat: [:p | p parent = seq]) in: [:c | c parent elements indexOf: c].
		start := myIndex - mySubIndex + 1.
		^ self owner submorphs copyFrom: start to: start + seq elements size - 1].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> slot [

	^ slot
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> slot: aSlot [

	self assert: (aSlot isNil or: [aSlot class = SBTSSlot]).
	slot := aSlot
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> sourceString [

	^ self contents
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> submorphIndex [

	^ self owner submorphs indexOf: self
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> wrapOffscreen: anEditor [

	
]

{ #category : #'as yet unclassified' }
SBTSTextMorph >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	aStream nextPutAll: ((aBoolean and: [self contents isEmpty and: [self canBeEmpty not]])
		ifTrue: [String value: 0]
		ifFalse: [self contents])
]
