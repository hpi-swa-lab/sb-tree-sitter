Class {
	#name : #SBTSNodeChoice,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'alternatives'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #accessing }
SBTSNodeChoice >> allChildrenDo: aBlock [

	aBlock value: self.
	self alternatives do: [:alt | alt allChildrenDo: aBlock]
]

{ #category : #accessing }
SBTSNodeChoice >> alternatives [

	^ alternatives
]

{ #category : #accessing }
SBTSNodeChoice >> alternatives: aCollection [

	alternatives := aCollection.
	alternatives do: [:alt | alt parent: self]
]

{ #category : #printing }
SBTSNodeChoice >> buildEmpty [

	^ {SBTSUnknownBlock new slot: (SBTSSlot new addNode: self)}
]

{ #category : #printing }
SBTSNodeChoice >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock [
	"check if there is an unknown for this choice"

	aCollection
		detect: [:block | block isTSBlock and: [block isUnknown and: [block slot includesParent: self]]]
		ifFound: [:b |
			aClosure value: (SBCursorSelect new block: b).
			aBoolean ifFalse: [b cursorPositionsDo: aClosure shallow: aBoolean]]
		ifNone: ["otherwise just descend"
		self alternatives do: [:child | child cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock]]
]

{ #category : #testing }
SBTSNodeChoice >> isTSChoice [

	^ true
]

{ #category : #printing }
SBTSNodeChoice >> printOn: aStream [

	aStream nextPut: $(.
	self alternatives
		do: [:alt | aStream print: alt]
		separatedBy: [aStream nextPutAll: ' | '].
	aStream nextPut: $)
]

{ #category : #parsing }
SBTSNodeChoice >> resultsFor: aParser [

	^ (Array streamContents: [:stream |
		self alternatives do: [:alt | | parserCopy results |
			parserCopy := aParser copy.
			results := alt resultsFor: parserCopy.
			results = #noMatch ifFalse: [results do: [:result | stream nextPut: result]]]]) ifEmpty: [#noMatch]
]

{ #category : #parsing }
SBTSNodeChoice >> takeNodesFrom: aParser [

	^ (Array streamContents: [:stream |
		self alternatives do: [:alt | | parserCopy results |
			parserCopy := aParser copy.
			results := alt takeNodesFrom: parserCopy.
			results = #noMatch ifFalse: [results do: [:result | stream nextPut: result]]]]) ifEmpty: [#noMatch]
]

{ #category : #printing }
SBTSNodeChoice >> writeSourceOn: aStream indent: aNumber [

	self firstSubmorph writeSourceOn: aStream indent: aNumber
]
