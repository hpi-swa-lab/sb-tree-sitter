Class {
	#name : #SBTSNodeChoice,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'alternatives'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #accessing }
SBTSNodeChoice >> allChildrenDo: aBlock visited: aSet [

	aBlock value: self.
	self alternatives do: [:alt | alt allChildrenDo: aBlock visited: aSet]
]

{ #category : #accessing }
SBTSNodeChoice >> allElementsDo: aBlock [

	aBlock value: self.
	self alternatives do: [:alt | alt allElementsDo: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSNodeChoice >> allSubTypes [

	^ self alternatives select: [:alt | alt isTSSymbol]
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

	^ (self language defaultChoiceDuringInputFor: self)
		ifNotNil: [:choice | choice buildEmptyNodes]
		ifNil: [{SBTSParseNode kind: #unknown slot: (SBTSSlot with: self) contents: nil}]
]

{ #category : #printing }
SBTSNodeChoice >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock [
	"check if there is an unknown for this choice"

	aStream atEnd ifTrue: [^ self].
	
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
SBTSNodeChoice >> labelPrintOn: aStream [

	(self elements select: [:e | e hidden not])
		do: [:element | element labelPrintOn: aStream]
		separatedBy: [aStream nextPutAll: ' or ']
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
SBTSNodeChoice >> resultsForBlocks: aParser [

	^ Array streamContents: [:stream | self alternatives do: [:alt | (alt resultsForBlocks: aParser copy) do: [:result | stream nextPut: result]]]
	"this version would work if we had ordered choice. for example, python patterns are rougly defined as
		identifier ',' | (identifier ',')+
	so given an input such as a,b=... the first choice successfully parses the input but when descending realize that we did not consume all input
	| results |
	results := OrderedCollection new: 1.
	self alternatives do: [:alt | | currentPosition |
		currentPosition := aParser position.
		(alt resultsForBlocks: aParser copy) do: [:result |
			results add: result.
			result position > currentPosition ifTrue: [^ results]]].
	^ results"
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
