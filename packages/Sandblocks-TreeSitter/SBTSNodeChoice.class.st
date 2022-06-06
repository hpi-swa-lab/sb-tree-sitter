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
SBTSNodeChoice >> allElementsDo: aBlock [

	aBlock value: self.
	self alternatives do: [:alt | alt allElementsDo: aBlock]
]

{ #category : #hierarchy }
SBTSNodeChoice >> allSubTypesDo: aBlock parents: aCollection [

	self alternatives do: [:element | element allSubTypesDo: aBlock parents: aCollection]
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

{ #category : #copying }
SBTSNodeChoice >> basicCopy [

	^ super basicCopy alternatives: self alternatives
]

{ #category : #printing }
SBTSNodeChoice >> buildEmpty [

	^ {SBTSUnknownBlock new slot: (SBTSSlot with: self)}
]

{ #category : #'as yet unclassified' }
SBTSNodeChoice >> buildEmptyNodes [

	^ {SBTSParseNode kind: #unknown slot: (SBTSSlot with: self) contents: nil}
]

{ #category : #printing }
SBTSNodeChoice >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock [
	"check if there is an unknown for this choice"

	(aStream peek isTSBlock and: [aStream peek isUnknown and: [aStream peek slot firstNode = self]])
		ifTrue: [ | block |
			block := aStream next.
			aClosure value: (SBCursorSelect new block: block).
			aBoolean ifFalse: [block cursorPositionsDo: aClosure shallow: aBoolean]]
		ifFalse: [
			self alternatives
				detect: [:alt | aStream peek slot includesParent: alt effectiveNode]
				ifFound: [:alt | alt cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock]]
]

{ #category : #accessing }
SBTSNodeChoice >> elements [

	^ self alternatives
]

{ #category : #accessing }
SBTSNodeChoice >> elements: aCollection [

	self alternatives: aCollection
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

	^ self alternatives gather: [:alt | alt resultsFor: aParser copy]
]

{ #category : #parsing }
SBTSNodeChoice >> takeNodesFrom: aParser [

	^ Array streamContents: [:stream |
		self alternatives do: [:alt | | parserCopy results |
			parserCopy := aParser copy.
			results := alt takeNodesFrom: parserCopy.
			results do: [:result | stream nextPut: result]]]
]

{ #category : #hierarchy }
SBTSNodeChoice >> traverseBlocks: aStream do: aBlock [

	(aStream peek isTSBlock and: [aStream peek isUnknown and: [aStream peek slot firstNode = self]])
		ifTrue: [ | block |
			block := aStream next.
			aBlock value: block]
		ifFalse: [
			self alternatives
				detect: [:alt | aStream peek slot includesParent: alt]
				ifFound: [:alt | alt traverseBlocks: aStream do: aBlock]]
]

{ #category : #printing }
SBTSNodeChoice >> writeSourceOn: aStream indent: aNumber [

	self firstSubmorph writeSourceOn: aStream indent: aNumber
]
